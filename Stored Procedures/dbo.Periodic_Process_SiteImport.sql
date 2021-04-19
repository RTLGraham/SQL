SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Periodic_Process_SiteImport] 
AS
BEGIN

	UPDATE dbo.SiteImportRequest
	SET Status = 2, ExecutionStartDate = GETDATE()
	WHERE Status = 1

	DECLARE @temp TABLE
	(
		SiteImportRequestId INT,
		SiteImportDetailId INT,
		GeofenceId UNIQUEIDENTIFIER,
		GeofenceIntId INT NULL	
	)

	INSERT INTO @temp (SiteImportRequestId, SiteImportDetailId, GeofenceId)
	SELECT req.SiteImportRequestID, sd.SiteImportDetailId, NEWID()
	FROM dbo.SiteImportRequest req
			INNER JOIN dbo.SiteImportDetail sd ON sd.SiteImportRequestId = req.SiteImportRequestID
	WHERE req.Status = 2
 
	DECLARE @id INT 
	SELECT @id = MAX(GeofenceIntId) FROM dbo.Geofence 

	UPDATE @temp
	SET @id = GeofenceIntId = @id + 1

	INSERT INTO dbo.Geofence
			(GeofenceId,
			 GeofenceIntId,
			 GeofenceTypeId,
			 GeofenceCategoryId,
			 Description,
			 Name,
			 Enabled,
			 Archived,
			 LastModified,
			 CreationDate,
			 CreationUserId,
			 IsLocked,
			 the_geom,
			 SiteId,
			 Radius1,
			 Radius2,
			 CenterLon,
			 CenterLat,
			 Recipients,
			 SpeedLimit
			)
	SELECT	t.GeofenceId,
			t.GeofenceIntId,
			4,
			7,
			sd.Description,
			sd.Name,
			1,
			0,
			GETDATE(),
			GETDATE(),
			req.UserID,
			0,
			geometry::STGeomFromText(sd.WktStr, 4326).MakeValid(),
			sd.SiteId,
			sd.Radius1,
			sd.Radius2,
			sd.CenterLon,
			sd.CenterLat,
			sd.Recipients,
			NULL
	FROM dbo.SiteImportRequest req
			INNER JOIN dbo.SiteImportDetail sd ON sd.SiteImportRequestId = req.SiteImportRequestID
			INNER JOIN @temp t ON t.SiteImportRequestId = sd.SiteImportRequestId AND t.SiteImportDetailId = sd.SiteImportDetailId
	WHERE req.Status = 2

	UPDATE dbo.SiteImportRequest
	SET Status = 3, CompletionDate = GETDATE()
	WHERE Status = 2

END	


GO
