SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_IVH_ConfirmInstallationWithEngineerFeedback]
(
	@diagid INT,
	
	@Registration NVARCHAR(MAX) = NULL,
	@MakeModel NVARCHAR(100) = NULL,
	@BodyManufacturer NVARCHAR(50) = NULL,
	@BodyType NVARCHAR(50) = NULL,
	@ChassisNumber NVARCHAR(50) = NULL,
	@Odometer FLOAT = NULL,
	@Comment NVARCHAR(MAX) = NULL,

	@jobType INT = 1,
	@jobReference NVARCHAR(250) = NULL
)
AS
	--DECLARE @diagid INT
	--SET @diagid = 1 

	
	DECLARE @present_Registration NVARCHAR(MAX),
			@present_Customer NVARCHAR(MAX),
			@present_Groups NVARCHAR(MAX),
			@present_Tracker NVARCHAR(MAX),
			@present_CameraSerial NVARCHAR(MAX),
			@engineer NVARCHAR(MAX)

	SELECT TOP 1
		@present_Registration = ISNULL(d.Registration, 'n/a'),
		@present_Customer = ISNULL(d.CustomerName, 'n/a'),
		@present_Groups = ISNULL(d.VehicleGroups, 'n/a'),
		@engineer = u.Name + ' (Name: ' + ISNULL(u.FirstName, '') + '; Surname: ' + ISNULL(u.Surname, '') + ')',
		@present_Tracker = ISNULL(d.TrackerNumber, 'n/a'),
		@present_CameraSerial = ISNULL(d.CameraSerial, 'n/a')
	FROM dbo.Diagnostics d
		INNER JOIN NG_RTL2Application_App.dbo.[User] u ON u.UserID = d.UserId
	WHERE d.DiagnosticsId = @diagid

	UPDATE dbo.Diagnostics
	SET CompletedDateTime = GETUTCDATE(),

		Registration = ISNULL(@Registration, Registration),
		MakeModel = ISNULL(@MakeModel, MakeModel),
		BodyManufacturer = ISNULL(@BodyManufacturer, BodyManufacturer),
		BodyType = ISNULL(@BodyType, BodyType),
		ChassisNumber = ISNULL(@ChassisNumber, ChassisNumber),
		Odometer = ISNULL(@Odometer, Odometer),
		Comment = @Comment,

		JobType = @jobType,
		JobReference = @jobReference
	WHERE DiagnosticsId = @diagid

	IF DB_NAME() = 'UK_Roadsense_Data' -- Outside Clinic Correction -- GKP: code amended so no longer does conversion to KM as data is already provided in KM
	BEGIN	
	IF ISNULL(@Odometer, 0) > 0
		BEGIN	
			MERGE dbo.VehicleLatestOdometer AS target
			USING (SELECT VehicleId, CAST(@odometer AS INT) AS Odo FROM Vehicle WHERE Registration = @Registration) AS source	
			ON (target.VehicleId = source.VehicleId)
			WHEN MATCHED THEN
				UPDATE SET OdoGPS = source.Odo
			WHEN NOT MATCHED THEN	
				INSERT (VehicleId, OdoGPS, EventDateTime, LastOperation, Archived)
				VALUES (source.VehicleId, source.Odo, GETUTCDATE(), GETDATE(), 0);
			
			-- If an Odometer Offset is present remove it as it will no longer apply
			DELETE
            FROM dbo.VehicleOdoOffset
			FROM dbo.VehicleOdoOffset voo
			INNER JOIN dbo.Vehicle v ON v.VehicleIntId = voo.VehicleIntId
			WHERE v.Registration = @Registration
			  AND v.Archived = 0
		END	
	END	


	DECLARE @subject varchar(200), 
			@message varchar(8000),
			@email_recipient varchar(MAX)
			
	-- add email addresses for email alerts in the line below, delimited by semicolon'
	
	DECLARE @jobTypeString NVARCHAR(250)
	
	IF @jobType = 1 --'Service Call'
	BEGIN
		SET @email_recipient = 'support@rtlsystems.co.uk;'
		SET @jobTypeString = 'Service Call'
	END
	ELSE BEGIN
		SET @email_recipient = 'installations@rtlsystems.co.uk;'
		SET @jobTypeString = 'New Installation'
	END

	-- Set email subject
	SET @subject = 'New installation commissioned. ID: ' + CAST(@diagid AS VARCHAR(MAX))
	
	-- Set email header
	SET @message = '<HTML>' 
	SET @message = @message + 'Please find below details of commissioned vehicle.'
	SET @message = @message + '<br>'
	SET @message = @message + '<br>Website: Nestle'
	SET @message = @message + '<br>Customer: ' + @present_Customer
	SET @message = @message + '<br>Groups: ' + @present_Groups
	SET @message = @message + '<br>Vehicle: ' + @present_Registration
	SET @message = @message + '<br>Telematics tracker number: ' + @present_Tracker
	SET @message = @message + '<br>Camera serial: ' + ISNULL(@present_CameraSerial, 'n/a')
	SET @message = @message + '<br>'
	SET @message = @message + '<br>Engineer provided the following details:'
	IF @jobType IS NOT NULL AND @jobType != '' BEGIN SET					@message = @message + '<br>Job Type: ' + @jobTypeString END
	IF @jobReference IS NOT NULL AND @jobReference != '' BEGIN SET			@message = @message + '<br>Job Reference: ' + @jobReference END
	IF @Registration IS NOT NULL AND @Registration != '' BEGIN SET			@message = @message + '<br>Registration: ' + @Registration END
	IF @MakeModel IS NOT NULL AND @MakeModel != '' BEGIN SET				@message = @message + '<br>Make/Model: ' + @MakeModel END
	IF @BodyManufacturer IS NOT NULL AND @BodyManufacturer != '' BEGIN SET	@message = @message + '<br>Body manufacturer: ' + @BodyManufacturer END
	IF @BodyType IS NOT NULL AND @BodyType != '' BEGIN SET					@message = @message + '<br>Body type: ' + @BodyType END
	IF @ChassisNumber IS NOT NULL AND @ChassisNumber != '' BEGIN SET		@message = @message + '<br>Chassis number: ' + @ChassisNumber END
	IF @Odometer IS NOT NULL AND @Odometer != 0 BEGIN SET					@message = @message + '<br>Odometer: ' + STR(@Odometer, 25, 0) + ' (meters)' END
	IF @Comment IS NOT NULL AND @Comment != '' BEGIN SET					@message = @message + '<br>Comment: ' + @Comment END
	
	SET @message = @message + '<br>'
	SET @message = @message + '<br>Commissioning id: ' + CAST(@diagid AS VARCHAR(MAX))
	SET @message = @message + '<br>Commissioning date: ' + CAST(GETDATE() AS VARCHAR(MAX))
	SET @message = @message + '<br>Engineer: ' + @engineer
	SET @message = @message + '<br>'
	SET @message = @message + '<br>RTL Systems Ltd'
	SET @message = @message + '</HTML>'
	
	-- Send the email
	EXEC msdb.dbo.sp_send_dbmail 
		@profile_name = 'Fleetwise General Mail', 
		@recipients = @email_recipient,
		@subject = @subject,
		@body_format = 'HTML',
		@body = @message

	-- Send the Telegram message
	DECLARE @object INT,
			@requestBody VARCHAR(8000),
			@responseText Varchar(8000)

	SET @message = '' 
	SET @message = @message + 'Please find below details of commissioned vehicle.'
	SET @message = @message + '\r\n'
	SET @message = @message + '\r\nWebsite: Nestle'
	SET @message = @message + '\r\nCustomer: ' + @present_Customer
	SET @message = @message + '\r\nGroups: ' + @present_Groups
	SET @message = @message + '\r\nVehicle: ' + @present_Registration
	SET @message = @message + '\r\nTelematics tracker number: ' + @present_Tracker
	SET @message = @message + '\r\nCamera serial: ' + ISNULL(@present_CameraSerial, 'n/a')
	SET @message = @message + '\r\n'
	SET @message = @message + '\r\nEngineer provided the following details:'
	IF @jobType IS NOT NULL AND @jobType != '' BEGIN SET					@message = @message + '\r\nJob type: ' + @jobTypeString END
	IF @jobReference IS NOT NULL AND @jobReference != '' BEGIN SET			@message = @message + '\r\nJob Reference: ' + @jobReference END
	IF @Registration IS NOT NULL AND @Registration != '' BEGIN SET			@message = @message + '\r\nRegistration: ' + @Registration END
	IF @MakeModel IS NOT NULL AND @MakeModel != '' BEGIN SET				@message = @message + '\r\nMake/Model: ' + @MakeModel END
	IF @BodyManufacturer IS NOT NULL AND @BodyManufacturer != '' BEGIN SET	@message = @message + '\r\nBody manufacturer: ' + @BodyManufacturer END
	IF @BodyType IS NOT NULL AND @BodyType != '' BEGIN SET					@message = @message + '\r\nBody type: ' + @BodyType END
	IF @ChassisNumber IS NOT NULL AND @ChassisNumber != '' BEGIN SET		@message = @message + '\r\nChassis number: ' + @ChassisNumber END
	IF @Odometer IS NOT NULL AND @Odometer != 0 BEGIN SET					@message = @message + '\r\nOdometer: ' + STR(@Odometer, 25, 0) + ' (meters)' END
	IF @Comment IS NOT NULL AND @Comment != '' BEGIN SET					@message = @message + '\r\nComment: ' + @Comment END
	SET @message = @message + '\r\n'
	SET @message = @message + '\r\nCommissioning id: ' + CAST(@diagid AS VARCHAR(MAX))
	SET @message = @message + '\r\nCommissioning date: ' + CAST(GETDATE() AS VARCHAR(MAX))
	SET @message = @message + '\r\nEngineer: ' + @engineer

	SET @requestBody = '{"chat_id":"-1001278146439", "text":"' + @message + '"}'

	EXEC sp_OACreate 'MSXML2.XMLHTTP', @object OUT;
	EXEC sp_OAMethod @object, 'open', NULL, 'post',
					 'https://api.telegram.org/bot563105446:AAFz7NzYWMthjeyCn0UZhtHRTlqGVm7Wa-M/sendMessage',
					 'false'
	EXEC sp_OAMethod @object, 'setRequestHeader', null, 'Content-Type', 'application/json'
	EXEC sp_OAMethod @object, 'send', null, @requestBody
	EXEC sp_OAMethod @object, 'responseText', @responseText OUTPUT

GO
