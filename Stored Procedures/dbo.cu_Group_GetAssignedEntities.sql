SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cu_Group_GetAssignedEntities]
(
	@vid UNIQUEIDENTIFIER	
)
AS
	SELECT
		g.GroupId,
		g.GroupName
	FROM [dbo].[Group] g
	INNER JOIN [dbo].[GroupDetail] gd ON g.GroupId = gd.GroupId
	WHERE gd.EntityDataId = @vid
	AND g.IsParameter = 0
	AND g.Archived = 0

GO
