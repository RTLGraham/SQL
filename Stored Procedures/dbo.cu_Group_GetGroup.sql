SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cu_Group_GetGroup]
(
	@groupName nvarchar(255),
	@userId UNIQUEIDENTIFIER,
	@groupTypeId INT = NULL
)
AS

--DECLARE	@groupName nvarchar(255),
--		@userId UNIQUEIDENTIFIER,
--		@groupTypeId INT

--SET @groupTypeId = 4
--SET @groupName = ''
--SET @userId = N'4C0A0D44-0685-4292-9087-F32E03F10134'

	SELECT
		g.GroupId,
		g.GroupName,	
		g.GroupTypeId,
		g.LastModified,
		Count(gd.EntityDataId) AS DetailCount,
		g.IsParameter,
		g.OriginalGroupId
	FROM [dbo].[Group] g
	LEFT OUTER JOIN [dbo].[GroupDetail] gd ON g.GroupId = gd.GroupId AND g.GroupTypeId = gd.GroupTypeId
	INNER JOIN [dbo].[UserGroup] ug ON g.GroupId = ug.GroupId
	WHERE g.GroupName LIKE '%' + @groupName + '%'
	AND g.Archived = 0
	AND g.IsParameter = 0
	AND g.OriginalGroupId IS NULL
	AND ug.UserId = @userId
	AND (@groupTypeId IS NULL OR g.GroupTypeId = @groupTypeId)
	GROUP BY g.GroupId, g.GroupName, g.GroupTypeId, g.LastModified, g.OriginalGroupId, g.IsParameter

GO
