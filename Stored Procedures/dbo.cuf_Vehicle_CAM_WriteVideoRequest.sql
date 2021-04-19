SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[cuf_Vehicle_CAM_WriteVideoRequest]
(
	@userId UNIQUEIDENTIFIER,
	@vehicleId UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME, --this is also the EventDateTime
	@camera INT = 1,
	@apiEventId VARCHAR(1024),
	@apiVideoId VARCHAR(1024),
	@eventId BIGINT = NULL,
	@creationCode SMALLINT = NULL
)
AS
	
	--DECLARE @userId UNIQUEIDENTIFIER,
	--		@vehicleId UNIQUEIDENTIFIER,
	--		@sdate DATETIME,
	--		@edate DATETIME, --this is also the EventDateTime
	--		@camera INT = 1,
	--		@apiEventId VARCHAR(1024),
	--		@apiVideoId VARCHAR(1024)

	--SELECT	@userId = N'DA2B1EC5-8C26-4B6A-9B2B-4B20B8333883', 
	--		@vehicleId = N'A3EF2554-D638-477C-87BF-85130A1F2AD2', 
	--		@sdate = '2019-02-02 07:08:42',
	--		@edate = '2019-02-02 07:08:52',
	--		@apiEventId = '9M6Wn5PUX8hKSR2a2U9ySS0kMav_20110203T132116,195445+0000',
	--		@apiVideoId = '9M6Wn5PUX8hKSR2a2U9ySS0kMav_20110202T070842,000000+0000'


	DECLARE @vIntId INT,
			@dIntId INT,
			@custIntId INT,
			@eIntId INT,
			@camIntId INT,
			@videoStatus INT,
			@coachingStatus INT,
			@incidentId BIGINT,
			@videoId BIGINT

	SELECT	@videoStatus = 3,
			@coachingStatus = 0,
			@creationCode = ISNULL(@creationCode, 459)

	-- Select all INT identifiers using the specified vehicle id
	SELECT TOP 1
			@vIntId = v.VehicleIntId,
			@custIntId = c.CustomerIntId,
			@camIntId = cam.CameraIntId
	FROM dbo.Vehicle v
		INNER JOIN dbo.VehicleCamera vc ON vc.VehicleId = v.VehicleId
		INNER JOIN dbo.Camera cam ON cam.CameraId = vc.CameraId
		INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
		INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
	WHERE vc.EndDate IS NULL AND vc.Archived = 0
		AND cv.EndDate IS NULL AND cv.Archived = 0
		AND v.Archived = 0 AND cam.Archived = 0 AND c.Archived = 0
		AND v.VehicleId = @vehicleId
	ORDER BY cam.LastOperation DESC
    
	--Get the driver at a time of the event
	SELECT TOP 1 @dIntId = e.DriverIntId
	FROM dbo.Event e
	WHERE e.VehicleIntId = @vIntId
		AND e.EventDateTime BETWEEN DATEADD(HOUR, -1, @edate) AND @edate
	ORDER BY e.EventDateTime DESC
    
	IF @dIntId IS NULL
	BEGIN
		-- if there is no driver id - use the No ID driver
		SELECT @dIntId = d.DriverIntId
		FROM dbo.Driver d
			INNER JOIN dbo.CustomerDriver cd ON cd.DriverId = d.DriverId
			INNER JOIN dbo.Customer c ON c.CustomerId = cd.CustomerId
		WHERE c.CustomerIntId = @custIntId
			AND d.Surname = 'UNKNOWN' AND d.Number = 'No ID'
			AND d.Archived = 0 AND cd.EndDate IS NULL AND cd.Archived = 0
		ORDER BY d.DriverIntId ASC 
	END

	-- If @eventId isn't provided as a parameter generate a new Event
	IF @eventId IS NULL	
	BEGIN	

		-- Get next EventId for the Event table
		SELECT @eventid = NEXT VALUE FOR EventId

		--Write the event
		INSERT INTO dbo.EventListenerTemp
				(EventId,
				 VehicleIntId,
				 DriverIntId,
				 CreationCodeId,
				 Long,
				 Lat,
				 Heading,
				 Speed,
				 OdoGPS,
				 OdoRoadSpeed,
				 OdoDashboard,
				 EventDateTime,
				 DigitalIO,
				 CustomerIntId,
				 AnalogData0,
				 AnalogData1,
				 AnalogData2,
				 AnalogData3,
				 AnalogData4,
				 AnalogData5,
				 SeqNumber,
				 SpeedLimit,
				 LastOperation,
				 Archived,
				 Altitude,
				 GPSSatelliteCount,
				 GPRSSignalStrength,
				 SystemStatus,
				 BatteryChargeLevel,
				 ExternalInputVoltage,
				 MaxSpeed,
				 TripDistance,
				 TachoStatus,
				 CANStatus,
				 FuelLevel,
				 HardwareStatus
				)
		VALUES  (@eventId, --eventId BIGINT
				 @vIntId, -- VehicleIntId - int
				 @dIntId, -- DriverIntId - int
				 @creationCode, -- CreationCodeId - smallint
				 0.0, -- Long - float
				 0.0, -- Lat - float
				 0, -- Heading - smallint
				 0, -- Speed - smallint
				 0, -- OdoGPS - int
				 0, -- OdoRoadSpeed - int
				 0, -- OdoDashboard - int
				 @edate, -- EventDateTime - datetime
				 NULL, -- DigitalIO - tinyint
				 @custIntId, -- CustomerIntId - int
				 NULL, -- AnalogData0 - smallint
				 NULL, -- AnalogData1 - smallint
				 NULL, -- AnalogData2 - smallint
				 NULL, -- AnalogData3 - smallint
				 NULL, -- AnalogData4 - smallint
				 NULL, -- AnalogData5 - smallint
				 NULL, -- SeqNumber - int
				 NULL, -- SpeedLimit - tinyint
				 GETDATE(), -- LastOperation - smalldatetime
				 NULL, -- Archived - bit
				 NULL, -- Altitude - smallint
				 NULL, -- GPSSatelliteCount - tinyint
				 NULL, -- GPRSSignalStrength - tinyint
				 NULL, -- SystemStatus - tinyint
				 NULL, -- BatteryChargeLevel - tinyint
				 NULL, -- ExternalInputVoltage - tinyint
				 NULL, -- MaxSpeed - tinyint
				 NULL, -- TripDistance - int
				 NULL, -- TachoStatus - tinyint
				 NULL, -- CANStatus - tinyint
				 NULL, -- FuelLevel - tinyint
				 NULL  -- HardwareStatus - tinyint
				)
	END	


	INSERT INTO dbo.CAM_Incident
	        (EventId,
	         EventDateTime,
	         CreationCodeId,
	         CustomerIntId,
	         VehicleIntId,
	         DriverIntId,
	         CameraIntId,
	         CoachingStatusId,
	         ApiEventId,
	         ApiMetadataId,
	         LastOperation,
	         Archived,
	         MinX,
	         MaxX,
	         MinY,
	         MaxY,
	         MinZ,
	         MaxZ,
	         IsEscalated,
	         Lat,
	         Long,
	         Heading,
	         Speed
	        )
	VALUES  (@eventId, -- EventId - bigint
	         @edate, -- EventDateTime - datetime
	         @creationCode, -- CreationCodeId - smallint
	         @custIntId, -- CustomerIntId - int
	         @vIntId, -- VehicleIntId - int
	         @dIntId, -- DriverIntId - int
	         @camIntId, -- CameraIntId - int
	         @coachingStatus, -- CoachingStatusId - int
	         @apiEventId, -- ApiEventId - varchar(1024)
	         NULL, -- ApiMetadataId - varchar(1024)
	         GETDATE(), -- LastOperation - smalldatetime
	         0, -- Archived - bit
	         NULL, -- MinX - float
	         NULL, -- MaxX - float
	         NULL, -- MinY - float
	         NULL, -- MaxY - float
	         NULL, -- MinZ - float
	         NULL, -- MaxZ - float
	         0, -- IsEscalated - bit
	         0.0, -- Lat - float
	         0.0, -- Long - float
	         0, -- Heading - smallint
	         0  -- Speed - smallint
	        )

	SELECT @incidentId = SCOPE_IDENTITY()

	-- Write the video

	--first of all, need to write a dumy record to obtain the correct seq id

	INSERT INTO dbo.CAM_VideoIn
				( ApiEventId,
				  ApiVideoId,
				  ApiFileName,
				  ApiStartTime,
				  ApiEndTime,
				  CameraNumber,
				  LastOperation,
				  Archived,
				  VideoStatus,
				  ProjectId
				)
	VALUES ('','','',GETDATE(),GETDATE(),-1,GETDATE(),0,-1,'dummy')
	
	SELECT @videoId = SCOPE_IDENTITY()

	DELETE FROM dbo.CAM_VideoIn WHERE VideoInId = @videoId

	INSERT INTO dbo.CAM_Video
	        (IncidentId,
	         ApiEventId,
	         ApiVideoId,
	         ApiFileName,
	         ApiStartTime,
	         ApiEndTime,
	         CameraNumber,
	         LastOperation,
	         Archived,
	         VideoStatus,
	         VideoId,
	         IsVideoStoredLocally
	        )
	VALUES  (@incidentId, -- IncidentId - bigint
	         @apiEventId, -- ApiEventId - varchar(1024)
	         @apiVideoId, -- ApiVideoId - varchar(1024)
	         '', -- ApiFileName - varchar(1024)
	         @sdate, -- ApiStartTime - datetime
	         @edate, -- ApiEndTime - datetime
	         @camera, -- CameraNumber - int
	         GETDATE(), -- LastOperation - smalldatetime
	         0, -- Archived - bit
	         @videoStatus, -- VideoStatus - int
	         @videoId, -- VideoId - bigint
	         0  -- IsVideoStoredLocally - bit
	        )
GO
