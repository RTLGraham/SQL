SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE PROC [dbo].[proc_BulkInsert]
AS
SELECT MyVar = 5 INTO #BulkInsertRunningTable

IF @@ERROR <> 0
BEGIN
	-- do nothing!
	SELECT 0
END
ELSE
BEGIN
-- should the update block below be a single transaction?
	UPDATE STOPITemp SET Archived = 0
	UPDATE RTIMETemp SET Archived = 0
	UPDATE RPMTemp SET Archived = 0
	UPDATE PassComfTemp SET Archived = 0
	UPDATE SnapshotTemp SET Archived = 0
	UPDATE AccumTemp SET Archived = 0
	UPDATE VehicleLatestEventTemp SET Archived = 0
	UPDATE DriverLatestEventTemp SET Archived = 0
	UPDATE VehicleLatestAllEventTemp SET Archived = 0
	UPDATE EventDataTemp SET Archived = 0
	UPDATE EventBlobTemp SET Archived = 0
	UPDATE EventTemp SET Archived = 0
	UPDATE EventListenerTemp SET Archived = 0
	UPDATE EventCamTemp SET Archived = 0
	Update TripsAndStopsTemp SET Archived = 0
	UPDATE VehicleAnalogIoDataTemp SET Archived = 0
	UPDATE LoadTemp SET Archived = 0
	UPDATE DgenTemp SET Archived = 0
	UPDATE HeartbeatTemp SET Archived = 0
	UPDATE LogDataTemp SET Archived = 0

	DECLARE @NumberOfEvents INT,
			@NumberOfListenerEvents INT,
			@NumberOfCamEvents INT

	DECLARE @TimeStart DateTime
	DECLARE @TimePrev DateTime
	DECLARE @TimeNow DateTime
	DECLARE @MillisecEvent int
	DECLARE @MillisecTotal int
	DECLARE @MillisecEventData INT
	DECLARE @MillisecEventBlob int
	DECLARE @MillisecVehicleLatestEvent int
	DECLARE @MillisecAccum int
	DECLARE @MillisecSnapshots int
	DECLARE @MillisecVorads int

	SET @TimeStart = GETDATE()

	EXEC proc_BulkInsertEvent
	IF (@@ERROR = 0)
	BEGIN
		SET @NumberOfEvents = (SELECT COUNT(*) AS NumberOfEvents FROM EventTemp WHERE Archived = 0)
		SET @NumberOfListenerEvents = (SELECT COUNT(*) AS NumberOfEvents FROM EventListenerTemp WHERE Archived = 0)
		SET @NumberOfCamEvents = (SELECT COUNT(*) AS NumberOfEvents FROM EventCamTemp WHERE Archived = 0)
		SET @NumberOfEvents = @NumberOfEvents + @NumberOfListenerEvents + @NumberOfCamEvents
		SET @TimeNow = GETDATE()
		SET @MillisecEvent = DATEDIFF(millisecond, @TimeStart, @TimeNow)
		SET @TimePrev = @TimeNow
	END
	ELSE
	BEGIN
		-- if Events fail, don't update others. Also reset Events not yet written
		UPDATE AccumTemp SET Archived = 1 WHERE Archived = 0
		UPDATE EventTemp SET Archived = 1 WHERE Archived = 0
		UPDATE EventListenerTemp SET Archived = 1 WHERE Archived = 0
		UPDATE EventCamTemp SET Archived = 1 WHERE Archived = 0
		UPDATE EventDataTemp SET Archived = 1 WHERE Archived = 0
		UPDATE EventBlobTemp SET Archived = 1 WHERE Archived = 0
		UPDATE VehicleLatestEventTemp SET Archived = 1 WHERE Archived = 0
		UPDATE DriverLatestEventTemp SET Archived = 1 WHERE Archived = 0
		UPDATE VehicleLatestAllEventTemp SET Archived = 1 WHERE Archived = 0
		UPDATE Snapshottemp SET Archived = 1 WHERE Archived = 0
		UPDATE STOPITemp SET Archived = 1 WHERE Archived = 0
		UPDATE RTIMETemp SET Archived = 1 WHERE Archived = 0
		UPDATE RPMTemp SET Archived = 1 WHERE Archived = 0
		UPDATE PassComfTemp SET Archived = 1 WHERE Archived = 0
		Update TripsAndStopsTemp SET Archived = 1 WHERE Archived = 0
		UPDATE VehicleAnalogIoDataTemp SET Archived = 1 WHERE Archived = 0
		UPDATE LoadTemp SET Archived = 1 WHERE Archived = 0
		UPDATE DgenTemp SET Archived = 1 WHERE Archived = 0
		UPDATE HeartbeatTemp SET Archived = 1 WHERE Archived = 0
		UPDATE LogDataTemp SET Archived = 1 WHERE Archived = 0
		
		SET @NumberOfEvents = 0
	END

	EXEC proc_BulkInsertEventData
	IF (@@ERROR <> 0) UPDATE EventDataTemp SET Archived = 1 WHERE Archived = 0	

	SET @TimeNow = GETDATE()
	SET @MillisecEventData = DATEDIFF(millisecond, @TimePrev, @TimeNow)
	SET @TimePrev = @TimeNow

	EXEC proc_BulkInsertEventBlob
	IF (@@ERROR <> 0) UPDATE EventBlobTemp SET Archived = 1 WHERE Archived = 0	

	SET @TimeNow = GETDATE()
	SET @MillisecEventBlob = DATEDIFF(millisecond, @TimePrev, @TimeNow)
	SET @TimePrev = @TimeNow

	EXEC proc_BulkInsertVehicleLatestEvent
	IF (@@ERROR <> 0) UPDATE VehicleLatestEventTemp SET Archived = 1 WHERE Archived = 0

	SET @TimeNow = GETDATE()
	SET @MillisecVehicleLatestEvent = DATEDIFF(millisecond, @TimePrev, @TimeNow)
	SET @TimePrev = @TimeNow
	
	EXEC proc_BulkInsertDriverLatestEvent
	IF (@@ERROR <> 0) UPDATE DriverLatestEventTemp SET Archived = 1 WHERE Archived = 0
	
	EXEC proc_BulkInsertVehicleLatestAllEvent
	IF (@@ERROR <> 0) UPDATE VehicleLatestAllEventTemp SET Archived = 1 WHERE Archived = 0
	
	SET @TimeNow = GETDATE()
	SET @MillisecVorads = DATEDIFF(millisecond, @TimePrev, @TimeNow)
	SET @TimePrev = @TimeNow

	EXEC proc_BulkInsertAccum
	IF (@@ERROR <> 0) UPDATE AccumTemp SET Archived = 1 WHERE Archived = 0

	SET @TimeNow = GETDATE()
	SET @MillisecAccum = DATEDIFF(millisecond, @TimePrev, @TimeNow)
	SET @TimePrev = @TimeNow

	EXEC proc_BulkInsertSnapshot
	IF (@@ERROR <> 0) UPDATE SnapshotTemp SET Archived = 1 WHERE Archived = 0

	SET @TimeNow = GETDATE()
	SET @MillisecSnapshots = DATEDIFF(millisecond, @TimePrev, @TimeNow)
	SET @TimePrev = @TimeNow
	
	EXEC proc_BulkInsertRTIME
	IF (@@ERROR <> 0) UPDATE RTIMETemp SET Archived = 1 WHERE Archived = 0

	EXEC proc_BulkInsertRPM
	IF (@@ERROR <> 0) UPDATE RPMTemp SET Archived = 1 WHERE Archived = 0

	EXEC proc_BulkInsertPassComf
	IF (@@ERROR <> 0) UPDATE PassComfTemp SET Archived = 1 WHERE Archived = 0

	EXEC proc_BulkInsertSTOPI
	IF (@@ERROR <> 0) UPDATE STOPITemp SET Archived = 1 WHERE Archived = 0

	EXEC proc_BulkInsertTripsAndStops
	--IF (@@ERROR <> 0) Update TripsAndStopsTemp SET Archived = 1 Where Archived = 0
	-- Above line moved to inside the called stored procedure

	EXEC proc_BulkInsertLoad
	IF (@@ERROR <> 0) Update LoadTemp SET Archived = 1 Where Archived = 0

	EXEC proc_BulkInsertVehicleAnalogIoData
	IF (@@ERROR <> 0) UPDATE VehicleAnalogIoDataTemp SET Archived = 1 WHERE Archived = 0
	
	EXEC proc_BulkInsertDGen
	IF (@@ERROR <> 0) Update DGenTemp SET Archived = 1 Where Archived = 0
	
	EXEC proc_BulkInsertHeartbeat
	IF (@@ERROR <> 0) Update HeartbeatTemp SET Archived = 1 Where Archived = 0

	EXEC proc_BulkInsertLogData
	IF (@@ERROR <> 0) Update LogDataTemp SET Archived = 1 Where Archived = 0

	DELETE FROM STOPITemp WHERE Archived = 0
	DELETE FROM RTIMETemp WHERE Archived = 0	
	DELETE FROM RPMTemp WHERE Archived = 0	
	DELETE FROM PassComfTemp WHERE Archived = 0	
	DELETE FROM SnapshotTemp WHERE Archived = 0
	DELETE FROM AccumTemp WHERE Archived = 0
	DELETE FROM EventTemp WHERE Archived = 0
	DELETE FROM EventListenerTemp WHERE Archived = 0
	DELETE FROM EventCamTemp WHERE Archived = 0
	DELETE FROM EventDataTemp WHERE Archived = 0
	DELETE FROM EventBlobTemp WHERE Archived = 0
	DELETE FROM VehicleLatestEventTemp WHERE Archived = 0
	DELETE FROM DriverLatestEventTemp WHERE Archived = 0
	DELETE FROM VehicleLatestAllEventTemp WHERE Archived = 0
	DELETE FROM TripsAndStopsTemp Where Archived = 0
	DELETE FROM LoadTemp Where Archived = 0
	DELETE FROM VehicleAnalogIoDataTemp WHERE Archived = 0
	DELETE FROM DGenTemp Where Archived = 0
	DELETE FROM HeartbeatTemp WHERE Archived = 0
	DELETE FROM LogDataTemp WHERE Archived = 0
	
	SET @TimeNow = GETDATE()
	SET @MillisecTotal = DATEDIFF(millisecond, @TimeStart, @TimeNow)
	INSERT INTO BulkInserts (EventCount, InsertDateTime, MilliSecondsTaken, MilliSecondsEventsData, MilliSecondsVehiclesLatestEvents, MilliSecondsAccums, MilliSecondsSnapshots, MilliSecondsVorads, MilliSecondsTotal) Values (@NumberOfEvents, @TimeNow, @MillisecEvent, @MillisecEventData, @MillisecVehicleLatestEvent, @MillisecAccum, @MillisecSnapshots, @MillisecVorads, @MillisecTotal)
END

DROP TABLE #BulkInsertRunningTable


GO
