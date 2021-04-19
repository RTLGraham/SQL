SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_PopulateDriverTrip]
AS

SET NOCOUNT ON

-- First of all check whether or not this process is still running
-- by trying to create a temporary table
SELECT MyVar = 5 INTO #DriverTrip

IF @@ERROR <> 0
BEGIN
	-- do nothing!
	SELECT 0
END ELSE

BEGIN

	-- This job runs every minute and time is required to allow Event Data to be inserted into
	-- the Event table and any idling points to be generated (causing change of vehicle mode)
	-- before calculating trips. A 5 minute delay is incorporated by incrementing 
	-- the Archived column by 1 on each iteration and only processing rows where 
	-- the value exceeds 5
	-- Note that the Archived column on this table has datatype TINYINT rather than BIT to achieve this functionality

	-- Increment the Archived column (will have been inserted with the value 0 initially)
	UPDATE dbo.EventCopyTrip
	SET Archived = Archived + 1

	DECLARE @dintid INT,
			@vintid INT,
			@eventendtime DATETIME,
			@eventstarttime DATETIME,
			@eventid BIGINT,
			@driverintid INT,
			@creationcodeid SMALLINT,
			@eventdatetime DATETIME,
			@OdoGPS BIGINT,
			@lat FLOAT,
			@long FLOAT,
			@vehicleintid INT,
			@starteventid BIGINT,
			@startlat FLOAT,
			@startlong FLOAT,
			@starteventdatetime DATETIME,
			@startdistance BIGINT,
			@startvehicleintid INT,
			@endeventid BIGINT,
			@endvehicleintid INT,
			@endlat FLOAT,
			@endlong FLOAT,
			@endeventdatetime DATETIME,
			@enddistance BIGINT,
			@diststr VARCHAR(20),
			@distmult FLOAT,
			@custid UNIQUEIDENTIFIER,
			@delay INT,
			@db_name NVARCHAR(128)
			
	DECLARE @VehicleList TABLE ( VehicleIntId INT, EventDateTime DATETIME ) 
	DECLARE @DriverList TABLE ( DriverIntId INT, VehicleIntId INT, EventDateTime DATETIME )
	DECLARE @TripTable TABLE 
	( 
		VehicleIntId INT,
		DriverIntId INT,
		StartEventId BIGINT,
		StartLat FLOAT,
		StartLong FLOAT, 
		StartEventDateTime DATETIME, 
		StartDistance BIGINT, 
		EndEventId BIGINT,
		EndLat FLOAT,
		EndLong FLOAT, 
		EndEventDateTime DATETIME, 
		EndDistance BIGINT	
	)
	
	-- Determine how far back to look in events (in hurs) based on database (longer period allowed in Australia)
	SELECT @db_name = DB_NAME()
	IF @db_name = 'AU_Fleetseek_Data'
		SET @delay = -15
	ELSE
		SET @delay = -8

	-- First identify the vehicles recording a Key Off / Driver Change
	INSERT INTO @VehicleList (VehicleIntId, EventdateTime)
	SELECT DISTINCT VehicleIntId, EventDateTime
	FROM dbo.EventCopyTrip ec WITH (NOLOCK)
	WHERE ec.CreationCodeId IN (5,61)
	  AND Archived > 5
	
	-- Now identify the drivers who were driving each vehicle for the trip and the EventTime
	INSERT INTO @DriverList (DriverIntId, VehicleIntId, EventDateTime)
	SELECT DISTINCT vma.StartDriverIntId, tv.VehicleIntId, tv.EventDateTime
	FROM @VehicleList tv
	INNER JOIN dbo.VehicleModeActivity vma WITH (NOLOCK) ON tv.VehicleIntId = vma.VehicleIntId AND tv.EventDateTime BETWEEN vma.StartDate AND ISNULL(vma.EndDate, tv.EventDateTime)


	-- The process from here needs to execute twice
	-- - First for 'normal' drivers by checking for Key On, Key Off and Driver Login Events
	-- - Second for Camera only linked drivers wher we need to check for Trip start and stop events as these are the only ones with distance recorded

	DECLARE DriverCursor CURSOR FAST_FORWARD
	FOR
	SELECT DISTINCT dl.DriverIntId, dl.VehicleIntId, EventDateTime
	FROM @DriverList dl
	INNER JOIN dbo.Driver d ON d.DriverIntId = dl.DriverIntId
	INNER JOIN dbo.Vehicle v ON v.VehicleIntId = dl.VehicleIntId
	LEFT JOIN dbo.VehicleDriver vd ON vd.DriverId = d.DriverId AND vd.Archived = 0 AND vd.EndDate IS NULL
	LEFT JOIN dbo.VehicleCamera vc ON vc.VehicleId = v.VehicleId AND vc.Archived = 0 AND vc.EndDate IS NULL	
	WHERE (vc.VehicleId IS NULL OR (vd.vehicleid IS NULL AND d.Number != 'No ID') OR v.IVHId IS NOT NULL)	-- this indicates the driver is NOT linked to a camera only vehicle
--	INNER JOIN dbo.Driver d ON dl.DriverIntId = d.DriverIntId
--	WHERE ISNULL(d.Number, 0) != 'No ID'

	OPEN DriverCursor
	FETCH NEXT FROM DriverCursor INTO @dintid, @vintid, @eventendtime
	WHILE @@FETCH_STATUS = 0
	BEGIN
			SET @eventstarttime = DATEADD(hh, @delay, @eventendtime)
			-- Initialise variables
			SET @starteventid = 0
			SET @endeventid = 0
			SET @startvehicleintid = 0

			DECLARE TripCursor CURSOR FAST_FORWARD READ_ONLY
			FOR
			SELECT e.eventid, e.Lat, e.Long, e.DriverIntId, e.CreationCodeId, e.EventDateTime, e.VehicleIntId, e.OdoGPS, e.VehicleIntId
			FROM dbo.Event e WITH (NOLOCK)
			WHERE e.EventDateTime BETWEEN @eventstarttime AND @eventendtime
			  AND e.CreationCodeId IN (4,5,61)
			  AND e.VehicleIntId = @vintid
			ORDER BY e.EventId

			OPEN TripCursor
			FETCH NEXT FROM TripCursor INTO @eventid, @lat, @long, @driverintid, @creationcodeid, @eventdatetime, @vehicleintid, @OdoGPS, @vehicleintid
			WHILE @@FETCH_STATUS = 0
			BEGIN
				IF @driverintid = @dintid AND @creationcodeid IN (4,61) -- This is possibly a trip start (but could be a driver logout from a previous vehicle)
				BEGIN
					SET @startvehicleintid = @vehicleintid
					SET @starteventid = @eventid
					SET @startlat = @lat
					SET @startlong = @long
					SET @starteventdatetime = @eventdatetime
					SET @startdistance = @OdoGPS
				END ELSE
				BEGIN
					IF (@creationcodeid = 5 OR (@creationcodeid = 61 AND @driverintid != @dintid)) AND @starteventid != 0 AND @vehicleintid = @startvehicleintid -- This is a trip end
					BEGIN
						SET @endeventid = @eventid
						SET @endlat = @lat
						SET @endlong = @long
						SET @endeventdatetime = @eventdatetime
						SET @enddistance = @OdoGPS
					END		
					IF @vehicleintid != @startvehicleintid -- We didn't have a trip start or end, but the vehicle has changed, so reset the start and end ids
					BEGIN
						SET @starteventid = 0
						SET @endeventid = 0
					END
				END
				
				IF @starteventid != 0 AND @endeventid != 0 -- We have identified a complete trip
				BEGIN
					INSERT INTO @TripTable (VehicleIntId, DriverIntId, StartEventId, StartLat, StartLong, StartEventDateTime, StartDistance, EndEventId, EndLat, EndLong, EndEventDateTime, EndDistance)
					VALUES  (@vehicleintid, @dintid, @starteventid, @startlat, @startlong, @starteventdatetime, @startdistance, @endeventid, @endlat, @endlong, @endeventdatetime, @enddistance)
					-- Reset the trip start and end events
					SET @starteventid = 0
					SET @endeventid = 0
				END
				
				FETCH NEXT FROM TripCursor INTO @eventid, @lat, @long, @driverintid, @creationcodeid, @eventdatetime, @vehicleintid, @OdoGPS, @vehicleintid
			END
			
			CLOSE TripCursor
			DEALLOCATE TripCursor
			
			--Reinitialise variables for next driver
			SET @starteventid = 0
			SET @endeventid = 0
			SET @startvehicleintid = 0
			
			FETCH NEXT FROM DriverCursor INTO @dintid, @vintid, @eventendtime

	END

	CLOSE DriverCursor
	DEALLOCATE DriverCursor	

	-- Now execute second loop for drivers linked to cameras
	-- This loop could be simplified but for now is a copy of the previous loop using different creation codes

	DECLARE DriverCursor CURSOR FAST_FORWARD
	FOR
	SELECT DISTINCT dl.DriverIntId, dl.VehicleIntId, EventDateTime
	FROM @DriverList dl
	INNER JOIN dbo.Driver d ON d.DriverIntId = dl.DriverIntId
	INNER JOIN dbo.Vehicle v ON v.VehicleIntId = dl.VehicleIntId
	LEFT JOIN dbo.VehicleDriver vd ON vd.DriverId = d.DriverId AND vd.Archived = 0 AND vd.EndDate IS NULL
	INNER JOIN dbo.VehicleCamera vc ON vc.VehicleId = v.VehicleId AND vc.Archived = 0 AND vc.EndDate IS NULL	
	WHERE v.IVHId IS NULL	-- this indicates the driver IS linked to a camera only vehicle
--	INNER JOIN dbo.Driver d ON dl.DriverIntId = d.DriverIntId
--	WHERE ISNULL(d.Number, 0) != 'No ID'

	OPEN DriverCursor
	FETCH NEXT FROM DriverCursor INTO @dintid, @vintid, @eventendtime
	WHILE @@FETCH_STATUS = 0
	BEGIN
			SET @eventstarttime = DATEADD(hh, @delay, @eventendtime)
			-- Initialise variables
			SET @starteventid = 0
			SET @endeventid = 0
			SET @startvehicleintid = 0

			DECLARE TripCursor CURSOR FAST_FORWARD READ_ONLY
			FOR
			SELECT e.eventid, e.Lat, e.Long, e.DriverIntId, e.CreationCodeId, e.EventDateTime, e.VehicleIntId, e.OdoGPS, e.VehicleIntId
			FROM dbo.Event e WITH (NOLOCK)
			WHERE e.EventDateTime BETWEEN @eventstarttime AND @eventendtime
			  AND e.CreationCodeId IN (77,78,61)
			  AND e.VehicleIntId = @vintid
			ORDER BY e.EventId

			OPEN TripCursor
			FETCH NEXT FROM TripCursor INTO @eventid, @lat, @long, @driverintid, @creationcodeid, @eventdatetime, @vehicleintid, @OdoGPS, @vehicleintid
			WHILE @@FETCH_STATUS = 0
			BEGIN
				IF @driverintid = @dintid AND @creationcodeid IN (77,61) -- This is possibly a trip start (but could be a driver logout from a previous vehicle)
				BEGIN
					SET @startvehicleintid = @vehicleintid
					SET @starteventid = @eventid
					SET @startlat = @lat
					SET @startlong = @long
					SET @starteventdatetime = @eventdatetime
					SET @startdistance = @OdoGPS
				END ELSE
				BEGIN
					IF (@creationcodeid = 78 OR (@creationcodeid = 61 AND @driverintid != @dintid)) AND @starteventid != 0 AND @vehicleintid = @startvehicleintid -- This is a trip end
					BEGIN
						SET @endeventid = @eventid
						SET @endlat = @lat
						SET @endlong = @long
						SET @endeventdatetime = @eventdatetime
						SET @enddistance = @OdoGPS
					END		
					IF @vehicleintid != @startvehicleintid -- We didn't have a trip start or end, but the vehicle has changed, so reset the start and end ids
					BEGIN
						SET @starteventid = 0
						SET @endeventid = 0
					END
				END
				
				IF @starteventid != 0 AND @endeventid != 0 -- We have identified a complete trip
				BEGIN
					INSERT INTO @TripTable (VehicleIntId, DriverIntId, StartEventId, StartLat, StartLong, StartEventDateTime, StartDistance, EndEventId, EndLat, EndLong, EndEventDateTime, EndDistance)
					VALUES  (@vehicleintid, @dintid, @starteventid, @startlat, @startlong, @starteventdatetime, @startdistance, @endeventid, @endlat, @endlong, @endeventdatetime, @enddistance)
					-- Reset the trip start and end events
					SET @starteventid = 0
					SET @endeventid = 0
				END
				
				FETCH NEXT FROM TripCursor INTO @eventid, @lat, @long, @driverintid, @creationcodeid, @eventdatetime, @vehicleintid, @OdoGPS, @vehicleintid
			END
			
			CLOSE TripCursor
			DEALLOCATE TripCursor
			
			--Reinitialise variables for next driver
			SET @starteventid = 0
			SET @endeventid = 0
			SET @startvehicleintid = 0
			
			FETCH NEXT FROM DriverCursor INTO @dintid, @vintid, @eventendtime

	END

	CLOSE DriverCursor
	DEALLOCATE DriverCursor	
	
	--	 Now insert data (if trip not already inserted)
	INSERT INTO dbo.DriverTrip
			( DriverIntId,
			  VehicleIntId,
			  StartEventDateTime,
			  StartEventID,
			  StartLat,
			  StartLong,
			  StartOdo,
			  EndEventDateTime,
			  EndEventID,
			  EndLat,
			  EndLong,
			  EndOdo,
			  TripDistance,
			  TripDuration,
			  IsBusiness
			)
	SELECT  DISTINCT tt.DriverIntId,
			tt.VehicleIntId,
			tt.StartEventDateTime,
			tt.StartEventId,
			tt.StartLat,
			tt.StartLong,
			tt.StartDistance,
			tt.EndEventDateTime,
			tt.EndEventId,
			tt.EndLat,
			tt.EndLong,
			tt.EndDistance,
			tt.EndDistance - tt.StartDistance,
			DATEDIFF(mi, tt.StartEventDateTime, tt.EndEventDateTime),
			CASE WHEN cp.Value = '1' THEN ISNULL(1 ^ d.PlayInd, 0) ELSE 0 END -- Take the IsBusiness value from Driver.PlayInd when customer uses work/play Driver Mode
	FROM @TripTable tt
	INNER JOIN dbo.Driver d ON d.DriverIntId = tt.DriverIntId
	INNER JOIN dbo.CustomerDriver cd ON cd.DriverId = d.DriverId
	LEFT JOIN dbo.CustomerPreference cp ON cp.CustomerID = cd.CustomerId AND cp.NameID = 3001
	LEFT JOIN dbo.DriverTrip dt ON tt.DriverIntId = dt.DriverIntId AND tt.StartEventId = dt.StartEventID
	WHERE tt.EndDistance - tt.StartDistance > 0
	  AND cd.Archived = 0
	  AND cd.EndDate IS NULL	
	  AND dt.StartEventID IS NULL

	-- Cleanup Processing tables
	DELETE
	FROM dbo.EventCopyTrip
	WHERE Archived > 5

	-- Delete temporary table to indicate job has completed
	DROP TABLE #DriverTrip

END



GO
