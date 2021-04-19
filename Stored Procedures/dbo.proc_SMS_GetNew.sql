SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_SMS_GetNew]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SMSId ,
           SMSSourceId ,
           SMSStatusId ,
           TelephoneNumber ,
		   SenderId ,
           SMSMessage ,
		   SMSExternalid ,
           TimeInitiated ,
           TimeCompleted ,
           LastOperation ,
           Archived
	FROM dbo.SMS
	WHERE Archived = 0
		AND SMSStatusId IN (0)
END


GO
