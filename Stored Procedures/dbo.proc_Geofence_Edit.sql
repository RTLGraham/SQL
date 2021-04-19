SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_Geofence_Edit]
(
	@geoId UNIQUEIDENTIFIER,
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
	@isLookupExcluded BIT = NULL,
	@isTemperatureMonitored BIT = NULL,
	@speedLimit TINYINT = NULL,
	@isVideoProhibited BIT = NULL
)
AS
BEGIN
	UPDATE dbo.Geofence
	SET
		GeofenceTypeId = @geofenceType,
		GeofenceCategoryId = @category,
		Description = @description,
		Name = @name,
		LastModified = GETDATE(),
		IsLocked = @isLocked,
		the_geom = geometry::STGeomFromText(@geom_wkt, 4326).MakeValid(),
		SiteId = dbo.TrimSiteId(@siteId),
		Radius1 = @radius1,
		Radius2 = @radius2,
		CenterLon = @centerLon,
		CenterLat = @centerLat,
		Recipients = @recipients,
		IsLookupExcluded = @isLookupExcluded,
		SpeedLimit = @speedLimit,
		IsTemperatureMonitored = @isTemperatureMonitored,
		IsVideoProhibited = @isVideoProhibited
	WHERE 
		GeofenceId = @geoId

END

GO
