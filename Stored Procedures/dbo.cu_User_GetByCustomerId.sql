SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cu_User_GetByCustomerId]
(

	@CustomerId uniqueidentifier   
)
AS

				SELECT
					u.[UserID],
					u.[Name],
					'' as [Password],
					u.[Archived],
					u.[Email],
					u.[Location],
					u.[FirstName],
					u.[Surname],
					u.[CustomerID],
					u.[ExpiryDate]
				FROM
					[dbo].[User] u
					LEFT OUTER JOIN dbo.UserPreference up ON u.UserID = up.UserID AND (up.NameID = 1013 AND up.Value = '1')
				WHERE
					u.[CustomerID] = @CustomerId
					AND u.Archived = 0
					AND up.UserPreferenceID IS NULL

GO
