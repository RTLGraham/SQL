SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[proc_WriteEventListenerTemp]
	@eid bigint, 
	@vintid int, @dintid int, @ccid smallint, 
	@long float, @lat float, @heading smallint, @speed smallint,
	@odogps int, @odoroadspeed int, @ododash int,
	@eventdt datetime, @dio tinyint, @customerintid int = NULL,
	@analog0 smallint, @analog1 smallint, @analog2 smallint, @analog3 smallint,
	@analog4 smallint, @analog5 smallint,
	@sequencenumber int,
	@evtstring varchar(1024) = NULL, @evtdname varchar(30) = NULL,
	@altitude SMALLINT = NULL,
	@gpssatellitecount TINYINT = NULL,
	@gprssignalstrength TINYINT = NULL,
	@systemstatus TINYINT = NULL,
	@batterychargelevel TINYINT = NULL,
	@externalinputvoltage TINYINT = NULL,
	@maxspeed TINYINT = NULL,
	@tripdistance INT = NULL,
	@tachostatus TINYINT = NULL,
	@canstatus TINYINT = NULL,
	@fuelLevel TINYINT = NULL,
	@hardwareStatus TINYINT = NULL,
	@ADBlueLevel TINYINT = NULL,
	@bitmask INT = NULL	
AS

DECLARE @existingrows int,
		@lasteventdt datetime,
		@paniceid int,
		@vehicleMode INT,
		@dnumber VARCHAR(32),
		@rdnumber VARCHAR(32),
		@dname VARCHAR(50),
		@rdid UNIQUEIDENTIFIER,
		@dvguid UNIQUEIDENTIFIER,
		@cid UNIQUEIDENTIFIER,
		@workplaymode TINYINT,
		@unplannedplay INT,
		@playind TINYINT,
		@buttonind TINYINT,
		@tripstartid BIGINT			


INSERT INTO EventListenerTemp 	
				(EventId, VehicleIntId, DriverIntId, CreationCodeId,
				Long, Lat, Heading, Speed, OdoGPS, OdoRoadSpeed, OdoDashboard,
				EventDateTime, DigitalIO, CustomerIntId,
				AnalogData0, AnalogData1, AnalogData2, AnalogData3, AnalogData4, AnalogData5,
				SeqNumber,
				Altitude, GPSSatelliteCount, GPRSSignalStrength, SystemStatus, BatteryChargeLevel, ExternalInputVoltage, MaxSpeed,
				TripDistance, TachoStatus, CANStatus,
				FuelLevel,
				HardwareStatus,
				ADBlueLevel,
				Bitmask
				)
VALUES			(@eid, @vintid, @dintid, @ccid,
				@long, @lat, @heading, @speed, @odogps, @odoroadspeed, @ododash,
				@eventdt, @dio, @customerintid,
				@analog0, @analog1, @analog2, @analog3, @analog4, @analog5,
				@sequencenumber,
				@altitude, @gpssatellitecount, @gprssignalstrength, @systemstatus, @batterychargelevel, @externalinputvoltage, @maxspeed,
				@tripdistance, @tachostatus, @canstatus,
				@fuelLevel,
				@hardwareStatus,
				@ADBlueLevel,
				@bitmask
				)

-- extended (dump) text to be written in
IF @evtstring IS NOT NULL
BEGIN
	IF @evtdname IS NULL
		SET @evtdname = 'Dump'
	INSERT INTO EventDataTemp (EventId, EventDataName, EventDataString, LastOperation, EventDateTime, CreationCodeId, CustomerIntId, VehicleIntId, DriverIntId) 
	VALUES (@eid, @evtdname, @evtstring, GETDATE(), @eventdt, @ccid, @customerintid, @vintid, @dintid)
END

DECLARE @vguid UNIQUEIDENTIFIER
SET @vguid = dbo.GetVehicleIdFromInt(@vintid)

-- attempt to find the vehicle mode from the creation code
SELECT @vehicleMode = VehicleModeId FROM VehicleModeCreationCode WHERE CreationCodeId = @ccid
UPDATE dbo.VehicleLatestEvent
SET VehicleMode =
	CASE
		WHEN ((@vehicleMode IS NOT NULL) AND (@vehicleMode > 0)) THEN @vehicleMode
		ELSE VehicleMode
	END
WHERE VehicleId = @vguid
	
-- get the driver id based upon the unit type
DECLARE @IVHDriverIdType INT,
		@did UNIQUEIDENTIFIER
SELECT TOP 1 @IVHDriverIdType = it.DriverIdType
FROM dbo.Vehicle v
	INNER JOIN dbo.IVH i ON v.IVHId = i.IVHId
	INNER JOIN dbo.IVHType it ON it.IVHTypeId = i.IVHTypeId
WHERE v.VehicleIntId = @vintid
ORDER BY v.LastOperation DESC
	
IF @IVHDriverIdType = 2
BEGIN
	SELECT TOP 1 @did = d.DriverId
	FROM [dbo].EventData ed
	INNER JOIN [dbo].[Driver] d ON ed.DriverIntId = d.DriverIntId
	WHERE ed.VehicleIntId = @vintid
		AND ed.EventDateTime > DATEADD(dd, -1, GETUTCDATE())
		AND ed.EventDataName = 'DID'
		AND ed.CreationCodeId IN (0, 61)
	ORDER BY ed.EventDateTime DESC
		
	IF @did IS NULL
	BEGIN
		SET @did = dbo.GetDriverIdFromInt(@dintid)
	END
	ELSE BEGIN
		SET @dintid = dbo.GetDriverIntFromId(@did)
	END

END ELSE
BEGIN
	SET @did = dbo.GetDriverIdFromInt(@dintid)
END

UPDATE dbo.DriverLatestEvent
SET VehicleMode =
	CASE
		WHEN ((@vehicleMode IS NOT NULL) AND (@vehicleMode > 0)) THEN @vehicleMode
		ELSE VehicleMode
	END
WHERE DriverId = @did


SELECT @dnumber = Number, @playind = ISNULL(PlayInd, 0) FROM dbo.Driver WHERE DriverId = @did
IF @dnumber = 'No ID' AND @ccid = 61 -- This is a driver logoff so need to get real driver from vehicle latest
BEGIN
	SELECT @rdid = DriverId FROM dbo.VehicleLatestEvent WHERE VehicleId = @vguid
	SELECT @rdnumber = Number FROM dbo.Driver WHERE DriverId = @rdid
	SET @dvguid = NULL	
END ELSE
BEGIN
	SET @rdid = @did
	SET @rdnumber = @dnumber
	SET @dvguid = @vguid
END
	
--Only process DriverLatestEvent data for 'real' drivers
SELECT @dname = Surname FROM dbo.Driver WHERE DriverId = @rdid
IF ISNULL(@rdnumber, '') != 'No ID' AND @dname != 'UNKNOWN'
BEGIN	
	SET @lasteventdt = NULL
	-- if current event later than last recorded Driver event, update DriverEventLatest table
	--SELECT @lasteventdt = EventDateTime FROM DriverLatestEventTemp WHERE DriverId = @rdid AND Archived is NULL
				
	IF @long <> 0 AND @lat <> 0 AND @ccid NOT IN (0,24,55,56,77,78,91,100,436,437,438,455,456,457,458)
		--AND @lasteventdt IS NOT NULL 
		--AND @eventdt >= @lasteventdt  
	BEGIN
		UPDATE DriverLatestEvent
		SET EventId = @eid,
			EventDateTime = @eventdt,
			VehicleId = @dvguid,
			CreationCodeId = @ccid,
			Long = @long,
			Lat = @lat,
			Heading = @heading,
			Speed = @speed,
			OdoGPS = @odogps,
			OdoRoadSpeed = @odoroadspeed,
			OdoDashboard = @ododash,
			DigitalIO = @dio,
			AnalogData0 = @analog0,
			AnalogData1 = @analog1,
			AnalogData2 = @analog2,
			AnalogData3 = @analog3,
			AnalogData4 = @analog4,
			AnalogData5 = @analog5
		WHERE DriverId = @rdid 
		-- Insert a new row if the update statement failed
		IF (@@ROWCOUNT = 0)
		BEGIN
			INSERT INTO dbo.DriverLatestEvent (VehicleId, EventId, EventDateTime, DriverId, CreationCodeId, Long, Lat, Heading, Speed, OdoGPS, OdoRoadSpeed, OdoDashboard, DigitalIO, AnalogData0, AnalogData1, AnalogData2, AnalogData3, AnalogData4, AnalogData5)
			VALUES (@dvguid, @eid, @eventdt, @rdid, @ccid, @long, @lat, @heading, @speed, @odogps, @odoroadspeed, @ododash, @dio, @analog0, @analog1, @analog2, @analog3, @analog4, @analog5)
		END	
	END 
	--ELSE
	--BEGIN
	--	IF @lasteventdt IS NULL AND @long <> 0 AND @lat <> 0 AND @ccid NOT IN (0,24,55,56,77,78,91,100,436,437,438,455,456,457,458) AND @rdid IS NOT NULL
	--	BEGIN
	--		INSERT INTO DriverLatestEventTemp (DriverId, EventId, EventDateTime, VehicleId, CreationCodeId, Long, Lat, Heading, Speed, OdoGPS, OdoRoadSpeed, OdoDashboard, DigitalIO, AnalogData0, AnalogData1, AnalogData2, AnalogData3, AnalogData4, AnalogData5)
	--		VALUES (@rdid, @eid, @eventdt, @dvguid, @ccid, @long, @lat, @heading, @speed, @odogps, @odoroadspeed, @ododash, @dio, @analog0, @analog1, @analog2, @analog3, @analog4, @analog5)
	--	END
	--END
END

-- Determine whether customer operates work/play and if so, are we working or playing
DECLARE	@proceed BIT
SET @proceed = NULL -- Initialise

SET @cid = dbo.GetCustomerIdFromInt(@customerintid)
SELECT @workplaymode = ISNULL(dbo.CustomerPref(@cid, 3001), 0)

-- Also check if there is any unplanned play
SELECT @unplannedplay = VehicleUnplannedPlayId
FROM dbo.VehicleUnplannedPlay
WHERE VehicleIntId = @vintid AND @eventdt BETWEEN PlayStartDateTime AND PlayEndDateTime AND Archived = 0

IF @unplannedplay IS NOT NULL -- we are playing so do not proceed with latest update
	SET @proceed = 0 
		
-- The following work/play evaluation is split so that only events for customers using work/play are analysed
IF	@workplaymode = 0  -- work/play mode is Off so skip the work/play processing and process every event
	SET @proceed = 1

IF @proceed IS NULL
	IF  @workplaymode = 1 -- work/play mode is Driver
			--AND ((@playind = 0 AND dbo.IsVehicleWorkingHours(@eventdt, @vintid, @cid) = 1) -- not playing inside working hours
			-- OR (@playind = 1 AND dbo.IsVehicleWorkingHours(@eventdt, @vintid, @cid) = 0)) -- playing outside working hours (= working)
			AND @playind = 0 -- this is a working driver
	SET @proceed = 1
		
IF @proceed IS NULL		 		  
	IF @workplaymode IN (2, 3, 4, 5) -- work/play mode is Switch
	BEGIN	
		-- Determine if we are processing a work/play event and insert or delete row accordingly and set proceed flag
		IF @ccid = 68 -- button has been pressed
		BEGIN	
			IF NOT EXISTS (SELECT 1
			FROM dbo.VehicleButtonPressed
			WHERE VehicleIntId = @vintid)
				INSERT INTO dbo.VehicleButtonPressed (VehicleIntId, LastOperation)
				VALUES  (@vintid, GETDATE())
			-- Find the current trip start for this vehicle in TripsAndStops (check TripsAndStopsTemp first)
			SELECT TOP 1 @tripstartid = TripsAndStopsID
			FROM dbo.TripsAndStopsTemp
			WHERE VehicleIntID = @vintid
				AND VehicleState = 4
			ORDER BY TripsAndStopsID DESC
			IF @tripstartid IS NULL	
				SELECT TOP 1 @tripstartid = TripsAndStopsID
				FROM dbo.TripsAndStops
				WHERE VehicleIntID = @vintid
					AND VehicleState = 4
				ORDER BY TripsAndStopsID DESC	
			-- Mark this trip as Business or Private by inserting into TripsAndStopsWorkPlay (if doesn't already exist)
			IF NOT EXISTS (SELECT 1
			FROM dbo.TripsAndStopsWorkPlay
			WHERE TripsAndStopsId = @tripstartid)
				INSERT INTO dbo.TripsAndStopsWorkPlay (TripsAndStopsId, PlayInd)
				VALUES  (@tripstartid, CASE WHEN @workplaymode IN (3,5) THEN 1 ELSE 0 END)
			-- Finally set @proceed flag according to working or playing so don't update VehicleLatestEvent
			SELECT @proceed = CASE WHEN @workplaymode IN (3,5) THEN 1 ELSE 0 END	
		END	
		ELSE 
		IF @ccid IN (5, 69) -- we have keyed off so mark button as not pressed
		BEGIN
			DELETE	FROM dbo.VehicleButtonPressed
			WHERE VehicleIntId = @vintid
			SELECT @proceed = CASE WHEN @workplaymode IN (3,5) THEN 1 ELSE 0 END  
		END	
		ELSE	
		BEGIN -- any other event so need to check whether currently in play mode
			SELECT @buttonind = COUNT(*)
			FROM dbo.VehicleButtonPressed
			WHERE VehicleIntId = @vintid
			IF @buttonind = 1 -- button has been pressed 
				SELECT @proceed = CASE WHEN @workplaymode IN (3,5) THEN 0 ELSE 1 END	
			ELSE 
				SELECT @proceed = CASE WHEN @workplaymode IN (3,5) THEN 1 ELSE 0 END

		END		
	END		

IF @proceed = 1 AND @unplannedplay IS NULL -- we are in working hours
BEGIN
	-- We are in work mode so clear any row in VehicleInPlay table
	DELETE	
	FROM dbo.VehicleInPlay
	WHERE VehicleIntId = @vintid
END	

IF @workplaymode IN (4, 5) -- work play mode but no privacy so still need to update latest event tables
BEGIN
	SET @proceed = 1
	SET @unplannedplay = NULL
END	

IF @proceed = 1 AND @unplannedplay IS NULL -- we are still in working hours
BEGIN
	-- We are in work mode so clear any row in VehicleInPlay table

	--Now process VehicleLatestEvent
	SET @lasteventdt = NULL
	SET @existingrows = 0 -- initialise value

	-- if current event later than last recorded Vehicle event, update VehicleEventLatest table
	--SELECT @lasteventdt = EventDateTime FROM VehicleLatestEventTemp WHERE VehicleId = @vguid AND Archived is NULL
	--IF @lasteventdt IS NULL	
	--BEGIN 
	--	-- Try getting latest event datetime from VehicleLatestEvent
	--	SELECT @lasteventdt = EventDateTime FROM VehicleLatestEvent WHERE VehicleId = @vguid
	--END ELSE
 --   BEGIN
	--	SET @existingrows = 1 -- we had found a row in the temp table
	--END
		
	IF @long <> 0 AND @lat <> 0 AND @ccid NOT IN (0,24,55,56,77,78,79,91,100,436,437,438,455,456,457,458) 
		--AND @lasteventdt IS NOT NULL 
		--AND @existingrows = 1
		--AND @eventdt >= @lasteventdt 
	BEGIN
		UPDATE VehicleLatestEvent
		SET EventId = @eid,
			EventDateTime = @eventdt,
			DriverId = CASE WHEN @did IS NULL THEN DriverId ELSE @did END,
			CreationCodeId = @ccid,
			Long = @long,
			Lat = @lat,
			Heading = @heading,
			Speed = @speed,
			OdoGPS = @odogps,
			OdoRoadSpeed = @odoroadspeed,
			OdoDashboard = @ododash,
			DigitalIO = @dio,
			AnalogData0 = @analog0,
			AnalogData1 = @analog1,
			AnalogData2 = @analog2,
			AnalogData3 = @analog3,
			AnalogData4 = @analog4,
			AnalogData5 = @analog5
		WHERE VehicleId = @vguid 
		-- Insert a new row if the update statement failed
		IF (@@ROWCOUNT = 0)
		BEGIN
			INSERT INTO dbo.VehicleLatestEvent (VehicleId, EventId, EventDateTime, DriverId, CreationCodeId, Long, Lat, Heading, Speed, OdoGPS, OdoRoadSpeed, OdoDashboard, DigitalIO, AnalogData0, AnalogData1, AnalogData2, AnalogData3, AnalogData4, AnalogData5)
			VALUES (@vguid, @eid, @eventdt, @did, @ccid, @long, @lat, @heading, @speed, @odogps, @odoroadspeed, @ododash, @dio, @analog0, @analog1, @analog2, @analog3, @analog4, @analog5)
		END	
	END
	--ELSE
	--BEGIN
	--	IF (@lasteventdt IS NULL OR @eventdt >= @lasteventdt) AND @long <> 0 AND @lat <> 0 AND @ccid NOT IN (0,24,55,56,77,78,91,100,436,437,438,455,456,457,458)
	--	BEGIN
	--		INSERT INTO VehicleLatestEventTemp (VehicleId, EventId, EventDateTime, DriverId, CreationCodeId, Long, Lat, Heading, Speed, OdoGPS, OdoRoadSpeed, OdoDashboard, DigitalIO, AnalogData0, AnalogData1, AnalogData2, AnalogData3, AnalogData4, AnalogData5)
	--		VALUES (dbo.GetVehicleIdFromInt(@vintid), @eid, @eventdt, @did, @ccid, @long, @lat, @heading, @speed, @odogps, @odoroadspeed, @ododash, @dio, @analog0, @analog1, @analog2, @analog3, @analog4, @analog5)
	--	END
	--END

	-- Special process to update odometer for camera only vehicles from Trip data i.e. ccid = 77 or 78
	--IF @ccid IN (77,78) --AND @existingrows = 1 -- update row in VehicleLatestEventTemp updating odometer only
	--BEGIN
	--	UPDATE dbo.VehicleLatestEvent
	--	SET OdoGPS = @odogps
	--	WHERE VehicleId = @vguid
	--END	ELSE
 --   IF @ccid IN (77,78) -- insert a row in VehicleLatestEventTemp taking current row from VehicleLatestEvent as a template and updating only the odometer
	--BEGIN
	--	INSERT INTO dbo.VehicleLatestEventTemp (VehicleId, EventId, EventDateTime, DriverId, CreationCodeId, Long, Lat, Heading, Speed, OdoGPS, OdoRoadSpeed, OdoDashboard, VehicleMode, AnalogIoAlertTypeId, DigitalIO, AnalogData0, AnalogData1, AnalogData2, AnalogData3, AnalogData4, AnalogData5)
	--	SELECT VehicleId, EventId, EventDateTime, DriverId, CreationCodeId, Long, Lat, Heading, Speed, @odogps, OdoRoadSpeed, OdoDashboard, VehicleMode, AnalogIoAlertTypeId, DigitalIO, AnalogData0, AnalogData1, AnalogData2, AnalogData3, AnalogData4, AnalogData5
	--	FROM dbo.VehicleLatestEvent WITH (NOLOCK)
	--	WHERE VehicleId = @vguid       
	--END	

END	ELSE
BEGIN -- We are in play mode so insert into the VehicleInPlay table if not already present	
	IF NOT EXISTS (SELECT 1
					FROM dbo.VehicleInPlay
					WHERE VehicleIntId = @vintid)
	INSERT INTO dbo.VehicleInPlay (VehicleIntId, LastOperation)
	VALUES  (@vintid, GETDATE())
END	

SET @lasteventdt = NULL
SET @existingrows = 0 -- initialise value

-- if current event later than last recorded Vehicle event, update VehicleEventLatest table
--SELECT @lasteventdt = EventDateTime FROM VehicleLatestAllEventTemp WHERE VehicleId = @vguid AND Archived is NULL
--IF @lasteventdt IS NULL	
--BEGIN 
--	-- Try getting latest event datetime from VehicleLatestAllEvent
--	SELECT @lasteventdt = EventDateTime FROM VehicleLatestAllEvent WHERE VehicleId = @vguid
--END ELSE
--BEGIN
--	SET @existingrows = 1 -- we had found a row in the temp table
--END

--IF @lasteventdt IS NOT NULL AND @eventdt >= @lasteventdt AND @existingrows = 1 --AND @long <> 0 AND @lat <> 0 AND @ccid NOT IN (0,24,91,100)
--BEGIN
	UPDATE VehicleLatestAllEvent
	SET EventId = @eid,
		EventDateTime = @eventdt,
		DriverId = CASE WHEN @did IS NULL THEN DriverId ELSE @did END,
		CreationCodeId = @ccid,
		Long = @long,
		Lat = @lat,
		Heading = @heading,
		Speed = @speed,
		OdoGPS = @odogps,
		OdoRoadSpeed = @odoroadspeed,
		OdoDashboard = @ododash,
		DigitalIO = @dio,
		AnalogData0 = @analog0,
		AnalogData1 = @analog1,
		AnalogData2 = @analog2,
		AnalogData3 = @analog3,
		AnalogData4 = @analog4,
		AnalogData5 = @analog5
	WHERE VehicleId = @vguid 
	-- Insert a new row if the update statement failed
	IF (@@ROWCOUNT = 0)
	BEGIN
		INSERT INTO dbo.VehicleLatestAllEvent (VehicleId, EventId, EventDateTime, DriverId, CreationCodeId, Long, Lat, Heading, Speed, OdoGPS, OdoRoadSpeed, OdoDashboard, DigitalIO, AnalogData0, AnalogData1, AnalogData2, AnalogData3, AnalogData4, AnalogData5)
		VALUES (@vguid, @eid, @eventdt, @did, @ccid, @long, @lat, @heading, @speed, @odogps, @odoroadspeed, @ododash, @dio, @analog0, @analog1, @analog2, @analog3, @analog4, @analog5)
	END	
--END
--ELSE
--BEGIN
--	IF (@lasteventdt IS NULL OR @eventdt >= @lasteventdt) --AND @long <> 0 AND @lat <> 0 AND @ccid NOT IN (24,91,100)
--	BEGIN
--		INSERT INTO VehicleLatestAllEventTemp (VehicleId, EventId, EventDateTime, DriverId, CreationCodeId, Long, Lat, Heading, Speed, OdoGPS, OdoRoadSpeed, OdoDashboard, DigitalIO, AnalogData0, AnalogData1, AnalogData2, AnalogData3, AnalogData4, AnalogData5)
--		VALUES (dbo.GetVehicleIdFromInt(@vintid), @eid, @eventdt, @did, @ccid, @long, @lat, @heading, @speed, @odogps, @odoroadspeed, @ododash, @dio, @analog0, @analog1, @analog2, @analog3, @analog4, @analog5)
--	END
--END


GO
