SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_CombinedTemperatureScoreByPeriod]
(
	@dids NVARCHAR(MAX) = NULL,
	@sdate DATETIME,
	@edate DATETIME,
	@sensorid SMALLINT = NULL,
	@uid UNIQUEIDENTIFIER
)
AS

--DECLARE @dids NVARCHAR(MAX),
--		@sdate DATETIME,
--		@edate DATETIME,
--		@sensorid SMALLINT,
--		@uid UNIQUEIDENTIFIER

--SET @dids = N'FB52A2E1-A64D-4F17-820F-DD328E5BD001'
--SET @sdate = '2017-07-17 00:00'
--SET @edate = '2017-08-20 23:59'
--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'

DECLARE @ldids NVARCHAR(MAX),
		@lsdate DATETIME,
		@ledate DATETIME,
		@lsensorid SMALLINT,
		@luid UNIQUEIDENTIFIER,
		@periodType INT
		
SET @ldids = @dids
SET @lsdate = @sdate
SET @ledate = @edate
SET @lsensorid = @sensorid
SET @luid = @uid

DECLARE @tempmult FLOAT,
		@liquidmult FLOAT,
		@templimit FLOAT,
		@tempdepart FLOAT,
		@stime TIME,
		@etime TIME
 
DECLARE @period_dates TABLE (
		PeriodNum TINYINT IDENTITY (1,1),
		PeriodId INT,
		StartDate DATETIME,
		EndDate DATETIME)

IF ISNULL(@periodType, 0) = 0	-- Default setting of last 5 weeks used for Combined report
BEGIN      
INSERT  INTO @period_dates ( StartDate, EndDate )
        SELECT  StartDate,
                EndDate
        FROM    dbo.CreateDateRangeSec(@lsdate, @ledate, 168)
UPDATE @period_dates
SET PeriodId = PeriodNum -- set the periodId = PeriodNum for default processing
END	 
    
-- Set 'real' departure and return time limits
-- Use today's date by default so that DST time conversion is applied p[roperly
SET @stime = dbo.TZ_TimeToUtc('05:00', NULL, DEFAULT, @uid)
SET @etime = dbo.TZ_TimeToUtc('20:00', NULL, DEFAULT, @uid)

-- Temperature Limits are currently hard-coded
SET @templimit = -18.0
SET @tempdepart = -25.0
SET @lsdate = dbo.TZ_ToUtc(@lsdate, DEFAULT, @luid)
SET @ledate = dbo.TZ_ToUtc(@ledate, DEFAULT, @luid)


-- Create a temporary table for real geofence exits / entries for the required vehicles
DECLARE @RealTrips TABLE
(
	VehicleIntId INT,
	DriverIntId INT,
	GeofenceId UNIQUEIDENTIFIER,
	ExitDateTime DATETIME,
	ExitEventId BIGINT,
	EntryDateTime DATETIME,
	EntryEventId BIGINT,
	ExitSeconds BIGINT,
	OverLimitDuration BIGINT
)
INSERT INTO @RealTrips (VehicleIntId, DriverIntId, GeofenceId, ExitDateTime, ExitEventId, EntryDateTime, EntryEventId, ExitSeconds)
SELECT DISTINCT gexit.VehicleIntId AS vehicleIntId, gexit.ExitDriverIntId AS DriverIntId, gexit.GeofenceId AS GeofenceId, gexit.ExitDateTime, gexit.ExitEventId, gentry.EntryDateTime, gentry.EntryEventId, DATEDIFF(ss, gexit.ExitDateTime, gentry.EntryDateTime) AS ExitSeconds
FROM

	(SELECT ROW_NUMBER() OVER (PARTITION BY VehicleIntId, vgh.GeofenceId ORDER BY EntryDateTime) AS RowNum, vgh.*
	FROM dbo.VehicleGeofenceHistory vgh
	INNER JOIN dbo.Geofence geo ON geo.GeofenceId = vgh.GeofenceId AND geo.Name LIKE 'NCH%'
	WHERE EntryDateTime BETWEEN @lsdate AND @ledate OR ExitDateTime BETWEEN @lsdate AND @ledate
	  ) gexit
	  
INNER JOIN 

	(SELECT ROW_NUMBER() OVER (PARTITION BY VehicleIntId, vgh.GeofenceId ORDER BY EntryDateTime) AS RowNum, vgh.*
	FROM dbo.VehicleGeofenceHistory vgh
	INNER JOIN dbo.Geofence geo ON geo.GeofenceId = vgh.GeofenceId AND geo.Name LIKE 'NCH%'
	WHERE EntryDateTime BETWEEN @lsdate AND @ledate OR ExitDateTime BETWEEN @lsdate AND @ledate
	  ) gentry ON gexit.VehicleIntId = gentry.VehicleIntId AND gexit.GeofenceId = gentry.GeofenceId AND gentry.RowNum = gexit.RowNum + 1
	  
INNER JOIN dbo.Driver d ON gexit.ExitDriverIntId = d.DriverIntId
WHERE DATEDIFF(ss, gexit.ExitDateTime, gentry.EntryDateTime) BETWEEN 2700 AND 50400 -- Real trips are between 30mins and 14 hours in duration
  AND CAST(gexit.ExitDateTime AS TIME) > @stime
  AND CAST(gentry.EntryDateTime AS TIME) < @etime
  AND d.DriverId IN (SELECT Value FROM dbo.Split(@ldids, ','))

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

SELECT	CASE WHEN (GROUPING(d.DriverId) = 1) THEN NULL
			ELSE ISNULL(d.DriverId, NULL)
		END AS DriverId,

		CASE WHEN (GROUPING(p.PeriodId) = 1) THEN NULL
			ELSE ISNULL(p.PeriodId, NULL)
		END AS PeriodId,

		ISNULL(SUM(rt.ExitSeconds),0) AS OutsideTime,
		ISNULL(SUM(nce.OverLimitDuration),0) AS OverTempDuration,
		ISNULL(SUM(nce.OverLimit2Duration),0) AS OverTemp2Duration,
		ISNULL(SUM(nce.OverLimit3Duration),0) AS OverTemp3Duration

FROM @RealTrips rt
INNER JOIN dbo.Driver d ON rt.DriverIntId = d.DriverIntId
INNER JOIN @period_dates p ON rt.ExitDateTime BETWEEN p.StartDate AND p.EndDate
INNER JOIN dbo.Vehicle v ON rt.VehicleIntId = v.VehicleIntId
INNER JOIN dbo.ReportingNCE nce ON rt.VehicleIntId = nce.VehicleIntId AND FLOOR(CAST(rt.ExitDateTime AS FLOAT)) = FLOOR(CAST(nce.Date AS FLOAT))

-- The following line is intended to exclude outlier data (where the sensors are marked invalid).
-- We test T1 (the Product Sensor) as this is the sensor that drives the KPIs (additional sensors can be addde if required)
INNER JOIN dbo.Maintenance m ON m.VehicleIntId = nce.VehicleIntId AND nce.Date = m.Date AND m.T1 = 1

WHERE nce.Date BETWEEN @lsdate AND @ledate
GROUP BY d.DriverId, p.PeriodId WITH CUBE
HAVING d.DriverId IS NOT NULL

GO
