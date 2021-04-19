SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_GetMaintenanceFaultsToday]
AS

DECLARE @sdate DATETIME,
		@edate DATETIME

SET @sdate = CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)
SET @edate = CAST(FLOOR(CAST(GETDATE() AS FLOAT) + 1) AS DATETIME)

SELECT	c.Name AS CustomerName,
		v.Registration,
		dbo.GetVehicleGroupNamesByVehicle(v.VehicleId) AS GroupNames,
		it.Name AS TrackerType,
		mj.CreationDateTime,
		mft.Name AS FaultType,
		mat.Name AS AssetType,
		mf.AssetReference
FROM dbo.MaintenanceJob mj
INNER JOIN dbo.Vehicle v ON v.VehicleIntId = mj.VehicleIntId
INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId
INNER JOIN dbo.IVHType it ON it.IVHTypeId = i.IVHTypeId
INNER JOIN dbo.MaintenanceFault mf ON mf.MaintenanceJobId = mj.MaintenanceJobId
INNER JOIN dbo.MaintenanceFaultType mft ON mft.FaultTypeId = mf.FaultTypeId
LEFT JOIN dbo.MaintenanceAssetType mat ON mat.AssetTypeId = mf.AssetTypeId
LEFT JOIN dbo.[User] u ON mf.AcknowledgedBy = u.UserID
WHERE cv.EndDate IS NULL	
  AND mj.ResolvedDateTime IS NULL
  AND mj.CreationDateTime BETWEEN @sdate AND @edate
  AND mj.Archived = 0
  AND mf.Archived = 0
  AND cv.Archived = 0
ORDER BY mj.CreationDateTime



GO
