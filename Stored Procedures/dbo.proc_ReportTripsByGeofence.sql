SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportTripsByGeofence]
	@vids NVARCHAR(MAX),
	@gids NVARCHAR(MAX) = NULL, 
	@sdate datetime, 
	@edate datetime,
	@reportparameter1 int = 2, 
	@idle int = 5, 
	@uid uniqueidentifier = NULL,
	@maxidle INT = NULL
AS 

--DECLARE	@vids NVARCHAR(MAX),
--		@gids NVARCHAR(MAX),
--		@sdate DATETIME,
--		@edate DATETIME,
--		@reportparameter1 INT,
--		@idle INT,
--		@uid UNIQUEIDENTIFIER

--SET @vids = N'86FD6906-E023-4F97-9F34-48E8C1FB2EB9'
--SET @gids = NULL--'EC5CEEAC-9E02-4951-B87C-1DC95CF6F642'
--SET @sdate = '2018-10-12 00:00'
--SET @edate = '2018-10-12 23:59'
--SET @reportparameter1 = 1
--SET @idle = 15
--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'

DECLARE	@lvids NVARCHAR(MAX),
		@lgids NVARCHAR(MAX),
		@lsdate DATETIME,
		@ledate DATETIME,
		@lreportparameter1 INT,
		@lidle INT,
		@luid UNIQUEIDENTIFIER

SET @lvids = @vids
SET @lgids = @gids
SET @lsdate = @sdate
SET @ledate = @edate
SET @lreportparameter1 = @reportparameter1
SET @lidle = @idle
SET @luid = @uid

SET @lsdate = dbo.TZ_ToUtc(@lsdate, DEFAULT, @luid)
SET @ledate = dbo.TZ_ToUtc(@ledate, DEFAULT, @luid)

DECLARE @state INT,
		@vehicleintid INT,
		@driverintid INT,
		@startvehicleintid INT,
		@startdriverintid INT,
		@starttime DATETIME,
		@endtime DATETIME,
		@startlat FLOAT,
		@endlat FLOAT,
		@startlon FLOAT,
		@endlon FLOAT,
		@duration INT,
		@tripdistance INT,
		@tripstarttime DATETIME,
		@tripstartlat FLOAT,
		@tripstartlon FLOAT,
		@tripendtime DATETIME,
		@tripendlat FLOAT,
		@tripendlon FLOAT,
		@triptotaldistance INT,
		@distunit NVARCHAR(20),
		@diststr VARCHAR(20),
		@distmult FLOAT,
		@maxDiam FLOAT,
		@workplaymode TINYINT,
		@cid UNIQUEIDENTIFIER,
		@startplayind TINYINT,
		@playind TINYINT,
		@gap INT
	
SELECT @maxDiam = dbo.GetUserGeoMaxDiam(@uid)

SELECT  @diststr = [dbo].UserPref(@luid, 203)
SELECT  @distmult = [dbo].UserPref(@luid, 202)

SELECT	@workplaymode = ISNULL(dbo.CustomerPref(u.CustomerID, 3001), 0),
		@cid = u.CustomerID
FROM dbo.[User] u
WHERE u.UserID = @uid

--SET @workplaymode = 0
				
SET @state = CASE WHEN @lreportparameter1 = 1 THEN 4 ELSE 1 END
SET @lidle = CASE WHEN @lreportparameter1 = 1 THEN 0 ELSE @lidle * 60 END
SET @gap = 0 -- Initialise
IF @lgids = '' OR @lgids = '00000000-0000-0000-0000-000000000000'
BEGIN
	SET @lgids = NULL
END
DECLARE @Trips TABLE
(
	VehicleIntId INT,
	DriverIntId INT,
	StartTime DATETIME,
	StartLat FLOAT,
	StartLon FLOAT,
	Duration INT,
	EndTime DATETIME,
	EndLat FLOAT,
	EndLon FLOAT,
	TripDistance INT,
	IsRequested BIT,
	PlayInd TINYINT
)

DECLARE TCursor CURSOR FAST_FORWARD READ_ONLY
FOR 
	SELECT	tstart.VehicleIntID,
			tstart.DriverIntID,
			tstart.Timestamp,
			tstart.Latitude,
			tstart.Longitude,
			tend.Duration,
			tend.Timestamp,
			tend.Latitude,
			tend.Longitude,
			tend.TripDistance,
			CASE WHEN @workplaymode = 2 THEN
				CASE WHEN ISNULL(wp.PlayInd, 1) = 1 THEN 1 ELSE 0 END	
			ELSE
				CASE WHEN ISNULL(wp.PlayInd, 0) = 1 THEN 1 ELSE 0 END
			END AS PlayInd
	FROM dbo.TripsAndStops tstart WITH (NOLOCK)
	LEFT JOIN dbo.TripsAndStopsWorkPlay wp ON wp.TripsAndStopsId = tstart.TripsAndStopsID
	INNER JOIN dbo.TripsAndStops tend WITH (NOLOCK) ON tend.PreviousID = tstart.TripsAndStopsID
	INNER JOIN dbo.Vehicle v ON tstart.VehicleIntID = v.VehicleIntId
	WHERE v.VehicleId IN (SELECT VALUE FROM dbo.Split(@lvids, ',')) 
	  AND tstart.Timestamp BETWEEN @lsdate AND @ledate
	  AND tend.Timestamp BETWEEN @lsdate AND @ledate
	  AND tend.TripDistance > 0
	  AND tstart.VehicleState = @state
	ORDER BY tstart.VehicleIntID, tstart.Timestamp

OPEN TCursor
FETCH NEXT FROM Tcursor INTO @startvehicleintid, @startdriverintid, @tripstarttime, @tripstartlat, @tripstartlon, @duration, @tripendtime, @tripendlat, @tripendlon, @triptotaldistance, @startplayind

WHILE @@FETCH_STATUS = 0
BEGIN

	FETCH NEXT FROM Tcursor INTO @vehicleintid, @driverintid, @starttime, @startlat, @startlon, @duration, @endtime, @endlat, @endlon, @tripdistance, @playind
	SET @gap = @gap + DATEDIFF(SECOND, @tripendtime, @starttime) -- Add seconds between end of previous stop and start of next stop

	IF @@FETCH_STATUS = 0
	BEGIN	
		IF ISNULL(@vehicleintid, 0) != @startvehicleintid
		BEGIN -- vehicle has changed, or we only had one record in the list (when @vehicleintid IS NULL), so write current row
			INSERT INTO @Trips (VehicleIntId, DriverIntId, StartTime, StartLat, StartLon, Duration, EndTime, EndLat, EndLon, TripDistance, PlayInd)
			VALUES  (@startvehicleintid, @startdriverintid, @tripstarttime, @tripstartlat, @tripstartlon, @Duration, @tripendtime, @tripendlat, @tripendlon, @triptotaldistance, @startplayind)
			SET @startvehicleintid = @vehicleintid
			SET @startdriverintid = @driverintid
			SET @tripstarttime = @starttime--
			SET @tripstartlat = @startlat
			SET @tripstartlon = @startlon
			SET @tripendtime = @endtime
			SET @tripendlat = @endlat
			SET @tripendlon = @endlon
			SET @triptotaldistance = @tripdistance
			SET @startplayind = @playind
			SET @gap = 0 
		END ELSE	
		BEGIN -- still processing the same vehicle so continue
			IF @gap >= @lidle -- we were stopped long enough to record a trip end
			BEGIN
				INSERT INTO @Trips (VehicleIntId, DriverIntId, StartTime, StartLat, StartLon, Duration, EndTime, EndLat, EndLon, TripDistance, PlayInd)
				VALUES  (@startvehicleintid, @startdriverintid, @tripstarttime, @tripstartlat, @tripstartlon, @Duration, @tripendtime, @tripendlat, @tripendlon, @triptotaldistance, @startplayind)
				SET @startdriverintid = @driverintid
				SET @tripstarttime = @starttime
				SET @tripstartlat = @startlat
				SET @tripstartlon = @startlon
				SET @tripendtime = @endtime
				SET @tripendlat = @endlat
				SET @tripendlon = @endlon
				SET @triptotaldistance = @tripdistance
				SET @startplayind = @playind
				SET @gap = 0
			END ELSE -- didn't stop long enough so carry the start data forward, but update end data
			BEGIN
				SET @tripendtime = @endtime
				SET @tripendlat = @endlat
				SET @tripendlon = @endlon
				SET @triptotaldistance = @triptotaldistance + @tripdistance
			END
		END	
	END	
END

INSERT INTO @Trips (VehicleIntId, DriverIntId, StartTime, StartLat, StartLon, Duration, EndTime, EndLat, EndLon, TripDistance, PlayInd)
VALUES  (@startvehicleintid, @startdriverintid, @tripstarttime, @tripstartlat, @tripstartlon, @Duration, @tripendtime, @tripendlat, @tripendlon, @triptotaldistance, @startplayind)

CLOSE TCursor
DEALLOCATE TCursor

IF @lgids IS NOT NULL
BEGIN
	-- Identify the resultant trips that start or end in one of the requested geofences
	UPDATE @Trips
	SET IsRequested = 1
	FROM @Trips t
	INNER JOIN dbo.VehicleGeofenceHistory vgh ON t.VehicleIntId = vgh.VehicleIntId 
				AND (t.StartTime BETWEEN vgh.EntryDateTime AND vgh.ExitDateTime OR t.EndTime BETWEEN vgh.EntryDateTime AND vgh.ExitDateTime)
	WHERE vgh.GeofenceId IN (SELECT VALUE FROM dbo.Split(@lgids, ','))
END ELSE
BEGIN
	-- Mark all trips as requested
	UPDATE @Trips 
	SET IsRequested = 1
END


-- Finally return the rows required, but if the customer uses Work/Play then only select if the vehicle was working at the trip start
SELECT	v.Vehicleid,
		v.Registration,
		dbo.FormatDriverNameByUser(d.DriverId, @luid) AS Drivername,
		StartLat,
		StartLon,
        ISNULL([dbo].[GetGeofenceNameFromLongLat_Ltd] (StartLat, StartLon, @luid, [dbo].GetAddressFromLongLat(StartLat, StartLon), @maxDiam), '') AS StartLocation,
        EndLat,
        EndLon,
        ISNULL([dbo].[GetGeofenceNameFromLongLat_Ltd] (EndLat, EndLon, @luid, [dbo].GetAddressFromLongLat(EndLat, EndLon), @maxDiam), '') AS EndLocation,
        dbo.TZ_GetTime(StartTime, DEFAULT, @luid) AS StartDateTime,
        dbo.TZ_GetTime(EndTime, DEFAULT, @luid) AS EndDateTime,
        DATEDIFF(ss, StartTime, EndTime) AS TripDuration,
        TripDistance * @distmult * 100 AS TripDistance,
        @diststr AS DistUnit
FROM @Trips t
LEFT JOIN dbo.VehicleUnplannedPlay vup ON vup.VehicleIntId = t.VehicleIntId AND t.StartTime BETWEEN vup.PlayStartDateTime AND vup.PlayEndDateTime
INNER JOIN dbo.Driver d ON t.DriverIntId = d.DriverIntId
INNER JOIN dbo.Vehicle v ON t.VehicleIntId = v.VehicleIntId
WHERE IsRequested = 1

	AND (@workplaymode IN (0, 4, 5) -- work/play mode is Off, or No Privacy, so select every event
	 OR (@workplaymode = 1 -- work/play mode is Driver
			  AND ((ISNULL(d.PlayInd, 0) = 0 AND dbo.IsVehicleWorkingHours(t.StartTime, t.VehicleIntId, @cid) = 1) -- playing inside working hours
			   OR (ISNULL(d.PlayInd, 0) = 1 AND dbo.IsVehicleWorkingHours(t.StartTime, t.VehicleIntId, @cid) = 0)) -- not playing outside working hours (= working)		  
	OR (@workplaymode IN (2, 3) -- work/play mode is Switch
						  AND t.PlayInd = 0) -- working
	)) -- only display work events where customer uses work/play

  AND vup.VehicleUnplannedPlayId IS NULL -- If unplanned play don't show events regardless of work/play settings


GO
