SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_VideoTool_Driver_Escalated]
    (
      @did UNIQUEIDENTIFIER
    )
AS 
	--DECLARE @did UNIQUEIDENTIFIER
	--SET @did = N'1FD99647-E230-4332-8888-80EC53F1E182'

	DECLARE @uid UNIQUEIDENTIFIER

	SELECT TOP 1 @uid = u.UserID
	FROM dbo.[User] u
	INNER JOIN dbo.Customer c ON c.CustomerId = u.CustomerID
	INNER JOIN dbo.CustomerDriver cd ON cd.CustomerId = c.CustomerId
	WHERE cd.DriverId = @did
	  AND cd.Archived = 0
	  AND cd.EndDate IS NULL
	  AND u.Archived = 0

	DECLARE @maxDiam FLOAT
	SELECT @maxDiam = dbo.GetUserGeoMaxDiam(@uid)
	
	DECLARE @speedmult FLOAT
	SET @speedmult = cast([dbo].[UserPref](@uid, 208) as float)

	DECLARE @expirycoach INT, @expirynoncoach INT
	SELECT @expirycoach = CAST(ISNULL(dbo.CustomerPref(CustomerID, 3009), 8760) AS INT), @expirynoncoach = CAST(ISNULL(dbo.CustomerPref(CustomerID, 3010), 1440) AS INT)
	FROM dbo.[User]
	WHERE UserID = @uid


	SELECT
		o.IncidentId,
		o.VehicleIntId,
		o.DriverIntId,
		o.VehicleId,
		o.Registration,
		o.VehicleTypeID,
		o.DriverId,
		o.DriverName,
		o.CreationCodeId,
		o.Long,
		o.Lat,
		o.ReverseGeoCode,
		o.Heading,
		o.Speed,
		o.OdoGPS,
		o.OdoRoadSpeed,
		o.OdoDashboard,
		o.EventDateTime,
		o.DigitalIO,
		o.SpeedLimit,
		o.LastOperation,
		o.Archived,
		o.CustomerIntId,
		o.EventId,
		o.CoachingStatusId,
		o.PreviousCoachingStatusId,
		o.Serial,
		o.ApiEventId,
		o.ApiMetadataId,
		o.OffsetHours,
		o.ApiVideoId_1,
		o.ApiFileName_1,
		o.ApiStartTime_1,
		o.ApiEndTime_1,
		o.IsVideoStoredLocally_1,
		o.ApiVideoId_2,
		o.ApiFileName_2,
		o.ApiStartTime_2,
		o.ApiEndTime_2,
		o.IsVideoStoredLocally_2,
		o.ApiUrl,
		o.ApiUser,
		o.ApiPassword,
		o.BucketName,
		o.MaxX,
		o.MaxY,
		o.MinX,
		o.MinY,
		o.IsEscalated,
		o.VideoAvailability
	FROM
    (
		SELECT	i.IncidentId,
				i.VehicleIntId,
				i.DriverIntId,
				v.VehicleId,
				v.Registration,
				v.VehicleTypeID,
				d.DriverId,
				dbo.FormatDriverNameByUser(d.DriverId, @uid) AS DriverName,
				--i.CreationCodeId
				CASE WHEN i.CreationCodeId = 0 AND i.ApiMetadataId IS NULL THEN 435 ELSE i.CreationCodeId END AS CreationCodeId,
				i.Long,
				i.Lat,
				[dbo].[GetGeofenceNameFromLongLat_Ltd] (i.Lat, i.Long, @uid, [dbo].[GetAddressFromLongLat](i.Lat, i.Long), @maxDiam) as ReverseGeoCode,
				i.Heading,
				CAST(i.Speed * @speedmult AS SMALLINT) as Speed,
				e.OdoGPS,
				e.OdoRoadSpeed,
				e.OdoDashboard,
				dbo.TZ_GetTime(i.EventDateTime, DEFAULT, @uid) AS EventDateTime,
				e.DigitalIO,
				e.SpeedLimit,
				i.LastOperation,
				i.Archived,
				i.CustomerIntId,
				i.EventId,
				i.CoachingStatusId,
				dbo.GetPreviousCoachingStatus(i.IncidentId, i.CoachingStatusId) AS PreviousCoachingStatusId,
				c.Serial,
			
				i.ApiEventId,
				i.ApiMetadataId,
				dbo.TZ_GetOffsetInHours(@uid, i.EventDateTime) AS OffsetHours,
			
				--v1.VideoId AS VideoId_1,
				v1.ApiVideoId AS ApiVideoId_1,
				MAX(v1.ApiFileName) AS ApiFileName_1,
				--v1.ApiStartTime AS ApiStartTime_1,
				--v1.ApiEndTime AS ApiEndTime_1,
				dbo.TZ_GetTime(v1.ApiStartTime, DEFAULT, @uid) AS ApiStartTime_1,
				dbo.TZ_GetTime(v1.ApiEndTime, DEFAULT, @uid) AS ApiEndTime_1,
				MAX(CAST(v1.IsVideoStoredLocally AS TINYINT)) AS IsVideoStoredLocally_1,

				--v2.VideoId AS VideoId_2,
				v2.ApiVideoId AS ApiVideoId_2,
				MAX(v2.ApiFileName) AS ApiFileName_2,
				--v2.ApiStartTime AS ApiStartTime_2,
				--v2.ApiEndTime AS ApiEndTime_2,
				dbo.TZ_GetTime(v2.ApiStartTime, DEFAULT, @uid) AS ApiStartTime_2,
				dbo.TZ_GetTime(v2.ApiEndTime, DEFAULT, @uid) AS ApiEndTime_2,
				MAX(CAST(v2.IsVideoStoredLocally AS TINYINT)) AS IsVideoStoredLocally_2,
			
				p.ApiUrl,
				p.ApiUser,
				p.ApiPassword,
				p.BucketName,

				i.MaxX, i.MaxY, i.MinX, i.MinY,
				CAST(1 AS BIT) AS IsEscalated,
				CASE WHEN i.CoachingStatusId IN (2,4,97) THEN
					CASE WHEN DATEDIFF(HOUR, i.EventDateTime, GETDATE()) > @expirycoach THEN 'Unavailable' ELSE CASE WHEN MAX(v1.ApiFileName) = MAX(v1.ApiEventId) THEN 'S3' ELSE CASE WHEN DATEDIFF(HOUR, i.EventDateTime, GETDATE()) <= 1440 THEN 'TrajetAndRTL' ELSE 'RTL' END END END 
				ELSE	
					CASE WHEN DATEDIFF(HOUR, i.EventDateTime, GETDATE()) > @expirynoncoach THEN 'Unavailable' ELSE CASE WHEN MAX(v1.ApiFileName) = MAX(v1.ApiEventId) THEN 'S3' ELSE CASE WHEN DATEDIFF(HOUR, i.EventDateTime, GETDATE()) <= 1440 THEN 'Trajet' ELSE 'Unavailable' END END END 	
				END	AS VideoAvailability

		FROM dbo.ObjectShare os 
			INNER JOIN dbo.CAM_Incident i ON os.ObjectIntId = i.IncidentId AND os.ObjectTypeId = 1 AND os.Archived = 0
			LEFT OUTER JOIN dbo.Event e ON i.EventId = e.EventId
			INNER JOIN dbo.Driver d ON i.DriverIntId = d.DriverIntId
			INNER JOIN dbo.Vehicle v ON i.VehicleIntId = v.VehicleIntId
			INNER JOIN dbo.Customer cust ON i.CustomerIntId = cust.CustomerIntId
			INNER JOIN dbo.Camera c ON c.CameraIntId = i.CameraIntId
			INNER JOIN dbo.Project p ON c.ProjectId = p.ProjectId
			INNER JOIN dbo.CAM_Video v1 ON i.IncidentId = v1.IncidentId AND v1.CameraNumber = 1 AND v1.VideoStatus = 1
			LEFT OUTER JOIN dbo.CAM_Video v2 ON i.IncidentId = v2.IncidentId AND v2.CameraNumber = 2 AND v2.VideoStatus = 1
		WHERE d.DriverId = @did 
			AND i.Archived = 0
			AND c.Archived = 0
			AND i.CreationCodeId IN (0, 55, 455, 456, 436, 437, 438)
			AND i.CoachingStatusId NOT IN (97, 98)
		GROUP BY i.IncidentId, i.VehicleIntId, i.DriverIntId, v.VehicleId, v.Registration, v.VehicleTypeID, d.DriverId,
			i.CreationCodeId, i.Long, i.Lat, i.Heading, i.Speed, e.OdoGPS, e.OdoRoadSpeed, e.OdoDashboard, i.EventDateTime, e.DigitalIO,
			e.SpeedLimit, i.LastOperation, i.Archived, i.CustomerIntId, i.EventId, i.CoachingStatusId, c.Serial, i.ApiEventId, i.ApiMetadataId,
			v1.ApiStartTime, v1.ApiEndTime, v1.ApiVideoId, v2.ApiVideoId, v2.ApiStartTime, v2.ApiEndTime, p.ApiUrl, p.ApiUser, p.ApiPassword,p.BucketName,
			i.MaxX, i.MaxY, i.MinX, i.MinY, i.IsEscalated
	
		UNION ALL

		SELECT	i.IncidentId,
				i.VehicleIntId,
				i.DriverIntId,
				v.VehicleId,
				v.Registration,
				v.VehicleTypeID,
				d.DriverId,
				dbo.FormatDriverNameByUser(d.DriverId, @uid) AS DriverName,
				--i.CreationCodeId
				CASE WHEN i.CreationCodeId = 0 AND i.ApiMetadataId IS NULL THEN 435 ELSE i.CreationCodeId END AS CreationCodeId,
				i.Long,
				i.Lat,
				[dbo].[GetGeofenceNameFromLongLat_Ltd] (i.Lat, i.Long, @uid, [dbo].[GetAddressFromLongLat](i.Lat, i.Long), @maxDiam) as ReverseGeoCode,
				i.Heading,
				CAST(i.Speed * @speedmult AS SMALLINT) as Speed,
				e.OdoGPS,
				e.OdoRoadSpeed,
				e.OdoDashboard,
				dbo.TZ_GetTime(i.EventDateTime, DEFAULT, @uid) AS EventDateTime,
				e.DigitalIO,
				e.SpeedLimit,
				i.LastOperation,
				i.Archived,
				i.CustomerIntId,
				i.EventId,
				i.CoachingStatusId,
				dbo.GetPreviousCoachingStatus(i.IncidentId, i.CoachingStatusId) AS PreviousCoachingStatusId,
				c.Serial,
			
				i.ApiEventId,
				i.ApiMetadataId,
				dbo.TZ_GetOffsetInHours(@uid, i.EventDateTime) AS OffsetHours,
			
				--v1.VideoId AS VideoId_1,
				v1.ApiVideoId AS ApiVideoId_1,
				MAX(v1.ApiFileName) AS ApiFileName_1,
				--v1.ApiStartTime AS ApiStartTime_1,
				--v1.ApiEndTime AS ApiEndTime_1,
				dbo.TZ_GetTime(v1.ApiStartTime, DEFAULT, @uid) AS ApiStartTime_1,
				dbo.TZ_GetTime(v1.ApiEndTime, DEFAULT, @uid) AS ApiEndTime_1,
				MAX(CAST(v1.IsVideoStoredLocally AS TINYINT)) AS IsVideoStoredLocally_1,

				--v2.VideoId AS VideoId_2,
				v2.ApiVideoId AS ApiVideoId_2,
				MAX(v2.ApiFileName) AS ApiFileName_2,
				--v2.ApiStartTime AS ApiStartTime_2,
				--v2.ApiEndTime AS ApiEndTime_2,
				dbo.TZ_GetTime(v2.ApiStartTime, DEFAULT, @uid) AS ApiStartTime_2,
				dbo.TZ_GetTime(v2.ApiEndTime, DEFAULT, @uid) AS ApiEndTime_2,
				MAX(CAST(v2.IsVideoStoredLocally AS TINYINT)) AS IsVideoStoredLocally_2,
			
				p.ApiUrl,
				p.ApiUser,
				p.ApiPassword,
				p.BucketName,

				i.MaxX, i.MaxY, i.MinX, i.MinY,
				CAST(1 AS BIT) AS IsEscalated,
				CASE WHEN i.CoachingStatusId IN (2,4,97) THEN
					CASE WHEN DATEDIFF(HOUR, i.EventDateTime, GETDATE()) > @expirycoach THEN 'Unavailable' ELSE CASE WHEN MAX(v1.ApiFileName) = MAX(v1.ApiEventId) THEN 'S3' ELSE CASE WHEN DATEDIFF(HOUR, i.EventDateTime, GETDATE()) <= 1440 THEN 'TrajetAndRTL' ELSE 'RTL' END END END 
				ELSE	
					CASE WHEN DATEDIFF(HOUR, i.EventDateTime, GETDATE()) > @expirynoncoach THEN 'Unavailable' ELSE CASE WHEN MAX(v1.ApiFileName) = MAX(v1.ApiEventId) THEN 'S3' ELSE CASE WHEN DATEDIFF(HOUR, i.EventDateTime, GETDATE()) <= 1440 THEN 'Trajet' ELSE 'Unavailable' END END END 	
				END	AS VideoAvailability

		FROM dbo.CAM_Incident i
			LEFT OUTER JOIN dbo.Event e ON i.EventId = e.EventId
			INNER JOIN dbo.Driver d ON i.DriverIntId = d.DriverIntId
			INNER JOIN dbo.Vehicle v ON i.VehicleIntId = v.VehicleIntId
			INNER JOIN dbo.Customer cust ON i.CustomerIntId = cust.CustomerIntId
			INNER JOIN dbo.Camera c ON c.CameraIntId = i.CameraIntId
			INNER JOIN dbo.Project p ON c.ProjectId = p.ProjectId
			INNER JOIN dbo.CAM_Video v1 ON i.IncidentId = v1.IncidentId AND v1.CameraNumber = 1 AND v1.VideoStatus = 1
			LEFT OUTER JOIN dbo.CAM_Video v2 ON i.IncidentId = v2.IncidentId AND v2.CameraNumber = 2 AND v2.VideoStatus = 1
		WHERE d.DriverId = @did 
			AND i.Archived = 0
			AND i.CreationCodeId IN (0, 55, 455, 456, 436, 437, 438)
			AND i.CoachingStatusId = 97
		GROUP BY i.IncidentId, i.VehicleIntId, i.DriverIntId, v.VehicleId, v.Registration, v.VehicleTypeID, d.DriverId,
			i.CreationCodeId, i.Long, i.Lat, i.Heading, i.Speed, e.OdoGPS, e.OdoRoadSpeed, e.OdoDashboard, i.EventDateTime, e.DigitalIO,
			e.SpeedLimit, i.LastOperation, i.Archived, i.CustomerIntId, i.EventId, i.CoachingStatusId, c.Serial, i.ApiEventId, i.ApiMetadataId,
			v1.ApiStartTime, v1.ApiEndTime, v1.ApiVideoId, v2.ApiVideoId, v2.ApiStartTime, v2.ApiEndTime, p.ApiUrl, p.ApiUser, p.ApiPassword,p.BucketName,
			i.MaxX, i.MaxY, i.MinX, i.MinY, i.IsEscalated
		--ORDER BY i.EventDateTime DESC
	) o
	WHERE o.VideoAvailability != 'Unavailable'
	ORDER BY o.EventDateTime DESC


GO
