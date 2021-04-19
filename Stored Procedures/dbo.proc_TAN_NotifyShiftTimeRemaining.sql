SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[proc_TAN_NotifyShiftTimeRemaining]  (@vid UNIQUEIDENTIFIER, @did UNIQUEIDENTIFIER, @entrytime DATETIME, @geoid UNIQUEIDENTIFIER, @uid UNIQUEIDENTIFIER)
AS
--BEGIN

	-- 1. Vehicle Enters Deport Geofence
	-- 2. Determine Driver's Shift Start Time
	-- 3. Calculate time remaining

	--DECLARE @vid UNIQUEIDENTIFIER,
	--		@entrytime DATETIME,
	--		@geoid UNIQUEIDENTIFIER,
	--		@uid UNIQUEIDENTIFIER

	--SET @vid = N'C5868274-5850-4762-8EA8-5B5B7C1C2B5B'
	--SET @entrytime = '2016-08-10 10:00'
	--SET @geoid = N'318D95E3-3ED0-4DBE-ACA3-9283C9BC8D1C'
	--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'

	DECLARE @ShiftLengthMins INT,
			@ShiftMinsRemaining INT,
			@TimeRemaining VARCHAR(8),
			@ExitTime DATETIME,
			@DriverName NVARCHAR(300),
			@tableattributes VARCHAR(MAX)

	SET @ShiftLengthMins = 480

	SELECT TOP 1 @ShiftMinsRemaining = @ShiftLengthMins - DATEDIFF(MINUTE, vgh.ExitDateTime, @entrytime),
				 @DriverName = dbo.FormatDriverNameByUser(d.DriverId, @uid),
				 @ExitTime = vgh.ExitDateTime
	FROM dbo.VehicleGeofenceHistory vgh
	INNER JOIN dbo.Vehicle v ON v.VehicleIntId = vgh.VehicleIntId
	INNER JOIN Driver d ON d.DriverIntId = vgh.ExitDriverIntId
	WHERE v.VehicleId = @vid
	  AND vgh.GeofenceId = @geoid
	  AND vgh.ExitDateTime BETWEEN CAST(FLOOR(CAST(@entrytime AS FLOAT)) AS DATETIME) AND @entrytime
	ORDER BY vgh.ExitDateTime

	SET @TimeRemaining = CAST(FLOOR(@ShiftMinsRemaining / 60) AS VARCHAR(2)) + 'h ' + CAST(@ShiftMinsRemaining - (FLOOR(@ShiftMinsRemaining / 60) * 60) AS VARCHAR(2)) + 'm'

	-- Prepare Email to Send
	DECLARE @Recipients NVARCHAR(4000),
			@Subject NVARCHAR(4000),
			@Body NVARCHAR(MAX)

	SET @Recipients = 'graham@rtlsystems.co.uk;dmitrijs@rtlsystems.co.uk'
	SET @Subject = 'Driver Shift Time Remaining for ' + @DriverName

	-- Set email header
	SET @tableattributes = 'border="1" cellpadding="3"'
	SET @Body = '<HTML>' 
	SET @Body = @Body + '<p>Please find below details of a driver currently returning to the depot.</p>'
							+ '<table ' + @tableattributes + '>'
							+ '<tr><th>Driver</th><th>Exit Time</th><th>Return Time</th><th>Shift Time Remaining</th><th>'
	SET @Body = @Body + '<tr><td>' + @DriverName + '</td><td>' 
											+ CAST(dbo.TZ_GetTime(@ExitTime, DEFAULT, @uid) AS VARCHAR(20)) + '</td><td>' 
											+ CAST(dbo.TZ_GetTime(@entrytime, DEFAULT, @uid) AS VARCHAR(20)) + '</td><td>' 
											+ @TimeRemaining +'</td></tr>'

	SET @Body = @Body + '</table>'		
	SET @Body = @Body + '<p>Please check the Skynet systems for further details.</p>'
	SET @Body = @Body + '<p>RTL Systems Ltd</p>'
	SET @Body = @Body + '</HTML>'

	EXEC dbo.proc_TAN_SendHTMLEmail_db @aRecipient = @Recipients, -- nvarchar(4000)
	    @aSubject = @Subject, -- nvarchar(4000)
	    @aBodyText = @Body -- nvarchar(max)
	

--END	


GO
