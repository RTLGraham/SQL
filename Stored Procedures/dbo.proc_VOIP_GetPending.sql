SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_VOIP_GetPending]
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
		AND CallStatusId NOT IN (0,4,5,6,7,8)
END

GO
