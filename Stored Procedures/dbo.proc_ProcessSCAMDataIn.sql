SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE PROC [dbo].[proc_ProcessSCAMDataIn]
AS
BEGIN

	DECLARE @driverIntId INT,
			@customerintid INT,
			@vehicleIntId INT,
			@EventId BIGINT,
			@eventDateTime DATETIME,
			@EventDataString VARCHAR(1024),
			@CamIntId INT,
			@CcId SMALLINT,
			@Lat FLOAT,
			@Long FLOAT,
			@Speed SMALLINT,
			@Heading SMALLINT,
			@eid BIGINT,
			@incidentId BIGINT,
			@hasAnalyst BIT,
			@shareVideos BIT

	-- Mark data to be processed
	UPDATE dbo.SCAM_DataIn
	SET ProcessInd = 1
	WHERE ProcessInd = 0

	-- First Insert events into EventCamTemp
	INSERT INTO dbo.EventCamTemp (EventId, VehicleIntId, DriverIntId, CreationCodeId, Long, Lat, Heading, Speed, OdoGPS, OdoRoadSpeed, OdoDashboard, EventDateTime, DigitalIO, CustomerIntId, AnalogData0, AnalogData1, AnalogData2, AnalogData3, AnalogData4, AnalogData5, 
							   SeqNumber, SpeedLimit, LastOperation, Archived, Altitude, GPSSatelliteCount, GPRSSignalStrength, SystemStatus, BatteryChargeLevel, ExternalInputVoltage, MaxSpeed, TripDistance, TachoStatus, CANStatus, FuelLevel, HardwareStatus)
	SELECT sdi.EventId,
		   sdi.VehicleIntId,
           sdi.DriverIntId,
		   sdi.CreationCodeId,
           sdi.Long,
           sdi.Lat,
           sdi.Heading,
           sdi.Speed,
           sdi.OdoGPS, NULL, NULL,
		   sdi.EventDateTime,
		   CASE WHEN sdi.IgnitionStatus = 1 THEN 128 ELSE 0 END, -- This will need more bitwise calculations as other data becomes available - for now the digitalio only shows ignition status
		   sdi.CustomerIntId,
		   NULL, NULL, NULL, NULL, NULL, NULL,
		   sdi.SeqNumber, NULL, GETDATE(), NULL,
		   sdi.Altitude,
           sdi.GPSSatelliteCount,
           sdi.GPRSSignalStrength,
		   NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
	FROM dbo.SCAM_DataIn sdi
	WHERE sdi.ProcessInd = 1

	-- Insert into EventData where there is a video so we can obtain the EventId for this video when it arrives later
	INSERT INTO dbo.EventDataTemp (EventDataName, EventDataString, LastOperation, Archived, EventDateTime, CreationCodeId, CustomerIntId, VehicleIntId, DriverIntId, EventId)
	SELECT sdi.EventDataName, sdi.EventDataString, GETDATE(), NULL, sdi.EventDateTime, sdi.CreationCodeId, sdi.CustomerIntId, sdi.VehicleIntId, sdi.DriverIntId, sdi.EventId
	FROM dbo.SCAM_DataIn sdi
	WHERE sdi.ProcessInd = 1
	  AND sdi.EventDataName IS NOT NULL	

	-- Process Incident data uing a cursor so that we can handle the various option for Coach/Analyst and video sharing
	-- Insert into CAM_Incident for the harsh events (ccid 436, 437, 438) and button (55)
	DECLARE Incident_cursor CURSOR FAST_FORWARD FOR
	SELECT sdi.EventId, sdi.EventDateTime, sdi.CreationCodeId, sdi.CustomerIntId, sdi.VehicleIntId, sdi.DriverIntId, sdi.CamIntId, sdi.EventDataString, sdi.Lat, sdi.Long, sdi.Heading, sdi.Speed
	FROM dbo.SCAM_DataIn sdi
	WHERE sdi.ProcessInd = 1
	  AND sdi.CreationCodeId IN (436, 437, 438, 55)	

	OPEN Incident_cursor
	FETCH NEXT FROM Incident_cursor INTO @EventId, @EventDateTime, @CcId, @customerIntId, @vehicleIntId, @driverIntId, @camIntId, @eventDataString, @Lat, @Long, @Heading, @Speed
	WHILE @@fetch_status = 0
	BEGIN

		INSERT INTO dbo.CAM_Incident (EventId, EventDateTime, CreationCodeId, CustomerIntId, VehicleIntId, DriverIntId, CameraIntId, CoachingStatusId, ApiEventId, ApiMetadataId, LastOperation, Archived, MinX, MaxX, MinY, MaxY, MinZ, MaxZ, IsEscalated, Lat, Long, Heading, Speed)
		VALUES (@EventId, @eventDateTime, @CcId, @customerintid, @vehicleIntId, @driverIntId, @CamIntId, 0, @EventDataString, NULL, GETDATE(), 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, @Lat, @Long, @Heading, @Speed)

		SET @incidentId = SCOPE_IDENTITY()

		INSERT INTO dbo.CAM_VideoIn (ApiEventId, ApiVideoId, CameraNumber, LastOperation, Archived, VideoStatus, ProjectId)
		VALUES  (@EventDataString, @EventDataString, 1, GETDATE(), 0, 4, 999)

		-- Check Customer Preference to see if the customer has an Analyst
		SELECT @hasAnalyst = ISNULL(dbo.CustomerPref(dbo.GetCustomerIdFromInt(@customerintid), 1700),0)

		--Check Customer Preference to see if button presses should be automatically shared with drivers
		SET @shareVideos = 0 -- initialise
		SELECT @shareVideos = ISNULL(dbo.CustomerPref(dbo.GetCustomerIdFromInt(@customerintid), 3013),0)

		-- If this incident is a button press and videos are auto shared then automatically share the incident with the Driver
		IF @CcId = 55 AND @shareVideos = 1
			INSERT INTO dbo.ObjectShare (ObjectId, ObjectIntId, ObjectTypeId, EntityId, EntityTypeId, LastModifiedDateTime, Archived)
			VALUES  (NULL, @incidentId, 1, dbo.GetDriverIdFromInt(@driverIntId), 2, GETDATE(), 0)

		-- If the customer does NOT have an Analyst OR the event is a low/medium event, change the coaching status to 'For Review' and handle ABC codes accordingly by calling ChangeEventVideoStatus
		IF @hasAnalyst = 0 OR @CcId IN (457, 458)
		BEGIN
			EXEC dbo.proc_ChangeEventVideoStatus @incidentId, NULL, 1, NULL, @CcId	
		END	

		FETCH NEXT FROM Incident_cursor INTO @EventId, @EventDateTime, @CcId, @customerIntId, @vehicleIntId, @driverIntId, @camIntId, @eventDataString, @Lat, @Long, @Heading, @Speed

	END 
	CLOSE Incident_cursor
	DEALLOCATE Incident_cursor	

	-- Delete processed rows
	DELETE
    FROM dbo.SCAM_DataIn
	WHERE ProcessInd = 1

END	

GO
