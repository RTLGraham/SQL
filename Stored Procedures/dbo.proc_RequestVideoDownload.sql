SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_RequestVideoDownload]
(
	@incidentId BIGINT,
	@uid UNIQUEIDENTIFIER = NULL
)
AS
	--DECLARE @incidentId BIGINT,	
	--		@uid UNIQUEIDENTIFIER
	--SET @incidentId = 17410362
	--SET @uid = NULL

	DECLARE @ApiEventId VARCHAR(1024),
			@ApiMetadataId VARCHAR(1024),
			@VideoId BIGINT,
			@ApiVideoId VARCHAR(1024),
			@ApiStartTime DATETIME,
			@ApiEndTime DATETIME,
			
			@IsLoaded BIT,

			@ApiUrl NVARCHAR(MAX),
			@ApiUser NVARCHAR(MAX),
			@ApiPassword NVARCHAR(MAX),

			@RequestDate DATETIME,
			@VideoDispatcher VARCHAR(1024)
			
	/* Process first camera */
	SELECT	TOP 1
			@ApiEventId = i.ApiEventId,
			@ApiMetadataId = i.ApiMetadataId,
			@VideoId = v1.VideoId,
			@ApiVideoId = v1.ApiVideoId,
			@ApiStartTime = v1.ApiStartTime,
			@ApiEndTime = v1.ApiEndTime,
			
			@IsLoaded = v1.IsVideoStoredLocally,
			
			@ApiUrl = p.ApiUrl,
			@ApiUser = p.ApiUser,
			@ApiPassword = p.ApiPassword,

			@RequestDate = GETDATE(),
			@VideoDispatcher = 'RTL.VideoDispatcher' -- For scaleability, populate from Customer table when needed to parallelise the load
	FROM dbo.CAM_Incident i
		INNER JOIN dbo.Vehicle v ON i.VehicleIntId = v.VehicleIntId
		INNER JOIN dbo.VehicleCamera vc ON v.VehicleId = vc.VehicleId
		INNER JOIN dbo.Camera c ON vc.CameraId = c.CameraId
		INNER JOIN dbo.Project p ON c.ProjectId = p.ProjectId
		INNER JOIN dbo.CAM_Video v1 ON i.IncidentId = v1.IncidentId AND v1.CameraNumber = 1 AND v1.VideoStatus = 1
	WHERE i.IncidentId = @incidentId
		AND i.Archived = 0
		AND c.Archived = 0
		AND vc.Archived = 0
	ORDER BY i.EventDateTime DESC

	IF @VideoId IS NULL OR @IsLoaded = 1
	BEGIN
		-- Video is either not present (yet?) or is already downloaded
		RETURN
	END
	
	--File the request
	INSERT INTO dbo.VideoDownloadRequest( IncidentId ,ApiEventId ,ApiMetadataId ,VideoId ,ApiVideoId ,ApiStartTime ,ApiEndTime ,ApiUrl ,ApiUser ,ApiPassword ,RequestDate ,ProcessInd ,VideoDispatcher ,UserId)
	VALUES  ( @incidentId, @ApiEventId, @ApiMetadataId, @VideoId, @ApiVideoId, @ApiStartTime, @ApiEndTime, @ApiUrl, @ApiUser, @ApiPassword, @RequestDate, NULL, @VideoDispatcher, @uid)

	/* Process second camera */
	SELECT @ApiEventId = NULL, @ApiMetadataId = NULL, @VideoId = NULL, @ApiVideoId = NULL, @ApiStartTime = NULL, @ApiEndTime = NULL, @ApiUrl = NULL, @ApiUser = NULL, @ApiPassword = NULL, @RequestDate = NULL, @VideoDispatcher = NULL
	
	SELECT	TOP 1
			@ApiEventId = i.ApiEventId,
			@ApiMetadataId = i.ApiMetadataId,
			@VideoId = v1.VideoId,
			@ApiVideoId = v1.ApiVideoId,
			@ApiStartTime = v1.ApiStartTime,
			@ApiEndTime = v1.ApiEndTime,
			
			@IsLoaded = v1.IsVideoStoredLocally,
			
			@ApiUrl = p.ApiUrl,
			@ApiUser = p.ApiUser,
			@ApiPassword = p.ApiPassword,

			@RequestDate = GETDATE(),
			@VideoDispatcher = 'RTL.VideoDispatcher' -- For scaleability, populate from Customer table when needed to parallelise the load
	FROM dbo.CAM_Incident i
		INNER JOIN dbo.Vehicle v ON i.VehicleIntId = v.VehicleIntId
		INNER JOIN dbo.VehicleCamera vc ON v.VehicleId = vc.VehicleId
		INNER JOIN dbo.Camera c ON vc.CameraId = c.CameraId
		INNER JOIN dbo.Project p ON c.ProjectId = p.ProjectId
		INNER JOIN dbo.CAM_Video v1 ON i.IncidentId = v1.IncidentId AND v1.CameraNumber = 2 AND v1.VideoStatus = 1
	WHERE i.IncidentId = @incidentId
		AND i.Archived = 0
		AND c.Archived = 0
		AND vc.Archived = 0
	ORDER BY i.EventDateTime DESC

	IF @VideoId IS NULL OR @IsLoaded = 1
	BEGIN
		-- Video is either not present (yet?) or is already downloaded
		RETURN
	END
	
	--File the request
	INSERT INTO dbo.VideoDownloadRequest( IncidentId ,ApiEventId ,ApiMetadataId ,VideoId ,ApiVideoId ,ApiStartTime ,ApiEndTime ,ApiUrl ,ApiUser ,ApiPassword ,RequestDate ,ProcessInd ,VideoDispatcher ,UserId)
	VALUES  ( @incidentId, @ApiEventId, @ApiMetadataId, @VideoId, @ApiVideoId, @ApiStartTime, @ApiEndTime, @ApiUrl, @ApiUser, @ApiPassword, @RequestDate, NULL, @VideoDispatcher, @uid)


GO
