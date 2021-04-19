SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_Track_LatestAllEvent]
(
	@vids NVARCHAR(MAX),
	@uid UNIQUEIDENTIFIER
)
AS

--DECLARE @vids NVARCHAR(MAX),
--		@uid UNIQUEIDENTIFIER;

--SET @vids = N'486A43F1-70D9-46CC-A745-542B6A4D77CE'
--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'

DECLARE @speedmult FLOAT,
		@timediff NVARCHAR(30),
		@curUtcDate DATETIME,
		@vid UNIQUEIDENTIFIER,
--		@depid INT,
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

DECLARE @vehs TABLE (vid UNIQUEIDENTIFIER, vehtype INT)
DECLARE @snsr TABLE 
(
	VehicleId UNIQUEIDENTIFIER, 
	Registration NVARCHAR(20), 
	SensorType CHAR(1), 
	SensorIndex TINYINT, 
	[Description] NVARCHAR(MAX), 
	ShortName NVARCHAR(MAX), 
	Colour NVARCHAR(MAX), 
	[Enabled] BIT
)
DECLARE @scount INT

INSERT INTO @vehs (vid, vehtype)
	SELECT DISTINCT VehicleId, VehicleTypeId
	FROM [dbo].Vehicle 
	WHERE VehicleId IN (SELECT Value FROM dbo.Split(@vids, ','))
	--06.01.2015
	--OPTION (KEEPFIXED PLAN)

INSERT INTO @snsr( VehicleId ,Registration ,SensorType ,SensorIndex ,Description ,ShortName ,Colour ,Enabled)
	SELECT v.VehicleId, v.Registration, SensorType, SensorIndex, Description, ShortName, Colour, Enabled
	FROM dbo.VehicleSensor vs
		INNER JOIN dbo.Sensor s ON vs.SensorId = s.SensorId
		INNER JOIN dbo.Vehicle v ON vs.VehicleIntId = v.VehicleIntId
		INNER JOIN @vehs vd ON v.VehicleId = vd.vid
	WHERE s.SensorType = 'A' AND vs.Enabled = 1
	--06.01.2015
	--OPTION (KEEPFIXED PLAN)
	
SELECT @scount = COUNT(*) FROM @snsr

 --receive Track information
SELECT
	v.vid AS VehicleId,
	v.vehtype AS VehicleType,
	vle.Lat,
	vle.Long,
	CASE WHEN v.vehtype = 5000002
		THEN
			dbo.[GetGeofenceNameFromLongLat_Ltd](vle.Lat, vle.Long, @uid, CAST(vle.Lat AS VARCHAR(MAX)) + '; ' + CAST(vle.Long AS VARCHAR(MAX)) + ';', @maxDiam) 
		ELSE 
			dbo.[GetGeofenceNameFromLongLat_Ltd](vle.Lat, vle.Long, @uid, dbo.[GetAddressFromLongLat] (vle.Lat, vle.Long), @maxDiam) 
		END AS ReverseGeoCode,
	--dbo.[GetGeofenceNameFromLongLat] (vle.Lat, vle.Long, @uid, dbo.[GetAddressFromLongLat] (vle.Lat, vle.Long)) as ReverseGeoCode,
	--dbo.[GetAddressFromLongLat] (e.Lat, e.Long) as ReverseGeoCode,
	vle.Heading AS Direction,
	CAST(vle.Speed * @speedmult AS SMALLINT) AS Speed,
	dbo.[TZ_GetTime]( vle.EventDateTime, @timediff, @uid) AS EventDateTime,
	@queryTime AS QueryTime,
	--vle.EventDateTime AS GMTEventTime,
	dbo.[TZ_GetTime]( vle.EventDateTime, @timediff, @uid) AS GMTEventTime,
	ISNULL(vle.VehicleMode, 0) AS VehicleModeId,
	vle.DriverId AS DriverId,
	vle.AnalogIoAlertTypeId,
	vle.OdoGPS,
	vle.OdoRoadSpeed,
	vle.OdoDashboard,
	CASE WHEN @scount != 0 THEN dbo.GetScaleConvertAnalogValue(vle.AnalogData0, 0, VehicleId, @tempmult, @liquidmult) ELSE NULL END AS AnalogData0,
	CASE WHEN @scount != 0 THEN dbo.GetScaleConvertAnalogValue(vle.AnalogData1, 1, VehicleId, @tempmult, @liquidmult) ELSE NULL END AS AnalogData1,
	CASE WHEN @scount != 0 THEN dbo.GetScaleConvertAnalogValue(vle.AnalogData2, 2, VehicleId, @tempmult, @liquidmult) ELSE NULL END AS AnalogData2,
	CASE WHEN @scount != 0 THEN dbo.GetScaleConvertAnalogValue(vle.AnalogData3, 3, VehicleId, @tempmult, @liquidmult) ELSE NULL END AS AnalogData3,
	NULL AS AnalogData4,
	NULL AS AnalogData5,
	CASE WHEN @scount != 0 THEN dbo.CFG_GetTemperatureAlertValueFromHistory(VehicleId, 'Name_1', GETUTCDATE()) ELSE NULL END AS AnalogAlert1Name,
	CASE WHEN @scount != 0 THEN dbo.CFG_GetTemperatureAlertValueFromHistory(VehicleId, 'Colour_1', GETUTCDATE()) ELSE NULL END AS AnalogAlert1Colour,
	CASE WHEN @scount != 0 THEN dbo.TestBits(vle.AnalogData5, @AnalogAlert1) ELSE 0 END AS AnalogAlert1Status,
	CASE WHEN @scount != 0 THEN dbo.CFG_GetTemperatureAlertValueFromHistory(VehicleId, 'Name_2', GETUTCDATE()) ELSE NULL END AS AnalogAlert2Name,
	CASE WHEN @scount != 0 THEN dbo.CFG_GetTemperatureAlertValueFromHistory(VehicleId, 'Colour_2', GETUTCDATE()) ELSE NULL END AS AnalogAlert2Colour,
	CASE WHEN @scount != 0 THEN dbo.TestBits(vle.AnalogData5, @AnalogAlert2) ELSE 0 END AS AnalogAlert2Status,
	CASE WHEN @scount != 0 THEN dbo.CFG_GetTemperatureAlertValueFromHistory(VehicleId, 'Name_3', GETUTCDATE()) ELSE NULL END AS AnalogAlert3Name,
	CASE WHEN @scount != 0 THEN dbo.CFG_GetTemperatureAlertValueFromHistory(VehicleId, 'Colour_3', GETUTCDATE()) ELSE NULL END AS AnalogAlert3Colour,
	CASE WHEN @scount != 0 THEN dbo.TestBits(vle.AnalogData5, @AnalogAlert3) ELSE 0 END AS AnalogAlert3Status,
	CASE WHEN @scount != 0 THEN dbo.CFG_GetTemperatureAlertValueFromHistory(VehicleId, 'Name_4', GETUTCDATE()) ELSE NULL END AS AnalogAlert4Name,
	CASE WHEN @scount != 0 THEN dbo.CFG_GetTemperatureAlertValueFromHistory(VehicleId, 'Colour_4', GETUTCDATE()) ELSE NULL END AS AnalogAlert4Colour,
	CASE WHEN @scount != 0 THEN dbo.TestBits(vle.AnalogData5, @AnalogAlert4) ELSE 0 END AS AnalogAlert4Status,
	vle.PaxCount
FROM [dbo].VehicleLatestAllEvent vle
INNER JOIN @vehs v ON vle.VehicleId = v.vid

OPTION (KEEPFIXED PLAN)

-- receive Vehicle Entity information
SELECT v.*
FROM [dbo].[Vehicle] v
INNER JOIN @vehs vd ON v.VehicleId = vd.vid
OPTION (KEEPFIXED PLAN)

SELECT VehicleId, Registration, SensorType, SensorIndex, Description, ShortName, Colour, Enabled
FROM @snsr



GO
