SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_MSG_MarkMessageReceived](@msglist NVARCHAR(MAX), @uid UNIQUEIDENTIFIER)
AS
	
	--DECLARE	@msglist NVARCHAR(MAX),
	--		@uid UNIQUEIDENTIFIER
	--SET @msglist = '5,6'
	--SET @uid = N'EA58EB23-1A08-4FD7-9D4F-3D5154AAC3F0'

	DECLARE @maxid INT
	SELECT @maxid = MAX(cpm.LastUpdateId)
	FROM dbo.MSG_ChatroomParticipantMessage cpm
	WHERE cpm.MessageId IN (SELECT value FROM dbo.Split(@msglist, ','))

	UPDATE dbo.MSG_ChatroomParticipantMessage
	SET TimeReceived = GETUTCDATE(), LastUpdateId = @maxid + 1
	FROM dbo.MSG_ChatroomParticipantMessage cpm
		INNER JOIN dbo.MSG_ChatroomParticipant cp ON cp.ChatroomParticipantId = cpm.ChatroomParticipantId
	WHERE cpm.MessageId IN (SELECT value FROM dbo.Split(@msglist, ','))
	  AND cp.ParticipantId = @uid
	  


	
					

GO
