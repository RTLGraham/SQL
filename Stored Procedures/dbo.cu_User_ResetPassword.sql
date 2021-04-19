SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cu_User_ResetPassword]
(
	@currentUserId UNIQUEIDENTIFIER,
	@userId UNIQUEIDENTIFIER,
	@password varchar(50)
)
AS

	--DECLARE	@currentUserId UNIQUEIDENTIFIER,
	--		@userId UNIQUEIDENTIFIER,
	--		@password varchar(50)
	--SELECT	@currentUserId = N'94748A81-CE8F-4694-B45C-AE216BCE4CBF',
	--		@userId = N'4F1B2A41-022B-434B-845D-8229C4D98D87',
	--		@password = 'pass'
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
	WHERE u.UserID = @userId
		and uCurr.UserID = @currentUserId

	IF @count > 0
	BEGIN -- User exists so return the details
		UPDATE dbo.[User]
		SET PasswordHash = HASHBYTES('SHA2_512', 'hash'+CAST([Name] as VARCHAR(512))+'salt'+CAST(@password as VARCHAR(50))+'pepper')
		WHERE UserId = @userId
	END	

GO
