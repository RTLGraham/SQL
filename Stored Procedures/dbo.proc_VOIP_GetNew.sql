SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_VOIP_GetNew]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT CallId ,
           CallSourceId ,
           CallStatusId ,
           TelephoneNumber ,
           PlaybackMessage ,
           ExternalIntId ,
           ExternalUniqueId ,
           ExternalStringId ,
           CallSid ,
           TimeInitiated ,
           TimeCompleted ,
           CallDuration ,
           CallAttempts ,
           LastOperation ,
           Archived
	FROM dbo.VOIP_Call
	WHERE Archived = 0
		AND CallStatusId IN (0)
END

GO
