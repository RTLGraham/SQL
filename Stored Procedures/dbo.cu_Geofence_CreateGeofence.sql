SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cu_Geofence_CreateGeofence]
(
	@userId uniqueidentifier,
	@geom_wkt nvarchar(MAX),
	@geofenceType int,
	@category int,
	@name nvarchar (MAX),
	@isLocked BIT = 0,
	@description nvarchar(MAX) = NULL,
	@siteId NVARCHAR(30) = NULL,
	@radius1 FLOAT = NULL,
	@radius2 FLOAT = NULL,
	@centerLon FLOAT = NULL,
	@centerLat FLOAT = NULL,
	@recipients NVARCHAR(MAX) = NULL
)
AS
BEGIN
	DECLARE @IdentityRowGuids TABLE (GeofenceId UNIQUEIDENTIFIER)
	INSERT INTO dbo.Geofence
		(GeofenceCategoryId,
		 [Description],
		 Name,
		 [Enabled],
		 GeofenceTypeId,
		 CreationUserId,
		 --the_geom,
		 IsLocked ,
          SiteId ,
          Radius1 ,
          Radius2 ,
          CenterLon ,
          CenterLat ,
          Recipients) OUTPUT INSERTED.GeofenceId INTO @IdentityRowGuids
	VALUES
		(@category,
		 @description,
		 @name,
		 1,
		 @geofenceType,
		 @userId,
		 --ST.GeomFromText( @geom_wkt, 4326 ),
		 @isLocked,
		 dbo.TrimSiteId(@siteId),
		 @radius1,
		 @radius2,
		 @centerLon,
		 @centerLat,
		 @recipients)

		 
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
		 INNER JOIN @IdentityRowGuids irg ON g.GeofenceId = irg.GeofenceId
END

GO
