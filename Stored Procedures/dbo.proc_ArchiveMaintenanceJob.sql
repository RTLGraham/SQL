SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [dbo].[proc_ArchiveMaintenanceJob]
(
	@maintenanceJobId INT,
	@uid UNIQUEIDENTIFIER NULL
)
AS

UPDATE dbo.MaintenanceJob 
SET Archived = 1
WHERE MaintenanceJobId = @maintenanceJobId

-- Mark any faults as Acknowledged if not already
UPDATE dbo.MaintenanceFault
SET AcknowledgedBy = @uid
FROM dbo.MaintenanceFault mf
INNER JOIN dbo.MaintenanceJob mj ON mj.MaintenanceJobId = mf.MaintenanceJobId
WHERE mj.MaintenanceJobId = @maintenanceJobId
  AND mf.AcknowledgedBy IS NULL	
	





GO
