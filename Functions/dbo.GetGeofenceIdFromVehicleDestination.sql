SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[GetGeofenceIdFromVehicleDestination]
	(@DestinationId varchar(20), @vid uniqueidentifier)
RETURNS uniqueidentifier AS 
BEGIN 
	DECLARE @GeofenceId uniqueidentifier

	-- This function only returns geofences that are for use with the delivery notification system
	-- ie. Radius2 is not null

	SELECT @GeofenceId = g.GeoFenceId
	FROM dbo.Geofence g
	INNER JOIN dbo.GroupDetail gdg ON gdg.EntityDataId = g.GeofenceId AND gdg.GroupTypeId = 4
	INNER JOIN dbo.UserGroup ugg ON gdg.GroupId = ugg.GroupId
	INNER JOIN dbo.UserGroup ugv ON ugv.UserId = ugg.UserId
	INNER JOIN dbo.GroupDetail gdv ON gdv.GroupId = ugv.GroupId AND gdv.GroupTypeId = 1
	WHERE SiteId = @DestinationId
	  AND gdv.EntityDataId = @vid
	  AND Radius2 IS NOT NULL			  

	RETURN @GeofenceId
END

GO
