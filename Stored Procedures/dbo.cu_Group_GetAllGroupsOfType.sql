SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cu_Group_GetAllGroupsOfType]
(
	@grouptypeid int
)
AS
SELECT
	[GroupId],
	[GroupName]
FROM
	[dbo].[Group]
WHERE
	GroupTypeId = @grouptypeid
	AND Archived = 0
	AND IsParameter = 0

GO
