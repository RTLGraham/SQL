SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Driver_MobilePlatformUsage]
(
	@uid UNIQUEIDENTIFIER,
	@year INT
)
AS
	--DECLARE @uid UNIQUEIDENTIFIER,
	--		@year INT
			
	--SET @uid = N'988d25de-65e9-4fc5-8981-3d2b4ea0feab'
	--SET @year = 2017

	SELECT @year AS YearNumber,
		g.GroupName, d.FirstName, d.Surname, 
		ISNULL(d.FirstName + ' ', '') + ISNULL(d.Surname,'') AS DriverName,
		CAST([Jan] AS INT) AS [Jan],
		CAST([Feb] AS INT) AS [Feb],
		CAST([Mar] AS INT) AS [Mar],
		CAST([Apr] AS INT) AS [Apr],
		CAST([May] AS INT) AS [May],
		CAST([Jun] AS INT) AS [Jun],
		CAST([Jul] AS INT) AS [Jul],
		CAST([Aug] AS INT) AS [Aug],
		CAST([Sep] AS INT) AS [Sep],
		CAST([Oct] AS INT) AS [Oct],
		CAST([Nov] AS INT) AS [Nov],
		CAST([Dec] AS INT) AS [Dec],
		([Jan] + [Feb] + [Mar] + [Apr] + [May] + [Jun] + [Jul] + [Aug] + [Sep] + [Oct] + [Nov] + [Dec]) AS YTD
	FROM dbo.Driver d
		INNER JOIN 
		(	
			SELECT 
				UserId, 
				[Jan],[Feb],[Mar],[Apr],[May],[Jun],[Jul],[Aug],[Sep],[Oct],[Nov],[Dec]
			FROM
			(
				SELECT us.UserId, us.IsLoggedIn,
					   LEFT(DATENAME(MONTH,us.LastOperation),3) AS DateMonth
					   --REPLACE(RIGHT(CONVERT(VARCHAR(9), us.LastOperation, 6), 6), ' ', '') AS DateMonth
					   --(CAST(DATEPART(YEAR, LastOperation) AS VARCHAR(4)) + '-' + CAST(DATEPART(MONTH, LastOperation) AS VARCHAR(2))) AS DateMonth
				FROM dbo.UserSession us
				WHERE DATEPART(YEAR, LastOperation) = @year
			) AS source
			PIVOT
			(
				COUNT(IsLoggedIn) 
				FOR DateMonth
				IN 
				(
					[Jan],[Feb],[Mar],[Apr],[May],[Jun],[Jul],[Aug],[Sep],[Oct],[Nov],[Dec]
				)
			) AS pvt 
		) sessionlog ON sessionlog.UserId = d.DriverId
		INNER JOIN dbo.GroupDetail gd ON gd.EntityDataId = d.DriverId
		INNER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId
		INNER JOIN dbo.CustomerDriver cd ON cd.DriverId = d.DriverId
		INNER JOIN dbo.Customer c ON c.CustomerId = cd.CustomerId
		INNER JOIN dbo.[User] u ON u.CustomerID = c.CustomerId
	WHERE u.UserID = @uid
		AND g.IsParameter = 0 AND g.Archived = 0 AND g.GroupTypeId = 2
	ORDER BY g.GroupName, d.Surname
GO
