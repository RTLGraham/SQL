SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cu_MessageVehicle_SendMessage]
(
	@UserId UNIQUEIDENTIFIER,
	@VehicleId UNIQUEIDENTIFIER,
	@MessageText VARCHAR(1024),
	@ExpiryHours int = null,
	@Lat FLOAT = null,
	@Lon FLOAT = null
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
	VALUES ( @MessageText, @Lat, @Lon)

	SET @MessageId = @@IDENTITY
	
	SET @MessageCommand = '#WRITE,DMSG'

	IF @lat IS NULL OR @lon IS NULL SET @messageType = '1' ELSE SET @messageType = '2'

	SET @MessageCommand =  @MessageCommand + ',' + @messageType + ',' + CAST(@MessageId AS VARCHAR(10)) + ',' +
							CAST(ISNULL(@Lat,0) AS VARCHAR(20)) + ',' + CAST(ISNULL(@Lon,0) AS VARCHAR(20)) + ',' +
							CAST(ISNULL(@ExpiryHours,24) AS VARCHAR(20)) + ',' + '"' + @MessageText + '"'

	SET @expiryDate = DATEADD(hh, ISNULL(@ExpiryHours, 24), GETDATE())
	INSERT INTO dbo.VehicleCommand (IVHId, Command, ExpiryDate, LastOperation, Archived)
	VALUES (@IVHId, CAST(@MessageCommand AS BINARY(1024)), @expiryDate, GETDATE(), 0)

	SET @CommandId = @@IDENTITY
	
	INSERT INTO [dbo].[MessageVehicle] (MessageId, VehicleId, UserId, TimeSent, MessageStatusHardwareId, MessageStatusWetwareId, CommandId )
	VALUES ( @MessageId, @VehicleId, @UserId, GETUTCDATE(), 0, 0, @CommandId )
	COMMIT TRANSACTION
		
	SELECT * FROM dbo.MessageHistory WHERE MessageId = @MessageId

GO
