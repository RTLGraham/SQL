SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_WriteEventNewTemp_Save]
	@eid bigint = NULL OUTPUT, 
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
	@maxspeed TINYINT = NULL
AS

DECLARE @existingrows int,
		@existingdifferentcc int,
		@lasteventdt datetime,
		@paniceid int,
		@vehicleMode int

IF @eid IS NULL
BEGIN
	INSERT INTO EventTemp 	
					(VehicleIntId, DriverIntId, CreationCodeId,
					Long, Lat, Heading, Speed, OdoGPS, OdoRoadSpeed, OdoDashboard,
					EventDateTime, DigitalIO, CustomerIntId,
					AnalogData0, AnalogData1, AnalogData2, AnalogData3, AnalogData4, AnalogData5,
					SeqNumber,
					Altitude, GPSSatelliteCount, GPRSSignalStrength, SystemStatus, BatteryChargeLevel, ExternalInputVoltage, MaxSpeed
					)
	VALUES			(@vintid, @dintid, @ccid,
					@long, @lat, @heading, @speed, @odogps, @odoroadspeed, @ododash,
					@eventdt, @dio, @customerintid,
					@analog0, @analog1, @analog2, @analog3, @analog4, @analog5,
					@sequencenumber,
					@altitude, @gpssatellitecount, @gprssignalstrength, @systemstatus, @batterychargelevel, @externalinputvoltage, @maxspeed
					)

	SET @eid = SCOPE_IDENTITY()

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
	WHERE VehicleId = @vguid --dbo.GetVehicleIdFromInt(@vintid)
	
	-- get the driver id based upon the unit type
	DECLARE @IVHTypeId INT,
			@did UNIQUEIDENTIFIER
	SELECT TOP 1 @IVHTypeId = i.IVHTypeId
	FROM dbo.Vehicle v
		INNER JOIN dbo.IVH i ON v.IVHId = i.IVHId
	WHERE v.VehicleIntId = @vintid
	ORDER BY v.LastOperation DESC
	
	IF @IVHTypeId IN (1,2)
	BEGIN
		SELECT TOP 1 @did = d.DriverId
		FROM [dbo].EventData ed
		INNER JOIN [dbo].[Driver] d ON ed.DriverIntId = d.DriverIntId
		WHERE ed.VehicleIntId = @vintid
		  AND ed.EventDateTime > DATEADD(dd, -1, GETUTCDATE())
		  AND ed.EventDataName = 'DID'
		  AND ed.CreationCodeId = 0
		ORDER BY ed.EventDateTime DESC
		SET @dintid = dbo.GetDriverIntFromId(@did)
	END ELSE
	BEGIN
		SET @did = dbo.GetDriverIdFromInt(@dintid)
	END

	-- if current event later than last recorded event, update Vehicle table
	SELECT @lasteventdt = EventDateTime FROM VehicleLatestEventTemp WHERE VehicleId = @vguid AND Archived is NULL
	
	
	IF @lasteventdt IS NOT NULL AND @eventdt >= @lasteventdt AND @long <> 0 AND @lat <> 0 AND @ccid NOT IN (0,24,100)
	BEGIN
		UPDATE VehicleLatestEventTemp 
		SET EventId = @eid,
			EventDateTime = @eventdt,
--			DriverId = dbo.GetDriverIdFromInt(@dintid), -- is this correct here?
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
		WHERE VehicleId = @vguid /* dbo.GetVehicleIdFromInt(@vintid) */
	END
	ELSE
	BEGIN
		IF @lasteventdt IS NULL AND @long <> 0 AND @lat <> 0 AND @ccid NOT IN (24,100)
		BEGIN
			INSERT INTO VehicleLatestEventTemp (VehicleId, EventId, EventDateTime, DriverId, CreationCodeId, Long, Lat, Heading, Speed, OdoGPS, OdoRoadSpeed, OdoDashboard, DigitalIO, AnalogData0, AnalogData1, AnalogData2, AnalogData3, AnalogData4, AnalogData5)
			VALUES (dbo.GetVehicleIdFromInt(@vintid), @eid, @eventdt, @did, @ccid, @long, @lat, @heading, @speed, @odogps, @odoroadspeed, @ododash, @dio, @analog0, @analog1, @analog2, @analog3, @analog4, @analog5)
		END
	END


	----Provess Driver Notification reason codes
	--IF @ccid IN (120,121,122)
	--BEGIN
	--	DECLARE @vehicleId UNIQUEIDENTIFIER,
	--			@aid INT
				
	--	SET		@vehicleId = dbo.GetVehicleIdFromInt(@vintid)
	--	IF		@ccid = 120 BEGIN SET @aid = 15 END
	--	ELSE IF @ccid = 121 BEGIN SET @aid = 17 END
	--	ELSE IF @ccid = 122 BEGIN SET @aid = 16 END
	--	ELSE					  SET @aid = NULL
		
	--	UPDATE dbo.VehicleLatestEvent
	--	SET AnalogIoAlertTypeId = @aid
	--	WHERE VehicleId = @vehicleId
		
	--	INSERT INTO dbo.DriverNotification
	--			( VehicleId ,
	--			  Status ,
	--			  LastOperation ,
	--			  Archived ,
	--			  UserId ,
	--			  CommandId,
	--			  EventId,
	--			  Long,
	--			  Lat
	--			)
	--	VALUES  ( @vehicleId , -- VehicleId - uniqueidentifier
	--			  @aid , -- Status - int
	--			  GETDATE() , -- LastOperation - datetime
	--			  0 , -- Archived - bit
	--			  NULL , -- UserId - uniqueidentifier
	--			  NULL , -- CommandId - int
	--			  @eid ,
	--			  @long ,
	--			  @lat
	--			)
	--END

	--INSERT INTO dbo.windms_EventTemp
	--       (EventId, VehicleIntId, DriverIntId, CreationCodeId, Long, Lat, Heading, Speed, OdoGPS, OdoRoadSpeed,
	--		OdoDashboard, EventDateTime, DigitalIO,	CustomerIntId, 
	--		AnalogData0, AnalogData1, AnalogData2, AnalogData3, AnalogData4, AnalogData5, 
	--		SeqNumber, SpeedLimit, LastOperation, Archived)
	--VALUES (@eid, @vintid, @dintid, @ccid, @long, @lat, @heading, @speed, @odogps, @odoroadspeed, 
	--		@ododash, @eventdt, @dio, @customerintid,
	--		@analog0, @analog1, @analog2, @analog3, @analog4, @analog5,
	--		@sequencenumber, NULL, GETDATE(), 0)
	
END

GO
