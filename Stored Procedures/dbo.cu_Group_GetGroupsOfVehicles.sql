SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cu_Group_GetGroupsOfVehicles]
(
	@groupName nvarchar(255)
)
AS
SELECT
	g.GroupId,
	g.GroupName,	
	g.GroupTypeId,
	g.LastModified,
	Count(gd.EntityDataId) AS DetailCount,
	g.IsParameter,
	g.OriginalGroupId
FROM [dbo].[Group] g
INNER JOIN [dbo].[GroupDetail] gd ON g.GroupId = gd.GroupId AND g.GroupTypeId = gd.GroupTypeId AND g.GroupTypeId = 1
WHERE g.GroupName LIKE '%' + @groupName + '%'
AND g.Archived = 0
AND g.IsParameter = 0
AND g.OriginalGroupId IS NULL
GROUP BY g.GroupId, g.GroupName, g.GroupTypeId, g.LastModified, g.OriginalGroupId, g.IsParameter

GO
