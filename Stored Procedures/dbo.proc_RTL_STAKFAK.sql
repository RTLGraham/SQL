SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_RTL_STAKFAK] 
AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @subject varchar(200), 
			@message varchar(8000),
			@email_recipient varchar(max),
			@tableattributes VARCHAR(MAX),
			
			@Customer NVARCHAR(MAX),
			@Registration NVARCHAR(MAX),
			@VoltageSpikes INT,
			@GPSStalls INT,
			
			@ProblemCount INT
			
	-- add email addresses for email alerts in the line below, delimited by semicolon'
	--SET @email_recipient = 'ray@rtlsystems.co.uk;dmitrijs@rtlsystems.co.uk;steve.rick@rtlsystems.co.uk;support@rtlsystems.co.uk;'
	SET @email_recipient = 'support@rtlsystems.co.uk;'
	
	-- Set email subject
	SET @subject = 'STAK FAK: Nestle'
	
	SET @tableattributes = 'border="1" cellpadding="3"'


	DECLARE @sdate DATETIME

	SET @sdate = DATEADD(HOUR, -1, GETUTCDATE())

	DECLARE @results TABLE
	(
		CustomerIntId INT,
		CustomerName NVARCHAR(MAX),
		VehicleIntId INT,
		Registration NVARCHAR(MAX),
		Reason NVARCHAR(MAX)
	)
	
	DECLARE @triggers TABLE
	(
		CustomerIntId INT,
		CustomerName NVARCHAR(MAX),
		VehicleIntId INT,
		Registration NVARCHAR(MAX),
		VoltageSpikes INT,
		GPSStalls INT
	)

	INSERT INTO @results
			( CustomerIntId ,
			  CustomerName ,
			  VehicleIntId ,
			  Registration ,
			  Reason
			)
	SELECT c.CustomerIntId, c.Name AS Customer, v.VehicleIntId, v.Registration, --'Voltage Spike' AS Reason
		CASE WHEN ed.EventDataName IS NULL 
			THEN 'Voltage Spike'
			ELSE CASE WHEN ed.EventDataString = 'Stalled GPS'
					THEN 'GPS Stall'
					ELSE 'Voltage Spike'
			END 
		END AS Reason
--		COUNT(*) AS VoltageSpikes
	FROM dbo.Event e WITH (INDEX(IX_Event_Vehicle_EventDateTime), NOLOCK)
		LEFT OUTER JOIN dbo.EventData ed ON e.EventId = ed.EventId AND e.VehicleIntId = ed.VehicleIntId AND e.EventDateTime = ed.EventDateTime AND e.CustomerIntId = ed.CustomerIntId
		INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
		INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
		INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
	WHERE 
		e.EventDateTime BETWEEN @sdate AND GETUTCDATE()
		AND v.Registration NOT LIKE '%UNKNOWN%'
		AND cv.Archived = 0
		AND (e.ExternalInputVoltage >= 70 OR (ed.EventDataName = 'ERR' AND ed.EventDataString = 'Stalled GPS'))
	ORDER BY c.CustomerIntId, c.Name, v.VehicleIntId, v.Registration
	
	
	INSERT INTO @triggers
	        ( CustomerIntId ,
	          CustomerName ,
	          VehicleIntId ,
	          Registration ,
	          VoltageSpikes ,
	          GPSStalls
	        )
	SELECT CustomerIntId , CustomerName , VehicleIntId , Registration ,
		SUM(VoltageSpike) AS VoltageSpikes, SUM(GPSStall) AS GPSStalls
	FROM
	(
		SELECT CustomerIntId , CustomerName , VehicleIntId , Registration , 
			CASE WHEN Reason = 'Voltage Spike' THEN 1 ELSE 0 END AS VoltageSpike,
			CASE WHEN Reason = 'GPS Stall' THEN 1 ELSE 0 END AS GPSStall
		FROM @results
	) r
	GROUP BY CustomerIntId , CustomerName , VehicleIntId , Registration
	HAVING (SUM(VoltageSpike) + SUM(GPSStall)) >= 3
	ORDER BY CustomerIntId , CustomerName , VehicleIntId , Registration
	
	SELECT @ProblemCount = COUNT(*) FROM @triggers WHERE VoltageSpikes > 1 OR GPSStalls > 5
		
	IF @ProblemCount > 0
	-- We have updates to report so proceed to create email
	BEGIN
		
		-- Set email header
		SET @message = '<HTML>' 
		SET @message = @message + '<p>Please find below details of vehicles that are suffering from STAK FAK.</p>'
								+ '<table ' + @tableattributes + '>'
								+ '<tr><th>Customer</th><th>Vehicle Registration</th><th>Voltage Spikes</th><th>GPS Stalls</th><th>'

		-- Process the Vehicle Inserts in a cursor to build the new vehicles table
		DECLARE cur CURSOR FAST_FORWARD FORWARD_ONLY FOR
			SELECT CustomerName, Registration, VoltageSpikes, GPSStalls
			FROM @triggers
			WHERE VoltageSpikes > 1 OR GPSStalls > 5
		OPEN cur
		FETCH NEXT FROM cur INTO @Customer, @Registration, @VoltageSpikes, @GPSStalls
		WHILE @@FETCH_STATUS = 0
		BEGIN
			
			SET @message = @message + '<tr><td>' + @Customer + '</td><td>' 
												 + @Registration + '</td><td>' 
												 + CAST(@VoltageSpikes AS NVARCHAR(MAX)) + '</td><td>' 
												 + CAST(@GPSStalls AS NVARCHAR(MAX)) +'</td></tr>'
			FETCH NEXT FROM cur INTO @Customer, @Registration, @VoltageSpikes, @GPSStalls
		END
		CLOSE cur
		DEALLOCATE cur
		
		SET @message = @message + '</table>'		
		SET @message = @message + '<p>Please fix it.</p>'
		SET @message = @message + '<p>RTL Systems Ltd</p>'
		SET @message = @message + '</HTML>'

		-- Send the email
		EXEC msdb.dbo.sp_send_dbmail 
			@profile_name = 'Fleetwise General Mail', 
			@recipients = @email_recipient,
			@subject = @subject,
			@body_format = 'HTML',
			@body = @message
		
	END
END




	
--	UPDATE @results
--	SET r.TotalEvents = v.TotalEvents,
--		r.IgnitionEvents = k.IgnitionEvents,
--		r.IdleEvents = i.IdleEvents,
--		r.UnknownEvents = u.UnknownEvents,
--		r.DriveEvents = d.DriveEvents,
--		r.StalledGPS = s.StalledGPS
--	FROM @results r
--		LEFT OUTER JOIN 
--			(
--				SELECT c.CustomerIntId, c.Name AS Customer, v.VehicleIntId, v.Registration, COUNT(*) AS TotalEvents
--				FROM dbo.Event e WITH (NOLOCK)
--					INNER JOIN @results r ON e.CustomerIntId = r.CustomerIntId AND e.VehicleIntId = r.VehicleIntId
--					INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
--					INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
--					INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
--				WHERE e.EventDateTime BETWEEN @sdate AND GETUTCDATE()
--				GROUP BY c.CustomerIntId, c.Name, v.VehicleIntId, v.Registration
--			) v ON r.CustomerIntId = v.CustomerIntId
--					 AND r.VehicleIntId = v.VehicleIntId
--		LEFT OUTER JOIN 
--			(
--				SELECT c.CustomerIntId, c.Name AS Customer, v.VehicleIntId, v.Registration, COUNT(*) AS IgnitionEvents
--				FROM dbo.Event e WITH (NOLOCK)
--					INNER JOIN dbo.VehicleModeCreationCode vmcc ON e.CreationCodeId = vmcc.CreationCodeId
--					INNER JOIN dbo.VehicleMode vm ON vmcc.VehicleModeId = vm.VehicleModeID
--					INNER JOIN @results r ON e.CustomerIntId = r.CustomerIntId AND e.VehicleIntId = r.VehicleIntId
--					INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
--					INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
--					INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
--				WHERE e.EventDateTime BETWEEN @sdate AND GETUTCDATE()
--					AND vm.Name LIKE '%Key%'
--				GROUP BY c.CustomerIntId, c.Name, v.VehicleIntId, v.Registration
--			) k ON r.CustomerIntId = k.CustomerIntId
--					 AND r.VehicleIntId = k.VehicleIntId
--		LEFT OUTER JOIN 
--			(
--				SELECT c.CustomerIntId, c.Name AS Customer, v.VehicleIntId, v.Registration, COUNT(*) AS IdleEvents
--				FROM dbo.Event e WITH (NOLOCK)
--					INNER JOIN dbo.VehicleModeCreationCode vmcc ON e.CreationCodeId = vmcc.CreationCodeId
--					INNER JOIN dbo.VehicleMode vm ON vmcc.VehicleModeId = vm.VehicleModeID
--					INNER JOIN @results r ON e.CustomerIntId = r.CustomerIntId AND e.VehicleIntId = r.VehicleIntId
--					INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
--					INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
--					INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
--				WHERE e.EventDateTime BETWEEN @sdate AND GETUTCDATE()
--					AND vm.Name = 'Idle'
--				GROUP BY c.CustomerIntId, c.Name, v.VehicleIntId, v.Registration
--			) i ON r.CustomerIntId = i.CustomerIntId
--					 AND r.VehicleIntId = i.VehicleIntId
--		LEFT OUTER JOIN 
--			(
--				SELECT c.CustomerIntId, c.Name AS Customer, v.VehicleIntId, v.Registration, COUNT(*) AS UnknownEvents
--				FROM dbo.Event e WITH (NOLOCK)
--					LEFT OUTER JOIN dbo.VehicleModeCreationCode vmcc ON e.CreationCodeId = vmcc.CreationCodeId
--					LEFT OUTER JOIN dbo.VehicleMode vm ON vmcc.VehicleModeId = vm.VehicleModeID
--					INNER JOIN @results r ON e.CustomerIntId = r.CustomerIntId AND e.VehicleIntId = r.VehicleIntId
--					INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
--					INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
--					INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
--				WHERE e.EventDateTime BETWEEN @sdate AND GETUTCDATE()
--					AND (vm.Name = 'Undefined' OR vm.Name IS NULL)
--				GROUP BY c.CustomerIntId, c.Name, v.VehicleIntId, v.Registration
--			) u ON r.CustomerIntId = u.CustomerIntId
--					 AND r.VehicleIntId = u.VehicleIntId
--		LEFT OUTER JOIN 
--			(
--				SELECT c.CustomerIntId, c.Name AS Customer, v.VehicleIntId, v.Registration, COUNT(*) AS DriveEvents
--				FROM dbo.Event e WITH (NOLOCK)
--					INNER JOIN dbo.VehicleModeCreationCode vmcc ON e.CreationCodeId = vmcc.CreationCodeId
--					INNER JOIN dbo.VehicleMode vm ON vmcc.VehicleModeId = vm.VehicleModeID
--					INNER JOIN @results r ON e.CustomerIntId = r.CustomerIntId AND e.VehicleIntId = r.VehicleIntId
--					INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
--					INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
--					INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
--				WHERE e.EventDateTime BETWEEN @sdate AND GETUTCDATE()
--					AND vm.Name = 'Drive'
--				GROUP BY c.CustomerIntId, c.Name, v.VehicleIntId, v.Registration
--			) d ON r.CustomerIntId = d.CustomerIntId
--					 AND r.VehicleIntId = d.VehicleIntId
--		LEFT OUTER JOIN 
--			(
--				SELECT c.CustomerIntId, c.Name AS CustomerName, v.VehicleIntId, v.Registration, COUNT(*) AS StalledGPS
--				FROM dbo.Event e WITH (NOLOCK)
--					INNER JOIN @results r ON e.CustomerIntId = r.CustomerIntId AND e.VehicleIntId = r.VehicleIntId
--					INNER JOIN dbo.EventData ed WITH (NOLOCK) ON e.VehicleIntId = ed.VehicleIntId AND e.EventId = ed.EventId AND e.CustomerIntId = ed.CustomerIntId
--					INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
--					INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
--					INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
--				WHERE e.EventDateTime BETWEEN @sdate AND GETUTCDATE()
--					AND ed.EventDataName = 'ERR'
--					AND ed.EventDataString = 'Stalled GPS'
--				GROUP BY c.CustomerIntId, c.Name, v.VehicleIntId, v.Registration
--			) s ON r.CustomerIntId = s.CustomerIntId
--					 AND r.VehicleIntId = s.VehicleIntId

GO
