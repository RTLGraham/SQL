SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportDeliveryNotification]
(
	@gids varchar(max),
	@vids varchar(max),
	@sdate datetime,
	@edate datetime,
	@uid uniqueidentifier
)
AS

--DECLARE	@gids VARCHAR(MAX),
--		@vids varchar(max),
--		@sdate datetime,
--		@edate datetime,
--		@uid UNIQUEIDENTIFIER

--SET @gids = N'71EA94C1-857A-4FD2-9836-723269C4CEF3'		
--SET @vids = N'AA5ECF1F-A319-463A-A6A0-EEA71275A3D2'
--SET @sdate = '2018-06-07 00:00'
--SET @edate = '2018-06-07 23:59'
--SET	@uid = N'D46602E9-8709-4963-A7DE-194FB53A1A3E'

-- Section added to allow the report to be automatically scheduled
IF datepart(yyyy, @sdate) = '1960'
BEGIN
	SET @edate = dbo.Calc_Schedule_EndDate(@sdate, @uid)
	SET @sdate = dbo.Calc_Schedule_StartDate(@sdate, @uid)
END

DECLARE @Vehicles TABLE (VehicleId UNIQUEIDENTIFIER)
IF @vids IS NULL -- populate vehicle list from Group Ids provided
BEGIN
	INSERT INTO @Vehicles ( VehicleId )
	SELECT EntityDataId
	FROM dbo.GroupDetail gd
	INNER JOIN dbo.[Group] g ON gd.GroupId = g.GroupId
	WHERE g.GroupTypeId = 1
	  AND g.IsParameter = 0
	  AND g.Archived = 0
	  AND g.GroupId IN (SELECT VALUE FROM dbo.Split(@gids, ','))
END ELSE -- populate from list of Vehicle Ids provided
BEGIN
	INSERT INTO	@Vehicles ( VehicleId )
	SELECT VALUE FROM dbo.Split(@vids, ',')
END

DECLARE @sdate_in DATETIME
DECLARE @edate_in DATETIME

SET @sdate_in = @sdate
SET @edate_in = @edate
SET @sdate = dbo.TZ_ToUtc(@sdate, DEFAULT, @uid)
SET @edate = dbo.TZ_ToUtc(@edate, DEFAULT, @uid)

SELECT Result.VehicleId ,
				Result.DriverId ,
				Result.GroupName ,
				Result.GeofenceId ,
				Result.Registration ,
				Result.DriverName,
				Result.DriverNumber,
				Result.GeofenceName ,
				Result.SiteId ,
				Result.Recipients ,
				Result.TimeSiteIdEntered ,
				Result.TimeGeofenceBroken ,
				Result.TimeVehicleArrived ,
				Result.Significance ,
				Result.AdditionalInfo ,
				Result.sdate ,
				Result.edate ,
				Result.CreationDateTime ,
				Result.ClosureDateTime,
				Result.TimeCallInitiated,
				Result.CallDuration,
				Result.CallAttempts, 
				ISNULL(cs.Description, Result.CallResult) AS Results
FROM	
	(
		SELECT	v.VehicleId ,
				d.DriverId ,
				gr.GroupName ,
				g.GeofenceId ,
				v.Registration ,
				dbo.FormatDriverNameByUser(d.DriverId, @uid) as DriverName,
				d.Number AS DriverNumber,
				g.Name AS GeofenceName ,
				g.SiteId ,
				ISNULL(dn.TelephoneNumber, g.Recipients) AS Recipients ,
				[dbo].TZ_GetTime(dn.TimeDestinationIDEntered,default,@uid) AS TimeSiteIdEntered ,
				[dbo].TZ_GetTime(dn.TimeGeofenceEntered,default,@uid) AS TimeGeofenceBroken ,
				MIN([dbo].TZ_GetTime(t.Timestamp,default,@uid)) AS TimeVehicleArrived ,
				--dn.CallResult AS Results ,
				--vcs.Description AS Results ,
				MAX(vcs.Significance) AS Significance ,
				NULL AS AdditionalInfo ,
				@sdate AS sdate ,
				@edate AS edate ,
				@sdate_in AS CreationDateTime ,
				@edate_in AS ClosureDateTime,
				ISNULL(MIN([dbo].TZ_GetTime(vc.TimeInitiated,default,@uid)), dbo.TZ_GetTime(dn.TimeNotificationInitiated, DEFAULT, @uid)) AS TimeCallInitiated,
				MAX(vc.CallDuration) AS CallDuration,
				ISNULL(MAX(vc.CallAttempts), 1) AS CallAttempts,
				dn.CallResult
		FROM	dbo.DeliveryNotification dn
		LEFT JOIN dbo.VOIP_Call vc ON dn.NotificationID = vc.ExternalIntId
		INNER JOIN dbo.Vehicle v ON dn.VehicleID = v.VehicleId
		INNER JOIN @Vehicles vt ON v.VehicleId = vt.VehicleId
		INNER JOIN dbo.GroupDetail gd ON gd.EntityDataId = v.VehicleId
		INNER JOIN dbo.[Group] gr ON gr.GroupId = gd.GroupId
		INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
		LEFT JOIN dbo.Driver d ON dn.DriverID = d.DriverId
		INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId AND cv.CustomerId = c.CustomerId
		INNER JOIN dbo.Geofence g ON dn.GeofenceID = g.GeofenceId AND g.Archived = 0
		LEFT JOIN dbo.VOIP_CallStatus vcs ON dn.CallResult = vcs.Description
		LEFT JOIN dbo.TripsAndStops t ON t.VehicleIntID = v.VehicleIntId AND t.CustomerIntID = c.CustomerIntId
					AND t.Timestamp > dn.TimeDestinationIDEntered
					AND t.Timestamp < DATEADD(hh,5,dn.TimeDestinationIDEntered) -- assume vehicle will arrive within 5 hours of entering site id
					AND dbo.DistanceBetweenPoints(t.Latitude,t.Longitude,g.Centerlat,g.Centerlon) <= g.Radius1
					AND t.VehicleState IN (5,0) -- vehicle must stop within inner geofence boundary
		WHERE gr.GroupId IN (SELECT VALUE FROM dbo.Split(@gids, ','))
		  --AND v.VehicleID IN (SELECT Value FROM dbo.Split(@vids, ','))
		  AND dn.TimeDestinationIDEntered >= @sdate 
		  AND dn.TimeDestinationIDEntered <= @edate
		  --AND dn.TimeGeofenceEntered IS NOT NULL
		  AND cv.EndDate IS NULL
		GROUP BY v.VehicleId ,
				d.DriverId ,
				gr.GroupName ,
				g.GeofenceId ,
				v.Registration ,
				d.FirstName, d.Surname ,
				d.Number ,
				g.Name ,
				g.SiteId ,
				dn.TelephoneNumber ,
				dn.TimeDestinationIDEntered ,
				dn.TimeGeofenceEntered ,
				dn.TimeNotificationInitiated,
				dn.CallResult,
				g.Recipients
				--dn.CallResult 
				--vcs.Description
	) Result
	LEFT JOIN dbo.VOIP_CallStatus cs ON cs.Significance = Result.Significance
ORDER BY Result.GroupName, Result.TimeSiteIdEntered, Result.TimeCallInitiated


GO
