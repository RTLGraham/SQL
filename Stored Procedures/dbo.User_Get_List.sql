SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[User_Get_List]

AS


				
				SELECT
					[UserID],
					[Name],
					[Password],
					[Archived],
					[Email],
					[Location],
					[FirstName],
					[Surname],
					[CustomerID],
					[ExpiryDate]
				FROM
					[dbo].[User]
                WHERE Archived = 0

				SELECT @@ROWCOUNT

GO
