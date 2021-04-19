SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_ChangeEventVideoStatus]
(
	@evid BIGINT,
	@uid UNIQUEIDENTIFIER,
	@newStatus INT,
	@comment NVARCHAR(MAX),
	@ccid INT = NULL	
)
AS

/********************************************************************************/
/* This stored procedure is used to change the video coaching status by:        */ 
/* a) cuf_Vehicle_ChangeEventVideoStatus (change applied manually via the UI)   */
/* b) proc_ProcessCameras (where customer does not use an Analyst)              */
/* A newStatus of -1 means update ABC but do not update the coaching status     */
/********************************************************************************/

	DECLARE @oldStatus INT,
			@oldCcid INT,
			@vintid INT,
			@dintid INT,
			@timestamp DATETIME,
			@date DATETIME,
			@umnId UNIQUEIDENTIFIER,
			@customerIntId INT,
			@dbname VARCHAR(50),

			-- temp debugging fields
			@ahcount INT,
			@bhcount INT,
			@chcount INT
		
	-- Get the old status, creation code, vehicle, driver and date to determine what is required for updating ReportingABC		
	SELECT	@oldStatus = CoachingStatusId, @oldCcid = CreationCodeId, @vintid = VehicleIntId, @dintid = DriverIntId, @timestamp = EventDateTime,
			@customerIntId = CustomerIntId
	FROM dbo.CAM_Incident
	WHERE IncidentId = @evid	
	
	IF @ccid IS NULL -- The CCid has NOT been passed in as a parameter, so use the Ccid that was already recorded on the Incident
		SET @ccid = @oldCcid	
	
	IF @newStatus != -1
	BEGIN		
		-- Update the EventVideo with the new status
		UPDATE dbo.CAM_Incident
		SET CoachingStatusId = @newStatus
		WHERE IncidentId = @evid
	END	

	-- Section added here to generate a trigger if the video is changed to 'Coaching Required/Coachable (2)' or 'Positive Recognition (97)'
	IF @newStatus IN (2, 97) AND @oldStatus NOT IN (2, 97)
	BEGIN
		INSERT INTO dbo.TAN_TriggerEvent (TriggerEventId, CreationCodeId, EventId, CustomerIntId, VehicleIntID, DriverIntId, ApplicationId, Long, Lat, Heading, Speed, TriggerDateTime, ProcessInd, LastOperation)
		SELECT NEWID(), 144, i.EventId, i.CustomerIntId, i.VehicleIntId, i.DriverIntId, 9, e.Long, e.Lat, e.Heading, e.Speed, i.EventDateTime, 0, GETDATE()
		FROM dbo.CAM_Incident i 
		INNER JOIN dbo.Event e ON e.EventId = i.EventId
		WHERE i.IncidentId = @evid    

		-- Do we need to do anything for mobile notifications?

	END	

	IF @uid IS NOT NULL	-- Will be NULL if proc called from proc_ProcessCameras so this code not required
	BEGIN
		-- Write a row to the Coaching History to record the change
		INSERT INTO dbo.VideoCoachingHistory (IncidentId, CoachingStatusId, StatusUserId, StatusDateTime, Comments, LastOperation, Archived)
		VALUES  (@evid, @newStatus, @uid, GETUTCDATE(), @comment, GETDATE(), 0)

		-- If the change was made manually to 'For Review' insert a trigger here
		IF @newStatus = 1 -- 'For Review' = selected for potential coaching
		BEGIN
			INSERT INTO dbo.TAN_TriggerEvent (TriggerEventId, CreationCodeId, EventId, CustomerIntId, VehicleIntID, DriverIntId, ApplicationId, Long, Lat, Heading, Speed, TriggerDateTime, ProcessInd, LastOperation)
			SELECT NEWID(), 138, i.EventId, i.CustomerIntId, i.VehicleIntId, i.DriverIntId, 9, e.Long, e.Lat, e.Heading, e.Speed, i.EventDateTime, 0, GETDATE()
			FROM dbo.CAM_Incident i 
			INNER JOIN dbo.Event e ON e.EventId = i.EventId
			WHERE i.IncidentId = @evid
			
			SELECT @umnId = NEWID()
			INSERT INTO dbo.UserMobileNotification( UserMobileNotificationId, CreationCodeId, EventId, CustomerIntId, VehicleIntID, DriverIntId, ApplicationId, Long, Lat, Heading, Speed, TriggerDateTime, ProcessInd, LastOperation)
			SELECT DISTINCT @umnid, 138, i.EventId, i.CustomerIntId, i.VehicleIntId, i.DriverIntId, 9, e.Long, e.Lat, e.Heading, e.Speed, i.EventDateTime, 0, GETDATE()
			FROM dbo.CAM_Incident i
				INNER JOIN dbo.Vehicle veh ON veh.VehicleIntId = i.VehicleIntId
				INNER JOIN dbo.GroupDetail gd ON veh.VehicleId = gd.EntityDataId
				INNER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId
				INNER JOIN dbo.UserGroup ug ON ug.GroupId = g.GroupId
				INNER JOIN dbo.[User] u ON u.UserID = ug.UserId
				INNER JOIN dbo.UserPreference up ON up.UserID = u.UserID
				INNER JOIN dbo.UserMobileToken umt ON umt.UserId = u.UserID
				INNER JOIN dbo.Event e WITH (NOLOCK) ON e.EventId = i.EventId
			WHERE i.IncidentId = @evid
			  AND i.CreationCodeId IN (436,437,438,55)
			  AND up.NameID = 1097 AND up.Archived = 0 AND up.Value = '1' /* Analyst: 1095; Coach: 1097*/
			  AND umt.Archived = 0 --only for vehicles that have users with tokens
		END

		DECLARE @cname NVARCHAR(MAX)
		SELECT @cname = Name FROM dbo.Customer WHERE CustomerIntId = @customerIntId
		IF @cname = 'Air Products' AND NOT (@oldStatus = 0 AND @newStatus = 98)
		BEGIN
			-- Air Products video status change. Not from 'New' to 'Archive' -> need to send the JSON to AP System

			DECLARE @vehicleRegistration NVARCHAR(MAX),
					@vehicleFleetNumber NVARCHAR(MAX),
					@driverGroup NVARCHAR(MAX),
					@driverAPEXID NVARCHAR(MAX),
					@driverName NVARCHAR(MAX),
					@coachAPEXID NVARCHAR(MAX),
					@coachPassword NVARCHAR(MAX),
					@tags NVARCHAR(MAX),
					@prevOrNot NVARCHAR(MAX)
			-- Get Vehicle Data
			SELECT @vehicleFleetNumber = v.FleetNumber, @vehicleRegistration = v.Registration
			FROM dbo.Vehicle v
			WHERE v.VehicleIntId = @vintid
			
			--Get driver data
			SELECT @driverAPEXID = d.EmpNumber, @driverName = dbo.FormatDriverNameByUser(d.DriverId, NULL)
			FROM dbo.Driver d
			WHERE d.DriverIntId = @dintid

			--GET driver group
			SELECT TOP 1 
				@driverGroup = g.GroupName
			FROM dbo.Driver d
				INNER JOIN dbo.CustomerDriver cd ON cd.DriverId = d.DriverId
				INNER JOIN dbo.Customer c ON c.CustomerId = cd.CustomerId
				INNER JOIN dbo.GroupDetail gd ON gd.EntityDataId = d.DriverId
				INNER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId
			WHERE g.GroupTypeId = 2 AND g.IsParameter = 0 AND g.Archived = 0
				AND d.DriverIntId = @dintid
				AND (g.GroupName LIKE '[a-zA-Z] [a-zA-Z][a-zA-Z] [0-9][0-9][0-9][0-9] %' OR g.GroupName LIKE '[a-zA-Z][a-zA-Z] [a-zA-Z][a-zA-Z] [0-9][0-9][0-9][0-9] %')
			ORDER BY g.LastModified ASC 
			
			-- GET coach
			SELECT TOP 1 @coachAPEXID = u.Name, @coachPassword = u.[Password]
			FROM dbo.TAN_Trigger t
				INNER JOIN dbo.TAN_TriggerEntity te ON te.TriggerId = t.TriggerId
				INNER JOIN dbo.Vehicle v ON te.TriggerEntityId = v.VehicleId
				INNER JOIN dbo.TAN_NotificationTemplate nt ON nt.TriggerId = t.TriggerId AND nt.Archived = 0 AND nt.Disabled = 0
				INNER JOIN dbo.TAN_RecipientNotification rn ON rn.NotificationTemplateId = nt.NotificationTemplateId AND rn.Archived = 0
				INNER JOIN dbo.[User] u ON rn.RecipientAddress = u.Email AND u.Name NOT IN ('COONEYSCopy')
				INNER JOIN dbo.TAN_TriggerType tt ON tt.TriggerTypeId = t.TriggerTypeId
				INNER JOIN dbo.Customer c ON c.CustomerId = t.CustomerId
			WHERE c.CustomerIntId = 58
				AND t.TriggerTypeId = 48
				AND t.Archived = 0
				AND t.Disabled = 0
				AND v.VehicleIntId = @vintid
				AND (rn.RecipientAddress IS NULL OR rn.RecipientAddress NOT IN ('HALLGI@airproducts.com'))
			
			-- GET tags
			SELECT @tags = COALESCE(@tags + ',', '') + CAST(it.TagId AS NVARCHAR(MAX))
			FROM dbo.CAM_Incident i
				INNER JOIN dbo.CAM_IncidentTag it ON it.IncidentId = i.IncidentId
			WHERE it.Archived = 0 AND it.TagId IN (5,18,22,40,41,42,43,44,45,46,47,48,49,50)
				AND i.IncidentId = @evid
				
			-- GET preventable or nonpreventable tags
			SELECT @prevOrNot = COALESCE(@prevOrNot + ',', '') + CAST(it.TagId AS NVARCHAR(MAX))
			FROM dbo.CAM_Incident i
				INNER JOIN dbo.CAM_IncidentTag it ON it.IncidentId = i.IncidentId
			WHERE it.Archived = 0 AND it.TagId IN (51,52)
				AND i.IncidentId = @evid
				
			INSERT INTO dbo.AirProductsCSCEvent
					( AirProductsCSCEventType, IncidentURL, IncidentURLUser, IncidentURLPassword, IncidentURLWidgetId, EventDateTime, ReviewDateTime, CoachingStatus, DriverGroup, DriverAPEXID, DriverName, VehicleRegistration, VehicleFleetNumber, IncidentType, DefaultCoachAPEXID, Tags, PreventableNonPreventable, ProcessInd, LastOperation, Archived, IncidentId )
			VALUES  ( 1 , -- AirProductsCSCEventType - int
			          N'https://skynet.l-track.com/AirProducts.aspx' , -- IncidentURL - nvarchar(max)
			          ISNULL(@coachAPEXID,'') , -- IncidentURLUser - nvarchar(max)
			          ISNULL(@coachPassword,'') , -- IncidentURLPassword - nvarchar(max)
			          '95' , -- IncidentURLWidgetId - nvarchar(max)
			          @timestamp , -- EventDateTime - datetime
			          GETDATE() , -- ReviewDateTime - datetime
			          @newStatus , -- CoachingStatus - int
			          @driverGroup , -- DriverGroup - nvarchar(max)
			          @driverAPEXID , -- DriverAPEXID - nvarchar(max)
			          @driverName , -- DriverName - nvarchar(max)
			          @vehicleRegistration , -- VehicleRegistration - nvarchar(max)
			          @vehicleFleetNumber , -- VehicleFleetNumber - nvarchar(max)
			          @ccid , -- IncidentType - int
			          ISNULL(@coachAPEXID,'') , -- DefaultCoachAPEXID - nvarchar(max)
			          ISNULL(@tags,'') , -- Tags - nvarchar(max)
			          CAST(ISNULL(@prevOrNot,'0') AS INT) , -- PreventableNonPreventable - int
			          0 , -- ProcessInd - smallint
			          GETDATE() , -- LastOperation - datetime
			          0,  -- Archived - bit,
					  @evid -- Incidentid
			        )
		END
	END	
	ELSE IF @uid IS NULL AND @newStatus = 1 -- 'For Review' was applied automatically
	BEGIN
		SELECT @umnId = NEWID()
		INSERT INTO dbo.UserMobileNotification( UserMobileNotificationId, CreationCodeId, EventId, CustomerIntId, VehicleIntID, DriverIntId, ApplicationId, Long, Lat, Heading, Speed, TriggerDateTime, ProcessInd, LastOperation)
		SELECT DISTINCT @umnId, 138, i.EventId, i.CustomerIntId, i.VehicleIntId, i.DriverIntId, 9, e.Long, e.Lat, e.Heading, e.Speed, i.EventDateTime, 0, GETDATE()
		FROM dbo.CAM_Incident i
			INNER JOIN dbo.Vehicle veh ON veh.VehicleIntId = i.VehicleIntId
			INNER JOIN dbo.GroupDetail gd ON veh.VehicleId = gd.EntityDataId
			INNER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId
			INNER JOIN dbo.UserGroup ug ON ug.GroupId = g.GroupId
			INNER JOIN dbo.[User] u ON u.UserID = ug.UserId
			INNER JOIN dbo.UserPreference up ON up.UserID = u.UserID
			INNER JOIN dbo.UserMobileToken umt ON umt.UserId = u.UserID
			INNER JOIN dbo.Event e WITH (NOLOCK) ON e.EventId = i.EventId
		WHERE i.IncidentId = @evid
			AND i.CreationCodeId IN (436,437,438,55)
			AND up.NameID = 1097 AND up.Archived = 0 AND up.Value = '1' /* Analyst: 1095; Coach: 1097*/
			AND umt.Archived = 0 --only for vehicles that have users with tokens
    END

	-- Convert timestamp to a date
	SET @date = CAST(FLOOR(CAST(@timestamp AS FLOAT)) AS DATETIME)

	--check if there are rows to update
	DECLARE @cnt INT
	SELECT @cnt = COUNT(*)
	FROM dbo.ReportingABC
	WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
	
	IF ISNULL(@cnt,0) = 0
	BEGIN
		INSERT INTO dbo.ReportingABC( VehicleIntId ,DriverIntId ,Acceleration ,Braking ,Cornering ,Date ,AccelerationLow ,BrakingLow ,CorneringLow ,AccelerationHigh ,BrakingHigh ,CorneringHigh)
		VALUES  (@vintid, @dintid, 0, 0, 0, @date, 0, 0, 0, 0, 0, 0)
	END

	-- Now determine any required updates to ReportingABC
	IF @oldStatus = 0 AND @newStatus = 1 
	-- Status from Unknown to Selected
	BEGIN
	
		IF @ccid = 36 UPDATE dbo.ReportingABC SET Braking = ISNULL(Braking, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
		IF @ccid IN (37,458) UPDATE dbo.ReportingABC SET Acceleration = ISNULL(Acceleration, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
		IF @ccid = 38 UPDATE dbo.ReportingABC SET Cornering = ISNULL(Cornering, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
		IF @ccid = 336 UPDATE dbo.ReportingABC SET BrakingLow = ISNULL(BrakingLow, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
		IF @ccid IN (337,457) UPDATE dbo.ReportingABC SET AccelerationLow = ISNULL(AccelerationLow, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
		IF @ccid = 338 UPDATE dbo.ReportingABC SET CorneringLow = ISNULL(CorneringLow, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
		IF @ccid = 436 UPDATE dbo.ReportingABC SET BrakingHigh = ISNULL(BrakingHigh, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
		IF @ccid = 437 UPDATE dbo.ReportingABC SET AccelerationHigh = ISNULL(AccelerationHigh, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
		IF @ccid = 438 UPDATE dbo.ReportingABC SET CorneringHigh = ISNULL(CorneringHigh, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
	END
	
	IF  (@oldStatus = 1 OR @oldStatus = 2 OR @oldStatus = 3 OR @oldStatus = 4) 
	AND (@newStatus = 0 OR @newStatus = 97 OR @newStatus = 98 OR @newStatus = 99) 
	-- Status from variation of required to variation of not required
	-- Modified for workaround so that the count cannot go negative
	BEGIN
		IF @ccid = 36 UPDATE dbo.ReportingABC SET Braking = CASE WHEN Braking > 0 THEN ISNULL(Braking, 0) - 1 ELSE 0 END WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
		IF @ccid IN (37,458) UPDATE dbo.ReportingABC SET Acceleration = CASE WHEN Acceleration > 0 THEN ISNULL(Acceleration, 0) - 1 ELSE 0 END WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
		IF @ccid = 38 UPDATE dbo.ReportingABC SET Cornering = CASE WHEN Cornering > 0 THEN ISNULL(Cornering, 0) - 1 ELSE 0 END WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
		IF @ccid = 336 UPDATE dbo.ReportingABC SET BrakingLow = CASE WHEN BrakingLow > 0 THEN ISNULL(BrakingLow, 0) - 1 ELSE 0 END WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
		IF @ccid IN (337,457) UPDATE dbo.ReportingABC SET AccelerationLow = CASE WHEN AccelerationLow > 0 THEN ISNULL(AccelerationLow, 0) - 1 ELSE 0 END WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
		IF @ccid = 338 UPDATE dbo.ReportingABC SET CorneringLow = CASE WHEN CorneringLow > 0 THEN ISNULL(CorneringLow, 0) - 1 ELSE 0 END WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
		IF @ccid = 436 UPDATE dbo.ReportingABC SET BrakingHigh = CASE WHEN BrakingHigh > 0 THEN ISNULL(BrakingHigh, 0) - 1 ELSE 0 END WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
		IF @ccid = 437 UPDATE dbo.ReportingABC SET AccelerationHigh = CASE WHEN AccelerationHigh > 0 THEN ISNULL(AccelerationHigh, 0) - 1 ELSE 0 END WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
		IF @ccid = 438 UPDATE dbo.ReportingABC SET CorneringHigh = CASE WHEN CorneringHigh > 0 THEN ISNULL(CorneringHigh, 0) - 1 ELSE 0 END WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	

		-- Temporary debugging added to try and determine the cause of negative count values - added 28/3/18
		SELECT @ahcount = AccelerationHigh, @bhcount = BrakingHigh, @chcount = CorneringHigh FROM dbo.ReportingABC WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid
		IF @ahcount < 0 OR @bhcount < 0 OR @chcount < 0
			INSERT INTO dbo.temp_Debug_VideoCount (IncidentId, VehicleIntId, DriverIntId, ReportingDate, UserId, OldCreationCodeId, NewCreationCodeId, OldStatus, NewStatus, Timestamp)
			VALUES  (@evid, @vintid, @dintid, @Date, @uid, @oldCcid, @Ccid, @OldStatus, @newStatus, GETDATE())

	END	
	
	IF  (@oldStatus = 97 OR @oldStatus = 98 OR @oldStatus = 99) 
	AND (@newStatus = 1 OR @newStatus = 2 OR @newStatus = 3 OR @newStatus = 4) 
	-- Status from variation of not required to variation of required
	BEGIN
		IF @ccid = 36 UPDATE dbo.ReportingABC SET Braking = ISNULL(Braking, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
		IF @ccid IN (37,458) UPDATE dbo.ReportingABC SET Acceleration = ISNULL(Acceleration, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
		IF @ccid = 38 UPDATE dbo.ReportingABC SET Cornering = ISNULL(Cornering, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
		IF @ccid = 336 UPDATE dbo.ReportingABC SET BrakingLow = ISNULL(BrakingLow, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
		IF @ccid IN (337,457) UPDATE dbo.ReportingABC SET AccelerationLow = ISNULL(AccelerationLow, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
		IF @ccid = 338 UPDATE dbo.ReportingABC SET CorneringLow = ISNULL(CorneringLow, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
		IF @ccid = 436 UPDATE dbo.ReportingABC SET BrakingHigh = ISNULL(BrakingHigh, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
		IF @ccid = 437 UPDATE dbo.ReportingABC SET AccelerationHigh = ISNULL(AccelerationHigh, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
		IF @ccid = 438 UPDATE dbo.ReportingABC SET CorneringHigh = ISNULL(CorneringHigh, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
	END

	IF  @oldStatus = 1 AND @newStatus = -1 
	-- New high event for customer where no analyst so need to increment
	BEGIN
		IF @ccid = 436 UPDATE dbo.ReportingABC SET BrakingHigh = ISNULL(BrakingHigh, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
		IF @ccid = 437 UPDATE dbo.ReportingABC SET AccelerationHigh = ISNULL(AccelerationHigh, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
		IF @ccid = 438 UPDATE dbo.ReportingABC SET CorneringHigh = ISNULL(CorneringHigh, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
	END

	IF  ((@oldStatus NOT IN (2,3,4,97)) AND (@newStatus IN (2,3,4,97)))
	-- When the video is passed for coaching, save the video
	BEGIN
		EXEC [dbo].[proc_RequestVideoDownload] @evid, @uid
	END



GO
