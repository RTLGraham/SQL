SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[GetGeofenceNameFromLongLat_ST] 
(
	@lat FLOAT, 
	@lon FLOAT,
	@uid UNIQUEIDENTIFIER,
	@address VARCHAR(255)
)
RETURNS varchar(255) 
AS  
BEGIN 
	--DECLARE @address VARCHAR(255),
	--		@uid UNIQUEIDENTIFIER,
	--		@lat FLOAT, 
	--		@lon FLOAT
			
	--SET @address = 'address'
	--SET @uid = N'7BAEE9C3-1B0E-49FC-A98D-D5A2D6ADF8CA'
	--SET @lat = 55.8574323
	--SET @lon = -4.045263
	
	DECLARE @geofenceName varchar(255)
	
	SELECT @geofenceName = geo.Name
						FROM dbo.UserGroup ug
							INNER JOIN dbo.[Group] g ON ug.GroupId = g.GroupId AND g.GroupTypeId = 4 AND g.IsParameter = 0 AND g.Archived = 0
							LEFT OUTER JOIN dbo.GroupDetail gd ON g.GroupId = gd.GroupId AND gd.GroupTypeId = 4
							INNER JOIN dbo.Geofence geo ON geo.GeofenceId = gd.EntityDataId AND geo.Archived = 0
						WHERE ug.UserId = @uid 
							AND ug.Archived = 0
							AND ST.Within(ST.Point(@lon, @lat, 4326), ST.Envelope(geo.the_geom)) = 1
							--AND dbo.DistanceBetweenPoints(@lat, @lon, geo.CenterLat, geo.CenterLon) <= geo.Radius1
	
	IF @geofenceName IS NULL
	BEGIN
		RETURN @address
	END
	
	RETURN @geofenceName
END


GO
