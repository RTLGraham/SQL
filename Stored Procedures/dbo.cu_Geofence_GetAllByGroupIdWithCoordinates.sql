SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cu_Geofence_GetAllByGroupIdWithCoordinates]
(
	@groupId UNIQUEIDENTIFIER
)

AS

				SELECT
					g.[GeofenceId],
					g.[GeofenceIntId],
					g.[GeofenceSpatialId],
					g.[GeofenceTypeId],
					g.[GeofenceCategoryId],
					g.[Description],
					g.[Name],
					g.[Enabled],
					g.[Archived],
					g.[LastModified],
					g.[CreationDate],
					g.[CreationUserId],
					g.[IsLocked],
					CAST(g.[the_geom] AS VARBINARY(MAX)) AS the_geom,
					g.[SiteId],
					g.[Radius1],
					g.[Radius2],
					g.[CenterLon],
					g.[CenterLat],
					g.[Recipients],
					g.[SpeedLimit]
				FROM dbo.Geofence g
					INNER JOIN dbo.GroupDetail gd ON gd.EntityDataId = g.GeofenceId
				WHERE gd.GroupId = @groupId
					AND g.Archived = 0

GO
