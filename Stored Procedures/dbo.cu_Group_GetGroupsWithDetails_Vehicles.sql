SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cu_Group_GetGroupsWithDetails_Vehicles]
(
	@userId UNIQUEIDENTIFIER
)
AS

	--DECLARE	@userId UNIQUEIDENTIFIER
	--SET @userId = N'E90A46FA-B384-4E5B-9351-EBED1C5E4617'

	DECLARE @groupTable TABLE
	(
		GroupId UNIQUEIDENTIFIER,
		GroupName NVARCHAR(255),
		GroupTypeId INT,
		LastModified DATETIME,
		DetailCount INT,
		IsParameter BIT,
		OriginalGroupId UNIQUEIDENTIFIER,
		IsPhysical BIT,
		GeofenceId UNIQUEIDENTIFIER
	)

	INSERT INTO @groupTable (GroupId, GroupName, GroupTypeId, LastModified, DetailCount, IsParameter, OriginalGroupId, IsPhysical, GeofenceId)
		SELECT	g.GroupId,
				g.GroupName,	
				g.GroupTypeId,
				g.LastModified,
				Count(gd.EntityDataId) AS DetailCount,
				g.IsParameter,
				g.OriginalGroupId,
				g.IsPhysical,
				g.GeofenceId
		FROM	[dbo].[Group] g
		LEFT OUTER JOIN [dbo].[GroupDetail] gd ON g.GroupId = gd.GroupId AND g.GroupTypeId = gd.GroupTypeId
		INNER JOIN dbo.UserGroup ug ON g.GroupId = ug.GroupId AND ug.Archived = 0
		WHERE	ug.UserId = @userId
		AND g.Archived = 0
		AND g.IsParameter = 0
		AND g.OriginalGroupId IS NULL
		AND g.GroupTypeId = 1
		GROUP BY g.GroupId, g.GroupName, g.GroupTypeId, g.LastModified, g.OriginalGroupId, g.IsParameter, g.IsPhysical, g.GeofenceId

	SELECT GroupId,
		GroupName,
		GroupTypeId,
		LastModified,
		DetailCount,
		IsParameter,
		OriginalGroupId,
		IsPhysical,
		GeofenceId	 
	FROM @groupTable
	ORDER BY GroupName

	SELECT 
			v.VehicleId ,
			v.VehicleIntId ,
			v.IVHId ,
			v.Registration ,
			v.MakeModel ,
			v.BodyManufacturer ,
			v.BodyType ,
			v.ChassisNumber ,
			v.FleetNumber ,
			v.DisplayColour ,
			v.IconId ,
			v.Identifier ,
			v.Archived ,
			v.LastOperation ,
			v.ROPEnabled ,
			v.Notes ,
			v.IsTrailer ,
			v.FuelMultiplier ,
			v.VehicleTypeID ,
			v.IsCAN ,
			v.IsPrivate ,
			v.ClaimRate ,
			v.FuelTypeId ,
			v.EngineSize ,
			v.MaxPax, 
			g.GroupId
	FROM dbo.Vehicle v
		INNER JOIN dbo.GroupDetail gd on v.VehicleId = gd.EntityDataId
		INNER JOIN @groupTable g on g.GroupId = gd.GroupId
	WHERE v.Archived = 0
	ORDER BY g.GroupId, v.Registration

GO
