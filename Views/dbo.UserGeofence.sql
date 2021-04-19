SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [dbo].[UserGeofence]
AS
SELECT DISTINCT ug.UserId, geo.GeofenceId
FROM NG_RTL2Application.dbo.Geofence geo
INNER JOIN NG_RTL2Application.dbo.GroupDetail gd ON geo.GeofenceId = gd.EntityDataId
INNER JOIN NG_RTL2Application.dbo.[Group] g ON gd.GroupId = g.GroupId
INNER JOIN NG_RTL2Application.dbo.UserGroup ug ON g.GroupId = ug.GroupId
WHERE g.GroupTypeId = 4
  AND g.IsParameter = 0
  AND g.Archived = 0




GO
