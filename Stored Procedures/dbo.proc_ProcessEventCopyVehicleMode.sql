SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_ProcessEventCopyVehicleMode]
AS
	UPDATE dbo.EventCopyVehicleMode
	SET Archived = 1
	WHERE Archived = 0

	-- Clean up the EventCopyVehicleMode table to remove any events with an earlier date than currently known
	-- This will prevent previously sent duplicate data from affecting the vehicle mode history
	DELETE FROM dbo.EventCopyVehicleMode 
	FROM dbo.EventCopyVehicleMode ecvm
	INNER JOIN dbo.VehicleModeActivity vma ON ecvm.VehicleIntId = vma.VehicleIntId AND vma.EndDate IS NULL
	WHERE ecvm.Archived = 1
	  AND ecvm.EventDateTime < ISNULL(vma.LatestEventDateTime, vma.StartDate)

	-- Now proceed to process the remaining data
	-- Within vehicle, use row numbers to partition the data into modes in time order
	-- Insert this data into temporary table #Partitions
	SELECT  e.VehicleIntID, e.EventDateTime, e.DriverIntId, e.EventId, e.Lat, e.Long, vm.VehicleModeID,
			ROW_NUMBER() OVER (ORDER BY e.VehicleIntID, e.EventDateTime) AS RowNumTime,
			ROW_NUMBER() OVER (PARTITION BY e.VehicleIntID, vm.VehicleModeID ORDER BY e.VehicleIntID, e.EventDateTime) AS RowNumMode
	INTO    #Partitions
	FROM    dbo.EventCopyVehicleMode e
	  INNER JOIN dbo.VehicleModeCreationCode mcc ON e.CreationCodeId = mcc.CreationCodeId
	  INNER JOIN dbo.VehicleMode vm ON mcc.VehicleModeId = vm.VehicleModeID
	WHERE e.Archived = 1    
	  AND vm.VehicleModeID != 0;
	
	-- Now use the #Partition data to determine the start time for each mode transition
	-- Insert this data into temporary table #Bands	
	SELECT  VehicleIntID, VehicleModeID, 
			MIN(EventDateTime) AS StartDate,
			MIN(DriverIntId) AS DriverIntId, 
			MIN(EventId) AS EventId,
			MIN(Lat) AS Lat,
			MIN(Long) AS Long,
			ROW_NUMBER() OVER (PARTITION BY VehicleIntID ORDER BY MIN(EventDateTime)) AS RowNumber
	INTO    #Bands
	FROM    #Partitions
	GROUP BY VehicleIntID, RowNumTime - RowNumMode, VehicleModeID;

	-- If mode unchanged since last activity in VehicleModeActivity table then just update the LatestEventDateTime and leave row 'open'
	UPDATE dbo.VehicleModeActivity
	SET LatestEventDateTime = b.StartDate
	FROM #Bands b
	INNER JOIN dbo.VehicleModeActivity vma ON b.VehicleIntID = vma.VehicleIntId AND b.VehicleModeID = vma.VehicleModeId AND vma.EndDate IS NULL AND b.RowNumber = 1

	-- Now remove these processed rows from the #Bands table    
	DELETE
	FROM #Bands
	FROM #Bands b
	INNER JOIN dbo.VehicleModeActivity vma ON b.VehicleIntID = vma.VehicleIntId AND b.VehicleModeID = vma.VehicleModeId AND vma.EndDate IS NULL
	WHERE b.RowNumber = 1 

	-- Update open VehicleModeActivity rows with startdate of first mode
	-- However, if the open row is an Idle then check for an elapsed time >5 mins (this indicates a problem e.g. Master Off)
	-- In this case close the open row at latest known event (or StartDate + 3 mins if not known)
	UPDATE dbo.VehicleModeActivity
	SET EndDate = CASE WHEN VehicleModeId = 2 AND DATEDIFF(SECOND, ISNULL(vma.LatestEventDateTime, vma.StartDate), b.StartDate) > 300 THEN ISNULL(vma.LatestEventDateTime, DATEADD(MINUTE, 3,  vma.StartDate)) ELSE b.StartDate END, 
		EndDriverIntId = b.DriverIntId, EndEventId = b.EventId, EndLat = b.Lat, EndLon = b.Long
	FROM (SELECT VehicleIntID, MIN(StartDate) AS StartDate, MIN(DriverIntId) AS DriverIntId, MIN(EventId) AS EventId, MIN(Lat) AS Lat, MIN(Long) AS Long
			FROM #Bands
			GROUP BY VehicleIntID) b
	INNER JOIN dbo.VehicleModeActivity vma ON b.VehicleIntID = vma.VehicleIntId AND vma.EndDate IS NULL

	SELECT    B.VehicleIntID, 
			  B.VehicleModeID, 
			  B.StartDate, 
			  B.DriverIntId AS StartDriverIntId, 
			  B.EventId AS StartEventId,
			  B.Lat AS StartLat,
			  B.Long AS StartLon,
			  B2.StartDate AS EndDate,
			  B2.EventId AS EndEventId,
			  B2.Lat AS EndLat,
			  B2.Long AS EndLon, 
			  B2.DriverIntId AS EndDriverIntId
	INTO      #Results
	FROM      #Bands B
			LEFT OUTER JOIN #Bands B2 ON B2.RowNumber = B.RowNumber+1 AND B2.VehicleIntID = B.VehicleIntID

	INSERT INTO dbo.VehicleModeActivity
			( VehicleIntId,
			  VehicleModeId,
			  StartDate,
			  StartDriverIntId,
			  StartEventId,
			  StartLat,
			  StartLon,
			  EndDate,
			  EndEventId,
			  EndLat,
			  EndLon,
			  EndDriverIntId,
			  LatestEventDateTime
			)
	SELECT VehicleIntId,
           VehicleModeID,
           StartDate,
           StartDriverIntId,
           StartEventId,
           StartLat,
           StartLon,
           EndDate,
           EndEventId,
           EndLat,
           EndLon,
           EndDriverIntId,
		   StartDate
	FROM #Results

	-- Clean Up temporary Tables
	DROP TABLE #Results;
	DROP TABLE #Bands;
	DROP TABLE #Partitions;
          
	-- Clean Up Processed Rows
	DELETE
	FROM dbo.EventCopyVehicleMode
	WHERE Archived = 1


GO
