SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cu_User_Logout]
(
	@userId uniqueidentifier
)
AS
BEGIN
	UPDATE [dbo].[UserSession]
	SET [IsLoggedIn] = 0
	WHERE [UserId] = @userId
END

GO
