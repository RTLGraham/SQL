SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cu_Group_GetGroupWithDetails]
(
	@groupId UNIQUEIDENTIFIER,
	@userId UNIQUEIDENTIFIER
)
AS
	--DECLARE	@groupId UNIQUEIDENTIFIER,
	--		@userId UNIQUEIDENTIFIER

	--SET @groupId = N'267AFF1C-D821-4D69-9585-0114D4DA372A'
	--SET @userId = N'4C0A0D44-0685-4292-9087-F32E03F10134'
	
	DECLARE @gid UNIQUEIDENTIFIER,
			@isparam BIT
	
	SELECT	@gid = GroupId,
			@isparam = IsParameter
	FROM	[dbo].[Group]
	WHERE	GroupId = @groupId
	
	IF @isparam IS NULL
	BEGIN
		-- Gets the group header information
		SELECT 
			g.GroupId,
			g.GroupName,	
			g.GroupTypeId,
			g.LastModified,
			Count(gd.EntityDataId) AS DetailCount,
			g.IsParameter,
			g.OriginalGroupId,
			g.IsPhysical,
			g.GeofenceId
		FROM [dbo].[Group] g
		LEFT OUTER JOIN [dbo].[GroupDetail] gd ON g.GroupId = gd.GroupId AND g.GroupTypeId = gd.GroupTypeId
		INNER JOIN [dbo].[UserGroup] ug ON g.GroupId = ug.GroupId AND ug.UserId = @userId
		WHERE g.GroupId = @groupId
		AND g.Archived = 0
		GROUP BY g.GroupId, g.GroupName, g.GroupTypeId, g.LastModified, g.OriginalGroupId, g.IsParameter,g.IsPhysical,g.GeofenceId
	END
	ELSE
	BEGIN
		-- Gets the group header information
		SELECT 
			g.GroupId,
			g.GroupName,	
			g.GroupTypeId,
			g.LastModified,
			Count(gd.EntityDataId) AS DetailCount,
			g.IsParameter,
			g.OriginalGroupId,
			g.IsPhysical,
			g.GeofenceId
		FROM [dbo].[Group] g
		LEFT OUTER JOIN [dbo].[GroupDetail] gd ON g.GroupId = gd.GroupId AND g.GroupTypeId = gd.GroupTypeId
		WHERE g.GroupId = @groupId
		AND g.Archived = 0
		GROUP BY g.GroupId, g.GroupName, g.GroupTypeId, g.LastModified, g.OriginalGroupId, g.IsParameter,g.IsPhysical,g.GeofenceId
	END
	
	-- Get the details for the group. GroupType is calculated based on the data in the tables.
	EXECUTE cu_Group_GetGroupDetails @groupId, @userId

GO
