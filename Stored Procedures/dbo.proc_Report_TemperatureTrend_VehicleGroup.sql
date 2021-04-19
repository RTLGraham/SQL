SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_Report_TemperatureTrend_VehicleGroup]
(
	@vids VARCHAR(MAX),
	@gids varchar(max), 
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

--DECLARE @vids VARCHAR(MAX),
--		@gids VARCHAR(max),
--		@routeid INT,
--		@vehicletypeid INT,	
--		@sdate datetime,
--		@edate datetime,
--		@uid UNIQUEIDENTIFIER,
--		@rprtcfgid UNIQUEIDENTIFIER,
--		@drilldown TINYINT,
--		@calendar TINYINT,
--		@groupBy INT
		
--SET @gids = N'D2B5005D-E9C1-4B42-A0C9-0C56B704A392'
--SET @vehicletypeid = NULL
--SET @routeid = NULL
--SET	@sdate = '2013-12-30 00:00'
--SET	@edate = '2014-01-05 23:59'
--SET	@uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
--SET	@rprtcfgid = N'6FAD9660-775F-4E1D-94B2-613CD4F94D65'
--SET @drilldown = 1
--SET @calendar = 0
--SET @groupBy = 2

DECLARE @lvids VARCHAR(MAX),
		@lgids VARCHAR(max),
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
SET @lgids = @gids
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
INNER JOIN dbo.GroupDetail gd ON v.VehicleId = gd.EntityDataId
WHERE DATEDIFF(ss, gexit.ExitDateTime, gentry.EntryDateTime) BETWEEN 2700 AND 50400 -- Real trips are between 30mins and 14 hours in duration
  AND CAST(gexit.ExitDateTime AS TIME) > @stime
  AND CAST(gentry.EntryDateTime AS TIME) < @etime
  AND (v.VehicleId IN (SELECT VALUE FROM dbo.Split(@lvids, ',')) OR @lvids IS NULL)
  AND gd.GroupId IN (SELECT VALUE FROM dbo.Split(@lgids, ','))

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
	ExternalScaleFactor FLOAT)
INSERT INTO @VehicleScaling (VehicleId, VehicleIntId, InternalScaleFactor, ProductScaleFactor, ExternalScaleFactor)
SELECT v.VehicleId, v.VehicleIntId, vsi.AnalogSensorScalefactor, vsp.AnalogSensorScaleFactor, vse.AnalogSensorScaleFactor
FROM dbo.Vehicle v 
INNER JOIN dbo.GroupDetail gd ON v.VehicleId = gd.EntityDataId
INNER JOIN dbo.VehicleSensor vsi ON v.VehicleIntId = vsi.VehicleIntId AND vsi.SensorId = @internalsensorid
INNER JOIN dbo.VehicleSensor vsp ON v.VehicleIntId = vsp.VehicleIntId AND vsp.SensorId = @productsensorid
INNER JOIN dbo.VehicleSensor vse ON v.VehicleIntId = vse.VehicleIntId AND vse.SensorId = @externalsensorid
WHERE (v.VehicleId IN (SELECT VALUE FROM dbo.Split(@lvids, ',')) OR @lvids IS NULL)
  AND gd.GroupId IN (SELECT VALUE FROM dbo.Split(@lgids, ','))
  AND v.Archived = 0
GROUP BY v.VehicleId, v.VehicleIntId, vsi.AnalogSensorScaleFactor, vsp.AnalogSensorScaleFactor, vse.AnalogSensorScaleFactor

SELECT  p.PeriodNum,
		[dbo].TZ_GetTime(p.StartDate,default,@luid) AS WeekStartDate,
		[dbo].TZ_GetTime(p.EndDate,default,@luid) AS WeekEndDate,
		p.PeriodType,
		g.GroupID,
		g.GroupName,
		NULL AS VehicleId,
		NULL AS Registration,
		Result.OutsideTime,
		Result.WeakestPercentage,
		Result.AveragePercentage,
		Result.TotalOverTempDuration,
		Result.WeakestOverTempDuration,
		Result.Confirmed,
		Result.NonConfirmed,
		Result.AvgProductTempInside,
		Result.AvgProductTempOutside,
		Result.AvgExternalTempOutside,
		Result.DefrostCount
FROM      (SELECT	CASE WHEN (GROUPING(p.PeriodNum) = 1) THEN NULL
		          ELSE ISNULL(p.PeriodNum, NULL)
				  END AS PeriodNum,
			
				  CASE WHEN (GROUPING(g.GroupId) = 1) THEN NULL
					  ELSE ISNULL(g.GroupId, NULL)
				  END AS GroupId,
		          
				  SUM(outside.OutsideTime) AS OutsideTime,
				  MAX(ISNULL(CAST(nce.WeakestOverTempDuration AS FLOAT),0)/CASE WHEN outside.OutsideTime = 0 THEN NULL ELSE outside.OutsideTime END) AS WeakestPercentage,
				  SUM(ISNULL(CAST(nce.TotalOverTempDuration AS FLOAT),0))/CASE WHEN SUM(outside.OutsideTime) = 0 THEN NULL ELSE SUM(outside.OutsideTime) END AS AveragePercentage,
--				  SUM(ISNULL(nce.OverLimitDuration,0)) AS TotalOverTempDuration,
				  SUM(nce.TotalOvertempDuration) AS TotalOverTempDuration,
--				  MAX(ISNULL(nce.OverLimitDuration,0)) AS WeakestOverTempDuration,
				  MAX(nce.WeakestOverTempDuration) AS WeakestOverTempDuration,
				  SUM(ISNULL(releases.Released,0)) AS Confirmed,
				  SUM(ISNULL(overtempcounts.OverDepartTemp,0)) - SUM(ISNULL(releases.Released,0)) AS NonConfirmed,
				  dbo.ScaleConvertAnalogValue(AVG(nce.AnalogData1AvgInside), MAX(vs.ProductScaleFactor), @tempmult, @liquidmult) AS AvgProductTempInside,
				  dbo.ScaleConvertAnalogValue(AVG(nce.AnalogData1AvgOutside), MAX(vs.ProductScaleFactor), @tempmult, @liquidmult) AS AvgProductTempOutside,
				  dbo.ScaleConvertAnalogValue(AVG(nce.AnalogData3AvgOutside), MAX(vs.ExternalScaleFactor), @tempmult, @liquidmult) AS AvgExternalTempOutside,
				  SUM(ISNULL(defrost.DefrostCount,0)) AS DefrostCount
			FROM @VehicleScaling vs
			CROSS JOIN #period_dates p
			INNER JOIN dbo.GroupDetail gd ON vs.VehicleId = gd.EntityDataId
			INNER JOIN dbo.[Group] g ON gd.GroupId = g.GroupId
			INNER JOIN (SELECT  gd.GroupId, p.PeriodNum, vs.VehicleIntId, 
								SUM(ISNULL(r.OverLimitDuration,0)) AS TotalOverTempDuration, 
								MAX(ISNULL(r.OverLimitDuration,0)) AS WeakestOverTempDuration,
								AVG(r.AnalogData1AvgInside) AS AnalogData1AvgInside,
								AVG(r.AnalogData1AvgOutside) AS AnalogData1AvgOutside,
								AVG(r.AnalogData3AvgOutside) AS AnalogData3AvgOutside
						FROM @VehicleScaling vs
						INNER JOIN dbo.GroupDetail gd ON vs.VehicleId = gd.EntityDataId
						INNER JOIN dbo.ReportingNCE r ON vs.VehicleIntId = r.VehicleIntId
						INNER JOIN #period_dates p ON r.Date BETWEEN p.StartDate AND p.EndDate

						-- The following line is intended to exclude outlier data (where the sensors are marked invalid).
						-- We test T1 (the Product Sensor) as this is the sensor that drives the KPIs (additional sensors can be addde if required)
						LEFT JOIN dbo.Maintenance m ON m.VehicleIntId = r.VehicleIntId AND r.Date = m.Date AND m.T1 = 1

						WHERE r.Date BETWEEN @lsdate AND @ledate
						  AND gd.GroupId IN (SELECT VALUE FROM dbo.Split(@lgids,','))
						GROUP BY gd.GroupId, p.PeriodNum, vs.VehicleIntId) nce ON g.GroupId = nce.GroupId AND vs.VehicleIntId = nce.VehicleIntId AND p.PeriodNum = nce.PeriodNum
			INNER JOIN (SELECT GroupId, PeriodNum, VehicleIntId, SUM(OverDepartTemp) AS OverDepartTemp
			            FROM
				            (SELECT gd.GroupId, p.PeriodNum, vs.VehicleIntId,
					                CASE WHEN dbo.ScaleConvertAnalogValue(CASE @internalsensorid WHEN 1 THEN eout.AnalogData0 WHEN 2 THEN eout.AnalogData1 WHEN 3 THEN eout.AnalogData2 WHEN 4 THEN eout.AnalogData3 END, vs.InternalScaleFactor, @tempmult, @liquidmult) > @tempdepart THEN 1 ELSE 0 END AS OverDepartTemp
							FROM @VehicleScaling vs
							INNER JOIN dbo.GroupDetail gd ON vs.VehicleId = gd.EntityDataId
							INNER JOIN @RealTrips rt ON vs.VehicleIntId = rt.VehicleIntId
										AND rt.GeofenceId IN (SELECT cg.GeofenceId
																FROM dbo.CustomerGeofence cg
																INNER JOIN [User] u ON cg.CustomerID = u.CustomerID
																WHERE u.UserID = @luid)
							LEFT JOIN dbo.Event eout ON rt.ExitEventId = eout.EventId
							INNER JOIN #period_dates p ON rt.exitdatetime BETWEEN p.StartDate AND p.EndDate AND rt.EntryDateTime BETWEEN p.StartDate AND p.EndDate
							WHERE ISNULL(rt.ExitDateTime, @ledate) BETWEEN @lsdate AND @ledate
							  AND gd.GroupId IN (SELECT VALUE FROM dbo.Split(@lgids,','))) overtemp
						GROUP BY overtemp.GroupId, overtemp.PeriodNum, overtemp.VehicleIntId) overtempcounts ON g.GroupId = overtempcounts.GroupId AND vs.VehicleIntId = overtempcounts.VehicleIntId AND p.PeriodNum = overtempcounts.PeriodNum
            LEFT JOIN  (SELECT gd.GroupId, p.PeriodNum, vs.VehicleIntId, ISNULL(SUM(CAST(ISNULL(ts.Ack, 0) AS INT)),0) AS Released
	                    FROM @VehicleScaling vs
						INNER JOIN dbo.GroupDetail gd ON vs.VehicleId = gd.EntityDataId
	                    INNER JOIN dbo.TemperatureStatus ts ON vs.VehicleIntId = dbo.GetVehicleIntFromId(ts.VehicleId)
	                    INNER JOIN #period_dates p ON ts.AckDateTime BETWEEN p.StartDate AND p.EndDate
	                    WHERE ts.AckDateTime BETWEEN @lsdate AND @ledate
	                      AND gd.GroupId IN (SELECT VALUE FROM dbo.Split(@lgids,','))
	                    GROUP BY gd.GroupId, p.PeriodNum, vs.VehicleIntId) releases ON g.GroupId = releases.GroupId AND vs.VehicleIntId = releases.VehicleIntId AND p.PeriodNum = releases.PeriodNum	
            LEFT JOIN  (SELECT gd.GroupId, p.PeriodNum, vs.VehicleIntId, COUNT(*) AS DefrostCount
	                    FROM @VehicleScaling vs
						INNER JOIN dbo.GroupDetail gd ON vs.VehicleId = gd.EntityDataId
	                    INNER JOIN dbo.TAN_EntityCheckOut tec ON vs.VehicleIntId = dbo.GetVehicleIntFromId(tec.EntityId)
	                    INNER JOIN #period_dates p ON tec.CheckOutDateTime BETWEEN p.StartDate AND p.EndDate
	                    WHERE tec.CheckOutDateTime BETWEEN @lsdate AND @ledate
	                      AND tec.CheckOutReason IN ('Defrosting','Abtauen','Dégelé','Sbrinare')
	                      AND gd.GroupId IN (SELECT VALUE FROM dbo.Split(@lgids,','))
	                    GROUP BY gd.GroupId, p.PeriodNum, vs.VehicleIntId) defrost ON g.GroupId = defrost.GroupId AND vs.VehicleIntId = defrost.VehicleIntId AND p.PeriodNum = defrost.PeriodNum
			LEFT JOIN  (SELECT gd.GroupId, p.PeriodNum, vs.VehicleIntId, SUM(rt.ExitSeconds) AS OutsideTime
						FROM @VehicleScaling vs
						INNER JOIN dbo.GroupDetail gd ON vs.VehicleId = gd.EntityDataId
						INNER JOIN @RealTrips rt ON vs.vehicleintid = rt.vehicleintid 
						INNER JOIN #period_dates p ON rt.ExitDateTime BETWEEN p.StartDate AND p.EndDate AND rt.EntryDateTime BETWEEN p.StartDate AND p.EndDate
						WHERE rt.exitdatetime BETWEEN @lsdate AND @ledate
						  AND gd.GroupId IN (SELECT VALUE FROM dbo.Split(@lgids,','))
						GROUP BY gd.GroupId, p.PeriodNum, vs.VehicleIntId) outside ON g.GroupId = outside.GroupId AND vs.VehicleIntId = outside.VehicleIntId AND p.PeriodNum = outside.PeriodNum	                    
            WHERE (vs.VehicleId IN (SELECT VALUE FROM dbo.Split(@lvids, ',')) OR @lvids IS NULL)
              AND g.GroupId IN (SELECT VALUE FROM dbo.Split(@lgids,','))
            GROUP BY p.PeriodNum, g.GroupId WITH CUBE) Result

LEFT JOIN dbo.[Group] g ON Result.GroupId = g.GroupId
LEFT JOIN #period_dates p ON Result.PeriodNum = p.PeriodNum
ORDER BY p.PeriodNum

DROP TABLE #period_dates
GO
