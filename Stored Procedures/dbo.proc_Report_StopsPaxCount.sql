SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[proc_Report_StopsPaxCount]
(
	@uid UNIQUEIDENTIFIER,
	@vids NVARCHAR(MAX),
	@routes NVARCHAR(MAX),
	@sdate DATETIME,
	@edate DATETIME
)
AS

--DECLARE	@vids NVARCHAR(MAX),
--		@sdate DATETIME,
--		@edate DATETIME,
--		@uid UNIQUEIDENTIFIER;
--
--SET		@vids = N'CCE4340D-8914-4F66-ABEC-101973B77582'
--SET		@sdate = '2014-06-29 07:00'
--SET		@edate = '2014-06-29 07:59'
--SET		@uid = N'F9A00148-7520-461B-B650-7514B026B373'

DECLARE @maxDiam FLOAT,
		@usdate DATETIME,
		@uedate DATETIME
SELECT @maxDiam = dbo.GetUserGeoMaxDiam(@uid)

SET @usdate = dbo.TZ_ToUtc(@sdate, DEFAULT, @uid)
SET @uedate = dbo.TZ_ToUtc(@edate, DEFAULT, @uid)

SELECT	v.VehicleId,
		v.Registration,
		d.DriverId,
		dbo.FormatDriverNameByUser(d.DriverId, @uid) AS DriverName,
		[dbo].TZ_GetTime(pc.DoorsOpenDateTime, DEFAULT, @uid)
			AS StartDate,
		pc.StopLat AS Lat,
		pc.StopLon AS Lon,
		ISNULL([dbo].[GetGeofenceNameFromLongLat_Ltd] (pc.StopLat, pc.StopLon, @uid, [dbo].GetAddressFromLongLat(pc.StopLat, pc.StopLon), @maxDiam), '') AS RevGeocode,
		[dbo].TZ_GetTime(pc.DoorsClosedDateTime, DEFAULT, @uid) 
			AS EndDate,
		DATEDIFF(ss, pc.DoorsOpenDateTime, pc.DoorsClosedDateTime) AS StopDuration,
		pc.StartPassengerCount AS PaxStart,
		pc.DeltaInDoor1 + pc.DeltaInDoor2 + pc.DeltaInDoor3 AS PaxIn,
		pc.DeltaOutDoor1 + pc.DeltaOutDoor2 + pc.DeltaOutDoor3 AS PaxOut,
		pc.EndPassengerCount AS PaxEnd,
		@sdate AS CreationDateTime,
		@edate AS ClosuredateTime
FROM dbo.PassengerCount pc
INNER JOIN dbo.Driver d ON pc.DriverId = d.DriverId
INNER JOIN dbo.Vehicle v ON pc.VehicleId = v.VehicleId
WHERE pc.VehicleId IN (SELECT VALUE FROM dbo.Split(@vids, ','))
  AND (@routes = '' OR dbo.GetGeofenceIdFromLongLat_Ltd(pc.StopLat, pc.StopLon, @uid, '', @maxDiam) IN (SELECT VALUE FROM dbo.Split(@routes, ',')))
  AND pc.DoorsClosedDateTime BETWEEN @usdate AND @uedate
  AND NOT (pc.DeltaInDoor1 + pc.DeltaInDoor2 + pc.DeltaInDoor3 = 0 AND pc.DeltaOutDoor1 + pc.DeltaOutDoor2 + pc.DeltaOutDoor3 = 0) -- Don't show rows where no passenger change


GO
