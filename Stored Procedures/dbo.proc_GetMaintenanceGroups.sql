SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[proc_GetMaintenanceGroups]
AS

SELECT DISTINCT g.GroupId, g.GroupName
FROM dbo.[User] u
INNER JOIN dbo.GroupDetail gd ON u.UserID = gd.EntityDataId
INNER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId
INNER JOIN dbo.UserPreference up ON up.UserID = u.UserID
WHERE up.NameID = 717
  AND g.GroupTypeId = 6
  AND g.Archived = 0
  AND g.IsParameter = 0


GO
