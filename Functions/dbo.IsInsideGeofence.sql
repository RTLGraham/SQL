SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:	<D. Jurins>
-- Create date:     <2013-03-06>
-- Description:	<This function performs geofence lookup to identify if provided coordinate is WITHIN the geofence>
-- =============================================
CREATE FUNCTION [dbo].[IsInsideGeofence]
(
          @lat FLOAT,
          @lon FLOAT,
          @cid UNIQUEIDENTIFIER
)
RETURNS UNIQUEIDENTIFIER
AS
BEGIN
          DECLARE   @point GEOMETRY,
                    @result UNIQUEIDENTIFIER
          
          SET @point = geometry::Point(@Lon,@Lat, 4326)
          
	SELECT    TOP 1
	          @result = g.GeofenceId
	FROM      dbo.Geofence g
	INNER JOIN dbo.[User] u on u.UserID = g.CreationUserId
	WHERE	@point.STWithin(g.the_geom) = 1
	          AND g.Archived = 0
	          AND u.CustomerID = @cid
	ORDER BY  the_geom.STDistance(@point) DESC
	
	RETURN @result
END




GO
