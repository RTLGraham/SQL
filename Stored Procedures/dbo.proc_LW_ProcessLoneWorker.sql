SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[proc_LW_ProcessLoneWorker] 
AS
BEGIN	

	DECLARE @now DATETIME
	SET @now = GETUTCDATE()

	-- Insert into TAN_TriggerEvent to trigger alarm
	INSERT INTO dbo.TAN_TriggerEvent (TriggerEventId, CreationCodeId, EventId, CustomerIntId, VehicleIntID, DriverIntId, ApplicationId, Long, Lat, Speed, DataString, DataInt, TriggerDateTime, ProcessInd, LastOperation, GeofenceId)
	SELECT NEWID(), 141, 0, c.CustomerIntId, NULL, d.DriverIntId, 9, lw.Lon, lw.Lat, lw.Speed, 'Timer expired' + ISNULL('|' + lw.AddtlData, ''), lw.LoneWorkerId, @now, 0, GETDATE(), NULL
	FROM dbo.LW_LoneWorker lw
	INNER JOIN dbo.Driver d ON d.DriverId = lw.DriverId
	INNER JOIN dbo.CustomerDriver cd ON cd.DriverId = d.DriverId
	INNER JOIN dbo.Customer c ON c.CustomerId = cd.CustomerId
	WHERE DATEADD(MINUTE, lw.Duration, lw.StartTime) < @now
	  AND lw.StopTime IS NULL 
	  AND lw.AlarmTriggeredDateTime IS NULL
	  AND cd.Archived = 0
	  AND cd.EndDate IS NULL	
	  AND c.Archived = 0

	-- In parallel, insert into TAN_TriggerEvent to generate escalation level 1 and 2 triggers. These will fire if not acknowledged before the trigger delay time is reached
	-- Escalation 1
	INSERT INTO dbo.TAN_TriggerEvent (TriggerEventId, CreationCodeId, EventId, CustomerIntId, VehicleIntID, DriverIntId, ApplicationId, Long, Lat, Speed, DataString, DataInt, TriggerDateTime, ProcessInd, LastOperation, GeofenceId)
	SELECT NEWID(), 145, 0, c.CustomerIntId, NULL, d.DriverIntId, 9, lw.Lon, lw.Lat, lw.Speed, 'Escalation level 1 delay expired' + ISNULL('|' + lw.AddtlData, ''), lw.LoneWorkerId, @now, 0, GETDATE(), NULL
	FROM dbo.LW_LoneWorker lw
	INNER JOIN dbo.Driver d ON d.DriverId = lw.DriverId
	INNER JOIN dbo.CustomerDriver cd ON cd.DriverId = d.DriverId
	INNER JOIN dbo.Customer c ON c.CustomerId = cd.CustomerId
	WHERE DATEADD(MINUTE, lw.Duration, lw.StartTime) < @now
	  AND lw.StopTime IS NULL 
	  AND lw.AlarmTriggeredDateTime IS NULL
	  AND cd.Archived = 0
	  AND cd.EndDate IS NULL	
	  AND c.Archived = 0

	-- Insert into TAN_TriggerEvent to trigger alarm
	INSERT INTO dbo.TAN_TriggerEvent (TriggerEventId, CreationCodeId, EventId, CustomerIntId, VehicleIntID, DriverIntId, ApplicationId, Long, Lat, Speed, DataString, DataInt, TriggerDateTime, ProcessInd, LastOperation, GeofenceId)
	SELECT NEWID(), 146, 0, c.CustomerIntId, NULL, d.DriverIntId, 9, lw.Lon, lw.Lat, lw.Speed, 'Escalation level 2 delay expired' + ISNULL('|' + lw.AddtlData, ''), lw.LoneWorkerId, @now, 0, GETDATE(), NULL
	FROM dbo.LW_LoneWorker lw
	INNER JOIN dbo.Driver d ON d.DriverId = lw.DriverId
	INNER JOIN dbo.CustomerDriver cd ON cd.DriverId = d.DriverId
	INNER JOIN dbo.Customer c ON c.CustomerId = cd.CustomerId
	WHERE DATEADD(MINUTE, lw.Duration, lw.StartTime) < @now
	  AND lw.StopTime IS NULL 
	  AND lw.AlarmTriggeredDateTime IS NULL
	  AND cd.Archived = 0
	  AND cd.EndDate IS NULL	
	  AND c.Archived = 0

	-- Update rows to identify which Lone Worker records have been alarmed
	UPDATE dbo.LW_LoneWorker
	SET AlarmTriggeredDateTime = @now
	FROM dbo.LW_LoneWorker lw
	INNER JOIN dbo.Driver d ON d.DriverId = lw.DriverId
	INNER JOIN dbo.CustomerDriver cd ON cd.DriverId = d.DriverId
	INNER JOIN dbo.Customer c ON c.CustomerId = cd.CustomerId
	WHERE DATEADD(MINUTE, lw.Duration, lw.StartTime) < @now
	  AND lw.StopTime IS NULL 
	  AND lw.AlarmTriggeredDateTime IS NULL
	  AND cd.Archived = 0
	  AND cd.EndDate IS NULL	
	  AND c.Archived = 0

END	
GO
