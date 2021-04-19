SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_CFG_ProcessIncomingConfigs] 
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @vehicleIntId INT,
			@EventDataName VARCHAR(30),
			@EventDataString VARCHAR(1024),
			@commandstring VARCHAR(MAX),
			@command VARCHAR(MAX),
			@commanddesc VARCHAR(MAX),
			@ivhid UNIQUEIDENTIFIER,
			@odo BIGINT,
			@data INT,
			@curr_ivhId UNIQUEIDENTIFIER

	-- Define a set of Key / Command pairs that will be excluded from the 'database is master' check
	DECLARE @Exclusions TABLE
	(
			CommandId INT,
			KeyId INT
	)

	-- Populate the list of exclusions
	INSERT INTO @Exclusions (CommandId, KeyId) VALUES (7, 192) -- Unused4 on ENGA - used to be Fuel Scaling Factor on ENGA (now on ENGF)
	
	DECLARE @ConfigData TABLE 
	(
			IVHIntId INT,
			KeyId INT,
			KeyValue NVARCHAR(MAX)
	)

	DECLARE @Reapply TABLE
    (
			VehicleId UNIQUEIDENTIFIER,
			CommandId INT
	)

	-- Mark all relevant rows in EDC
	UPDATE EventDataCopy
	SET Archived = 1 
	WHERE EventDataName IN (SELECT DISTINCT EventDataNamePrefix + CommandRoot + EventDatanameSuffix
							FROM dbo.CFG_Command
							INNER JOIN dbo.IVHType ON dbo.CFG_Command.IVHTypeId = dbo.IVHType.IVHTypeId)
	
	DECLARE EDCCursor CURSOR FAST_FORWARD READ_ONLY
	FOR 
		SELECT VehicleIntId, EventDataName, EventDataString
		FROM 
			(SELECT VehicleIntId, EventDataName, EventDataString, ROW_NUMBER() OVER (PARTITION BY VehicleIntId, EventDataName ORDER BY EventDataId DESC) AS RowNum
			FROM dbo.EventDataCopy
			WHERE Archived = 1 
			  AND EventDataName IN (SELECT DISTINCT EventDataNamePrefix + CommandRoot + EventDatanameSuffix
								FROM dbo.CFG_Command
								INNER JOIN dbo.IVHType ON dbo.CFG_Command.IVHTypeId = dbo.IVHType.IVHTypeId)) result
		WHERE Result.RowNum = 1	-- select only the latest update for a particular command for a vehicle					
		
	OPEN EDCCursor
	FETCH NEXT FROM EDCCursor INTO @VehicleIntId, @EventDataName, @EventDataString
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		-- Populate the table for all config data received
		INSERT INTO @ConfigData
				( IVHIntId, KeyId, KeyValue )
		        
		SELECT IVHIntId, KeyId, KeyValue
		FROM dbo.ParseConfigData(@VehicleIntId, @EventDataName, @EventDataString)

		FETCH NEXT FROM EDCCursor INTO @VehicleIntId, @EventDataName, @EventDataString
	END
	CLOSE EDCCursor
	DEALLOCATE EDCCursor	

	-------------------------------------------------------------------------------------------------------------------------------------
	-- Main logic change as of 05/12/18 to make the database the 'master' of the configs - actions below now deprecated 
	-------------------------------------------------------------------------------------------------------------------------------------
	-- These are the steps required (some later steps become true or false as a result of actions taken on earlier steps):
	-- We have a key matching an active key and the value is the same --> should leave this row alone to keep integrity of StartDate
	--																		but instruction is to discontinue old key and insert new key! 
	-- We have a key matching a pending key but the value is different --> mark the pending as failed
	-- We have a key matching a pending value and the value matches --> mark the pending as active 
	-- We have a key matching an active key but the value is different --> discontinue old key 
	-- We have no active matching key --> insert new active key

	--------------------------------------------------------------------------------------------------------------------------------------
	-- The above changed to a simpler approach to make the database the 'master' of the configs
	---------------------------------------------------------------------------------------------------------------------------------------------------
	-- If a key/value arrives from the unit that already matches that stored in the database then do nothing
	-- If a key/value arrives from the unit that does not already exist in the database, then add it
	-- If a key/value arrives from the unit with a different value then re-issue the config from the database back to the unit if ExcludeResend not set
	---------------------------------------------------------------------------------------------------------------------------------------------------

	---- Delete RTLA X, Y, Z relearn key/value pairs from the incoming data so they are not stored in the database
	--DELETE FROM cd
	--FROM @ConfigData cd
	--INNER JOIN dbo.CFG_KeyCommand kc ON kc.KeyId = cd.KeyId
	--INNER JOIN dbo.CFG_Command com ON com.CommandId = kc.CommandId
	--WHERE com.CommandRoot = 'RTLA'
	--  AND cd.KeyValue = '0'

	-- We have a key matching an active key and the value is the same --> discontinue old key and allow new key to be inserted in later step == new process: do nothing - this part no longer required and is commented out
	--UPDATE dbo.CFG_History
	--SET EndDate = GETUTCDATE()
	--FROM @ConfigData cd
	--INNER JOIN dbo.CFG_History h ON cd.IVHIntId = h.IVHIntId AND cd.KeyId = h.KeyId AND cd.KeyValue = h.KeyValue
	--WHERE h.EndDate IS NULL AND h.Status = 1
	
	-- (11/06/19) - Special process for RTLA command to facilitate re-learn function
	-- If the command is RTLA and the unit is reporting 0,0,0 then save this config in the database
	-- by first marking the currently active config as ended
	UPDATE dbo.CFG_History
	SET EndDate = GETUTCDATE()
	FROM @ConfigData cd
	INNER JOIN dbo.CFG_KeyCommand kc ON kc.KeyId = cd.KeyId
	INNER JOIN dbo.CFG_Command cc ON cc.CommandId = kc.CommandId
	INNER JOIN dbo.CFG_History h ON cd.IVHIntId = h.IVHIntId AND cd.KeyId = h.KeyId AND h.KeyValue != '0'
	WHERE h.EndDate IS NULL AND h.Status = 1 AND cc.CommandRoot = 'RTLA' AND cd.KeyValue = '0'
	-- then by marking the re-learn config as active
	UPDATE dbo.CFG_History
	SET Status = 1, StartDate = GETUTCDATE()
	FROM @ConfigData cd
	INNER JOIN dbo.CFG_History h ON cd.IVHIntId = h.IVHIntId AND cd.KeyId = h.KeyId AND cd.KeyValue = h.KeyValue
	INNER JOIN dbo.CFG_KeyCommand kc ON kc.KeyId = h.KeyId
	INNER JOIN dbo.CFG_Command cc ON cc.CommandId = kc.CommandId
	WHERE h.EndDate IS NULL AND h.Status IS NULL AND cc.CommandRoot = 'RTLA' AND h.KeyValue = '0'

	-- If the command is RTLA and the database is currently holding 0,0,0 and a relearnt config has now arrived mark the 0,0,0 as discontinued and allow new values to be inserted in later step
	UPDATE h
	SET EndDate = GETUTCDATE()
	FROM @ConfigData cd
	INNER JOIN dbo.CFG_History h ON cd.IVHIntId = h.IVHIntId AND cd.KeyId = h.KeyId AND cd.KeyValue != h.KeyValue
	INNER JOIN dbo.CFG_KeyCommand kc ON kc.KeyId = cd.KeyId
	INNER JOIN dbo.CFG_Command cc ON cc.CommandId = kc.CommandId
	INNER JOIN dbo.Vehicle v ON v.IVHId = dbo.GetIVHIdFromInt(cd.IVHIntId) AND v.Archived = 0
	WHERE h.EndDate IS NULL AND h.Status = 1 AND cc.CommandRoot = 'RTLA' AND h.KeyValue = '0'

	-- Now process all other commands (including any remainung actions for RTLA)
	-- We have a key matching a pending key but the value is different --> re-issue command for pending value
	INSERT INTO @Reapply (VehicleId, CommandId)
	SELECT DISTINCT v.VehicleId, kc.CommandId
	FROM @ConfigData cd
	INNER JOIN dbo.CFG_History h ON cd.IVHIntId = h.IVHIntId AND cd.KeyId = h.KeyId AND cd.KeyValue != h.KeyValue
	INNER JOIN dbo.CFG_KeyCommand kc ON kc.KeyId = cd.KeyId
	INNER JOIN dbo.Vehicle v ON v.IVHId = dbo.GetIVHIdFromInt(cd.IVHIntId) AND v.Archived = 0
	LEFT JOIN @Exclusions e ON e.CommandId = kc.CommandId AND e.KeyId = kc.KeyId
	WHERE h.EndDate IS NULL AND h.Status IS NULL AND e.KeyId IS NULL	

	-- We have a key matching a pending value and the value matches --> mark the pending as active 
	UPDATE dbo.CFG_History
	SET Status = 1, StartDate = GETUTCDATE()
	FROM @ConfigData cd
	INNER JOIN dbo.CFG_History h ON cd.IVHIntId = h.IVHIntId AND cd.KeyId = h.KeyId AND cd.KeyValue = h.KeyValue
	INNER JOIN dbo.CFG_KeyCommand kc ON kc.KeyId = h.KeyId
	LEFT JOIN @Exclusions e ON e.CommandId = kc.CommandId AND e.KeyId = kc.KeyId
	WHERE h.EndDate IS NULL AND h.Status IS NULL AND e.KeyId IS NULL	

	-- We have a key matching an active key but the value is different but there is also an active or pending key with a matching value --> discontinue the non-matching key
	UPDATE h
	SET EndDate = GETUTCDATE()
	FROM @ConfigData cd
	INNER JOIN dbo.CFG_History h ON cd.IVHIntId = h.IVHIntId AND cd.KeyId = h.KeyId AND cd.KeyValue != h.KeyValue
	INNER JOIN dbo.Vehicle v ON v.IVHId = dbo.GetIVHIdFromInt(cd.IVHIntId) AND v.Archived = 0
	LEFT JOIN dbo.CFG_History h2 ON cd.IVHIntId = h2.IVHIntId AND cd.KeyId = h2.KeyId AND cd.KeyValue = h2.KeyValue AND ISNULL(h2.Status, 1) = 1 AND h2.EndDate IS NULL	
	WHERE h.EndDate IS NULL AND h.Status = 1
	  AND h2.HistoryId IS NOT NULL	

	-- We have a key matching an active key but the value is different --> generate a command for the database to re-issue the config
	INSERT INTO @Reapply (VehicleId, CommandId)
	SELECT DISTINCT v.VehicleId, kc.CommandId
	FROM @ConfigData cd
	INNER JOIN dbo.CFG_History h ON cd.IVHIntId = h.IVHIntId AND cd.KeyId = h.KeyId AND cd.KeyValue != h.KeyValue
	INNER JOIN dbo.CFG_KeyCommand kc ON kc.KeyId = cd.KeyId
	INNER JOIN dbo.Vehicle v ON v.IVHId = dbo.GetIVHIdFromInt(cd.IVHIntId) AND v.Archived = 0
	LEFT JOIN @Exclusions e ON e.CommandId = kc.CommandId AND e.KeyId = kc.KeyId
	WHERE h.EndDate IS NULL AND h.Status = 1 AND e.KeyId IS NULL	
	
	-- We have no active matching key --> insert new active key 
	INSERT INTO dbo.CFG_History (IVHIntId, KeyId, KeyValue, StartDate, EndDate, Status, LastOperation)
	SELECT cd.IVHIntId, cd.KeyId, cd.KeyValue, GETUTCDATE(), NULL, 1, GETDATE()
	FROM @ConfigData cd
	WHERE NOT EXISTS (SELECT 1
					  FROM dbo.CFG_History h
					  WHERE cd.IVHIntId = h.IVHIntId
					    AND cd.KeyId = h.KeyId
					    AND h.EndDate IS NULL
					    AND h.Status = 1)

	DELETE FROM dbo.EventDataCopy
	WHERE archived = 1 
	  AND EventDataName IN (SELECT DISTINCT EventDataNamePrefix + CommandRoot + EventDatanameSuffix
							FROM dbo.CFG_Command
							INNER JOIN dbo.IVHType ON dbo.CFG_Command.IVHTypeId = dbo.IVHType.IVHTypeId)

	--------------------------------------------------------------------------------------------------------------------
	-- Now re-apply configs for all vehicles listed in the @Reappy table by sending appropriate commands to each vehicle
	-- After all commands for a vehicle have been sent a reboot command is issued to ensure commands are applied
	--------------------------------------------------------------------------------------------------------------------
	
	DECLARE @ConfigReq TABLE
	(
		IVHId UNIQUEIDENTIFIER,
		Command VARCHAR(MAX),
		IndexPos INT,
		KeyValue VARCHAR(MAX),
		CommandDesc VARCHAR(MAX)
	)
	
	-- Select all the current configs for the required unit/command combinations and insert into table variable
	INSERT INTO @ConfigReq
			( IVHId,
			  Command,
			  IndexPos,
			  KeyValue,
			  CommandDesc
			)
	SELECT DISTINCT 
		   i.IVHId, 
		   it.WriteCommandPrefix + com.CommandRoot + it.WriteCommandSuffix,
		   kc.IndexPos, 
		   ISNULL(hpend.KeyValue, hcurr.KeyValue),
		   com.Description 
	FROM dbo.Vehicle v
	INNER JOIN dbo.IVH i ON v.IVHId = i.IVHId
	INNER JOIN dbo.CFG_History hcurr ON i.IVHIntId = hcurr.IVHIntId AND hcurr.EndDate IS NULL AND hcurr.Status = 1
	INNER JOIN dbo.CFG_Key k ON hcurr.KeyId = k.KeyId
	INNER JOIN dbo.CFG_KeyCommand kc ON k.KeyId = kc.KeyId
	INNER JOIN dbo.CFG_Command com ON kc.CommandId = com.CommandId
	INNER JOIN dbo.IVHType it ON com.IVHTypeId = it.IVHTypeId AND i.IVHTypeId = it.IVHTypeId
	LEFT JOIN dbo.CFG_History hpend ON hpend.IVHIntId = i.IVHIntId  AND k.KeyId = hpend.KeyId AND hpend.EndDate IS NULL AND hpend.Status IS NULL
	INNER JOIN @Reapply r ON r.VehicleId = v.VehicleId AND r.CommandId = com.CommandId -- join to the @Reapply table to identify vehicles and commands that require sending
	  AND kc.IndexPos >= 0 -- only select configs that actually need to be sent to the vehicle (i.e. non negative values)
	  AND ISNULL(com.ExcludeResend, 0) = 0 -- Exclude any commands where we do not want database to be master (e.g. Odometer)

	-- Only continue processing if we have selected data to send 
	SELECT @data = COUNT(*)
	FROM @ConfigReq c
	INNER JOIN dbo.IVH i ON i.IVHId = c.IVHId
	WHERE ISNULL(i.IsDev,0) = 0

	IF ISNULL(@data, 0) > 0
	BEGIN
		-- Process each unit and command type in turn using a cursor
		DECLARE CFGCursor CURSOR FAST_FORWARD
		FOR
		SELECT DISTINCT c.IVHId, Command, CommandDesc
		FROM @ConfigReq c
		INNER JOIN dbo.IVH i ON i.IVHId = c.IVHId
		WHERE ISNULL(i.IsDev, 0) = 0
		ORDER BY c.IVHId, Command

		OPEN CFGCursor
		FETCH NEXT FROM CFGCursor INTO @ivhid, @command, @commanddesc	
		SET @curr_ivhId = @ivhid -- Initialise to first unit
		WHILE @@FETCH_STATUS = 0
		BEGIN

			-- Initialise the command string to begin with the current command format 
			SET @commandstring = @command

			-- Now append all the parameters for this command
			SELECT @commandstring = COALESCE(@commandstring,'') + KeyValue + ','
			FROM @ConfigReq
			WHERE Command = @command AND IVHId = @ivhid
			ORDER BY IndexPos

			-- Insert the command into the vehicleCommand table for sending to the vehicle
			INSERT INTO dbo.VehicleCommand
					( IVHId,
					  Command,
					  ExpiryDate,
					  AcknowledgedDate,
					  LastOperation,
					  Archived,
					  ProcessInd
					)
			SELECT  @ivhid, --LEFT(@commandstring,LEN(@commandstring)-1),
					CAST(LEFT(@commandstring,LEN(@commandstring)-1) AS VARBINARY(1024)), -- remove the final comma from the commandstring
					DATEADD(dd, 2, GETUTCDATE()), NULL, GETDATE(), 0, 0
			
			FETCH NEXT FROM CFGCursor INTO @ivhid, @command, @commanddesc

			IF @ivhid != @curr_ivhId OR @@FETCH_STATUS != 0 -- change of unit or we have just processed last unit
			BEGIN	

				-- Send a reboot command to ensure all the configs are correctly applied
				SELECT @commandstring = it.WriteCommandPrefix + com.CommandRoot + it.WriteCommandSuffix + '0',
						@commanddesc = com.Description
				FROM dbo.Vehicle v
				INNER JOIN dbo.IVH i ON v.IVHId = i.IVHId
				INNER JOIN dbo.IVHType it ON i.IVHTypeId = it.IVHTypeId
				INNER JOIN dbo.CFG_Command com ON com.IVHTypeId = it.IVHTypeId
				WHERE i.IVHId = @ivhid
				  AND com.CommandId = 31 -- CTCG - Reboot Command

				INSERT INTO dbo.VehicleCommand
						( IVHId,
						  Command,
						  ExpiryDate,
						  AcknowledgedDate,
						  LastOperation,
						  Archived,
						  ProcessInd
						)
				SELECT  @ivhid, --@commandstring, 
						CAST(@commandstring AS VARBINARY(1024)), 
						DATEADD(dd, 2, GETUTCDATE()), NULL, GETDATE(), 0, 0

			END	

			SET @curr_ivhId = @ivhid

		END

		CLOSE CFGCursor
		DEALLOCATE CFGCursor
			
	END -- there was data to process

END

	


GO
