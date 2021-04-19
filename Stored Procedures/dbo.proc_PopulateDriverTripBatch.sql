SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_PopulateDriverTripBatch]
AS

SET NOCOUNT ON

DECLARE @sdate DATETIME,
		@edate DATETIME
		
-- Set sdate and edate for entire of yesterday - this script should be run no earlier than 6am to allow trips from before midnight to complete
-- To recalculate data: delete from DriverTrip for given dates and hard code the start and end dates to re-populate
SET @sdate = '2016-07-26 00:00'
SET @edate = '2016-07-27 23:59'

DECLARE @dintid INT,
		@eventid BIGINT,
		@driverintid INT,
		@creationcodeid SMALLINT,
		@eventdatetime DATETIME,
		@OdoGPS INT,
		@lat FLOAT,
		@long FLOAT,
		@vehicleintid INT,
		@starteventid BIGINT,
		@startvehicleintid INT,
		@startlat FLOAT,
		@startlong FLOAT,
		@starteventdatetime DATETIME,
		@startdistance INT,
		@endeventid BIGINT,
		@endvehicleintid INT,
		@endlat FLOAT,
		@endlong FLOAT,
		@endeventdatetime DATETIME,
		@enddistance INT,
		@diststr VARCHAR(20),
		@distmult FLOAT,
        @custid UNIQUEIDENTIFIER
		
DECLARE @VehicleList TABLE ( VehicleIntId INT )
DECLARE @DriverList TABLE ( DriverIntId INT )
DECLARE @TripTable TABLE 
( 
	VehicleIntId INT,
	DriverIntId INT,
	StartEventId BIGINT,
	StartLat FLOAT,
	StartLong FLOAT, 
	StartEventDateTime DATETIME, 
	StartDistance INT, 
	EndEventId BIGINT,
	EndLat FLOAT,
	EndLong FLOAT, 
	EndEventDateTime DATETIME, 
	EndDistance INT	
)

INSERT INTO @DriverList	(DriverIntId)
SELECT DISTINCT e.DriverIntId
FROM dbo.Event e WITH (NOLOCK)
--INNER JOIN dbo.Customer c ON e.CustomerIntId = c.CustomerIntId
--INNER JOIN dbo.MileageClaimCustomer mcc ON c.CustomerId = mcc.CustomerId
WHERE e.EventDateTime BETWEEN @sdate AND @edate
  AND e.CreationCodeId IN (5,61) 

  --AND e.DriverIntId IN (20778, 20779)
  --AND e.DriverIntId > 20500

SET @starteventid = 0
SET @endeventid = 0
SET @startvehicleintid = 0

DECLARE DriverCursor CURSOR FAST_FORWARD
FOR
SELECT dl.DriverIntId
FROM @DriverList dl
--INNER JOIN dbo.Driver d ON dl.DriverIntId = d.DriverIntId
--WHERE ISNULL(d.Number, 0) != 'No ID'

OPEN DriverCursor
FETCH NEXT FROM DriverCursor INTO @dintid
WHILE @@FETCH_STATUS = 0
BEGIN
		DELETE FROM @VehicleList
		INSERT INTO @VehicleList (VehicleintId)
		SELECT DISTINCT e.VehicleIntId
		FROM dbo.Event e WITH (NOLOCK)
		WHERE e.DriverIntId = @dintid
		  AND e.EventDateTime BETWEEN @sdate AND @edate

		DECLARE TripCursor CURSOR FAST_FORWARD READ_ONLY
		FOR
		SELECT e.eventid, e.Lat, e.Long, e.DriverIntId, e.CreationCodeId, e.EventDateTime, e.VehicleIntId, e.OdoGPS, e.VehicleIntId
		FROM dbo.Event e WITH (NOLOCK)
		INNER JOIN @VehicleList vl ON e.VehicleIntId = vl.VehicleintId
		WHERE e.EventDateTime BETWEEN @sdate AND @edate
		  AND e.CreationCodeId IN (4,5,61)
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
				IF @vehicleintid != @startvehicleintid -- We didn't have a trip start or end, but the vehicle has changed, so reset the start id
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
		
		FETCH NEXT FROM DriverCursor INTO @dintid

END

CLOSE DriverCursor
DEALLOCATE DriverCursor	
		
-- Now insert data (if trip not already inserted)
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
SELECT  tt.DriverIntId,
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






GO
