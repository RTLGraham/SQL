SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
	
CREATE PROCEDURE [dbo].[cuf_IVH_ConfirmInstallation]
(
	@diagid INT,
	@cameraId UNIQUEIDENTIFIER = NULL,
	@cameraSerial NVARCHAR(100) = NULL, 
	@lastCameraEventDateTime DATETIME = NULL, 
	@cameraState NVARCHAR(100) = NULL, 
    @cameraFirmware NVARCHAR(1024) = NULL, 
	@cameraVideoId NVARCHAR(1024) = NULL, 
	@cameraVideoType NVARCHAR(100) = NULL, 
    @cameraVideoState NVARCHAR(100) = NULL,

	@cameraSIMICCID NVARCHAR(1024)= NULL, 
	@cameraSIMDataUsage FLOAT= NULL, 
	@cameraSIMRatePlan NVARCHAR(1024)= NULL, 
	@cameraSIMStatus NVARCHAR(250) = NULL, 
	@cameraSIMLimitReached BIT = NULL, 
	@cameraSIMLastSession DATETIME = NULL,

	@pulsFirstId DATETIME = NULL,
	@pulsLastId DATETIME = NULL,
	@pulsLastConfigUpdate DATETIME = NULL,
	@pulsConfigStatus NVARCHAR(250) = NULL,
	@pulsConfigGroup NVARCHAR(250) = NULL
)
AS
	--DECLARE @diagid INT
	--SET @diagid = 1 

	UPDATE dbo.Diagnostics
	SET CompletedDateTime = GETUTCDATE(),
		CameraID = @cameraId,
		CameraSerial = @cameraSerial,
		LastCameraEventDateTime = @lastCameraEventDateTime,
		CameraState = @cameraState,
		CameraFirmware = @cameraFirmware,
		CameraVideoId = @cameraVideoId,
		CameraVideoType = @cameraVideoType,
		CameraVideoState = @cameraVideoState,

		CameraSIMICCID = @cameraSIMICCID,
		CameraSIMDataUsage = @cameraSIMDataUsage,
		CameraSIMRatePlan = @cameraSIMRatePlan,
		CameraSIMStatus = @cameraSIMStatus,
		CameraSIMLimitReached = @cameraSIMLimitReached,
		CameraSIMLastSession = @cameraSIMLastSession,

		PulsFirstId = @pulsFirstId,
		PulsLastId = @pulsLastId,
		PulsLastConfigUpdate = @pulsLastConfigUpdate,
		PulsConfigStatus = @pulsConfigStatus,
		PulsConfigGroup = @pulsConfigGroup
	WHERE DiagnosticsId = @diagid

GO
