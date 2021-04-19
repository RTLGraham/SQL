SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_Report_OutOfHours_Driver]
	@vids	NVARCHAR(MAX) = NULL,
	@dids	NVARCHAR(MAX) = NULL,
	@sdate	DATETIME,
	@edate	DATETIME,
	@uid	UNIQUEIDENTIFIER
AS
	SET NOCOUNT ON;
	
	--DECLARE	@vids	NVARCHAR(MAX),
	--		@dids	NVARCHAR(MAX),
	--		@sdate	DATETIME,
	--		@edate	DATETIME,
	--		@uid	UNIQUEIDENTIFIER

	--SET @vids = NULL--N'89332E92-4B0C-43B4-91E0-057649734C13'
	--SET @dids = N'814B16C8-5F9E-46CA-B949-3FD02C7D6274'--NULL--N'4CE8ACB6-4E5C-4412-9067-195F270EE83E'--NULL--N'1B5600D4-85AE-4A78-B071-2EE555EB3300,843EEAB8-EC94-4923-8327-402B09F64F1F,5E9679AC-1B6F-4700-97E8-53BB46B0BC01,0D572BAC-D832-4D53-A192-7F7C56E1D37B,98E7ECE2-6AA1-41D9-BAA9-8B9CAB5D5FD2,983AEB57-6600-42C3-BA24-8D307F5AD57F,BB3428A6-B8A5-4E7A-A081-99806369285F,071410D1-1B88-40E7-8D81-ADE51D9683E9,26C8A9B2-2EB9-49A1-8C8D-DFBA04C697C3,0071EDE5-3222-4A5F-A00C-EB679C17B6FC,51D84E06-84FB-451C-8A02-F86F0219C39A'
	--SET @sdate = '2019-06-01 00:00'
	--SET @edate = '2019-06-13 23:59'
	--SET @uid = N'FB9B80CE-71DD-4927-AF4A-2E6C8E125D2E'

	DECLARE @lvids NVARCHAR(MAX),
			@ldids NVARCHAR(MAX),
			@lsdate DATETIME,
			@ledate DATETIME,
			@luid UNIQUEIDENTIFIER,
			@distmult FLOAT,
			@fleetNumber VARCHAR(1025),
			@datelistcount INT,
			@diststr VARCHAR(20)
			
	SET @lvids = @vids
	SET @ldids = @dids
	SET @lsdate = @sdate
	SET @ledate = @edate
	SET @luid = @uid
	SET @distmult = Cast(dbo.UserPref(@uid, 202) as float)
    SET @diststr = [dbo].UserPref(@luid, 203)
	SET @fleetNumber = ISNULL([dbo].UserPref(@uid, 379), 'Fleet Number')
	
	IF @lvids = ''
		SET @lvids = NULL

	IF @ldids = ''
		SET @ldids = NULL
		
	DECLARE @s_date DATETIME,
			@e_date DATETIME
			
	SET @s_date = @lsdate
	SET @e_date = @ledate
	SET @lsdate = dbo.TZ_ToUtc(@lsdate, DEFAULT, @luid)
	SET @ledate = dbo.TZ_ToUtc(@ledate, DEFAULT, @luid) 
	
	DECLARE @DateList TABLE
	(
		Id INT,
		Date DATETIME,
		DayInd SMALLINT,
		StartWork DATETIME,
		EndWork DATETIME
	)
	
	INSERT INTO @DateList (Date, DayInd) 
	SELECT	dbo.TZ_GetTime(StartDate, DEFAULT, @luid), 
			DATEPART(dw,dbo.TZ_GetTime(StartDate, DEFAULT, @luid))
	FROM dbo.CreateDependentDateRange(@s_date, @e_date, @luid, 1, 0, 1)

	DECLARE @WorkingHours TABLE -- Working Hours in user timezone (excluding daylight savings)
	(
		CustomerId UNIQUEIDENTIFIER,
		MonStart DATETIME,
		MonEnd DATETIME,
		TueStart DATETIME,
		TueEnd DATETIME,
		WedStart DATETIME,
		WedEnd DATETIME,
		ThuStart DATETIME,
		ThuEnd DATETIME,
		FriStart DATETIME,
		FriEnd DATETIME,
		SatStart DATETIME,
		SatEnd DATETIME,
		SunStart DATETIME,
		SunEnd DATETIME,
		TimezoneId INT
	)
	
	INSERT INTO @WorkingHours (MonStart, MonEnd, TueStart, TueEnd, WedStart, WedEnd, ThuStart, ThuEnd, FriStart, FriEnd, SatStart, SatEnd, SunStart, SunEnd, TimezoneId)
	EXEC dbo.cu_User_GetWorkingHours @luid
	UPDATE @WorkingHours
	SET CustomerId = u.CustomerID
	FROM dbo.[User] u 
	WHERE u.UserID = @luid

	--Now update the start and end working times for each day in user timezone
	UPDATE @DateList
	SET StartWork = CASE DayInd
						WHEN 1 THEN DATEADD(dd,DATEDIFF(dd,SunStart,Date),SunStart)
						WHEN 2 THEN DATEADD(dd,DATEDIFF(dd,MonStart,Date),MonStart)
						WHEN 3 THEN DATEADD(dd,DATEDIFF(dd,TueStart,Date),TueStart)
						WHEN 4 THEN DATEADD(dd,DATEDIFF(dd,WedStart,Date),WedStart)
						WHEN 5 THEN DATEADD(dd,DATEDIFF(dd,ThuStart,Date),ThuStart)
						WHEN 6 THEN DATEADD(dd,DATEDIFF(dd,FriStart,Date),FriStart)
						WHEN 7 THEN DATEADD(dd,DATEDIFF(dd,satStart,Date),SatStart)
					END,
		EndWork = CASE DayInd
						WHEN 1 THEN DATEADD(dd,DATEDIFF(dd,SunEnd,Date),SunEnd)
						WHEN 2 THEN DATEADD(dd,DATEDIFF(dd,MonEnd,Date),MonEnd)
						WHEN 3 THEN DATEADD(dd,DATEDIFF(dd,TueEnd,Date),TueEnd)
						WHEN 4 THEN DATEADD(dd,DATEDIFF(dd,WedEnd,Date),WedEnd)
						WHEN 5 THEN DATEADD(dd,DATEDIFF(dd,ThuEnd,Date),ThuEnd)
						WHEN 6 THEN DATEADD(dd,DATEDIFF(dd,FriEnd,Date),FriEnd)
						WHEN 7 THEN DATEADD(dd,DATEDIFF(dd,satEnd,Date),SatEnd)
					END
	FROM @WorkingHours 

	--Remove any days that are not working days
	DELETE
	FROM @DateList
	WHERE StartWork IS NULL

	--Set the Id column to order the rows prior to calculating non-working periods
	UPDATE @DateList
	SET Id = RowNum
	FROM @DateList dl 
	INNER JOIN (SELECT Date, ROW_NUMBER() OVER (ORDER BY Date) AS RowNum
				FROM @DateList) x ON dl.Date = x.Date AND StartWork IS NOT NULL	
	
	--Now create non-working date ranges from the working times
	DECLARE @OutOfHours TABLE
	(
		StartDateTime DATETIME,
		EndDateTime DATETIME
	)

	--Insert unitial working period
	INSERT INTO @OutOfHours (StartDateTime, EndDateTime)
	SELECT TOP 1 @sdate, StartWork
	FROM @DateList
	ORDER BY Id
	
	--Now insert non-working periods taking end of working day to start of next working day
	INSERT INTO @OutOfHours (StartDateTime, EndDateTime)
	SELECT dl1.EndWork, dl2.StartWork
	FROM @DateList dl1
	INNER JOIN @DateList dl2 ON dl1.Id + 1 = dl2.Id 
	
	--Now insert final non-working period
	INSERT INTO @OutOfHours (StartDateTime, EndDateTime)
	SELECT TOP 1 EndWork, @edate
	FROM @DateList
	ORDER BY Id DESC

	--Finally, in case the selected period was all non-working hours (e.g. a weekend) insert the whole period
	--This is identified by @DateList being empty
	SELECT @datelistcount = COUNT(*) FROM @DateList
	IF @datelistcount = 0
		INSERT INTO @OutOfHours (StartDateTime, EndDateTime)
		VALUES (@s_date, @e_date)

	--Now convert everything in @OutOfHours to UTC prior to comparison to data in database
	UPDATE @OutOfHours
	SET StartDateTime = dbo.TZ_ToUtc(StartDateTime, DEFAULT, @luid), EndDateTime = dbo.TZ_ToUtc(EndDateTime, DEFAULT, @luid)

	SELECT	v.VehicleId, 
			v.Registration, 
			v.FleetNumber,
			@fleetNumber AS FleetNumberText,
			d.DriverId, 
			dbo.FormatDriverNameByUser(d.DriverId, @luid) AS DriverName,
			dbo.TZ_GetTime(dt.StartEventDateTime, DEFAULT, @luid) AS StartDateTime,
			ISNULL([dbo].[GetGeofenceNameFromLongLat] (dt.StartLat, dt.StartLong, @luid, [dbo].GetAddressFromLongLat(dt.StartLat, dt.StartLong)), '') AS StartLocation,
			dbo.TZ_GetTime(dt.EndEventDateTime, DEFAULT, @luid) AS EndDateTime,
			ISNULL([dbo].[GetGeofenceNameFromLongLat] (dt.EndLat, dt.EndLong, @luid, [dbo].GetAddressFromLongLat(dt.EndLat, dt.EndLong)), '') AS EndLocation,
			dt.StartLat, dt.StartLong,
			dt.EndLat, dt.EndLong,
			@s_date AS CreationDateTime,
			@e_date AS ClosureDateTime,
			dbo.GetUserWorkingHoursString(dt.StartEventDateTime, @luid) AS WorkingHoursString,
			dt.TripDistance * @distmult AS TripDistance,
			@diststr AS DistanceString
	FROM dbo.DriverTrip dt
	INNER JOIN @OutOfHours oo ON dt.StartEventDateTime BETWEEN oo.StartDateTime AND oo.EndDateTime 
								OR dt.EndEventDateTime BETWEEN oo.StartDateTime AND oo.EndDateTime 
	INNER JOIN dbo.Driver d ON dt.DriverIntId = d.DriverIntId
	INNER JOIN dbo.Vehicle v ON dt.VehicleIntId = v.VehicleIntId
	LEFT JOIN dbo.OutOfHoursWorking oohw ON oohw.DriverIntId = d.DriverIntId AND dt.StartEventDateTime BETWEEN oohw.StartDateTime AND oohw.EndDateTime AND dt.EndEventDateTime BETWEEN oohw.StartDateTime AND oohw.EndDateTime
	WHERE 
	  d.DriverId IN (SELECT VALUE FROM dbo.Split(@ldids,','))
	  AND dt.StartEventDateTime BETWEEN @lsdate AND @ledate
	  AND dt.EndEventDateTime BETWEEN @lsdate AND @ledate
	  AND dt.EndEventDateTime > dt.StartEventDateTime
	  AND oohw.OutOfHoursWorkingId IS NULL -- used to exclude official out of hours working
	ORDER BY dt.StartEventDateTime, Registration



GO
