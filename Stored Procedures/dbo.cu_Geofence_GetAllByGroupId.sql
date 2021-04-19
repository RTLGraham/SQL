SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cu_Geofence_GetAllByGroupId]
(
	@groupId UNIQUEIDENTIFIER
)

AS

				--DECLARE @groupId UNIQUEIDENTIFIER
				--SET @groupId = N'e3acb89a-e2f7-4325-8f2a-c228ff9056ba'	
				
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
					g.[IsLookupExcluded],
					g.[IsTemperatureMonitored],
					CASE WHEN g.[GeofenceTypeId] = 1 THEN NULL ELSE CAST(g.[the_geom] AS VARBINARY(MAX)) END AS [the_geom],
					g.[SiteId],
					g.[Radius1],
					g.[Radius2],
					g.[CenterLon],
					g.[CenterLat],
					g.[Recipients],
					g.[SpeedLimit],
					g.[IsVideoProhibited]
				FROM dbo.Geofence g
					INNER JOIN dbo.GroupDetail gd ON gd.EntityDataId = g.GeofenceId
				WHERE gd.GroupId = @groupId
					AND g.Archived = 0
				

GO
