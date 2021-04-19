SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_ReportDriverTimesheet]
(
	@did UNIQUEIDENTIFIER,
	@uid UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME
)
AS

---- Nestle
--DECLARE @did UNIQUEIDENTIFIER,
--		@uid UNIQUEIDENTIFIER,
--		@sdate DATETIME,
--		@edate DATETIME
--SET @did = N'AB0B496F-0659-495D-AD3D-EB5274BDC73C'
--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
--SET @sdate = '2013-03-15 00:00'
--SET @edate = '2013-03-20 23:59'

---- Roadsense
--DECLARE @did UNIQUEIDENTIFIER,
--		@uid UNIQUEIDENTIFIER,
--		@sdate DATETIME,
--		@edate DATETIME
--SET @did = N'E8F03F5F-5DB6-4DEB-922E-550DF5B836CC'
--SET @uid = N'3C29A1A3-95A5-46B6-A416-39AEE33B5D98'
--SET @sdate = '2015-07-13 00:00'
--SET @edate = '2015-07-13 23:59'

DECLARE @dintid INT,
		@diststr VARCHAR(20),
		@distmult FLOAT,
        @custid UNIQUEIDENTIFIER,
		@ldid UNIQUEIDENTIFIER,
		@luid UNIQUEIDENTIFIER,
		@lsdate DATETIME,
		@ledate DATETIME
		
	SET @ldid = @did
	SET @lsdate = @sdate
	SET @ledate = @edate
	SET @luid = @uid
SELECT @diststr = [dbo].UserPref(@luid, 203)
SELECT @distmult = [dbo].UserPref(@luid, 202)
SELECT @custid = CustomerID FROM [User] WHERE userID = @luid

SET @lsdate = dbo.TZ_ToUtc(@lsdate, DEFAULT, @luid)
SET @ledate = dbo.TZ_ToUtc(@ledate, DEFAULT, @luid)

SET @dintid = dbo.GetDriverIntFromId(@ldid);

WITH ttDay AS
(
	SELECT	ROW_NUMBER() OVER(ORDER BY CONVERT(CHAR(6),starteventdatetime, 12)) AS DayNum,
			CONVERT(CHAR(6),starteventdatetime, 12) AS ttDay,
			MIN(StartEventDateTime) AS StartDateTime,
			MAX(EndEventDateTime) AS EndDateTime,
			DATEDIFF(mi, MIN(StartEventDateTime), MAX(EndEventDateTime)) AS ShiftTime,
			1440 - DATEDIFF(mi, MIN(StartEventDateTime), MAX(EndEventDateTime)) AS RestTime,
			SUM(DATEDIFF(mi, StartEventDateTime, EndEventDateTime)) AS DriveTime,
			DATEDIFF(mi, MIN(StartEventDateTime), MAX(EndEventDateTime)) - SUM(DATEDIFF(mi, StartEventDateTime, EndEventDateTime)) AS StopTime,
			SUM(CAST(TripDistance AS BIGINT)) AS Distance
	FROM dbo.DriverTrip WITH (NOLOCK)
	WHERE DriverIntId = @dintid
	  AND StartEventDateTime BETWEEN @lsdate AND @ledate
	GROUP BY CONVERT(CHAR(6),starteventdatetime, 12)
)

SELECT  dbo.FormatDriverNameByUser(@ldid, @luid) AS DriverName,
		v.VehicleId,
		v.Registration,
		tt.StartLat,
        tt.StartLong,
        dbo.GetGeofenceNameFromLongLat (tt.StartLat, tt.StartLong, @luid, .dbo.GetAddressFromLongLat (tt.StartLat, tt.StartLong)) as StartLocation,
        dbo.TZ_GetTime(tt.StartEventDateTime, DEFAULT, @luid) AS StartEventdateTime,
        tt.EndLat,
        tt.EndLong,
        .dbo.GetGeofenceNameFromLongLat (tt.EndLat, tt.EndLong, @luid, dbo.GetAddressFromLongLat (tt.EndLat, tt.EndLong)) as EndLocation,        
        dbo.TZ_GetTime(tt.EndEventDateTime, DEFAULT, @luid) AS EndEventDateTime,
        DATEDIFF(mi, tt.StartEventDateTime, tt.EndEventDateTime) AS TripDuration,
        tt.TripDistance * @distmult AS TripDistance,
		ttPeriod.PeriodShiftTime,
		ttPeriod.PeriodDriveTime,
		ttPeriod.PeriodDistance * @distmult AS PeriodDistance,
		ttPeriod.PeriodStopTime,
		dbo.TZ_GetTime(ttday.StartDateTime, DEFAULT, @luid) AS StartDayTime,
		dbo.TZ_GetTime(ttday.EndDateTime, DEFAULT, @luid) AS EndDayTime,
		ttday.ShiftTime AS DayShiftTime,
		ISNULL(DATEDIFF(mi, ttyesterday.EndDateTime, ttday.StartDateTime),0) AS DayRestTime,
        ttday.DriveTime AS DayDriveTime,
		ttday.Distance * @distmult AS DayDriveDistance,
		ttday.StopTime AS DayStopTime,
		@diststr AS DistanceUnit
FROM dbo.DriverTrip tt WITH (NOLOCK)
INNER JOIN dbo.Vehicle v ON tt.VehicleIntId = v.VehicleIntId
INNER JOIN ttDay ON CONVERT(CHAR(6),tt.starteventdatetime, 12) = ttDay.ttDay
LEFT JOIN (SELECT	ROW_NUMBER() OVER(ORDER BY CONVERT(CHAR(6),starteventdatetime, 12)) AS DayNum,
					MIN(StartEventDateTime) AS StartDateTime,
					MAX(EndEventDateTime) AS EndDateTime
			FROM dbo.DriverTrip WITH (NOLOCK)
			WHERE DriverIntId = @dintid
			  AND StartEventDateTime BETWEEN @lsdate AND @ledate
			GROUP BY CONVERT(CHAR(6),starteventdatetime, 12)) ttyesterday ON ttday.DayNum = ttyesterday.DayNum + 1					
CROSS JOIN (SELECT SUM(ShiftTime) AS PeriodShiftTime, SUM(DriveTime) AS PeriodDriveTime, SUM(StopTime) AS PeriodStopTime, SUM(Distance) AS PeriodDistance
			FROM ttDay
			) ttPeriod
WHERE tt.DriverIntId = @dintid
  AND tt.StartEventDateTime BETWEEN @lsdate AND @ledate
  AND tt.TripDistance > 0 -- remove trips of zero distance
ORDER BY tt.StartEventDateTime

GO
