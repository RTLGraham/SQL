SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_Geofence_ChangeGroup]
(
	@userId UNIQUEIDENTIFIER,
	@geoId UNIQUEIDENTIFIER,
	@groupId UNIQUEIDENTIFIER
)
AS
BEGIN

	DECLARE @currGroup UNIQUEIDENTIFIER

	SELECT TOP 1 @currGroup = g.GroupId
	FROM dbo.[Group] g
		INNER JOIN dbo.GroupDetail gd ON gd.GroupId = g.GroupId
		INNER JOIN dbo.Geofence geo ON gd.EntityDataId = geo.GeofenceId
		INNER JOIN dbo.UserGroup ug ON ug.GroupId = g.GroupId
		INNER JOIN dbo.[User] u ON u.UserID = ug.UserId
	WHERE geo.GeofenceId = @geoId AND u.UserID = @userId
		AND g.IsParameter = 0 AND g.Archived = 0 AND g.GroupTypeId = 4
		AND ug.Archived = 0 AND geo.Archived = 0 
	ORDER BY g.LastModified DESC
    
	IF @currGroup != @groupId
	BEGIN
		--Move to different group
		DELETE FROM dbo.GroupDetail WHERE GroupId = @currGroup AND EntityDataId = @geoId AND GroupTypeId = 4
		INSERT INTO dbo.GroupDetail (GroupId, GroupTypeId, EntityDataId) VALUES (@groupId, 4, @geoId)
	END

END



GO
