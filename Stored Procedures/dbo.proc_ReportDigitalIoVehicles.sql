SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportDigitalIoVehicles]
(
	@vids NVARCHAR(MAX) = NULL, 
    @uid UNIQUEIDENTIFIER = NULL,
	@sdate DATETIME = NULL, 
	@edate DATETIME = NULL,
    @dios NVARCHAR(MAX) = NULL
)
AS

--DECLARE	@sdate DATETIME,
--		@edate DATETIME,
--		@uid UNIQUEIDENTIFIER,
--		@vids NVARCHAR(MAX),
--		@dios NVARCHAR(MAX)
--		
--SET @vids = N'02EA55B8-EB47-4A27-8BAB-18682C6DA0F2,2243BCEB-95B2-478D-9F0E-BEF4E8420032'
--SET @uid = N'3C65E267-ED53-4599-98C5-CBF5AFD85A66'
--SET @sdate = '2012-05-01 00:00'
--SET @edate = '2012-06-30 23:59'
--SET @dios = '9,12'


DECLARE @dio INT,
		@depid INT,
		@vid UNIQUEIDENTIFIER,
		@onoff BIT,
		@s_date DATETIME,
		@e_date DATETIME

SET @s_date = [dbo].TZ_ToUTC(@sdate,default,@uid)
SET @e_date = [dbo].TZ_ToUTC(@edate,default,@uid)


DECLARE @static_data TABLE
(
	VehicleId UNIQUEIDENTIFIER,
	DioTypeId SMALLINT
)

DECLARE @results_pre TABLE
(
	VehicleId UNIQUEIDENTIFIER,
	Registration NVARCHAR(MAX),
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
	DigitalIoUri NVARCHAR(512)
)

DECLARE dio_cur CURSOR FAST_FORWARD FORWARD_ONLY FOR
	SELECT VALUE FROM dbo.Split(@dios, ',')
	
OPEN dio_cur
FETCH NEXT FROM dio_cur INTO @dio
WHILE @@FETCH_STATUS = 0
BEGIN
	INSERT INTO @static_data ( VehicleId, DioTypeId )
		SELECT VehicleId, @dio
		FROM dbo.Vehicle
		WHERE VehicleId IN (SELECT Value FROM dbo.Split(@vids, ','))
		
	FETCH NEXT FROM dio_cur INTO @dio
END
CLOSE dio_cur

INSERT INTO @results_pre (VehicleId, Registration, DigitalIoTypeId, DigitalIoTypeName, EventTime, EventId, CustomerId, DigitalIo, CreationCodeId, Lat, Lon, OnOff, StatusString, DigitalIoUri) 
SELECT v.VehicleId, v.Registration, dst.DigitalSensorTypeId, dst.Description, [dbo].[TZ_GetTime]( e.EventDateTime, default, @uid) as EventTime, e.EventId, 
	c.CustomerId,
	sd.DioTypeId, e.CreationCodeId, e.Lat, e.Long,
	dbo.[GetDioOnOff](sd.VehicleId, s.SensorId, e.CreationCodeId) AS OnOff,
	CASE dbo.[GetDioOnOff](sd.VehicleId, s.SensorId, e.CreationCodeId) WHEN 1 THEN dst.OnDescription ELSE dst.OffDescription END AS StatusString,
	dst.IconLocation AS DigitalIoUri 
FROM dbo.Event e 
	INNER JOIN dbo.Driver d ON e.DriverIntId = d.DriverIntId
	INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
	INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
	INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId AND e.CustomerIntId = c.CustomerIntId
	INNER JOIN @static_data sd ON v.VehicleId = sd.VehicleId
	INNER JOIN dbo.VehicleSensor vs ON vs.VehicleIntId = v.VehicleIntId AND sd.DioTypeId = vs.DigitalSensorTypeId
	INNER JOIN dbo.DigitalSensorType dst ON vs.DigitalSensorTypeId = dst.DigitalSensorTypeId
	INNER JOIN dbo.Sensor s ON vs.SensorId = s.SensorId
WHERE e.EventDateTime BETWEEN @s_date AND @e_date 
AND (e.CreationCodeId = s.CreationCodeIdActive OR e.CreationCodeId = s.CreationCodeIdInactive)
AND e.Lat != 0 AND e.Long != 0 
--GROUP BY sd.VehicleId, v.VehicleId, v.Registration, s.SensorId, dst.Description, c.CustomerId, e.EventDateTime, /*sd.CCId,*/ e.EventId, e.CreationCodeId, e.Lat, e.Long, sd.DioTypeId

DECLARE @TotalOnTime INT,
		@TotalOffTime INT

DECLARE @results TABLE
(
	VehicleId UNIQUEIDENTIFIER,
	Registration NVARCHAR(MAX),
	DigitalIo INT,
	DigitalIoTypeId INT,
	DigitalIoTypeName NVARCHAR(MAX),
	EventId BIGINT,
	StartTime DATETIME,
	EndTime DATETIME,
	Duration INT
)

INSERT INTO @results (VehicleId, Registration, DigitalIo, DigitalIoTypeId, DigitalIoTypeName, EventId, StartTime, EndTime, Duration)
	SELECT r1.VehicleId, r1.Registration, r1.DigitalIo, r1.DigitalIoTypeId, r1.DigitalIoTypeName, r1.EventId, r1.EventTime AS StartTime, MIN(r2.EventTime) AS EndTime, DATEDIFF(ss, r1.EventTime, MIN(r2.EventTime)) AS Duration
	FROM @results_pre r1
	LEFT OUTER JOIN @results_pre r2 ON r1.DigitalIo = r2.DigitalIo AND r1.VehicleId = r2.VehicleId AND r2.EventTime > r1.EventTime AND r2.OnOff = 0 AND r1.OnOff = 1
	GROUP BY r1.VehicleId, r1.Registration, r1.DigitalIo, r1.DigitalIoTypeId, r1.DigitalIoTypeName, r1.EventId, r1.EventTime, r1.CreationCodeId

OPEN dio_cur
FETCH NEXT FROM dio_cur INTO @dio
WHILE @@FETCH_STATUS = 0
BEGIN
	SELECT @TotalOnTime = SUM(Duration) FROM @results WHERE DigitalIo = @dio
	SELECT @TotalOffTime = DATEDIFF(ss, @sdate, @edate) - SUM(Duration) FROM @results WHERE DigitalIo = @dio
	
	UPDATE @results_pre
	SET TotalOn = @TotalOnTime,
		TotalOff = @TotalOffTime
	WHERE DigitalIo = @dio
		
	FETCH NEXT FROM dio_cur INTO @dio
END
CLOSE dio_cur
DEALLOCATE dio_cur

SELECT DISTINCT * FROM @results_pre
ORDER BY DigitalIo, VehicleId, EventTime, OnOff DESC


GO
