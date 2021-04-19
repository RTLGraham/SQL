SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cu_Geofence_GetSites]
(
	@userId UNIQUEIDENTIFIER
)
AS
	--DECLARE	@userId UNIQUEIDENTIFIER
	--SET @userId = N'86C3891D-3F65-4679-BDCE-2924B2D5BAEE'
	
	SELECT	DISTINCT
			g.GeofenceId ,
			g.GeofenceIntId ,
			g.GeofenceTypeId ,
			g.GeofenceCategoryId ,
			g.Description ,
			g.Name ,
			g.Enabled ,
			g.Archived ,
			g.LastModified ,
			g.CreationDate ,
			u.Name AS CreationUser ,
			g.CreationUserId ,
			g.SiteId ,
			g.Radius1 ,
			g.Radius2 ,
			g.CenterLon ,
			g.CenterLat ,
			g.Recipients ,
			g.SpeedLimit
	FROM dbo.Geofence g
		INNER JOIN dbo.[User] u ON g.CreationUserId = u.UserID
		INNER JOIN dbo.[User] uMe ON uMe.CustomerID = u.CustomerID
	WHERE g.Archived = 0 
		AND g.GeofenceTypeId = 4 -- Site
		AND uMe.UserID = @userId
	ORDER BY g.Name

GO
