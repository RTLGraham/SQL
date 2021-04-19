SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_ProcessPassengerCounts] 
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @VehicleId UNIQUEIDENTIFIER,
			@Driverid UNIQUEIDENTIFIER,
			@EventDateTime	DATETIME,
			@EventDataString VARCHAR(1024),
			@Lat FLOAT,
			@Long FLOAT,
			@OdoGPS INT,
			@OdoDashboard INT,
			@CurrCount INT,
			@MaxPax INT
	
	DECLARE @CountData TABLE 
	(
		VehicleId UNIQUEIDENTIFIER,
		DriverId UNIQUEIDENTIFIER,
		EventDateTime DATETIME,
		Lat FLOAT,
		Lon FLOAT,
		OdoGPS INT,
		OdoDashboard INT,
		DoorsOpenSeconds INT,
		A0DeltaIn INT,
		A0DeltaOut INT,
		A1DeltaIn INT,
		A1DeltaOut INT,
		A2DeltaIn INT,
		A2DeltaOut INT,
		A0AbsIn INT,
		A0AbsOut INT,
		A1AbsIn INT,
		A1AbsOut INT,
		A2AbsIn INT,
		A2AbsOut INT
	)

	-- Mark all relevant rows in EDPC
	UPDATE EventDataPassengerCount
	SET Archived = 1 
	
	DECLARE EDPCCursor CURSOR FAST_FORWARD READ_ONLY
	FOR 
		SELECT v.VehicleId, d.DriverId, e.EventDateTime, e.Lat, e.Long, e.OdoGPS, e.OdoDashboard, edpc.EventDataString, v.MaxPax
		FROM dbo.EventDataPassengerCount edpc
		INNER JOIN dbo.Event e ON edpc.EventId = e.EventId
		INNER JOIN dbo.Vehicle v ON edpc.VehicleIntId = v.VehicleIntId
		INNER JOIN dbo.Driver d ON edpc.DriverIntId = d.DriverIntId
		WHERE edpc.Archived = 1
		ORDER BY edpc.EventDateTime ASC

	OPEN EDPCCursor
	FETCH NEXT FROM EDPCCursor INTO @VehicleId, @DriverId, @EventDateTime, @Lat, @Long, @OdoGPS, @OdoDashboard, @EventDataString, @MaxPax
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		DELETE FROM @CountData
		
		-- Populate the table for all config data received
		INSERT INTO @CountData (VehicleId,DriverId,EventDateTime,Lat,Lon,OdoGPS, OdoDashboard,DoorsOpenSeconds,A0DeltaIn,A0DeltaOut,A1DeltaIn,A1DeltaOut,A2DeltaIn,A2DeltaOut,A0AbsIn,A0AbsOut,A1AbsIn,A1AbsOut,A2AbsIn,A2AbsOut)
		SELECT @VehicleId,@DriverId,@EventDateTime,@Lat,@Long,@OdoGPS,@OdoDashboard,DoorsOpenSeconds,A0DeltaIn,A0DeltaOut,A1DeltaIn,A1DeltaOut,A2DeltaIn,A2DeltaOut,A0AbsIn,A0AbsOut,A1AbsIn,A1AbsOut,A2AbsIn,A2AbsOut
		FROM dbo.ParsePassengerCount(@EventDataString)

		-- Now process the data for each row in turn
		
		-- Get the current passenger count	
		SELECT TOP 1 @CurrCount = EndPassengerCount
		FROM dbo.PassengerCount
		WHERE VehicleId = @VehicleId
		ORDER BY DoorsClosedDateTime DESC
		
		IF @CurrCount IS NULL SET @CurrCount = 0
		
		-- Insert New PassengerCount row
		INSERT INTO dbo.PassengerCount
		        ( VehicleId,
				  DriverId,
		          StopLat,
		          StopLon,
		          OdoGPS,
		          OdoDashboard,
		          DoorsOpenDateTime,
		          DoorsClosedDateTime,
		          StartPassengerCount,
		          EndPassengerCount,
		          DeltaInDoor1,
		          DeltaOutDoor1,
		          DeltaInDoor2,
		          DeltaOutDoor2,
		          DeltaInDoor3,
		          DeltaOutDoor3,
		          AbsoluteInDoor1,
		          AbsoluteOutDoor1,
		          AbsoluteInDoor2,
		          AbsoluteOutDoor2,
		          AbsoluteInDoor3,
		          AbsoluteOutDoor3,
		          CalibrationFlag,
		          LastOperation,
		          GeofenceId
		        )
		SELECT	cd.VehicleId, 
				cd.DriverId,
				Lat, 
				Lon, 
				OdoGPS,
				OdoDashboard,
				DATEADD(ss, DoorsOpenSeconds * -1, cd.EventDateTime),
				cd.EventDateTime,
				@CurrCount,			
				CASE WHEN @CurrCount + A0DeltaIn + A1DeltaIn + A2DeltaIn - A0DeltaOut - A1DeltaOut - A2DeltaOut < 0
				THEN 0
				ELSE @CurrCount + A0DeltaIn + A1DeltaIn + A2DeltaIn - A0DeltaOut - A1DeltaOut - A2DeltaOut
--				ELSE CASE WHEN @CurrCount + A0DeltaIn + A1DeltaIn + A2DeltaIn - A0DeltaOut - A1DeltaOut - A2DeltaOut > @MaxPax
--					 THEN @MaxPax
--					 ELSE @CurrCount + A0DeltaIn + A1DeltaIn + A2DeltaIn - A0DeltaOut - A1DeltaOut - A2DeltaOut
--					 END
				END,
--				@CurrCount + A0DeltaIn + A1DeltaIn + A2DeltaIn - A0DeltaOut - A1DeltaOut - A2DeltaOut, -- Calibration disabled
				A0DeltaIn,
				A0DeltaOut,
				A1DeltaIn,
				A1DeltaOut,
				A2DeltaIn,
				A2DeltaOut,
				A0AbsIn,
				A0AbsOut,
				A1AbsIn,
				A1AbsOut,
				A2AbsIn,
				A2AbsOut,
--				-- Calibration Flag: -1 when calibrated to zero; 1 when claibrated to max value; 0 when no calibration
--				0, -- Calibration disabled
				CASE WHEN @CurrCount + A0DeltaIn + A1DeltaIn + A2DeltaIn - A0DeltaOut - A1DeltaOut - A2DeltaOut < 0
				THEN -1
				ELSE 0
--				ELSE CASE WHEN @CurrCount + A0DeltaIn + A1DeltaIn + A2DeltaIn - A0DeltaOut - A1DeltaOut - A2DeltaOut > @MaxPax
--					 THEN 1
--					 ELSE 0
--					 END
				END,			
				GETDATE(),
				g.GeofenceId	
		FROM @CountData cd

		LEFT JOIN 
				(
				SELECT ROW_NUMBER() OVER(PARTITION BY cd.VehicleId, cd.DriverId, cd.EventDateTime ORDER BY cd.VehicleId, cd.VehicleId, cd.EventDateTime, geo.Radius1) AS RowNum, cd.VehicleId, cd.DriverId, cd.EventDateTime, geo.GeofenceId, geo.Name
				FROM @CountData cd
				LEFT JOIN dbo.Geofence geo ON geometry::STPointFromText('POINT('+ CAST(cd.Lon AS NVARCHAR(30)) + ' '+ CAST(cd.Lat AS NVARCHAR(30)) + ')', 4326).STWithin(geo.the_geom) = 1
				INNER JOIN dbo.GroupDetail gd ON geo.GeofenceId = gd.EntityDataId
				INNER JOIN dbo.[Group] g ON gd.GroupId = g.GroupId
				WHERE g.GroupName = 'Omni Serv Route Terminals'
				) g ON cd.VehicleId = g.VehicleId AND cd.driverId = g.Driverid AND cd.EventDateTime = g.EventDateTime AND g.RowNum = 1
		  		
		--Update the latest count on VehicleLatestEvent
		UPDATE dbo.VehicleLatestEvent
		SET PaxCount = CASE WHEN @CurrCount + A0DeltaIn + A1DeltaIn + A2DeltaIn - A0DeltaOut - A1DeltaOut - A2DeltaOut < 0
						THEN 0
--						ELSE CASE WHEN @CurrCount + A0DeltaIn + A1DeltaIn + A2DeltaIn - A0DeltaOut - A1DeltaOut - A2DeltaOut > @MaxPax
--							 THEN @MaxPax
							 ELSE @CurrCount + A0DeltaIn + A1DeltaIn + A2DeltaIn - A0DeltaOut - A1DeltaOut - A2DeltaOut
--							 END
						END
--		SET PaxCount = @CurrCount + A0DeltaIn + A1DeltaIn + A2DeltaIn - A0DeltaOut - A1DeltaOut - A2DeltaOut
		FROM dbo.VehicleLatestEvent vle
		INNER JOIN @CountData cd ON vle.VehicleId = cd.VehicleId

		FETCH NEXT FROM EDPCCursor INTO @VehicleId, @DriverId, @EventDateTime, @Lat, @Long, @OdoGPS, @OdoDashboard, @EventDataString, @MaxPax
	END
	CLOSE EDPCCursor
	DEALLOCATE EDPCCursor	

	-- Clean up processed rows
	DELETE FROM dbo.EventDataPassengerCount
	WHERE Archived = 1 
	
END
GO
