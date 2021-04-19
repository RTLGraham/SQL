SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







-- Stored Procedure

---- ==========================================================================
---- Author:	  Graham Pattison
---- Create date: 07-05-2015
---- Description: Takes data from CAM_Event table and inserts into Event taking
----			  event data from every minute rather than every second
---- Updated:     09-08-2016 : GKP : Select more columns in main select clauses
----								 and pass to WriteEvent as parameters
---- ==========================================================================
CREATE PROCEDURE [dbo].[proc_ProcessCAMEventGPS]
AS

-- First of all check whether or not this process is still running
-- by trying to create a temprary table
SELECT MyVar = 5 INTO #Process_CAMEvent

IF @@ERROR <> 0
BEGIN
	-- do nothing!
	SELECT 0
END ELSE

BEGIN
	SET NOCOUNT ON;

	DECLARE @VehicleId UNIQUEIDENTIFIER,
			@p_VehicleId UNIQUEIDENTIFIER,
			@TripStart DATETIME,
			@TripStop DATETIME,
			@EventDateTime DATETIME,
			@p_EventDateTime DATETIME,
			@CreationCodeId SMALLINT,
			@Lat FLOAT,
			@Long FLOAT,
			@Speed SMALLINT,
			@Heading SMALLINT,
			@Elapsed INT,
			@Distance INT,
			@p_Distance INT,
			@Odo INT,
			@eid BIGINT,
			@starteid BIGINT,
			@stopeid BIGINT,
			@vintid INT,
			@dintid INT,
			@customerintid INT,
			@driverid UNIQUEIDENTIFIER,
			@ivhid UNIQUEIDENTIFIER,
			@customerid UNIQUEIDENTIFIER,
			@tsid BIGINT,
			@timestamp DATETIME,
			@latestodoid INT,
			@lateststoptime DATETIME,
			@startlat FLOAT,
			@startlon FLOAT,
			@endlat FLOAT,
			@endlon FLOAT,
			@logId BIGINT,
			@startTime DATETIME,
			@sdateinthepast DATETIME

	SET @sdateinthepast = '1900-01-01 00:00'

	-- Create Log Entry
	--SET @startTime = GETDATE()
	--INSERT INTO dbo.CamProcessLog (SP, StartTime) VALUES ('Process CAMEventGPS', @startTime)
	--SET @logId = SCOPE_IDENTITY()

	-- First process the CAM_Event data - all rows need to be inserted into the Event table

	-- Mark all CAM_Event rows as in process
	UPDATE dbo.CAM_Event
	SET Archived = 1
	WHERE Archived = 0

	DECLARE ECursor CURSOR FAST_FORWARD READ_ONLY
	FOR
		SELECT  ce.VehicleId, v.VehicleIntId, cv.CustomerId, c.CustomerIntId, vd.DriverId, v.IVHId, ce.EventDateTime,
			    ce.Lat, ce.Long, 
				ISNULL(ce.Speed, 0), ISNULL(ce.Heading, 0), ISNULL(etcc.CreationCodeId, 0)
		FROM dbo.CAM_Event ce
		INNER JOIN dbo.Vehicle v ON v.VehicleId = ce.VehicleId
		LEFT JOIN dbo.VehicleLatestEvent vle ON vle.VehicleId = v.VehicleId
		LEFT JOIN dbo.VehicleDriver vd ON vd.VehicleId = v.VehicleId AND vd.Archived = 0 AND vd.Archived = 0 AND GETDATE() >= ISNULL(vd.StartDate, @sdateinthepast) AND vd.EndDate IS NULL	
		INNER JOIN CustomerVehicle cv ON v.VehicleId = cv.VehicleId
		INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
		INNER JOIN dbo.CAM_EventTypeCreationCode etcc ON ce.EventType = etcc.EventType
		--WHERE Lat != 0 AND Long != 0 AND ce.Archived = 1 AND etcc.Archived = 0
		WHERE ce.Archived = 1 AND etcc.Archived = 0
		  AND v.IVHId IS NULL -- Only process rows for vehicles that do not have a telematics unit
		AND v.Archived = 0 AND cv.Archived = 0
		AND GETDATE() >= ISNULL(cv.StartDate, @sdateinthepast) AND cv.EndDate IS NULL
		ORDER BY ce.VehicleID, ce.EventDateTime 

	OPEN ECursor
	FETCH NEXT FROM ECursor INTO @VehicleId, @vintid, @customerid, @customerintid, @driverid, @ivhid, @EventDateTime, @Lat, @Long, @Speed, @Heading, @CreationCodeId

	WHILE @@FETCH_STATUS = 0
	BEGIN
		--If ignition events are w/o location information - use the last known
		IF @Lat = 0 AND @Long = 0 AND @CreationCodeId IN (4, 5)
		BEGIN
			SELECT @Lat = Lat, @Long = Long
			FROM dbo.VehicleLatestEventTemp
			WHERE VehicleId = @VehicleId
			ORDER BY EventDateTime DESC
		END
		IF @Lat = 0 AND @Long = 0 AND @CreationCodeId IN (4, 5)
		BEGIN
			SELECT @Lat = Lat, @Long = Long
			FROM dbo.VehicleLatestEvent
			WHERE VehicleId = @VehicleId
			ORDER BY EventDateTime DESC
		END

		IF @Lat != 0 AND @Long != 0
		BEGIN
			EXEC dbo.proc_WriteCAMEventTemp @vid = @VehicleId,
				@vintid = @vintid, 
				@customerid = @customerid,
				@customerintid = @customerintid,
				@did = @driverid, 
				@ivhid = @ivhid,
				@ccid = @CreationCodeId, 
				@long = @Long, 
				@lat = @Lat, 
				@heading = @Heading, 
				@speed = @Speed, 
				@odogps = 0, 
				@odotrip = 0, 
				@eventdt = @EventDateTime, 
				@dintid = NULL,
				@eid = NULL
		END

		FETCH NEXT FROM ECursor INTO @VehicleId, @vintid, @customerid, @customerintid, @driverid, @ivhid, @EventDateTime, @Lat, @Long, @Speed, @Heading, @CreationCodeId
	END

	CLOSE ECursor
	DEALLOCATE ECursor	

	-- Delete all processed CAM_Event rows
	DELETE
	FROM dbo.CAM_Event
	WHERE Archived = 1

	-- Now process CAM_TripIn to generate Trips and Stops data, Events with OdoGPS and Reporting data 

	-- Mark all CAM_TripIn rows as in process
	UPDATE dbo.CAM_TripIn
	SET ProcessInd = 1
	WHERE ProcessInd = 0

	----DEBUG - copy Trips for vehicle int 1164 to temporary table
	--INSERT INTO dbo.CAM_TripIn_1164
	--        ( ProjectId ,
	--          VehicleId ,
	--          TripStart ,
	--          TripStop ,
	--          TripDistance ,
	--          LastOperation ,
	--          ProcessInd ,
	--          TripState ,
	--          TripStartLat ,
	--          TripStartLon ,
	--          TripEndLat ,
	--          TripEndLon
	--        )
	--SELECT t.ProjectId ,
 --          t.VehicleId ,
 --          t.TripStart ,
 --          t.TripStop ,
 --          t.TripDistance ,
 --          t.LastOperation ,
 --          t.ProcessInd ,
 --          t.TripState ,
 --          t.TripStartLat ,
 --          t.TripStartLon ,
 --          t.TripEndLat ,
 --          t.TripEndLon 
	--FROM dbo.CAM_TripIn t
	--INNER JOIN dbo.Vehicle v ON v.VehicleId = t.VehicleId
	--WHERE v.VehicleIntId = 1164

	DECLARE TCursor CURSOR FAST_FORWARD READ_ONLY
	FOR
		SELECT  t.VehicleId, v.VehicleIntId, c.CustomerId, c.CustomerIntId, vd.DriverId, d.DriverIntId, v.IVHId, t.TripStart, t.TripStop, ISNULL(t.TripDistance, 0), t.TripStartLat, t.TripStartLon, t.TripEndLat, t.TripEndLon
		FROM dbo.CAM_TripIn t
		INNER JOIN dbo.Vehicle v ON v.VehicleId = t.VehicleId
		INNER JOIN CustomerVehicle cv ON v.VehicleId = cv.VehicleId
		INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
		LEFT JOIN dbo.VehicleDriver vd ON vd.VehicleId = v.VehicleId AND vd.Archived = 0 AND GETDATE() >= ISNULL(vd.StartDate, @sdateinthepast) AND vd.EndDate IS NULL
		LEFT JOIN dbo.Driver d ON d.DriverId = vd.DriverId
		WHERE t.ProcessInd = 1
		  AND t.TripState = 'closed'
		  AND v.IVHId IS NULL -- Only process rows for vehicles that do not have a telematics unit
		  AND v.Archived = 0 AND cv.Archived = 0
		  AND GETDATE() >= ISNULL(cv.StartDate, @sdateinthepast) AND cv.EndDate IS NULL
		  

	OPEN TCursor
	FETCH NEXT FROM TCursor INTO @VehicleId, @vintid, @customerid, @customerintid, @driverid, @dintid, @ivhid, @TripStart, @TripStop, @Distance, @startlat, @startlon, @endlat, @endlon
	WHILE @@FETCH_STATUS = 0
	BEGIN

		-- Initialise variables
		SET @starteid = NULL
		SET @stopeid = NULL
		SET @latestodoid = NULL

		-- First Get the Latest Odo and Stop Time from VehicleLatestOdometer for the vehicle 
		SELECT	@Odo = OdoGPS, @latestodoid = VehicleLatestOdometerId, @lateststoptime = EventDateTime
		FROM dbo.VehicleLatestOdometer
		WHERE VehicleId = @VehicleId

		SELECT @Odo = ISNULL(@Odo, 0)
		SELECT @lateststoptime = ISNULL(@lateststoptime, '2015-01-01 00:00')

		-- Only proceed to write the trip/stop data if more than 20 seconds has elapsed since the previous stop time
		IF DATEDIFF(ss, @lateststoptime, @TripStop) > 20
		BEGIN

			-- First write Start and Stop Event
			EXEC dbo.proc_WriteCAMEventTemp @vid = @VehicleId,
				@vintid = @vintid, 
				@customerid = @customerid,
				@customerintid = @customerintid,
				@did = @driverid, 
				@ivhid = @ivhid,
				@ccid = 77, 
				@long = @startlon, 
				@lat = @startlat, 
				@heading = 0, 
				@speed = 0, 
				@odogps = @Odo, 
				@odotrip = 0, 
				@eventdt = @TripStart, 
				@dintid = @dintid OUTPUT,
				@eid = @starteid OUTPUT

			SET @Odo = @Odo + @Distance
			EXEC dbo.proc_WriteCAMEventTemp @vid = @VehicleId,
				@vintid = @vintid, 
				@customerid = @customerid,
				@customerintid = @customerintid,
				@did = @driverid, 
				@ivhid = @ivhid,
				@ccid = 78, 
				@long = @endlon, 
				@lat = @endlat, 
				@heading = 0, 
				@speed = 0, 
				@odogps = @Odo, 
				@odotrip = 0, 
				@eventdt = @TripStop, 
				@dintid = @dintid OUTPUT,
				@eid = @stopeid OUTPUT

			-- Now insert or update the VehicleLatestOdometer
			IF @latestodoid IS NULL	
			BEGIN
				INSERT INTO dbo.VehicleLatestOdometer (VehicleId, OdoGPS, EventDateTime, LastOperation, Archived)
				VALUES  (@VehicleId, @Odo, @TripStop, GETDATE(), 0)
			END ELSE
			BEGIN
				UPDATE dbo.VehicleLatestOdometer
				SET OdoGPS = @Odo, EventDateTime = @TripStop
				WHERE VehicleId = @VehicleId
			END	

			-- Now write Trips and Stops Rows
			-- First get most recent trips and stops row for the vehicle
			SET @tsid = NULL -- Initialise variable
			SELECT TOP 1 @tsid = TripsAndStopsID, @timestamp = Timestamp
			FROM dbo.TripsAndStopsTemp
			WHERE VehicleIntID = @vintid
			ORDER BY Timestamp DESC	

			IF @tsid IS NULL -- read again from main TripsAndStops table
				SELECT TOP 1 @tsid = TripsAndStopsID, @timestamp = Timestamp
				FROM dbo.TripsAndStops
				WHERE VehicleIntID = @vintid
				ORDER BY Timestamp DESC	

			IF @tsid IS NULL 
			BEGIN
				SET @tsid = -1
				SET @timestamp = GETUTCDATE()
			END	

			-- Write trip start
			INSERT INTO dbo.TripsAndStopsTemp (EventID, CustomerIntID, IVHIntID, VehicleIntID, DriverIntID, VehicleState, Timestamp, Latitude, Longitude,
												PreviousID, TripDistance, Duration, Archived, BrokenData)
			VALUES  (@starteid, @customerintid, NULL, @vintid, @dintid, 4, @TripStart, @startlat, @startlon,
					 @tsid, 0, CASE WHEN DATEDIFF(ss, @timestamp, @TripStart) < 0 THEN 0 ELSE DATEDIFF(ss, @timestamp, @TripStart) END, 0, 0)

					SET @tsid = SCOPE_IDENTITY()
			-- Write trip end
			INSERT INTO dbo.TripsAndStopsTemp (EventID, CustomerIntID, IVHIntID, VehicleIntID, DriverIntID, VehicleState, Timestamp, Latitude, Longitude,
												PreviousID, TripDistance, Duration, Archived, BrokenData)

			VALUES  (@stopeid, @customerintid, NULL, @vintid, @dintid, 5, @TripStop, @endlat, @endlon,
					 @tsid, @Distance/100, DATEDIFF(ss, @TripStart, @TripStop), 0, 0)

			-- Finally write data to Reporting to record distance using MERGE to UPDATE if exists else INSERT a row
			-- This section only required if vehicle not fitted with a tracker
			--SELECT @ivhid = IVHId FROM dbo.Vehicle WHERE VehicleIntId = @vintid
			
			IF @ivhid IS NULL
            BEGIN				
				MERGE dbo.Reporting r
				USING ( SELECT v.VehicleIntId, @dintid, CAST(FLOOR(CAST(@TripStop AS FLOAT)) AS DATETIME), @Distance / 1000.0, vle.OdoGPS
						FROM dbo.Vehicle v
						INNER JOIN dbo.VehicleLatestOdometer vle ON vle.VehicleId = v.VehicleId
						WHERE v.VehicleIntId = @vintid ) AS s (VehicleIntId, DriverIntId, Date, DrivingDistance, Odogps)
				ON r.VehicleIntId = s.VehicleIntId AND r.DriverIntId = s.DriverIntId AND r.Date = s.Date
				WHEN MATCHED THEN UPDATE SET r.DrivingDistance = r.DrivingDistance + s.DrivingDistance, r.LatestOdoGPS = s.Odogps
				WHEN NOT MATCHED THEN INSERT (VehicleIntId, DriverIntId, Date, DrivingDistance, PTOMovingDistance, EarliestOdoGPS, LatestOdoGPS) 
									  VALUES (s.VehicleIntId, s.DriverIntId, s.Date, s.DrivingDistance, 0, s.Odogps, s.Odogps);
			END	

		END -- Write trip stop data

		FETCH NEXT FROM TCursor INTO @VehicleId, @vintid, @customerid, @customerintid, @driverid, @dintid, @ivhid, @TripStart, @TripStop, @Distance, @startlat, @startlon, @endlat, @endlon
	END

	CLOSE TCursor
	DEALLOCATE TCursor

	-- Delete all processed CAM_TripIn rows
	DELETE
	FROM dbo.CAM_TripIn
	WHERE ProcessInd = 1

	-- Now process the CAM_GPS data - One row per vehicle per minute needs to be inserted into the Event table

	-- Mark all CAM_GPSIn rows as in process
	UPDATE dbo.CAM_GPSIn
	SET ProcessInd = 1
	WHERE ProcessInd = 0

	DECLARE GCursor CURSOR FAST_FORWARD READ_ONLY
	FOR
		SELECT  g.VehicleId, v.VehicleIntId, v.IVHId, c.CustomerId, c.CustomerIntId, d.DriverId, d.DriverIntId, EventDateTime, Lat, Long, Speed, Heading, Distance
		FROM dbo.CAM_GPSIn g
		INNER JOIN dbo.Vehicle v ON v.VehicleId = g.VehicleId
		INNER JOIN CustomerVehicle cv ON v.VehicleId = cv.VehicleId
		INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
		LEFT JOIN dbo.VehicleDriver vd ON vd.VehicleId = v.VehicleId AND vd.Archived = 0 AND GETDATE() >= ISNULL(vd.StartDate, @sdateinthepast) AND vd.EndDate IS NULL
		LEFT JOIN dbo.Driver d ON d.DriverId = vd.DriverId
		WHERE Lat != 0 AND Long != 0 AND g.ProcessInd = 1
		  AND v.IVHId IS NULL	-- Only process rows for vehicles that do not have a telematics unit
		  AND v.Archived = 0 AND cv.Archived = 0
		  AND GETDATE() >= ISNULL(cv.StartDate, @sdateinthepast) AND cv.EndDate IS NULL
		  
		ORDER BY g.VehicleID, EventDateTime 

	-- Initialise loop variables
	SET @p_VehicleId = NULL
	SET @Elapsed = 0
	SET @p_Distance = 0

	OPEN GCursor
	FETCH NEXT FROM GCursor INTO @VehicleId, @vintid, @ivhid, @customerid, @customerintid, @driverid, @dintid, @EventDateTime, @Lat, @Long, @Speed, @Heading, @Distance

	WHILE @@FETCH_STATUS = 0
	BEGIN

			EXEC dbo.proc_WriteCAMEventTemp @vid = @VehicleId,
				@vintid = @vintid, 
				@customerid = @customerid,
				@customerintid = @customerintid,
				@did = @driverid, 
				@ivhid = @ivhid,
				@ccid = 1, 
				@long = @Long, 
				@lat = @Lat, 
				@heading = @Heading, 
				@speed = @Speed, 
				@odogps = 0, 
				@odotrip = 0, 
				@eventdt = @EventDateTime, 
				@dintid = NULL,
				@eid = NULL

		FETCH NEXT FROM GCursor INTO @VehicleId, @vintid, @ivhid, @customerid, @customerintid, @driverid, @dintid, @EventDateTime, @Lat, @Long, @Speed, @Heading, @Distance
	END

	CLOSE GCursor
	DEALLOCATE GCursor	

	-- Delete all processed CAM_GPSIn rows
	DELETE
	FROM dbo.CAM_GPSIn
	WHERE ProcessInd = 1

	-- Update Log Entry
	--UPDATE dbo.CamProcessLog
	--SET EndDate = GETDATE(), ElapsedTimeSS = DATEDIFF(ss, @startTime, GETDATE())
	--WHERE RecordID = @logId

	-- Delete temporary table to indicate job has completed
	DROP TABLE #Process_CAMEvent

END



GO
