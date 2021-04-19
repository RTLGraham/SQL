SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_GetMaintenanceExclusions]
(
	@vid UNIQUEIDENTIFIER NULL,
	@sdate DATETIME NULL,
	@edate DATETIME NULL
)
AS

--DECLARE @vid UNIQUEIDENTIFIER,
--		@sdate DATETIME,
--		@edate DATETIME

--SET @vid = NULL --N'A2A7640A-7CD1-48D3-8270-80A8F2C9FA63'
--SET @sdate = NULL
--SET @edate = NULL


IF @sdate IS NULL SET @sdate = '1900-01-01'
IF @edate IS NULL SET @edate = '2999-12-31'


SELECT 	me.MaintenanceExclusionId,
		'NG_Fleetwise' AS DatabaseName,
		me.ExcludeUntil,
		c.CustomerId,
		c.Name AS CustomerName,
		v.VehicleId,
		v.Registration,
		v.VehicleTypeId,
		dbo.GetVehicleGroupNamesByVehicle(v.VehicleId) AS GroupNames,
		i.IVHId,
		it.Name AS TrackerType,
		i.TrackerNumber,
		me.FaultTypeId,
		CASE WHEN me.FaultTypeId = 0 THEN 'All Faults' ELSE mft.Name END AS FaultType,
		nc.NoteNum
FROM dbo.MaintenanceExclusion me
INNER JOIN dbo.Vehicle v ON v.VehicleIntId = me.VehicleIntId
INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId
INNER JOIN dbo.IVHType it ON it.IVHTypeId = i.IVHTypeId
INNER JOIN dbo.MaintenanceFaultType mft ON mft.FaultTypeId = me.FaultTypeId
LEFT JOIN ( SELECT v.VehicleId, COUNT(DISTINCT n.NoteId) AS NoteNum
			FROM dbo.Vehicle v
			INNER JOIN dbo.MaintenanceExclusion me ON me.VehicleIntId = v.VehicleIntId
			LEFT JOIN dbo.Note n ON n.NoteEntityId = v.VehicleId
			GROUP BY v.VehicleId) nc ON nc.VehicleId = v.VehicleId
WHERE (v.VehicleId = @vid OR @vid IS NULL)
  AND cv.EndDate IS NULL	
  AND (me.ExcludeUntil IS NULL OR me.ExcludeUntil > GETDATE())
  AND cv.Archived = 0
  AND me.Archived = 0
  AND c.Name IN ('Nestle Switzerland', 'Nestle Germany OOH', 'Nestle Germany RML', 'Nestle Germany SLKW')
ORDER BY c.Name, v.Registration






GO
