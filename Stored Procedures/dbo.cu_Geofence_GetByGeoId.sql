SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cu_Geofence_GetByGeoId]
(
	@geofenceId UNIQUEIDENTIFIER
)
AS
BEGIN
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
				WHERE g.[GeofenceId] = @geofenceId
					AND g.[Archived] = 0
END

GO
