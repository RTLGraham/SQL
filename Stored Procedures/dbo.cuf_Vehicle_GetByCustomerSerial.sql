SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_GetByCustomerSerial]
	@cName NVARCHAR(MAX),
	@serial NVARCHAR(MAX)
AS
	--DECLARE @cName NVARCHAR(MAX),
	--		@serial NVARCHAR(MAX)
	--SELECT  @cName = 'Sucklings Transport', 
	--		@serial = '114900825'

	SELECT TOP 1 v.VehicleId ,
                 v.IVHId ,
                 v.Registration ,
                 v.ChassisNumber, 
				 i.SerialNumber,
				 STUFF((SELECT ',' + CAST(g.GroupName AS NVARCHAR(MAX))
				   FROM dbo.Vehicle v
						INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId	
						INNER JOIN dbo.GroupDetail gd ON v.VehicleId = gd.EntityDataId
						INNER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId
				   WHERE g.GroupTypeId = 1 AND g.IsParameter = 0 AND g.Archived = 0
						AND g.GroupName NOT LIKE '*%'
						AND g.GroupName NOT LIKE '$%'
						AND i.SerialNumber = @serial AND v.Archived = 0 AND i.Archived = 0
				   GROUP BY g.GroupName
				   FOR XML PATH(''), TYPE).value('.','VARCHAR(max)'), 1, 1, '') AS Groups
	FROM dbo.Vehicle v
		INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
		INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
		INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId	
	WHERE i.SerialNumber = @serial AND c.Name = @cName AND v.Archived = 0 AND i.Archived = 0 AND cv.EndDate IS NULL
	ORDER BY v.LastOperation DESC

GO
