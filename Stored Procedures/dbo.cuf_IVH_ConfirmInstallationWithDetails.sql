SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_IVH_ConfirmInstallationWithDetails]
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
	@Registration NVARCHAR(MAX) = NULL,
	@MakeModel NVARCHAR(100) = NULL,
	@BodyManufacturer NVARCHAR(50) = NULL,
	@BodyType NVARCHAR(50) = NULL,
	@ChassisNumber NVARCHAR(50) = NULL,
	@Odometer FLOAT = NULL,
	@Comment NVARCHAR(MAX) = NULL,

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
	@pulsConfigGroup NVARCHAR(250) = NULL,

	@jobType INT = 1,
	@jobReference NVARCHAR(250) = NULL
)
AS
	--DECLARE @diagid INT
	--SET @diagid = 1 

	
	DECLARE @present_Registration NVARCHAR(MAX),
			@present_Customer NVARCHAR(MAX),
			@present_Groups NVARCHAR(MAX),
			@present_Tracker NVARCHAR(MAX),
			@engineer NVARCHAR(MAX)

	SELECT TOP 1
		@present_Registration = ISNULL(d.Registration, 'n/a'),
		@present_Customer = ISNULL(d.CustomerName, 'n/a'),
		@present_Groups = ISNULL(d.VehicleGroups, 'n/a'),
		@engineer = u.Name + ' (Name: ' + ISNULL(u.FirstName, '') + '; Surname: ' + ISNULL(u.Surname, '') + ')',
		@present_Tracker = ISNULL(d.TrackerNumber, 'n/a')
	FROM dbo.Diagnostics d
		INNER JOIN dbo.[User] u ON u.UserID = d.UserId
	WHERE d.DiagnosticsId = @diagid

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
		Registration = ISNULL(@Registration, Registration),
		MakeModel = ISNULL(@MakeModel, MakeModel),
		BodyManufacturer = ISNULL(@BodyManufacturer, BodyManufacturer),
		BodyType = ISNULL(@BodyType, BodyType),
		ChassisNumber = ISNULL(@ChassisNumber, ChassisNumber),
		Odometer = ISNULL(@Odometer, Odometer),
		Comment = @Comment,

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
		PulsConfigGroup = @pulsConfigGroup,

		JobType = @jobType,
		JobReference = @jobReference
	WHERE DiagnosticsId = @diagid

	IF DB_NAME() = 'UK_Roadsense_Data' -- Outside Clinic Correction -- GKP: code amended so no longer does conversion to KM as data is already provided in KM
	BEGIN	
	IF ISNULL(@Odometer, 0) > 0
		BEGIN	
			MERGE dbo.VehicleLatestOdometer AS target
			USING (SELECT VehicleId, CAST(@odometer AS INT) AS Odo FROM Vehicle WHERE Registration = @Registration) AS source	
			ON (target.VehicleId = source.VehicleId)
			WHEN MATCHED THEN
				UPDATE SET OdoGPS = source.Odo
			WHEN NOT MATCHED THEN	
				INSERT (VehicleId, OdoGPS, EventDateTime, LastOperation, Archived)
				VALUES (source.VehicleId, source.Odo, GETUTCDATE(), GETDATE(), 0);
			
			-- If an Odometer Offset is present remove it as it will no longer apply
			DELETE
            FROM dbo.VehicleOdoOffset
			FROM dbo.VehicleOdoOffset voo
			INNER JOIN dbo.Vehicle v ON v.VehicleIntId = voo.VehicleIntId
			WHERE v.Registration = @Registration
			  AND v.Archived = 0
		END	
	END	


GO
