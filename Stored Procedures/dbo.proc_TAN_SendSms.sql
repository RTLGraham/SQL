SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[proc_TAN_SendSms]
	@aRecipient [NVARCHAR](4000),
	@aSubject [NVARCHAR](4000),
	@aBodyText [NVARCHAR](4000)
AS
BEGIN
	IF @aRecipient IS NOT NULL	
		INSERT INTO dbo.SMS (SMSSourceId, SMSStatusId, TelephoneNumber, SenderId, SMSMessage, ExternalIntId, SMSExternalid, TimeInitiated, TimeCompleted, LastOperation, Archived)
		VALUES  (0, 0, @aRecipient, NULL,  @aBodyText, NULL, NULL, GETUTCDATE(), NULL, GETDATE(), 0)
END	

GO
