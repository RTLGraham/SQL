SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_RTL_Accelerometer] 
AS
	
	SET NOCOUNT ON;
	
	DECLARE @subject varchar(200), 
			@message varchar(8000),
			@email_recipient varchar(max),
			@tableattributes VARCHAR(MAX),
			
			@Customer NVARCHAR(MAX),
			@Registration NVARCHAR(MAX),
			@Manufacturer NVARCHAR(MAX),
			@MakeModel NVARCHAR(MAX),
			@BodyType NVARCHAR(MAX),
			@Value NVARCHAR(MAX),
			
			@ProblemCount INT
			
	-- add email addresses for email alerts in the line below, delimited by semicolon'
	--SET @email_recipient = 'ray@rtlsystems.co.uk;dmitrijs@rtlsystems.co.uk;steve.rick@rtlsystems.co.uk;support@rtlsystems.co.uk;'
	SET @email_recipient = 'ray@rtlsystems.co.uk;support@rtlsystems.co.uk;'
	
	-- Set email subject
	SET @subject = 'Accelerometer: Nestlé'
	
	SET @tableattributes = 'border="1" cellpadding="3"'


	DECLARE @sdate DATETIME

	SET @sdate = DATEADD(HOUR, -1, GETUTCDATE())

	DECLARE @results TABLE
	(
		CustomerIntId INT,
		CustomerName NVARCHAR(MAX),
		VehicleIntId INT,
		Registration NVARCHAR(MAX),
		Reason NVARCHAR(MAX),
		Value NVARCHAR(MAX),
		Manufacturer NVARCHAR(MAX),
		MakeModel NVARCHAR(MAX),
		BodyType NVARCHAR(MAX),
		Reconfigs INT
	)
	
	INSERT INTO @results
			( CustomerIntId ,
			  CustomerName ,
			  VehicleIntId ,
			  Registration ,
			  Reason,
			  Value,
			  Manufacturer,
			  MakeModel,
			  BodyType,
			  Reconfigs
			)
	SELECT c.CustomerIntId, c.Name AS Customer, v.VehicleIntId, v.Registration, 
		ed.EventDataName AS Reason, ed.EventDataString AS Value, v.BodyManufacturer, v.MakeModel, v.BodyType,
		(	SELECT COUNT(*) 
			FROM dbo.VehicleCommand vc 
			WHERE vc.IVHId = v.IVHId 
				AND CAST(vc.Command AS VARCHAR(1024)) LIKE '%>STCXAT+RTLA=0,0,0%'
				AND vc.LastOperation BETWEEN DATEADD(day, -1, @sdate) AND GETDATE()
		) AS Reconfigs
	FROM dbo.EventData ed WITH (NOLOCK)
		INNER JOIN dbo.Vehicle v ON ed.VehicleIntId = v.VehicleIntId
		INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
		INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
	WHERE 
		ed.EventDateTime BETWEEN @sdate AND GETUTCDATE()
		AND v.Registration NOT LIKE '%UNKNOWN%'
		AND ed.EventDataName = 'CACC'
	ORDER BY c.CustomerIntId, c.Name, v.VehicleIntId, v.Registration
	
	SELECT @ProblemCount = COUNT(*) FROM @results WHERE Reconfigs = 0
		
	IF @ProblemCount > 0
	-- We have updates to report so proceed to create email
	BEGIN
		
		-- Set email header
		SET @message = '<HTML>' 
		SET @message = @message + '<p>Please find below details of vehicles that learned new (potentially incorrect) accelerometer configuration.</p>'
								+ '<table ' + @tableattributes + '>'
								+ '<tr><th>Customer</th><th>Vehicle Registration</th><th>Manufacturer</th><th>Make/Model</th><th>Body Type</th><th>New Position</th>'

		-- Process the Vehicle Inserts in a cursor to build the new vehicles table
		DECLARE cur CURSOR FAST_FORWARD FORWARD_ONLY FOR
			SELECT CustomerName, Registration, ISNULL(Manufacturer, ''), ISNULL(MakeModel,''), ISNULL(BodyType,''), Value
			FROM @results

		OPEN cur
		FETCH NEXT FROM cur INTO @Customer, @Registration, @Manufacturer, @MakeModel, @BodyType, @Value
		WHILE @@FETCH_STATUS = 0
		BEGIN
			
			SET @message = @message + '<tr><td>' + @Customer + '</td><td>' 
												 + @Registration + '</td><td>' 
												 + @Manufacturer + '</td><td>'
												 + @MakeModel + '</td><td>'
												 + @BodyType + '</td><td>'
												 + @Value + '</td>' 
			FETCH NEXT FROM cur INTO @Customer, @Registration, @Manufacturer, @MakeModel, @BodyType, @Value
		END
		CLOSE cur
		DEALLOCATE cur
		
		SET @message = @message + '</table>'		
		SET @message = @message + '<p>Please check the new value and change if it''s wrong.</p>'
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

GO
