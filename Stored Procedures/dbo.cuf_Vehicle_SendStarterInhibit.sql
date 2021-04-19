SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_Vehicle_SendStarterInhibit]
(
	@vehicleId UNIQUEIDENTIFIER,
	@userId UNIQUEIDENTIFIER,
	@status INT
)
AS
	/*@status: 0 - not inhibited; 1 - inhibited */
	DECLARE @IVHId UNIQUEIDENTIFIER,
			@cmdBit BINARY(1024),
			@cmd VARCHAR(1024),
			@expiryDate DATETIME,
			@cmdId INT,
			@analogIoAlertTypeId INT
	IF @status = 0
		BEGIN
			SET @analogIoAlertTypeId = 20
			SET @cmd = '>STCXAT+ENGI=0'
		END
	ELSE
		BEGIN
			SET @analogIoAlertTypeId = 19
			SET @cmd = '>STCXAT+ENGI=1'
		END
	
	SET @cmdBit = CAST(@cmd AS BINARY(1024))
	SET @expiryDate = DATEADD(DAY, 1, GETDATE())
	SELECT TOP 1 @IVHId = IVHid FROM dbo.Vehicle WHERE VehicleId = @vehicleId ORDER BY LastOperation DESC
	
	INSERT INTO dbo.VehicleCommand
	        ( IVHId ,
	          Command ,
	          ExpiryDate ,
	          AcknowledgedDate ,
	          LastOperation ,
	          Archived
	        )
	VALUES  ( @IVHId , -- IVHId - uniqueidentifier
	          @cmdBit , -- Command - binary
	          @expiryDate , -- ExpiryDate - smalldatetime
	          NULL , -- AcknowledgedDate - smalldatetime
	          GETDATE() , -- LastOperation - smalldatetime
	          0  -- Archived - bit
	        )
	        
	UPDATE dbo.VehicleLatestEvent
	SET AnalogIoAlertTypeId = @analogIoAlertTypeId
	WHERE VehicleId = @vehicleId
	
	SELECT TOP 1 @cmdId = CommandId FROM dbo.VehicleCommand WHERE IVHId = @IVHId ORDER BY LastOperation DESC
	
	INSERT INTO dbo.StarterInhibit
	        ( VehicleId ,
	          Status ,
	          LastOperation ,
	          Archived ,
	          UserId ,
	          CommandId,
	          EventId,
	          Long,
	          Lat
	        )
	VALUES  ( @vehicleId , -- VehicleId - uniqueidentifier
	          @analogIoAlertTypeId , -- Status - int
	          GETDATE() , -- LastOperation - datetime
	          0 , -- Archived - bit
	          @userId , -- UserId - uniqueidentifier
	          @cmdId , -- CommandId - int
	          NULL,
	          NULL,
	          NULL
	        )
	        


GO
