SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_CFG_ReapplyConfig]
(
	@vid UNIQUEIDENTIFIER
)
AS
BEGIN

--	DECLARE @vid UNIQUEIDENTIFIER
--	SET @vid = N'2682E712-C15D-4C12-9C84-84601446E3F6'
	
	DECLARE @commandstring VARCHAR(MAX),
			@command VARCHAR(MAX),
			@commanddesc VARCHAR(MAX),
			@ivhid UNIQUEIDENTIFIER,
			@odo BIGINT,
			@data INT

	DECLARE @ConfigData TABLE
	(
		IVHId UNIQUEIDENTIFIER,
		Command VARCHAR(MAX),
		IndexPos INT,
		KeyValue VARCHAR(MAX),
		CommandDesc VARCHAR(MAX)
	)
	
	DECLARE @email TABLE
	(
		CommandString VARCHAR(MAX),
		CommandDesc VARCHAR(MAX)
	)

	-- Select all the current configs for the vehicle and insert into table variable
	INSERT INTO @ConfigData
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
	INNER JOIN dbo.CFG_Category cat ON com.CategoryId = cat.CategoryId
	INNER JOIN dbo.IVHType it ON com.IVHTypeId = it.IVHTypeId AND i.IVHTypeId = it.IVHTypeId
	LEFT JOIN dbo.CFG_History hpend ON hpend.IVHIntId = i.IVHIntId  AND k.KeyId = hpend.KeyId AND hpend.EndDate IS NULL AND hpend.Status IS NULL
	WHERE v.VehicleId = @vid
	  AND v.Archived = 0
	  AND v.IVHId IS NOT NULL
	  AND kc.IndexPos >= 0 -- only select configs that actually need to be sent to the vehicle (i.e. non negative values)
	  AND ISNULL(com.ExcludeResend, 0) = 0 -- Exclude any commands where we do not want database to be master (e.g. Odometer)

	-- Only continue processing if we have selected data to send 
	SELECT @data = COUNT(*)
	FROM @ConfigData
	IF ISNULL(@data, 0) > 0
	BEGIN
		-- Process each command type in turn using a cursor
		DECLARE CFGCursor CURSOR FAST_FORWARD
		FOR
		SELECT DISTINCT ivhid, Command, CommandDesc
		FROM @ConfigData

		OPEN CFGCursor
		FETCH NEXT FROM CFGCursor INTO @ivhid, @command, @commanddesc	
		WHILE @@FETCH_STATUS = 0
		BEGIN

			-- Initialise the command string to begin with the current command format 
			SET @commandstring = @command

			-- Now append all the parameters for this command
			SELECT @commandstring = COALESCE(@commandstring,'') + KeyValue + ','
			FROM @Configdata
			WHERE Command = @command
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
			SELECT  @ivhid,
					CAST(LEFT(@commandstring,LEN(@commandstring)-1) AS VARBINARY(1024)), -- remove the final comma from the commandstring
					DATEADD(dd, 2, GETUTCDATE()), NULL, GETDATE(), 0, 0
			
			INSERT INTO @email (CommandString, CommandDesc)
			VALUES  (LEFT(@commandstring,LEN(@commandstring)-1), @commanddesc)
			
			FETCH NEXT FROM CFGCursor INTO @ivhid, @command, @commanddesc

		END

		CLOSE CFGCursor
		DEALLOCATE CFGCursor
		
		-- Now send the latest known Odometer Reading (by checking for the Max Odo in the previous 100 events)
		SELECT @odo = MAX(OdoGPS)
		FROM	
			(SELECT TOP 100 OdoGPS
			FROM Event e WITH (NOLOCK)
			INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
			WHERE v.VehicleId = @vid
			  AND e.EventDateTime < GETUTCDATE()
			ORDER BY e.EventDateTime DESC) x

		SELECT @commandstring = it.WriteCommandPrefix + com.CommandRoot + it.WriteCommandSuffix + CAST(ISNULL(@odo,0) AS VARCHAR(12)),
				@commanddesc = com.Description
		FROM dbo.Vehicle v
		INNER JOIN dbo.IVH i ON v.IVHId = i.IVHId
		INNER JOIN dbo.IVHType it ON i.IVHTypeId = it.IVHTypeId
		INNER JOIN dbo.CFG_Command com ON com.IVHTypeId = it.IVHTypeId
		WHERE v.VehicleId = @vid
		  AND com.CommandId = 19 -- RTLB - Odometer Reset

		INSERT INTO dbo.VehicleCommand
				( IVHId,
				  Command,
				  ExpiryDate,
				  AcknowledgedDate,
				  LastOperation,
				  Archived,
				  ProcessInd
				)
		SELECT  @ivhid,
				CAST(@commandstring AS VARBINARY(1024)), 
				DATEADD(dd, 2, GETUTCDATE()), NULL, GETDATE(), 0, 0
		
		INSERT INTO @email (CommandString, CommandDesc)
		VALUES  (@commandstring, @commanddesc)	
		
		-- Finally send a reboot command to ensure all the configs are correctly applied
		SELECT @commandstring = it.WriteCommandPrefix + com.CommandRoot + it.WriteCommandSuffix + '0',
				@commanddesc = com.Description
		FROM dbo.Vehicle v
		INNER JOIN dbo.IVH i ON v.IVHId = i.IVHId
		INNER JOIN dbo.IVHType it ON i.IVHTypeId = it.IVHTypeId
		INNER JOIN dbo.CFG_Command com ON com.IVHTypeId = it.IVHTypeId
		WHERE v.VehicleId = @vid
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
		SELECT  @ivhid,
				CAST(@commandstring AS VARBINARY(1024)), 
				DATEADD(dd, 2, GETUTCDATE()), NULL, GETDATE(), 0, 0
		
		INSERT INTO @email (CommandString, CommandDesc)
		VALUES  (@commandstring, @commanddesc)	
		
		/****************************************************************************************/
		/* Now send an email to notify of the activity                                          */
		/* This section self contained so can be commeneted out / deleted later if not required */
		/****************************************************************************************/
			
	--	DECLARE @subject varchar(200), 
	--			@message varchar(8000),
	--			@email_recipient varchar(max),
	--			@tableattributes VARCHAR(MAX),
	--			@registration NVARCHAR(MAX),
	--			@db_name VARCHAR(MAX),
	--			@count INT

	--	SELECT @count = COUNT(*)
	--	FROM @email
		
	--	IF ISNULL(@count, 0) > 0 -- only send email if there is data to send
	--	BEGIN
				
	--		-- add email addresses for email alerts in the line below, delimited by semicolon'
	--		SET @email_recipient = 'ray@rtlsystems.co.uk;support@rtlsystems.co.uk;'
	----		SET @email_recipient = 'graham@rtlsystems.co.uk;'
			
	--		-- Set email subject
	--		SELECT @db_name = DB_NAME()
	--		SET @subject = 'DSW - Configs re-applied on database ' + @db_name
			
	--		SET @tableattributes = 'border="1" cellpadding="3"'
			
	--		SELECT @registration = Registration
	--		FROM dbo.Vehicle
	--		WHERE VehicleId = @vid
			
	--		-- Set email header
	--		SET @message = '<HTML>' 
	--		SET @message = @message + '<p>Please find below the commands that have been sent to re-apply the configs to the vehicles listed in database ' 
	--								+ @db_name + '.</p>'
	--								+ '<table ' + @tableattributes + '>'
	--								+ '<tr><th>Vehicle Registration</th><th>Command Type</th><th>Command</th></tr>'

	--		-- Process the Vehicle Inserts in a cursor to build the new vehicles table
	--		DECLARE cur CURSOR FAST_FORWARD FORWARD_ONLY FOR
	--			SELECT CommandString, CommandDesc
	--			FROM @email

	--		OPEN cur
	--		FETCH NEXT FROM cur INTO @commandstring, @commanddesc
	--		WHILE @@FETCH_STATUS = 0
	--		BEGIN
				
	--			SET @message = @message + '<tr><td>' + @registration + '</td><td>' 
	--												 + @commanddesc + '</td><td>'
	--												 + @commandstring + '</td></tr>'
													 
	--			FETCH NEXT FROM cur INTO @commandstring, @commanddesc
	--		END
	--		CLOSE cur
	--		DEALLOCATE cur
			
	--		SET @message = @message + '</table>'		
	--		SET @message = @message + '<p>Please take note!.</p>'
	--		SET @message = @message + '<p>RTL Systems Ltd</p>'
	--		SET @message = @message + '</HTML>'

	--		-- Send the email
	--		EXEC msdb.dbo.sp_send_dbmail 
	--			@profile_name = 'Fleetwise General Mail', 
	--			@recipients = @email_recipient,
	--			@subject = @subject,
	--			@body_format = 'HTML',
	--			@body = @message
		
	--	END -- if data available to send email
	END -- there was data to process	
END


GO
