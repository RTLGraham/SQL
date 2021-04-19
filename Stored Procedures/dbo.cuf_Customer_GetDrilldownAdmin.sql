SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Customer_GetDrilldownAdmin]
(
	@cid UNIQUEIDENTIFIER
)
AS
	
	SELECT TOP 1 u.UserID, u.Name, u.Password
	FROM dbo.[User] u
		INNER JOIN dbo.UserPreference up ON up.UserID = u.UserID
	WHERE u.CustomerID = @cid AND u.Archived = 0 AND (u.ExpiryDate IS NULL OR u.ExpiryDate >= GETDATE())
		AND up.NameID = 1129 AND up.Value = 1 AND up.Archived = 0
	ORDER BY u.Name


GO
