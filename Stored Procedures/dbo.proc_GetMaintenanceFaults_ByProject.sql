SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_GetMaintenanceFaults_ByProject]
(
       @project NVARCHAR(50),
       @faultType INT
)
AS
       --DECLARE @project NVARCHAR(50),
       --            @faultType INT

       --SET @project = '006'
       --SET @faultType = 20

       SELECT mf.MaintenanceFaultId, p.Project, cam.Serial
       FROM dbo.MaintenanceFault mf
              INNER JOIN dbo.MaintenanceJob mj ON mj.MaintenanceJobId = mf.MaintenanceJobId
              INNER JOIN dbo.Vehicle v ON v.VehicleIntId = mj.VehicleIntId
              INNER JOIN dbo.VehicleCamera vc ON vc.VehicleId = v.VehicleId
              INNER JOIN dbo.Camera cam ON cam.CameraId = vc.CameraId
              INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
              INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
              INNER JOIN dbo.Project p ON cam.ProjectId = p.ProjectId
       WHERE mf.FaultTypeId = @faultType 
              AND mj.ResolvedDateTime IS NULL 
              AND mj.Archived = 0
              AND mf.Archived = 0 
              AND vc.Archived = 0 AND vc.EndDate IS NULL
              AND cv.Archived = 0 AND cv.EndDate IS NULL
              AND p.Archived = 0 AND c.Archived = 0
              AND p.Project = @project

GO
