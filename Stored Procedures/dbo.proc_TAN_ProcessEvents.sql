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
-- 15/06/2017:  Removed processing of TAN_VehicleGeofenceHistory table and created new 
--				paralleised process for it: proc_TAN_VehicleGeofenceHistory
-- ==========================================================================================
CREATE PROCEDURE [dbo].[proc_TAN_ProcessEvents]
AS

BEGIN

	SET NOCOUNT ON

	DECLARE @EventId BIGINT, 
			@CustomerIntId INT,
			@VehicleIntID INT, 
			@DriverIntId INT, 
			@EventDateTime DATETIME, 
			@GeofenceId UNIQUEIDENTIFIER, 
			@GeoCount INT,
			@Result INT

	-- Mark rows as 'In Process' in EventCopy table
	UPDATE dbo.EventCopy
	SET Archived = 1
	WHERE Archived = 0

	-- Copy data to be processed from EventCopy to TAN_EventCopy to keep EventCopy table free from process locks in case of large bulk data inserts
	-- Data copied has Archived = 1 and non-zero Lat and Long
	INSERT INTO dbo.TAN_EventCopy (EventId,VehicleIntId,DriverIntId,CreationCodeId,Long,Lat,Heading,Speed,OdoGPS,OdoRoadSpeed,OdoDashboard,EventDateTime,DigitalIO,CustomerIntId,AnalogData0,AnalogData1,AnalogData2,AnalogData3,AnalogData4,AnalogData5,SeqNumber,SpeedLimit,LastOperation,Archived,Altitude,GPSSatelliteCount,GPRSSignalStrength,SystemStatus,BatteryChargeLevel,ExternalInputVoltage,MaxSpeed,TripDistance,TachoStatus,CANStatus,FuelLevel,HardwareStatus,ADBlueLevel)
	SELECT EventId,VehicleIntId,DriverIntId,CreationCodeId,Long,Lat,Heading,Speed,OdoGPS,OdoRoadSpeed,OdoDashboard,EventDateTime,DigitalIO,CustomerIntId,AnalogData0,AnalogData1,AnalogData2,AnalogData3,AnalogData4,AnalogData5,SeqNumber,SpeedLimit,LastOperation,Archived,Altitude,GPSSatelliteCount,GPRSSignalStrength,SystemStatus,BatteryChargeLevel,ExternalInputVoltage,MaxSpeed,TripDistance,TachoStatus,CANStatus,FuelLevel,HardwareStatus,ADBlueLevel
	FROM dbo.EventCopy
	WHERE Archived = 1
	  AND Lat != 0 AND Long != 0

	-- Now remove data from EventCopy table
	DELETE
	FROM dbo.EventCopy
	WHERE Archived = 1

	-- Now perform GeoSpatial processing to populate table TAN_GeofenceEvent 
	DECLARE @GeoCheck TABLE (
		VehicleIntId INT,
		InGeofence BIT,
		DriverIntId INT,
		Lat FLOAT,
		Long FLOAT,
		Heading SMALLINT,
		Speed SMALLINT,
		EventId BIGINT,
		EventDateTime DATETIME,
		CustomerId UNIQUEIDENTIFIER )
		
	INSERT INTO @GeoCheck ( VehicleIntId, InGeofence, DriverIntId, Lat, Long, Heading, Speed, EventId, EventDateTime, c.CustomerId)
	SELECT ec.VehicleIntId, CASE WHEN Inside.InGeofence IS NULL THEN 0 ELSE 1 END AS InGeofence, ec.DriverIntId, ec.Lat, ec.Long, ec.Heading, ec.Speed, ec.EventId, ec.EventDateTime, c.CustomerId
	FROM TAN_EventCopy ec
	INNER JOIN dbo.Customer c ON c.CustomerIntId = ec.CustomerIntId
	LEFT JOIN 
	(SELECT 1 AS InGeofence, ec.Lat, ec.Long, ec.EventId
	FROM dbo.TAN_EventCopy ec
	INNER JOIN dbo.Geofence g WITH(INDEX(SIndx_Geofence_TheGeom)) ON geometry::Point(ec.Long,ec.Lat, 4326).STWithin(g.the_geom) = 1 AND g.Archived = 0
	INNER JOIN dbo.[User] u ON u.UserId = g.CreationUserId
	INNER JOIN dbo.Customer c ON ec.CustomerIntId = c.CustomerIntId AND c.CustomerId = u.CustomerId) Inside ON Inside.EventId = ec.EventId

	INSERT INTO dbo.TAN_GeofenceEvent (EventId, CustomerId, VehicleIntID, DriverIntId, Lat, Long, Heading, Speed, EventDateTime, GeofenceId)
	SELECT t.EventId, t.CustomerId, t.VehicleIntId, t.DriverIntId, t.Lat, t.Long, t.Heading, t.Speed, t.EventDateTime, t.GeofenceId  
	FROM (
		-- Look up geofences for Events where vehicle is in a Geofence ONLY
		SELECT gc.VehicleIntId, g.GeofenceId, gc.DriverIntId, gc.EventId, gc.EventDateTime, gc.CustomerId, gc.Lat, gc.Long, gc.Heading, gc.Speed
		FROM @GeoCheck gc
		INNER JOIN dbo.[User] u on gc.CustomerId = u.CustomerID
		INNER JOIN dbo.Geofence g WITH(INDEX(SIndx_Geofence_TheGeom)) ON u.UserID = g.CreationUserId AND g.Archived = 0
			AND geometry::Point(gc.Long,gc.Lat, 4326).STWithin(g.the_geom) = 1
		WHERE gc.InGeofence = 1
		
		UNION
		
		-- Combine this with events where we know a vehicle is NOT in a geofence
		SELECT VehicleIntId, NULL AS geofenceId, DriverIntId, EventId, EventDateTime, CustomerId, Lat, Long, Heading, Speed
		FROM @GeoCheck
		WHERE InGeofence = 0
	) t
	ORDER BY VehicleIntId, EventDateTime

	-- Copy the new data into TAN_GeofenceVehicleEvent for parallel process of VehicleGeofenceHistory table
	INSERT INTO dbo.TAN_GeofenceVehicleEvent (EventId, CustomerId, VehicleIntID, DriverIntId, Lat, Long, Heading, Speed, EventDateTime, ProcessInd, LastOperation, GeofenceId)
	SELECT EventId, CustomerId, VehicleIntID, DriverIntId, Lat, Long, Heading, Speed, EventDateTime, 0, LastOperation, GeofenceId
	FROM dbo.TAN_GeofenceEvent

	-- Add potential triggers section
	--===============================
	
	-- Add any potential triggers for specific events
	INSERT INTO dbo.TAN_TriggerEvent (TriggerEventId, CreationCodeId, EventId, CustomerIntId, VehicleIntID, DriverIntId, ApplicationId, Long, Lat, Heading, Speed, TripDistance, TriggerDateTime, ProcessInd, GeofenceId)
	SELECT  NEWID(), ec.CreationCodeId, ec.EventId, CustomerIntId, ec.VehicleIntId, ec.DriverIntId, 5, ec.Long, ec.Lat, ec.Heading, ec.Speed, OdoGPS, ec.EventDateTime, 0, g.GeofenceId
	FROM dbo.TAN_EventCopy ec
	LEFT JOIN dbo.TAN_GeofenceEvent g ON ec.EventId = g.EventId
	WHERE ec.CreationCodeId IN (6, 7, 8, 9, 12, 13, 14, 15,				-- Digital Input activations/deactivations
							 111, 112, 113, 114, 115, 116, 117, 118,	-- Temperature Alerts 1-4
							 180, 181, 182, 183, 184, 185, 186, 187,	-- Temperature Alerts 5-8
							 39,										-- Overspeed
							 4, 5,										-- Key On, Key Off
							 84, 85,									-- External Power Disconnected, Connected
							 3,											-- Idling (Exception) - see below for main idling
							 42											-- Moving Without Ignition
	 -- Any creation codes processed here should complement the exclusion list in trig_TAN_EventData (trigger on EventData table)
		)
	
	-- Additionally add potential trigger for Driving with no ID
	INSERT INTO dbo.TAN_TriggerEvent (TriggerEventId, CreationCodeId, EventId, CustomerIntId, VehicleIntID, DriverIntId, ApplicationId, Long, Lat, Heading, Speed, TripDistance, TriggerDateTime, ProcessInd, GeofenceId)
	SELECT  NEWID(), 131, ec.EventId, CustomerIntId, ec.VehicleIntId, ec.DriverIntId, 5, ec.Long, ec.Lat, ec.Heading, ec.Speed, OdoGPS, ec.EventDateTime, 0, g.GeofenceId
	FROM dbo.TAN_EventCopy ec
	INNER JOIN dbo.VehicleModeCreationCode vmcc ON ec.CreationCodeId = vmcc.CreationCodeId
	LEFT JOIN dbo.Driver d ON ec.DriverIntId = d.DriverIntId  
	LEFT JOIN dbo.TAN_GeofenceEvent g ON ec.EventId = g.EventId
	INNER JOIN (SELECT ec.VehicleIntId, MIN(ec.EventId) AS EventId 
				FROM dbo.TAN_EventCopy ec
				INNER JOIN dbo.VehicleModeCreationCode vmcc ON ec.CreationCodeId = vmcc.CreationCodeId
				LEFT JOIN dbo.Driver d ON ec.DriverIntId = d.DriverIntId
				WHERE d.Number = 'No ID'
				  AND vmcc.VehicleModeId = 1 -- Drive
				GROUP BY ec.VehicleIntId
				) e1 ON ec.VehicleIntId = e1.VehicleIntId AND ec.EventId = e1.EventId -- this join to get the first event only from the events within the run period
	WHERE d.Number = 'No ID'
	  AND vmcc.VehicleModeId = 1 -- Drive
	  AND NOT EXISTS (SELECT 1 FROM dbo.TAN_TriggerEvent WHERE CreationCodeId = 131 AND VehicleIntID = ec.VehicleIntId AND ProcessInd < 3) -- don't insert if already exists
	
	-- Add events for Idling using CC = 133
	INSERT INTO dbo.TAN_TriggerEvent (TriggerEventId, CreationCodeId, EventId, CustomerIntId, VehicleIntID, DriverIntId, ApplicationId, Long, Lat, Heading, Speed, TripDistance, TriggerDateTime, ProcessInd, GeofenceId)
	SELECT NEWID(), 133, ec.EventId, CustomerIntId, ec.VehicleIntId, ec.DriverIntId, 5, ec.Long, ec.Lat, ec.Heading, ec.Speed, OdoGPS, ec.EventDateTime, 0, g.GeofenceId
	FROM dbo.TAN_EventCopy ec
	INNER JOIN dbo.VehicleModeCreationCode vmcc ON ec.CreationCodeId = vmcc.CreationCodeId
	LEFT JOIN dbo.TAN_GeofenceEvent g ON ec.EventId = g.EventId
	INNER JOIN (SELECT ec.VehicleIntId, MIN(ec.EventId) AS EventId 
				FROM dbo.TAN_EventCopy ec
				INNER JOIN dbo.VehicleModeCreationCode vmcc ON ec.CreationCodeId = vmcc.CreationCodeId
				WHERE vmcc.VehicleModeId = 2 -- Idle
				GROUP BY ec.VehicleIntId
				) e1 ON ec.VehicleIntId = e1.VehicleIntId AND ec.EventId = e1.EventId -- this join to get the first event only from the events within the run period
	WHERE vmcc.VehicleModeId = 2 -- Idle
	  AND NOT EXISTS (SELECT 1 FROM dbo.TAN_TriggerEvent WHERE CreationCodeId = 133 AND VehicleIntID = ec.VehicleIntId AND ProcessInd < 3) -- don't insert if already exists

	-- Add events for Key Off using CC = 134 (for Lone Worker stopped in conjunction with geofences)
	INSERT INTO dbo.TAN_TriggerEvent (TriggerEventId, CreationCodeId, EventId, CustomerIntId, VehicleIntID, DriverIntId, ApplicationId, Long, Lat, Heading, Speed, TripDistance, TriggerDateTime, ProcessInd, GeofenceId)
	SELECT NEWID(), 134, ec.EventId, CustomerIntId, ec.VehicleIntId, ec.DriverIntId, 5, ec.Long, ec.Lat, ec.Heading, ec.Speed, OdoGPS, ec.EventDateTime, 0, g.GeofenceId
	FROM dbo.TAN_EventCopy ec
	INNER JOIN dbo.VehicleModeCreationCode vmcc ON ec.CreationCodeId = vmcc.CreationCodeId
	LEFT JOIN dbo.TAN_GeofenceEvent g ON ec.EventId = g.EventId
	INNER JOIN (SELECT ec.VehicleIntId, MIN(ec.EventId) AS EventId 
				FROM dbo.TAN_EventCopy ec
				INNER JOIN dbo.VehicleModeCreationCode vmcc ON ec.CreationCodeId = vmcc.CreationCodeId
				WHERE vmcc.VehicleModeId = 4 -- KeyOff
				GROUP BY ec.VehicleIntId
				) e1 ON ec.VehicleIntId = e1.VehicleIntId AND ec.EventId = e1.EventId -- this join to get the first event only from the events within the run period
	WHERE vmcc.VehicleModeId = 4 -- KeyOff
	  AND NOT EXISTS (SELECT 1 FROM dbo.TAN_TriggerEvent WHERE CreationCodeId = 134 AND VehicleIntID = ec.VehicleIntId AND ProcessInd < 3) -- don't insert if already exists

	-- Add events for Driving with Camera Off using CC = 140
	INSERT INTO dbo.TAN_TriggerEvent (TriggerEventId, CreationCodeId, EventId, CustomerIntId, VehicleIntID, DriverIntId, ApplicationId, Long, Lat, Heading, Speed, TripDistance, TriggerDateTime, ProcessInd, GeofenceId)
	SELECT NEWID(), 140, ec.EventId, CustomerIntId, ec.VehicleIntId, ec.DriverIntId, 5, ec.Long, ec.Lat, ec.Heading, ec.Speed, OdoGPS, ec.EventDateTime, 0, g.GeofenceId
	FROM dbo.TAN_EventCopy ec
	INNER JOIN dbo.Vehicle v ON v.VehicleIntId = ec.VehicleIntId
	INNER JOIN dbo.VehicleCamera vc ON vc.VehicleId = v.VehicleId
	LEFT JOIN dbo.TAN_GeofenceEvent g ON ec.EventId = g.EventId
	INNER JOIN (SELECT ec.VehicleIntId, MIN(ec.EventId) AS EventId 
				FROM dbo.TAN_EventCopy ec
				INNER JOIN dbo.Vehicle v ON v.VehicleIntId = ec.VehicleIntId
				INNER JOIN dbo.VehicleCamera vc ON vc.VehicleId = v.VehicleId
				WHERE ec.DigitalIO & 8 = 0 -- Camera is off
				  AND ec.Speed > 40.2336 -- Speed > 25 mph
				  AND vc.Archived = 0
				  AND vc.EndDate IS NULL	
				GROUP BY ec.VehicleIntId
				) e1 ON ec.VehicleIntId = e1.VehicleIntId AND ec.EventId = e1.EventId -- this join to get the first event only from the events within the run period
	WHERE ec.DigitalIO & 8 = 0 -- Camera is off
	  AND ec.Speed > 40.2336 -- Speed > 25 mph
	  AND vc.Archived = 0
	  AND vc.EndDate IS NULL	
	  AND NOT EXISTS (SELECT 1 FROM dbo.TAN_TriggerEvent WHERE CreationCodeId = 140 AND VehicleIntID = ec.VehicleIntId AND ProcessInd < 3) -- don't insert if already exists

	-- Cancel Triggers Section
	--========================

	-- Cancel any outstanding Driving Without ID Triggers if a Driving With ID or a Key Off is received 	
	UPDATE dbo.TAN_TriggerEvent
	SET ProcessInd = 4 -- Cancelled Notification
	FROM dbo.TAN_TriggerEvent te
	INNER JOIN dbo.TAN_EventCopy ec ON te.VehicleIntID = ec.VehicleIntId
	INNER JOIN (SELECT ec.VehicleIntId, MAX(ec.EventId) AS EventId 
				FROM dbo.TAN_EventCopy ec
				INNER JOIN dbo.Driver d ON ec.DriverIntId = d.DriverIntId
				WHERE (d.Number != 'No ID' OR ec.CreationCodeId = 5)
				GROUP BY ec.VehicleIntId
				) e1 ON ec.VehicleIntId = e1.VehicleIntId AND ec.EventId = e1.EventId -- this join to get the last event only from the events within the run period
	WHERE te.CreationCodeId = 131
	  AND e1.EventId > te.EventId
	  AND te.ProcessInd < 3		
	
	-- Cancel any outstanding Idling triggers if vehicle moves or keys off
	UPDATE dbo.TAN_TriggerEvent
	SET ProcessInd = 4 -- Cancelled Notification
	FROM dbo.TAN_TriggerEvent te
	INNER JOIN dbo.TAN_EventCopy ec ON te.VehicleIntID = ec.VehicleIntId
	INNER JOIN (SELECT ec.VehicleIntId, MAX(EventDateTime) AS EventDateTime
				FROM dbo.TAN_EventCopy ec
				INNER JOIN dbo.VehicleModeCreationCode vmcc ON ec.CreationCodeId = vmcc.CreationCodeId
				WHERE vmcc.VehicleModeId IN (1,4)
				GROUP BY ec.VehicleIntId) m ON ec.VehicleIntId = m.VehicleIntId 
	WHERE te.CreationCodeId = 133
	  AND m.EventDateTime > te.TriggerDateTime
	  AND te.ProcessInd < 3
	
	-- Cancel any outstanding key off triggers if vehicle moves or keys on
	UPDATE dbo.TAN_TriggerEvent
	SET ProcessInd = 4 -- Cancelled Notification
	FROM dbo.TAN_TriggerEvent te
	INNER JOIN dbo.TAN_EventCopy ec ON te.VehicleIntID = ec.VehicleIntId
	INNER JOIN (SELECT ec.VehicleIntId, MAX(EventDateTime) AS EventDateTime
				FROM dbo.TAN_EventCopy ec
				INNER JOIN dbo.VehicleModeCreationCode vmcc ON ec.CreationCodeId = vmcc.CreationCodeId
				WHERE vmcc.VehicleModeId IN (1,3)
				GROUP BY ec.VehicleIntId) m ON ec.VehicleIntId = m.VehicleIntId 
	WHERE te.CreationCodeId = 134
	  AND m.EventDateTime > te.TriggerDateTime
	  AND te.ProcessInd < 3	
	
	-- Reset Act Once Triggers Section
	--================================
	
	-- Reset 'Act Once' for the following triggers where a Key Off has occurred:
	-- Driving with No Id - cc = 38
	-- Driving with Camera Off - cc = 140
	DELETE
	FROM dbo.TAN_TriggerEntityLatest
	FROM dbo.TAN_TriggerEntityLatest tel
	INNER JOIN dbo.TAN_Trigger t ON tel.TriggerId = t.TriggerId AND t.TriggerTypeId IN (38, 140)
	INNER JOIN dbo.TAN_EventCopy ec ON ec.VehicleIntId = dbo.GetVehicleIntFromId(tel.TriggerEntityId)
	WHERE ec.CreationCodeId = 5 -- Key Off
	
	-- Reset 'Act Once' for Moving without ignition when stopped moving is received
	DELETE
	FROM dbo.TAN_TriggerEntityLatest
	FROM dbo.TAN_TriggerEntityLatest tel
	INNER JOIN dbo.TAN_Trigger t ON tel.TriggerId = t.TriggerId AND t.TriggerTypeId = 40 -- Moving Without Ignition
	INNER JOIN dbo.TAN_EventCopy ec ON ec.VehicleIntId = dbo.GetVehicleIntFromId(tel.TriggerEntityId)
	WHERE ec.CreationCodeId = 43 -- Stopped Moving

	-- Processing of VehicleGeofenceHistory records moved from here into new parallelised process
	-- see proc_TAN_VehicleGeofenceHistory
	
	-- Cleanup Processing tables
	TRUNCATE TABLE dbo.TAN_GeofenceEvent
	TRUNCATE TABLE dbo.TAN_EventCopy

END


GO
