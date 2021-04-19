SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cu_User_GetAllWithPrefs]
(
	@prefId int
)
AS
	SELECT
		u.[UserID],
		u.[Name],
		'' as [Password],
		u.[Email],
		u.[Location],
		u.[FirstName],
		u.[Surname],
		u.[Archived]
	FROM
		[dbo].[User] u
	INNER JOIN [dbo].[UserPreference] up ON u.UserID = up.UserID 
	WHERE u.Archived = 0 AND up.Archived = 0
	AND up.NameID = @prefId

GO
