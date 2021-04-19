SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cu_UserPreference_AddCustomLogos]
(
	@userNames VARCHAR(MAX),
	@logoUri VARCHar(MAX),
	@watermark VARCHAR(MAX)
)
AS

DECLARE @uid UNIQUEIDENTIFIER,
		@count INT

/* Samples:
		/RTLTwo;Component/Resources/Images/CustomLogo/Total.jpg		| Powered by RTL
		/RTLTwo;Component/Resources/Images/CustomLogo/RTL.jpg		| Powered by RTL
*/

DECLARE @userTab TABLE (UserId UNIQUEIDENTIFIER, UserName VARCHAR(100))

INSERT INTO @userTab ( UserName )
	SELECT VALUE FROM dbo.Split(@userNames, ',')

UPDATE @userTab
SET UserId = (SELECT UserId FROM dbo.[User] WHERE Name = UserName AND archived = 0)

DECLARE user_cur CURSOR FAST_FORWARD FOR
	SELECT UserId FROM @userTab
BEGIN TRANSACTION
	OPEN user_cur
	FETCH NEXT FROM user_cur INTO @uid
	WHILE @@fetch_status = 0
	BEGIN
		SELECT @count = COUNT(*) FROM dbo.UserPreference WHERE UserID = @uid AND NameID IN (308, 309)
		IF @logoUri != '' AND @watermark != ''
		BEGIN
			IF @count = 0
			BEGIN
				--Insert
				INSERT INTO dbo.UserPreference (UserID, NameID, Value, Archived)
				VALUES  ( @uid, 308, @logoUri, 0)
				INSERT INTO dbo.UserPreference (UserID, NameID, Value, Archived)
				VALUES  ( @uid, 309, @watermark, 0)
			END
			ELSE BEGIN
				--Update
				UPDATE dbo.UserPreference SET Value = @logoUri, Archived = 0 WHERE UserID = @uid AND NameID = 308
				UPDATE dbo.UserPreference SET Value = @watermark, Archived = 0 WHERE UserID = @uid AND NameID = 309
			END
		END
		IF @logoUri = '' AND @watermark = '' AND @count != 0
		BEGIN
			UPDATE dbo.UserPreference SET Archived = 1 WHERE UserID = @uid AND NameID = 308
			UPDATE dbo.UserPreference SET Archived = 1 WHERE UserID = @uid AND NameID = 309
		END 
		FETCH NEXT FROM user_cur INTO @uid
	END
	CLOSE user_cur
	DEALLOCATE user_cur
--COMMIT
--ROLLBACK

GO
