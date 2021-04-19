SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[proc_BulkInsertVehicleLatestStatus]
AS

-- update/insert rows into VehicleLatestEvent table
-- don't change the 'LatestDriverId' column as this is written
-- directly to the live table (not the temp version) by proc_WriteLatestDriver

-- NB keeping rows in Vehicle latest Event temp will remove the need for these tests here against event date time
-- however it will mean that the temp values should be cleared aty each iteration otherwise they will always all be copied to the live tabels.

UPDATE dbo.VehicleLatestStatus
SET 
	dbo.VehicleLatestStatus.EcospeedStatus = ISNULL(dbo.VehicleLatestStatusTemp.EcospeedStatus, dbo.VehicleLatestStatus.EcospeedStatus),
	dbo.VehicleLatestStatus.SDCardStatus   = ISNULL(dbo.VehicleLatestStatusTemp.SDCardStatus, dbo.VehicleLatestStatus.SDCardStatus),
	dbo.VehicleLatestStatus.Firmware       = ISNULL(dbo.VehicleLatestStatusTemp.Firmware, dbo.VehicleLatestStatus.Firmware),
	dbo.VehicleLatestStatus.LogNumber      = ISNULL(dbo.VehicleLatestStatusTemp.LogNumber, dbo.VehicleLatestStatus.LogNumber),
	
	dbo.VehicleLatestStatus.UnitTime	   = dbo.VehicleLatestStatusTemp.UnitTime,
	dbo.VehicleLatestStatus.LastOperation  = GETDATE()
FROM dbo.VehicleLatestStatus, dbo.VehicleLatestStatusTemp
WHERE dbo.VehicleLatestStatus.VehicleIntId = dbo.VehicleLatestStatusTemp.VehicleIntId
	AND VehicleLatestStatusTemp.Archived = 0
	
-- insert any rows that don't already exist
INSERT INTO dbo.VehicleLatestStatus
        ( VehicleIntId ,
          UnitTime ,
          EcospeedStatus ,
          SDCardStatus ,
          Firmware ,
          LogNumber ,
          LastOperation ,
          Archived
        )
SELECT	  VehicleIntId ,
          UnitTime ,
          EcospeedStatus ,
          SDCardStatus ,
          Firmware ,
          LogNumber ,
          GETDATE(),
          0
FROM	dbo.VehicleLatestStatusTemp vlst
WHERE NOT EXISTS 
	(SELECT vls.VehicleIntId
	FROM dbo.VehicleLatestStatus vls
	WHERE vls.VehicleIntId = vlst.VehicleIntId)



GO
