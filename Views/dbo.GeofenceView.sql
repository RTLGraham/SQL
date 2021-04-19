SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dbo].[GeofenceView]
AS

SELECT		[GeofenceId]
           ,[GeofenceIntId]
           ,[GeofenceTypeId]
           ,[GeofenceCategoryId]
           ,[Description]
           ,[Name]
           ,[Enabled]
           ,[Archived]
           ,[LastModified]
           ,[CreationDate]
           ,[CreationUserId]
           ,[IsLocked]
           --,CONVERT(VARBINARY(MAX), [the_geom]) AS TheGeom
           ,CONVERT(VARCHAR(MAX), [the_geom]) AS TheGeomString
           ,[SiteId]
           ,[Radius1]
           ,[Radius2]
           ,[CenterLon]
           ,[CenterLat]
           ,[Recipients]
           ,[SpeedLimit]
		   ,GeofenceSpatialId
FROM dbo.Geofence




GO
