SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_ProcessVehicleLatestEvent]
AS
SELECT MyVar = 5 INTO #VLERunningTable

IF @@ERROR <> 0
BEGIN
	-- do nothing!
	SELECT 0
END
ELSE
BEGIN

	DECLARE @eid bigint, 
			@vintid int, 
			@dintid int, 
			@ccid smallint, 
			@long float, 
			@lat float, 
			@heading smallint, 
			@speed smallint,
			@odogps int, 
			@odoroadspeed int, 
			@ododash int,
			@eventdt datetime, 
			@dio tinyint, 
			@customerintid int,
			@analog0 smallint, 
			@analog1 smallint, 
			@analog2 smallint, 
			@analog3 smallint,
			@analog4 smallint, 
			@analog5 smallint,
			@existingrows int,
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
			@playind BIT,
			@vguid UNIQUEIDENTIFIER,
			@IVHTypeId INT,
			@did UNIQUEIDENTIFIER,
			@proceed BIT

	-- Mark all VLE_Temp Rows rows as in process
	UPDATE dbo.EventVLE
	SET ProcessInd = 1
	WHERE ProcessInd = 0

	-- Declare a cursor to process each EventVLE row in turn and determine necessary updates to the Vehicle and Driver LatestEvent tables 
	-- and Work/Play data
	DECLARE ECursor CURSOR FAST_FORWARD READ_ONLY
	FOR
		SELECT e.EventId,
               e.VehicleIntId,
               e.DriverIntId,
               e.CreationCodeId,
               e.Long,
               e.Lat,
               e.Heading,
               e.Speed,
               e.OdoGPS,
               e.OdoRoadSpeed,
               e.OdoDashboard,
               e.EventDateTime,
               e.DigitalIO,
               e.CustomerIntId,
               e.AnalogData0,
               e.AnalogData1,
               e.AnalogData2,
               e.AnalogData3,
               e.AnalogData4,
               e.AnalogData5,
			   ISNULL(vmcc.VehicleModeId, 0)
		FROM dbo.EventVLE e
		LEFT JOIN dbo.VehicleModeCreationCode vmcc ON vmcc.CreationCodeId = e.CreationCodeId
		WHERE ProcessInd = 1
		ORDER BY e.EventId ASC	
	
	OPEN ECursor
	FETCH NEXT FROM ECursor INTO @eid, @vintid, @dintid, @ccid, @long, @lat, @heading, @speed, @odogps, @odoroadspeed, @ododash, @eventdt, @dio, @customerintid,
								 @analog0, @analog1, @analog2, @analog3, @analog4, @analog5, @vehicleMode

	WHILE @@FETCH_STATUS = 0
	BEGIN	

		SET @vguid = dbo.GetVehicleIdFromInt(@vintid)

		---- attempt to find the vehicle mode from the creation code
		--SELECT @vehicleMode = VehicleModeId FROM VehicleModeCreationCode WHERE CreationCodeId = @ccid
		---- update of vehicle mode on VehicleLatestEvent moved from here to inside work/play evaluation
	
		-- get the driver id based upon the unit type
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
			SET @dintid = CASE WHEN @did IS NULL THEN @dintid ELSE dbo.GetDriverIntFromId(@did) END	
		END 
		
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
			SELECT @lasteventdt = EventDateTime FROM DriverLatestEventTemp WHERE DriverId = @rdid AND Archived is NULL
				
			IF @lasteventdt IS NOT NULL AND @eventdt >= @lasteventdt AND @long <> 0 AND @lat <> 0 AND @ccid NOT IN (0,24,77,78,91,100)
			BEGIN
				UPDATE DriverLatestEventTemp 
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
			ELSE
			BEGIN
				IF @lasteventdt IS NULL AND @long <> 0 AND @lat <> 0 AND @ccid NOT IN (0,24,77,78,91,100) AND @rdid IS NOT NULL
				BEGIN
					INSERT INTO DriverLatestEventTemp (DriverId, EventId, EventDateTime, VehicleId, CreationCodeId, Long, Lat, Heading, Speed, OdoGPS, OdoRoadSpeed, OdoDashboard, DigitalIO, AnalogData0, AnalogData1, AnalogData2, AnalogData3, AnalogData4, AnalogData5)
					VALUES (@rdid, @eid, @eventdt, @dvguid, @ccid, @long, @lat, @heading, @speed, @odogps, @odoroadspeed, @ododash, @dio, @analog0, @analog1, @analog2, @analog3, @analog4, @analog5)
				END
			END
		END

		-- Determine whether customer operates work/play and if so, are we working or playing
		SET @proceed = NULL -- Initialise

		SET @cid = dbo.GetCustomerIdFromInt(@customerintid)
		SELECT @workplaymode = ISNULL(dbo.CustomerPref(@cid, 3001), 0)

				-- Also check if there is any unplanned play
		SELECT @unplannedplay = VehicleUnplannedPlayId
		FROM dbo.VehicleUnplannedPlay
		WHERE VehicleIntId = @vintid AND @eventdt BETWEEN PlayStartDateTime AND PlayEndDateTime

		IF @unplannedplay IS NOT NULL
			SET @proceed = 0 
		
		-- The following work/play evaluation is split so that only events for customers using work/play are analysed
		IF	@workplaymode = 0  -- work/play mode is Off so select every event
			SET @proceed = 1

		IF @proceed IS NULL	
			IF  @workplaymode = 1 -- work/play mode is Driver
					AND ((@playind = 0 AND dbo.IsVehicleWorkingHours(@eventdt, @vintid, @cid) = 1) -- not playing inside working hours
						OR (@playind = 1 AND dbo.IsVehicleWorkingHours(@eventdt, @vintid, @cid) = 0)) -- playing outside working hours (= working)
			SET @proceed = 1
	
		--IF @proceed IS NULL		 		  
		--	IF @workplaymode = 2 -- work/play mode is Switch
		--			AND ((e.Switch = 0 AND dbo.IsVehicleWorkingHours(e.EventDateTime, e.VehicleIntId, @cid) = 1) -- not playing inside working hours
		--			 OR (e.Switch = 1 AND dbo.IsVehicleWorkingHours(e.EventDateTime, e.VehicleIntId, @cid) = 0)) -- playing outside working hours (= working)
		--	SET @proceed = 1

		IF @proceed = 1 AND @unplannedplay IS NULL -- we are in working hours
		BEGIN
		
			-- Update of vehiclemode on VehicleLatestEvent moved to here from above
			UPDATE dbo.VehicleLatestEvent
			SET VehicleMode =
				CASE
					WHEN ((@vehicleMode IS NOT NULL) AND (@vehicleMode > 0)) THEN @vehicleMode
					ELSE VehicleMode
				END
			WHERE VehicleId = @vguid

			-- We are in work mode so clear any row in VehicleInPlay table
			-- TODO: Handle CalAmp login issue for work play
			--		 Driver may have been in play when logged off but next login will put him in Work mode
			--		 Therefore, only delete from VehicleInPlay if receive a driving event for work driver
			--		 Furthermore, don't enter this section if an entry already exists in VehicleInPlay
			--		 If we have deleted a row under these circumstances, also change the login and and later events to the w
			DELETE	
			FROM dbo.VehicleInPlay
			WHERE VehicleIntId = @vintid

			--Now process VehicleLatestEvent
			SET @lasteventdt = NULL
			SET @existingrows = 0 -- initialise value

			-- if current event later than last recorded Vehicle event, update VehicleEventLatest table
			SELECT @lasteventdt = EventDateTime FROM VehicleLatestEventTemp WHERE VehicleId = @vguid AND Archived is NULL
			IF @lasteventdt IS NULL	
			BEGIN 
				-- Try getting latest event datetime from VehicleLatestEvent
				SELECT @lasteventdt = EventDateTime FROM VehicleLatestEvent WHERE VehicleId = @vguid
			END ELSE
			BEGIN
				SET @existingrows = 1 -- we had found a row in the temp table
			END
		
			IF @lasteventdt IS NOT NULL AND @eventdt >= @lasteventdt AND @long <> 0 AND @lat <> 0 AND @ccid NOT IN (0,24,77,78,91,100) AND @existingrows = 1
			BEGIN
				UPDATE VehicleLatestEventTemp 
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
			ELSE
			BEGIN
				IF (@lasteventdt IS NULL OR @eventdt >= @lasteventdt) AND @long <> 0 AND @lat <> 0 AND @ccid NOT IN (0,24,77,78,91,100)
				BEGIN
					INSERT INTO VehicleLatestEventTemp (VehicleId, EventId, EventDateTime, DriverId, CreationCodeId, Long, Lat, Heading, Speed, OdoGPS, OdoRoadSpeed, OdoDashboard, DigitalIO, AnalogData0, AnalogData1, AnalogData2, AnalogData3, AnalogData4, AnalogData5)
					VALUES (dbo.GetVehicleIdFromInt(@vintid), @eid, @eventdt, @did, @ccid, @long, @lat, @heading, @speed, @odogps, @odoroadspeed, @ododash, @dio, @analog0, @analog1, @analog2, @analog3, @analog4, @analog5)
				END
			END
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
		SELECT @lasteventdt = EventDateTime FROM VehicleLatestAllEventTemp WHERE VehicleId = @vguid AND Archived is NULL
		IF @lasteventdt IS NULL	
		BEGIN 
			-- Try getting latest event datetime from VehicleLatestAllEvent
			SELECT @lasteventdt = EventDateTime FROM VehicleLatestAllEvent WHERE VehicleId = @vguid
		END ELSE
		BEGIN
			SET @existingrows = 1 -- we had found a row in the temp table
		END

		IF @lasteventdt IS NOT NULL AND @eventdt >= @lasteventdt AND @existingrows = 1 --AND @long <> 0 AND @lat <> 0 AND @ccid NOT IN (0,24,91,100)
		BEGIN
			UPDATE VehicleLatestAllEventTemp 
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
		ELSE
		BEGIN
			IF (@lasteventdt IS NULL OR @eventdt >= @lasteventdt) --AND @long <> 0 AND @lat <> 0 AND @ccid NOT IN (24,91,100)
			BEGIN
				INSERT INTO VehicleLatestAllEventTemp (VehicleId, EventId, EventDateTime, DriverId, CreationCodeId, Long, Lat, Heading, Speed, OdoGPS, OdoRoadSpeed, OdoDashboard, DigitalIO, AnalogData0, AnalogData1, AnalogData2, AnalogData3, AnalogData4, AnalogData5)
				VALUES (dbo.GetVehicleIdFromInt(@vintid), @eid, @eventdt, @did, @ccid, @long, @lat, @heading, @speed, @odogps, @odoroadspeed, @ododash, @dio, @analog0, @analog1, @analog2, @analog3, @analog4, @analog5)
			END
		END

		----Process Driver Notification reason codes
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

		FETCH NEXT FROM ECursor INTO @eid, @vintid, @dintid, @ccid, @long, @lat, @heading, @speed, @odogps, @odoroadspeed, @ododash, @eventdt, @dio, @customerintid,
									 @analog0, @analog1, @analog2, @analog3, @analog4, @analog5, @vehicleMode
	END

	CLOSE ECursor
	DEALLOCATE ECursor

	-- Delete all processed VLE_Temp rows
	DELETE FROM dbo.EventVLE
	WHERE ProcessInd = 1

	DROP TABLE #VLERunningTable
	
END

GO
