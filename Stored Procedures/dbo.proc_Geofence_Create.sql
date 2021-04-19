SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_Geofence_Create]
(
	@userId UNIQUEIDENTIFIER,
	@geom_wkt NVARCHAR(MAX),
	@geofenceType INT,
	@category INT,
	@name NVARCHAR (MAX),
	@isLocked BIT = 0,
	@description NVARCHAR(MAX) = NULL,
	@siteId NVARCHAR(30) = NULL,
	@radius1 FLOAT = NULL,
	@radius2 FLOAT = NULL,
	@centerLon FLOAT = NULL,
	@centerLat FLOAT = NULL,
	@recipients NVARCHAR(MAX) = NULL,
	@groupId UNIQUEIDENTIFIER,
	@isLookupExcluded BIT = NULL,
	@isTemperatureMonitored BIT = NULL,
	@speedLimit TINYINT = NULL,
	@isVideoProhibited BIT = NULL
		
)
AS
BEGIN
	DECLARE @geoId UNIQUEIDENTIFIER
	SET @geoId = NEWID()
	DECLARE @geoIntId INT
	SELECT @geoIntId = MAX(GeofenceIntId) + 1 FROM dbo.Geofence

	DECLARE @tmpgeom GEOMETRY
	SET @tmpgeom = geometry::STGeomFromText(@geom_wkt, 4326).MakeValid()
	IF (@tmpgeom.ToString() LIKE 'POLYGON%')
	BEGIN

		INSERT INTO dbo.Geofence
				( GeofenceId ,
				  GeofenceIntId ,
				  GeofenceTypeId ,
				  GeofenceCategoryId ,
				  Description ,
				  Name ,
				  Enabled ,
				  Archived ,
				  LastModified ,
				  CreationDate ,
				  CreationUserId ,
				  IsLocked ,
				  the_geom ,
				  SiteId ,
				  Radius1 ,
				  Radius2 ,
				  CenterLon ,
				  CenterLat ,
				  Recipients,
				  IsLookupExcluded,
				  SpeedLimit,
				  IsTemperatureMonitored,
				  IsVideoProhibited
				)
		VALUES
			(
				@geoId,
				@geoIntId,
				@geofenceType,
				@category,
				@description,
				@name,
				1,
				0,
				GETDATE(),
				GETDATE(),
				@userId,
				@isLocked,
				geometry::STGeomFromText(@geom_wkt, 4326).MakeValid(),
				dbo.TrimSiteId(@siteId),
				@radius1,
				@radius2,
				@centerLon,
				@centerLat,
				@recipients,
				@isLookupExcluded,
				@speedLimit,
				@isTemperatureMonitored,
				@isVideoProhibited)
		
		IF @groupId IS NOT NULL
		BEGIN
			--Desease outbreak geofences don't need to be linked to Group
			INSERT INTO dbo.GroupDetail
					( GroupId ,
					  GroupTypeId ,
					  EntityDataId
					)
			VALUES  ( @groupId , -- GroupId - uniqueidentifier
					  4 , -- GroupTypeId - int
					  @geoId  -- EntityDataId - uniqueidentifier
					)
		END
		SELECT @geoId AS GeofenceId
	END
	ELSE BEGIN
		RAISERROR ('Geofence is not valid: check for crossed lines', 16, 1)
	END
END

GO
