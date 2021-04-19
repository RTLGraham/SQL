SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[GetGeofenceNameFromLongLat] 
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
	--SET @uid = N'AC5FC459-FAF5-48D7-BBBE-88CC5EE824E1'
	--SET @lat = 55.8574323
	--SET @lon = -4.045263

	DECLARE @geofenceName varchar(255)

	DECLARE @luid UNIQUEIDENTIFIER,
			@llat FLOAT, 
			@llon FLOAT

	SELECT	@luid = @uid,
			@llat = @lat,
			@llon = @lon

	SELECT @geofenceName = geo.Name
						FROM dbo.UserGroup ug
							INNER JOIN dbo.[Group] g ON ug.GroupId = g.GroupId AND g.GroupTypeId = 4 AND g.IsParameter = 0 AND g.Archived = 0
							INNER JOIN dbo.GroupDetail gd ON g.GroupId = gd.GroupId AND gd.GroupTypeId = 4
							INNER JOIN dbo.Geofence geo ON geo.GeofenceId = gd.EntityDataId AND geo.Archived = 0 AND geo.IsLookupExcluded != 1
						WHERE ug.UserId = @luid 
							AND ug.Archived = 0
							--AND ST.Within(ST.Point(@lon, @lat, 4326), ST.Envelope(geo.the_geom)) = 1
							AND dbo.DistanceBetweenPoints(@llat, @llon, geo.CenterLat, geo.CenterLon) <= geo.Radius1

	--SELECT @geofenceName, @address

	IF @geofenceName IS NULL
	BEGIN
		RETURN @address
	END

	RETURN @geofenceName
END



GO
