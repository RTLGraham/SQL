SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_UserMobileToken_Insert]
(
	@userId UNIQUEIDENTIFIER,
	@mobileToken NVARCHAR(100),
	@deviceId NVARCHAR(100)
)
AS
	DECLARE @prevToken NVARCHAR(100),
			@prevId INT
			
	--Look up the token for this user for this device
	SELECT TOP 1 @prevToken = MobileToken, @prevId = UserMobileTokenId
	FROM dbo.UserMobileToken
	WHERE UserId = @userId and Archived = 0 AND DeviceId = @deviceId
	ORDER BY LastOperation DESC
	
	--Archive previously used token, if it is present and different from the new one
	IF @prevId IS NOT NULL
	BEGIN
		IF @prevToken != @mobileToken
		BEGIN
			UPDATE dbo.UserMobileToken
			SET Archived = 1, LastOperation = GETDATE()
			WHERE UserMobileTokenId = @prevId
			
			INSERT INTO dbo.UserMobileToken(UserId, MobileToken, LastOperation, Archived, DeviceId)
			VALUES (@userId, @mobileToken, GETDATE(), 0, @deviceId)
		END		
	END
	--Add new record - we don't have any tokens for this user
	ELSE
	BEGIN
		INSERT INTO dbo.UserMobileToken(UserId, MobileToken, LastOperation, Archived, DeviceId)
		VALUES (@userId, @mobileToken, GETDATE(), 0, @deviceId)
	END
		
GO
