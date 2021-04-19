SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_WriteProactiveMaintenance]
(
	@vid UNIQUEIDENTIFIER,
	@faultTypeId SMALLINT,
	@assetTypeId SMALLINT,
	@assetReference NVARCHAR(100)
)
AS 

SET NOCOUNT OFF

--DECLARE	@vid UNIQUEIDENTIFIER,
--		@faultTypeId SMALLINT,
--		@assetTypeId SMALLINT,
--		@assetReference NVARCHAR(100)

--SET	@vid = N'1d65cc6c-42b7-4bd5-b0b5-944d44e70975'
--SET @faultTypeId = 20
--SET	@assetTypeId = 3
--SET	@assetReference = '22004975 - sdcard corrupted'

/*
This stored procedure is used to insert an item into MaintenanceJob and MaintenanceFault table for Proactive Maintenance
It handles creation of a new job, or adding a fault to an existing job, as required
*/

DECLARE @faultData TABLE (VehicleIntId INT, MaintenanceJobId INT, FaultTypeId SMALLINT, AssetTypeId SMALLINT, AssetReference NVARCHAR(100))
DECLARE @MaintenanceJobId INT

---------------------------------------------------------------------------------------------------------------------------------------
-- Now check for an existing Maintenance Job and compare to any exclusions. Row will be inserted into @faultData if fault to be created
---------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO @faultData (VehicleIntId, MaintenanceJobId, FaultTypeId, AssetTypeId, AssetReference)
SELECT v.VehicleIntId, mj.MaintenanceJobId, @faultTypeId, @assetTypeId, @assetReference
FROM dbo.Vehicle v
LEFT JOIN dbo.MaintenanceExclusion ex ON ex.VehicleIntId = v.VehicleIntId AND (ex.FaultTypeId = 0 OR ex.FaultTypeId = @faultTypeId) AND GETDATE() < ISNULL(ex.ExcludeUntil, '2999-12-31')
LEFT JOIN dbo.MaintenanceJob mj ON mj.VehicleIntId = v.VehicleIntId AND mj.ResolvedDateTime IS NULL	AND mj.Archived = 0
LEFT JOIN dbo.MaintenanceFault mf ON mf.MaintenanceJobId = mj.MaintenanceJobId AND mf.Archived = 0 AND mf.FaultTypeId = @faultTypeId
WHERE v.VehicleId = @vid
  AND ex.MaintenanceExclusionId IS NULL		
  AND mf.MaintenanceFaultId IS NULL	

--------------------------------------------------------------------------------------------------------------------
-- If a MaintenanceJob already exists the fault data is added to that job, otherwise a MaintenanceJob is created
--------------------------------------------------------------------------------------------------------------------

-- Create new MaintenanceJob if no currently open job	
INSERT INTO dbo.MaintenanceJob (VehicleIntId, IVHIntId, CreationDateTime, Archived, LastOperation)
SELECT v.VehicleIntId, i.IVHIntId, GETUTCDATE(), 0, GETDATE()
FROM @faultData f	
INNER JOIN dbo.Vehicle v ON v.VehicleIntId = f.VehicleIntId
LEFT OUTER JOIN dbo.IVH i ON i.IVHId = v.IVHId
WHERE f.MaintenanceJobId IS NULL	

SET @MaintenanceJobId = SCOPE_IDENTITY()

-- Now add new faults to the MaintenanceJob
INSERT INTO dbo.MaintenanceFault (MaintenanceJobId, FaultTypeId, FaultDateTime, AssetTypeId, AssetReference, AcknowledgedBy, Archived, LastOperation)
SELECT ISNULL(f.MaintenanceJobId, @MaintenanceJobId), FaultTypeId, GETUTCDATE(), AssetTypeId, AssetReference, NULL, 0, GETDATE()
FROM @faultData f



GO
