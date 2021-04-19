SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_VideoTool_ById]
    (
      @uid UNIQUEIDENTIFIER,
      @incidentId BIGINT
    )
AS 
	--DECLARE	@uid UNIQUEIDENTIFIER,
	--		@incidentId BIGINT
			
	----SET @uid = N'6175F9DA-68C9-4CBA-92F1-B504FD80B6E0' --analyst
	--SET @uid = N'60174CB3-DD3E-466A-B651-06CE0A3E5648' --coach
	----SET @uid = N'CE63ED92-3CA9-46CF-8647-F2ACC6D18A53' --noone
	--SET @incidentId = 62343040

	--/*
 --           var anal = new List<int> {0, 1, 98}; //1095
 --           var coach = new List<int> { 1, 2, 3, 4, 97, 98 }; //1097
	--*/


	DECLARE @role BIT,
			@status NVARCHAR(MAX)

	--Is Analyst?
	SELECT @role = 0
	FROM dbo.UserPreference
	WHERE UserID = @uid AND NameID = 1095 AND Value = '1' AND Archived = 0
	
	--Is Coach?
	SELECT @role = 1
	FROM dbo.UserPreference
	WHERE UserID = @uid AND NameID = 1097 AND Value = '1' AND Archived = 0
	
	SET @role = ISNULL(@role, 0) --default to analyst
	IF @role = 0
	BEGIN
		SET @status = '0,1,98'
	END
    ELSE BEGIN
		SET @status = '1,2,3,4,97,98'
	END
	
	DECLARE @maxDiam FLOAT
	SELECT @maxDiam = dbo.GetUserGeoMaxDiam(@uid)
	
	DECLARE @speedmult FLOAT
	SET @speedmult = cast([dbo].[UserPref](@uid, 208) as float)

	DECLARE @expirycoach INT, @expirynoncoach INT
	SELECT @expirycoach = CAST(ISNULL(dbo.CustomerPref(CustomerID, 3009), 8760) AS INT), @expirynoncoach = CAST(ISNULL(dbo.CustomerPref(CustomerID, 3010), 1440) AS INT)
	FROM dbo.[User]
	WHERE UserID = @uid

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
			CASE WHEN MAX(os.ObjectShareId) IS NOT NULL THEN 1 ELSE 0 END AS IsEscalated,
			CASE WHEN i.CoachingStatusId IN (2,4,97) THEN
				CASE WHEN DATEDIFF(HOUR, i.EventDateTime, GETDATE()) > @expirycoach THEN 'Unavailable' ELSE CASE WHEN MAX(v1.ApiFileName) = MAX(v1.ApiEventId) THEN 'S3' ELSE CASE WHEN DATEDIFF(HOUR, i.EventDateTime, GETDATE()) <= 1440 THEN 'TrajetAndRTL' ELSE 'RTL' END END END 	
			ELSE	
				CASE WHEN DATEDIFF(HOUR, i.EventDateTime, GETDATE()) > @expirynoncoach THEN 'Unavailable' ELSE CASE WHEN MAX(v1.ApiFileName) = MAX(v1.ApiEventId) THEN 'S3' ELSE CASE WHEN DATEDIFF(HOUR, i.EventDateTime, GETDATE()) <= 1440 THEN 'Trajet' ELSE 'Unavailable' END END END 	
			END	AS VideoAvailability

	FROM dbo.CAM_Incident i
		LEFT OUTER JOIN dbo.ObjectShare os ON i.IncidentId = os.ObjectIntId AND os.ObjectTypeId = 1 AND os.Archived = 0
		LEFT OUTER JOIN dbo.Event e ON i.EventId = e.EventId
		INNER JOIN dbo.Driver d ON i.DriverIntId = d.DriverIntId
		INNER JOIN dbo.Vehicle v ON i.VehicleIntId = v.VehicleIntId
		INNER JOIN dbo.GroupDetail gd ON gd.EntityDataId = v.VehicleId
		INNER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId
		INNER JOIN dbo.UserGroup ug ON ug.GroupId = g.GroupId
		INNER JOIN dbo.Customer cust ON i.CustomerIntId = cust.CustomerIntId
		INNER JOIN dbo.Camera c ON c.CameraIntId = i.CameraIntId
		INNER JOIN dbo.Project p ON c.ProjectId = p.ProjectId
		INNER JOIN dbo.CAM_Video v1 ON i.IncidentId = v1.IncidentId AND v1.CameraNumber = 1 AND v1.VideoStatus = 1
		LEFT OUTER JOIN dbo.CAM_Video v2 ON i.IncidentId = v2.IncidentId AND v2.CameraNumber = 2 AND v2.VideoStatus = 1
	WHERE i.CoachingStatusId IN (SELECT CAST(VALUE AS SMALLINT) FROM dbo.Split(@status, ','))
		AND i.IncidentId = @incidentId
		AND i.Archived = 0
		AND g.IsParameter = 0 AND g.Archived = 0 AND g.GroupTypeId = 1 AND gd.GroupTypeId = 1
		AND ug.UserId = @uid AND ug.Archived = 0
		AND i.CreationCodeId IN (0, 55, 455, 456, 436, 437, 438)
	GROUP BY i.IncidentId, i.VehicleIntId, i.DriverIntId, v.VehicleId, v.Registration, v.VehicleTypeID, d.DriverId,
		i.CreationCodeId, i.Long, i.Lat, i.Heading, i.Speed, e.OdoGPS, e.OdoRoadSpeed, e.OdoDashboard, i.EventDateTime, e.DigitalIO,
		e.SpeedLimit, i.LastOperation, i.Archived, i.CustomerIntId, i.EventId, i.CoachingStatusId, c.Serial, i.ApiEventId, i.ApiMetadataId,
		v1.ApiStartTime, v1.ApiEndTime, v1.ApiVideoId, v2.ApiVideoId, v2.ApiStartTime, v2.ApiEndTime, p.ApiUrl, p.ApiUser, p.ApiPassword,p.BucketName,
		i.MaxX, i.MaxY, i.MinX, i.MinY
	ORDER BY i.EventDateTime DESC




GO
