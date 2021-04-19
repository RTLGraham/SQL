SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_PopulateReportingNCE]
AS

SET NOCOUNT ON;
	
DECLARE	@uid UNIQUEIDENTIFIER,
		@sdate DATETIME,
		@edate DATETIME,
		@departhour SMALLINT,
		@productsensorid SMALLINT,
		@externalsensorid SMALLINT,
		@cust1 NVARCHAR(100),
		@cust2 NVARCHAR(100),
		@cust3 NVARCHAR(100),
		@cust4 NVARCHAR(100)
		
SET @uid = N'3DB40C4A-7E79-4F41-8017-DE6E12EC7A20' -- NestleAdmin
SET @cust1 = 'Nestle Switzerland'
SET @cust2 = 'Nestle Germany OOH'
SET @cust3 = 'Nestle Germany SLKW'
SET @cust4 = 'Nestle Germany RML'

-- Always run for today and the last 2 days to capture any late data
SET @edate = GETDATE()
SET @sdate = DATEADD(DAY, -2, @edate)

DECLARE @tempmult FLOAT,
		@liquidmult FLOAT,
		@templimit FLOAT,
		@templimit2 FLOAT,
		@templimit3 FLOAT,
		@stime TIME,
		@etime TIME
    
-- Set 'real' departure and return time limits
SET @stime = dbo.TZ_TimeToUtc('05:00', NULL, DEFAULT, @uid)
SET @etime = dbo.TZ_TimeToUtc('20:00', NULL, DEFAULT, @uid)

SET @tempmult = ISNULL(dbo.[UserPref](@uid, 214),1)
SET @liquidmult = ISNULL(dbo.[UserPref](@uid, 200),1)
SET @departhour = DATEPART(hh,dbo.TZ_ToUtc(CAST(CONVERT(CHAR(10), @edate, 120) + ' 05:00' AS DATETIME),DEFAULT,@uid)) -- set to 5am

-- Sensor Ids and Temperature Limits are currently hard-coded
SET @productsensorid = 2
SET @templimit  = -18.0
SET @templimit2 = -15.0
SET @templimit3 = -20.0

-- Declare temporary table to build up results
DECLARE @TempResults TABLE (
	VehicleIntId INT,
	Date DATETIME,
	OverLimitDuration INT,
	OverLimit2Duration INT,
	OverLimit3Duration INT,
	TimedDateTime DATETIME,
	AnalogData0Timed INT,
	AnalogData1Timed INT,
	AnalogData2Timed INT,
	AnalogData3Timed INT,
	AnalogData0AvgInside INT,
	AnalogData1AvgInside INT,
	AnalogData2AvgInside INT,
	AnalogData3AvgInside INT,
	AnalogData0AvgOutside INT,
	AnalogData1AvgOutside INT,
	AnalogData2AvgOutside INT,
	AnalogData3AvgOutside INT,
	OutsideDuration INT
	)
-- Pre-populate results table with dates
INSERT INTO @TempResults (VehicleIntId, Date)
SELECT v.VehicleIntId, CAST(YEAR(d.StartDate) AS varchar(4)) + '-' + CAST(dbo.LeadingZero(MONTH(d.StartDate),2) AS varchar(2)) + '-' + CAST(dbo.LeadingZero(DAY(d.StartDate),2) AS varchar(2)) + ' 00:00:00.000'
FROM dbo.Vehicle v
INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
CROSS JOIN dbo.CreateDateRange(@sdate, @edate, 24) d
WHERE v.Archived = 0
  AND c.Name IN (@cust1, @cust2, @cust3, @cust4)
  AND cv.EndDate IS NULL	
  AND cv.Archived = 0

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

	(SELECT ROW_NUMBER() OVER (PARTITION BY vgh.VehicleIntId, vgh.GeofenceId ORDER BY EntryDateTime) AS RowNum, vgh.*
	FROM dbo.VehicleGeofenceHistory vgh
	INNER JOIN @TempResults t ON t.VehicleIntId = vgh.VehicleIntId
	INNER JOIN dbo.Geofence geo ON geo.GeofenceId = vgh.GeofenceId AND geo.IsTemperatureMonitored = 1
	WHERE EntryDateTime BETWEEN @sdate AND @edate OR ExitDateTime BETWEEN @sdate AND @edate
	  ) gexit
	  
INNER JOIN 

	(SELECT ROW_NUMBER() OVER (PARTITION BY vgh.VehicleIntId, vgh.GeofenceId ORDER BY EntryDateTime) AS RowNum, vgh.*
	FROM dbo.VehicleGeofenceHistory vgh
	INNER JOIN @TempResults t ON t.VehicleIntId = vgh.VehicleIntId
	INNER JOIN dbo.Geofence geo ON geo.GeofenceId = vgh.GeofenceId AND geo.IsTemperatureMonitored = 1
	WHERE EntryDateTime BETWEEN @sdate AND @edate OR ExitDateTime BETWEEN @sdate AND @edate
	  ) gentry ON gexit.VehicleIntId = gentry.VehicleIntId AND gexit.GeofenceId = gentry.GeofenceId AND gentry.RowNum = gexit.RowNum + 1
	  
INNER JOIN Vehicle v ON gexit.VehicleIntId = v.VehicleIntId
WHERE DATEDIFF(ss, gexit.ExitDateTime, gentry.EntryDateTime) BETWEEN 2700 AND 50400 -- Real trips are between 30mins and 14 hours in duration
  AND CAST(gexit.ExitDateTime AS TIME) > @stime
  AND CAST(gentry.EntryDateTime AS TIME) < @etime

-- Remove real trips where the vehicle was checked out 
DELETE	
FROM @RealTrips	
--SELECT rt.*
FROM @RealTrips rt
INNER JOIN dbo.TAN_EntityCheckOut tec ON dbo.GetVehicleIdFromInt(rt.VehicleIntId) = tec.EntityId AND rt.ExitDateTime BETWEEN tec.CheckOutDateTime AND tec.CheckInDateTime

-- Calculate duration for 'Over Temperature Limit' while outside geofence by date
-- Major assumption is that vehicles are only outside a geofence within a single day (i.e. do not cross a midnight point)
-- This step is repeated three times - once for each temperature threshold
DECLARE @OverLimit TABLE (
	VehicleIntId INT,
	Date DATETIME,
	OverLimitDuration INT)

INSERT INTO @OverLimit (VehicleIntId, Date, OverLimitDuration)
SELECT	GroupedbyLimit.VehicleIntId,
		GroupedbyLimit.Date,
		SUM(GroupedbyLimit.Duration) AS OverLimitDuration	
FROM	
	(SELECT Outside.VehicleIntId, 
			CAST(FLOOR(CAST(Outside.EventDateTime AS FLOAT)) AS DATETIME) AS Date,
			Outside.OverLimit,
			MIN(Outside.EventDateTime) AS StartTime, 
			MAX(Outside.EventDateTime) AS EndTime, 
			DATEDIFF(ss,MIN(Outside.EventDateTime),MAX(Outside.EventDateTime)) AS Duration
	FROM 
		(SELECT	ROW_NUMBER() OVER(PARTITION BY e.VehicleIntId ORDER BY e.VehicleIntId, e.EventDateTime) -
				ROW_NUMBER() OVER(PARTITION BY e.VehicleIntId, CASE WHEN (dbo.ScaleConvertAnalogValue(CASE @productsensorid WHEN 1 THEN e.AnalogData0 WHEN 2 THEN e.AnalogData1 WHEN 3 THEN e.AnalogData2 WHEN 4 THEN e.AnalogData3 END, vsp.AnalogSensorScaleFactor, @tempmult, @liquidmult) > @templimit) AND rt.ExitDateTime IS NOT NULL THEN 1 ELSE 0 END ORDER BY e.VehicleIntId, e.EventDateTime) AS GroupNumber,  
				e.VehicleIntId, 
				e.EventDateTime,
				dbo.ScaleConvertAnalogValue(CASE @productsensorid WHEN 1 THEN e.AnalogData0 WHEN 2 THEN e.AnalogData1 WHEN 3 THEN e.AnalogData2 WHEN 4 THEN e.AnalogData3 END, vsp.AnalogSensorScaleFactor, @tempmult, @liquidmult) AS Temperature,
				-- Determine OverLimit value by temperature limit and by location within / GroupedbyLimit geofence (set overlimit false when inside geofence)
				CASE WHEN (dbo.ScaleConvertAnalogValue(CASE @productsensorid WHEN 1 THEN e.AnalogData0 WHEN 2 THEN e.AnalogData1 WHEN 3 THEN e.AnalogData2 WHEN 4 THEN e.AnalogData3 END, vsp.AnalogSensorScaleFactor, @tempmult, @liquidmult) > @templimit) AND rt.ExitDateTime IS NOT NULL THEN 1 ELSE 0 END AS OverLimit
		FROM dbo.Event e WITH (NOLOCK)
		INNER JOIN @TempResults t ON t.VehicleIntId = e.VehicleIntId
		INNER JOIN VehicleSensor vsp ON e.VehicleIntId = vsp.VehicleIntId AND vsp.SensorId = @productsensorid
		LEFT JOIN @RealTrips rt ON e.VehicleIntId = rt.VehicleIntId AND e.EventDateTime BETWEEN rt.ExitdateTime AND rt.EntryDateTime
				AND rt.GeofenceId IN (SELECT cg.GeofenceId
										FROM dbo.CustomerGeofence cg
										INNER JOIN dbo.Customer c ON cg.CustomerID = c.CustomerID
										WHERE c.Name in (@cust1, @cust2, @cust3, @cust4))
		WHERE e.EventDateTime BETWEEN @sdate AND @edate
		  AND e.Lat != 0 AND e.Long != 0 AND e.AnalogData1 != 0) Outside
	GROUP BY Outside.VehicleIntId, FLOOR(CAST(Outside.EventDateTime AS FLOAT)), Outside.OverLimit, Outside.GroupNumber) GroupedbyLimit
WHERE GroupedbyLimit.OverLimit = 1
GROUP BY GroupedbyLimit.VehicleIntId, GroupedbyLimit.Date

DECLARE @OverLimit2 TABLE (
	VehicleIntId INT,
	Date DATETIME,
	OverLimitDuration INT)

INSERT INTO @OverLimit2 (VehicleIntId, Date, OverLimitDuration)
SELECT	GroupedbyLimit.VehicleIntId,
		GroupedbyLimit.Date,
		SUM(GroupedbyLimit.Duration) AS OverLimitDuration	
FROM	
	(SELECT Outside.VehicleIntId, 
			CAST(FLOOR(CAST(Outside.EventDateTime AS FLOAT)) AS DATETIME) AS Date,
			Outside.OverLimit,
			MIN(Outside.EventDateTime) AS StartTime, 
			MAX(Outside.EventDateTime) AS EndTime, 
			DATEDIFF(ss,MIN(Outside.EventDateTime),MAX(Outside.EventDateTime)) AS Duration
	FROM 
		(SELECT	ROW_NUMBER() OVER(PARTITION BY e.VehicleIntId ORDER BY e.VehicleIntId, e.EventDateTime) -
				ROW_NUMBER() OVER(PARTITION BY e.VehicleIntId, CASE WHEN (dbo.ScaleConvertAnalogValue(CASE @productsensorid WHEN 1 THEN e.AnalogData0 WHEN 2 THEN e.AnalogData1 WHEN 3 THEN e.AnalogData2 WHEN 4 THEN e.AnalogData3 END, vsp.AnalogSensorScaleFactor, @tempmult, @liquidmult) > @templimit2) AND rt.ExitDateTime IS NOT NULL THEN 1 ELSE 0 END ORDER BY e.VehicleIntId, e.EventDateTime) AS GroupNumber,  
				e.VehicleIntId, 
				e.EventDateTime,
				dbo.ScaleConvertAnalogValue(CASE @productsensorid WHEN 1 THEN e.AnalogData0 WHEN 2 THEN e.AnalogData1 WHEN 3 THEN e.AnalogData2 WHEN 4 THEN e.AnalogData3 END, vsp.AnalogSensorScaleFactor, @tempmult, @liquidmult) AS Temperature,
				-- Determine OverLimit value by temperature limit and by location within / GroupedbyLimit geofence (set overlimit false when inside geofence)
				CASE WHEN (dbo.ScaleConvertAnalogValue(CASE @productsensorid WHEN 1 THEN e.AnalogData0 WHEN 2 THEN e.AnalogData1 WHEN 3 THEN e.AnalogData2 WHEN 4 THEN e.AnalogData3 END, vsp.AnalogSensorScaleFactor, @tempmult, @liquidmult) > @templimit2) AND rt.ExitDateTime IS NOT NULL THEN 1 ELSE 0 END AS OverLimit
		FROM dbo.Event e WITH (NOLOCK)
		INNER JOIN @TempResults t ON t.VehicleIntId = e.VehicleIntId
		INNER JOIN VehicleSensor vsp ON e.VehicleIntId = vsp.VehicleIntId AND vsp.SensorId = @productsensorid
		LEFT JOIN @RealTrips rt ON e.VehicleIntId = rt.VehicleIntId AND e.EventDateTime BETWEEN rt.ExitdateTime AND rt.EntryDateTime
				AND rt.GeofenceId IN (SELECT cg.GeofenceId
										FROM dbo.CustomerGeofence cg
										INNER JOIN dbo.Customer c ON cg.CustomerID = c.CustomerID
										WHERE c.Name in (@cust1, @cust2, @cust3, @cust4))
		WHERE e.EventDateTime BETWEEN @sdate AND @edate
		  AND e.Lat != 0 AND e.Long != 0 AND e.AnalogData1 != 0) Outside
	GROUP BY Outside.VehicleIntId, FLOOR(CAST(Outside.EventDateTime AS FLOAT)), Outside.OverLimit, Outside.GroupNumber) GroupedbyLimit
WHERE GroupedbyLimit.OverLimit = 1
GROUP BY GroupedbyLimit.VehicleIntId, GroupedbyLimit.Date

DECLARE @OverLimit3 TABLE (
	VehicleIntId INT,
	Date DATETIME,
	OverLimitDuration INT)

INSERT INTO @OverLimit3 (VehicleIntId, Date, OverLimitDuration)
SELECT	GroupedbyLimit.VehicleIntId,
		GroupedbyLimit.Date,
		SUM(GroupedbyLimit.Duration) AS OverLimitDuration	
FROM	
	(SELECT Outside.VehicleIntId, 
			CAST(FLOOR(CAST(Outside.EventDateTime AS FLOAT)) AS DATETIME) AS Date,
			Outside.OverLimit,
			MIN(Outside.EventDateTime) AS StartTime, 
			MAX(Outside.EventDateTime) AS EndTime, 
			DATEDIFF(ss,MIN(Outside.EventDateTime),MAX(Outside.EventDateTime)) AS Duration
	FROM 
		(SELECT	ROW_NUMBER() OVER(PARTITION BY e.VehicleIntId ORDER BY e.VehicleIntId, e.EventDateTime) -
				ROW_NUMBER() OVER(PARTITION BY e.VehicleIntId, CASE WHEN (dbo.ScaleConvertAnalogValue(CASE @productsensorid WHEN 1 THEN e.AnalogData0 WHEN 2 THEN e.AnalogData1 WHEN 3 THEN e.AnalogData2 WHEN 4 THEN e.AnalogData3 END, vsp.AnalogSensorScaleFactor, @tempmult, @liquidmult) > @templimit3) AND rt.ExitDateTime IS NOT NULL THEN 1 ELSE 0 END ORDER BY e.VehicleIntId, e.EventDateTime) AS GroupNumber,  
				e.VehicleIntId, 
				e.EventDateTime,
				dbo.ScaleConvertAnalogValue(CASE @productsensorid WHEN 1 THEN e.AnalogData0 WHEN 2 THEN e.AnalogData1 WHEN 3 THEN e.AnalogData2 WHEN 4 THEN e.AnalogData3 END, vsp.AnalogSensorScaleFactor, @tempmult, @liquidmult) AS Temperature,
				-- Determine OverLimit value by temperature limit and by location within / GroupedbyLimit geofence (set overlimit false when inside geofence)
				CASE WHEN (dbo.ScaleConvertAnalogValue(CASE @productsensorid WHEN 1 THEN e.AnalogData0 WHEN 2 THEN e.AnalogData1 WHEN 3 THEN e.AnalogData2 WHEN 4 THEN e.AnalogData3 END, vsp.AnalogSensorScaleFactor, @tempmult, @liquidmult) > @templimit3) AND rt.ExitDateTime IS NOT NULL THEN 1 ELSE 0 END AS OverLimit
		FROM dbo.Event e WITH (NOLOCK)
		INNER JOIN @TempResults t ON t.VehicleIntId = e.VehicleIntId
		INNER JOIN VehicleSensor vsp ON e.VehicleIntId = vsp.VehicleIntId AND vsp.SensorId = @productsensorid
		LEFT JOIN @RealTrips rt ON e.VehicleIntId = rt.VehicleIntId AND e.EventDateTime BETWEEN rt.ExitdateTime AND rt.EntryDateTime
				AND rt.GeofenceId IN (SELECT cg.GeofenceId
										FROM dbo.CustomerGeofence cg
										INNER JOIN dbo.Customer c ON cg.CustomerID = c.CustomerID
										WHERE c.Name in (@cust1, @cust2, @cust3, @cust4))
		WHERE e.EventDateTime BETWEEN @sdate AND @edate
		  AND e.Lat != 0 AND e.Long != 0 AND e.AnalogData1 != 0) Outside
	GROUP BY Outside.VehicleIntId, FLOOR(CAST(Outside.EventDateTime AS FLOAT)), Outside.OverLimit, Outside.GroupNumber) GroupedbyLimit
WHERE GroupedbyLimit.OverLimit = 1
GROUP BY GroupedbyLimit.VehicleIntId, GroupedbyLimit.Date

UPDATE @TempResults
SET OverLimitDuration = o.OverLimitDuration
FROM @TempResults t
INNER JOIN @OverLimit o ON t.VehicleIntId = o.VehicleIntId AND t.Date = o.Date

UPDATE @TempResults
SET OverLimit2Duration = o.OverLimitDuration
FROM @TempResults t
INNER JOIN @OverLimit2 o ON t.VehicleIntId = o.VehicleIntId AND t.Date = o.Date

UPDATE @TempResults
SET OverLimit3Duration = o.OverLimitDuration
FROM @TempResults t
INNER JOIN @OverLimit3 o ON t.VehicleIntId = o.VehicleIntId AND t.Date = o.Date

-- Calculate Total Outside Duration
UPDATE @TempResults
SET OutsideDuration = outside.OutsideDuration
FROM @TempResults t
INNER JOIN 
	(
	SELECT v.VehicleIntId, CAST(FLOOR(CAST(rt.ExitDateTime AS FLOAT)) AS DATETIME) AS Date, SUM(rt.ExitSeconds) AS OutsideDuration
	FROM dbo.Vehicle v 
	INNER JOIN @RealTrips rt ON v.VehicleIntId = rt.VehicleIntId
	WHERE v.Archived = 0
	GROUP BY v.VehicleIntId, FLOOR(CAST(rt.ExitDateTime AS FLOAT))
	) outside ON t.VehicleIntId = outside.VehicleIntId AND t.Date = outside.Date

-- Calculate average temperatures while outside geofence by date
DECLARE @OutsideAvg TABLE (
	VehicleIntId INT,
	Date DATETIME,
	AvgAnalogData0 INT,
	AvgAnalogData1 INT,
	AvgAnalogData2 INT,
	AvgAnalogData3 INT)
	
INSERT INTO @OutsideAvg (VehicleIntId, Date, AvgAnalogData0, AvgAnalogData1, AvgAnalogData2, AvgAnalogData3)
SELECT	e.VehicleIntId,
		CAST(FLOOR(CAST(e.EventDateTime AS FLOAT)) AS DATETIME) AS Date,
		AVG(e.AnalogData0) AS AvgAnalogData0,
		AVG(e.AnalogData1) AS AvgAnalogData1,
		AVG(e.AnalogData2) AS AvgAnalogData2,
		AVG(e.AnalogData3) AS AvgAnalogData3
FROM dbo.Event e WITH (NOLOCK)
INNER JOIN @TempResults t ON t.VehicleIntId = e.VehicleIntId
INNER JOIN @RealTrips rt ON e.VehicleIntId = rt.VehicleIntId AND e.EventDateTime BETWEEN rt.ExitDateTime AND rt.EntryDateTime
		AND rt.GeofenceId IN (SELECT cg.GeofenceId
								FROM dbo.CustomerGeofence cg
								INNER JOIN dbo.Customer c ON cg.CustomerID = c.CustomerID
								WHERE c.Name in (@cust1, @cust2, @cust3, @cust4))
WHERE e.EventDateTime BETWEEN @sdate AND @edate
  AND e.Lat != 0 AND e.Long != 0 AND e.AnalogData0 != 0
GROUP BY e.VehicleIntId, FLOOR(CAST(e.EventDateTime AS FLOAT))
ORDER BY e.VehicleIntId


UPDATE @TempResults
SET AnalogData0AvgOutside = o.AvgAnalogData0, AnalogData1AvgOutside = o.AvgAnalogData1, AnalogData2AvgOutside = o.AvgAnalogData2, AnalogData3AvgOutside = o.AvgAnalogData3
FROM @TempResults t
INNER JOIN @OutsideAvg o ON t.VehicleIntId = o.VehicleIntId AND t.Date = o.Date

-- Calculate average temperatures while inside geofence by date
DECLARE @InsideAvg TABLE (
	VehicleIntId INT,
	Date DATETIME,
	AvgAnalogData0 INT,
	AvgAnalogData1 INT,
	AvgAnalogData2 INT,
	AvgAnalogData3 INT)

INSERT INTO @InsideAvg (VehicleIntId, Date, AvgAnalogData0, AvgAnalogData1, AvgAnalogData2, AvgAnalogData3)
SELECT	e.VehicleIntId,
		CAST(FLOOR(CAST(e.EventDateTime AS FLOAT)) AS DATETIME) AS Date,
		AVG(e.AnalogData0) AS AvgAnalogData0,
		AVG(e.AnalogData1) AS AvgAnalogData1,
		AVG(e.AnalogData2) AS AvgAnalogData2,
		AVG(e.AnalogData3) AS AvgAnalogData3
FROM dbo.Event e WITH (NOLOCK)
INNER JOIN @TempResults t ON t.VehicleIntId = e.VehicleIntId
LEFT JOIN @RealTrips rt ON e.VehicleIntId = rt.VehicleIntId AND e.EventDateTime BETWEEN rt.ExitDateTime AND rt.EntryDateTime
		AND rt.GeofenceId IN (SELECT cg.GeofenceId
								FROM dbo.CustomerGeofence cg
								INNER JOIN dbo.Customer c ON cg.CustomerID = c.CustomerID
								WHERE c.Name in (@cust1, @cust2, @cust3, @cust4))
WHERE e.EventDateTime BETWEEN @sdate AND @edate
  AND e.Lat != 0 AND e.Long != 0 AND e.AnalogData0 != 0
  AND rt.ExitDateTime IS NULL -- Not out on a trip - therefore in the RDC
GROUP BY e.VehicleIntId, FLOOR(CAST(e.EventDateTime AS FLOAT))
ORDER BY e.VehicleIntId


UPDATE @TempResults
SET AnalogData0AvgInside = i.AvgAnalogData0, AnalogData1AvgInside = i.AvgAnalogData1, AnalogData2AvgInside = i.AvgAnalogData2, AnalogData3AvgInside = i.AvgAnalogData3
FROM @TempResults t
INNER JOIN @InsideAvg i ON t.VehicleIntId = i.VehicleIntId AND t.Date = i.Date

-- Determine temperature at 5am (time based upon userid set) by date
DECLARE @Timed TABLE (
	VehicleIntId INT,
	Date DATETIME,
	TimedDateTime DATETIME,
	AnalogData0 INT,
	AnalogData1 INT,
	AnalogData2 INT,
	AnalogData3 INT)

INSERT INTO @Timed (VehicleIntId, Date, TimedDateTime, AnalogData0, AnalogData1, AnalogData2, AnalogData3)
SELECT	p5.VehicleIntId, 
		CAST(FLOOR(CAST(p5.EventDateTime AS FLOAT)) AS DATETIME) AS Date,
		p5.EventDateTime, 
		p5.AnalogData0,
		p5.AnalogData1,
		p5.AnalogData2,
		p5.AnalogData3
FROM
	(SELECT	ROW_NUMBER() OVER (PARTITION BY e.VehicleIntId, FLOOR(CAST(e.EventDateTime AS FLOAT)) ORDER BY e.VehicleIntId, EventDateTime DESC) AS RowNum,
			CASE WHEN DATEPART(hh,e.EventDateTime) < 5 THEN 1 ELSE 0 END AS Period,
			e.VehicleIntId, e.EventDateTime, e.AnalogData0, e.AnalogData1, e.AnalogData2, e.AnalogData3
	FROM dbo.Event e WITH (NOLOCK)
	INNER JOIN @TempResults t ON t.VehicleIntId = e.VehicleIntId
	WHERE e.EventDateTime BETWEEN @sdate AND @edate
	  AND DATEPART(hh,e.EventDateTime) < @departhour) p5
WHERE RowNum = 1

UPDATE @TempResults
SET TimedDateTime = tm.TimedDateTime, AnalogData0Timed = tm.AnalogData0, AnalogData1Timed = tm.AnalogData1, AnalogData2Timed = tm.AnalogData2, AnalogData3Timed = tm.AnalogData3
FROM @TempResults t
INNER JOIN @Timed tm ON t.VehicleIntId = tm.VehicleIntId AND t.Date = tm.Date

-- Update any rows that already exist in ReportingNCE
UPDATE dbo.ReportingNCE
SET OverLimitDuration = tr.OverLimitDuration,
	OverLimit2Duration = tr.OverLimit2Duration,
	OverLimit3Duration = tr.OverLimit3Duration,
	TimedDateTime = tr.TimedDateTime,
	AnalogData0Timed = tr.AnalogData0Timed,
	AnalogData1Timed = tr.AnalogData1Timed,
	AnalogData2Timed = tr.AnalogData2Timed,
	AnalogData3Timed = tr.AnalogData3Timed,
	AnalogData0AvgInside = tr.AnalogData0AvgInside,
	AnalogData1AvgInside = tr.AnalogData1AvgInside,
	AnalogData2AvgInside = tr.AnalogData2AvgInside,
	AnalogData3AvgInside = tr.AnalogData3AvgInside,
	AnalogData0AvgOutside = tr.AnalogData0AvgOutside,
	AnalogData1AvgOutside = tr.AnalogData1AvgOutside,
	AnalogData2AvgOutside = tr.AnalogData2AvgOutside,
	AnalogData3AvgOutside = tr.AnalogData3AvgOutside,
	OutsideDuration = tr.OutsideDuration
FROM dbo.ReportingNCE re
INNER JOIN @TempResults tr ON re.VehicleIntId = tr.VehicleIntId AND re.Date = tr.Date

-- Add any new rows that don't already exist in Reporting Temperature
INSERT INTO dbo.ReportingNCE
        ( VehicleIntId ,
          Date ,
          OverLimitDuration ,
		  OverLimit2Duration ,
		  OverLimit3Duration ,
          TimedDateTime ,
          AnalogData0Timed ,
          AnalogData1Timed ,
          AnalogData2Timed ,
          AnalogData3Timed ,
          AnalogData0AvgInside ,
          AnalogData1AvgInside ,
          AnalogData2AvgInside ,
          AnalogData3AvgInside ,
          AnalogData0AvgOutside ,
          AnalogData1AvgOutside ,
          AnalogData2AvgOutside ,
          AnalogData3AvgOutside ,
          OutsideDuration
        )
SELECT *
FROM @TempResults tr
WHERE NOT EXISTS (SELECT 1
				  FROM dbo.ReportingNCE re
				  WHERE tr.VehicleIntId = re.VehicleIntId
					AND tr.Date = re.Date)
GO
