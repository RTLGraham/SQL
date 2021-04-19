SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cu_UserSession_Renew]
(
	@sessionID uniqueidentifier
)
AS
	UPDATE [dbo].[UserSession]
	SET [LastOperation] = GetDate()
	WHERE [SessionID] = @sessionID AND [IsLoggedIn] = 1

GO
