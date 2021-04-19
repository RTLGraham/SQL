SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cu_User_Login]
(
	@name nvarchar(512),
	@password nvarchar(50)
)
AS

	--DECLARE	@name nvarchar(512),
	--		@password nvarchar(50)

	--SET @name = 'AdminSpain'
	--SET @password = 'Spain12'

	DECLARE @input VARBINARY(64)
	SET @input = HASHBYTES('SHA2_512', 'hash'+CAST(ISNULL(@name,'') as VARCHAR(512))+'salt'+CAST(ISNULL(@password,'') as VARCHAR(50))+'pepper')
	
	DECLARE @count INT,
			@failedCount INT,
			@failedMax INT,
			@failedTimeSeconds INT

	SET @count = 0
	SET @failedMax = 3
	SET @failedTimeSeconds = 600

	SELECT @failedCount = COUNT(*) FROM dbo.UserFailedLogin WHERE [Name] = @name AND LastOperation BETWEEN DATEADD(SECOND, (-1)*@failedTimeSeconds, GETDATE()) AND GETDATE()

	IF @failedCount > @failedMax
	BEGIN
		--User is 'blocked' right now, let's add one more entry to 'extend' the block. Block will release only after the user stopps trying (even with the correct pwd) for @failedTimeSeconds
		INSERT INTO dbo.UserFailedLogin([Name],[Password],LastOperation)
		VALUES (@name, @password, GETDATE())

		RAISERROR ('Failed to login the user',16,1, @name);  
	END
	ELSE BEGIN
		SELECT @count = COUNT(*)
		FROM dbo.[User]
		WHERE Archived = 0
		--AND Name = @name
		--AND Password = @password
		AND PasswordHash = @input
		AND ISNULL(ExpiryDate, '2099-12-31 00:00') > GETUTCDATE()


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
			WHERE Archived = 0
			--AND Name = @name
			--AND Password = @password
			AND PasswordHash = @input
			AND ISNULL(ExpiryDate, '2099-12-31 00:00') > GETUTCDATE()
		END	ELSE	
		BEGIN -- User doesn't exist so try and return a driver login instead	
			SELECT @count = COUNT(*)
			FROM dbo.Driver
			WHERE Archived = 0
			AND 
			(
				(Surname = @name AND (Number = @password OR NumberAlternate = @password OR NumberAlternate2 = @password OR [Password] = @password))
				OR
				(NumberAlternate2 = @name AND Password = @password)
			)

			IF @count > 0
			BEGIN
				SELECT	d.DriverId AS UserId,
						Surname AS Name,
						@password AS [Password],
						d.Archived,
						'support@rtlsystems.co.uk' AS [Email],
						'Mobile' AS [Location],
						d.FirstName,
						d.Surname,
						cd.CustomerId,
						DATEADD(dd,1,GETDATE()) AS ExpiryDate
				FROM dbo.Driver d
				INNER JOIN dbo.CustomerDriver cd ON cd.DriverId = d.DriverId
				WHERE d.Archived = 0
					AND cd.Archived = 0
					AND cd.EndDate IS NULL
					--AND d.Surname = @name
					--AND (d.Number = @password OR d.NumberAlternate = @password OR d.NumberAlternate2 = @password OR d.Password = @password)
					AND	
					(
						(d.Surname = @name AND (d.Number = @password OR d.NumberAlternate = @password OR d.NumberAlternate2 = @password OR d.[Password] = @password))
							OR
						(d.NumberAlternate2 = @name AND d.Password = @password)
					)
			END	ELSE	
			BEGIN 
				-- We have neither a valid user nor a valid driver so return empty user dataset
				INSERT INTO dbo.UserFailedLogin([Name],[Password],LastOperation)
				VALUES (@name, @password, GETDATE())

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
		END	
	END

GO
