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
CREATE PROCEDURE [dbo].[proc_CFG_ProcessCFG_DSW]
AS

-- First of all check whether or not this process is still running
-- by trying to create a temprary table
SELECT MyVar = 5 INTO #CFG_ProcessCFGDSW

IF @@ERROR <> 0
BEGIN
	-- do nothing!
	SELECT 0
END ELSE

BEGIN

	SET NOCOUNT ON
	
	DECLARE @vid UNIQUEIDENTIFIER

	-- Mark rows as 'In Process' in CFG_DSW_Vehicle table
	UPDATE dbo.CFG_DSW_Vehicle
	SET ProcessInd = 1
	WHERE ProcessInd = 0

	-- Use a cursor to process each row in turn
	DECLARE TCursor CURSOR FAST_FORWARD READ_ONLY
	FOR
	
	SELECT DISTINCT VehicleId
	FROM dbo.CFG_DSW_Vehicle
	WHERE ProcessInd = 1
	
	OPEN TCursor
	FETCH NEXT FROM TCursor INTO @vid
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
		-- Execute the stored proc to re-apply the configs
--		IF @vid IN (N'2682E712-C15D-4C12-9C84-84601446E3F6') -- list candidate vehicles here until ready to go to full rollout
		EXEC dbo.proc_CFG_ReapplyConfig @vid
		
		FETCH NEXT FROM TCursor INTO @vid
	END
	
	CLOSE TCursor
	DEALLOCATE TCursor	
	
	UPDATE dbo.CFG_DSW_Vehicle
	SET ProcessInd = 2
	WHERE ProcessInd = 1
	
	-- Delete temporary table to indicate job has completed
	DROP TABLE #CFG_ProcessCFGDSW

END
GO
