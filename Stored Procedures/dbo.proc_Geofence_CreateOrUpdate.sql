SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_Geofence_CreateOrUpdate]
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
	@groupId UNIQUEIDENTIFIER = NULL
)
AS
BEGIN

	-- Identify the Customer for the userid provided
	DECLARE @customerId UNIQUEIDENTIFIER
	SELECT @customerId = CustomerID
	FROM dbo.[User]
	WHERE UserID = @userId

	-- First we need to check if this geofence already exists for the customer - are we creating or updating?
	DECLARE @currGeofenceId UNIQUEIDENTIFIER
	SET @currGeofenceId = NULL
	SELECT TOP 1  @currGeofenceId = geo.GeofenceId
	FROM dbo.Geofence geo
	INNER JOIN dbo.[User] u ON geo.CreationUserId = u.UserID
	INNER JOIN dbo.Customer c ON c.CustomerId = u.CustomerID
	WHERE geo.SiteId = @siteId
	  AND c.CustomerId = @customerId

	-- Validate the shape to make sure it is ok to use
	DECLARE @geoId UNIQUEIDENTIFIER
	SET @geoId = NEWID()

	DECLARE @gIntId INT
	SELECT @gIntId = MAX(g.GeofenceIntId) + 1 FROM dbo.Geofence g

	DECLARE @tmpgeom GEOMETRY
	SET @tmpgeom = geometry::STGeomFromText(@geom_wkt, 4326).MakeValid()
	IF (@tmpgeom.ToString() LIKE 'POLYGON%') -- Shape is valid to use, so continue
	BEGIN

		IF @currGeofenceId IS NULL -- Geofence does not already exist, so create it
		BEGIN	

			INSERT INTO dbo.Geofence
					( GeofenceId ,
					  GeofenceIntId,
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
					  Recipients
					)
			VALUES
				(
					@geoId,
					@gIntId,
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
					@recipients)
	
			INSERT INTO dbo.GroupDetail
					( GroupId ,
					  GroupTypeId ,
					  EntityDataId
					)
			VALUES  ( @groupId , -- GroupId - uniqueidentifier
					  4 , -- GroupTypeId - int
					  @geoId  -- EntityDataId - uniqueidentifier
					)
			SELECT @geoId AS GeofenceId
		END	-- of geofence create
		ELSE BEGIN -- Geofence already exists so we will update it	
			UPDATE dbo.Geofence
			SET	Name = @name,
				Description = @description,
				Radius1 = @radius1,
				Radius2 = @radius2,
				CenterLon = @centerLon,
				CenterLat = @centerLat,
				Recipients = @recipients,
				the_geom = geometry::STGeomFromText(@geom_wkt, 4326).MakeValid(),
				LastModified = GETDATE()
			WHERE GeofenceId = @currGeofenceId
			SELECT @currGeofenceId
		END	-- of geofence update	
	END
	ELSE BEGIN -- geofence shape was not valid
		RAISERROR ('Geofence is not valid: check for crossed lines', 16, 1)
	END
END




GO
