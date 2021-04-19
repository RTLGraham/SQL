SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE PROCEDURE [dbo].[cu_MessageVehicle_UpdateMessageStatusWithCode]
(
	@MessageID int,
	@MessageCode varchar(1024)
)
AS
BEGIN
	DECLARE @MessageStatusCode INT

	SELECT @MessageStatusCode = MessageStatusId
	FROM dbo.MessageStatus
	WHERE [Name] = @MessageCode
	
	UPDATE [MessageVehicle] 
	SET MessageStatusHardwareId = @MessageStatusCode,
		LastModified = GETUTCDATE() 
	WHERE MessageID = @MessageID
END







GO
