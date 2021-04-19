SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[GetGeofenceIdFromLongLat_Ltd] 
(
	@lat FLOAT, 
	@lon FLOAT,
	@uid UNIQUEIDENTIFIER,
	@address VARCHAR(255),
	@maxDiam FLOAT
)
RETURNS varchar(255) 
AS  
BEGIN 
	--DECLARE @address VARCHAR(255),
	--		@uid UNIQUEIDENTIFIER,
	--		@lat FLOAT, 
	--		@lon FLOAT,
	--		@maxDiam FLOAT
			
	--SET @address = 'address'
	--SET @uid = N'E09678EC-1B66-402A-B168-548048ECB262'
	--SET @lat = 53.620323	
	--SET @lon = -2.340126
	--SET @maxDiam = 0.38
	
	DECLARE @geofenceName varchar(255),
			@geofenceId UNIQUEIDENTIFIER,
			@maxLatFactor FLOAT,
			@maxLonFactor FLOAT

	IF @maxDiam > 5
	BEGIN
		SET @maxDiam = 5
	END
	
	SET @maxLatFactor = ABS((1 / 110.54) * @maxDiam);
	SET @maxLonFactor = ABS((1 / (111.320 * COS(@lat))) * @maxDiam);
	
	SELECT @geofenceId = geo.GeofenceId
						FROM dbo.UserGroup ug
							INNER JOIN dbo.[Group] g ON ug.GroupId = g.GroupId AND g.GroupTypeId = 4 AND g.IsParameter = 0 AND g.Archived = 0
							INNER JOIN dbo.GroupDetail gd ON g.GroupId = gd.GroupId AND gd.GroupTypeId = 4
							INNER JOIN dbo.Geofence geo ON geo.GeofenceId = gd.EntityDataId AND geo.Archived = 0
						WHERE ug.UserId = @uid 
							AND ug.Archived = 0
							AND (geo.CenterLat BETWEEN @lat - @maxLatFactor AND @lat + @maxLatFactor AND geo.CenterLon BETWEEN @lon - @maxLonFactor AND @lon + @maxLonFactor)
							--AND ST.Within(ST.Point(@lon, @lat, 4326), ST.Envelope(geo.the_geom)) = 1
							AND dbo.DistanceBetweenPoints(@lat, @lon, geo.CenterLat, geo.CenterLon) <= geo.Radius1
											
	RETURN @geofenceId
END


GO
