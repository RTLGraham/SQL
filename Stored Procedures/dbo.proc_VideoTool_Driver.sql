SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_VideoTool_Driver]
    (
      @dids NVARCHAR(MAX),
      @status VARCHAR(MAX),
      @uid UNIQUEIDENTIFIER,
      @sdate DATETIME,
      @edate DATETIME
    )
AS 

	--DECLARE	@sdate DATETIME,
	--		@edate DATETIME,
	--		@uid UNIQUEIDENTIFIER,
	--		@dids NVARCHAR(MAX),
	--		@status VARCHAR(MAX)
			
	--SET @sdate = '2020-08-11 00:00'
	--SET @edate = '2020-08-11 23:59'
	--SET @uid = N'988D25DE-65E9-4FC5-8981-3D2B4EA0FEAB'
	--SET @dids = N'2859C9F7-578E-48D4-AC86-5B503B9113A7,BEBE0242-E71F-44B7-BA82-C6DCA03086DD,BB1E1CDA-3965-4D7B-8B16-D30AB2E833A8,BB1E1CDA-3965-4D7B-8B16-D30AB2E833A8,BB1E1CDA-3965-4D7B-8B16-D30AB2E833A8'
	--SET @status = '0,1,98'

    SET @sdate = [dbo].TZ_ToUTC(@sdate, DEFAULT, @uid)
    SET @edate = [dbo].TZ_ToUTC(@edate, DEFAULT, @uid)

	DECLARE @maxDiam FLOAT
	SELECT @maxDiam = dbo.GetUserGeoMaxDiam(@uid)
	
	DECLARE @speedmult FLOAT
	SET @speedmult = cast([dbo].[UserPref](@uid, 208) as float)

	DECLARE @expirycoach INT, @expirynoncoach INT
	SELECT @expirycoach = CAST(ISNULL(dbo.CustomerPref(CustomerID, 3009), 8760) AS INT), @expirynoncoach = CAST(ISNULL(dbo.CustomerPref(CustomerID, 3010), 1440) AS INT)
	FROM dbo.[User]
	WHERE UserID = @uid

		--Create a temporary list for the geofence that only belongs to specified customer. To prevent duplicates in the main select.
	DECLARE @geofence TABLE 
	(
		GeofenceId UNIQUEIDENTIFIER,
		Name VARCHAR(MAX),
		the_geom GEOMETRY,
		IsVideoProhibited BIT
	)

	INSERT INTO @geofence
	(
	    GeofenceId,
	    Name,
	    the_geom,
	    IsVideoProhibited
	)
	SELECT geo.GeofenceId,geo.Name,geo.the_geom,geo.IsVideoProhibited
	FROM dbo.Geofence geo
	INNER JOIN dbo.[User] u ON geo.CreationUserId = u.UserID
	INNER JOIN dbo.Customer c ON c.CustomerId = u.CustomerID
	INNER JOIN dbo.[User] cu ON cu.CustomerID = u.CustomerID
	WHERE cu.UserId = @uid
	AND geo.Archived = 0

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
			[dbo].[GetGeofenceNameFromLongLat_Ltd] (i.Lat, i.Long, @uid, [dbo].[GetAddressFromLongLat](i.Lat, i.Long), @maxDiam) AS ReverseGeoCode,
			i.Heading,
			CAST(i.Speed * @speedmult AS SMALLINT) AS Speed,
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
		INNER JOIN dbo.Customer cust ON i.CustomerIntId = cust.CustomerIntId
		INNER JOIN dbo.Camera c ON c.CameraIntId = i.CameraIntId
		INNER JOIN dbo.Project p ON c.ProjectId = p.ProjectId
		INNER JOIN dbo.CAM_Video v1 ON i.IncidentId = v1.IncidentId AND v1.CameraNumber = 1 AND v1.VideoStatus = 1
		LEFT OUTER JOIN dbo.CAM_Video v2 ON i.IncidentId = v2.IncidentId AND v2.CameraNumber = 2 AND v2.VideoStatus = 1
		LEFT JOIN @geofence geo ON geometry::Point(i.Long,i.Lat, 4326).STWithin(geo.the_geom) = 1 
	WHERE d.DriverId IN (SELECT VALUE FROM dbo.Split(@dids, ','))
		AND i.CoachingStatusId IN (SELECT CAST(VALUE AS SMALLINT) FROM dbo.Split(@status, ','))
		AND i.EventDateTime BETWEEN @sdate AND @edate
		AND i.Archived = 0
		AND i.CreationCodeId IN 
							(
							0, /* Harsh unknown */
							55,	/* Button */
							-- 455, 	/* ROP Stage 1 */
							456, 	/* ROP Stage 2 */
							436, 	/* Harsh Decel High */
							437, 	/* Harsh Accel High */
							438)	/* Harsh Corner High */
	AND (geo.IsVideoProhibited IS NULL OR geo.IsVideoProhibited = 0)
	GROUP BY i.IncidentId, i.VehicleIntId, i.DriverIntId, v.VehicleId, v.Registration, v.VehicleTypeID, d.DriverId,
		i.CreationCodeId, i.Long, i.Lat, i.Heading, i.Speed, e.OdoGPS, e.OdoRoadSpeed, e.OdoDashboard, i.EventDateTime, e.DigitalIO,
		e.SpeedLimit, i.LastOperation, i.Archived, i.CustomerIntId, i.EventId, i.CoachingStatusId, c.Serial, i.ApiEventId, i.ApiMetadataId,
		v1.ApiStartTime, v1.ApiEndTime, v1.ApiVideoId, v2.ApiVideoId, v2.ApiStartTime, v2.ApiEndTime, p.ApiUrl, p.ApiUser, p.ApiPassword,p.BucketName,
		i.MaxX, i.MaxY, i.MinX, i.MinY
	ORDER BY i.EventDateTime DESC


GO
