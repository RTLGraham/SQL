SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ==========================================================================================
-- Author:		Graham Pattison
-- Create date: 06/01/2015
-- Description:	Processes data from the vehicleLatestAllEvent table to create TAN triggers.
--				This job should be scheduled to execute every 10 mins and will identify
--				vehicles that have not communicated for between 60 and 69 minutes.
--				Any outstanding bradycardia triggers are cancelled for vehicles that have 
--				communicated within the last 60 minutes.
--				The trigger setup will allow the customer to determine the bradycardia time
--				period, but must obviously be greater than 60 minutes 
-- ==========================================================================================
CREATE PROCEDURE [dbo].[proc_TAN_ProcessBradycardia]
AS

-- First of all check whether or not this process is still running
-- by trying to create a temprary table
SELECT MyVar = 5 INTO #TAN_ProcessBradycardia

IF @@ERROR <> 0
BEGIN
	-- do nothing!
	SELECT 0
END ELSE

BEGIN

	SET NOCOUNT ON
	
	-- Check VehicleLatestAllEvent to identify any vehicle that have not reported for at least one hour
	INSERT INTO dbo.TAN_TriggerEvent (TriggerEventId,CreationCodeId,CustomerIntId,VehicleIntID,DriverIntId,ApplicationId,TriggerDateTime,ProcessInd)
	SELECT NEWID(), 135, CustomerIntId, VehicleIntId, NULL, 6, EventDateTime, 0
	FROM dbo.VehicleLatestAllEvent vle
	INNER JOIN dbo.Vehicle v ON vle.VehicleId = v.VehicleId
	INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
	INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
	WHERE DATEDIFF(mi, EventDateTime, GETUTCDATE()) BETWEEN 60 AND 69
	  AND v.Archived = 0
	  AND v.IVHId IS NOT NULL
	  AND cv.Archived = 0
	  AND c.Archived = 0

	-- Now cancel any outstanding Bradycardia triggers for vehicles that have subsequently resumed communication
	UPDATE dbo.TAN_TriggerEvent
	SET ProcessInd = 4 -- Cancelled Notification
	FROM dbo.TAN_TriggerEvent te
	INNER JOIN dbo.Vehicle v ON te.VehicleIntID = v.VehicleIntId
	INNER JOIN dbo.VehicleLatestAllEvent vle ON v.VehicleId = vle.VehicleId
	INNER JOIN dbo.CustomerVehicle cv ON vle.VehicleId = cv.VehicleId
	INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
	WHERE DATEDIFF(mi, EventDateTime, GETUTCDATE()) < 60
	  AND v.Archived = 0
	  AND v.IVHId IS NOT NULL
	  AND cv.Archived = 0
	  AND c.Archived = 0
	  AND te.CreationCodeId = 135
	  AND te.ProcessInd < 3	
	
	-- Delete temporary table to indicate job has completed
	DROP TABLE #TAN_ProcessBradycardia

END


GO
