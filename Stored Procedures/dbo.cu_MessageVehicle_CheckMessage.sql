SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cu_MessageVehicle_CheckMessage]
(
	@MessageId INT
)
AS
BEGIN
	DECLARE @count INT,
			@expiry DATETIME,
			@commandId INT,
			@messageCommand NVARCHAR(1024),
			@ivhid UNIQUEIDENTIFIER
	
	SELECT @count = COUNT(*) FROM dbo.MessageVehicle WHERE MessageId = @MessageId
	IF @count = 1
	BEGIN
		SELECT TOP 1 @expiry = ExpiryDate,
					 @ivhid = c.IVHID
		FROM dbo.MessageVehicle m
		INNER JOIN dbo.VehicleCommand c ON m.CommandId = c.CommandId
		WHERE m.MessageId = @MessageId
		ORDER BY c.CommandId DESC

		SET @messageCommand = '#READINFO,DMSG,' + CAST(@messageId AS VARCHAR(50))
		
		BEGIN TRANSACTION
			INSERT INTO dbo.VehicleCommand ( IVHId , Command , ExpiryDate , LastOperation , Archived )
			VALUES  (@ivhid, CAST(@messageCommand AS VARBINARY(1024)), @expiry, GETUTCDATE(), 0)
			SET @commandId = @@IDENTITY
			UPDATE dbo.MessageVehicle SET CommandId = @commandId WHERE MessageId = @messageId
		COMMIT TRANSACTION
	END
END



GO
