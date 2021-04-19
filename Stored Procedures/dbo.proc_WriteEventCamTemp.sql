SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[proc_WriteEventCamTemp]
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

DECLARE @paniceid int,
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

INSERT INTO EventCamTemp 	
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

-- driverId processing removed from here as not relevant to cameras
DECLARE @did UNIQUEIDENTIFIER
SET @did = dbo.GetDriverIdFromInt(@dintid)

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
IF @rdnumber != 'No ID' AND @dname != 'UNKNOWN'
BEGIN	
				
	IF @long <> 0 AND @lat <> 0 AND @ccid NOT IN (0,24,55,56,77,78,91,100,436,437,438,455,456,457,458)
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
	END
	-- Insert a new row if the update statement failed
	IF (@@ROWCOUNT = 0)
	BEGIN
		INSERT INTO dbo.DriverLatestEvent (VehicleId, EventId, EventDateTime, DriverId, CreationCodeId, Long, Lat, Heading, Speed, OdoGPS, OdoRoadSpeed, OdoDashboard, DigitalIO, AnalogData0, AnalogData1, AnalogData2, AnalogData3, AnalogData4, AnalogData5)
		VALUES (@dvguid, @eid, @eventdt, @rdid, @ccid, @long, @lat, @heading, @speed, @odogps, @odoroadspeed, @ododash, @dio, @analog0, @analog1, @analog2, @analog3, @analog4, @analog5)
	END	
END

--Now process VehicleLatestEvent
IF @long <> 0 AND @lat <> 0 AND @ccid NOT IN (0,24,55,56,77,78,79,91,100,436,437,438,455,456,457,458) 
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
END
-- Insert a new row if the update statement failed
IF (@@ROWCOUNT = 0)
BEGIN
	INSERT INTO dbo.VehicleLatestEvent (VehicleId, EventId, EventDateTime, DriverId, CreationCodeId, Long, Lat, Heading, Speed, OdoGPS, OdoRoadSpeed, OdoDashboard, DigitalIO, AnalogData0, AnalogData1, AnalogData2, AnalogData3, AnalogData4, AnalogData5)
	VALUES (@vguid, @eid, @eventdt, @did, @ccid, @long, @lat, @heading, @speed, @odogps, @odoroadspeed, @ododash, @dio, @analog0, @analog1, @analog2, @analog3, @analog4, @analog5)
END	

-- Special process to update odometer for camera only vehicles from Trip data i.e. ccid = 77 or 78
IF @ccid IN (77,78) 
BEGIN
	UPDATE dbo.VehicleLatestEvent
	SET OdoGPS = @odogps
	WHERE VehicleId = @vguid
END	

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

-- Additionally we update VehicleLatestCamEvent as this stored procedure only used by camera
-- This update kept very simple as only purpose is for proactive maintenance

UPDATE VehicleLatestCamEvent
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
	INSERT INTO dbo.VehicleLatestCamEvent (VehicleId, EventId, EventDateTime, DriverId, CreationCodeId, Long, Lat, Heading, Speed, OdoGPS, OdoRoadSpeed, OdoDashboard, DigitalIO, AnalogData0, AnalogData1, AnalogData2, AnalogData3, AnalogData4, AnalogData5)
	VALUES (@vguid, @eid, @eventdt, @did, @ccid, @long, @lat, @heading, @speed, @odogps, @odoroadspeed, @ododash, @dio, @analog0, @analog1, @analog2, @analog3, @analog4, @analog5)
END	




GO
