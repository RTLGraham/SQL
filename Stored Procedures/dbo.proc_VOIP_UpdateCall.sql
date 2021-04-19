SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Dmitrijs Jurins>
-- Create date: <11/10/2016>
-- Description:	<Used by RTL.DataDispatcher to update VOIP call results>
-- =============================================
CREATE PROCEDURE [dbo].[proc_VOIP_UpdateCall]
	@callId INT,
	@callSid VARCHAR(200) = NULL,
	@statusId INT,
	@initiated DATETIME,
	@completed DATETIME = NULL,
	@duration INT = NULL,
	@attempts INT = NULL,
	@details NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT OFF;

	DECLARE @CallSourceId INT,
			@ExternalIntId INT,
			@telephoneNumber VARCHAR(50),
			@CallResult VARCHAR(255),
			@PlaybackMessage VARCHAR(200)

	UPDATE dbo.VOIP_Call
	SET CallSid = @callSid,
		CallStatusId = @statusId,
        TimeInitiated = @initiated,
        TimeCompleted = @completed,
        CallDuration = @duration,
        CallAttempts = ISNULL(@attempts, CallAttempts),
		Details = @details,
		LastOperation = GETDATE()
	WHERE CallId = @callId

	SELECT @CallSourceId = vc.CallSourceId, @ExternalIntId = vc.ExternalIntId, @telephoneNumber = vc.TelephoneNumber, @PlaybackMessage = vc.PlaybackMessage, @CallResult = vs.Description
	FROM dbo.VOIP_Call vc
	INNER JOIN dbo.VOIP_CallStatus vs ON vs.CallStatusId = vc.CallStatusId
	WHERE vc.CallId = @callId

	-- Next section is the retry policy. If the status reports Busy or NoAnswer retry up to a maximum 3 times
	IF @statusId IN (6,8) AND @attempts < 3
		INSERT INTO dbo.VOIP_Call (CallSourceId, CallStatusId, TelephoneNumber, PlaybackMessage, ExternalIntId, CallAttempts, LastOperation, Archived)
		VALUES (@CallSourceId,
				0,
				@telephoneNumber,
				@PlaybackMessage,
				@ExternalIntId,
				@attempts,
				GETDATE(),
				0)

	-- Handle updates to the DeliveryNotification table
	IF @CallSourceId = 1 AND @statusId IN (4,5,6,7,8) -- Delivery Notication and call complete - so update DeliveryNotification table
		UPDATE dbo.DeliveryNotification
		SET TimeNotificationInitiated = @initiated,
			TelephoneNumber = @telephoneNumber,
			TimeCallEnded = @completed,
			CallDuration = @duration,
			CallAttempts = @attempts,
			CallResult = @CallResult
		WHERE NotificationID = @ExternalIntId
END




GO
