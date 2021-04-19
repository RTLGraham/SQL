SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_Report_ActivityTraceByDriver]
(
		@did UNIQUEIDENTIFIER,
		@uid UNIQUEIDENTIFIER,
		@sdate DATETIME,
		@edate DATETIME
)
AS

--DECLARE   @did UNIQUEIDENTIFIER,
--	@sdate DATETIME,
--	@edate DATETIME,
--	@uid UNIQUEIDENTIFIER;

--SET @did = N'4B91A86E-371D-4BA3-AC47-C71C335EF707';
--SET @sdate = '2019-01-01 00:00';
--SET @edate = '2019-01-31 23:59';
--SET @uid = N'B09FAFFB-16CE-4F92-A9E7-DD1BFE09375F';

DECLARE   @ldid UNIQUEIDENTIFIER,
	@lsdate DATETIME,
	@ledate DATETIME,
	@luid UNIQUEIDENTIFIER;

SET @ldid = @did;
SET @lsdate = @sdate;
SET @ledate = @edate;
SET @luid = @uid;

SELECT @lsdate = dbo.TZ_ToUtc(@lsdate, DEFAULT, @luid)
SELECT @ledate = dbo.TZ_ToUtc(@ledate, DEFAULT, @luid)

DECLARE @noidInt INT,
		@idInt INT	

-- Determine the No ID driver for this customer
SELECT @noidInt = d.DriverIntId
FROM dbo.Driver d
INNER JOIN dbo.CustomerDriver cd ON cd.DriverId = d.DriverId
INNER JOIN dbo.[User] u ON u.CustomerID = cd.CustomerId
WHERE u.UserID = @luid AND d.Number = 'No ID'

SELECT @idInt = dbo.GetDriverIntFromId(@ldid)

-- Use Source table to collect data but convert dates to local time to ensure day splits occur at midnight local time
DECLARE @Source TABLE	
(
	DriverIntId INT,
	VehicleModeId INT,
	StartDate DATETIME,
	EndDate DATETIME
)

DECLARE @Results TABLE
(
	DriverIntId INT,
	VehicleModeId INT,
	StartDate DATETIME,
	EndDate DATETIME
)

-- Populate @Source table
INSERT INTO @Source
        ( DriverIntId,
          VehicleModeID,
          StartDate,
          EndDate
        )
SELECT	@idInt, 
		vma.VehicleModeId,
		dbo.TZ_GetTime(vma.StartDate, DEFAULT, @luid),
		dbo.TZ_GetTime(vma.EndDate, DEFAULT, @luid)
FROM dbo.VehicleModeActivity vma
WHERE vma.StartDate >= @lsdate
  AND ISNULL(vma.EndDate, GETUTCDATE()) <= @ledate
  AND (vma.StartDriverIntId = @idInt OR (vma.StartDriverIntId = @noidInt AND vma.EndDriverIntId = @idInt))
   

-- Insert sections all done on the same day
INSERT INTO @Results
        ( DriverIntId,
          VehicleModeID,
          StartDate,
          EndDate
        )
SELECT	DriverIntId, 
		VehicleModeId,
		StartDate,
		EndDate
FROM @Source
WHERE FLOOR(CAST(StartDate AS FLOAT)) = FLOOR(CAST(EndDate AS FLOAT))

-- Now insert sections all done at end of day into the next day
INSERT INTO @Results
        ( DriverIntId,
          VehicleModeID,
          StartDate,
          EndDate
        )
SELECT	DriverIntId, 
		VehicleModeId,
		StartDate,
		DATEADD(ss, -1, CAST(FLOOR(CAST(EndDate AS FLOAT)) AS DATETIME))
FROM @Source
WHERE FLOOR(CAST(StartDate AS FLOAT)) = FLOOR(CAST(EndDate AS FLOAT)) - 1

-- Now insert sections started in previous day into the day
INSERT INTO @Results
        ( DriverIntId,
          VehicleModeID,
          StartDate,
          EndDate
        )
SELECT	DriverIntId, 
		VehicleModeId,
		CAST(FLOOR(CAST(EndDate AS FLOAT)) AS DATETIME),
		EndDate
FROM @Source
WHERE FLOOR(CAST(StartDate AS FLOAT)) = FLOOR(CAST(EndDate AS FLOAT)) - 1

INSERT INTO @Results
        ( DriverIntId,
          VehicleModeId,
          StartDate,
          EndDate
        )
SELECT	DriverIntId, 0, @lsdate, MIN(StartDate)
FROM @Results
GROUP BY DriverIntId   

UPDATE @Results
SET EndDate = CASE VehicleModeID
                   WHEN 4 THEN DATEADD(MINUTE, 1, StartDate)
                   ELSE CASE WHEN GETUTCDATE() < @ledate THEN GETUTCDATE() ELSE @ledate END
              END
WHERE EndDate IS NULL

INSERT INTO @Results
        ( DriverIntId,
          VehicleModeId,
          StartDate,
          EndDate
        )
SELECT DriverIntId, 0, MAX(EndDate), @ledate
FROM @Results
GROUP BY DriverIntId
HAVING MAX(EndDate) < @ledate

-- Calculate Daily totals
DECLARE @Totals TABLE
(
DriverIntId INT,
FloatDate FLOAT,
VehicleModeId INT,
Duration INT
)
INSERT INTO @Totals (DriverIntId, FloatDate, VehicleModeId, Duration)
SELECT DriverIntId, FLOOR(CAST(StartDate AS FLOAT)), VehicleModeId, SUM(DATEDIFF(s, StartDate, EndDate))
FROM @Results
GROUP BY DriverIntId, FLOOR(CAST(StartDate AS FLOAT)), VehicleModeId

SELECT  d.DriverId, dbo.FormatDriverNameByUser(d.DriverId, @luid) AS DriverName,
		r.VehicleModeID,
		r.StartDate,
		r.EndDate,
        DATEDIFF(s, r.StartDate, r.EndDate) AS Duration,
					t0.Duration AS UndefinedDuration,
					t1.Duration AS DriveDuration,
					t2.Duration AS IdleDuration,
					t3.Duration AS KeyOnDuration,
					t4.Duration AS KeyOffDuration,
					t5.Duration AS PTODuration,
					rep.DrivingDistance AS Distance
FROM @Results r
INNER JOIN dbo.Driver d ON r.DriverIntId = d.DriverIntId

LEFT JOIN @Totals t0 ON t0.DriverIntId = r.DriverIntId AND FLOOR(CAST(r.StartDate AS FLOAT)) = t0.FloatDate AND t0.VehicleModeId = 0
LEFT JOIN @Totals t1 ON t1.DriverIntId = r.DriverIntId AND FLOOR(CAST(r.StartDate AS FLOAT)) = t1.FloatDate AND t1.VehicleModeId = 1
LEFT JOIN @Totals t2 ON t2.DriverIntId = r.DriverIntId AND FLOOR(CAST(r.StartDate AS FLOAT)) = t2.FloatDate AND t2.VehicleModeId = 2
LEFT JOIN @Totals t3 ON t3.DriverIntId = r.DriverIntId AND FLOOR(CAST(r.StartDate AS FLOAT)) = t3.FloatDate AND t3.VehicleModeId = 3
LEFT JOIN @Totals t4 ON t4.DriverIntId = r.DriverIntId AND FLOOR(CAST(r.StartDate AS FLOAT)) = t4.FloatDate AND t4.VehicleModeId = 4
LEFT JOIN @Totals t5 ON t5.DriverIntId = r.DriverIntId AND FLOOR(CAST(r.StartDate AS FLOAT)) = t5.FloatDate AND t5.VehicleModeId = 5

LEFT JOIN dbo.Reporting rep ON rep.DriverIntId = r.DriverIntId AND CAST(FLOOR(CAST(r.StartDate AS FLOAT)) AS DATETIME) = rep.Date


WHERE DATEDIFF(s, r.StartDate, r.EndDate) > 0
ORDER BY r.DriverIntId, StartDate



GO
