SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[CustomerGeofence]
AS
SELECT DISTINCT u.CustomerID, g.GeofenceId
FROM NG_RTL2Application.dbo.[User] u
	INNER JOIN NG_RTL2Application.dbo.UserGroup ug ON u.UserID = ug.UserId
	INNER JOIN NG_RTL2Application.dbo.[Group] gr ON ug.GroupId = gr.GroupId
	INNER JOIN NG_RTL2Application.dbo.GroupDetail gd ON gr.GroupId = gd.GroupId AND gr.GroupTypeId = gd.GroupTypeId
	INNER JOIN NG_RTL2Application.dbo.Geofence g ON gd.EntityDataId = g.GeofenceId
WHERE u.Archived = 0
  AND ug.Archived = 0
  AND gr.GroupTypeId = 4
  AND gr.Archived = 0
  AND gr.IsParameter = 0
  AND g.Archived = 0

GO
