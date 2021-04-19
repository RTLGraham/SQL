SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Driver_GetEventsForDriver]
(
	@DriverId UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME,
	@ccid INT = null,
	@uid uniqueidentifier = null
)
AS

--DECLARE @DriverId UNIQUEIDENTIFIER,
--    @sdate DATETIME,
--    @edate DATETIME,
--    @uid uniqueidentifier
--
--SET @DriverId = N'BB3428A6-B8A5-4E7A-A081-99806369285F'
--SET @sdate = '2013-11-07 00:00'
--SET @edate = '2013-11-07 23:59'
--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'

--SELECT *
--FROM dbo.Driver
--WHERE Surname != 'UNKNOWN'
--  AND Archived = 0


DECLARE @s_date smalldatetime
DECLARE @e_date smalldatetime
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
	@Analog4Scaling FLOAT

DECLARE @driverintid INT
SET @driverintid = dbo.GetDriverIntFromId(@DriverId)
		
SET @speedmult = cast(dbo.[UserPref](@uid, 208) as float)
SET @distmult = Cast(dbo.[UserPref](@uid, 202) as float)
SET @tempmult = Cast(ISNULL(dbo.[UserPref](@uid, 214),1) as float)
SET @liquidmult = Cast(ISNULL(dbo.[UserPref](@uid, 200),1) as float)
SET @timezone = dbo.[UserPref](@uid, 600)

--SET @AnalogAlert1 = 1
--SET @AnalogAlert2 = 2
--SET @AnalogAlert3 = 4
--SET @AnalogAlert4 = 8
--		
--SET @AnalogAlert1Name = dbo.CFG_GetTemperatureAlertValueFromHistory(@DriverId, 'Name_1', GETUTCDATE())
--SET @AnalogAlert2Name = dbo.CFG_GetTemperatureAlertValueFromHistory(@DriverId, 'Name_2', GETUTCDATE())
--SET @AnalogAlert3Name = dbo.CFG_GetTemperatureAlertValueFromHistory(@DriverId, 'Name_3', GETUTCDATE())
--SET @AnalogAlert4Name = dbo.CFG_GetTemperatureAlertValueFromHistory(@DriverId, 'Name_4', GETUTCDATE())
--
--SET @AnalogAlert1Colour = dbo.CFG_GetTemperatureAlertValueFromHistory(@DriverId, 'Colour_1', GETUTCDATE())
--SET @AnalogAlert2Colour = dbo.CFG_GetTemperatureAlertValueFromHistory(@DriverId, 'Colour_2', GETUTCDATE())
--SET @AnalogAlert3Colour = dbo.CFG_GetTemperatureAlertValueFromHistory(@DriverId, 'Colour_3', GETUTCDATE())
--SET @AnalogAlert4Colour = dbo.CFG_GetTemperatureAlertValueFromHistory(@DriverId, 'Colour_4', GETUTCDATE())
--
--SELECT @Analog1Scaling = AnalogSensorScaleFactor FROM dbo.VehicleSensor WHERE VehicleIntId = @vehicleintid AND SensorId = 1
--SELECT @Analog2Scaling = AnalogSensorScaleFactor FROM dbo.VehicleSensor WHERE VehicleIntId = @vehicleintid AND SensorId = 2
--SELECT @Analog3Scaling = AnalogSensorScaleFactor FROM dbo.VehicleSensor WHERE VehicleIntId = @vehicleintid AND SensorId = 3
--SELECT @Analog4Scaling = AnalogSensorScaleFactor FROM dbo.VehicleSensor WHERE VehicleIntId = @vehicleintid AND SensorId = 4

SELECT  e.DriverIntId,
        e.VehicleIntId,
        v.Registration,
        v.VehicleTypeId,
        @DriverId AS DriverId,
        v.VehicleId,
        e.CreationCodeId,
        e.Long as SafeNameLong,
        e.Lat,
        e.Heading,
        Cast(Round(e.Speed * @speedmult, 0) as smallint) as Speed,
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
        dbo.[GetAddressFromLongLat](e.Lat, e.Long) as ReverseGeoCode,
        --dbo.[GetGeofenceNameFromLongLat_ST] (e.Lat, e.Long, @uid, dbo.[GetAddressFromLongLat](e.Lat, e.Long)) as ReverseGeoCode,
        NULL /*dbo.ScaleConvertAnalogValue(e.AnalogData0, @Analog1Scaling, @tempmult, @liquidmult)*/ AS AnalogData0,
        NULL /*dbo.ScaleConvertAnalogValue(e.AnalogData1, @Analog2Scaling, @tempmult, @liquidmult)*/ AS AnalogData1,
        NULL /*dbo.ScaleConvertAnalogValue(e.AnalogData2, @Analog3Scaling, @tempmult, @liquidmult)*/ AS AnalogData2,
        NULL /*dbo.ScaleConvertAnalogValue(e.AnalogData3, @Analog4Scaling, @tempmult, @liquidmult)*/ AS AnalogData3,
        NULL AS AnalogData4,
        NULL AS AnalogData5,
        
        NULL /*@AnalogAlert1Name*/ AS AnalogAlert1Name,
		NULL /*@AnalogAlert2Name*/ AS AnalogAlert2Name,
		NULL /*@AnalogAlert3Name*/ AS AnalogAlert3Name,
		NULL /*@AnalogAlert4Name*/ AS AnalogAlert4Name,
		
		NULL /*@AnalogAlert1Colour*/ AS AnalogAlert1Colour,
		NULL /*@AnalogAlert2Colour*/ AS AnalogAlert2Colour,
		NULL /*@AnalogAlert3Colour*/ AS AnalogAlert3Colour,
		NULL /*@AnalogAlert4Colour*/ AS AnalogAlert4Colour,
        
		NULL /*dbo.TestBits(e.AnalogData5, @AnalogAlert1)*/ AS AnalogAlert1Status,
		NULL /*dbo.TestBits(e.AnalogData5, @AnalogAlert2)*/ AS AnalogAlert2Status,
		NULL /*dbo.TestBits(e.AnalogData5, @AnalogAlert3)*/ AS AnalogAlert3Status,
		NULL /*dbo.TestBits(e.AnalogData5, @AnalogAlert4)*/ AS AnalogAlert4Status
FROM    [dbo].[Event] e WITH (NOLOCK)
        INNER JOIN Vehicle v ON v.VehicleIntId = e.VehicleIntId
WHERE   e.EventDateTime BETWEEN @sdate AND @edate
        AND e.DriverIntId = @driverintid
        AND e.CreationCodeId IS NOT NULL
        AND e.CreationCodeId != 91
		AND NOT (e.CreationCodeId IN (4,5) AND e.OdoGPS = 0 AND e.Lat = 0 AND e.Long = 0)
        AND ( e.Lat != 0
              AND e.Long != 0
            )
ORDER BY e.DriverIntId,
        e.EventDateTime ASC

GO
