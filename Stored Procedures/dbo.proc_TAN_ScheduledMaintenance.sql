SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ==================================================================================
-- Author:		Graham Pattison
-- Create date: 28/01/2015
-- Description:	Run once daily to identify vehicles approaching scheduled maintenance
-- ==================================================================================
CREATE PROCEDURE [dbo].[proc_TAN_ScheduledMaintenance]
AS

BEGIN
	INSERT INTO dbo.TAN_TriggerEvent
			( TriggerEventId,
			  CreationCodeId,
			  CustomerIntId,
			  VehicleIntID,
			  ApplicationId,
			  TripDistance,
			  DataString,
			  TriggerDateTime,
			  ProcessInd,
			  LastOperation
			)
	SELECT  NEWID(),
			136,
			c.CustomerIntId,
			V.VehicleIntID,
			6,
			E.OdoGPS,
			vmt.Name,
			dbo.GetNextScheduledMaintenanceDate(S.DistanceInterval,S.TimeInterval,S.TimeIntervalWeeks,S.FuelInterval,S.EngineInterval,E.OdoGPS,t.TotalVehicleFuel,t.TotalEngineHours,S.DateOfLastMaintenance,S.OdoAtLastMaintenance,S.FuelAtLastMaintenance,S.EngineAtLastMaintenance),
			0,
			GETDATE()
	FROM    dbo.Vehicle V
			INNER JOIN (
				SELECT vms.VehicleIntID, a.TotalEngineHours, a.TotalVehicleFuel, ROW_NUMBER() OVER(PARTITION BY vms.VehicleIntID ORDER BY vms.VehicleIntID, a.AccumId DESC) AS RowNum
				FROM dbo.Accum a
				INNER JOIN dbo.VehicleMaintenanceSchedule vms ON a.VehicleIntId = vms.VehicleIntID
				WHERE a.CreationDateTime > DATEADD(dd, -7, GETDATE())
			) t ON V.VehicleIntId = t.VehicleIntID AND t.RowNum = 1
			INNER JOIN dbo.VehicleLatestEvent E ON E.VehicleID = V.VehicleID
			INNER JOIN dbo.VehicleMaintenanceSchedule S ON S.VehicleIntID = V.VehicleIntID
			INNER JOIN dbo.CustomerVehicle cv ON V.VehicleId = cv.VehicleId
			INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
			INNER JOIN dbo.VehicleMaintenanceType vmt ON S.VehicleMaintenanceTypeID = vmt.VehicleMaintenanceTypeID
	WHERE	DATEDIFF(dd, GETDATE(), dbo.GetNextScheduledMaintenanceDate(S.DistanceInterval,S.TimeInterval,S.TimeIntervalWeeks,S.FuelInterval,S.EngineInterval,E.OdoGPS,t.TotalVehicleFuel,t.TotalEngineHours,S.DateOfLastMaintenance,S.OdoAtLastMaintenance,S.FuelAtLastMaintenance,S.EngineAtLastMaintenance)) <= S.ReminderDays
	  AND	DATEADD(dd, S.ReminderDays, ISNULL(S.LastReminderDate, '2016-01-01 00:00')) < GETDATE()
	  AND	cv.Archived = 0
	ORDER BY  V.Registration, S.VehicleMaintenanceTypeID

	-- Now update the VehicleMaintenanceSchedule to reflect the reminders just sent
	UPDATE dbo.VehicleMaintenanceSchedule
	SET LastReminderDate = GETDATE()
	FROM    dbo.Vehicle V
			INNER JOIN (
				SELECT vms.VehicleIntID, a.TotalEngineHours, a.TotalVehicleFuel, ROW_NUMBER() OVER(PARTITION BY vms.VehicleIntID ORDER BY vms.VehicleIntID, a.AccumId DESC) AS RowNum
				FROM dbo.Accum a
				INNER JOIN dbo.VehicleMaintenanceSchedule vms ON a.VehicleIntId = vms.VehicleIntID
				WHERE a.CreationDateTime > DATEADD(dd, -7, GETDATE())
			) t ON V.VehicleIntId = t.VehicleIntID AND t.RowNum = 1
			INNER JOIN dbo.VehicleLatestEvent E ON E.VehicleID = V.VehicleID
			INNER JOIN dbo.VehicleMaintenanceSchedule S ON S.VehicleIntID = V.VehicleIntID
			INNER JOIN dbo.CustomerVehicle cv ON V.VehicleId = cv.VehicleId
			INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
			INNER JOIN dbo.VehicleMaintenanceType vmt ON S.VehicleMaintenanceTypeID = vmt.VehicleMaintenanceTypeID
	WHERE	DATEDIFF(dd, GETDATE(), dbo.GetNextScheduledMaintenanceDate(S.DistanceInterval,S.TimeInterval,S.TimeIntervalWeeks,S.FuelInterval,S.EngineInterval,E.OdoGPS,t.TotalVehicleFuel,t.TotalEngineHours,S.DateOfLastMaintenance,S.OdoAtLastMaintenance,S.FuelAtLastMaintenance,S.EngineAtLastMaintenance)) <= S.ReminderDays
	  AND	DATEADD(dd, S.ReminderDays, ISNULL(S.LastReminderDate, '2016-01-01 00:00')) < GETDATE()
	  AND	cv.Archived = 0

END


GO
