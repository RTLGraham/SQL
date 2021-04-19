SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[cu_User_LoginIntent]
(
	@cname NVARCHAR(512),
	@dnumber VARCHAR(1024)
)
AS

	--DECLARE @cname NVARCHAR(512),
	--		@dnumber VARCHAR(1024)

	--SELECT  @cname = 'HOYER_UK',
	--		@dnumber = 'DB12247162200701'

	IF LEN(@dnumber) > 14
	BEGIN
		SET @dnumber = LEFT(@dnumber, 14)
	END

	
	--DB12247162200701
	--DECLARE	@name nvarchar(512),
	--		@tenantId nvarchar(50)

	--SET @name = 'HALLG'
	--SET @tenantId = '35d093a2-7c4a-41de-9651-873e0c4ed131'


	DECLARE @count INT
	SET @count = 0

	SELECT @count = COUNT(d.DriverId)
	FROM dbo.Driver d
		INNER JOIN dbo.CustomerDriver cd ON cd.DriverId = d.DriverId
		INNER JOIN dbo.Customer c ON c.CustomerId = cd.CustomerId
	WHERE d.Archived = 0
		AND 
		(
			d.Number = @dnumber OR d.NumberAlternate = @dnumber OR d.NumberAlternate2 = @dnumber
		)
		AND c.IsIntentEnabled = 1 AND c.Intent_ClientId = @cname

	IF @count > 0
	BEGIN
		SELECT	d.DriverId AS UserId,
				Surname AS Name,
				'' AS [Password],
				d.Archived,
				'support@rtlsystems.co.uk' AS [Email],
				'Mobile' AS [Location],
				d.FirstName,
				d.Surname,
				cd.CustomerId,
				DATEADD(dd,1,GETDATE()) AS ExpiryDate
		FROM dbo.Driver d
			INNER JOIN dbo.CustomerDriver cd ON cd.DriverId = d.DriverId
			INNER JOIN dbo.Customer c ON c.CustomerId = cd.CustomerId
		WHERE d.Archived = 0
			AND cd.Archived = 0
			AND cd.EndDate IS NULL
			AND 
			(
				d.Number = @dnumber OR d.NumberAlternate = @dnumber OR d.NumberAlternate2 = @dnumber
			)
			AND c.IsIntentEnabled = 1 AND c.Intent_ClientId = @cname
	END	ELSE	
	BEGIN -- We have neither a valid user nor a valid driver so return empty user dataset
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
