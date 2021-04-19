SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ==========================================================================================
-- Author:		Graham Pattison
-- Create date: 12/03/2013
-- Description:	Processes data from the EventCopy table to create event based TAN triggers.
--				Then performs GeoSpatial processing via Fleetwise6. The resulting data is 
--				then processed to generate geofence history and TAN related geofence triggers
-- ==========================================================================================
CREATE PROCEDURE [dbo].[proc_TAN_ProcessAccums]
AS

-- First of all check whether or not this process is still running
-- by trying to create a temprary table
SELECT MyVar = 5 INTO #TAN_ProcessAccums

IF @@ERROR <> 0
BEGIN
	-- do nothing!
	SELECT 0
END ELSE

BEGIN

	SET NOCOUNT ON

	-- Mark rows as 'In Process' in AccumCopy table
	UPDATE dbo.AccumCopy
	SET Archived = 1
	WHERE Archived = 0

	-- Add potential triggers based on accum data
	
	-- First CAN link down (where downtime more than half of total accum time)
	INSERT INTO dbo.TAN_TriggerEvent (TriggerEventId,CreationCodeId,CustomerIntId,VehicleIntID,DriverIntId,ApplicationId,TriggerDateTime,ProcessInd)
	SELECT NEWID(), 130, CustomerIntId, VehicleIntId, DriverIntId, 6, ClosureDateTime, 0
	FROM dbo.AccumCopy
	WHERE DataLinkDownTime > DATEDIFF(ss, CreationDateTime, ClosureDateTime) / 2 
	
	-- Cleanup Processing tables	
	DELETE
	FROM dbo.AccumCopy
	WHERE Archived = 1
	
	-- Delete temporary table to indicate job has completed
	DROP TABLE #TAN_ProcessAccums

END


GO
