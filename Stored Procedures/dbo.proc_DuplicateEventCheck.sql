SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_DuplicateEventCheck] 
AS

BEGIN
	DECLARE	@Results TABLE (
		Registration NVARCHAR(30),
		CustomerIntId INT,
		EventDateTime DATETIME,
		SeqNumber INT,
		Number INT)

	DECLARE @count INT,
			@email_recipient VARCHAR(MAX),
			@tableattributes VARCHAR(MAX),
			@subject varchar(200), 
			@message varchar(8000),
			@Registration VARCHAR(30),
			@EventDateTime DATETIME,
			@SeqNumber INT

	SET @email_recipient = 'ray@rtlsystems.co.uk; steve.rick@rtlsystems.co.uk'
--	SET @email_recipient = 'graham@rtlsystems.co.uk'
	SET @subject = 'R Record duplicate sequence numbers'
	SET @tableattributes = 'border="1" cellpadding="3"'

	INSERT INTO @Results (Registration, CustomerIntId, EventDateTime, SeqNumber, Number)
	SELECT v.Registration, e.CustomerIntId, e.EventDateTime, e.SeqNumber, COUNT(*)
	FROM dbo.Event e
	INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
	WHERE e.EventDateTime BETWEEN DATEADD(mm, -1, GETUTCDATE()) AND GETUTCDATE()
	GROUP BY e.EventDateTime, e.CustomerIntId, v.Registration, e.SeqNumber
	HAVING COUNT(*) > 1 AND MAX(e.LastOperation) > DATEADD(dd, -1, GETUTCDATE())

	SET @count = 0
	SELECT @count = COUNT(*) FROM @Results

	IF ISNULL(@count, 0) > 0
	BEGIN
			-- Set email header
			SET @message = '<HTML>' 
			SET @message = @message + '<p>New duplicate R records have been received in the last 24 hours as detailed below.</p>'
			
			SET @message = @message + '<table ' + @tableattributes + '>'
									+ '<tr><th>Registration</th><th>Original Event Date/Time</th><th>Sequence Number</th></tr>'

			-- Process the Vehicle Inserts in a cursor to build the new vehicles table
			DECLARE cur CURSOR FAST_FORWARD FORWARD_ONLY FOR
				SELECT Registration, EventDateTime, SeqNumber
				FROM @Results
				ORDER BY Registration, EventDateTime

			OPEN cur
			FETCH NEXT FROM cur INTO @Registration, @EventDateTime, @SeqNumber
			WHILE @@FETCH_STATUS = 0
			BEGIN

				SET @message = @message + '<tr><td>' + @Registration + '</td><td>' + CONVERT(CHAR(19),@EventDateTime,120) + '</td><td>' + CAST(@SeqNumber AS CHAR(10)) + '</td></tr>'
				FETCH NEXT FROM cur INTO @Registration, @EventDateTime, @SeqNumber
			END
			CLOSE cur
			DEALLOCATE cur
			
			SET @message = @message + '</table></HTML>'

			-- Send the email
			EXEC msdb.dbo.sp_send_dbmail 
			@profile_name = 'Fleetwise General Mail', 
			@recipients = @email_recipient,
			@subject = @subject,
			@body_format = 'HTML',
			@body = @message
	END
END
GO
