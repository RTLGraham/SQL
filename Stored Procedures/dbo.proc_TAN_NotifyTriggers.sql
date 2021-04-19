SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ============================================================
-- Author:		Graham Pattison
-- Create date: 02/03/2011
-- Description:	Process rows from TAN_NotificationPending table
-- ============================================================
CREATE PROCEDURE [dbo].[proc_TAN_NotifyTriggers]
AS

-- First of all check whether or not this process is still running
-- by trying to create a temprary table
SELECT MyVar = 5 INTO #TAN_Notify_Running

IF @@ERROR <> 0
BEGIN
	-- do nothing!
	SELECT 0
END ELSE
BEGIN

	DECLARE @Notification table (
				NotificationId uniqueidentifier,
				NotificationTypeId SmallInt,
				TriggerId uniqueidentifier,
				TriggerTypeId int,
				RecipientAddress varchar(255),
				Header varchar(500),
				Body nvarchar(max),
				VehicleId uniqueidentifier,
				Registration varchar(20),
				DriverId UNIQUEIDENTIFIER,
				DriverName nvarchar(100),
				DriverNumber varchar(20),
				GeofenceId UNIQUEIDENTIFIER,
				GeofenceName NVARCHAR(255),
				DataString varchar(1024),
				DataInt INT,
				TriggerDateTime datetime,
				CreatedBy UNIQUEIDENTIFIER,
				EventId BIGINT,
				CreationCodeName NVARCHAR(50),
				Lat FLOAT,
				Long FLOAT,
				Speed SMALLINT)
				
	DECLARE @Recipients table (
				Id int,
				RecipientAddress varchar(50))
				
	DECLARE	@currNotificationId UNIQUEIDENTIFIER,
			@currType SMALLINT,
			@currTriggerId UNIQUEIDENTIFIER,
			@currTriggerTypeId INT,
			@currAddress varchar(255),
			@currHeader nvarchar(500),
			@currBody nvarchar(max),
			@currTriggerDateTime DATETIME,
			@usrTriggerDateTime DATETIME,
			@currVehicleId UNIQUEIDENTIFIER,
			@currDriverId UNIQUEIDENTIFIER,
			@currGeofenceId UNIQUEIDENTIFIER,
			@currDataString varchar(1024),
			@currDataInt INT,
			@currSpeed FLOAT,
			@currCreatedBy UNIQUEIDENTIFIER,
			@currEventId BIGINT,
			@currLat FLOAT,
			@currLong FLOAT,
			@RecipientList varchar(1024),
			@NotificationId BIGINT,
			@TriggerEntityId UNIQUEIDENTIFIER,
			@NotificationStatus INT,
			@mult FLOAT,
			@speedmultstring NVARCHAR(5),
			@tempmult FLOAT,
			@tempunit NVARCHAR(2),
			@liquidmult FLOAT,
			@dbname VARCHAR(50),
			@emailuserid UNIQUEIDENTIFIER

	-- Declare variables for token substitutions
	DECLARE @subRegistration varchar(20),		-- %%registration
			@subDriverName nvarchar(100),		-- %%drivername
			@subDriverNumber varchar(20),		-- %%drivernumber
			@subTriggerDate varchar(11),		-- %%triggerdate
			@subTriggerTime varchar(5),			-- %%triggertime
			@subTriggerDateTime varchar(17),	-- %%triggerfulldatetime
			@subLocation nvarchar(255),			-- %%location
			@subBlobDescription VARCHAR(1024),	-- %%blobdescription
			@subGeofenceName NVARCHAR(255),		-- %%geofencename
			@subSpeed varchar(10),				-- %%speed
			@subSensor1 varchar(10),			-- %%sensor1
			@subSensor2 varchar(10),			-- %%sensor2
			@subSensor3 varchar(10),			-- %%sensor3
			@subSensor4 varchar(10),			-- %%sensor4
			@subSensor1Name nvarchar(100),		-- %%sensor1name
			@subSensor2Name nvarchar(100),		-- %%sensor2name
			@subSensor3Name nvarchar(100),		-- %%sensor3name
			@subSensor4Name nvarchar(100),		-- %%sensor4name
			@subDigitalActivity nvarchar(100),	-- %%digitalactivity
			@subEventType nvarchar(50),			-- %%eventtype
			@subLWState NVARCHAR(100),			-- %%loneworkerstate
			@subLWURL NVARCHAR(300),			-- %%loneworkerurl
			@subLWContacts NVARCHAR(100)		-- %%loneworkercontacts

	-- Step 1 -- Mark all unprocessed rows in TAN_NotificationPending as 'In Progress'
	UPDATE TAN_NotificationPending
	SET ProcessInd = 1
	WHERE ProcessInd = 0
	
	-- Step 2 -- Get first Notification to Process
	INSERT INTO @Notification (
						NotificationId, 
						NotificationTypeId,
						TriggerId,
						TriggerTypeId,
						RecipientAddress,
						Header,
						Body,
						VehicleId,
						Registration,
						DriverId,
						DriverName,
						DriverNumber,
						GeofenceId,
						Geofencename,
						DataString,
						DataInt,
						TriggerDateTime,
						CreatedBy,
						EventId,
						CreationCodeName,
						Lat,
						Long,
						Speed)

	SELECT TOP 1	np.NotificationId,
					nt.NotificationTypeId,
					np.TriggerId,
					t.TriggerTypeId,
					rn.RecipientAddress,
					nt.Header,
					nt.Body,
					v.VehicleId,
					v.Registration,
					d.DriverId,
					d.Surname,
					d.Number,
					g.GeofenceId,
					g.Name,
					np.DataString,
					np.DataInt,
					np.TriggerDateTime,
					t.CreatedBy,
					np.EventId,
					ISNULL(cci.Name, 'Unknown Reason'),
					np.Lat,
					np.Long,
					np.Speed
	FROM TAN_NotificationPending np
	LEFT JOIN TAN_RecipientNotification rn ON np.NotificationTemplateId = rn.NotificationTemplateId
										   AND np.RecipientName = rn.RecipientName AND rn.Archived = 0
	INNER JOIN TAN_NotificationTemplate nt ON np.NotificationTemplateId = nt.NotificationTemplateId
	LEFT JOIN dbo.Vehicle v ON np.VehicleId = v.VehicleId
	LEFT JOIN dbo.Driver d ON np.DriverId = d.DriverId
	LEFT JOIN dbo.CAM_Incident i ON np.EventId = i.EventId
	LEFT JOIN dbo.CreationCode cci ON cci.CreationCodeId = i.CreationCodeId
	LEFT JOIN dbo.Geofence g ON np.GeofenceId = g.GeofenceId
	INNER JOIN TAN_Trigger t ON np.TriggerId = t.TriggerId
	WHERE np.ProcessInd = 1
	ORDER BY np.TriggerDateTime

	-- Step 3 -- Loop until all Notifications have been processed 
	WHILE ((SELECT NotificationId FROM @Notification) IS NOT NULL)
		BEGIN
		
			SET @NotificationStatus = 0 -- Initialise (assume Notification will be successful)
		
			SELECT	@currNotificationId = NotificationId,
					@currType = NotificationTypeId, 
					@currTriggerId = TriggerId,
					@currTriggerTypeId = TriggerTypeId,
					@currAddress = RecipientAddress, 
					@currHeader = Header, 
					@currBody = Body,
					@currVehicleId = VehicleId,
					@currDriverId = DriverId,
					@currGeofenceId = GeofenceId,
					@currTriggerDateTime = TriggerDateTime,
					@subRegistration = Registration,
					@subDriverName = DriverName,
					@subDriverNumber = DriverNumber,
					@subGeofencename = ISNULL(GeofenceName, dbo.[GetGeofenceNameFromLongLat] (Lat, Long, CreatedBy, 'Unknown')),
					@currDataString = DataString,
					@currDataInt = DataInt,
					@currEventId = EventId,
					@currLat = Lat,
					@currLong = Long,
					@currSpeed = Speed,
					@currCreatedBy = CreatedBy,
					@subLocation = CASE WHEN @subGeofenceName IS NULL OR @subGeofenceName = 'Unknown' THEN dbo.GetAddressFromLongLat(Lat, Long) ELSE @subGeofenceName END,
					@subEventType = CreationCodeName

			FROM @Notification
			
			-- Initialise any values not just selected
			SET @subSensor1 = NULL
			SET @subSensor2 = NULL
			SET @subSensor3 = NULL
			SET @subSensor4 = NULL
			SET @subSensor1Name = NULL
			SET @subSensor2Name = NULL
			SET @subSensor3Name = NULL
			SET @subSensor4Name = NULL
			SET @subDigitalActivity = NULL
			SET @subLWState = NULL
			SET @subLWURL = NULL
			SET @subLWContacts = NULL

			-- Add any token substitution or data pass through processing here
			IF @currTriggerTypeId = 21 -- Vehicle Error
				SET @subBlobDescription = @currDataString
			ELSE SET @subBlobDescription = 'Unknown'
			
			--IF @currTriggerTypeId IN (26,27) -- Speeding - need to convert from kmh to local unit
			--BEGIN
				SET @mult = dbo.UserPref(@currCreatedBy, 202)
				SET @subSpeed = ROUND(@currspeed * @mult * 1000, 0)
			--END	ELSE
			--	SET @subSpeed = ROUND(@currSpeed,0)
			SET @speedmultstring = dbo.UserPref(@currCreatedBy, 209)
			SET @subSpeed = @subSpeed + ISNULL(@speedmultstring, 'kph') -- use kph as default if no user preference
			
			SET @usrTriggerDateTime = dbo.TZ_GetTime(@currTriggerDateTime, NULL, @currCreatedBy)
			SET @subTriggerDate = CONVERT(varchar(11), @usrTriggerDateTime, 106)
			SET @subTriggerTime = CONVERT(varchar(5), @usrTriggerDateTime, 14)
			SET @subTriggerDateTime = @subTriggerDate + ' ' + @subTriggerTime
			IF @subLocation IS NULL
			BEGIN 
				SET @subLocation = 'Address Unknown'
			END 
			
			/*DJ: Added trigger 23,24,25 (Geofence Delay/Entry/Exit) to the lookup*/
			IF @currTriggerTypeId IN (2, 3, 4, 5, 28, 29, 30, 31, 23, 24, 25) -- Temperature triggers so get temperature values and convert accordingly
			BEGIN
				SET @tempmult = ISNULL(dbo.[UserPref](@currCreatedBy, 214), 1)
				SET @tempunit = ISNULL(dbo.[UserPref](@currCreatedBy, 215),'°C')
				SET @liquidmult = ISNULL(dbo.[UserPref](@currCreatedBy, 200),1)
				SELECT	@subSensor1 = STR(dbo.GetScaleConvertAnalogValue(AnalogData0, 0, @currVehicleId, @tempmult, @liquidmult),5,2) + @tempunit,
						@subSensor2 = STR(dbo.GetScaleConvertAnalogValue(AnalogData1, 1, @currVehicleId, @tempmult, @liquidmult),5,2) + @tempunit,
						@subSensor3 = STR(dbo.GetScaleConvertAnalogValue(AnalogData2, 2, @currVehicleId, @tempmult, @liquidmult),5,2) + @tempunit,
						@subSensor4 = STR(dbo.GetScaleConvertAnalogValue(AnalogData3, 3, @currVehicleId, @tempmult, @liquidmult),5,2) + @tempunit
				FROM dbo.Event WITH (NOLOCK)
				WHERE EventId = @currEventId
				
				SELECT  @subSensor1Name = vs1.Description,
						@subSensor2Name = vs2.Description,
						@subSensor3Name = vs3.Description,
						@subSensor4Name = vs4.Description
				FROM dbo.Vehicle v
				LEFT JOIN dbo.VehicleSensor vs1 ON v.VehicleIntId = vs1.VehicleIntId AND vs1.SensorId = 1 AND vs1.Enabled = 1
				LEFT JOIN dbo.VehicleSensor vs2 ON v.VehicleIntId = vs2.VehicleIntId AND vs2.SensorId = 2 AND vs2.Enabled = 1
				LEFT JOIN dbo.VehicleSensor vs3 ON v.VehicleIntId = vs3.VehicleIntId AND vs3.SensorId = 3 AND vs3.Enabled = 1
				LEFT JOIN dbo.VehicleSensor vs4 ON v.VehicleIntId = vs4.VehicleIntId AND vs4.SensorId = 4 AND vs4.Enabled = 1
				WHERE v.VehicleId = @currVehicleId
			END 
			
			IF @currTriggerTypeId IN (7, 8) -- Digitial IO 1 trigger so get Digital IO 1 information (sensor id 7)
			BEGIN
				SELECT  @subDigitalActivity = dst7.Description + ' ' + CASE WHEN @currTriggerTypeId = 7 THEN dst7.OnDescription ELSE dst7.OffDescription END
				FROM dbo.Vehicle v
				INNER JOIN dbo.VehicleSensor vs7 ON v.VehicleIntId = vs7.VehicleIntId AND vs7.SensorId = 7 AND vs7.Enabled = 1
				INNER JOIN dbo.DigitalSensorType dst7 ON vs7.DigitalSensorTypeId = dst7.DigitalSensorTypeId
				WHERE v.VehicleId = @currVehicleId
			END		
			
			IF @currTriggerTypeId IN (9, 10) -- Digitial IO 2 trigger so get Digital IO 2 information (sensor id 8)
			BEGIN
				SELECT  @subDigitalActivity = dst8.Description + ' ' + CASE WHEN @currTriggerTypeId = 9 THEN dst8.OnDescription ELSE dst8.OffDescription END
				FROM dbo.Vehicle v
				INNER JOIN dbo.VehicleSensor vs8 ON v.VehicleIntId = vs8.VehicleIntId AND vs8.SensorId = 8 AND vs8.Enabled = 1
				INNER JOIN dbo.DigitalSensorType dst8 ON vs8.DigitalSensorTypeId = dst8.DigitalSensorTypeId
				WHERE v.VehicleId = @currVehicleId
			END	
			
			IF @currTriggerTypeId IN (11, 12) -- Digitial IO 3 trigger so get Digital IO 3 information (sensor id 9)
			BEGIN
				SELECT  @subDigitalActivity = dst9.Description + ' ' + CASE WHEN @currTriggerTypeId = 11 THEN dst9.OnDescription ELSE dst9.OffDescription END
				FROM dbo.Vehicle v
				INNER JOIN dbo.VehicleSensor vs9 ON v.VehicleIntId = vs9.VehicleIntId AND vs9.SensorId = 9 AND vs9.Enabled = 1
				INNER JOIN dbo.DigitalSensorType dst9 ON vs9.DigitalSensorTypeId = dst9.DigitalSensorTypeId
				WHERE v.VehicleId = @currVehicleId
			END	
			
			IF @currTriggerTypeId IN (13, 14) -- Digitial IO 4 trigger so get Digital IO 4 information (sensor id 10)
			BEGIN
				SELECT  @subDigitalActivity = dst10.Description + ' ' + CASE WHEN @currTriggerTypeId = 13 THEN dst10.OnDescription ELSE dst10.OffDescription END
				FROM dbo.Vehicle v
				INNER JOIN dbo.VehicleSensor vs10 ON v.VehicleIntId = vs10.VehicleIntId AND vs10.SensorId = 10 AND vs10.Enabled = 1
				INNER JOIN dbo.DigitalSensorType dst10 ON vs10.DigitalSensorTypeId = dst10.DigitalSensorTypeId
				WHERE v.VehicleId = @currVehicleId
			END					

			IF @currTriggerTypeId IN (51, 65, 66) -- Lone Worker and escalations
			BEGIN
				-- Parse the DataString to get the LW state and the emergency contact numbers	
				SELECT @subLWState = CASE WHEN Id = 1 THEN Value ELSE @subLWState END,
					   @subLWContacts = CASE WHEN Id = 2 THEN Value ELSE @subLWContacts END,
					   @subLWContacts = CASE WHEN Id = 3 AND Value != '0' THEN @subLWContacts + ' or ' + Value ELSE @subLWContacts END		
				FROM dbo.Split(@currDataString, '|')

				-- Now create url string for acknowledgement - currently restricted to email notifications as cannot identify user by other methods until recipients linked to users
				IF @currType IN (1,2)
				BEGIN	
					SET @emailuserid = NULL -- Initialise	
					SELECT TOP 1 @emailuserid = UserID
					FROM dbo.[User]
					WHERE Email = @currAddress
					IF @emailuserid IS NULL
						SET @emailuserid = @currCreatedBy -- Default to trigger creation user
					SELECT @dbname = Value 
					FROM dbo.DBConfig
					WHERE NameID = 9002
					SET @subLWURL = 'https://' + @dbname +
									 '.l-track.com/LoneWorker.aspx?lwid=' + CAST(@currDataInt AS VARCHAR(8)) +
									 '&uid=' + CAST(@emailuserid AS VARCHAR(100))
				END	
				ELSE
				BEGIN	
					SET @subLWURL = 'URL only available in email or SMS notifications'
				END	
			END 
			ELSE
			BEGIN	
				SET @subLWState = 'N/A'	
				SET @subLWURL = 'N/A'		
			END	

			IF @currType = 9  -- Delivery Notification via SMS so need to get GeofenceId and Name from EventData
			BEGIN
				SELECT @subGeofencename = g.Name
				FROM dbo.Geofence g
				WHERE SiteId = dbo.TrimSiteId(@currDataString)				
			END	
						
			-- Substitution Tokens for body
			SET @currBody = REPLACE(@currBody, '%%registration', CASE WHEN @subRegistration IS NULL THEN 'Unknown' ELSE @subRegistration END)
			SET @currBody = REPLACE(@currBody, '%%drivername', CASE WHEN @subDriverName IS NULL THEN 'Unknown' ELSE @subDriverName END)
			SET @currBody = REPLACE(@currBody, '%%drivernumber', CASE WHEN @subDriverNumber IS NULL THEN 'Unknown' ELSE @subDriverNumber END)
			SET @currBody = REPLACE(@currBody, '%%triggerdate', @subTriggerDate)
			SET @currBody = REPLACE(@currBody, '%%triggertime', @subTriggerTime)
			SET @currBody = REPLACE(@currBody, '%%triggerfulldatetime', @subTriggerDateTime)
			SET @currBody = REPLACE(@currBody, '%%blobdescription', CASE WHEN @currDataString IS NULL THEN 'Unknown' ELSE @currDataString END) 
			SET @currBody = REPLACE(@currBody, '%%location', CASE WHEN @subLocation IS NULL THEN 'Unknown' ELSE @subLocation END)
			SET @currBody = REPLACE(@currBody, '%%geofencename', CASE WHEN @subGeofenceName IS NULL THEN 'Unknown' ELSE @subGeofencename END)
			SET @currBody = REPLACE(@currBody, '%%speed', CASE WHEN @subSpeed IS NULL THEN 'Unknown' ELSE @subSpeed END)
			SET @currBody = REPLACE(@currBody, '%%sensor1name', CASE WHEN @subSensor1Name IS NULL THEN 'Unknown' ELSE @subSensor1Name END)
			SET @currBody = REPLACE(@currBody, '%%sensor2name', CASE WHEN @subSensor2Name IS NULL THEN 'Unknown' ELSE @subSensor2Name END)
			SET @currBody = REPLACE(@currBody, '%%sensor3name', CASE WHEN @subSensor3Name IS NULL THEN 'Unknown' ELSE @subSensor3Name END)
			SET @currBody = REPLACE(@currBody, '%%sensor4name', CASE WHEN @subSensor4Name IS NULL THEN 'Unknown' ELSE @subSensor4Name END)
			SET @currBody = REPLACE(@currBody, '%%sensor1', CASE WHEN @subSensor1 IS NULL THEN 'Unknown' ELSE @subSensor1 END)
			SET @currBody = REPLACE(@currBody, '%%sensor2', CASE WHEN @subSensor2 IS NULL THEN 'Unknown' ELSE @subSensor2 END)
			SET @currBody = REPLACE(@currBody, '%%sensor3', CASE WHEN @subSensor3 IS NULL THEN 'Unknown' ELSE @subSensor3 END)
			SET @currBody = REPLACE(@currBody, '%%sensor4', CASE WHEN @subSensor4 IS NULL THEN 'Unknown' ELSE @subSensor4 END)
			SET @currBody = REPLACE(@currBody, '%%digitalactivity', CASE WHEN @subDigitalActivity IS NULL THEN 'Unknown' ELSE @subDigitalActivity END)
			SET @currBody = REPLACE(@currBody, '%%eventtype', CASE WHEN @subEventType IS NULL THEN 'Unknown' ELSE @subEventType END)
			SET @currBody = REPLACE(@currBody, '%%loneworkerstate', CASE WHEN @subLWState IS NULL THEN 'Unknown' ELSE @subLWState END)
			SET @currBody = REPLACE(@currBody, '%%loneworkerurl', CASE WHEN @subLWURL IS NULL THEN 'Unknown' ELSE @subLWURL END)
			SET @currBody = REPLACE(@currBody, '%%loneworkercontacts', CASE WHEN @subLWContacts IS NULL THEN 'unknown' ELSE @subLWContacts END)
			
			-- Substitution Tokens for header
			SET @currHeader = REPLACE(@currHeader, '%%registration', CASE WHEN @subRegistration IS NULL THEN 'Unknown' ELSE @subRegistration END)
			SET @currHeader = REPLACE(@currHeader, '%%drivername', CASE WHEN @subDriverName IS NULL THEN 'Unknown' ELSE @subDriverName END)
			SET @currHeader = REPLACE(@currHeader, '%%drivernumber', CASE WHEN @subDriverNumber IS NULL THEN 'Unknown' ELSE @subDriverNumber END)
			SET @currHeader = REPLACE(@currHeader, '%%triggerdate', @subTriggerDate)
			SET @currHeader = REPLACE(@currHeader, '%%triggertime', @subTriggerTime)
			SET @currHeader = REPLACE(@currHeader, '%%triggerfulldatetime', @subTriggerDateTime)
			SET @currHeader = REPLACE(@currHeader, '%%blobdescription', CASE WHEN @currDataString IS NULL THEN 'Unknown' ELSE @currDataString END) 
			SET @currHeader = REPLACE(@currHeader, '%%location', CASE WHEN @subLocation IS NULL THEN 'Unknown' ELSE @subLocation END)
			SET @currHeader = REPLACE(@currHeader, '%%geofencename', CASE WHEN @subGeofenceName IS NULL THEN 'Unknown' ELSE @subGeofencename END)
			SET @currHeader = REPLACE(@currHeader, '%%speed', CASE WHEN @subSpeed IS NULL THEN 'Unknown' ELSE @subSpeed END)
			SET @currHeader = REPLACE(@currHeader, '%%sensor1', CASE WHEN @subSensor1 IS NULL THEN 'Unknown' ELSE @subSensor1 END)
			SET @currHeader = REPLACE(@currHeader, '%%sensor2', CASE WHEN @subSensor2 IS NULL THEN 'Unknown' ELSE @subSensor2 END)
			SET @currHeader = REPLACE(@currHeader, '%%sensor3', CASE WHEN @subSensor3 IS NULL THEN 'Unknown' ELSE @subSensor3 END)
			SET @currHeader = REPLACE(@currHeader, '%%sensor4', CASE WHEN @subSensor4 IS NULL THEN 'Unknown' ELSE @subSensor4 END)
			SET @currHeader = REPLACE(@currHeader, '%%sensor1name', CASE WHEN @subSensor1Name IS NULL THEN 'Unknown' ELSE @subSensor1Name END)
			SET @currHeader = REPLACE(@currHeader, '%%sensor2name', CASE WHEN @subSensor2Name IS NULL THEN 'Unknown' ELSE @subSensor2Name END)
			SET @currHeader = REPLACE(@currHeader, '%%sensor3name', CASE WHEN @subSensor3Name IS NULL THEN 'Unknown' ELSE @subSensor3Name END)
			SET @currHeader = REPLACE(@currHeader, '%%sensor4name', CASE WHEN @subSensor4Name IS NULL THEN 'Unknown' ELSE @subSensor4Name END)
			SET @currHeader = REPLACE(@currHeader, '%%digitalactivity', CASE WHEN @subDigitalActivity IS NULL THEN 'Unknown' ELSE @subDigitalActivity END)
			SET @currHeader = REPLACE(@currHeader, '%%eventtype', CASE WHEN @subEventType IS NULL THEN 'Unknown' ELSE @subEventType END)
			SET @currHeader = REPLACE(@currHeader, '%%loneworkerstate', CASE WHEN @subLWState IS NULL THEN 'Unknown' ELSE @subLWState END)
			SET @currHeader = REPLACE(@currHeader, '%%loneworkerurl', CASE WHEN @subLWURL IS NULL THEN 'Unknown' ELSE @subLWURL END)
			SET @currHeader = REPLACE(@currHeader, '%%loneworkercontacts', CASE WHEN @subLWContacts IS NULL THEN 'unknown' ELSE @subLWContacts END)

			-- Perform Notifications based upon Notification Type (Need to capture return code?)
			IF @currType = 1 -- Email Notifications
			BEGIN
				IF @currAddress IS NOT NULL AND @currAddress != ''	
					EXEC @NotificationStatus = proc_TAN_SendHTMLEmail_db @currAddress, @currHeader, @currBody	
			END	
			ELSE
			IF @currType = 2 -- SMS Notifications
			BEGIN	
				IF @currAddress IS NOT NULL AND @currAddress != ''
				BEGIN	
					INSERT INTO dbo.SMS (SMSSourceId, SMSStatusId, TelephoneNumber, SenderId, SMSMessage, ExternalIntId, SMSExternalid, TimeInitiated, TimeCompleted, LastOperation, Archived)
					VALUES  (3, 0, @currAddress, NULL,  @currBody, NULL, NULL, GETUTCDATE(), NULL, GETDATE(), 0)
					--EXEC @NotificationStatus = proc_TAN_SendSMS @currAddress, @currHeader, @currBody	
				END	
			END	
			ELSE
			IF @currType = 3 -- VOIP Notifications
			BEGIN	
				IF @currAddress IS NOT NULL AND @currAddress != ''
				BEGIN	
					--EXEC @NotificationStatus = proc_TAN_SendVOIP @currAddress, @currBody
					INSERT INTO dbo.VOIP_Call (CallSourceId, CallStatusId, TelephoneNumber, PlaybackMessage, LastOperation, Archived)
					VALUES (3, 0, @currAddress, @currBody, GETDATE(), 0)
				END	
			END	
			ELSE
			IF @currType = 4 -- Web Status Notifications
			BEGIN
				SET @currHeader = 'Web Status Change'
				SET @currBody = @subRegistration
				EXEC @NotificationStatus = proc_TAN_WebStatusUpdate @currVehicleId, @currTriggerTypeId
			END	
			ELSE
			IF @currType = 5 -- Delivery Notifications
			BEGIN
				-- Get an ID for DeliveryNotification table to be updated
				SELECT TOP 1 @NotificationId = NotificationID
				FROM dbo.DeliveryNotification d
				INNER JOIN dbo.VehicleLatestState v ON d.VehicleId = v.VehicleID
														AND d.DestinationID = v.CurrentDestination
														AND d.NotificationID = v.CurrentNotificationID
				WHERE d.DestinationId = dbo.TrimSiteId(@currDataString)
					AND d.VehicleId = @currVehicleId

				IF @NotificationId IS NOT NULL	
				BEGIN	  
					-- find the recipient addresses for the geofence by site id
					SELECT DISTINCT @RecipientList = Recipients
					FROM dbo.Geofence g
					INNER JOIN dbo.GroupDetail gdg ON gdg.EntityDataId = g.GeofenceId AND gdg.GroupTypeId = 4
					INNER JOIN dbo.UserGroup ugg ON gdg.GroupId = ugg.GroupId
					INNER JOIN dbo.UserGroup ugv ON ugv.UserId = ugg.UserId
					INNER JOIN dbo.GroupDetail gdv ON gdv.GroupId = ugv.GroupId AND gdv.GroupTypeId = 1
					WHERE SiteId = dbo.TrimSiteId(@currDataString)
						AND gdv.EntityDataId = @CurrVehicleId
					
					INSERT INTO @Recipients SELECT * FROM dbo.Split(@RecipientList, ',')
					-- Loop for each recipient 
					WHILE ((SELECT TOP 1 RecipientAddress FROM @Recipients) IS NOT NULL)
					BEGIN
						SELECT TOP 1 @currAddress = RecipientAddress FROM @Recipients

						IF @currAddress IS NOT NULL AND @currAddress != ''
						BEGIN	
							INSERT INTO dbo.VOIP_Call (CallSourceId, CallStatusId, TelephoneNumber, PlaybackMessage, ExternalIntId, LastOperation, Archived)
							VALUES  (1, 0, @currAddress, @currBody, @NotificationId, GETDATE(), 0)
						END	
						DELETE FROM @Recipients WHERE RecipientAddress = @currAddress
					END
					SET @currHeader = 'Delivery Notification'
					SET @currAddress = @RecipientList -- set so all recipients recorded in NotificationLog
					
					--update the DeliveryNotification table with the event datetime
					UPDATE dbo.DeliveryNotification
					SET TimeGeofenceEntered = @currTriggerDateTime,
						TimeNotificationInitiated = GETUTCDATE()
					WHERE NotificationID = @NotificationId	
				END					
			END
			ELSE
			IF @currType = 6 -- Send Command to Vehicle
				EXEC @NotificationStatus = proc_TAN_SendVehicleCommand @currVehicleId, @currDriverId, @currHeader
			ELSE
			IF @currType = 7 -- Exception (write to exception table)
			BEGIN
				SET @currHeader = 'Exception'
				SET @currBody = @subRegistration
				INSERT INTO dbo.Exception (DriverId, VehicleId, TriggerId, ExceptionTypeId, EventDateTime, Lat, Long, Location, Speed)
				VALUES  (@currDriverId, @currVehicleId, @currTriggerId, @currTriggerTypeId, @currTriggerDateTime, @currLat, @currLong, CASE WHEN @subGeofencename = 'Unknown' THEN @subLocation ELSE @subGeofencename END, @currSpeed)			
			END
			ELSE	
			IF @currType = 9 -- Delivery Notification using SMS
			BEGIN
				-- Get an ID for DeliveryNotification table to be updated
				SELECT TOP 1 @NotificationId = NotificationID
				FROM dbo.DeliveryNotification d
				INNER JOIN dbo.VehicleLatestState v ON d.VehicleId = v.VehicleID
														AND d.DestinationID = v.CurrentDestination
														AND d.NotificationID = v.CurrentNotificationID
				WHERE d.DestinationId = dbo.TrimSiteId(@currDataString)
					AND d.VehicleId = @currVehicleId

				IF @NotificationId IS NOT NULL	
				BEGIN	  
					-- find the recipient addresses for the geofence by site id
					SELECT DISTINCT @RecipientList = Recipients
					FROM dbo.Geofence g
					INNER JOIN dbo.GroupDetail gdg ON gdg.EntityDataId = g.GeofenceId AND gdg.GroupTypeId = 4
					INNER JOIN dbo.UserGroup ugg ON gdg.GroupId = ugg.GroupId
					INNER JOIN dbo.UserGroup ugv ON ugv.UserId = ugg.UserId
					INNER JOIN dbo.GroupDetail gdv ON gdv.GroupId = ugv.GroupId AND gdv.GroupTypeId = 1
					WHERE SiteId = dbo.TrimSiteId(@currDataString)
						AND gdv.EntityDataId = @CurrVehicleId
					
					INSERT INTO @Recipients SELECT * FROM dbo.Split(@RecipientList, ',')
					-- Loop for each recipient 
					WHILE ((SELECT TOP 1 RecipientAddress FROM @Recipients) IS NOT NULL)
					BEGIN
						SELECT TOP 1 @currAddress = RecipientAddress FROM @Recipients

						IF @currAddress IS NOT NULL AND @currAddress != ''
						BEGIN	
							-- Send notification via SMS
							INSERT INTO dbo.SMS (SMSSourceId, SMSStatusId, TelephoneNumber, SenderId, SMSMessage, ExternalIntId, SMSExternalid, TimeInitiated, TimeCompleted, LastOperation, Archived)
							VALUES  (1, 0, @currAddress, NULL,  @currBody, @NotificationId, NULL, GETUTCDATE(), NULL, GETDATE(), 0)
							--EXEC @NotificationStatus = proc_TAN_SendSMS @currAddress, @currHeader, @currBody
						END	
						DELETE FROM @Recipients WHERE RecipientAddress = @currAddress
					END
					SET @currHeader = 'Delivery Notification via SMS'
					SET @currAddress = @RecipientList -- set so all recipients recorded in NotificationLog
					
					--update the DeliveryNotification table with the event datetime
					UPDATE dbo.DeliveryNotification
					SET TimeGeofenceEntered = @currTriggerDateTime,
						TimeNotificationInitiated = GETUTCDATE(),
						CallResult = 'SMS Sent'
					WHERE NotificationID = @NotificationId	
				END					
			END	
			ELSE	
			IF @currType = 10 -- Email directly to driver
			BEGIN	
				SET @currAddress = NULL -- Initialise email address
				-- Now lookup email address for current driver
				SELECT @currAddress = Email
				FROM dbo.Driver
				WHERE DriverId = @currDriverId
				IF @currAddress IS NOT NULL AND @currAddress != '' EXEC @NotificationStatus = proc_TAN_SendHTMLEmail_db @currAddress, @currHeader, @currBody	
			END	
			
			IF @NotificationStatus = 0 -- Notification has been successful
			BEGIN
				-- Update notification date and time on TAN_TriggerEntity table where appropriate
				SELECT @TriggerEntityId = tel.TriggerEntityId
				FROM TAN_TriggerEntityLatest tel
				INNER JOIN TAN_NotificationPending np ON tel.TriggerId = np.TriggerId
				WHERE np.NotificationId = @currNotificationId
				  AND (tel.TriggerEntityId = np.VehicleId OR tel.TriggerEntityId = np.DriverId OR tel.TriggerEntityId = np.GeofenceId)
				IF @TriggerEntityId IS NULL
				BEGIN
					INSERT INTO dbo.TAN_TriggerEntityLatest (TriggerId, TriggerEntityId, LatestTriggerDateTime, LastOperation)
					VALUES  (@currTriggerId, ISNULL(@currVehicleId, ISNULL(@currDriverId, @currGeofenceId)), @currTriggerdateTime, GETDATE())
				END ELSE	
				BEGIN
					UPDATE dbo.TAN_TriggerEntityLatest
					SET LatestTriggerDateTime = getutcdate()
					FROM TAN_TriggerEntityLatest tel
					INNER JOIN TAN_NotificationPending np ON tel.TriggerId = np.TriggerId
					WHERE np.NotificationId = @currNotificationId
					  AND (tel.TriggerEntityId = np.VehicleId OR tel.TriggerEntityId = np.DriverId OR tel.TriggerEntityId = np.GeofenceId)
				END

				-- Write to NotificationLog (Change this to report actual return code from send)
				INSERT INTO TAN_NotificationLog (NotificationId, TriggerId, RecipientAddress, Header, Body, NotificationDateTime, NotificationTypeId)
				VALUES (@currNotificationId, @currTriggerId, @currAddress, @currHeader, @currBody, GETUTCDATE(), @currType)
				
				-- For Lone Worker Triggers also update the LoneWorking table
				IF @currTriggerTypeId = 20 -- Lone Worker
				BEGIN
					UPDATE dbo.LoneWorking
					SET AlarmTriggeredDateTime = GETUTCDATE()
					WHERE DriverId = @currDriverId
					  AND VehicleId = @currVehicleId
					  AND LoneWorkingEnd IS NULL
					  AND AlarmTriggeredDateTime IS NULL
				END
				
			END
			
			-- Mark row as processed
			UPDATE TAN_NotificationPending
			SET ProcessInd = 2
			WHERE NotificationId = @currNotificationId

			-- Get next Notification to Process
			DELETE FROM @Notification
			INSERT INTO @Notification (
								NotificationId, 
								NotificationTypeId,
								TriggerId,
								TriggerTypeId,
								RecipientAddress,
								Header,
								Body,
								VehicleId,
								Registration,
								DriverId,
								DriverName,
								DriverNumber,
								GeofenceId,
								GeofenceName,
								DataString,
								DataInt,
								TriggerDateTime,
								CreatedBy,
								EventId,
								CreationCodeName,
								Lat,
								Long,
								Speed)
			SELECT TOP 1	np.NotificationId,
							nt.NotificationTypeId,
							np.TriggerId,
							t.TriggerTypeId,
							rn.RecipientAddress,
							nt.Header,
							nt.Body,
							v.VehicleId,
							v.Registration,
							d.DriverId,
							d.Surname,
							d.Number,
							g.GeofenceId,
							g.Name,
							np.DataString,
							np.DataInt,
							np.TriggerDateTime,
							t.CreatedBy,
							np.EventId,
							ISNULL(cci.Name, 'Unknown Reason'),
							np.Lat,
							np.Long,
							np.Speed
			FROM TAN_NotificationPending np
			LEFT JOIN TAN_RecipientNotification rn ON np.NotificationTemplateId = rn.NotificationTemplateId
												   AND np.RecipientName = rn.RecipientName
			INNER JOIN TAN_NotificationTemplate nt ON np.NotificationTemplateId = nt.NotificationTemplateId
			LEFT JOIN dbo.Vehicle v ON np.VehicleId = v.VehicleId
			LEFT JOIN dbo.Driver d ON np.DriverId = d.DriverId
			LEFT JOIN dbo.CAM_Incident i ON np.EventId = i.EventId
			LEFT JOIN dbo.CreationCode cci ON cci.CreationCodeId = i.CreationCodeId
			LEFT JOIN dbo.Geofence g ON np.GeofenceId = g.GeofenceId
			INNER JOIN TAN_Trigger t ON np.TriggerId = t.TriggerId
			WHERE np.ProcessInd = 1
			ORDER BY np.TriggerDateTime
		END
		
	-- Clean Up -- comment this section out to build up debugging history
	DELETE	
	FROM dbo.TAN_NotificationPending
	FROM dbo.TAN_NotificationPending np
	INNER JOIN dbo.TAN_Trigger t ON np.TriggerId = t.TriggerId
	WHERE np.ProcessInd = 2
	  AND t.TriggerTypeId NOT IN (22,23,24,25)  -- These notifications are required for geofence delay reporting

	-- Delete temporary table to indicate job has completed
	DROP TABLE #TAN_Notify_Running

END
GO
