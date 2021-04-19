SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ============================================================
-- Author:		Graham Pattison
-- Create date: 02/03/2011
-- Description:	Process rows from TAN_NotificationPending table
-- ============================================================
CREATE PROCEDURE [dbo].[proc_SI_ProcessVehicleCommands]
AS

-- First of all check whether or not this process is still running
-- by trying to create a temprary table
SELECT MyVar = 5 INTO #SI_Process_VehicleCommands

IF @@ERROR <> 0
BEGIN
	-- do nothing!
	SELECT 0
END ELSE
BEGIN

	-- Step 1: Set ProcessInd = 0 where NULL
	UPDATE dbo.VehicleCommand
	SET ProcessInd = 0
	WHERE ProcessInd IS NULL

	-- Step 2:

	-- 2a - expired commands
	UPDATE dbo.VehicleLatestEvent
	SET AnalogIoAlertTypeId = 23
	WHERE VehicleId IN (
						SELECT v.VehicleId
						FROM dbo.VehicleCommand vc
						INNER JOIN dbo.Vehicle v ON vc.IVHId = v.IVHId
						WHERE vc.ProcessInd = 0
						  AND CAST(vc.Command AS VARCHAR(MAX)) LIKE '>STCXAT+ENGI=%'
						  AND vc.AcknowledgedDate IS NULL
						  AND vc.ExpiryDate < GETDATE()
						)
	  
	-- 2b - acknowledged but no confirmation
	UPDATE dbo.VehicleLatestEvent
	SET AnalogIoAlertTypeId = 23
	WHERE VehicleId IN (
						SELECT v.VehicleId
						FROM dbo.VehicleCommand vc
						INNER JOIN dbo.Vehicle v ON vc.IVHId = v.IVHId
						LEFT JOIN dbo.EventData ed ON v.VehicleIntId = ed.VehicleIntId 
														AND ed.EventDataName = 'RES' 
														AND ed.EventDateTime > DATEADD(hh, -1, GETUTCDATE())
														AND ed.EventDataString LIKE 'ENGI%'
						WHERE vc.ProcessInd = 0
						  AND CAST(vc.Command AS VARCHAR(MAX)) LIKE '>STCXAT+ENGI=%'
						  AND vc.AcknowledgedDate < DATEADD(hh, -1, GETDATE())
						  AND ed.EventDataId IS NULL -- No eventdata row exists
						)
	  
	-- Step 3: Set ProcessInd = 1 where 0 AND Acknowledgedate < DATEADD(hh, -1, GETDATE())
	UPDATE dbo.VehicleCommand
	SET ProcessInd = 1
	WHERE ProcessInd = 0
	  AND (AcknowledgedDate IS NULL AND ExpiryDate < GETDATE() -- Expired
	   OR AcknowledgedDate < DATEADD(hh, -1, GETDATE())) -- Acknowledged more than 1 hour ago

	-- Delete temporary table to indicate job has completed
	DROP TABLE #SI_Process_VehicleCommands

END
GO
