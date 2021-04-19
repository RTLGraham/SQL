SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

---- =====================================================================================================================
---- Author:	  Graham Pattison
---- Create date: 2015-04-23
---- Updated:     
---- Description: Reads data from three incoming files and process it to populate Event, CAM_Incident and CAM_Video tables
---- 28/01/16 : Added Transaction Processing to ensure no data is lost in the event of a deadlock
---- =====================================================================================================================
CREATE PROCEDURE [dbo].[proc_ProcessCameras]
AS

-- First of all check whether or not this process is still running
-- by trying to create a temprary table
SELECT MyVar = 5 INTO #ProcessCameras

IF @@ERROR <> 0
BEGIN
	-- do nothing!
	SELECT 0
END ELSE

BEGIN
	SET NOCOUNT ON;
	
	DECLARE @did UNIQUEIDENTIFIER,
			@dintid INT,
			@vintid INT,
			@cameraintid INT,
			@customerintid INT,
			@EventInId BIGINT,

			@MetadataInId BIGINT,
			@MetadataMinX FLOAT,
			@MetadataMaxX FLOAT,
			@MetadataMinY FLOAT,
			@MetadataMaxY FLOAT,
			@MetadataMinZ FLOAT,
			@MetadataMaxZ FLOAT,

			@ProjectId VARCHAR(1024),
			@VehicleId UNIQUEIDENTIFIER,
			@VehicleIntId INT,
			@EventDateTime DATETIME,
			@ApiEventId VARCHAR(1024),
			@ApiMetadataId VARCHAR(1024),
			@ApiStartTime DATETIME,
			@ApiEndTime DATETIME,
			@HasMetadata TINYINT,
			@CameraId UNIQUEIDENTIFIER,
			@CcId SMALLINT,
			@CCFound SMALLINT,
			@Lat FLOAT,
			@Long FLOAT,
			@Speed SMALLINT,
			@Heading SMALLINT,
			@eid BIGINT,
			@incidentId BIGINT,
			@hasAnalyst BIT,
			@shareVideos BIT,
			@softlock INT,
			@locktime DATETIME,
			@now DATETIME

	-- ====================================================================================================================================================
	-- Use softlocking to try and eliminate job failures through deadlocks.
	-- Perform Soft Lock check to ensure Populate Cam from Gopher is not running before commencing processing. Retry after 5 seconds.
	-- If soft lock has not been released after 90 seconds then attempt processing anyway
	-- ====================================================================================================================================================

	-- Insert row for this process
	WAITFOR DELAY '00:00:03' -- 3 second delay to allow CAM from Gopher to begin first and minimise chance of deadlock
	INSERT INTO dbo.CAM_SoftLock (ProcessName, LockTime, LockStatus)
	VALUES  ('Process Cameras', GETDATE(), 'Waiting')

	SET @softlock = 1
	WHILE ISNULL(@softlock, 0) > 0
	BEGIN
		SELECT @softlock = COUNT(*), @locktime = MAX(LockTime)
		FROM dbo.CAM_SoftLock
		WHERE ProcessName = 'Populate CAM from Gopher'
		IF ISNULL(@softlock, 0) > 0 WAITFOR DELAY '00:00:05' -- Wait 5 seconds before trying again
		-- Next step is a 'safety' feature. Iff lock has existed for more than 65 seconds then delete soft lock and try processing anyway
		IF DATEDIFF(ss, @locktime, GETDATE()) > 90 DELETE FROM dbo.CAM_SoftLock WHERE ProcessName = 'Populate CAM from Gopher'
	END	

	-- Now mark process as running
	UPDATE dbo.CAM_SoftLock SET LockStatus = 'Running' WHERE ProcessName = 'Process Cameras'

	-- ====================================================================================================================================================
	-- First process the CAM_EventIn table
	-- ====================================================================================================================================================
	
	UPDATE dbo.CAM_EventIn
	SET Archived = 1
	WHERE Archived = 0
	
	-- Use a cursor to process each event in turn
	DECLARE Event_cursor CURSOR FAST_FORWARD FOR
		SELECT EventInId,ProjectId,VehicleId,EventDateTime,ApiEventId,CameraId,Lat,Long,Speed,Heading,ISNULL(ecc.CreationCodeId,0)
		FROM dbo.CAM_EventIn i
		INNER JOIN dbo.CAM_EventTypeCreationCode ecc ON ecc.EventType = i.EventType
		WHERE i.Archived = 1 AND ecc.Archived = 0

	OPEN Event_cursor
	FETCH NEXT FROM Event_cursor INTO @EventInId,@ProjectId,@VehicleId,@EventDateTime,@ApiEventId,@CameraId,@Lat,@Long,@Speed,@Heading,@CcId
	WHILE @@fetch_status = 0
	BEGIN
		-- initialise Variables
		SET @customerintid = NULL
		SET @vintid = NULL
		SET @dintid = NULL
		SET @eid = NULL

		EXEC dbo.proc_CAM_WriteEventTemp @vid = @VehicleId,
			@driverid = NULL,
			@ccid = @CcId,
			@long = @Long,
			@lat = @Lat,
			@heading = @Heading,
			@speed = @Speed,
			@odogps = 0,
			@odotrip = 0,
			@eventdt = @EventDateTime,
			@customerintid = @customerintid OUTPUT,
			@vintid = @vintid OUTPUT,
			@dintid = @dintid OUTPUT,
			@eid = @eid OUTPUT

		SELECT @cameraintid = CameraIntId FROM dbo.Camera WHERE CameraId = @CameraId

		-- Now write the corresponding Incident using Coaching Status Id = Unknown (New)
		INSERT INTO dbo.CAM_Incident (EventId, EventDateTime, CreationCodeId, CustomerIntId, VehicleIntId, DriverIntId, CameraIntId, CoachingStatusId, ApiEventId, Lat, Long, Heading, Speed, LastOperation, Archived)
		VALUES  (@eid, @EventDateTime, @CcId, @customerintid, @vintid, @dintid, @cameraintid, 0, @ApiEventId, @Lat, @Long, @Heading, @Speed, GETDATE(), 0)
		
		SET @incidentId = SCOPE_IDENTITY()

		-- Check Customer Preference to see if the customer has an Analyst
		SELECT @hasAnalyst = ISNULL(dbo.CustomerPref(dbo.GetCustomerIdFromInt(@customerintid), 1700),0)

		--Check Customer Preference to see if button presses should be automatically shared with drivers
		SET @shareVideos = 0 -- initialise
		SELECT @shareVideos = ISNULL(dbo.CustomerPref(dbo.GetCustomerIdFromInt(@customerintid), 3013),0)

		-- If this incident is a button press and videos are auto shared then automatically share the incident with the Driver
		IF @CcId = 55 AND @shareVideos = 1
			INSERT INTO dbo.ObjectShare (ObjectId, ObjectIntId, ObjectTypeId, EntityId, EntityTypeId, LastModifiedDateTime, Archived)
			VALUES  (NULL, @incidentId, 1, dbo.GetDriverIdFromInt(@dintid), 2, GETDATE(), 0)

		-- Prevent double counting of high events by setting ccid to 0 (will be counted correctly by metadata)
		IF @CcId NOT IN (457, 458) -- not low or med manoeuvres
			SET @CcId = 0

		-- If the customer does NOT have an Analyst OR the event is a low/medium event, change the coaching status to 'For Review' and handle ABC codes accordingly by calling ChangeEventVideoStatus
		IF @hasAnalyst = 0 OR @CcId IN (457, 458)
		BEGIN
			EXEC dbo.proc_ChangeEventVideoStatus @incidentId, NULL, 1, NULL, @CcId	
		END			 

		-- Finally remove the EventIn data that has just been processed
		DELETE
		FROM dbo.CAM_EventIn
		WHERE EventInId = @EventInId

		FETCH NEXT FROM Event_cursor INTO @EventInId,@ProjectId,@VehicleId,@EventDateTime,@ApiEventId,@CameraId,@Lat,@Long,@Speed,@Heading,@CcId
	END 
	CLOSE Event_cursor
	DEALLOCATE Event_cursor		
	
	-- =====================================================================================================================================================
	-- Second process the CAM_MetadataIn table
	-- =====================================================================================================================================================
	
	UPDATE dbo.CAM_MetadataIn
	SET Archived = 1
	FROM dbo.CAM_MetadataIn m
	INNER JOIN dbo.CAM_Incident i ON i.ApiEventId = m.ApiEventId
	INNER JOIN dbo.Event e WITH (NOLOCK) ON e.EventId = i.EventId
	WHERE m.Archived = 0
	
	-- Use a cursor to process each item of metadata in turn (so that can handle updates to reportingABC)
	DECLARE mData_cursor CURSOR FAST_FORWARD FOR
		SELECT	m.MetadataInId, m.CreationCodeId, m.ApiEventId, m.ApiMetadataId, 
				m.MinX, m.MaxX,
				m.MinY, m.MaxY,
				m.MinZ, m.MaxZ
		FROM dbo.CAM_MetadataIn m
		WHERE m.Archived = 1
			
	OPEN mData_cursor
	FETCH NEXT FROM mData_cursor INTO	@MetadataInId, @CcId, @ApiEventId, @ApiMetadataId,
										@MetadataMinX, @MetadataMaxX,
										@MetadataMinY, @MetadataMaxY,
										@MetadataMinZ, @MetadataMaxZ
	WHILE @@fetch_status = 0
	BEGIN
			
		-- Check to see if the incident already has Metadata (no ABC counting required)
		SET @HasMetadata = 0 -- initialise count

		SELECT @HasMetadata = COUNT(*)
		FROM dbo.CAM_Incident
		WHERE ApiEventId = @ApiEventId
			AND ApiMetadataId IS NOT NULL	

		-- Update the Incident that was created from a previous incoming event
		UPDATE dbo.CAM_Incident
		SET ApiMetadataId = @ApiMetadataId,
			CreationCodeId = @CcId,
			LastOperation = GETDATE(),
			MinX = @MetadataMinX,
			MaxX = @MetadataMaxX,
			MinY = @MetadataMinY,
			MaxY = @MetadataMaxY,
			MinZ = @MetadataMinZ,
			MaxZ = @MetadataMaxZ
		WHERE ApiEventId = @ApiEventId AND CreationCodeId NOT IN (55,455) --,436,437,438)

		-- The following code removed and new columns added to CAM_Incident to resolve performance issues
		-------------------------------------------------------------------------------------------------
		---- Update the Event table to reflect the correct CreationCode (update both EventTemp and Event - although only one will actually update)
		--UPDATE dbo.EventTemp
		--SET CreationCodeId = i.CreationCodeId --@CcId
		--FROM dbo.CAM_Incident i 
		--INNER JOIN dbo.EventTemp e ON i.EventId = e.EventId
		--WHERE i.ApiEventId = @ApiEventId --AND i.CreationCodeId NOT IN (55,455,436,437,438)
		--	AND i.CreationCodeId != e.CreationCodeId

		--UPDATE dbo.Event
		--SET CreationCodeId = i.CreationCodeId --@CcId
		--FROM dbo.CAM_Incident i 
		--INNER JOIN dbo.Event e ON i.EventId = e.EventId
		--WHERE i.ApiEventId = @ApiEventId --AND i.CreationCodeId NOT IN (55,455,436,437,438)
		--	AND i.CreationCodeId != e.CreationCodeId

		-- Now get Customer and Incident to determine what, if any, updates are required to ReportingABC
		SELECT @customerintid = CustomerIntId, @incidentId = IncidentId
		FROM dbo.CAM_Incident
		WHERE ApiEventId = @ApiEventId

		-- Check Customer Preference to see if the customer has an Analyst
		SELECT @hasAnalyst = ISNULL(dbo.CustomerPref(dbo.GetCustomerIdFromInt(@customerintid), 1700),0)

		-- If the customer does NOT have an Analyst AND Incident did not previously have any Metadata then
		-- handle ABC codes accordingly by calling ChangeEventVideoStatus (but use status -1 to indicate no change of status)
		IF @hasAnalyst = 0 AND @CcId IN (36,37,38,336,337,338,436,437,438) AND @HasMetadata = 0
		BEGIN
			EXEC dbo.proc_ChangeEventVideoStatus @incidentId, NULL, -1, NULL, @CcId	
		END	

		-- Finally remove the MetadataIn data that has just been processed
		DELETE
		FROM dbo.CAM_MetadataIn
		WHERE MetadataInId = @MetadataInId

		FETCH NEXT FROM mData_cursor INTO	@MetadataInId, @CcId, @ApiEventId, @ApiMetadataId,
											@MetadataMinX, @MetadataMaxX,
											@MetadataMinY, @MetadataMaxY,
											@MetadataMinZ, @MetadataMaxZ
	END 
	CLOSE mData_cursor
	DEALLOCATE mData_cursor	

	-- ====================================================================================================================================================
	-- Third process the CAM_VideoIn table
	-- ====================================================================================================================================================

	SET @now = GETDATE()

	UPDATE dbo.CAM_VideoIn
	SET Archived = 1
	WHERE Archived = 0

	-- Perform trigger and notifications checks before inserting video as relies on checking for a video already existing

	-- Insert a trigger into TAN_TriggerEvent for all high/button videos received with status = 1 (Complete)
	INSERT INTO dbo.TAN_TriggerEvent (TriggerEventId, CreationCodeId, EventId, CustomerIntId, VehicleIntID, DriverIntId, ApplicationId, Long, Lat, Heading, Speed, TriggerDateTime, ProcessInd, LastOperation)
	--SELECT NEWID(), 137, i.EventId, i.CustomerIntId, i.VehicleIntId, i.DriverIntId, 9, ISNULL(e.Long, et.Long), ISNULL(e.Lat, et.Lat), ISNULL(e.Heading, et.Heading), ISNULL(e.Speed, et.Speed), i.EventDateTime, 0, GETDATE()
	SELECT NEWID(), 137, i.EventId, i.CustomerIntId, i.VehicleIntId, i.DriverIntId, 15, i.Long, i.Lat, i.Heading, i.Speed, i.EventDateTime, 0, GETDATE()
	FROM dbo.CAM_VideoIn v
	INNER JOIN dbo.CAM_Incident i ON v.ApiEventId = i.ApiEventId AND v.Archived = 1
	LEFT JOIN dbo.CAM_Video cv ON cv.ApiEventId = v.ApiEventId AND cv.Archived = 0 AND cv.VideoStatus = 1 AND v.VideoInId != cv.VideoId AND cv.LastOperation != @now  AND cv.CameraNumber = 1
	--LEFT JOIN dbo.Event e WITH (NOLOCK) ON e.EventId = i.EventId
	--LEFT JOIN dbo.EventTemp et ON et.EventId = i.EventId -- join in case Event not yet inserted
	WHERE v.VideoStatus = 1
		AND i.CreationCodeId IN (436,437,438,55)
		AND cv.VideoId IS NULL -- only notify if we don't already have a completed video for camera 1 for this incident

	INSERT INTO dbo.UserMobileNotification( UserMobileNotificationId, CreationCodeId, EventId, CustomerIntId, VehicleIntID, DriverIntId, ApplicationId, Long, Lat, Heading, Speed, TriggerDateTime, ProcessInd, LastOperation)
	--SELECT NEWID(), 137, i.EventId, i.CustomerIntId, i.VehicleIntId, i.DriverIntId, 9, ISNULL(e.Long, et.Long), ISNULL(e.Lat, et.Lat), ISNULL(e.Heading, et.Heading), ISNULL(e.Speed, et.Speed), i.EventDateTime, 0, GETDATE()
	SELECT NEWID(), 137, i.EventId, i.CustomerIntId, i.VehicleIntId, i.DriverIntId, 15, i.Long, i.Lat, i.Heading, i.Speed, i.EventDateTime, 0, GETDATE()
	FROM dbo.CAM_VideoIn v
		INNER JOIN dbo.CAM_Incident i ON v.ApiEventId = i.ApiEventId AND v.Archived = 1
		INNER JOIN dbo.Vehicle veh ON veh.VehicleIntId = i.VehicleIntId
		INNER JOIN dbo.GroupDetail gd ON veh.VehicleId = gd.EntityDataId
		INNER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId
		INNER JOIN dbo.UserGroup ug ON ug.GroupId = g.GroupId
		INNER JOIN dbo.[User] u ON u.UserID = ug.UserId
		INNER JOIN dbo.UserMobileToken umt ON umt.UserId = u.UserID
		LEFT JOIN dbo.CAM_Video cv ON cv.ApiEventId = v.ApiEventId AND cv.Archived = 0 AND cv.VideoStatus = 1 AND v.VideoInId != cv.VideoId AND cv.LastOperation != @now AND cv.CameraNumber = 1
		--LEFT JOIN dbo.Event e WITH (NOLOCK) ON e.EventId = i.EventId
		--LEFT JOIN dbo.EventTemp et ON et.EventId = i.EventId -- join in case Event not yet inserted
	WHERE v.VideoStatus = 1
		AND i.CreationCodeId IN (436,437,438,55)
		AND cv.VideoId IS NULL -- only notify if we don't already have a completed video for camera 1 for this incident
		AND umt.Archived = 0 --oly for vehicles that have users with tokens
	GROUP BY i.EventId, i.CustomerIntId, i.VehicleIntId, i.DriverIntId, i.Long, i.Lat, i.Heading, i.Speed, i.EventDateTime

	-- Now insert the video data by matching to APIEventId
	INSERT INTO dbo.CAM_Video (VideoId, IncidentId, ApiEventId, ApiVideoId, ApiFileName, ApiStartTime, ApiEndTime, CameraNumber, LastOperation, Archived, VideoStatus)
	SELECT  v.VideoInId, i.IncidentId, v.ApiEventId, v.ApiVideoId, v.ApiFileName, v.ApiStartTime, v.ApiEndTime, v.CameraNumber, @now, 0, v.VideoStatus
	FROM dbo.CAM_VideoIn v
	INNER JOIN dbo.CAM_Incident i ON v.ApiEventId = i.ApiEventId AND v.Archived = 1

	-- Now cursor round the videos for creation code 455 to try and determine real reason code
	-- increase time band by 2.5 minutes either side to allow for camera time differences
	DECLARE vData_cursor CURSOR FAST_FORWARD FOR
		SELECT DISTINCT i.IncidentId, i.VehicleIntId, i.DriverIntId, DATEADD(ss, -150, v.ApiStartTime), DATEADD(ss, 150, v.ApiEndTime), i.CustomerIntId
		FROM dbo.CAM_VideoIn v
		INNER JOIN dbo.CAM_Incident i ON v.ApiEventId = i.ApiEventId AND v.Archived = 1
		WHERE i.CreationCodeId = 455

	OPEN vData_cursor
	FETCH NEXT FROM vData_cursor INTO @incidentId, @VehicleIntId, @dintid, @ApiStartTime, @ApiEndTime, @customerintid
	WHILE @@fetch_status = 0
	BEGIN
		-- Check for ROP Stage 2 and 1
		SET @CCFound = NULL -- initialise value
		SELECT TOP 1 @CCFound = CreationCodeId 
		FROM dbo.Event WITH (NOLOCK)
		WHERE VehicleIntId = @VehicleIntId
			AND CreationCodeId IN (30, 231)
			AND EventDateTime BETWEEN @ApiStartTime AND @ApiEndTime
		ORDER BY CreationCodeId DESC	

		IF @CCFound IS NOT NULL	-- we have found a ROP stage 1 or 2
		BEGIN
			UPDATE dbo.CAM_Incident
			SET CreationCodeId = CASE @CCFound 
									WHEN 30 THEN 455
									WHEN 231 THEN 456 
									END	
			WHERE IncidentId = @incidentId
		END	ELSE	
		BEGIN -- see if the 455 was caused by a Telematics Harsh Manoeuvre Trigger
			SELECT TOP 1 @CCFound = CreationCodeId
			FROM dbo.EventData WITH (NOLOCK)
			WHERE VehicleIntId = @VehicleIntId
				AND EventDateTime BETWEEN @ApiStartTime AND @ApiEndTime
				AND EventDataName = 'HMV'

			IF @CCFound IS NOT NULL -- We have a Telematics Harsh Manoeuvre Trigger
			BEGIN
				UPDATE dbo.CAM_Incident
				SET CreationCodeId = 56
				WHERE IncidentId = @incidentId					
			END ELSE						
			BEGIN -- see if the 455 was caused by a Cheetah reboot
				SELECT TOP 1 @CCFound = CreationCodeId
				FROM dbo.EventData WITH (NOLOCK)
				WHERE VehicleIntId = @VehicleIntId
					AND EventDateTime BETWEEN @ApiStartTime AND @ApiEndTime
					AND EventDataName IN ('SWS', 'CFG', 'DSW')

				IF @CCFound IS NOT NULL -- We have a probable Cheetah reboot
				BEGIN
					UPDATE dbo.CAM_Incident
					SET CreationCodeId = 28
					WHERE IncidentId = @incidentId
				END ELSE	

				BEGIN -- We have a button press
					UPDATE dbo.CAM_Incident
					SET CreationCodeId = 55
					WHERE IncidentId = @incidentId	

					--Check Customer Preference to see if button presses should be automatically shared with drivers
					SET @shareVideos = 0 -- initialise
					SELECT @shareVideos = ISNULL(dbo.CustomerPref(dbo.GetCustomerIdFromInt(@customerintid), 3013),0)

					-- Escalate the button press to the driver
					IF @shareVideos = 1
					BEGIN	
						INSERT INTO dbo.ObjectShare (ObjectId, ObjectIntId, ObjectTypeId, EntityId, EntityTypeId, LastModifiedDateTime, Archived)
						VALUES  (NULL, @incidentId, 1, dbo.GetDriverIdFromInt(@dintid), 2, GETDATE(), 0)
					END	
				END	
			END
		END	

		FETCH NEXT FROM vData_cursor INTO @incidentId, @VehicleIntId, @dintid, @ApiStartTime, @ApiEndTime, @customerintid
	END	
	CLOSE vData_cursor
	DEALLOCATE vData_cursor	

	-- Delete only the rows that have been processed - any rows not processed due to missing data will be retried on next execution
		
	DELETE v
	FROM dbo.CAM_VideoIn v
	INNER JOIN dbo.CAM_Incident i ON v.ApiEventId = i.ApiEventId AND v.Archived = 1

	-- Delete temporary table to indicate job has completed
	DROP TABLE #ProcessCameras

	-- Delete soft locking row
	DELETE	
	FROM dbo.CAM_SoftLock
	WHERE ProcessName = 'Process Cameras'

END

GO
