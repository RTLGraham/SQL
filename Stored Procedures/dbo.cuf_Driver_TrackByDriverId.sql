SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Driver_TrackByDriverId]
(
	@did UNIQUEIDENTIFIER
)
AS

--DECLARE @did UNIQUEIDENTIFIER
--SET @did = N'301367b7-8822-417a-b9d6-f3513907b2d4'

DECLARE @uid UNIQUEIDENTIFIER

SELECT TOP 1 @uid = u.UserID
	FROM dbo.[User] u
	INNER JOIN dbo.Customer c ON c.CustomerId = u.CustomerID
	INNER JOIN dbo.CustomerDriver cd ON cd.CustomerId = c.CustomerId
	WHERE cd.DriverId = @did
	  AND cd.Archived = 0
	  AND cd.EndDate IS NULL
	  AND u.Archived = 0	


DECLARE @speedmult FLOAT,
		@timediff NVARCHAR(30),
		@curUtcDate DATETIME,
		@date DATETIME,
		@queryTime DATETIME,
		@AnalogAlert1 SMALLINT,
		@AnalogAlert2 SMALLINT,
		@AnalogAlert3 SMALLINT,
		@AnalogAlert4 SMALLINT,
		@tempmult FLOAT,
		@liquidmult FLOAT,
		@maxDiam FLOAT
	
SELECT @maxDiam = dbo.GetUserGeoMaxDiam(@uid)	

SET @speedmult = CAST(dbo.[UserPref](@uid,208) AS FLOAT)
SET @timediff = dbo.[UserPref](@uid, 600)
SET @tempmult = ISNULL(dbo.[UserPref](@uid, 214),1)
SET @liquidmult = ISNULL(dbo.[UserPref](@uid, 200),1)
SET @curUtcDate = GETUTCDATE()
SET @queryTime = dbo.[TZ_GetTime]( @curUtcDate, @timediff, @uid)
SET @AnalogAlert1 = 1
SET @AnalogAlert2 = 2
SET @AnalogAlert3 = 4
SET @AnalogAlert4 = 8

/*
INSERT INTO @snsr( VehicleId ,Registration ,SensorType ,SensorIndex ,Description ,ShortName ,Colour ,Enabled)
	SELECT v.VehicleId, v.Registration, SensorType, SensorIndex, Description, ShortName, Colour, Enabled
	FROM dbo.VehicleSensor vs
		INNER JOIN dbo.Sensor s ON vs.SensorId = s.SensorId
		INNER JOIN dbo.Vehicle v ON vs.VehicleIntId = v.VehicleIntId
		INNER JOIN @vehs vd ON v.VehicleId = vd.vid
	WHERE s.SensorType = 'A' AND vs.Enabled = 1
	--06.01.2015
	--OPTION (KEEPFIXED PLAN)
*/

SELECT TOP 1
	d.DriverId,
	vle.Lat,
	vle.Long,
	dbo.[GetGeofenceNameFromLongLat] (vle.Lat, vle.Long, @uid, dbo.[GetAddressFromLongLat] (vle.Lat, vle.Long)) as ReverseGeoCode,
	vle.Heading AS Direction,
	CAST(vle.Speed * @speedmult AS SMALLINT) as Speed,
	dbo.[TZ_GetTime]( vle.EventDateTime, @timediff, @uid) AS EventDateTime,
	@queryTime AS QueryTime,
	vle.EventDateTime AS GMTEventTime,
	ISNULL(vle.VehicleMode, 0) AS VehicleModeId,
	v.VehicleId,
	v.Registration,
	v.VehicleTypeID,
	vle.AnalogIoAlertTypeId,
	vle.OdoGPS,
	vle.OdoRoadSpeed,
	vle.OdoDashboard,
	dbo.GetScaleConvertAnalogValue(vle.AnalogData0, 0, vle.VehicleId, @tempmult, @liquidmult) AS AnalogData0,
	dbo.GetScaleConvertAnalogValue(vle.AnalogData1, 1, vle.VehicleId, @tempmult, @liquidmult) AS AnalogData1,
	dbo.GetScaleConvertAnalogValue(vle.AnalogData2, 2, vle.VehicleId, @tempmult, @liquidmult) AS AnalogData2,
	dbo.GetScaleConvertAnalogValue(vle.AnalogData3, 3, vle.VehicleId, @tempmult, @liquidmult) AS AnalogData3,
	NULL AS AnalogData4,
	NULL AS AnalogData5,
	dbo.CFG_GetTemperatureAlertValueFromHistory(vle.VehicleId, 'Name_1', GETUTCDATE()) AS AnalogAlert1Name,
	dbo.CFG_GetTemperatureAlertValueFromHistory(vle.VehicleId, 'Colour_1', GETUTCDATE()) AS AnalogAlert1Colour,
	dbo.TestBits(vle.AnalogData5, @AnalogAlert1) AS AnalogAlert1Status,

	
	dbo.CFG_GetTemperatureAlertValueFromHistory(vle.VehicleId, 'Name_2', GETUTCDATE()) AS AnalogAlert2Name,
	dbo.CFG_GetTemperatureAlertValueFromHistory(vle.VehicleId, 'Colour_2', GETUTCDATE()) AS AnalogAlert2Colour,
	dbo.TestBits(vle.AnalogData5, @AnalogAlert2) AS AnalogAlert2Status,

	dbo.CFG_GetTemperatureAlertValueFromHistory(vle.VehicleId, 'Name_3', GETUTCDATE()) AS AnalogAlert3Name,
	dbo.CFG_GetTemperatureAlertValueFromHistory(vle.VehicleId, 'Colour_3', GETUTCDATE()) AS AnalogAlert3Colour,
	dbo.TestBits(vle.AnalogData5, @AnalogAlert3) AS AnalogAlert3Status,

	dbo.CFG_GetTemperatureAlertValueFromHistory(vle.VehicleId, 'Name_4', GETUTCDATE()) AS AnalogAlert4Name,
	dbo.CFG_GetTemperatureAlertValueFromHistory(vle.VehicleId, 'Colour_4', GETUTCDATE()) AS AnalogAlert4Colour,
	dbo.TestBits(vle.AnalogData5, @AnalogAlert4) AS AnalogAlert4Status
FROM [dbo].VehicleLatestEvent vle
INNER JOIN dbo.Driver d ON vle.DriverId = d.DriverId
INNER JOIN dbo.Vehicle v ON vle.VehicleId = v.VehicleId
WHERE vle.DriverId = @did
ORDER BY vle.EventDateTime DESC
OPTION (KEEPFIXED PLAN)






GO
