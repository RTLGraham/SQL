SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO





CREATE PROCEDURE [dbo].[cu_User_Login_Save]
(
	@name nvarchar(512),
	@password nvarchar(50)
)
AS
SELECT
	[UserId],
	[Name],
	[Password],
	[Archived],
	[Email],
	[Location],
	[FirstName],
	[Surname],
	[CustomerId],
	[ExpiryDate]
FROM [dbo].[User]
WHERE Archived = 0
AND Name = @name
AND Password = @password
AND ISNULL(ExpiryDate, '2099-12-31 00:00') > GETUTCDATE()

GO
