SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ==========================================================================================
-- Author:		Graham Pattison
-- Create date: 15/06/2017
-- Description:	Process data from TAN_GeofenceVehicleEvent table which is populated in
--				TAN_Process_Events. This process parallelises the TAN processing in order
--				to improve performance
-- ==========================================================================================
CREATE PROCEDURE [dbo].[proc_TAN_VehicleGeofenceHistory]
AS
		
	DECLARE @EventId BIGINT, 
			@CustomerIntId INT,
			@VehicleIntID INT, 
			@DriverIntId INT, 
			@Lat FLOAT,
			@Long FLOAT,
			@Heading SMALLINT,
			@Speed SMALLINT,
			@EventDateTime DATETIME, 
			@GeofenceId UNIQUEIDENTIFIER, 
			@GeoCount INT,
			@Result INT	
			
	DECLARE @InGeo TABLE (
			GeofenceId UNIQUEIDENTIFIER )

	DECLARE @GeoHistory TABLE (
			VehicleGeofenceHistoryId BIGINT,
			GeofenceId UNIQUEIDENTIFIER )	
	
	-- Process Geofence Section
	--=========================
	
	-- Mark newly inserted rows as in process
	UPDATE dbo.TAN_GeofenceVehicleEvent
	SET ProcessInd = 1
	WHERE ProcessInd = 0

	-- Use a cursor to process each event in turn and determine which entry / exit points to record
	DECLARE TCursor CURSOR FAST_FORWARD READ_ONLY
	FOR
	
	SELECT DISTINCT EventId, EventDateTime, VehicleIntID, DriverIntId, dbo.GetCustomerIntFromId(CustomerId), Lat, Long, Heading, Speed
	FROM dbo.TAN_GeofenceVehicleEvent
	WHERE ProcessInd = 1
	ORDER BY VehicleIntID, EventDateTime 
	
	OPEN TCursor
	FETCH NEXT FROM TCursor INTO @EventId, @EventDateTime, @VehicleIntID, @DriverIntId, @CustomerIntId, @Lat, @Long, @Heading, @Speed
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
		-- Identify any currently open history records for this vehicle
		DELETE FROM @GeoHistory
		INSERT INTO @GeoHistory (VehicleGeofenceHistoryId, GeofenceId)
		SELECT VehicleGeofenceHistoryId, GeofenceId
		FROM dbo.VehicleGeofenceHistory
		WHERE VehicleIntId = @VehicleIntID
		  AND ExitDateTime IS NULL
		  
		-- Identify all the geofences this vehicle is currently in 
		DELETE FROM @InGeo
		INSERT INTO @InGeo (GeofenceId)
		SELECT GeofenceId
		FROM dbo.TAN_GeofenceVehicleEvent
		WHERE ProcessInd = 1
		  AND VehicleIntID = @VehicleIntID
		  AND EventId = @EventId
		
		-- Process Geofences we are no longer in
		
		-- A. Close open history records 
		UPDATE dbo.VehicleGeofenceHistory
		SET ExitEventId = @EventId, ExitDateTime = @EventDateTime, ExitDriverIntId = @DriverIntId, LastOperation = GETDATE()
		FROM dbo.VehicleGeofenceHistory vgh
		INNER JOIN @GeoHistory gh ON gh.VehicleGeofenceHistoryId = vgh.VehicleGeofenceHistoryId
		LEFT JOIN @InGeo ig ON gh.GeofenceId = ig.GeofenceId
		WHERE ig.GeofenceId IS NULL
		
		-- B. Cancel any Delay triggers
		UPDATE dbo.TAN_TriggerEvent
		SET ProcessInd = 4 -- Cancelled Notification
		FROM dbo.TAN_TriggerEvent te
		INNER JOIN dbo.VehicleGeofenceHistory vgh ON te.GeofenceId = vgh.GeofenceId
		INNER JOIN @GeoHistory gh ON gh.VehicleGeofenceHistoryId = vgh.VehicleGeofenceHistoryId
		LEFT JOIN @InGeo ig ON gh.GeofenceId = ig.GeofenceId
		WHERE ig.GeofenceId IS NULL		
		  AND te.CreationCodeId = 126
		  AND te.VehicleIntID = @VehicleIntId
		  AND te.ProcessInd < 3
		
		-- C. Create exit geofence triggers
		INSERT INTO dbo.TAN_TriggerEvent (TriggerEventId, CreationCodeId, EventId, CustomerIntId, VehicleIntID, DriverIntId, ApplicationId, Long, Lat, Heading, Speed, TriggerDateTime, GeofenceId)
		SELECT NEWID(), 128, @EventId, @CustomerIntId, @VehicleIntId, @DriverIntId, 5, @Long, @Lat, @Heading, @Speed, @EventDateTime, gh.GeofenceId
		FROM dbo.VehicleGeofenceHistory vgh
		INNER JOIN @GeoHistory gh ON gh.VehicleGeofenceHistoryId = vgh.VehicleGeofenceHistoryId
		LEFT JOIN @InGeo ig ON gh.GeofenceId = ig.GeofenceId
		WHERE ig.GeofenceId IS NULL
		
		-- Process Geofences we have just entered
		
		-- A. Create an open history row
		INSERT INTO dbo.VehicleGeofenceHistory (VehicleIntId, GeofenceId, EntryDateTime, EntryDriverIntId, EntryEventId)
		SELECT @VehicleIntId, ig.GeofenceId, @EventDateTime, @DriverIntId, @EventId
		FROM @InGeo ig
		LEFT JOIN @GeoHistory gh ON ig.GeofenceId = gh.GeofenceId
		WHERE ig.GeofenceId IS NOT NULL AND gh.GeofenceId IS NULL
		
		-- B. Create a TAN entry row
		INSERT INTO dbo.TAN_TriggerEvent (TriggerEventId, CreationCodeId, EventId, CustomerIntId, VehicleIntID, DriverIntId, ApplicationId, Long, Lat, Heading, Speed, TriggerDateTime, GeofenceId)
		SELECT NEWID(), 127, @EventId, @CustomerIntId, @VehicleIntId, @DriverIntId, 5, @Long, @Lat, @Heading, @Speed, @EventDateTime, ig.GeofenceId
		FROM @InGeo ig
		LEFT JOIN @GeoHistory gh ON ig.GeofenceId = gh.GeofenceId
		WHERE ig.GeofenceId IS NOT NULL AND gh.GeofenceId IS NULL

		-- C. Create a TAN delay row
		INSERT INTO dbo.TAN_TriggerEvent (TriggerEventId, CreationCodeId, EventId, CustomerIntId, VehicleIntID, DriverIntId, ApplicationId, Long, Lat, Heading, Speed, TriggerDateTime, GeofenceId)
		SELECT NEWID(), 126, @EventId, @CustomerIntId, @VehicleIntId, @DriverIntId, 5, @Long, @Lat, @Heading, @Speed, @EventDateTime, ig.GeofenceId
		FROM @InGeo ig
		LEFT JOIN @GeoHistory gh ON ig.GeofenceId = gh.GeofenceId
		WHERE ig.GeofenceId IS NOT NULL AND gh.GeofenceId IS NULL		
	
		FETCH NEXT FROM TCursor INTO @EventId, @EventDateTime, @VehicleIntID, @DriverIntId, @CustomerIntId, @Lat, @Long, @Heading, @Speed
	END
	
	CLOSE TCursor
	DEALLOCATE TCursor	
	
	-- Cleanup Processing tables
	DELETE 
	FROM dbo.TAN_GeofenceVehicleEvent
	WHERE ProcessInd = 1
GO
