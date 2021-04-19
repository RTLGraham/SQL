SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[GetUserGeoMaxDiam] 
(
	@uid UNIQUEIDENTIFIER
)
RETURNS FLOAT 
AS  
BEGIN 
--	DECLARE @uid UNIQUEIDENTIFIER
--			
--	SET @uid = N'07D3E863-2ECC-4CF3-AE3E-39CFB5E6C0EC'
	
	DECLARE @maxDiam FLOAT
	
	SELECT @maxDiam = ISNULL((MAX(geo.Radius1)) * 2.0, 0)
	FROM dbo.UserGroup ug
		INNER JOIN dbo.[Group] g ON ug.GroupId = g.GroupId AND g.GroupTypeId = 4 AND g.IsParameter = 0 AND g.Archived = 0
		INNER JOIN dbo.GroupDetail gd ON g.GroupId = gd.GroupId AND gd.GroupTypeId = 4
		INNER JOIN dbo.Geofence geo ON geo.GeofenceId = gd.EntityDataId AND geo.Archived = 0
	WHERE ug.UserId = @uid
		AND ug.Archived = 0	
	
	RETURN @maxDiam
END


GO
