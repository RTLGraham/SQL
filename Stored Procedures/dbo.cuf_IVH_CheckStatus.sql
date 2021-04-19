SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_IVH_CheckStatus]
(
	@userid UNIQUEIDENTIFIER,
	@ivhid UNIQUEIDENTIFIER = NULL,
	@vid UNIQUEIDENTIFIER,
	@cameraId UNIQUEIDENTIFIER = NULL,
	@minutes INT=NULL
)
AS

	--DECLARE @userid UNIQUEIDENTIFIER,
	--		@ivhid UNIQUEIDENTIFIER,
	--		@vid UNIQUEIDENTIFIER,
	--		@cameraId UNIQUEIDENTIFIER,
	--		@minutes INT

	--SET @userid = N'838C5D25-1635-4539-923C-5A733A3D8DA8'
	--SET @ivhid = NULL
	----SET @vid = N'C169D964-656A-4833-8A8C-FACE34A020E5' --xeu
	----SET @vid = N'A6B1F69C-87D7-4444-81AD-E0EA50760BF4' --jhk
	--SET @vid = N'D9E3238C-1432-475C-A946-95AF334249A4'
	--SET @cameraId = NULL
	--SET @minutes = 4320 

	--SELECT * FROM dbo.Vehicle WHERE Registration LIKE '%jhk%'
	--SELECT * FROM dbo.[User] WHERE Name LIKE '%eng%'

	IF @minutes = 4320
	BEGIN
		SET @minutes = 10080
	END 

	DECLARE @date DATETIME,
			@vintid INT,
			@IgnitionDateTime DATETIME,
			@LastEventDateTime DATETIME,
			@TotalDistance FLOAT,
			@AverageRPM FLOAT,
			@TotalFuel FLOAT,
			@DrivingFuel FLOAT,
			@ShortIdleFuel FLOAT,
			@TotalIdleTime FLOAT,
			@GPSSatelliteCount INT,
			@DriverNumber NVARCHAR(MAX),
			@Sensor0 INT,
			@Sensor0Max FLOAT,
			@Sensor0Min FLOAT,
			@Sensor0Current FLOAT,
			@Sensor1 INT,
			@Sensor1Max FLOAT,
			@Sensor1Min FLOAT,
			@Sensor1Current FLOAT,
			@Sensor2 INT,
			@Sensor2Max FLOAT,
			@Sensor2Min FLOAT,
			@Sensor2Current FLOAT,
			@Sensor3 INT,
			@Sensor3Max FLOAT,
			@Sensor3Min FLOAT,
			@Sensor3Current FLOAT,
			@DigitalIO1 INT,
			@DigitalIO2 INT,
			@DigitalIO3 INT,
			@DigitalIO4 INT,
			@CustomerName NVARCHAR(MAX),
			@VehicleGroups NVARCHAR(MAX),
			@Version NVARCHAR(MAX),
			@Website CHAR(3),
			@Network CHAR(3),
			@Com1 CHAR(3),
			@Com2 CHAR(3),
			@CanType CHAR(3),
			@Options CHAR(30),
			@SensorConfig NVARCHAR(MAX),
			@Registration NVARCHAR(MAX),
			@MakeModel NVARCHAR(100),
			@BodyManufacturer NVARCHAR(50),
			@BodyType NVARCHAR(50),
			@ChassisNumber NVARCHAR(50),
			@TrackerNumber NVARCHAR(MAX),
			@DiagnosticsId INT,
			@tempmult FLOAT,
			@liquidmult FLOAT,
			@accStart DATETIME,
			@accEnd DATETIME,
			@accCount INT,
			@hardwareStatus INT,
			@dig_DigidownTConnected BIT,
			@dig_TachographConnected BIT,
			@vehicleCameraId UNIQUEIDENTIFIER,
			@vehicleCameraSerial NVARCHAR(MAX),
			@ivhType INT,
			@isTachoDownloadEnabled BIT

	SET @tempmult = Cast(ISNULL(dbo.[UserPref](@userid, 214),1) as float)
	SET @liquidmult = Cast(ISNULL(dbo.[UserPref](@userid, 200),1) as float)

	IF @minutes IS NULL SET @minutes = 1440 -- default setting of 1 day

	SET @date = DATEADD(MINUTE, @minutes * -1, GETUTCDATE())

	SELECT TOP 1 @LastEventDateTime = EventDateTime, @vintid = v.VehicleIntId, @ivhType = it.IVHTypeId
	FROM dbo.VehicleLatestAllEvent vle
		INNER JOIN dbo.Vehicle v ON vle.VehicleId = v.VehicleId
		LEFT OUTER JOIN dbo.IVH i ON v.IVHId = i.IVHId
		LEFT JOIN dbo.IVHType it ON it.IVHTypeId = i.IVHTypeId
	WHERE v.VehicleId = @vid AND v.Archived = 0


	SELECT TOP 1 @IgnitionDateTime = EventDateTime
	FROM dbo.Event e 
	WHERE e.VehicleIntId = @vintid
		AND e.EventDateTime BETWEEN @date AND GETDATE()
		AND e.CreationCodeId IN (4,5)
	ORDER BY e.EventDateTime DESC

	--SELECT TOP 1 @hardwareStatus = e.HardwareStatus
	--FROM dbo.Event e
	--WHERE e.VehicleIntId = @vintid
	--	AND e.EventDateTime BETWEEN @date AND GETDATE()
	--ORDER BY e.EventDateTime DESC

	--SELECT	@dig_DigidownTConnected = @hardwareStatus & 1,
	--		@dig_TachographConnected = @hardwareStatus & 2
	
	
	SELECT 
		@dig_DigidownTConnected =  MAX(e.HardwareStatus & 1), 
		@dig_TachographConnected = MAX(e.HardwareStatus & 2)
	FROM dbo.Event e
	WHERE e.VehicleIntId = @vintid
		AND e.EventDateTime BETWEEN @date AND GETDATE()

	--Check if there are any driving w/o ignition events after the @IgnitionDateTime
	DECLARE @noIgnitionCount INT
	SELECT @noIgnitionCount = COUNT(*)
	FROM dbo.Event e
	WHERE e.EventDateTime BETWEEN @IgnitionDateTime AND GETDATE()
		AND e.CreationCodeId IN (42, 43)
		AND e.VehicleIntId = @vintid

	IF @noIgnitionCount IS NOT NULL AND @noIgnitionCount > 0
	BEGIN
		SET @IgnitionDateTime = NULL
	END

	SELECT @TotalDistance = MAX(a.TotalVehicleDistance), 
			@AverageRPM = MAX(a.AverageEngineRPM),
			@TotalFuel = MAX(a.TotalVehicleFuel),
			@DrivingFuel = SUM(a.DrivingFuel),
			@ShortIdleFuel = SUM(a.ShortIdleFuel) + SUM(a.IdleFuel), -- Added Idle Fuel so that ShortIdleFuel contains all Idle Fuel 
			@TotalIdleTime = SUM(a.IdleTime) + SUM(a.ShortIdleTime),
			@accStart = MIN(a.CreationDateTime), @accEnd = MAX(a.ClosureDateTime),
			@accCount = COUNT(*)
	FROM dbo.Accum a
	WHERE a.VehicleIntId = @vintid
		AND (a.CreationDateTime BETWEEN @date AND GETDATE() OR a.ClosureDateTime BETWEEN @date AND GETDATE())

	SELECT TOP 1 @GPSSatelliteCount = GPSSatelliteCount
	FROM dbo.Event e
	WHERE e.VehicleIntId = @vintid
		AND e.EventDateTime BETWEEN @date AND GETDATE()
		AND GPSSatelliteCount > 3
		--AND dbo.TestBits(SystemStatus, 4) = 1
		--AND dbo.TestBits(SystemStatus, 8) = 0
	ORDER BY e.EventDateTime DESC



	SELECT TOP 1 @DriverNumber = (ISNULL(d.Number,'')
								   + CASE WHEN d.NumberAlternate IS NOT NULL THEN '; ' + d.NumberAlternate ELSE '' END
								   + CASE WHEN d.NumberAlternate2 IS NOT NULL THEN '; ' + d.NumberAlternate2 ELSE '' END)
	FROM dbo.Event e
		INNER JOIN dbo.Driver d ON e.DriverIntId = d.DriverIntId
	WHERE e.VehicleIntId = @vintid
		AND e.EventDateTime BETWEEN @date AND GETDATE()
		AND e.CreationCodeId = 61
		AND (d.Number != 'No ID' OR d.Number IS NULL)
	ORDER BY e.EventDateTime DESC

	IF @DriverNumber IS NULL
	BEGIN
		SELECT TOP 1 @DriverNumber = 
			CASE WHEN ed.EventDataString = 'VD' THEN 'VDO Tachograph (no card)' 
				 WHEN ed.EventDataString = 'IB' THEN 'iButton' 
				 WHEN ed.EventDataString = 'ST' THEN 'Stoneridge Tachograph (no card)' 
				 WHEN ed.EventDataString = 'LE' THEN 'Leopard' 
				 WHEN ed.EventDataString = 'SI' THEN 'Simple ID' 
				 WHEN ed.EventDataString = 'CI' THEN 'Complex ID' 
				 WHEN ed.EventDataString = 'CA' THEN 'Driver ID from CAN' 
				 WHEN ed.EventDataString = 'CB' THEN 'Driver ID from CAN/BAM' 
				 WHEN ed.EventDataString = 'UN' THEN 'Drver ID Unknown' 
				ELSE 'Stonerige Tachograph or CAN (no card)' END
		FROM dbo.Event e
			INNER JOIN dbo.EventData ed ON ed.EventId = e.EventId AND ed.VehicleIntId = e.VehicleIntId AND ed.EventDateTime = e.EventDateTime
		WHERE e.VehicleIntId = @vintid
			AND e.EventDateTime BETWEEN @date AND GETDATE()
			AND ed.EventDataName = 'SRC' AND ed.EventDataString NOT LIKE '%CH%'
		ORDER BY e.EventId DESC
	END
	--A11 support
	IF @DriverNumber IS NULL
	BEGIN
		SELECT TOP 1 @DriverNumber = ed.EventDataString
		FROM dbo.Event e
			INNER JOIN dbo.EventData ed ON ed.EventId = e.EventId AND ed.VehicleIntId = e.VehicleIntId AND ed.EventDateTime = e.EventDateTime
		WHERE e.VehicleIntId = @vintid
			AND e.EventDateTime BETWEEN @date AND GETDATE()
			AND ed.EventDataName = 'DID1' AND ed.EventDataString NOT LIKE '%No ID%'
		ORDER BY e.EventId DESC
	END

	DECLARE @Analog0Scaling FLOAT,
			@Analog1Scaling FLOAT,
			@Analog2Scaling FLOAT,
			@Analog3Scaling FLOAT

	SELECT @Analog0Scaling = AnalogSensorScaleFactor FROM dbo.VehicleSensor WHERE VehicleIntId = @vintid AND SensorId = 1
	SELECT @Analog1Scaling = AnalogSensorScaleFactor FROM dbo.VehicleSensor WHERE VehicleIntId = @vintid AND SensorId = 2
	SELECT @Analog2Scaling = AnalogSensorScaleFactor FROM dbo.VehicleSensor WHERE VehicleIntId = @vintid AND SensorId = 3
	SELECT @Analog3Scaling = AnalogSensorScaleFactor FROM dbo.VehicleSensor WHERE VehicleIntId = @vintid AND SensorId = 4


	SELECT
		@Sensor0 = CASE WHEN CAST(MAX(e.AnalogData0) AS INT) - CAST(MIN(e.AnalogData0) AS INT) > 0 THEN 1 ELSE 0 END,
		@Sensor0Min = MIN(dbo.ScaleConvertAnalogValue(e.AnalogData0, @Analog0Scaling, @tempmult, @liquidmult)),
		@Sensor0Max = MAX(dbo.ScaleConvertAnalogValue(e.AnalogData0, @Analog0Scaling, @tempmult, @liquidmult)),
		@Sensor1 = CASE WHEN CAST(MAX(e.AnalogData1) AS INT) - CAST(MIN(e.AnalogData1) AS INT) > 0 THEN 1 ELSE 0 END,
		@Sensor1Min = MIN(dbo.ScaleConvertAnalogValue(e.AnalogData1, @Analog1Scaling, @tempmult, @liquidmult)),
		@Sensor1Max = MAX(dbo.ScaleConvertAnalogValue(e.AnalogData1, @Analog1Scaling, @tempmult, @liquidmult)),
		@Sensor2 = CASE WHEN CAST(MAX(e.AnalogData2) AS INT) - CAST(MIN(e.AnalogData2) AS INT) > 0 THEN 1 ELSE 0 END,
		@Sensor2Min = MIN(dbo.ScaleConvertAnalogValue(e.AnalogData2, @Analog2Scaling, @tempmult, @liquidmult)),
		@Sensor2Max = MAX(dbo.ScaleConvertAnalogValue(e.AnalogData2, @Analog2Scaling, @tempmult, @liquidmult)),
		@Sensor3 = CASE WHEN CAST(MAX(e.AnalogData3) AS INT) - CAST(MIN(e.AnalogData3) AS INT) > 0 THEN 1 ELSE 0 END,
		@Sensor3Min = MIN(dbo.ScaleConvertAnalogValue(e.AnalogData3, @Analog3Scaling, @tempmult, @liquidmult)),
		@Sensor3Max = MAX(dbo.ScaleConvertAnalogValue(e.AnalogData3, @Analog3Scaling, @tempmult, @liquidmult))
	FROM dbo.Event e
		INNER JOIN dbo.Vehicle v ON v.VehicleIntId = e.VehicleIntId
	WHERE e.VehicleIntId = @vintid
		AND e.EventDateTime BETWEEN @date AND GETDATE()

	SELECT
		@Sensor0Current = dbo.ScaleConvertAnalogValue(vle.AnalogData0, @Analog0Scaling, @tempmult, @liquidmult),
		@Sensor1Current = dbo.ScaleConvertAnalogValue(vle.AnalogData1, @Analog1Scaling, @tempmult, @liquidmult),
		@Sensor2Current = dbo.ScaleConvertAnalogValue(vle.AnalogData2, @Analog2Scaling, @tempmult, @liquidmult),
		@Sensor3Current = dbo.ScaleConvertAnalogValue(vle.AnalogData3, @Analog3Scaling, @tempmult, @liquidmult)
	FROM dbo.VehicleLatestAllEvent vle
	WHERE vle.VehicleId = @vid

	SELECT  @DigitalIO4 = MAX(CAST(dbo.TestBits(e.DigitalIO, 8) AS INT)),
			@DigitalIO3 = MAX(CAST(dbo.TestBits(e.DigitalIO, 4) AS INT)),
			@DigitalIO2 = MAX(CAST(dbo.TestBits(e.DigitalIO, 2) AS INT)),
			@DigitalIO1 = MAX(CAST(dbo.TestBits(e.DigitalIO, 1) AS INT))
	FROM dbo.Event e
	WHERE e.VehicleIntId = @vintid
		AND e.EventDateTime BETWEEN @date AND GETDATE()



	--IF(@vid = N'16d2096b-869f-4d22-9c66-be91b7b6d94a')
	--BEGIN
	--	SET @DigitalIO4 = 1
	--	SET @DigitalIO3 = 1
	--	SET @DigitalIO2 = 1
	--	SET @DigitalIO1 = 1
	--END
	SELECT  @CustomerName = c.Name,
			@Registration = v.Registration,
			@MakeModel = v.MakeModel,
			@BodyManufacturer = v.BodyManufacturer,
			@BodyType = v.BodyType,
			@ChassisNumber = v.ChassisNumber,
			@TrackerNumber = ISNULL(i.TrackerNumber,''),
			@vehicleCameraId = cam.CameraId,
			@vehicleCameraSerial = ISNULL(cam.Serial,''),
			@isTachoDownloadEnabled = CASE WHEN cp.Value IS NOT NULL THEN 1 ELSE 0 END
	FROM dbo.Vehicle v 
		LEFT OUTER JOIN dbo.VehicleCamera vc ON vc.VehicleId = v.VehicleId AND vc.Archived = 0 AND (vc.EndDate IS NULL OR vc.EndDate > GETDATE())
		LEFT OUTER JOIN dbo.Camera cam ON cam.CameraId = vc.CameraId AND cam.Archived = 0
		LEFT OUTER JOIN dbo.IVH i ON i.IVHId = v.IVHId
		INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
		INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
		LEFT JOIN dbo.CustomerPreference cp ON cp.CustomerID = c.CustomerId AND cp.NameID = 3003 AND cp.Value = '1'
	WHERE v.VehicleId = @vid
		AND v.Archived = 0
		AND cv.Archived = 0
		AND cv.EndDate IS NULL

	SELECT @VehicleGroups = COALESCE(@VehicleGroups + '; ', '') + g.GroupName
	FROM dbo.Vehicle v
		INNER JOIN dbo.GroupDetail gd ON v.VehicleId = gd.EntityDataId
		INNER JOIN dbo.[Group] g ON gd.GroupId = g.GroupId
	WHERE v.VehicleId = @vid
		AND v.Archived = 0
		AND g.GroupTypeId = 1
		AND g.IsParameter = 0
		AND g.Archived = 0
	
	SELECT	@Version = vf.Version,
			@Website = vf.Website,
			@Network = vf.Network,
			@Com1 = vf.Com1,
			@Com2 = vf.Com2,
			@CanType = vf.CanType,
			@Options = vf.Options
	FROM dbo.Vehicle v 
		INNER JOIN dbo.VehicleFirmware vf ON v.VehicleId = vf.VehicleId
	WHERE v.VehicleId = @vid
		AND v.Archived = 0
		AND vf.BaseActiveInd = 'A'

	IF @ivhType = 9 AND @isTachoDownloadEnabled = 1
	BEGIN
		SET @Com1 = 'A11'
		SET @Com2 = 'DIG'
	END
	
	SELECT @SensorConfig = COALESCE(@SensorConfig + '|', '') + CAST(s.SensorType AS VARCHAR(MAX)) + CAST(s.SensorIndex AS VARCHAR(MAX)) + ' = ' + vs.Description 
	FROM dbo.Vehicle v
		INNER JOIN dbo.VehicleSensor vs ON v.VehicleIntId = vs.VehicleIntId
		INNER JOIN dbo.Sensor s ON vs.SensorId = s.SensorId
	WHERE v.VehicleId = @vid
		AND v.Archived = 0
		AND vs.Enabled = 1


	--SELECT @userid,
	--		  GETUTCDATE(),
	--		  @vid,
	--		  @ivhid,
	--		  @IgnitionDateTime,
	--		  @LastEventDateTime,
	--		  @TotalDistance,
	--		  @AverageRPM,
	--		  @DriverNumber,
	--		  @hardwareStatus,
	--		  @dig_DigidownTConnected as DigConnected,
	--		  @dig_TachographConnected as TachoConnected

	INSERT INTO dbo.Diagnostics
			( UserId,
			  Date,
			  VehicleId,
			  IVHId,
			  IgnitionDateTime,
			  LastEventDateTime,
			  TotalDistance,
			  AverageRPM,
			  TotalFuel,
			  DrivingFuel,
			  ShortIdleFuel,
			  TotalIdleTime,
			  GPSSatelliteCount,
			  DriverNumber,
			  Sensor0,
			  Sensor0Max,
			  Sensor0Min,
			  Sensor0Current,
			  Sensor1,
			  Sensor1Max,
			  Sensor1Min,
			  Sensor1Current,
			  Sensor2,
			  Sensor2Max,
			  Sensor2Min,
			  Sensor2Current,
			  Sensor3,
			  Sensor3Max,
			  Sensor3Min,
			  Sensor3Current,
			  DigitalIO1,
			  DigitalIO2,
			  DigitalIO3,
			  DigitalIO4,
			  CustomerName,
			  VehicleGroups,
			  Version,
			  Website,
			  Network,
			  Com1,
			  Com2,
			  CanType,
			  Options,
			  SensorConfig,
			  Registration,
			  TrackerNumber,
			  AccumStart,
			  AccumEnd,
			  AccumCount,
			  HardwareStatus ,
	          DIG_DigidownTConnected ,
	          DIG_TachographConnected ,
			  CameraId,
			  CameraSerial,
			  MakeModel,
			  BodyManufacturer,
			  BodyType,
			  ChassisNumber
			)
	VALUES  ( @userid,
			  GETUTCDATE(),
			  @vid,
			  @ivhid,
			  @IgnitionDateTime,
			  @LastEventDateTime,
			  @TotalDistance,
			  @AverageRPM,
			  @TotalFuel,
			  @DrivingFuel,
			  @ShortIdleFuel,
			  @TotalIdleTime,
			  @GPSSatelliteCount,
			  @DriverNumber,
			  @Sensor0,
			  @Sensor0Max,
			  @Sensor0Min,
			  @Sensor0Current,
			  @Sensor1,
			  @Sensor1Max,
			  @Sensor1Min,
			  @Sensor1Current,
			  @Sensor2,
			  @Sensor2Max,
			  @Sensor2Min,
			  @Sensor2Current,
			  @Sensor3,
			  @Sensor3Max,
			  @Sensor3Min,
			  @Sensor3Current,
			  @DigitalIO1,
			  @DigitalIO2,
			  @DigitalIO3,
			  @DigitalIO4,
			  @CustomerName,
			  @VehicleGroups,
			  @Version,
			  @Website,
			  @Network,
			  @Com1,
			  @Com2,
			  @CanType,
			  @Options,
			  @SensorConfig,
			  @Registration,
			  @TrackerNumber,
			  @accStart,
			  @accEnd,
			  @accCount,
			  @hardwareStatus,
			  @dig_DigidownTConnected,
			  @dig_TachographConnected,
			  @vehicleCameraId,
			  @vehicleCameraSerial,
			  @MakeModel,
			  @BodyManufacturer,
			  @BodyType,
			  @ChassisNumber
			)

	SET @DiagnosticsId = SCOPE_IDENTITY()

	SELECT DiagnosticsId,
			UserId,
			dbo.TZ_GetTime(Date,DEFAULT,@userid) AS Date,
			dbo.TZ_GetTime(IgnitionDateTime,DEFAULT,@userid) AS IgnitionDateTime,
			--dbo.TZ_GetTime(@dbTime,DEFAULT,@userid) AS LastEventDateTime,
			dbo.TZ_GetTime(LastEventDateTime,DEFAULT,@userid) AS LastEventDateTime,
			TotalDistance AS TotalVehicleDistance,
			AverageRPM,
			TotalFuel,
			DrivingFuel,
			ShortIdleFuel,
			TotalIdleTime,
			GPSSatelliteCount,
			DriverNumber,
			Sensor0,
			Sensor0Max,
			Sensor0Min,
			Sensor0Current,
			Sensor1,
			Sensor1Max,
			Sensor1Min,
			Sensor1Current,
			Sensor2,
			Sensor2Max,
			Sensor2Min,
			Sensor2Current,
			Sensor3,
			Sensor3Max,
			Sensor3Min,
			Sensor3Current,
			DigitalIO1,
			DigitalIO2,
			DigitalIO3,
			DigitalIO4,
			CustomerName,
			VehicleGroups,
			Version AS SoftwareVersion,
			Website,
			Network,
			Com1,
			Com2,
			CanType,
			Options,
			SensorConfig,
			Registration,
			TrackerNumber,
			AccumStart,
			AccumEnd,
			AccumCount,
			HardwareStatus ,
	        DIG_DigidownTConnected ,
	        DIG_TachographConnected,
			VehicleId,
			IVHId,
			CameraID,
			CameraSerial,
			MakeModel,
			BodyManufacturer,
			BodyType,
			ChassisNumber
	FROM dbo.Diagnostics
	WHERE DiagnosticsId = @DiagnosticsId

GO
