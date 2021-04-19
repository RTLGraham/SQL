SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_VideoList_Vehicle_RequestedTop]
(
	@uid UNIQUEIDENTIFIER,
	@vid UNIQUEIDENTIFIER,
	@top INT
)
AS 
	--DECLARE	@uid UNIQUEIDENTIFIER,
	--		@vid UNIQUEIDENTIFIER,
	--		@top INT
			
	--SET @uid = N'D46602E9-8709-4963-A7DE-194FB53A1A3E'
	--SET @vid = N'1CA8DEF4-9249-46A0-8F92-79517A7C97D9'
	--SET @top = 10
			
	DECLARE @expirycoach INT, @expirynoncoach INT
	SELECT @expirycoach = CAST(ISNULL(dbo.CustomerPref(CustomerID, 3009), 8760) AS INT), @expirynoncoach = CAST(ISNULL(dbo.CustomerPref(CustomerID, 3010), 1440) AS INT)
	FROM dbo.[User]
	WHERE UserID = @uid

	SELECT TOP (@top)
			i.IncidentId,
			v.VehicleId,
			v.Registration,
			i.CreationCodeId,
			i.Long,
			i.Lat,
			i.Heading,
			--dbo.TZ_GetTime(i.EventDateTime, DEFAULT, @uid) AS EventDateTime,
			CASE WHEN v1.IncidentId IS NOT NULL
				THEN dbo.TZ_GetTime(v1.ApiStartTime, DEFAULT, @uid)
				ELSE ISNULL(dbo.TZ_GetTime(v2.ApiStartTime, DEFAULT, @uid), dbo.TZ_GetTime(i.EventDateTime, DEFAULT, @uid))
				END AS EventDateTime,
			i.LastOperation,
			c.Serial,
			
			i.ApiEventId,
			i.ApiMetadataId,
			dbo.TZ_GetOffsetInHours(@uid, i.EventDateTime) AS OffsetHours,
			
			CASE WHEN v1.IncidentId IS NOT NULL
				THEN v1.ApiVideoId
				ELSE v2.ApiVideoId
				END AS ApiVideoId_1,
			CASE WHEN v1.IncidentId IS NOT NULL
				THEN MAX(v1.ApiFileName) 
				ELSE MAX(v2.ApiFileName)
				END AS ApiFileName_1,
			CASE WHEN v1.IncidentId IS NOT NULL
				THEN dbo.TZ_GetTime(v1.ApiStartTime, DEFAULT, @uid)
				ELSE dbo.TZ_GetTime(v2.ApiStartTime, DEFAULT, @uid)
				END AS ApiStartTime_1,
			CASE WHEN v1.IncidentId IS NOT NULL
				THEN dbo.TZ_GetTime(v1.ApiEndTime, DEFAULT, @uid)
				ELSE dbo.TZ_GetTime(v2.ApiEndTime, DEFAULT, @uid)
				END AS ApiEndTime_1,
			CASE WHEN v1.IncidentId IS NOT NULL
				THEN dbo.GetLatestVideoStatusByIncidentId(v1.IncidentId, 1)
				ELSE dbo.GetLatestVideoStatusByIncidentId(v2.IncidentId, 2)
				END AS VideoStatus_1,


			CASE WHEN v1.IncidentId IS NULL
				THEN NULL
				ELSE v2.ApiVideoId 
				END AS ApiVideoId_2,

			CASE WHEN v1.IncidentId IS NULL
				THEN NULL
				ELSE MAX(v2.ApiFileName) 
				END AS ApiFileName_2,

			CASE WHEN v1.IncidentId IS NULL
				THEN NULL
				ELSE dbo.TZ_GetTime(v2.ApiStartTime, DEFAULT, @uid)
				END AS ApiStartTime_2,

			CASE WHEN v1.IncidentId IS NULL
				THEN NULL
				ELSE dbo.TZ_GetTime(v2.ApiEndTime, DEFAULT, @uid)
				END AS ApiEndTime_2,

			CASE WHEN v1.IncidentId IS NULL
				THEN NULL
				ELSE dbo.GetLatestVideoStatusByIncidentId(v2.IncidentId, 2)
				END AS VideoStatus_2,
			
			p.ApiUrl,
			p.ApiUser,
			p.ApiPassword,
			p.BucketName,

			CASE WHEN v1.IncidentId IS NOT NULL
				THEN 1
				ELSE 2
				END AS CameraNumber,
			CASE WHEN i.CoachingStatusId IN (2,4,97) THEN
				CASE WHEN DATEDIFF(HOUR, i.EventDateTime, GETDATE()) > @expirycoach THEN 'Unavailable' ELSE CASE WHEN MAX(v1.ApiFileName) = MAX(v1.ApiEventId) THEN 'S3' ELSE CASE WHEN DATEDIFF(HOUR, i.EventDateTime, GETDATE()) <= 1440 THEN 'TrajetAndRTL' ELSE 'RTL' END END END 	
			ELSE	
				CASE WHEN DATEDIFF(HOUR, i.EventDateTime, GETDATE()) > @expirynoncoach THEN 'Unavailable' ELSE CASE WHEN MAX(v1.ApiFileName) = MAX(v1.ApiEventId) THEN 'S3' ELSE CASE WHEN DATEDIFF(HOUR, i.EventDateTime, GETDATE()) <= 1440 THEN 'Trajet' ELSE 'Unavailable' END END END 	
			END	AS VideoAvailability

	FROM dbo.CAM_Incident i
		INNER JOIN dbo.Event e ON i.EventId = e.EventId
		INNER JOIN dbo.Driver d ON i.DriverIntId = d.DriverIntId
		INNER JOIN dbo.Vehicle v ON i.VehicleIntId = v.VehicleIntId
		INNER JOIN dbo.Customer cust ON i.CustomerIntId = cust.CustomerIntId
		INNER JOIN dbo.Camera c ON c.CameraIntId = i.CameraIntId
		INNER JOIN dbo.Project p ON c.ProjectId = p.ProjectId
		
		LEFT OUTER JOIN dbo.CAM_Video v1 ON i.IncidentId = v1.IncidentId AND v1.CameraNumber = 1 AND v1.ApiVideoId IS NOT NULL
		LEFT OUTER JOIN dbo.CAM_Video v2 ON i.IncidentId = v2.IncidentId AND v2.CameraNumber = 2 AND v2.ApiVideoId IS NOT NULL
	
	WHERE v.VehicleId = @vid
		AND i.CreationCodeId = 459
		AND i.Archived = 0
	GROUP BY i.IncidentId, v.VehicleId, v.Registration, i.CreationCodeId, i.Long, i.Lat, i.Heading, i.LastOperation,i.CoachingStatusId, c.Serial,
		i.ApiEventId, i.ApiMetadataId, i.EventDateTime,
		v1.ApiVideoId, v1.ApiStartTime, v1.ApiEndTime, v1.IncidentId,
		v2.ApiVideoId, v2.ApiStartTime, v2.ApiEndTime, v2.IncidentId,
		p.ApiUrl, p.ApiUser, p.ApiPassword,p.BucketName
	ORDER BY i.IncidentId DESC

GO
