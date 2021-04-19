SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[GetGeofenceNameFromLongLat_Ltd] 
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
	--SET @uid = N'8457C288-CBF2-4A49-A5BD-97C4BE8561B3'
	--SET @lat = 53.937818
	--SET @lon = -1.503486	
	--SET @maxDiam = 1.10886
	
	DECLARE @geofenceName varchar(255),
			@maxLatFactor FLOAT,
			@maxLonFactor FLOAT

	IF @maxDiam > 5
	BEGIN
		SET @maxDiam = 5
	END
	
	SET @maxLatFactor = ABS((1 / 110.54) * @maxDiam);
	SET @maxLonFactor = ABS((1 / (111.320 * COS(@lat))) * @maxDiam);

	SELECT @geofenceName = geo.Name
						FROM dbo.UserGroup ug
							INNER JOIN dbo.[Group] g ON ug.GroupId = g.GroupId AND g.GroupTypeId = 4 AND g.IsParameter = 0 AND g.Archived = 0
							INNER JOIN dbo.GroupDetail gd ON g.GroupId = gd.GroupId AND gd.GroupTypeId = 4
							INNER JOIN dbo.Geofence geo ON geo.GeofenceId = gd.EntityDataId AND geo.Archived = 0 AND ISNULL(geo.IsLookupExcluded, 0) != 1
						WHERE ug.UserId = @uid 
							AND ug.Archived = 0
							AND (geo.CenterLat BETWEEN @lat - @maxLatFactor AND @lat + @maxLatFactor AND geo.CenterLon BETWEEN @lon - @maxLonFactor AND @lon + @maxLonFactor)
							--AND ST.Within(ST.Point(@lon, @lat, 4326), ST.Envelope(geo.the_geom)) = 1
							AND dbo.DistanceBetweenPoints(@lat, @lon, geo.CenterLat, geo.CenterLon) <= geo.Radius1
	
	IF @geofenceName IS NULL
	BEGIN
		RETURN @address
	END
	
	RETURN @geofenceName
END



GO
