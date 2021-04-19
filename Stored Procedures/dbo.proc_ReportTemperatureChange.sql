SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportTemperatureChange]
(
	@vid UNIQUEIDENTIFIER = NULL,
	@gid UNIQUEIDENTIFIER = NULL,
    @uid UNIQUEIDENTIFIER = NULL,
    @dio INT,
	@sdate DATETIME = NULL, 
	@edate DATETIME = NULL
)
AS

--DECLARE	@sdate DATETIME,
--		@edate DATETIME,
--		@uid UNIQUEIDENTIFIER,
--		@vid UNIQUEIDENTIFIER,
--		@gid UNIQUEIDENTIFIER,
--		@dio INT
		
--SET @vid = N'BE8FBF38-57CE-42E8-AC53-D67166463191'
--SET @uid = N'5A183811-A76E-43E3-91A3-8CD60AF55EF3'
--SET @sdate = '2012-12-17 00:00'
--SET @edate = '2012-12-17 23:59'
--SET @dio = 12
--SET @gid = N'5483993E-7C16-4EEE-AAC9-DCC3E6508683'


DECLARE @depid INT,
		@onoff BIT,
		@s_date DATETIME,
		@e_date DATETIME,
		@AnalogAlert1 SMALLINT,
		@AnalogAlert2 SMALLINT,
		@AnalogAlert3 SMALLINT,
		@AnalogAlert4 SMALLINT,
		@Sensor1Enabled BIT,
		@Sensor2Enabled BIT,
		@Sensor3Enabled BIT,
		@Sensor4Enabled BIT,
		@Sensor1Name NVARCHAR(MAX),
		@Sensor2Name NVARCHAR(MAX),
		@Sensor3Name NVARCHAR(MAX),
		@Sensor4Name NVARCHAR(MAX),
		@tempmult FLOAT,
		@liquidmult FLOAT,
		@tempstring NVARCHAR(MAX)

SET @s_date = [dbo].TZ_ToUTC(@sdate,default,@uid)
SET @e_date = [dbo].TZ_ToUTC(@edate,default,@uid)
SET @AnalogAlert1 = 1
SET @AnalogAlert2 = 2
SET @AnalogAlert3 = 4
SET @AnalogAlert4 = 8
SET @Sensor1Enabled = dbo.[IsAnalogSensorEnabled](0, @vid)
SET @Sensor2Enabled = dbo.[IsAnalogSensorEnabled](1, @vid)
SET @Sensor3Enabled = dbo.[IsAnalogSensorEnabled](2, @vid)
SET @Sensor4Enabled = dbo.[IsAnalogSensorEnabled](3, @vid)
SET @Sensor1Name = dbo.[GetAnalogSensorName](0, @vid)
SET @Sensor2Name = dbo.[GetAnalogSensorName](1, @vid)
SET @Sensor3Name = dbo.[GetAnalogSensorName](2, @vid)
SET @Sensor4Name = dbo.[GetAnalogSensorName](3, @vid)


--SELECT @Sensor1Enabled, @Sensor2Enabled, @Sensor3Enabled, @Sensor4Enabled
SET @tempmult = ISNULL([dbo].[UserPref](@uid, 214),1)
SET @liquidmult = ISNULL([dbo].[UserPref](@uid, 200),1)
SET @tempstring = ISNULL([dbo].[UserPref](@uid, 215),1)


DECLARE @results_pre TABLE
(
	RowNum INT,
	VehicleId UNIQUEIDENTIFIER,
	Registration NVARCHAR(MAX),
    VehicleTypeID INT,	
	GroupName NVARCHAR(MAX),
	Drivername NVARCHAR(MAX),
	DigitalIoTypeId INT,
	DigitalIoTypeName NVARCHAR(MAX),
	EventTime DATETIME,
	EventId BIGINT,
	CustomerId UNIQUEIDENTIFIER,
	DigitalIo INT,
	CreationCodeId INT,
	Lat FLOAT,
	Lon FLOAT,
	OnOff BIT,
	TotalOn INT,
	TotalOff INT,
	StatusString VARCHAR(255),
	DigitalIoUri NVARCHAR(512),
	AnalogData0 FLOAT,
	AnalogData1 FLOAT,
	AnalogData2 FLOAT,
	AnalogData3 FLOAT,
	AnalogData4 FLOAT,
	Analogdata5 FLOAT
)

INSERT INTO @results_pre (RowNum, VehicleId, Registration, VehicleTypeID, GroupName, DriverName, DigitalIoTypeId, DigitalIoTypeName, EventTime, EventId, CustomerId, DigitalIo, CreationCodeId, Lat, Lon, OnOff, StatusString, DigitalIoUri, AnalogData0, AnalogData1, AnalogData2, AnalogData3, AnalogData4, Analogdata5) 
SELECT ROW_NUMBER() OVER(ORDER BY v.VehicleId, e.EventDateTime) AS RowNum, v.VehicleId, v.Registration, v.VehicleTypeID, g.GroupName, dbo.FormatDriverNameByUser(d.DriverId, @uid), dst.DigitalSensorTypeId, dst.Description, [dbo].[TZ_GetTime]( e.EventDateTime, default, @uid) as EventTime, e.EventId, 
	c.CustomerId,
	dst.DigitalSensorTypeId, e.CreationCodeId, e.Lat, e.Long,
	dbo.[GetDioOnOff](v.VehicleId, s.SensorId, e.CreationCodeId) AS OnOff,
	CASE dbo.[GetDioOnOff](v.VehicleId, s.SensorId, e.CreationCodeId) WHEN 1 THEN dst.OnDescription ELSE dst.OffDescription END AS StatusString,
	dst.IconLocation AS DigitalIoUri ,
	e.AnalogData0, e.AnalogData1, e.AnalogData2, e.AnalogData3, e.AnalogData4, e.AnalogData5
FROM dbo.Event e 
	INNER JOIN dbo.Driver d ON e.DriverIntId = d.DriverIntId
	INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
	INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
	INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId AND e.CustomerIntId = c.CustomerIntId
	INNER JOIN dbo.VehicleSensor vs ON vs.VehicleIntId = v.VehicleIntId
	INNER JOIN dbo.DigitalSensorType dst ON vs.DigitalSensorTypeId = dst.DigitalSensorTypeId
	INNER JOIN dbo.Sensor s ON vs.SensorId = s.SensorId
	INNER JOIN dbo.[Group] g ON GroupId = @gid
WHERE v.VehicleId = @vid
  AND vs.DigitalSensorTypeId = @dio
  AND e.EventDateTime BETWEEN @s_date AND @e_date 
  AND (e.CreationCodeId = s.CreationCodeIdActive OR e.CreationCodeId = s.CreationCodeIdInactive)
  AND e.Lat != 0 AND e.Long != 0 
  
/*TODO: Add sensor scaling*/
SELECT  o.VehicleId ,
        o.Registration ,
        o.VehicleTypeID,
        o.GroupName ,
        o.Drivername ,
        o.DigitalIoTypeName ,
        o.Lat AS OnLat,
        o.Lon AS OnLon,
        [dbo].[GetGeofenceNameFromLongLat] (o.Lat, o.Lon, @uid, [dbo].[GetAddressFromLongLat] (o.Lat, o.Lon)) as OnReverseGeoCode,
		o.StatusString AS OnStatus,
        o.EventTime AS DigitalOnTime ,
        
		CASE WHEN @Sensor1Enabled = 0 THEN NULL ELSE dbo.GetScaleConvertAnalogValue(o.AnalogData0, 0, o.VehicleId, @tempmult, @liquidmult) END AS OnAnalogData0,
		CASE WHEN @Sensor2Enabled = 0 THEN NULL ELSE dbo.GetScaleConvertAnalogValue(o.AnalogData1, 1, o.VehicleId, @tempmult, @liquidmult) END AS OnAnalogData1,
		CASE WHEN @Sensor3Enabled = 0 THEN NULL ELSE dbo.GetScaleConvertAnalogValue(o.AnalogData2, 2, o.VehicleId, @tempmult, @liquidmult) END AS OnAnalogData2,
		CASE WHEN @Sensor4Enabled = 0 THEN NULL ELSE dbo.GetScaleConvertAnalogValue(o.AnalogData3, 3, o.VehicleId, @tempmult, @liquidmult) END AS OnAnalogData3,
        
        f.Lat AS OffLat,
        f.Lon AS OffLon,
        [dbo].[GetGeofenceNameFromLongLat] (f.Lat, f.Lon, @uid, [dbo].[GetAddressFromLongLat] (f.Lat, f.Lon)) as OffReverseGeoCode,
        f.StatusString AS OffStatus,
        f.EventTime AS DigitalOffTime,
        
		CASE WHEN @Sensor1Enabled = 0 THEN NULL ELSE dbo.GetScaleConvertAnalogValue(f.AnalogData0, 0, o.VehicleId, @tempmult, @liquidmult) END AS OffAnalogData0,
		CASE WHEN @Sensor2Enabled = 0 THEN NULL ELSE dbo.GetScaleConvertAnalogValue(f.AnalogData1, 1, o.VehicleId, @tempmult, @liquidmult) END AS OffAnalogData1,
		CASE WHEN @Sensor3Enabled = 0 THEN NULL ELSE dbo.GetScaleConvertAnalogValue(f.AnalogData2, 2, o.VehicleId, @tempmult, @liquidmult) END AS OffAnalogData2,
		CASE WHEN @Sensor4Enabled = 0 THEN NULL ELSE dbo.GetScaleConvertAnalogValue(f.AnalogData3, 3, o.VehicleId, @tempmult, @liquidmult) END AS OffAnalogData3,
		
		@tempstring AS AnalogDataString,
		
		CAST(DATEPART(HOUR, f.EventTime - o.EventTime) AS VARCHAR(MAX)) + 'h ' +
		CAST(DATEPART(MINUTE, f.EventTime - o.EventTime) AS VARCHAR(MAX)) + 'm ' +
		CAST(DATEPART(SECOND, f.EventTime - o.EventTime) AS VARCHAR(MAX)) + 's' AS DigitalDuration,
		@Sensor1Name AS Sensor1Name,
		@Sensor2Name AS Sensor2Name,
		@Sensor3Name AS Sensor3Name,
		@Sensor4Name AS Sensor4Name
FROM @results_pre o
INNER JOIN @results_pre f ON f.RowNum = o.RowNum + 1
WHERE o.OnOff = 1
ORDER BY o.VehicleId, o.EventTime



GO
