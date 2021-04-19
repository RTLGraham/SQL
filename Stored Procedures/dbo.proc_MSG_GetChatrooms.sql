SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_MSG_GetChatrooms](@uid UNIQUEIDENTIFIER)
AS
	
	--DECLARE @uid UNIQUEIDENTIFIER
	--SET @uid = N'0B9C8586-FB6B-464D-B135-5329F47E5BA2'

	SELECT	DISTINCT c.ChatroomId,
			0 AS LastRequestedId,
			dbo.GetDriverOrUserNameByUid(c.OwnerId) AS OwnerName,
			c.OwnerId
	FROM dbo.[User] u
	INNER JOIN dbo.UserGroup ug ON ug.UserId = u.UserID
	INNER JOIN dbo.GroupDetail gd ON gd.GroupId = ug.GroupId
	INNER JOIN dbo.Driver d ON gd.EntityDataId = d.DriverId
	INNER JOIN dbo.MSG_Chatroom c ON c.OwnerId = d.DriverId
	WHERE u.UserID = @uid
	  AND ug.Archived = 0
	  AND gd.GroupTypeId = 2
	  AND d.Archived = 0
	  AND c.Archived = 0

GO
