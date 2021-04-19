SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_ReportTemperatureScore_190626]
(
	@vids NVARCHAR(MAX) = NULL,
	@gids NVARCHAR(MAX) = NULL,
	@sdate DATETIME,
	@edate DATETIME,
	@sensorid SMALLINT = NULL,
	@uid UNIQUEIDENTIFIER
)
AS

-- 19/07/16 gp/as added 2 additional over temperature bands 

--DECLARE @vids NVARCHAR(MAX),
--		@gids NVARCHAR(MAX),
--		@sdate DATETIME,
--		@edate DATETIME,
--		@sensorid SMALLINT,
--		@uid UNIQUEIDENTIFIER

--SET @vids = N'486A43F1-70D9-46CC-A745-542B6A4D77CE'
--SET @gids = N'906E3BAD-7739-44B1-8966-28F8D4F10A09' 
--SET @sdate = '2017-08-24 00:00'
--SET @edate = '2017-08-30 23:59'
--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'

DECLARE @lvids NVARCHAR(MAX),
		@lgids NVARCHAR(MAX),
		@lsdate DATETIME,
		@ledate DATETIME,
		@lsensorid SMALLINT,
		@luid UNIQUEIDENTIFIER
		
SET @lvids = @vids
SET @lgids = @gids
SET @lsdate = @sdate
SET @ledate = @edate
SET @lsensorid = @sensorid
SET @luid = @uid

DECLARE @tempmult FLOAT,
		@liquidmult FLOAT,
		@templimit FLOAT,
		@tempdepart FLOAT,
		@productsensorid SMALLINT,
		@internalsensorid SMALLINT,
		@externalsensorid SMALLINT,
		@stime TIME,
		@etime TIME
    
-- Set 'real' departure and return time limits
-- Use today's date by default so that DST time conversion is applied p[roperly
SET @stime = dbo.TZ_TimeToUtc('05:00', NULL, DEFAULT, @uid)
SET @etime = dbo.TZ_TimeToUtc('20:00', NULL, DEFAULT, @uid)

SET @tempmult = ISNULL([dbo].[UserPref](@luid, 214),1)
SET @liquidmult = ISNULL([dbo].[UserPref](@luid, 200),1)
-- Sensor Id and Temperature Limit are currently hard-coded
SET @internalsensorid = 1
SET @productsensorid = 2
SET @externalsensorid = 4
SET @templimit = -18.0
SET @tempdepart = -25.0
SET @lsdate = dbo.TZ_ToUtc(@lsdate, DEFAULT, @luid)
SET @ledate = dbo.TZ_ToUtc(@ledate, DEFAULT, @luid)


-- Create a temporary table for real geofence exits / entries for the required vehicles
DECLARE @RealTrips TABLE
(
	VehicleIntId INT,
	GeofenceId UNIQUEIDENTIFIER,
	ExitDateTime DATETIME,
	ExitEventId BIGINT,
	EntryDateTime DATETIME,
	EntryEventId BIGINT,
	ExitSeconds BIGINT,
	OverLimitDuration BIGINT
)
INSERT INTO @RealTrips (VehicleIntId, GeofenceId, ExitDateTime, ExitEventId, EntryDateTime, EntryEventId, ExitSeconds)
SELECT DISTINCT gexit.VehicleIntId AS vehicleIntId, gexit.GeofenceId AS GeofenceId, gexit.ExitDateTime, gexit.ExitEventId, gentry.EntryDateTime, gentry.EntryEventId, DATEDIFF(ss, gexit.ExitDateTime, gentry.EntryDateTime) AS ExitSeconds
FROM

	(SELECT ROW_NUMBER() OVER (PARTITION BY VehicleIntId, vgh.GeofenceId ORDER BY EntryDateTime) AS RowNum, vgh.*
	FROM dbo.VehicleGeofenceHistory vgh
	INNER JOIN dbo.Geofence geo ON geo.GeofenceId = vgh.GeofenceId AND geo.IsTemperatureMonitored = 1
	WHERE EntryDateTime BETWEEN @lsdate AND @ledate OR ExitDateTime BETWEEN @lsdate AND @ledate
	--WHERE ExitDateTime BETWEEN @lsdate AND @ledate
	  ) gexit
	  
INNER JOIN 

	(SELECT ROW_NUMBER() OVER (PARTITION BY VehicleIntId, vgh.GeofenceId ORDER BY EntryDateTime) AS RowNum, vgh.*
	FROM dbo.VehicleGeofenceHistory vgh
	INNER JOIN dbo.Geofence geo ON geo.GeofenceId = vgh.GeofenceId AND geo.IsTemperatureMonitored = 1
	WHERE EntryDateTime BETWEEN @lsdate AND @ledate OR ExitDateTime BETWEEN @lsdate AND @ledate
	--WHERE EntryDateTime BETWEEN @lsdate AND @ledate
	  ) gentry ON gexit.VehicleIntId = gentry.VehicleIntId AND gexit.GeofenceId = gentry.GeofenceId AND gentry.RowNum = gexit.RowNum + 1
	  
INNER JOIN dbo.Vehicle v ON gexit.VehicleIntId = v.VehicleIntId
--INNER JOIN dbo.GroupDetail gd ON v.VehicleId = gd.EntityDataId
--INNER JOIN dbo.[Group] g ON gd.GroupId = g.GroupId
WHERE DATEDIFF(ss, gexit.ExitDateTime, gentry.EntryDateTime) BETWEEN 2700 AND 50400 -- Real trips are between 30mins and 14 hours in duration
  --AND CAST(gexit.ExitDateTime AS FLOAT) - FLOOR(CAST(gexit.ExitDateTime AS FLOAT)) > CAST(@stime AS FLOAT)
  --AND CAST(gentry.EntryDateTime AS FLOAT) - FLOOR(CAST(gentry.EntryDateTime AS FLOAT)) < CAST(@etime AS FLOAT)
  AND CAST(gexit.ExitDateTime AS TIME) > @stime
  AND CAST(gentry.EntryDateTime AS TIME) < @etime
  AND v.VehicleId IN (SELECT VALUE FROM dbo.Split(@lvids, ','))

--SELECT *
--FROM @RealTrips

-- Remove real trips where the vehicle was checked out
DELETE	
FROM @RealTrips	
--SELECT rt.*
FROM @RealTrips rt
INNER JOIN dbo.TAN_EntityCheckOut tec ON dbo.GetVehicleIdFromInt(rt.VehicleIntId) = tec.EntityId 
												  AND (rt.ExitDateTime BETWEEN tec.CheckOutDateTime AND tec.CheckInDateTime OR rt.EntryDateTime BETWEEN tec.CheckOutDateTime AND tec.CheckInDateTime)

--SELECT *
--FROM @RealTrips

-- Use table variable to identify vehicles required and get associated sensor scaling factor and total time outside geofences
DECLARE @VehicleScaling TABLE (
	GroupId UNIQUEIDENTIFIER,
	VehicleIntId INT,
	InternalScaleFactor FLOAT,
	ProductScaleFactor FLOAT,
	ExternalScaleFactor FLOAT,
	OutsideTime BIGINT )
INSERT INTO @VehicleScaling (GroupId, VehicleIntId, InternalScaleFactor, ProductScaleFactor, ExternalScaleFactor, OutsideTime)
SELECT g.GroupId, v.VehicleIntId, vsi.AnalogSensorScalefactor, vsp.AnalogSensorScaleFactor, vse.AnalogSensorScaleFactor, SUM(rt.ExitSeconds)--DATEDIFF(ss, @lsdate, @ledate) - SUM(DATEDIFF(ss, CASE WHEN vgh.EntryDateTime < @lsdate THEN @lsdate ELSE vgh.EntryDateTime END, CASE WHEN ISNULL(vgh.ExitDateTime, @ledate) > @ledate THEN @ledate ELSE ISNULL(vgh.ExitDateTime, @ledate) END))
--FROM dbo.VehicleGeofenceHistory vgh
--INNER JOIN dbo.CustomerGeofence cg ON vgh.GeofenceId = cg.GeofenceId
--INNER JOIN dbo.[User] u ON cg.CustomerID = u.CustomerID
FROM dbo.Vehicle v 
INNER JOIN @RealTrips rt ON v.VehicleIntId = rt.VehicleIntId
--LEFT JOIN dbo.TAN_EntityCheckOut tec ON v.VehicleId = tec.EntityId 
--												  AND tec.CheckOutDateTime <= @ledate AND ISNULL(tec.CheckInDateTime, @ledate) >= @lsdate
----												  AND tec.CheckOutReason NOT IN ('Abtauen','Dégelé','Sbrinare')
INNER JOIN dbo.GroupDetail gd ON v.VehicleId = gd.EntityDataId
INNER JOIN dbo.[Group] g ON gd.GroupId = g.GroupId
INNER JOIN dbo.VehicleSensor vsi ON v.VehicleIntId = vsi.VehicleIntId AND vsi.SensorId = @internalsensorid
INNER JOIN dbo.VehicleSensor vsp ON v.VehicleIntId = vsp.VehicleIntId AND vsp.SensorId = @productsensorid
INNER JOIN dbo.VehicleSensor vse ON v.VehicleIntId = vse.VehicleIntId AND vse.SensorId = @externalsensorid
WHERE v.VehicleId IN (SELECT VALUE FROM dbo.Split(@lvids, ','))
  AND gd.GroupId IN (SELECT VALUE	FROM dbo.Split(@lgids, ','))
--  AND vgh.EntryDateTime <= @ledate
--  AND vgh.ExitDateTime >= @lsdate
  AND v.Archived = 0
  AND g.IsParameter = 0
  AND g.GroupTypeId = 1
  AND g.Archived = 0
--  AND (tec.EntityId IS NULL -- only include entities that are NOT checked out 
--   OR tec.EntityId = v.VehicleId AND rt.ExitDateTime NOT BETWEEN tec.CheckOutDateTime AND ISNULL(tec.CheckInDateTime, @ledate))
----  AND u.UserID = @luid
GROUP BY g.GroupId, v.VehicleIntId, vsi.AnalogSensorScaleFactor, vsp.AnalogSensorScaleFactor, vse.AnalogSensorScaleFactor

--SELECT *
--FROM @VehicleScaling
--
--SELECT *
--FROM dbo.TAN_EntityCheckOut
--WHERE EntityId = @vids
--  AND CheckOutDateTime <= @ledate AND ISNULL(CheckInDateTime, @ledate) >= @lsdate


SELECT	g.GroupName, 
		v.Registration, 
		vs.OutsideTime, 
		ISNULL(SUM(nce.OverLimitDuration),0) AS OverTempDuration,
		ISNULL(SUM(nce.OverLimit2Duration),0) AS OverTemp2Duration,
		ISNULL(SUM(nce.OverLimit3Duration),0) AS OverTemp3Duration,
		ISNULL(checkout.CheckOutCount,0) + ISNULL(releases.Released,0) - ISNULL(checkout.DefrostCount,0) AS Confirmed,
		ISNULL(SUM(alarms.AlarmCount),0) - (ISNULL(checkout.CheckOutCount,0)  - ISNULL(checkout.DefrostCount,0) + ISNULL(releases.Released,0)) AS NonConfirmed,
		dbo.ScaleConvertAnalogValue(AVG(nce.AnalogData1AvgInside),vs.ProductScaleFactor, @tempmult, @liquidmult) AS AvgProductTempInside,
		dbo.ScaleConvertAnalogValue(AVG(nce.AnalogData1AvgOutside),vs.ProductScaleFactor, @tempmult, @liquidmult) AS AvgProductTempOutside,
		dbo.ScaleConvertAnalogValue(AVG(nce.AnalogData3AvgOutside),vs.ExternalScaleFactor, @tempmult, @liquidmult) AS AvgExternalTempOutside,
		ISNULL(checkout.DefrostCount,0) AS DefrostCount
FROM @VehicleScaling vs
INNER JOIN dbo.Vehicle v ON vs.VehicleIntId = v.VehicleIntId
INNER JOIN dbo.[Group] g ON vs.GroupId = g.GroupId
INNER JOIN dbo.ReportingNCE nce ON vs.VehicleIntId = nce.VehicleIntId
INNER JOIN @RealTrips rt ON rt.VehicleIntId = nce.VehicleIntId AND FLOOR(CAST(rt.ExitDateTime AS FLOAT)) = FLOOR(CAST(nce.Date AS FLOAT))

-- The following line is intended to exclude outlier data (where the sensors are marked invalid).
-- We test T1 (the Product Sensor) as this is the sensor that drives the KPIs (additional sensors can be addde if required)
INNER JOIN dbo.Maintenance m ON m.VehicleIntId = nce.VehicleIntId AND nce.Date = m.Date AND m.T1 = 1

--INNER JOIN (SELECT VehicleIntId, SUM(OverDepartTemp) AS OverDepartTemp
--			FROM
--				(SELECT 
--					vs.VehicleIntId,
--					CASE WHEN dbo.ScaleConvertAnalogValue(CASE @internalsensorid WHEN 1 THEN eout.AnalogData0 WHEN 2 THEN eout.AnalogData1 WHEN 3 THEN eout.AnalogData2 WHEN 4 THEN eout.AnalogData3 END, vs.InternalScaleFactor, @tempmult, @liquidmult) > @tempdepart THEN 1 ELSE 0 END AS OverDepartTemp
-- 				FROM @VehicleScaling vs
--				INNER JOIN @RealTrips rt ON vs.VehicleIntId = rt.VehicleIntId
--								AND rt.GeofenceId IN (SELECT cg.GeofenceId
--														FROM dbo.CustomerGeofence cg
--														INNER JOIN dbo.[User] u ON cg.CustomerID = u.CustomerID
--														WHERE u.UserID = @luid)
--				LEFT JOIN dbo.Event eout ON rt.ExitEventId = eout.EventId
--				WHERE ISNULL(rt.ExitDateTime, @ledate) BETWEEN @lsdate AND @ledate) overtemp
--			GROUP BY overtemp.VehicleIntId) overtempcounts ON vs.VehicleIntId = overtempcounts.VehicleIntId
LEFT JOIN  (SELECT vs.VehicleIntId, ISNULL(SUM(CAST(ISNULL(ts.Ack, 0) AS INT)),0) AS Released
			FROM @VehicleScaling vs
			INNER JOIN dbo.TemperatureStatus ts ON vs.VehicleIntId = dbo.GetVehicleIntFromId(ts.VehicleId)
			WHERE ts.AckDateTime BETWEEN @lsdate AND @ledate
			GROUP BY vs.VehicleIntId) releases ON vs.VehicleIntId = releases.VehicleIntId			
LEFT JOIN  (SELECT vs.VehicleIntId, SUM(CASE WHEN tec.CheckOutReason IN ('Abtauen','Dégelé','Sbrinare') THEN 1 ELSE 0 END) AS DefrostCount,
			COUNT(*) AS CheckOutCount
			FROM @VehicleScaling vs
			INNER JOIN dbo.TAN_EntityCheckOut tec ON vs.VehicleIntId = dbo.GetVehicleIntFromId(tec.EntityId)
--			WHERE tec.CheckOutDateTime BETWEEN @lsdate AND @ledate
			WHERE tec.CheckOutDateTime <= @ledate AND ISNULL(tec.CheckInDateTime, @ledate) >= @lsdate
			GROUP BY vs.VehicleIntId) checkout ON vs.VehicleIntId = checkout.VehicleIntId
LEFT JOIN  (SELECT vs.VehicleIntId, nce.Date, SUM(CASE WHEN dbo.ScaleConvertAnalogValue(nce.AnalogData1Timed, vs.ProductScaleFactor, @tempmult, @liquidmult) > -25 THEN 1 ELSE 0 END) AS AlarmCount
			FROM @VehicleScaling vs
			INNER JOIN dbo.ReportingNCE nce ON vs.VehicleIntId = nce.VehicleIntId
			LEFT JOIN dbo.TAN_EntityCheckOut tec ON vs.VehicleIntId = dbo.GetVehicleIntFromId(tec.EntityId)
															  AND tec.CheckOutDateTime <= @ledate AND ISNULL(tec.CheckInDateTime, @ledate) >= @lsdate
			WHERE nce.Date BETWEEN @lsdate AND @ledate
			  AND tec.EntityId IS NULL
			GROUP BY vs.VehicleIntId, nce.Date) alarms ON vs.VehicleIntId = alarms.VehicleIntId AND nce.date = alarms.Date
WHERE nce.Date BETWEEN @lsdate AND @ledate
GROUP BY g.GroupName, v.Registration, vs.OutsideTime, 
releases.Released, 
--overtempcounts.OverDepartTemp, 
checkout.DefrostCount, checkout.CheckOutCount, 
vs.InternalScaleFactor, vs.ProductScaleFactor, vs.ExternalScaleFactor
ORDER BY g.GroupName, v.Registration

GO
