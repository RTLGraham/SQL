SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_GetProjectDevices] @cid UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @pid INT
	SELECT @pid = ProjectId FROM dbo.Project WHERE CustomerId = @cid

	SELECT	cv.VehicleId,
			cam.CameraId,
	        cam.Serial,
	        v.Registration
	FROM dbo.CustomerVehicle cv
	INNER JOIN dbo.Vehicle v ON cv.VehicleId = v.VehicleId
	INNER JOIN dbo.VehicleCamera vc ON cv.VehicleId = vc.VehicleId
	INNER JOIN dbo.Camera cam ON vc.CameraId = cam.CameraId
	WHERE cam.ProjectId = @pid
	  AND cv.Archived = 0
	  AND cv.EndDate IS NULL
	  AND vc.Archived = 0
	  AND vc.EndDate IS NULL
	  AND cam.Archived = 0
	  AND v.Archived = 0
END



GO
