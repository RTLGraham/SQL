SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[proc_GetLatestIncidents]
AS
	SELECT v.VehicleId, c.CameraId, c.Serial, c.ApiId, vli.IncidentId, vli.LastOperation, v.Registration
	FROM dbo.VehicleLatestIncident vli
		INNER JOIN dbo.Camera c ON vli.CameraId = c.CameraId
		INNER JOIN dbo.Vehicle v ON vli.VehicleId = v.VehicleId
	WHERE vli.Archived = 0 AND c.Archived = 0 AND v.Archived = 0
	ORDER BY c.Serial, vli.LastOperation DESC 

GO
