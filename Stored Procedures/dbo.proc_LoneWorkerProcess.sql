SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_LoneWorkerProcess] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @DriverID uniqueidentifier
	Declare @VehicleID uniqueidentifier
	
	-- Mark Lone Worker Mode ON as processed
	UPDATE dbo.LoneWorkingEventData SET Archived = 1 WHERE EventDataName = 'LW1'

	-- Insert New Lone Worker records to LoneWorker table
	INSERT INTO dbo.LoneWorking
	        ( CustomerIntId ,
	          DriverId ,
	          VehicleId ,
	          LoneWorkingStart
	        )
	SELECT  CustomerIntId,
			dbo.GetDriverIdFromInt(DriverIntId),
			dbo.GetVehicleIdFromInt(VehicleIntId),
			EventDateTime as LoneWorkingStart
	FROM dbo.LoneWorkingEventData
	WHERE Archived = 1 AND EventDataName = 'LW1' 
	
	-- Insert New Lone Worker Event into the TAN system
	INSERT INTO dbo.TAN_TriggerEvent
	        ( TriggerEventId ,
	          CreationCodeId ,
	          EventId ,
	          CustomerIntId ,
	          VehicleIntID ,
	          DriverIntId ,
	          ApplicationId ,
	          Long ,
	          Lat ,
	          DataName ,
	          DataInt ,
	          TriggerDateTime ,
	          ProcessInd ,
	          LastOperation
	        )
	SELECT NEWID(), 125, lwed.EventId, lwed.CustomerIntId, lwed.VehicleIntId, lwed.DriverIntId, 2, e.Long, e.Lat, lwed.EventDataName, lw.LoneWorkingId, lwed.EventDateTime, 0, GETUTCDATE()
	FROM LoneWorkingEventData lwed
	INNER JOIN dbo.Event e ON lwed.EventId = e.EventId
	INNER JOIN dbo.LoneWorking lw ON lwed.DriverIntId = dbo.GetDriverIntFromId(lw.DriverId) AND lwed.VehicleIntId = dbo.GetVehicleIntFromId(lw.VehicleId) AND lw.LoneWorkingStart = lwed.EventDateTime
	WHERE lwed.Archived = 1 AND lwed.EventDataName = 'LW1' 

	-- Mark Lone Worker Mode OFF as processed
	UPDATE LoneWorkingEventData SET Archived = 1 WHERE EventDataName = 'LW0'

	-- Cancel any outstanding notifications in TAN where Lone Working is ending
	UPDATE dbo.TAN_TriggerEvent
	SET ProcessInd = 4 -- Cancel Notification
	FROM dbo.LoneWorkingEventData lwed
	INNER JOIN dbo.LoneWorking lw ON lwed.VehicleIntId = dbo.GetVehicleIntFromId(lw.VehicleId) AND lwed.DriverIntId = dbo.GetDriverIntFromId(lw.DriverId)
	INNER JOIN dbo.TAN_TriggerEvent te ON lwed.VehicleIntId = te.VehicleIntId AND lwed.DriverIntId = te.DriverIntId AND lw.LoneWorkingId = te.DataInt
	WHERE lwed.Archived = 1 AND lwed.EventDataName = 'LW0'
	  AND lw.LoneWorkingEnd IS NULL
	  AND lwed.EventDateTime > lw.LoneWorkingStart
	  AND te.ProcessInd < 3 
	  
	-- Identify matching Driver where Lone Worker mode ending and mark as ended
	UPDATE LoneWorking
	SET LoneWorkingEnd = lwed.EventDateTime
	FROM LoneWorkingEventData lwed
	INNER JOIN dbo.LoneWorking lw ON lwed.VehicleIntId = dbo.GetVehicleIntFromId(lw.VehicleId) AND lwed.DriverIntId = dbo.GetDriverIntFromId(lw.DriverId)
	WHERE lwed.Archived = 1 AND lwed.EventDataName = 'LW0' 
	  AND lw.LoneWorkingEnd IS NULL
	  AND lwed.EventDateTime > lw.LoneWorkingStart

-- This code moved into the TAN system
--	UPDATE LoneWorking
--	SET AlarmTriggeredDateTime = ten.LatestTriggerDateTime
--	FROM LoneWorking lw
--	INNER JOIN dbo.TAN_TriggerEntity ten ON lw.VehicleId = ten.TriggerEntityId
--	INNER JOIN dbo.TAN_Trigger t ON ten.TriggerId = t.TriggerId AND t.TriggerTypeId = 20 -- Lone Worker	
--		WHERE lw.LoneWorkingEnd IS NULL
--		  AND lw.AlarmTriggeredDateTime IS NULL
--		  AND ten.LatestTriggerDateTime > lw.LoneWorkingStart
--		  AND t.Disabled = 0 AND t.Archived = 0
		  
	-- Delete all Archived Rows
	DELETE FROM dbo.LoneWorkingEventData
	WHERE Archived = 1

END

GO
