SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Graham Pattison>
-- Create date: <05/03/2018>
-- Description:	<Used by RTL.DataDispatcher to update SMS send results>
-- =============================================
CREATE PROCEDURE [dbo].[proc_SMS_UpdateSMS]
	@SMSId INT,
	@SMSExternalId VARCHAR(200) = NULL,
	@statusId INT,
	@initiated DATETIME,
	@completed DATETIME = NULL
AS
BEGIN
	SET NOCOUNT OFF;

	DECLARE @SMSSourceId INT,
			@ExternalIntId INT,
			@telephoneNumber VARCHAR(50),
			@SMSResult VARCHAR(255),
			@SMSMessage VARCHAR(1000)

	UPDATE dbo.SMS
	SET SMSExternalid = @SMSExternalId,
		SMSStatusId = @statusId,
        TimeInitiated = @initiated,
        TimeCompleted = @completed,
		LastOperation = GETDATE()
	WHERE SMSId = @SMSId

	SELECT @SMSSourceId = sms.SMSSourceId, @ExternalIntId = sms.ExternalIntId, @telephoneNumber = sms.TelephoneNumber, @SMSMessage = sms.SMSMessage, @SMSResult = ss.Description
	FROM dbo.SMS sms
	INNER JOIN dbo.SMSStatus ss ON ss.SMSStatusId = sms.SMSStatusId
	WHERE sms.SMSId = @SMSId

	---- Next section is the retry policy. If the status reports Busy or NoAnswer retry up to a maximum 3 times -- Implement this code by updating the VOIP code below to work for SMS, if required
	--IF @statusId IN (6,8) AND @attempts < 3
	--	INSERT INTO dbo.VOIP_Call (CallSourceId, CallStatusId, TelephoneNumber, PlaybackMessage, ExternalIntId, CallAttempts, LastOperation, Archived)
	--	VALUES (@SMSSourceId,
	--			0,
	--			@telephoneNumber,
	--			@PlaybackMessage,
	--			@ExternalIntId,
	--			@attempts,
	--			GETDATE(),
	--			0)

	-- Handle updates to the DeliveryNotification table
	IF @SMSSourceId = 1 AND @statusId IN (2) -- Delivery Notication and call complete - so update DeliveryNotification table
		UPDATE dbo.DeliveryNotification
		SET TimeNotificationInitiated = @initiated,
			TelephoneNumber = @telephoneNumber,
			TimeCallEnded = @completed,
			CallResult = @SMSResult
		WHERE NotificationID = @ExternalIntId
END




GO
