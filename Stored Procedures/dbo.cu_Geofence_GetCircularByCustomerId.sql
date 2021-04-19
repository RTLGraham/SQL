SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cu_Geofence_GetCircularByCustomerId]
(
	@customer NVARCHAR(1000)
)
AS

	SELECT 
		g.the_geom.ToString() AS GeomWKT,
		g.GeofenceId,
		g.GeofenceIntId,
		g.GeofenceSpatialId,
		g.GeofenceTypeId,
		g.GeofenceCategoryId,
		g.Description,
		g.Name,
		g.Enabled,
		g.Archived,
		g.LastModified,
		g.CreationDate,
		g.CreationUserId,
		g.IsLocked,
		g.SiteId,
		g.Radius1,
		g.Radius2,
		g.CenterLon,
		g.CenterLat,
		g.Recipients,
		g.SpeedLimit,
		g.IsLookupExcluded
	FROM dbo.Geofence g
		INNER JOIN dbo.[User] u ON g.CreationUserId = u.UserID
		INNER JOIN dbo.Customer c ON c.CustomerId = u.CustomerID
	WHERE g.Archived = 0 AND g.GeofenceTypeId = 1
		AND c.Name = @customer AND c.Archived = 0

GO
