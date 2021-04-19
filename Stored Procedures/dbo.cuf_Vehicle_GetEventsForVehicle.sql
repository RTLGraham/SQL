SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Vehicle_GetEventsForVehicle]
(
	@VehicleId UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME,
	@ccid INT = null,
	@uid uniqueidentifier = NULL
)
AS

--DECLARE @VehicleId UNIQUEIDENTIFIER,
--    @sdate DATETIME,
--    @edate DATETIME,
--    @uid UNIQUEIDENTIFIER

--SET @VehicleId = N'B0783E65-1E23-403A-B75A-0B7B95B64870'
--SET @sdate = '2019-07-10 00:00'
--SET @edate = '2019-07-10 23:59'
--SET @uid = N'D46602E9-8709-4963-A7DE-194FB53A1A3E'

DECLARE @s_date smalldatetime
DECLARE @e_date SMALLDATETIME
SET @s_date = @sdate
SET @e_date = @edate
SET @sdate = dbo.[TZ_ToUTC](@sdate, default, @uid)
SET @edate = dbo.[TZ_ToUTC](@edate, default, @uid)

DECLARE @speedmult FLOAT,
    @distmult FLOAT,
    @tempmult FLOAT,
    @liquidmult FLOAT,
    @timezone nvarchar(30),
    @AnalogAlert1 SMALLINT,
    @AnalogAlert2 SMALLINT,
    @AnalogAlert3 SMALLINT,
    @AnalogAlert4 SMALLINT,
    @AnalogAlert1Name NVARCHAR(MAX),
	@AnalogAlert2Name NVARCHAR(MAX),
	@AnalogAlert3Name NVARCHAR(MAX),
	@AnalogAlert4Name NVARCHAR(MAX),
	@AnalogAlert1Colour NVARCHAR(MAX),
	@AnalogAlert2Colour NVARCHAR(MAX),
	@AnalogAlert3Colour NVARCHAR(MAX),
	@AnalogAlert4Colour NVARCHAR(MAX),
	@Analog1Scaling FLOAT,
	@Analog2Scaling FLOAT,
	@Analog3Scaling FLOAT,
	@Analog4Scaling FLOAT,
	@scount INT,
	@maxDiam FLOAT,
	@workplaymode TINYINT,
	@cid UNIQUEIDENTIFIER,
	@boat BIT	
	
SELECT @maxDiam = dbo.GetUserGeoMaxDiam(@uid)

DECLARE @vehicleintid INT
SET @vehicleintid = dbo.GetVehicleIntFromId(@vehicleid)

SELECT @boat = CASE WHEN vt.Name = 'Motorboat' THEN 1 ELSE 0 END 
FROM dbo.Vehicle v
INNER JOIN dbo.VehicleType vt ON vt.VehicleTypeID = v.VehicleTypeID
WHERE v.VehicleId = @VehicleId

SELECT @scount = COUNT(*)
FROM dbo.VehicleSensor vs
	INNER JOIN dbo.Sensor s ON vs.SensorId = s.SensorId
WHERE vs.VehicleIntId = @vehicleintid
OPTION (KEEPFIXED PLAN)	
		
SET @speedmult = cast(dbo.[UserPref](@uid, 208) as float)
SET @distmult = Cast(dbo.[UserPref](@uid, 202) as float)
SET @tempmult = Cast(ISNULL(dbo.[UserPref](@uid, 214),1) as float)
SET @liquidmult = Cast(ISNULL(dbo.[UserPref](@uid, 200),1) as float)
SET @timezone = dbo.[UserPref](@uid, 600)

SELECT	@workplaymode = ISNULL(dbo.CustomerPref(u.CustomerID, 3001), 0),
		@cid = u.CustomerID
FROM dbo.[User] u
WHERE u.UserID = @uid

SET @AnalogAlert1 = 1
SET @AnalogAlert2 = 2
SET @AnalogAlert3 = 4
SET @AnalogAlert4 = 8

IF @scount > 0
BEGIN		
	SET @AnalogAlert1Name = dbo.CFG_GetTemperatureAlertValueFromHistory(@VehicleId, 'Name_1', GETUTCDATE())
	SET @AnalogAlert2Name = dbo.CFG_GetTemperatureAlertValueFromHistory(@VehicleId, 'Name_2', GETUTCDATE())
	SET @AnalogAlert3Name = dbo.CFG_GetTemperatureAlertValueFromHistory(@VehicleId, 'Name_3', GETUTCDATE())
	SET @AnalogAlert4Name = dbo.CFG_GetTemperatureAlertValueFromHistory(@VehicleId, 'Name_4', GETUTCDATE())

	SET @AnalogAlert1Colour = dbo.CFG_GetTemperatureAlertValueFromHistory(@VehicleId, 'Colour_1', GETUTCDATE())
	SET @AnalogAlert2Colour = dbo.CFG_GetTemperatureAlertValueFromHistory(@VehicleId, 'Colour_2', GETUTCDATE())
	SET @AnalogAlert3Colour = dbo.CFG_GetTemperatureAlertValueFromHistory(@VehicleId, 'Colour_3', GETUTCDATE())
	SET @AnalogAlert4Colour = dbo.CFG_GetTemperatureAlertValueFromHistory(@VehicleId, 'Colour_4', GETUTCDATE())

	SELECT @Analog1Scaling = AnalogSensorScaleFactor FROM dbo.VehicleSensor WHERE VehicleIntId = @vehicleintid AND SensorId = 1
	SELECT @Analog2Scaling = AnalogSensorScaleFactor FROM dbo.VehicleSensor WHERE VehicleIntId = @vehicleintid AND SensorId = 2
	SELECT @Analog3Scaling = AnalogSensorScaleFactor FROM dbo.VehicleSensor WHERE VehicleIntId = @vehicleintid AND SensorId = 3
	SELECT @Analog4Scaling = AnalogSensorScaleFactor FROM dbo.VehicleSensor WHERE VehicleIntId = @vehicleintid AND SensorId = 4
END	

SELECT  e.VehicleIntId,
        e.DriverIntId,
        @VehicleId AS VehicleId,
        dbo.GetDriverIdFromInt(e.DriverIntId) AS DriverId,
        e.CreationCodeId,
        e.Long as SafeNameLong,
        e.Lat,
        e.Heading,
        Cast(Round(e.Speed * @speedmult, 0) as smallint) as Speed,
		e.MaxSpeed,
		--CAST(Round(e.MaxSpeed * @speedmult, 0) AS smallint) as MaxSpeed,
        Cast(Round(e.OdoGPS * @distmult, 0) as int) as OdoGPS,
        Cast(Round(e.OdoRoadSpeed * @distmult, 0) as int) as OdoRoadSpeed,
        Cast(Round(e.OdoDashboard * @distmult, 0) as int) as OdoDashboard,
        dbo.[TZ_GetTime](e.EventDateTime, @timezone,
                                                @uid) as EventDateTime,
        e.DigitalIO,
        e.SpeedLimit,
        e.LastOperation,
        e.Archived,
        e.CustomerIntId,
        e.EventId,
        --dbo.[GetAddressFromLongLat](e.Lat, e.Long) as ReverseGeoCode,
        --dbo.[GetGeofenceNameFromLongLat] (e.Lat, e.Long, @uid, dbo.[GetAddressFromLongLat](e.Lat, e.Long)) as ReverseGeoCode,
        --dbo.[GetGeofenceNameFromLongLat_Ltd] (e.Lat, e.Long, @uid, dbo.[GetAddressFromLongLat](e.Lat, e.Long), @maxDiam) as ReverseGeoCode,
		dbo.[GetGeofenceNameFromLongLat_Ltd] (e.Lat, e.Long, @uid, CASE WHEN @boat = 1 THEN CAST(e.Lat AS VARCHAR(10)) + ', ' + CAST(e.Long AS VARCHAR(10)) ELSE dbo.[GetAddressFromLongLat](e.Lat, e.Long) END, @maxDiam) as ReverseGeoCode,
        CASE WHEN @scount != 0 THEN dbo.ScaleConvertAnalogValue(e.AnalogData0, @Analog1Scaling, @tempmult, @liquidmult) ELSE NULL END AS AnalogData0,
        CASE WHEN @scount != 0 THEN dbo.ScaleConvertAnalogValue(e.AnalogData1, @Analog2Scaling, @tempmult, @liquidmult) ELSE NULL END AS AnalogData1,
        CASE WHEN @scount != 0 THEN dbo.ScaleConvertAnalogValue(e.AnalogData2, @Analog3Scaling, @tempmult, @liquidmult) ELSE NULL END AS AnalogData2,
        CASE WHEN @scount != 0 THEN dbo.ScaleConvertAnalogValue(e.AnalogData3, @Analog4Scaling, @tempmult, @liquidmult) ELSE NULL END AS AnalogData3,
        NULL AS AnalogData4,
        NULL AS AnalogData5,
        
        @AnalogAlert1Name AS AnalogAlert1Name,
		@AnalogAlert2Name AS AnalogAlert2Name,
		@AnalogAlert3Name AS AnalogAlert3Name,
		@AnalogAlert4Name AS AnalogAlert4Name,
		
		@AnalogAlert1Colour AS AnalogAlert1Colour,
		@AnalogAlert2Colour AS AnalogAlert2Colour,
		@AnalogAlert3Colour AS AnalogAlert3Colour,
		@AnalogAlert4Colour AS AnalogAlert4Colour,
        
		CASE WHEN @scount != 0 THEN dbo.TestBits(e.AnalogData5, @AnalogAlert1) ELSE 0 END AS AnalogAlert1Status,
		CASE WHEN @scount != 0 THEN dbo.TestBits(e.AnalogData5, @AnalogAlert2) ELSE 0 END AS AnalogAlert2Status,
		CASE WHEN @scount != 0 THEN dbo.TestBits(e.AnalogData5, @AnalogAlert3) ELSE 0 END AS AnalogAlert3Status,
		CASE WHEN @scount != 0 THEN dbo.TestBits(e.AnalogData5, @AnalogAlert4) ELSE 0 END AS AnalogAlert4Status,

		e.CANStatus,
		e.HardwareStatus
FROM    [dbo].[Event] e WITH (NOLOCK)
LEFT JOIN dbo.VehicleUnplannedPlay vup ON vup.VehicleIntId = e.VehicleIntId AND e.EventDateTime BETWEEN vup.PlayStartDateTime AND vup.PlayEndDateTime
INNER JOIN dbo.Driver d ON d.DriverIntId = e.DriverIntId
LEFT JOIN 
		(
		SELECT tstart.VehicleIntID, tstart.EventID AS StartEvent, ISNULL(tend.EventID, 999999999999) AS EndEvent, wp.PlayInd
		FROM dbo.TripsAndStops tstart
		LEFT JOIN dbo.TripsAndStops tend ON tend.PreviousID = tstart.TripsAndStopsID
		LEFT JOIN dbo.TripsAndStopsWorkPlay wp ON wp.TripsAndStopsId = tstart.TripsAndStopsID
		WHERE tstart.VehicleIntID = @vehicleintid
			AND tstart.Timestamp BETWEEN @sdate AND @edate
			AND tstart.VehicleState = 4
		) trips ON trips.VehicleIntID = e.VehicleIntId AND e.EventId BETWEEN trips.StartEvent AND trips.EndEvent
WHERE   e.EventDateTime BETWEEN @sdate AND @edate
        AND e.VehicleIntId = @vehicleintid
        AND e.CreationCodeId IS NOT NULL
        AND e.CreationCodeId IN (61, 62, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 29, 42, 43, 57, 58, 59, 62, 74, 75, 77, 78, 100, 123)
        AND (e.Lat != 0 AND e.Long != 0)
		AND (@workplaymode IN (0, 4, 5) -- work/play mode is Off, or No Privacy, so select every event
			OR (@workplaymode = 1 -- work/play mode is Driver
								  AND ((ISNULL(d.PlayInd,0) = 0 AND dbo.IsVehicleWorkingHours(e.EventDateTime, e.VehicleIntId, @cid) = 1) -- not playing inside working hours
								   OR (d.PlayInd = 1 AND dbo.IsVehicleWorkingHours(e.EventDateTime, e.VehicleIntId, @cid) = 0)) -- playing outside working hours (= working)		  
			--OR (@workplaymode = 2 -- work/play mode is Switch
			--					  AND ((e.Switch = 0 AND dbo.IsVehicleWorkingHours(e.EventDateTime, e.VehicleIntId, @cid) = 1) -- not playing inside working hours
			--					   OR (e.Switch = 1 AND dbo.IsVehicleWorkingHours(e.EventDateTime, e.VehicleIntId, @cid) = 0)) -- playing outside working hours (= working)
			OR (@workplaymode IN (2, 3) AND ISNULL(trips.PlayInd, 0) = 0) -- Only display events during non-play trips
			)) -- only display work events where customer uses work/play
		AND vup.VehicleUnplannedPlayId IS NULL -- If unplanned play don't show events regardless of work/play settings

ORDER BY e.VehicleintId,
        e.EventDateTime ASC



  





GO
