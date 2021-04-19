SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_ReportWorkingDay]
		@vids NVARCHAR(MAX),
		@uid UNIQUEIDENTIFIER,
		@sdate DATETIME,
		@edate DATETIME
AS 

--DECLARE @vids NVARCHAR(MAX),
--		@uid UNIQUEIDENTIFIER,
--		@sdate DATETIME,
--		@edate DATETIME
--SET @vids = N'A7FB5DE6-9054-44D3-BF4E-C29DF0040A40'
--SET @uid = N'5164F6E5-1143-44F8-9B10-C39DB1429A8C'
--SET @sdate = '2016-07-31 00:00'
--SET @edate = '2016-07-31 23:59'

DECLARE @sdateUT DATETIME,
		@edateUT DATETIME,
		@fleetNumber VARCHAR(1025),
		@diststr VARCHAR(20),
		@distmult FLOAT

SET @sdateUT = @sdate
SET @edateUT = @edate

SET @sdate = dbo.TZ_ToUtc(@sdate, DEFAULT, @uid)
SET @edate = dbo.TZ_ToUtc(@edate, DEFAULT, @uid)

SET @diststr = [dbo].UserPref(@uid, 203)
SET @distmult = [dbo].UserPref(@uid, 202)
SET @fleetNumber = ISNULL([dbo].UserPref(@uid, 379), 'Fleet Number')

--SELECT	v.Registration,
--		CONVERT(VARCHAR(11),dbo.[TZ_GetTime](dt.StartEventDateTime, DEFAULT, @uid),121) AS [Date],
--		[dbo].[TZ_GetTime](MIN(dt.StartEventDateTime), DEFAULT, @uid) AS FirstKeyOn,
--		[dbo].[TZ_GetTime](MAX(dt.EndEventDateTime), DEFAULT, @uid) AS LastKeyOff,
--		DATEDIFF(second, MIN(dt.StartEventDateTime), MAX(dt.EndEventDateTime)) AS WorkingHours,
--		SUM(dt.TripDuration*60) AS DrivingHours
--FROM dbo.DriverTrip dt
--	INNER JOIN dbo.Vehicle v ON dt.VehicleIntId = v.VehicleIntId
--WHERE v.VehicleId IN (SELECT value FROM dbo.Split(@vids, ','))
--  AND v.Archived = 0 AND v.IVHId IS NOT NULL
--  AND dt.EndEventDateTime BETWEEN @sdate AND @edate
--GROUP BY v.Registration, CONVERT(VARCHAR(11),[dbo].[TZ_GetTime](dt.StartEventDateTime, DEFAULT, @uid),121)
--ORDER BY v.Registration, CONVERT(VARCHAR(11),[dbo].[TZ_GetTime](dt.StartEventDateTime, DEFAULT, @uid),121)

SELECT	v.VehicleId,
		v.Registration,
		v.FleetNumber,
		@fleetNumber AS FleetNumberText,
		CONVERT(VARCHAR(11),[dbo].[TZ_GetTime](dt.StartEventDateTime, DEFAULT, @uid),121) AS [Date],
--		[dbo].[TZ_GetTime](dt.StartEventDateTime, DEFAULT, @uid) AS [Date], 
		[dbo].[TZ_GetTime](MIN(dt.StartEventDateTime), DEFAULT, @uid) AS FirstKeyOn,
		[dbo].[TZ_GetTime](MAX(dt.EndEventDateTime), DEFAULT, @uid) AS LastKeyOff,
		DATEDIFF(second, MIN(dt.StartEventDateTime), MAX(dt.EndEventDateTime)) AS WorkingHours,
		SUM(dt.TripDuration*60) AS DrivingHours,
		ROUND(SUM(dt.TripDistance) * @distmult, 2) AS DrivingDistance,
		@sdateUT AS StartDate,
		@edateUT AS EndDate,
		@diststr AS DistanceUnit
		--,SUM(dt.TripDistance)/1000.0 AS TripDistance
FROM dbo.DriverTrip dt
	INNER JOIN dbo.Vehicle v ON dt.VehicleIntId = v.VehicleIntId
WHERE v.VehicleId IN (SELECT value FROM dbo.Split(@vids, ','))
  AND v.Archived = 0 AND v.IVHId IS NOT NULL
  AND dt.EndEventDateTime BETWEEN @sdate AND @edate
GROUP BY v.VehicleId, v.Registration, v.FleetNumber, CONVERT(VARCHAR(11),[dbo].[TZ_GetTime](dt.StartEventDateTime, DEFAULT, @uid),121)
ORDER BY v.Registration, CONVERT(VARCHAR(11),[dbo].[TZ_GetTime](dt.StartEventDateTime, DEFAULT, @uid),121)
--GROUP BY v.VehicleId, v.Registration, v.FleetNumber, dt.StartEventDateTime
--ORDER BY v.Registration, dt.StartEventDateTime

GO
