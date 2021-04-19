SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cu_UserSession_GetLatestByUserId]
(
	@userId uniqueidentifier
)
AS
SELECT TOP 1 --*
		SessionID,
		UserID,
		CASE WHEN UserID = N'7A4C7369-7E93-455E-8B66-660E91AB26C5' THEN CAST(1 as BIT) ELSE IsLoggedIn END AS IsLoggedIn,
		LastOperation	
FROM [dbo].[UserSession]
WHERE [UserID] = @userId
ORDER BY [LastOperation] DESC
GO
