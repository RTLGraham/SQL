SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [dbo].[cuf_Vehicle_GetByCustomerTrackerNumberWithGroupData]
	@cName NVARCHAR(MAX),
	@tNumber NVARCHAR(MAX)
AS
	--DECLARE @cName NVARCHAR(MAX),
	--		@tNumber NVARCHAR(MAX)
	--SELECt		@cName = 'Bert Logistics', 
	--		@tNumber = '357300071461589'

	DECLARE @groups TABLE(
	Groups NVARCHAR(MAX),
	FolderRoots NVARCHAR(MAX)
	)
	INSERT INTO @groups (Groups, FolderRoots)
	SELECT ',' + CAST(g.GroupName AS NVARCHAR(MAX)),',' + CAST(grd.GroupDataItem AS NVARCHAR(MAX))
				   FROM dbo.Vehicle v
						INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId	
						INNER JOIN dbo.GroupDetail gd ON v.VehicleId = gd.EntityDataId
						INNER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId
						LEFT JOIN dbo.GroupData grd ON grd.GroupId = g.GroupId AND grd.GroupDataTypeId = 1 AND grd.Archived = 0
				   WHERE g.GroupTypeId = 1 AND g.IsParameter = 0 AND g.Archived = 0
						AND g.GroupName NOT LIKE '*%'
						AND g.GroupName NOT LIKE '$%'
						AND i.TrackerNumber = @tNumber AND v.Archived = 0 AND i.Archived = 0
				   GROUP BY g.GroupName,grd.GroupDataItem



	SELECT TOP 1 v.VehicleId ,
                 v.IVHId ,
                 v.Registration ,
                 v.ChassisNumber, 
				 i.SerialNumber,
				STUFF((SELECT g.Groups
				   FROM @groups g
				   FOR XML PATH(''), TYPE).value('.','VARCHAR(max)'), 1, 1, '') AS Groups,
				STUFF((SELECT g.FolderRoots
				   FROM @groups g
				   FOR XML PATH(''), TYPE).value('.','VARCHAR(max)'), 1, 1, '') AS FolderRoots
	FROM dbo.Vehicle v
		INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
		INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
		INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId	
	WHERE i.TrackerNumber = @tNumber AND c.Name = @cName AND v.Archived = 0 AND i.Archived = 0 AND cv.EndDate IS NULL
	ORDER BY v.LastOperation DESC


GO
