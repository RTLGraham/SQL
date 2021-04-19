SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_Driver_ManageLoneWorker]
(
	@LoneWorkerId INT = NULL,
	@DriverId UNIQUEIDENTIFIER,
	@StartTime DATETIME,
	@DurationMins INT,
	@Lat FLOAT = NULL,
	@Lon FLOAT = NULL,
	@PosX FLOAT = NULL,
	@PosY FLOAT = NULL,
	@PosZ FLOAT = NULL,
	@Speed FLOAT = NULL,
	@CommandType INT,
	@AddtlData VARCHAR(1024) = NULL
)
AS
BEGIN

	--WAITFOR DELAY '00:01:10' -- For testing only to cause timeout to exceed
	--RETURN		

	DECLARE @alarm BIT	

	IF @CommandType = 1 -- Start Lone Worker Timer
    BEGIN
			INSERT INTO dbo.LW_LoneWorker (DriverId, StartTime, Duration, Lat, Lon, PosX, PosY, PosZ, Speed, AddtlData)
			VALUES  (@DriverId, @StartTime, @DurationMins, @Lat, @Lon, @PosX, @PosY, @PosZ, @Speed, @AddtlData)

			SET @LoneWorkerId = SCOPE_IDENTITY()
	END	

	IF @CommandType = 2 -- Extend Lone Worker Duration
	BEGIN
			UPDATE dbo.LW_LoneWorker
			SET Duration = @DurationMins, Lat = @Lat, Lon = @Lon
			WHERE LoneWorkerId = @LoneWorkerId
	END	

	IF @CommandType = 3 -- Stop lone Worker Timer (StartTime is used for purposes of passing the actual Stop Time)
	BEGIN
			-- Check to see if the event has already sent an alarm
			SELECT @alarm = CASE WHEN AlarmTriggeredDateTime IS NULL THEN 0 ELSE 1 END 
			FROM dbo.LW_LoneWorker
			WHERE LoneWorkerId = @LoneWorkerId

			IF @alarm = 1 -- Alarm has already been sent so send a 'cancellation' trigger
			BEGIN
 				INSERT INTO dbo.TAN_TriggerEvent (TriggerEventId, CreationCodeId, EventId, CustomerIntId, VehicleIntID, DriverIntId, ApplicationId,
													Long, Lat, Speed, DataString, DataInt, TriggerDateTime, ProcessInd, LastOperation, GeofenceId)
				SELECT NEWID(), 141, 0, c.CustomerIntId, NULL, d.DriverIntId, 9, @Lon, @Lat, @Speed, 'Timer exceeded but Lone Worker stopped by driver - driver safe|not required', @LoneWorkerId, @StartTime, 0, GETDATE(), NULL
				FROM dbo.Driver d 
				INNER JOIN dbo.CustomerDriver cd ON cd.DriverId = d.DriverId
				INNER JOIN dbo.Customer c ON c.CustomerId = cd.CustomerId
				WHERE d.DriverId = @DriverId
				  AND cd.Archived = 0
				  AND cd.EndDate IS NULL           
			END	

			UPDATE dbo.LW_LoneWorker
			SET StopTime = @StartTime, Lat = @Lat, Lon = @Lon
			WHERE LoneWorkerId = @LoneWorkerId
	END 

	IF @CommandType = 4 -- Panic (StartTime is used for purposes of passing the actual Panic Time
	BEGIN

		-- Record Panic in the LW table
		IF @LoneWorkerId IS NULL -- this is a panic while no currently active Lone Worker session
		BEGIN	
			INSERT INTO dbo.LW_LoneWorker (DriverId, StartTime, Duration, StopTime, Lat, Lon, PosX, PosY, PosZ, Speed, AlarmTriggeredDateTime, PanicStart, AddtlData)
			VALUES  (@DriverId, @StartTime, @DurationMins, NULL, @Lat, @Lon, @PosX, @PosY, @PosZ, @Speed, @StartTime, @StartTime, @AddtlData)
			SET @LoneWorkerId = SCOPE_IDENTITY()
		END ELSE
        BEGIN -- Mark Panic start on existing Lone Worker Session
			UPDATE dbo.LW_LoneWorker 
			SET PanicStart = @StartTime, Lat = @Lat, Lon = @Lon
			WHERE LoneWorkerId = @LoneWorkerId
		END	

		INSERT INTO dbo.TAN_TriggerEvent (TriggerEventId, CreationCodeId, EventId, CustomerIntId, VehicleIntID, DriverIntId, ApplicationId,
											Long, Lat, Speed, DataString, DataInt, TriggerDateTime, ProcessInd, LastOperation, GeofenceId)
		SELECT NEWID(), 141, 0, c.CustomerIntId, NULL, d.DriverIntId, 9, @Lon, @Lat, @Speed, 'Panic button activated by driver' + ISNULL('|' + @AddtlData, ''), @LoneWorkerId, @StartTime, 0, GETDATE(), NULL
		FROM dbo.Driver d 
		INNER JOIN dbo.CustomerDriver cd ON cd.DriverId = d.DriverId
		INNER JOIN dbo.Customer c ON c.CustomerId = cd.CustomerId
		WHERE d.DriverId = @DriverId
		  AND cd.Archived = 0
		  AND cd.EndDate IS NULL
		   
		-- In parallel, insert into TAN_TriggerEvent to generate escalation level 1 and 2 triggers. These will fire if not acknowledged before the trigger delay time is reached
		-- Escalation 1
		INSERT INTO dbo.TAN_TriggerEvent (TriggerEventId, CreationCodeId, EventId, CustomerIntId, VehicleIntID, DriverIntId, ApplicationId, Long, Lat, Speed, DataString, DataInt, TriggerDateTime, ProcessInd, LastOperation, GeofenceId)
		SELECT NEWID(), 145, 0, c.CustomerIntId, NULL, d.DriverIntId, 9, @Lon, @Lat, @Speed, 'Escalation level 1 delay expired' + ISNULL('|' + @AddtlData, ''), @LoneWorkerId, @StartTime, 0, GETDATE(), NULL
		FROM dbo.Driver d
		INNER JOIN dbo.CustomerDriver cd ON cd.DriverId = d.DriverId
		INNER JOIN dbo.Customer c ON c.CustomerId = cd.CustomerId
		WHERE d.DriverId = @DriverId
		  AND cd.Archived = 0
		  AND cd.EndDate IS NULL

		-- Escalation 2
		INSERT INTO dbo.TAN_TriggerEvent (TriggerEventId, CreationCodeId, EventId, CustomerIntId, VehicleIntID, DriverIntId, ApplicationId, Long, Lat, Speed, DataString, DataInt, TriggerDateTime, ProcessInd, LastOperation, GeofenceId)
		SELECT NEWID(), 146, 0, c.CustomerIntId, NULL, d.DriverIntId, 9, @Lon, @Lat, @Speed, 'Escalation level 2 delay expired' + ISNULL('|' + @AddtlData, ''), @LoneWorkerId, @StartTime, 0, GETDATE(), NULL
		FROM dbo.Driver d
		INNER JOIN dbo.CustomerDriver cd ON cd.DriverId = d.DriverId
		INNER JOIN dbo.Customer c ON c.CustomerId = cd.CustomerId
		WHERE d.DriverId = @DriverId
		  AND cd.Archived = 0
		  AND cd.EndDate IS NULL		  
	END
    
	IF @CommandType = 5 -- Release Panic
	BEGIN
		INSERT INTO dbo.TAN_TriggerEvent (TriggerEventId, CreationCodeId, EventId, CustomerIntId, VehicleIntID, DriverIntId, ApplicationId,
											Long, Lat, Speed, DataString, DataInt, TriggerDateTime, ProcessInd, LastOperation, GeofenceId)
		SELECT NEWID(), 141, 0, c.CustomerIntId, NULL, d.DriverIntId, 9, @Lon, @Lat, @Speed, 'Panic button released - driver safe|not required', @LoneWorkerId, @StartTime, 0, GETDATE(), NULL
		FROM dbo.Driver d 
		INNER JOIN dbo.CustomerDriver cd ON cd.DriverId = d.DriverId
		INNER JOIN dbo.Customer c ON c.CustomerId = cd.CustomerId
		WHERE d.DriverId = @DriverId
		  AND cd.Archived = 0
		  AND cd.EndDate IS NULL	

		-- Cancel any outstanding Lone Worker escalations
		UPDATE dbo.TAN_TriggerEvent
		SET ProcessInd = 5 -- Ignore
		FROM dbo.TAN_TriggerEvent tev
		INNER JOIN dbo.Driver d ON d.DriverIntId = tev.DriverIntId 
		INNER JOIN dbo.CustomerDriver cd ON cd.DriverId = d.DriverId
		INNER JOIN dbo.Customer c ON c.CustomerId = cd.CustomerId
		WHERE d.DriverId = @DriverId
		  AND cd.Archived = 0
		  AND cd.EndDate IS NULL
		  AND tev.CreationCodeId IN (145, 146) -- Lone Worker Escalations

		-- Update the status on the LW table for the Panic Release
		UPDATE dbo.LW_LoneWorker
		SET PanicRelease = @StartTime, Lat = @Lat, Lon = @Lon
		WHERE LoneWorkerId = @LoneWorkerId
	
	END	

	SELECT 	@LoneWorkerId AS LoneWorkerId,
			@DriverId AS DriverId,
			@StartTime AS StartTime,
			@DurationMins AS DurationMinutes,
			@Lat AS Latitude,
			@Lon AS Longitude,
			@PosX AS PositionX,
			@PosY AS PositionY,
			@PosZ AS PositionZ,
			@Speed AS Speed,
			@CommandType AS CommandType,
			@AddtlData AS AdditionalData

END


GO
