SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_MSG_GetOwnerChatrooms](@uid UNIQUEIDENTIFIER)
AS
					
	--DECLARE @uid UNIQUEIDENTIFIER
	--SET @uid = N'28b094cd-fd99-4a89-9e7d-addf0cd0e090'

	SELECT	c.ChatroomId, 
			ISNULL(cp.LastRequestedId,0) AS LastUpdateId, 
			dbo.GetDriverOrUserNameByUid(c.OwnerId) AS OwnerName,
			c.OwnerId
	FROM dbo.MSG_Chatroom c
		INNER JOIN dbo.MSG_ChatroomParticipant cp ON cp.ChatroomId = c.ChatroomId AND cp.ParticipantId = @uid
		LEFT JOIN dbo.[User] u ON c.OwnerId = u.UserID
		LEFT JOIN dbo.Driver d ON c.OwnerId = d.DriverId
	WHERE c.OwnerId = @uid






GO
