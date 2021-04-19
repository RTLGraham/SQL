SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportStopsByGeofence]
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
--		@maxidle INT,
--		@uid UNIQUEIDENTIFIER

--SET @vids = N'3D634F73-AFEA-4B04-8E88-F3D84D688ADC'
--SET @gids = NULL--'EC5CEEAC-9E02-4951-B87C-1DC95CF6F642'
--SET @sdate = '2018-04-23 00:00'
--SET @edate = '2018-04-23 23:59'
--SET @reportparameter1 = 1
--SET @idle = 15
--SET @uid = N'AC5FC459-FAF5-48D7-BBBE-88CC5EE824E1'

DECLARE	@lvids NVARCHAR(MAX),
		@lgids NVARCHAR(MAX),
		@lsdate DATETIME,
		@ledate DATETIME,
		@lreportparameter1 INT,
		@lidle INT,
		@lmaxidle INT,
		@luid UNIQUEIDENTIFIER

SET @lvids = @vids
SET @lgids = @gids
SET @lsdate = @sdate
SET @ledate = @edate
SET @lreportparameter1 = @reportparameter1
SET @lidle = @idle
SET @lmaxidle = @maxidle
SET @luid = @uid

SET @lsdate = dbo.TZ_ToUtc(@lsdate, DEFAULT, @luid)
SET @ledate = dbo.TZ_ToUtc(@ledate, DEFAULT, @luid)

DECLARE @state INT,
		@maxDiam FLOAT,
		@workplaymode TINYINT,
		@cid UNIQUEIDENTIFIER,
		@startplayind TINYINT,
		@playind TINYINT
	
SELECT @maxDiam = dbo.GetUserGeoMaxDiam(@luid)

SELECT	@workplaymode = ISNULL(dbo.CustomerPref(u.CustomerID, 3001), 0),
		@cid = u.CustomerID
FROM dbo.[User] u
WHERE u.UserID = @uid

SET @state = CASE WHEN @lreportparameter1 = 1 THEN 5 ELSE 0 END
SET @lidle = CASE WHEN @lreportparameter1 = 1 THEN 0 ELSE @lidle * 60 END
IF @lmaxidle = -999 SET @lmaxidle = NULL -- Needed to handle NULL in RDL
SET @lmaxidle = CASE WHEN @lreportparameter1 = 1 THEN 99999999 ELSE ISNULL(@lmaxidle, 9999999) * 60 END

IF @lgids = '' OR @lgids = '00000000-0000-0000-0000-000000000000'
BEGIN
	SET @lgids = NULL
END
DECLARE @Trips TABLE
(
	VehicleIntId INT,
	DriverIntId INT,
	StopTime DATETIME,
	StopLat FLOAT,
	StopLon FLOAT,
	Gap INT,
	StartTime DATETIME,
	StartLat FLOAT,
	StartLon FLOAT,
	IsRequested BIT,
	PlayInd TINYINT
)

INSERT INTO @Trips (VehicleIntId, DriverIntId, StopTime, StopLat, StopLon, Gap, StartTime, StartLat, StartLon, PlayInd)
SELECT	tstop.VehicleIntID,
		tstop.DriverIntID,
		tstop.Timestamp,
		tstop.Latitude,
		tstop.Longitude,
		tstart.Duration,
		tstart.Timestamp,
		tstart.Latitude,
		tstart.Longitude,
		CASE WHEN @workplaymode = 2 THEN
				CASE WHEN ISNULL(wp.PlayInd, 1) = 1 THEN 1 ELSE 0 END	
			ELSE
				CASE WHEN ISNULL(wp.PlayInd, 0) = 1 THEN 1 ELSE 0 END
			END AS PlayInd
FROM dbo.TripsAndStops tstop WITH (NOLOCK)
LEFT JOIN dbo.TripsAndStops tstart WITH (NOLOCK) ON tstart.PreviousID = tstop.TripsAndStopsID
LEFT JOIN dbo.TripsAndStopsWorkPlay wp ON wp.TripsAndStopsId = tstart.TripsAndStopsID
INNER JOIN dbo.Vehicle v ON tstop.VehicleIntID = v.VehicleIntId
WHERE v.VehicleId IN (SELECT VALUE FROM dbo.Split(@lvids, ',')) 
--	  AND tstart.Timestamp BETWEEN @lsdate AND @ledate
  AND tstop.Timestamp BETWEEN @lsdate AND @ledate
  AND tstop.VehicleState = @state
ORDER BY tstop.VehicleIntID, tstop.Timestamp


IF @lgids IS NOT NULL
BEGIN
	-- Identify the resultant trips that start or end in one of the requested geofences
	UPDATE @Trips
	SET IsRequested = 1
	FROM @Trips t
	INNER JOIN dbo.VehicleGeofenceHistory vgh ON t.VehicleIntId = vgh.VehicleIntId 
				AND (t.StartTime BETWEEN vgh.EntryDateTime AND vgh.ExitDateTime OR t.StopTime BETWEEN vgh.EntryDateTime AND vgh.ExitDateTime)
	WHERE vgh.GeofenceId IN (SELECT VALUE FROM dbo.Split(@lgids, ','))
END ELSE
BEGIN
	-- Mark all trips as requested
	UPDATE @Trips 
	SET IsRequested = 1
END


-- Finally return the rows required, but if the customer uses Work/Play then only select if the vehicle was working at the stop start time
SELECT	v.VehicleId,
		v.Registration,
		dbo.FormatDriverNameByUser(d.DriverId, @luid) AS DriverName,
		StopLat,
		StopLon,
        ISNULL([dbo].[GetGeofenceNameFromLongLat_Ltd] (StopLat, StopLon, @luid, [dbo].GetAddressFromLongLat(StopLat, StopLon), @maxDiam), '') AS Location,
        dbo.TZ_GetTime(StopTime, DEFAULT, @luid) AS Arrival,
        dbo.TZ_GetTime(StartTime, DEFAULT, @luid) AS Departure,
        Gap AS IdleTime
FROM @Trips t
LEFT JOIN dbo.VehicleUnplannedPlay vup ON vup.VehicleIntId = t.VehicleIntId AND t.StopTime BETWEEN vup.PlayStartDateTime AND vup.PlayEndDateTime
INNER JOIN dbo.Driver d ON t.DriverIntId = d.DriverIntId
INNER JOIN dbo.Vehicle v ON t.VehicleIntId = v.VehicleIntId
WHERE IsRequested = 1
  AND Gap BETWEEN @lidle AND @lmaxidle

	AND (@workplaymode IN (0, 4, 5) -- work/play mode is Off, or No Privacy, so select every event
	 OR (@workplaymode = 1 -- work/play mode is Driver
			  AND ((ISNULL(d.PlayInd, 0) = 0 AND dbo.IsVehicleWorkingHours(t.StartTime, t.VehicleIntId, @cid) = 1) -- playing inside working hours
			   OR (ISNULL(d.PlayInd, 0) = 1 AND dbo.IsVehicleWorkingHours(t.StartTime, t.VehicleIntId, @cid) = 0)) -- not playing outside working hours (= working)		  
	OR (@workplaymode IN (2, 3) -- work/play mode is Switch
						  AND t.PlayInd = 0) -- working
	)) -- only display work events where customer uses work/play

  AND vup.VehicleUnplannedPlayId IS NULL -- If unplanned play don't show events regardless of work/play settings






GO
