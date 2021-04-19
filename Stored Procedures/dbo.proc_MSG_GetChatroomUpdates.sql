SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_MSG_GetChatroomUpdates](@cid INT, @lastid INT, @uid UNIQUEIDENTIFIER)
AS

	--DECLARE @cid INT, @lastid INT, @uid UNIQUEIDENTIFIER
	--SET @cid = 3
	--SET @lastid = 0
	--SET @uid = N'32373B20-EE88-4153-94A9-1DB4A12739C9'

	DECLARE @maxid INT
	SELECT @maxid = MAX(cpm.LastUpdateId)
	FROM dbo.MSG_ChatroomParticipantMessage cpm
		INNER JOIN dbo.MSG_ChatroomParticipant cp ON cp.ChatroomParticipantId = cpm.ChatroomParticipantId
	WHERE cp.ChatroomId = @cid

	UPDATE dbo.MSG_ChatroomParticipant
	SET LastRequestedId = @maxid
	WHERE ChatroomId = @cid
	  AND ParticipantId = @uid

	SELECT	cp.ChatroomId, 
			m.MessageId, 
			cp.ParticipantId, 
			dbo.GetDriverOrUserNameByUid(cp.ParticipantId) AS ParticipantName, 
			m.Messagetext, 
			CASE WHEN m.MessageOwner = cp.ParticipantId THEN m.TimeSent ELSE NULL END AS TimeSent, 
			cpm.TimeReceived,
			cpm.TimeRead,
			CASE WHEN cp.ParticipantId = @uid THEN cp.LastRequestedId ELSE NULL END AS LastUpdateId
	FROM dbo.MSG_ChatroomParticipantMessage cpm
		INNER JOIN dbo.MSG_Message m ON m.MessageId = cpm.MessageId
		INNER JOIN dbo.MSG_ChatroomParticipant cp ON cp.ChatroomParticipantId = cpm.ChatroomParticipantId
		LEFT JOIN dbo.[User] u ON cp.ParticipantId = u.UserID
		LEFT JOIN dbo.Driver d ON cp.ParticipantId = d.DriverId
	WHERE cp.ChatroomId = @cid
	  AND m.Archived = 0
	  AND cpm.LastUpdateId > @lastid

GO
