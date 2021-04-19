SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_Report_ActivityTraceByDriver_Bert]
(
		@did UNIQUEIDENTIFIER,
		@uid UNIQUEIDENTIFIER,
		@sdate DATETIME,
		@edate DATETIME
)
AS


--DECLARE @did UNIQUEIDENTIFIER,
--		@sdate DATETIME,
--		@edate DATETIME,
--		@uid UNIQUEIDENTIFIER

--SET @did = N'4B91A86E-371D-4BA3-AC47-C71C335EF707'
--SET @sdate = '2019-05-13 00:00'
--SET @edate = '2019-05-13 23:59'
--SET @uid = N'B09FAFFB-16CE-4F92-A9E7-DD1BFE09375F'

--Determine driver name here rather than calling function for every output row
DECLARE @driverName NVARCHAR(200)
SELECT @driverName = dbo.FormatDriverNameByUser(@did, @uid)

-- Convert dates to UTC
SET @sdate = [dbo].TZ_ToUTC(@sdate,default,@uid)
SET @edate = [dbo].TZ_ToUTC(@edate,default,@uid)

DECLARE @EventData TABLE
(
	DriverIntId INT,
	WorkMode CHAR(1),
	EventDateTime DATETIME,
	EventId BIGINT,
	RowNum INT
)

DECLARE @EventDataConsolidated TABLE
(
	DriverIntId INT,
	WorkMode CHAR(1),
	EventDateTime DATETIME,
	EventId BIGINT,
	RowNum INT
)

DECLARE @Source TABLE	
(
	DayId SMALLDATETIME,
	DriverIntId INT,
	WorkMode CHAR(1),
	StartDate DATETIME,
	EndDate DATETIME
)

DECLARE @Results TABLE
(
	DayId SMALLDATETIME,
	DriverIntId INT,
	WorkMode CHAR(1),
	StartDate DATETIME,
	EndDate DATETIME
);

-- Populate @EventData table from EventData for the driver
--INSERT INTO @EventData (DriverIntId, WorkMode, EventDateTime, EventId)
--SELECT	d.DriverIntId, 
--		CASE ed.EventDataString 
--				WHEN 'DS1: UNAVAILABLE' THEN 'R'
--				WHEN 'DS1: DRIVE' THEN 'D'
--				WHEN 'DS1: WORK' THEN 'W'
--				WHEN 'DS1: AVAILABLE' THEN 'A'
--				WHEN 'DS1: REST' THEN 'R'
--				WHEN 'DS1: ERROR' THEN 'R'
--				WHEN 'DS1: UNKNOWN' THEN 'R'
--		END,
--		dbo.TZ_GetTime(ed.EventDateTime,DEFAULT,@uid), 
--		ed.EventId
--FROM UK_Skynet_Data.dbo.EventData ed
--INNER JOIN UK_Skynet_Data.dbo.Driver d ON d.DriverIntId = ed.DriverIntId
--WHERE d.DriverId = @did
--  AND ed.EventDateTime BETWEEN @sdate AND @edate	
--  AND ed.EventDataName = 'WRK'
--  AND ed.EventDataString LIKE 'DS1%';


INSERT INTO @EventData (DriverIntId, WorkMode, EventDateTime, EventId, RowNum)
SELECT	dte.DriverIntId, 
		dte.WorkMode,
		dbo.TZ_GetTime(dte.EventDateTime,DEFAULT,@uid), 
		NULL,
		ROW_NUMBER() OVER(ORDER BY dte.EventDateTime) AS RowNum
FROM dbo.DriverTachoEvent dte
INNER JOIN dbo.Driver d ON d.DriverIntId = dte.DriverIntId
WHERE d.DriverId = @did
  AND dte.EventDateTime BETWEEN @sdate AND @edate	

--SELECT *
--FROM @EventData

---- Now add trip ends for the driver in the same period
--INSERT INTO @EventData (DriverIntId, WorkMode, EventDateTime, EventId)
--SELECT d.DriverIntId, 'R', dbo.TZ_GetTime(dt.EndEventDateTime,DEFAULT,@uid), dt.EndEventID
--FROM UK_Skynet_Data.dbo.DriverTrip dt
--INNER JOIN UK_Skynet_Data.dbo.Driver d ON d.DriverIntId = dt.DriverIntId
--WHERE d.DriverId = @did
--  AND dt.StartEventDateTime BETWEEN @sdate AND @edate;

--SELECT *
--FROM @EventData

--Eliminate periods of work that are less than 75 seconds in an approximation of the tacho legislation
DELETE FROM e2
--SELECT *, DATEDIFF(SECOND, e2.EventDateTime, e3.EventDateTime)
FROM @EventData e2
INNER JOIN @EventData e1 ON e2.RowNum = e1.RowNum + 1
INNER JOIN @EventData e3 ON e3.RowNum = e2.RowNum + 1
WHERE e2.WorkMode = 'W' AND e1.WorkMode != 'W' AND e3.WorkMode != 'W'
  AND DATEDIFF(SECOND, e2.EventDateTime, e3.EventDateTime) < 60;

--SELECT *
--FROM @EventData

--Insert into Consolidated table to renumber the rows
INSERT INTO @EventDataConsolidated
        ( DriverIntId ,
          WorkMode ,
          EventDateTime ,
          EventId ,
          RowNum
        )
SELECT DriverIntId ,
       WorkMode ,
       EventDateTime ,
       EventId ,
       ROW_NUMBER() OVER(ORDER BY EventDateTime) AS RowNum
FROM @EventData

--SELECT *
--FROM @EventDataConsolidated

--Consolidate sections of the same mode together
DELETE FROM e2
FROM @EventDataConsolidated e2
INNER JOIN @EventDataConsolidated e1 ON e2.RowNum = e1.RowNum + 1
WHERE e2.WorkMode = e1.WorkMode;

-- Populate @Source table
WITH WorkModes (DayId, DriverIntId, WorkMode, EventDateTime, EventId, RowNum)
AS
(
	SELECT	NULL,
			ed.DriverIntId, 
			WorkMode, 
			ed.EventDateTime, 
			ed.EventId,
			ROW_NUMBER() OVER(ORDER BY EventDateTime) AS RowNum
	FROM @EventDataConsolidated ed
)
INSERT INTO @Source (DayId, DriverIntId, WorkMode, StartDate, EndDate)
SELECT CAST(FLOOR(CAST(w.EventDateTime AS FLOAT)) AS SMALLDATETIME), w.DriverIntId, w.WorkMode, w.EventDateTime, ISNULL(w1.EventDateTime, DATEADD(SECOND, -1, CAST(CEILING(CAST(w.EventDateTime AS FLOAT)) AS DATETIME)))
FROM WorkModes w
LEFT JOIN WorkModes w1 ON w1.RowNum = w.RowNum + 1 

-- Insert sections all done on the same day
INSERT INTO @Results ( DayId, DriverIntId, WorkMode, StartDate, EndDate)
SELECT	DayId,
		DriverIntId, 
		WorkMode,
		StartDate,
		EndDate
FROM @Source
WHERE FLOOR(CAST(StartDate AS FLOAT)) = FLOOR(CAST(EndDate AS FLOAT))

-- Now insert sections all done at end of day into the next day
INSERT INTO @Results ( DayId, DriverIntId, WorkMode, StartDate, EndDate)
SELECT	DayId,
		DriverIntId, 
		WorkMode,
		StartDate,
		DATEADD(ss, -1, CAST(CEILING(CAST(StartDate AS FLOAT)) AS DATETIME))
FROM @Source
WHERE FLOOR(CAST(StartDate AS FLOAT)) != FLOOR(CAST(EndDate AS FLOAT))

-- Now insert sections leading up to first activity of each day
INSERT INTO @Results ( DayId, DriverIntId, WorkMode, StartDate, EndDate)
SELECT s.Dayid, s.DriverIntId, swork.WorkMode, s.DayId, MIN(s.StartDate)
FROM @Source s 
INNER JOIN (
	SELECT CAST(FLOOR(CAST(EndDate AS FLOAT)) AS SMALLDATETIME) AS DayId, WorkMode
	FROM @Source
	WHERE FLOOR(CAST(StartDate AS FLOAT)) != FLOOR(CAST(EndDate AS FLOAT))
	) swork ON swork.DayId = s.DayId
GROUP BY s.DayId, s.DriverIntId, swork.WorkMode

-- Now insert the very first segment
INSERT INTO @Results (DayId, DriverIntId, WorkMode, StartDate, EndDate)
SELECT Min(DayId), DriverIntId, 'R', MIN(DayId), MIN(StartDate)
FROM @Source
GROUP BY DriverIntId

-- Finally change the end date to now if it is in the future
DECLARE @now DATETIME
SET @now = dbo.TZ_GetTime(GETUTCDATE(),DEFAULT,@uid)
UPDATE @Results
SET EndDate = @now
WHERE EndDate > @now 

SELECT r.DayId AS Date,
       d.DriverId,
	   @driverName AS DriverName,
       r.WorkMode,
       r.StartDate,
       r.EndDate,
	   DATEDIFF(SECOND, r.StartDate, r.EndDate) AS Duration,
	   DayVals.Drive AS DriveDay,
	   DayVals.Work AS WorkDay,
	   DayVals.Available AS AvailableDay,
	   DayVals.Rest AS RestDay,
	   --DayVals.Unknown + DayVals.Error + DayVals.Unavailable AS OtherDay,
	   0 AS OtherDay,
	   ROUND(DayDist.Distance, 0) AS DistanceDay,
	   --DayVals.Drive + DayVals.Work + DayVals.Available + DayVals.Rest + DayVals.Unknown + DayVals.Error + DayVals.Unavailable AS DurationDay,
	   DayVals.Drive + DayVals.Work + DayVals.Available + DayVals.Rest AS DurationDay,
	   TotVals.Drive AS DriveTotal,
	   TotVals.Work AS WorkTotal,
	   TotVals.Available AS AvailableTotal,
	   TotVals.Rest AS RestTotal,
	   --TotVals.Unknown + TotVals.Error + TotVals.Unavailable AS OtherTotal,
	   0 AS OtherTotal,
	   ROUND(TotDist.Distance, 0) AS DistanceTotal,
	   --TotVals.Drive + TotVals.Work + TotVals.Available + TotVals.Rest + TotVals.Unknown + TotVals.Error + TotVals.Unavailable AS DurationTotal
	   TotVals.Drive + TotVals.Work + TotVals.Available + TotVals.Rest AS DurationTotal
	   
FROM @Results r
INNER JOIN dbo.Driver d ON d.DriverIntId = r.DriverIntId

LEFT JOIN (SELECT rt.DriverIntId,
				  rt.DayId,
                  SUM(CASE WHEN rt.WorkMode = 'R' THEN DATEDIFF(SECOND, rt.StartDate, rt.EndDate) ELSE 0 END) AS Rest,
                  SUM(CASE WHEN rt.WorkMode = 'A' THEN DATEDIFF(SECOND, rt.StartDate, rt.EndDate) ELSE 0 END) AS Available,
                  SUM(CASE WHEN rt.WorkMode = 'W' THEN DATEDIFF(SECOND, rt.StartDate, rt.EndDate) ELSE 0 END) AS Work,
                  SUM(CASE WHEN rt.WorkMode = 'D' THEN DATEDIFF(SECOND, rt.StartDate, rt.EndDate) ELSE 0 END) AS Drive
			FROM @Results rt
			INNER JOIN dbo.Driver d ON d.DriverIntId = rt.DriverIntId
			WHERE d.DriverId = @did AND rt.DayId BETWEEN @sdate AND @edate
			GROUP BY rt.DriverIntId, rt.DayId) DayVals ON DayVals.DriverIntId = r.DriverIntId AND r.DayId = DayVals.DayId

LEFT JOIN (SELECT rep.DriverIntId,
				  rep.Date,
                  SUM(rep.DrivingDistance) AS Distance
			FROM dbo.Reporting rep
			INNER JOIN dbo.Driver d ON d.DriverIntId = rep.DriverIntId
			WHERE d.DriverId = @did AND rep.Date BETWEEN @sdate AND @edate
			GROUP BY rep.DriverIntId, rep.Date) DayDist ON DayDist.DriverIntId = r.DriverIntId AND r.DayId = DayDist.Date

LEFT JOIN (SELECT rt.DriverIntId,
                  SUM(CASE WHEN rt.WorkMode = 'R' THEN DATEDIFF(SECOND, rt.StartDate, rt.EndDate) ELSE 0 END) AS Rest,
                  SUM(CASE WHEN rt.WorkMode = 'A' THEN DATEDIFF(SECOND, rt.StartDate, rt.EndDate) ELSE 0 END) AS Available,
                  SUM(CASE WHEN rt.WorkMode = 'W' THEN DATEDIFF(SECOND, rt.StartDate, rt.EndDate) ELSE 0 END) AS Work,
                  SUM(CASE WHEN rt.WorkMode = 'D' THEN DATEDIFF(SECOND, rt.StartDate, rt.EndDate) ELSE 0 END) AS Drive
			FROM @Results rt
			INNER JOIN dbo.Driver d ON d.DriverIntId = rt.DriverIntId
			WHERE d.DriverId = @did AND rt.DayId BETWEEN @sdate AND @edate
			GROUP BY rt.DriverIntId) TotVals ON TotVals.DriverIntId = r.DriverIntId

LEFT JOIN (SELECT rep.DriverIntId,
                  SUM(rep.DrivingDistance) AS Distance
			FROM dbo.Reporting rep
			INNER JOIN dbo.Driver d ON d.DriverIntId = rep.DriverIntId
			WHERE d.DriverId = @did AND rep.Date BETWEEN @sdate AND @edate
			GROUP BY rep.DriverIntId) TotDist ON TotDist.DriverIntId = r.DriverIntId

ORDER BY r.DayId, r.StartDate





GO
