SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_ReportNCE_Temperature]
(
	@gid UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME,
	@sensorid SMALLINT = NULL,
	@uid UNIQUEIDENTIFIER
)
AS

--DECLARE @gid UNIQUEIDENTIFIER,
--		@sdate DATETIME,
--		@edate DATETIME,
--		@sensorid SMALLINT,
--		@uid UNIQUEIDENTIFIER
		
----SET @gid = N'BAF921F3-4DF1-42EA-993C-B583484F5554' -- CH 0000 Test Groupe
----SET @gid = N'F0F5ED40-A37B-4718-863D-FECA640FC5CD' -- CH 0030 Lausen
----SET @gid = N'B04062C4-67FA-41A9-9BFC-4776782653B4' -- CH 0025 Rümlang
----SET @gid = N'906E3BAD-7739-44B1-8966-28F8D4F10A09' -- CH 0024 Rorschach
--SET @gid = N'35DE2A6C-15B9-4F2C-BC3A-66CD1A7CA813' -- OOH Mitte Nuernberg
--SET @sdate = '2016-12-19 00:00'
--SET @edate = '2016-12-19 23:59'
--SET @uid = N'D4F3B463-2926-4171-A162-54684C7F0600'

DECLARE @tempmult FLOAT,
		@liquidmult FLOAT,
		@templimit FLOAT,
		@tempdepart FLOAT,
		@departtime DATETIME,
		@VehicleCount FLOAT,
		@productsensorid SMALLINT,
		@internalsensorid SMALLINT,
		@stime DATETIME,
		@etime DATETIME,
		@FleetOutside FLOAT,
		@FleetOverLimit FLOAT
    
-- Set 'real' departure and return time limits
-- Use today's date so that DST time conversion is applied p[roperly
SET @stime = dbo.TZ_ToUtc(CAST(CONVERT(VARCHAR(11), GETDATE(), 120) + '05:00' AS DATETIME), DEFAULT, @uid)
SET @etime = dbo.TZ_ToUtc(CAST(CONVERT(VARCHAR(11), GETDATE(), 120) + '20:00' AS DATETIME), DEFAULT, @uid)
-- Now convert to 1900-01-01 date so that time comparisons using FLOOR will function correctly later
SET @stime = '1900-01-01 ' + CONVERT(VARCHAR(5), @stime, 114)
SET @etime = '1900-01-01 ' + CONVERT(VARCHAR(5), @etime, 114)

SET @tempmult = ISNULL([dbo].[UserPref](@uid, 214),1)
SET @liquidmult = ISNULL([dbo].[UserPref](@uid, 200),1)
-- Sensor Id and Temperature Limit are currently hard-coded
SET @internalsensorid = 1
SET @productsensorid = 2
SET @templimit = -18.0
SET @tempdepart = -25.0

SET @departtime = dbo.TZ_ToUtc(CAST(CONVERT(CHAR(10), @edate, 120) + ' 05:00' AS DATETIME),DEFAULT,@uid) -- set to 5am
SET @sdate = dbo.TZ_ToUtc(@sdate, DEFAULT, @uid)
SET @edate = dbo.TZ_ToUtc(@edate, DEFAULT, @uid)

-- Create a table structure to hold output results so that can all be returned in a single dataset
DECLARE @ResultSet TABLE (
	MorningAvgTemp FLOAT,
	MorningPercentageGood FLOAT,
	Unauthorised INT,
	Released INT,
	AvgDepartTemp FLOAT,
	DepartPercentageGood FLOAT,
	OverTempTime INT,
	TripPercentageGood FLOAT,
	AvgArrivalTemp FLOAT,
	ArrivalPercentageGood FLOAT,
	DefrostCount INT,
	DefrostOther FLOAT,
	GroupScore FLOAT,
	FleetScore FLOAT,
	OutsideTime INT)

-- Create a temporary table for real geofence exits / entries for the required vehicles
DECLARE @RealTrips TABLE
(
	VehicleIntId INT,
	GeofenceId UNIQUEIDENTIFIER,
	ExitDateTime DATETIME,
	ExitEventId BIGINT,
	EntryDateTime DATETIME,
	EntryEventId BIGINT,
	ExitSeconds INT,
	OverLimitDuration INT
)
INSERT INTO @RealTrips (VehicleIntId, GeofenceId, ExitDateTime, ExitEventId, EntryDateTime, EntryEventId, ExitSeconds)
SELECT DISTINCT gexit.VehicleIntId AS vehicleIntId, gexit.GeofenceId AS GeofenceId, gexit.ExitDateTime, gexit.ExitEventId, gentry.EntryDateTime, gentry.EntryEventId, DATEDIFF(ss, gexit.ExitDateTime, gentry.EntryDateTime) AS ExitSeconds
FROM

	(SELECT ROW_NUMBER() OVER (PARTITION BY VehicleIntId, vgh.GeofenceId ORDER BY EntryDateTime) AS RowNum, vgh.*
	FROM dbo.VehicleGeofenceHistory vgh
	INNER JOIN dbo.Geofence geo ON geo.GeofenceId = vgh.GeofenceId AND geo.IsTemperatureMonitored = 1
	WHERE EntryDateTime BETWEEN @sdate AND @edate OR ExitDateTime BETWEEN @sdate AND @edate
	  ) gexit
	  
INNER JOIN 

	(SELECT ROW_NUMBER() OVER (PARTITION BY VehicleIntId, vgh.GeofenceId ORDER BY EntryDateTime) AS RowNum, vgh.*
	FROM dbo.VehicleGeofenceHistory vgh
	INNER JOIN dbo.Geofence geo ON geo.GeofenceId = vgh.GeofenceId AND geo.IsTemperatureMonitored = 1
	WHERE EntryDateTime BETWEEN @sdate AND @edate OR ExitDateTime BETWEEN @sdate AND @edate
	  ) gentry ON gexit.VehicleIntId = gentry.VehicleIntId AND gexit.GeofenceId = gentry.GeofenceId AND gentry.RowNum = gexit.RowNum + 1
	  
INNER JOIN dbo.Vehicle v ON gexit.VehicleIntId = v.VehicleIntId
INNER JOIN dbo.GroupDetail gd ON v.VehicleId = gd.EntityDataId
INNER JOIN dbo.[Group] g ON gd.GroupId = g.GroupId
WHERE DATEDIFF(ss, gexit.ExitDateTime, gentry.EntryDateTime) BETWEEN 2700 AND 50400 -- Real trips are between 30mins and 14 hours in duration
  AND CAST(gexit.ExitDateTime AS FLOAT) - FLOOR(CAST(gexit.ExitDateTime AS FLOAT)) > CAST(@stime AS FLOAT)
  AND CAST(gentry.EntryDateTime AS FLOAT) - FLOOR(CAST(gentry.EntryDateTime AS FLOAT)) < CAST(@etime AS FLOAT)
--  AND gd.GroupId = @gid

-- Use table variable to identify vehicles required and get associated sensor scaling factor and total time outside geofences
DECLARE @VehicleScaling TABLE (
	GroupId UNIQUEIDENTIFIER,
	VehicleIntId INT,
	ProductScaleFactor FLOAT,
	InternalScalefactor FLOAT,
	OutsideTime INT )
INSERT INTO @VehicleScaling (GroupId, VehicleIntId, ProductScaleFactor, InternalScalefactor, OutsideTime)
SELECT g.GroupId, v.VehicleIntId, vsp.AnalogSensorScaleFactor, vsi.AnalogSensorScaleFactor, SUM(rt.ExitSeconds)--DATEDIFF(ss, @sdate, @edate) - SUM(DATEDIFF(ss, CASE WHEN vgh.EntryDateTime < @sdate THEN @sdate ELSE vgh.EntryDateTime END, CASE WHEN ISNULL(vgh.ExitDateTime, @edate) > @edate THEN @edate ELSE ISNULL(vgh.ExitDateTime, @edate) END))
--FROM dbo.VehicleGeofenceHistory vgh
--INNER JOIN dbo.CustomerGeofence cg ON vgh.GeofenceId = cg.GeofenceId
--INNER JOIN dbo.[User] u ON cg.CustomerID = u.CustomerID
FROM dbo.Vehicle v 
INNER JOIN @RealTrips rt ON v.VehicleIntId = rt.VehicleIntId
INNER JOIN dbo.GroupDetail gd ON v.VehicleId = gd.EntityDataId
INNER JOIN dbo.[Group] g ON gd.GroupId = g.GroupId
INNER JOIN dbo.VehicleSensor vsp ON v.VehicleIntId = vsp.VehicleIntId AND vsp.SensorId = @productsensorid
INNER JOIN dbo.VehicleSensor vsi ON v.VehicleIntId = vsi.VehicleIntId AND vsi.SensorId = @internalsensorid
WHERE gd.GroupId = @gid
--  AND vgh.EntryDateTime <= @edate
--  AND vgh.ExitDateTime >= @sdate
  AND rt.ExitDateTime > @sdate
  AND rt.EntryDateTime < @edate
  AND v.Archived = 0
  AND g.IsParameter = 0
  AND g.GroupTypeId = 1
  AND g.Archived = 0
--  AND u.UserID = @uid
GROUP BY g.GroupId, v.VehicleIntId, vsp.AnalogSensorScaleFactor, vsi.AnalogSensorScaleFactor

INSERT INTO @ResultSet (MorningAvgTemp, MorningPercentageGood, OverTempTime) --, TripPercentageGood, OutsideTime)
SELECT	AVG(InternalAnalogdata), 
		1 - (CAST(SUM(InternalOverTemp) AS FLOAT)/CASE WHEN CAST(COUNT(*) AS FLOAT) = 0 THEN NULL ELSE CAST(COUNT(*) AS FLOAT) END),
		ISNULL(SUM(OverLimitDuration),0)
FROM
	(SELECT	nce.VehicleIntId,
			nce.Date,
			nce.OverLimitDuration,
			vs.OutsideTime,
			dbo.ScaleConvertAnalogValue(CASE @productsensorid WHEN 1 THEN nce.AnalogData0Timed WHEN 2 THEN nce.AnalogData1Timed WHEN 3 THEN nce.AnalogData2Timed WHEN 4 THEN nce.AnalogData3Timed END, vs.ProductScaleFactor, @tempmult, @liquidmult) AS ProductAnalogData,
			dbo.ScaleConvertAnalogValue(CASE @internalsensorid WHEN 1 THEN nce.AnalogData0Timed WHEN 2 THEN nce.AnalogData1Timed WHEN 3 THEN nce.AnalogData2Timed WHEN 4 THEN nce.AnalogData3Timed END, vs.InternalScalefactor, @tempmult, @liquidmult) AS InternalAnalogData,
			CASE WHEN dbo.ScaleConvertAnalogValue(CASE @productsensorid WHEN 1 THEN nce.AnalogData0Timed WHEN 2 THEN nce.AnalogData1Timed WHEN 3 THEN nce.AnalogData2Timed WHEN 4 THEN nce.AnalogData3Timed END, vs.ProductScaleFactor, @tempmult, @liquidmult) > @tempdepart THEN 1 ELSE 0 END AS ProductOverTemp,
			CASE WHEN dbo.ScaleConvertAnalogValue(CASE @internalsensorid WHEN 1 THEN nce.AnalogData0Timed WHEN 2 THEN nce.AnalogData1Timed WHEN 3 THEN nce.AnalogData2Timed WHEN 4 THEN nce.AnalogData3Timed END, vs.InternalScaleFactor, @tempmult, @liquidmult) > @tempdepart THEN 1 ELSE 0 END AS InternalOverTemp
	FROM dbo.ReportingNCE nce
	INNER JOIN @VehicleScaling vs ON nce.VehicleIntId = vs.VehicleIntId

	-- The following line is intended to exclude outlier data (where the sensors are marked invalid).
	-- We test T1 (the Product Sensor) as this is the sensor that drives the KPIs (additional sensors can be addde if required)
	INNER JOIN dbo.Maintenance m ON m.VehicleIntId = nce.VehicleIntId AND nce.Date = m.Date AND m.T1 = 1

	WHERE nce.Date BETWEEN @sdate AND @edate) morning

UPDATE @ResultSet
SET OutsideTime = (SELECT SUM(OutsideTime) FROM @VehicleScaling)

UPDATE @ResultSet
SET TripPercentageGood = 1 - (CAST(OverTempTime AS FLOAT) / CASE WHEN OutsideTime = 0 THEN NULL ELSE CAST(OutsideTime AS FLOAT) END),
	GroupScore = 1 - (CAST(OverTempTime AS FLOAT) / CASE WHEN OutsideTime = 0 THEN NULL ELSE CAST(OutsideTime AS FLOAT) END)

UPDATE @ResultSet
SET AvgDepartTemp = final.AvgDepartTemp, DepartPercentageGood = final.DepartPercentageGood, 
	AvgArrivalTemp = final.AvgArrivalTemp, ArrivalPercentageGood = final.ArrivalPercentageGood,
	Unauthorised = final.Unauthorised, Released = final.Released
FROM	
	(SELECT	
			AVG(InternalDepartTemp) AS AvgDepartTemp,
			(1 - (CAST(SUM(InternalOverDepartTemp) AS FLOAT)/CASE WHEN CAST(COUNT(VehicleIntId) AS FLOAT) = 0 THEN NULL ELSE CAST(COUNT(VehicleIntId) AS FLOAT) END)) AS DepartPercentageGood,
			SUM(Released) AS Released,
			SUM(InternalOverDepartTemp) - SUM(Released) AS Unauthorised,
			AVG(ProductArriveTemp) AS AvgArrivalTemp,
			(1 - (CAST(SUM(ProductOverArriveTemp) AS FLOAT)/CASE WHEN CAST(COUNT(VehicleIntId) AS FLOAT) = 0 THEN NULL ELSE CAST(COUNT(VehicleIntId) AS FLOAT) END)) AS ArrivalPercentageGood
	FROM
		(SELECT 
			vs.VehicleIntId,
			dbo.ScaleConvertAnalogValue(CASE @productsensorid WHEN 1 THEN eout.AnalogData0 WHEN 2 THEN eout.AnalogData1 WHEN 3 THEN eout.AnalogData2 WHEN 4 THEN eout.AnalogData3 END, vs.ProductScaleFactor, @tempmult, @liquidmult) AS ProductDepartTemp,
			dbo.ScaleConvertAnalogValue(CASE @internalsensorid WHEN 1 THEN eout.AnalogData0 WHEN 2 THEN eout.AnalogData1 WHEN 3 THEN eout.AnalogData2 WHEN 4 THEN eout.AnalogData3 END, vs.InternalScaleFactor, @tempmult, @liquidmult) AS InternalDepartTemp,
			CASE WHEN dbo.ScaleConvertAnalogValue(CASE @productsensorid WHEN 1 THEN eout.AnalogData0 WHEN 2 THEN eout.AnalogData1 WHEN 3 THEN eout.AnalogData2 WHEN 4 THEN eout.AnalogData3 END, vs.ProductScaleFactor, @tempmult, @liquidmult) > @tempdepart THEN 1 ELSE 0 END AS ProductOverDepartTemp,
			CASE WHEN dbo.ScaleConvertAnalogValue(CASE @internalsensorid WHEN 1 THEN eout.AnalogData0 WHEN 2 THEN eout.AnalogData1 WHEN 3 THEN eout.AnalogData2 WHEN 4 THEN eout.AnalogData3 END, vs.InternalScaleFactor, @tempmult, @liquidmult) > @tempdepart THEN 1 ELSE 0 END AS InternalOverDepartTemp,
			CAST(ISNULL(ts.Ack, 0) AS INT) AS Released,
			dbo.ScaleConvertAnalogValue(CASE @productsensorid WHEN 1 THEN ein.AnalogData0 WHEN 2 THEN ein.AnalogData1 WHEN 3 THEN ein.AnalogData2 WHEN 4 THEN ein.AnalogData3 END, vs.ProductScaleFactor, @tempmult, @liquidmult) AS ProductArriveTemp,
			dbo.ScaleConvertAnalogValue(CASE @internalsensorid WHEN 1 THEN ein.AnalogData0 WHEN 2 THEN ein.AnalogData1 WHEN 3 THEN ein.AnalogData2 WHEN 4 THEN ein.AnalogData3 END, vs.InternalScaleFactor, @tempmult, @liquidmult) AS InternalArriveTemp,
			CASE WHEN dbo.ScaleConvertAnalogValue(CASE @productsensorid WHEN 1 THEN ein.AnalogData0 WHEN 2 THEN ein.AnalogData1 WHEN 3 THEN ein.AnalogData2 WHEN 4 THEN ein.AnalogData3 END, vs.ProductScaleFactor, @tempmult, @liquidmult) > @templimit THEN 1 ELSE 0 END AS ProductOverArriveTemp,
			CASE WHEN dbo.ScaleConvertAnalogValue(CASE @internalsensorid WHEN 1 THEN ein.AnalogData0 WHEN 2 THEN ein.AnalogData1 WHEN 3 THEN ein.AnalogData2 WHEN 4 THEN ein.AnalogData3 END, vs.InternalScaleFactor, @tempmult, @liquidmult) > @templimit THEN 1 ELSE 0 END AS InternalOverArriveTemp
 		FROM @VehicleScaling vs
 		
 		INNER JOIN (
			SELECT VehicleIntId, GeofenceId, FLOOR(CAST(ExitDateTime as float)) AS Date, MIN(ExitDateTime) AS FirstExit, MIN(ExitEventId) AS ExitEventId, MAX(EntryDateTime) AS LastEntry, MAX(EntryEventId) AS EntryEventId
			FROM @RealTrips
			GROUP BY VehicleIntId, GeofenceId, FLOOR(CAST(ExitDateTime as float))
					) rt ON vs.vehicleIntId = rt.VehicleIntId 	
 						AND rt.GeofenceId IN (SELECT cg.GeofenceId
												FROM dbo.CustomerGeofence cg
												INNER JOIN dbo.[User] u ON cg.CustomerID = u.CustomerID
												WHERE u.UserID = @uid)
		LEFT JOIN dbo.Event ein ON rt.EntryEventId = ein.EventId
		LEFT JOIN dbo.Event eout ON rt.ExitEventId = eout.EventId
		LEFT JOIN dbo.TemperatureStatus ts ON vs.VehicleIntId = dbo.GetVehicleIntFromId(ts.VehicleId) AND ts.AckDateTime BETWEEN @sdate AND @edate
		WHERE rt.FirstExit BETWEEN @sdate AND @edate) stat
	) final
	
SELECT @VehicleCount = COUNT(*) FROM @VehicleScaling
UPDATE @ResultSet
SET DefrostCount = summary.DefrostCount, DefrostOther = summary.DefrostCount/CASE WHEN @VehicleCount = 0 THEN NULL ELSE @VehicleCount END
FROM 
	(SELECT COUNT(*) AS DefrostCount
	FROM dbo.TAN_EntityCheckOut t
	INNER JOIN @VehicleScaling vs ON vs.VehicleIntId = dbo.GetVehicleIntFromId(t.EntityId)
	WHERE t.CheckOutDateTime BETWEEN DATEADD(dd, -30, @edate) AND @edate
	  AND t.CheckOutReason IN ('Defrosting','Abtauen','Dégelé','Sbrinare')
	  ) summary

-- Now calculate FleetScore
SELECT @FleetOverLimit = ISNULL(SUM(OverLimitDuration),0)
FROM dbo.ReportingNCE nce
INNER JOIN dbo.Vehicle v ON nce.VehicleIntId = v.VehicleIntId

-- The following line is intended to exclude outlier data (where the sensors are marked invalid).
-- We test T1 (the Product Sensor) as this is the sensor that drives the KPIs (additional sensors can be addde if required)
INNER JOIN dbo.Maintenance m ON m.VehicleIntId = nce.VehicleIntId AND nce.Date = m.Date AND m.T1 = 1

WHERE nce.Date BETWEEN @sdate AND @edate
  AND v.VehicleId IN (SELECT VALUE FROM dbo.Split(dbo.GetFleetVids(@uid), ','))
  
SELECT @FleetOutside = SUM(ExitSeconds)
FROM @RealTrips
	
UPDATE @ResultSet
SET FleetScore = 1 - (@FleetOverLimit / CASE WHEN @FleetOutside = 0 THEN NULL ELSE @FleetOutside END)

SELECT	@sdate AS sdate, 
		@edate AS edate,
		dbo.TZ_GetTime(@sdate, DEFAULT, @uid) AS CreationDateTime,
		dbo.TZ_GetTime(@edate, DEFAULT, @uid) AS ClosureDateTime,
		*
FROM @ResultSet
GO
