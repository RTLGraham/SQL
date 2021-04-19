SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_Report_TripsPaxCount]
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
		@uedate DATETIME,
		@distmult FLOAT,
		@diststr NVARCHAR(20)
		
SELECT @maxDiam = dbo.GetUserGeoMaxDiam(@uid)

SELECT  @diststr = [dbo].UserPref(@uid, 203)
SELECT  @distmult = [dbo].UserPref(@uid, 202)

SET @usdate = dbo.TZ_ToUtc(@sdate, DEFAULT, @uid)
SET @uedate = dbo.TZ_ToUtc(@edate, DEFAULT, @uid)

SELECT	v.VehicleId,
		v.Registration,
		d.DriverId,
		dbo.FormatDriverNameByUser(d.DriverId, @uid) AS DriverName,
		[dbo].TZ_GetTime(pcstart.DoorsClosedDateTime, DEFAULT, @uid) 
			AS StartDate,
		pcstart.StopLat AS StartLat,
		pcstart.StopLon AS StartLon,
		ISNULL([dbo].[GetGeofenceNameFromLongLat_Ltd] (pcstart.StopLat, pcstart.StopLon, @uid, [dbo].GetAddressFromLongLat(pcstart.StopLat, pcstart.StopLon), @maxDiam), '') AS StartRevGeocode,
		[dbo].TZ_GetTime(pcend.DoorsOpenDateTime, DEFAULT, @uid) 
			AS EndDate,
		pcend.StopLat AS EndLat,
		pcend.StopLon AS EndLon,
		ISNULL([dbo].[GetGeofenceNameFromLongLat_Ltd] (pcend.StopLat, pcend.StopLon, @uid, [dbo].GetAddressFromLongLat(pcend.StopLat, pcend.StopLon), @maxDiam), '') AS EndRevGeocode,
		DATEDIFF(ss, pcstart.DoorsClosedDateTime, pcend.DoorsOpenDateTime) AS TripDuration,
		(pcend.OdoGPS - pcstart.OdoGPS) * @distmult AS TripDistance,
		@diststr AS DistUnit,
		pcend.StartPassengerCount AS PaxCount,
		pcend.StartPassengerCount / CAST(CASE WHEN v.MaxPax = 0 THEN NULL ELSE v.MaxPax END AS FLOAT) AS PaxLoad,
		@sdate AS CreationDateTime,
		@edate AS ClosureDateTime
FROM

(SELECT ROW_NUMBER() OVER(PARTITION BY VehicleId ORDER BY DoorsClosedDateTime) AS RowNum, *
 FROM dbo.PassengerCount pc
 WHERE pc.VehicleId IN (SELECT VALUE FROM dbo.Split(@vids, ','))
   AND (@routes = '' OR dbo.GetGeofenceIdFromLongLat_Ltd(pc.StopLat, pc.StopLon, @uid, '', @maxDiam) IN (SELECT VALUE FROM dbo.Split(@routes, ',')))
   AND pc.DoorsClosedDateTime BETWEEN @usdate AND @uedate) pcstart

INNER JOIN (SELECT ROW_NUMBER() OVER(PARTITION BY VehicleId ORDER BY DoorsClosedDateTime) AS RowNum, *
			FROM dbo.PassengerCount pc
			WHERE pc.VehicleId IN (SELECT VALUE FROM dbo.Split(@vids, ','))
			  AND (@routes = '' OR dbo.GetGeofenceIdFromLongLat_Ltd(pc.StopLat, pc.StopLon, @uid, '', @maxDiam) IN (SELECT VALUE FROM dbo.Split(@routes, ',')))
			  AND pc.DoorsClosedDateTime BETWEEN @usdate AND @uedate) pcend ON pcstart.VehicleId = pcend.VehicleId
																		 AND pcstart.RowNum = pcend.RowNum - 1
																		 AND pcstart.EndPassengerCount = pcend.StartPassengerCount
INNER JOIN dbo.Vehicle v ON pcend.VehicleId = v.VehicleId
INNER JOIN dbo.Driver d ON pcend.DriverId = d.DriverId

WHERE (pcend.OdoGPS - pcstart.OdoGPS) * @distmult > 0
  OR pcstart.AbsoluteInDoor1 != pcend.AbsoluteInDoor1
  OR pcstart.AbsoluteOutDoor1 != pcend.AbsoluteOutDoor1
  OR pcstart.AbsoluteInDoor2 != pcend.AbsoluteInDoor2
  OR pcstart.AbsoluteOutDoor2 != pcend.AbsoluteOutDoor2
  OR pcstart.AbsoluteInDoor3 != pcend.AbsoluteInDoor3
  OR pcstart.AbsoluteOutDoor3 != pcend.AbsoluteOutDoor3
  OR DATEDIFF(ss, pcstart.DoorsClosedDateTime, pcend.DoorsOpenDateTime) >= 60


GO
