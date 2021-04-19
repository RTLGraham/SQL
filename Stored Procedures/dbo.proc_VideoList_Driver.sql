SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_VideoList_Driver]
    (
      @dids NVARCHAR(MAX),
      @types VARCHAR(MAX),
      @uid UNIQUEIDENTIFIER,
      @sdate DATETIME,
      @edate DATETIME
    )
AS 
	--DECLARE	@sdate DATETIME,
	--		@edate DATETIME,
	--		@uid UNIQUEIDENTIFIER,
	--		@vids NVARCHAR(MAX),
	--		@types VARCHAR(MAX)
			
	--SET @sdate = '2015-01-01 00:00:00'
	--SET @edate = '2015-12-09 23:59:59'
	--SET @uid = N'0B9C8586-FB6B-464D-B135-5329F47E5BA2'
	--SET @vids = N'44EE3ACC-70AD-4244-B662-1FAF8A33D140,9D188F07-BB2B-4B45-A8A7-20C58AA9DB7C,279D8F07-0ECC-4B10-B5DC-3DE9E37C1AA9,84C01A41-2921-4B14-9EC4-516E8C4502D8,E1C256BE-6F4C-4184-A16D-679154095205,8584AB9F-B8D2-49E0-99A5-A5100F8D9C48,9F09A9E7-E213-45D9-9743-C010452A3EBD,EA804220-124A-43EF-8EA2-D982CD51DAAA'
	--SET @types = '50,436,437,438,455,456,457,458'
	
	
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
			i.CreationCodeId,
			i.Long,
			i.Lat,
			[dbo].[GetGeofenceNameFromLongLat_Ltd] (i.Lat, i.Long, @uid, [dbo].[GetAddressFromLongLat](i.Lat, i.Long), @maxDiam) AS ReverseGeoCode,
			e.Heading,
			CAST(e.Speed * @speedmult AS SMALLINT) as Speed,
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
			--i.CoachingStatusId,
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
			dbo.GetLatestVideoStatusByIncidentId(v1.IncidentId, 1) AS VideoStatus_1,

			--v2.VideoId AS VideoId_2,
			v2.ApiVideoId AS ApiVideoId_2,
			MAX(v2.ApiFileName) AS ApiFileName_2,
			--v2.ApiStartTime AS ApiStartTime_2,
			--v2.ApiEndTime AS ApiEndTime_2,
			dbo.TZ_GetTime(v2.ApiStartTime, DEFAULT, @uid) AS ApiStartTime_2,
			dbo.TZ_GetTime(v2.ApiEndTime, DEFAULT, @uid) AS ApiEndTime_2,
			dbo.GetLatestVideoStatusByIncidentId(v2.IncidentId, 2) AS VideoStatus_2,
			
			p.ApiUrl,
			p.ApiUser,
			p.ApiPassword,
			p.BucketName,
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
		
		INNER JOIN dbo.CAM_Video v1 ON i.IncidentId = v1.IncidentId AND v1.CameraNumber = 1 AND v1.ApiVideoId IS NOT NULL
		LEFT OUTER JOIN dbo.CAM_Video v2 ON i.IncidentId = v2.IncidentId AND v2.CameraNumber = 2 AND v2.ApiVideoId IS NOT NULL
		LEFT JOIN @geofence geo ON geometry::Point(i.Long,i.Lat, 4326).STWithin(geo.the_geom) = 1 
		--INNER JOIN 
		--(SELECT IncidentId, CameraNumber, ApiStartTime, ApiEndTime, ApiVideoId, ApiFileName, ROW_NUMBER() OVER(PARTITION BY IncidentId ORDER BY LastOperation DESC) AS RowNum
		--FROM dbo.CAM_Video) v1 ON i.IncidentId = v1.IncidentId AND v1.CameraNumber = 1 AND v1.RowNum = 1
			
		--LEFT OUTER JOIN 
		--(SELECT IncidentId, CameraNumber, ApiStartTime, ApiEndTime, ApiVideoId, ApiFileName, ROW_NUMBER() OVER(PARTITION BY IncidentId ORDER BY LastOperation DESC) AS RowNum
		--FROM dbo.CAM_Video) v2 ON i.IncidentId = v2.IncidentId AND v1.CameraNumber = 2 AND v2.RowNum = 1
	
	WHERE d.DriverId IN (SELECT VALUE FROM dbo.Split(@dids, ','))
		AND i.CreationCodeId IN (SELECT VALUE FROM dbo.Split(@types, ','))
		AND i.EventDateTime BETWEEN @sdate AND @edate
		AND i.Archived = 0
		AND (geo.IsVideoProhibited IS NULL OR geo.IsVideoProhibited = 0)
	GROUP BY i.IncidentId, i.VehicleIntId, i.DriverIntId, v.VehicleId, v.Registration, v.VehicleTypeID, d.DriverId,
		i.CreationCodeId, i.Long, i.Lat, e.Heading, e.Speed, e.OdoGPS, e.OdoRoadSpeed, e.OdoDashboard, i.EventDateTime, e.DigitalIO,
		e.SpeedLimit, i.LastOperation, i.Archived, i.CustomerIntId, i.EventId, i.CoachingStatusId, c.Serial, i.ApiEventId, i.ApiMetadataId,
		v1.ApiStartTime, v1.ApiEndTime, v1.ApiVideoId, v2.ApiVideoId, v2.ApiStartTime, v2.ApiEndTime, p.ApiUrl, p.ApiUser, p.ApiPassword,p.BucketName,
		v1.IncidentId, v2.IncidentId
	ORDER BY i.EventDateTime DESC

GO
