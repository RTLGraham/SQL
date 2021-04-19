SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- ====================================================================
-- Author:		Graham Pattison
-- Create date: 20/12/2011
-- Description:	Gets IVH Uniqueidentifier from the IVHIntegerId
-- ====================================================================
CREATE FUNCTION [dbo].[GetGeofenceIdFromSiteIdAndVehicleIntId] 
(
	@siteId NVARCHAR(MAX),
	@vehicleIntId INT
)
RETURNS UNIQUEIDENTIFIER
AS
BEGIN

	DECLARE @geofenceId UNIQUEIDENTIFIER

	SELECT TOP 1 @geofenceId = geo.GeofenceId
	FROM dbo.Vehicle v 
		INNER JOIN dbo.GroupDetail gd ON gd.EntityDataId = v.VehicleId
		INNER JOIN dbo.[Group] g ON gd.GroupId = g.GroupId
		INNER JOIN dbo.UserGroup ug ON g.GroupId = ug.GroupId
		INNER JOIN dbo.[User] u ON ug.UserId = u.UserID
		INNER JOIN dbo.UserGroup ugG ON u.UserID = ugG.UserId
		INNER JOIN dbo.[Group] gG ON ugG.GroupId = gG.GroupId
		INNER JOIN dbo.GroupDetail gdG ON gG.GroupId = gdG.GroupId
		INNER JOIN dbo.Geofence geo ON gdG.EntityDataId = geo.GeofenceId
	WHERE g.Archived = 0 AND g.IsParameter = 0 AND gG.Archived = 0 AND gG.IsParameter = 0 AND g.GroupTypeId = 1 AND gG.GroupTypeId = 4
		AND geo.SiteId = dbo.TrimSiteId(@siteId)
		AND v.VehicleIntId = @vehicleIntId
	ORDER BY geo.LastModified DESC
		
	RETURN @geofenceId

END


GO
