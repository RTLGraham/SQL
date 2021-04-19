SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[proc_UserMobileNotificationsVideo_DeleteBadToken]
(
	@token NVARCHAR(100)
)
AS

	UPDATE dbo.UserMobileToken
	SET Archived = 1
	WHERE MobileToken = @token

GO
