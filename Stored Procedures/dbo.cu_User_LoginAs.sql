SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[cu_User_LoginAs]
(
	@currentUserId UNIQUEIDENTIFIER,
	@newUserId UNIQUEIDENTIFIER
)
AS

	--DECLARE	@currentUserId UNIQUEIDENTIFIER,
	--		@newUserId UNIQUEIDENTIFIER

	--SET @currentUserId = N'31E48D28-5AA1-4E85-B8D0-E1724EB2948B'
	--SET @newUserId = N'4F1B2A41-022B-434B-845D-8229C4D98D87'

	--/*
	--1. SuperDima & APDixRTLAdmin		94748A81-CE8F-4694-B45C-AE216BCE4CBF	&	9DC6B1B6-C3EF-453F-96D1-32B2D2F16B3B
	--2. APDixRTLAdmin & DebbieHawkes		9DC6B1B6-C3EF-453F-96D1-32B2D2F16B3B	&	4F1B2A41-022B-434B-845D-8229C4D98D87
	--3. AdminCzech & DebbieHawkes		31E48D28-5AA1-4E85-B8D0-E1724EB2948B	&	4F1B2A41-022B-434B-845D-8229C4D98D87
	--*/

	DECLARE @count INT

	SET @count = 0

	SELECT @count = COUNT(*)
	FROM dbo.[User] u
		INNER JOIN dbo.[User] uCurr on u.CustomerID = uCurr.CustomerID OR uCurr.CustomerID IS NULL
	WHERE u.UserID = @newUserId
		and uCurr.UserID = @currentUserId


	IF @count > 0
	BEGIN -- User exists so return the details
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
		WHERE UserID = @newUserId
	END	
	ELSE BEGIN	
		SELECT	[UserId],
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
		WHERE 1 = 2
	END
GO
