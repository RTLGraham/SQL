SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE PROC [dbo].[proc_InsertSCAMDataIn]
	@eid BIGINT,
	@customerintid INT,
	@vintid INT,
	@camintid INT,
	@dintid INT,
	@imei VARCHAR(50), 
	@ccid SMALLINT, 
	@long FLOAT, 
	@lat FLOAT, 
	@heading SMALLINT, 
	@speed SMALLINT,
	@odogps INT, 
	@eventdt DATETIME, 
	@ignstatus TINYINT,
	@altitude SMALLINT = NULL,
	@gpssatellitecount TINYINT = NULL,
	@gprssignalstrength TINYINT = NULL,	 
	@sequencenumber int,
	@addtlname varchar(30) = NULL,
	@addtlvalue nvarchar(MAX) = NULL
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

	-- Write SCAMDataIn
	INSERT INTO dbo.SCAM_DataIn
			(IMEI,
			 EventId,
			 CustomerIntId,
			 VehicleIntId,
			 CamIntId,
			 DriverIntId,
			 CreationCodeId,
			 EventDateTime,
			 Long,
			 Lat,
			 Heading,
			 Speed,
			 Altitude,
			 OdoGPS,
			 GPSSatelliteCount,
			 GPRSSignalStrength,
			 SeqNumber,
			 IgnitionStatus,
			 EventDataName,
			 EventDataString,
			 ProcessInd,
			 LastOperation
			)
	VALUES  (@imei, -- IMEI - varchar(100)
			 @eid,
			 @customerintid, -- CustomerIntId - int
			 @vintid, -- VehicleIntId - int
			 @camintid, -- camintid - int
			 @dintid, -- DriverIntId - int
			 @ccid, -- CreationCodeId - smallint
			 @eventdt, -- EventDateTime - datetime
			 @long, -- Long - float
			 @lat, -- Lat - float
			 @heading, -- Heading - smallint
			 @speed, -- Speed - smallint
			 @altitude, -- Altitude - float
			 @odogps, -- OdoGPS - int
			 @gpssatellitecount, -- GPSSatelliteCount - tinyint
			 @gprssignalstrength, -- GPRSSignalStrength - tinyint
			 @sequencenumber, -- SeqNumber - int
			 @ignstatus, -- IgnitionStatus - tinyint
			 @addtlname, -- EventDataName - varchar(30)
			 @addtlvalue, -- EventDataString - varchar(1024)
			 0, -- ProcessInd - tinyint
			 GETDATE()  -- LastOperation - smalldatetime
			)

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
	SET @lasteventdt = NULL
	-- if current event later than last recorded Driver event, update DriverEventLatest table
				
	IF @long <> 0 AND @lat <> 0 AND @ccid NOT IN (0,24,25,26,55,56,77,78,91,100,200,436,437,438,455,456,457,458,470,471)
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
			OdoRoadSpeed = NULL,
			OdoDashboard = NULL,
			DigitalIO = CASE WHEN @ignstatus = 1 THEN ISNULL(DigitalIO, 0) | 128 ELSE CASE WHEN ISNULL(DigitalIO, 0) & 128 = 128 THEN ISNULL(DigitalIO, 0) ^ 128 ELSE ISNULL(DigitalIO, 0) END END,
			AnalogData0 = NULL,
			AnalogData1 = NULL,
			AnalogData2 = NULL,
			AnalogData3 = NULL,
			AnalogData4 = NULL,
			AnalogData5 = NULL
		WHERE DriverId = @rdid 
	END
	-- Insert a new row if the update statement failed
	IF (@@ROWCOUNT = 0)
	BEGIN
		INSERT INTO dbo.DriverLatestEvent (VehicleId, EventId, EventDateTime, DriverId, CreationCodeId, Long, Lat, Heading, Speed, OdoGPS, OdoRoadSpeed, OdoDashboard, DigitalIO, AnalogData0, AnalogData1, AnalogData2, AnalogData3, AnalogData4, AnalogData5)
		VALUES (@dvguid, @eid, @eventdt, @rdid, @ccid, @long, @lat, @heading, @speed, @odogps, NULL, NULL, CASE WHEN @ignstatus = 1 THEN 128 ELSE 0 END, NULL, NULL, NULL, NULL, NULL, NULL)
	END	
END

--Now process VehicleLatestEvent
SET @lasteventdt = NULL
SET @existingrows = 0 -- initialise value

IF @long <> 0 AND @lat <> 0 AND @ccid NOT IN (0,24,25,26,55,56,77,78,91,100,200,436,437,438,455,456,457,458,470,471) 
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
		OdoRoadSpeed = NULL,
		OdoDashboard = NULL,
		DigitalIO = CASE WHEN @ignstatus = 1 THEN ISNULL(DigitalIO, 0) | 128 ELSE CASE WHEN ISNULL(DigitalIO, 0) & 128 = 128 THEN ISNULL(DigitalIO, 0) ^ 128 ELSE ISNULL(DigitalIO, 0) END END,
		AnalogData0 = NULL,
		AnalogData1 = NULL,
		AnalogData2 = NULL,
		AnalogData3 = NULL,
		AnalogData4 = NULL,
		AnalogData5 = NULL
	WHERE VehicleId = @vguid 
END
-- Insert a new row if the update statement failed
IF (@@ROWCOUNT = 0)
BEGIN
	INSERT INTO dbo.VehicleLatestEvent (VehicleId, EventId, EventDateTime, DriverId, CreationCodeId, Long, Lat, Heading, Speed, OdoGPS, OdoRoadSpeed, OdoDashboard, DigitalIO, AnalogData0, AnalogData1, AnalogData2, AnalogData3, AnalogData4, AnalogData5)
	VALUES (@vguid, @eid, @eventdt, @did, @ccid, @long, @lat, @heading, @speed, @odogps, NULL, NULL, CASE WHEN @ignstatus = 1 THEN 128 ELSE 0 END, NULL, NULL, NULL, NULL, NULL, NULL)
END	
--END

-- Special process to update odometer for camera only vehicles from Trip data i.e. ccid = 77 or 78
IF @ccid IN (77,78) 
BEGIN
	UPDATE dbo.VehicleLatestEvent
	SET OdoGPS = @odogps
	WHERE VehicleId = @vguid
END	

SET @lasteventdt = NULL
SET @existingrows = 0 -- initialise value

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
	OdoRoadSpeed = NULL,
	OdoDashboard = NULL,
	DigitalIO = CASE WHEN @ignstatus = 1 THEN ISNULL(DigitalIO, 0) | 128 ELSE CASE WHEN ISNULL(DigitalIO, 0) & 128 = 128 THEN ISNULL(DigitalIO, 0) ^ 128 ELSE ISNULL(DigitalIO, 0) END END,
	AnalogData0 = NULL,
	AnalogData1 = NULL,
	AnalogData2 = NULL,
	AnalogData3 = NULL,
	AnalogData4 = NULL,
	AnalogData5 = NULL
WHERE VehicleId = @vguid 
-- Insert a new row if the update statement failed
IF (@@ROWCOUNT = 0)
BEGIN
	INSERT INTO dbo.VehicleLatestAllEvent (VehicleId, EventId, EventDateTime, DriverId, CreationCodeId, Long, Lat, Heading, Speed, OdoGPS, OdoRoadSpeed, OdoDashboard, DigitalIO, AnalogData0, AnalogData1, AnalogData2, AnalogData3, AnalogData4, AnalogData5)
	VALUES (@vguid, @eid, @eventdt, @did, @ccid, @long, @lat, @heading, @speed, @odogps, NULL, NULL, CASE WHEN @ignstatus = 1 THEN 128 ELSE 0 END, NULL, NULL, NULL, NULL, NULL, NULL)
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
	OdoRoadSpeed = NULL,
	OdoDashboard = NULL,
	DigitalIO = CASE WHEN @ignstatus = 1 THEN ISNULL(DigitalIO, 0) | 128 ELSE CASE WHEN ISNULL(DigitalIO, 0) & 128 = 128 THEN ISNULL(DigitalIO, 0) ^ 128 ELSE ISNULL(DigitalIO, 0) END END,
	AnalogData0 = NULL,
	AnalogData1 = NULL,
	AnalogData2 = NULL,
	AnalogData3 = NULL,
	AnalogData4 = NULL,
	AnalogData5 = NULL
WHERE VehicleId = @vguid 
-- Insert a new row if the update statement failed
IF (@@ROWCOUNT = 0)
BEGIN
	INSERT INTO dbo.VehicleLatestCamEvent (VehicleId, EventId, EventDateTime, DriverId, CreationCodeId, Long, Lat, Heading, Speed, OdoGPS, OdoRoadSpeed, OdoDashboard, DigitalIO, AnalogData0, AnalogData1, AnalogData2, AnalogData3, AnalogData4, AnalogData5)
	VALUES (@vguid, @eid, @eventdt, @did, @ccid, @long, @lat, @heading, @speed, @odogps, NULL, NULL, CASE WHEN @ignstatus = 1 THEN 128 ELSE 0 END, NULL, NULL, NULL, NULL, NULL, NULL)
END	

GO
