SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cu_MessageVehicle_ReceiveSMS]
(
	@UserId UNIQUEIDENTIFIER,
	@VehicleId UNIQUEIDENTIFIER,
	@MessageText VARCHAR(1024),
	@ExpiryHours int = null
)
AS

--DECLARE	@UserId UNIQUEIDENTIFIER,
--		@VehicleId UNIQUEIDENTIFIER,
--		@MessageText NVARCHAR(1024),
--		@ExpiryHours int,
--		@Lat FLOAT,
--		@Lon FLOAT

--SET @UserId = N'712DBE7D-3F6B-497B-8BBA-A24F66117479'
--SET @VehicleId = N'CF0BCF73-FD37-4007-90DC-DF9FFBBD2F7A'
--SET @MessageText = 'its down at tynecastle they bide'

	DECLARE @MessageId INT,
			@CommandId INT,
			@MessageCommand VARCHAR(1024),
			@IVHId UNIQUEIDENTIFIER,
			@IVHIntId INT,
			@expiryDate DATETIME,
			@messageType VARCHAR(1)
	
	BEGIN TRANSACTION
	SELECT TOP 1 @IVHId = IVHId FROM dbo.Vehicle WHERE VehicleId = @VehicleId
	
	INSERT INTO [dbo].[MessageHistory] (MessageText, Lat, Long)
	VALUES ( @MessageText, null, null)

	SET @MessageId = @@IDENTITY

	INSERT INTO [dbo].[MessageVehicle] (MessageId, VehicleId, UserId, TimeSent, MessageStatusHardwareId, MessageStatusWetwareId, CommandId )
	VALUES ( @MessageId, @VehicleId, @UserId, GETUTCDATE(), 102, 101, null )
	COMMIT TRANSACTION

	-- Update VLE table(looks very unsafe)

	Update dbo.VehicleLatestEvent
	SET AnalogIoAlertTypeId = 8
	WHERE VehicleId = @VehicleId
		
	SELECT * FROM dbo.MessageHistory WHERE MessageId = @MessageId




GO
