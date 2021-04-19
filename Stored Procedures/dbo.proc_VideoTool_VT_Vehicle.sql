SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_VideoTool_VT_Vehicle]
    (
      @vids NVARCHAR(MAX),
      @status VARCHAR(MAX),
      @uid UNIQUEIDENTIFIER,
      @sdate DATETIME,
      @edate DATETIME
    )
AS 
	--DECLARE	@sdate DATETIME,
	--		@edate DATETIME,
	--		@uid UNIQUEIDENTIFIER,
	--		@vids NVARCHAR(MAX),
	--		@status VARCHAR(MAX)
			
	--SET @sdate = '2016-11-11 00:00:00'
	--SET @edate = '2016-11-11 23:59:59'
	--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
	--SET @vids = N'DFB2454E-1286-473B-9215-A38D8717CE57'
	--SET @status = NULL


    SET @sdate = [dbo].TZ_ToUTC(@sdate, DEFAULT, @uid)
    SET @edate = [dbo].TZ_ToUTC(@edate, DEFAULT, @uid)

	DECLARE @maxDiam FLOAT
	SELECT @maxDiam = dbo.GetUserGeoMaxDiam(@uid)
	
	DECLARE @speedmult FLOAT
	SET @speedmult = cast([dbo].[UserPref](@uid, 208) as float)
	
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
			i.Heading,
			CAST(i.Speed * @speedmult AS SMALLINT) AS Speed,
			dbo.TZ_GetTime(i.EventDateTime, DEFAULT, @uid) AS EventDateTime,
			i.CustomerIntId,
			i.EventId,
			i.CoachingStatusId,
			c.Serial,
			
			i.ApiEventId,
			vid.ApiVideoURL,
			i.ApiMetadataId,
			dbo.TZ_GetOffsetInHours(@uid, i.EventDateTime) AS OffsetHours,

			vid.RequestId,
			dbo.TZ_GetTime(vid.ApiStartTime, DEFAULT, @uid) AS ApiStartTime,
			dbo.TZ_GetTime(vid.ApiEndTime, DEFAULT, @uid) AS ApiEndTime,
			
			i.MaxX, i.MaxY, i.MinX, i.MinY,
			IsEscalated

	FROM dbo.VT_CAM_Incident i
		INNER JOIN dbo.Driver d ON i.DriverIntId = d.DriverIntId
		INNER JOIN dbo.Vehicle v ON i.VehicleIntId = v.VehicleIntId
		INNER JOIN dbo.Customer cust ON i.CustomerIntId = cust.CustomerIntId
		INNER JOIN dbo.VehicleCamera vc ON v.VehicleId = vc.VehicleId
		INNER JOIN dbo.Camera c ON vc.CameraId = c.CameraId
		INNER JOIN dbo.VT_CAM_Video vid ON vid.IncidentId = i.IncidentId
	WHERE v.VehicleId IN (SELECT VALUE FROM dbo.Split(@vids, ','))
		AND i.EventDateTime BETWEEN @sdate AND @edate
		AND i.Archived = 0
		AND c.Archived = 0
		AND vc.Archived = 0
		AND i.CreationCodeId IN (55, 455, 456, 436, 437, 438, 459)
		AND vid.VideoStatusId = 3 /* only complete videos */
	ORDER BY i.EventDateTime DESC
	    
	--END


GO
