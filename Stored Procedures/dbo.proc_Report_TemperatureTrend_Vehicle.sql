SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_Report_TemperatureTrend_Vehicle]
(
	@vids varchar(max), 
	@sdate datetime,
	@edate datetime,
	@routeid INT,
	@vehicletypeid INT,	
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER,
	@drilldown TINYINT,
	@calendar TINYINT,
	@groupBy INT
)
AS

--DECLARE @vids varchar(max),
--		@routeid INT,
--		@vehicletypeid INT,	
--		@sdate datetime,
--		@edate datetime,
--		@uid UNIQUEIDENTIFIER,
--		@rprtcfgid UNIQUEIDENTIFIER,
--		@drilldown TINYINT,
--		@calendar TINYINT,
--		@groupBy INT
		
--SET @vids = N'5AAB0E74-D39E-483B-AAFF-200FB5A56850,1860348D-20B5-42CF-BA66-203864BA0461,BD5F9889-8007-4943-9001-46CB3ED2D36F,4DA5FA6D-8496-4D75-AA6A-4C32B377BDF9,C5868274-5850-4762-8EA8-5B5B7C1C2B5B,BD15D85F-F591-4AB5-881A-65E296715D18,33A67A70-9935-4214-B7B0-69B7AC228F5C,46F9F76A-1324-474B-B0BD-6E160C3E8ACD,EB5F8AE0-FC95-4D38-87FE-801C22911CA6,2D68CB77-FE15-4030-839A-824B6D0806BA,9A615ECD-2389-4D20-B0BE-8667626A38BA,CF6E7729-C9E7-4373-BEAB-895D9A2F1379,8288801A-186F-4BE4-A044-8A4007BD2372,0BBEF81F-92A9-4183-A354-8B15F4B354DD,AE9AD52F-7659-4339-BB56-A39AC3923A54,DF0D3E78-19EB-4779-BAE8-A974FE4F1B33,F5F18987-540E-44A0-A9EB-BC42699EFA30,2E7A5E82-702A-4003-BB17-C072A93ED941,18750389-36C6-4D3E-BE79-C54B859CE83B,2C63EBDD-07D4-4F26-A3A4-C5E18DBCB5CF,0A293ED6-5DE5-4B92-BDF0-C8357DF9003D,D103A123-A2A2-4EF1-97DF-D184E971FE7B,C98B01D1-B2E7-4378-A1A4-D5245CDDDF0D,3AAEA81D-20C4-4F24-B022-DECA9C7C51B1,5081472D-203E-4F21-9CF8-E1F98619361A,6913DDBF-6FAC-4E5B-A33D-0D61CA692791,53B878DA-091D-4722-B467-1463EE502C19,04D11745-A145-4215-A432-2A5061B9DC17,2C38D238-E1A6-4E08-B419-345ACB40930F,FA6E62CA-3470-4F73-A32D-3C79BF6206A9,339C8146-9790-4CFE-B974-5819ECC299C0,C83D509F-26C0-4ED6-9D12-5C5D9716789D,8780C077-1BCB-4EF9-AC7A-6D763D0B5721,FB0C91E1-401B-427B-B3EE-7AC8A4294BF3,7DE5AA38-2BA3-4C8F-A488-911911DA6F80,0FADC446-F107-4EF5-B23A-93CF7EA917E7,5C77C772-4FCA-4040-BDF7-942B2E153FFF,B88446F6-CDEE-456D-9896-9743AEDD4D9A,8C2E8B0E-E258-4F27-8BE6-9EE90EF08614,DB306411-629E-445B-8FE9-9FE65C285296,4723BA01-21CE-4FFB-85E7-A754BF858BC7,97E3C42B-0940-404F-B0FE-E4AD4981E728,76EE70C2-598A-4C1F-85C0-E5A102CD70F2,B7EEE367-B07C-4441-86EF-EB7E5613F7EF,7B27F3D7-3BAC-40AC-9B30-ED9211329331'
--SET @vehicletypeid = NULL
--SET @routeid = NULL
--SET	@sdate = '2016-04-01 00:00'
--SET	@edate = '2016-06-30 23:59'
--SET	@uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
--SET	@rprtcfgid = N'6FAD9660-775F-4E1D-94B2-613CD4F94D65'
--SET @drilldown = 1
--SET @calendar = 0
--SET @groupBy = 0

DECLARE @lvids varchar(max),
		@lrouteid INT,
		@lvehicletypeid INT,	
		@lsdate datetime,
		@ledate datetime,
		@luid UNIQUEIDENTIFIER,
		@lrprtcfgid UNIQUEIDENTIFIER,
		@ldrilldown TINYINT,
		@lcalendar TINYINT,
		@lgroupBy INT
SET @lvids = @vids
SET @lrouteid = @routeid
SET @lvehicletypeid = @vehicletypeid
SET @lsdate = @sdate
SET @ledate = @edate
SET @luid = @uid
SET @lrprtcfgid = @rprtcfgid
SET @ldrilldown = @drilldown
SET @lcalendar = @calendar
SET @lgroupBy = @groupBy

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

-- Determine period sizes based upon provided start date and end date total duration -- use dates in user time zone

CREATE TABLE #period_dates (
		PeriodNum TINYINT IDENTITY (1,1),
		StartDate DATETIME,
		EndDate DATETIME,
		PeriodType VARCHAR(MAX))
CREATE NONCLUSTERED INDEX [IX_period_dates] ON [dbo].[#period_dates] 
(
	[StartDate] ASC,
	[EndDate] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
      
INSERT  INTO #period_dates ( StartDate, EndDate, PeriodType )
		SELECT  StartDate,
				EndDate,
				PeriodType
		FROM    dbo.CreateDependentDateRange(@lsdate, @ledate, @luid, @ldrilldown, @lcalendar, @lgroupBy)

-- Convert dates to UTC
SET @lsdate = [dbo].TZ_ToUTC(@lsdate,default,@luid)
SET @ledate = [dbo].TZ_ToUTC(@ledate,default,@luid)

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

-- Remove real trips where the vehicle was checked out
DELETE	
FROM @RealTrips	
FROM @RealTrips rt
INNER JOIN dbo.TAN_EntityCheckOut tec ON dbo.GetVehicleIdFromInt(rt.VehicleIntId) = tec.EntityId AND rt.ExitDateTime BETWEEN tec.CheckOutDateTime AND tec.CheckInDateTime

DECLARE @VehicleScaling TABLE (
	VehicleId UNIQUEIDENTIFIER,
	VehicleIntId INT,
	InternalScaleFactor FLOAT,
	ProductScaleFactor FLOAT,
	ExternalScaleFactor FLOAT )
INSERT INTO @VehicleScaling (VehicleId, VehicleIntId, InternalScaleFactor, ProductScaleFactor, ExternalScaleFactor)
SELECT v.VehicleId, v.VehicleIntId, vsi.AnalogSensorScalefactor, vsp.AnalogSensorScaleFactor, vse.AnalogSensorScaleFactor
FROM dbo.Vehicle v 
INNER JOIN dbo.VehicleSensor vsi ON v.VehicleIntId = vsi.VehicleIntId AND vsi.SensorId = @internalsensorid
INNER JOIN dbo.VehicleSensor vsp ON v.VehicleIntId = vsp.VehicleIntId AND vsp.SensorId = @productsensorid
INNER JOIN dbo.VehicleSensor vse ON v.VehicleIntId = vse.VehicleIntId AND vse.SensorId = @externalsensorid
WHERE v.VehicleId IN (SELECT VALUE FROM dbo.Split(@lvids, ','))
  AND v.Archived = 0
GROUP BY v.VehicleId, v.VehicleIntId, vsi.AnalogSensorScaleFactor, vsp.AnalogSensorScaleFactor, vse.AnalogSensorScaleFactor

SELECT  p.PeriodNum,
		[dbo].TZ_GetTime(p.StartDate,default,@luid) AS WeekStartDate,
		[dbo].TZ_GetTime(p.EndDate,default,@luid) AS WeekEndDate,
		p.PeriodType,
        NULL AS GroupID,
        NULL AS GroupName,
		v.VehicleId,	
		v.Registration,
        Result.OutsideTime,
        Result.WeakestPercentage,
        Result.AveragePercentage,
        Result.TotalOverTempDuration,
        Result.WeakestOverTempDuration,
        Result.Confirmed,
        Result.NonConfirmed,
		dbo.ScaleConvertAnalogValue(Result.AvgProductTempInside, Result.ProductScaleFactor, @tempmult, @liquidmult) AS AvgProductTempInside,
		dbo.ScaleConvertAnalogValue(Result.AvgProductTempOutside, Result.ProductScaleFactor, @tempmult, @liquidmult) AS AvgProductTempOutside,
		dbo.ScaleConvertAnalogValue(Result.AvgExternalTempOutside, Result.ExternalScaleFactor, @tempmult, @liquidmult) AS AvgExternalTempOutside,
        Result.DefrostCount
FROM    (SELECT	CASE WHEN (GROUPING(p.PeriodNum) = 1) THEN NULL
		          ELSE ISNULL(p.PeriodNum, NULL)
	          END AS PeriodNum,
		
	          CASE WHEN (GROUPING(vs.VehicleId) = 1) THEN NULL
		          ELSE ISNULL(vs.VehicleId, NULL)
	          END AS VehicleId,

	          MAX(outside.OutsideTime) AS OutsideTime, 
			  MAX(ISNULL(CAST(nce.OverLimitDuration AS FLOAT),0)/CASE WHEN outside.OutsideTime = 0 THEN NULL ELSE outside.OutsideTime END) AS WeakestPercentage,
			  SUM(ISNULL(CAST(nce.OverLimitDuration AS FLOAT),0))/CASE WHEN SUM(outside.OutsideTime) = 0 THEN NULL ELSE SUM(outside.OutsideTime) END AS AveragePercentage,
	          NULL AS TotalOverTempDuration,
	          MAX(ISNULL(CAST(nce.OverLimitDuration AS FLOAT),0)) AS WeakestOverTempDuration,
	          SUM(ISNULL(releases.Released,0)) AS Confirmed,
	          SUM(ISNULL(overtempcounts.OverDepartTemp,0)) - SUM(ISNULL(releases.Released,0)) AS NonConfirmed,
	          AVG(CAST(nce.AnalogData1AvgInside AS FLOAT)) AS AvgProductTempInside,
	          AVG(CAST(nce.AnalogData1AvgOutside AS FLOAT)) AS AvgProductTempOutside,
	          AVG(CAST(nce.AnalogData3AvgOutside AS FLOAT)) AS AvgExternalTempOutside,
			  MAX(vs.ProductScaleFactor) AS ProductScaleFactor,
			  MAX(vs.ExternalScaleFactor) AS ExternalScaleFactor,
	          SUM(ISNULL(defrost.DefrostCount,0)) AS DefrostCount
        FROM @VehicleScaling vs
        INNER JOIN dbo.GroupDetail gd ON vs.VehicleId = gd.EntityDataId
        INNER JOIN dbo.ReportingNCE nce ON vs.VehicleIntId = nce.VehicleIntId

		-- The following line is intended to exclude outlier data (where the sensors are marked invalid).
		-- We test T1 (the Product Sensor) as this is the sensor that drives the KPIs (additional sensors can be addde if required)
		LEFT JOIN dbo.Maintenance m ON m.VehicleIntId = nce.VehicleIntId AND nce.Date = m.Date AND m.T1 = 1

		INNER JOIN #period_dates p ON nce.Date BETWEEN p.StartDate AND p.EndDate
        LEFT JOIN (SELECT PeriodNum, VehicleIntId, SUM(OverDepartTemp) AS OverDepartTemp
                    FROM
	                    (SELECT p.PeriodNum, vs.VehicleIntId,
		                    CASE WHEN dbo.ScaleConvertAnalogValue(CASE @internalsensorid WHEN 1 THEN eout.AnalogData0 WHEN 2 THEN eout.AnalogData1 WHEN 3 THEN eout.AnalogData2 WHEN 4 THEN eout.AnalogData3 END, vs.InternalScaleFactor, @tempmult, @liquidmult) > @tempdepart THEN 1 ELSE 0 END AS OverDepartTemp
						FROM @VehicleScaling vs
						INNER JOIN @RealTrips rt ON vs.VehicleIntId = rt.VehicleIntId
										AND rt.GeofenceId IN (SELECT cg.GeofenceId
																FROM dbo.CustomerGeofence cg
																INNER JOIN dbo.[User] u ON cg.CustomerID = u.CustomerID
																WHERE u.UserID = @luid)
						LEFT JOIN dbo.Event eout ON rt.ExitEventId = eout.EventId
						INNER JOIN #period_dates p ON rt.exitdatetime BETWEEN p.StartDate AND p.EndDate AND rt.EntryDateTime BETWEEN p.StartDate AND p.EndDate
						WHERE ISNULL(rt.ExitDateTime, @ledate) BETWEEN @lsdate AND @ledate) overtemp
						GROUP BY overtemp.PeriodNum, overtemp.VehicleIntId) overtempcounts ON vs.VehicleIntId = overtempcounts.VehicleIntId AND p.PeriodNum = overtempcounts.PeriodNum
        LEFT JOIN  (SELECT p.PeriodNum, vs.VehicleIntId, ISNULL(SUM(CAST(ISNULL(ts.Ack, 0) AS INT)),0) AS Released
                    FROM @VehicleScaling vs
                    INNER JOIN dbo.TemperatureStatus ts ON vs.VehicleIntId = dbo.GetVehicleIntFromId(ts.VehicleId)
                    INNER JOIN #period_dates p ON ts.AckDateTime BETWEEN p.StartDate AND p.EndDate
                    WHERE ts.AckDateTime BETWEEN @lsdate AND @ledate
                    GROUP BY p.PeriodNum, vs.VehicleIntId) releases ON vs.VehicleIntId = releases.VehicleIntId AND p.PeriodNum = releases.PeriodNum		
        LEFT JOIN  (SELECT p.PeriodNum, vs.VehicleIntId, COUNT(*) AS DefrostCount
                    FROM @VehicleScaling vs
                    INNER JOIN dbo.TAN_EntityCheckOut tec ON vs.VehicleIntId = dbo.GetVehicleIntFromId(tec.EntityId)
                    INNER JOIN #period_dates p ON tec.CheckOutDateTime BETWEEN p.StartDate AND p.EndDate
                    WHERE tec.CheckOutDateTime BETWEEN @lsdate AND @ledate
                      AND tec.CheckOutReason IN ('Defrosting','Abtauen','Dégelé','Sbrinare')
                    GROUP BY p.PeriodNum, vs.VehicleIntId) defrost ON vs.VehicleIntId = defrost.VehicleIntId AND p.PeriodNum = defrost.PeriodNum 
        LEFT JOIN  (SELECT p.PeriodNum, vs.VehicleIntId, SUM(rt.ExitSeconds) AS OutsideTime
                    FROM @VehicleScaling vs
                    INNER JOIN @RealTrips rt ON vs.vehicleintid = rt.vehicleintid 
                    INNER JOIN #period_dates p ON rt.ExitDateTime BETWEEN p.StartDate AND p.EndDate AND rt.EntryDateTime BETWEEN p.StartDate AND p.EndDate
                    WHERE rt.exitdatetime BETWEEN @lsdate AND @ledate
                    GROUP BY p.PeriodNum, vs.VehicleIntId) outside ON vs.VehicleIntId = outside.VehicleIntId AND p.PeriodNum = outside.PeriodNum
        WHERE nce.Date BETWEEN @lsdate AND @ledate
        GROUP BY p.PeriodNum, vs.VehicleId WITH CUBE) Result

LEFT JOIN dbo.Vehicle v ON Result.VehicleId = v.VehicleId
LEFT JOIN #period_dates p ON Result.PeriodNum = p.PeriodNum
ORDER BY p.PeriodNum

DROP TABLE #period_dates
GO
