SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_ReportDriverTimesheet_Groups]
(
	@dids NVARCHAR(MAX),
	@uid UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME
)
AS

	---- Nestle
	--DECLARE @dids NVARCHAR(MAX),
	--		@uid UNIQUEIDENTIFIER,
	--		@sdate DATETIME,
	--		@edate DATETIME
	--SET @dids = N'AB0B496F-0659-495D-AD3D-EB5274BDC73C'
	--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
	--SET @sdate = '2013-03-15 00:00'
	--SET @edate = '2013-03-20 23:59'

	-- Roadsense
	--DECLARE @dids NVARCHAR(MAX),
	--		@uid UNIQUEIDENTIFIER,
	--		@sdate DATETIME,
	--		@edate DATETIME
	--SET @dids = N'7B67E00F-505A-4B65-A3C2-01666376FB71,569777B4-4187-466D-A287-0297E80F52C7,424A8DFA-E44F-43D2-8FF8-033775F5F317,7FFDAED2-620F-4E2B-94FE-03B97B42FB57,A172C66A-7327-463D-A8D5-04188F66B57C,D4C0664E-DD5A-4719-BC2E-045027FACDFE,5252B5E5-1A9C-4E74-B753-053351F2A6FC,EC75606C-1A01-44A6-B100-065D0AD43181,00759BC4-D288-4E48-96DB-09490324908D,CB6B710E-721C-4722-9242-107665DF825C,38E8E955-83A0-41B3-910C-132A9F6F8A4F,8F76C55C-609F-4599-AD99-15136299F69F,C98A2BCA-76AC-4B1B-B7E9-1636E81A77E9,FD4D5250-BE2F-49AD-9E7A-1712F11E545A,29C46E24-EF42-403F-A073-1AB993CADBD2,A9316095-C13D-465B-9127-21E29A851599,3E15EC75-B2C8-4EC4-A7D3-285E2DA5CFD8,F6F0BCA7-6829-473A-A271-35D9B2330559,9104C910-4839-47F5-B1E9-35E05D689599,98BA475D-F1B2-48D6-940B-360F9D5D878B,99F42811-196B-4F67-B6FE-3633023FD704,CD97D3E6-8D08-47AF-9527-3655D76653A8,7C3EE8F2-6E18-4DC4-91FC-3B70283CAB64,87350405-3BAF-4A9B-BB13-3EF9F9B1E25C,1F787E0A-4EFF-430B-8CB8-4C987DF39305,79524668-8FDA-4260-A3FD-53050DC7E499,E8F03F5F-5DB6-4DEB-922E-550DF5B836CC,9B10F5DF-BF57-4D73-9EFA-578E187362FF,02CCC4CF-EBA7-4255-B226-5A8BFEAE419F,8A47C826-5256-4287-849B-650150EECA86,0D6A191A-1275-457B-9791-742247624763,4B453F41-E349-4775-B355-8223C115057D,3A8555E0-7770-492B-8FA7-875436443152,F135F354-88DC-4409-93A5-88A17296966E,A4236A5A-EDA7-4DE7-91E1-88C4C4C8268A,F5F12C91-45E0-4B60-BD59-8A8385709A32,60643397-8DCA-487A-AA0A-8CC4B6946B68,D81377FE-CF16-487C-AA0B-8EE568D13176,3D89A6AF-0CA1-40CA-9FF1-91B91782899E,D6169C39-4A3E-42B7-95DA-923232CE6168,5218B483-72DC-4D55-A9C5-957F30543D7E,E88B449F-4E8B-48E9-A9DC-95ADDFF1F871,5B094719-646F-4752-8AEE-9ADF58279623,F727F919-6313-4ED6-9655-9B39AEC490D2,E0BAED73-2EDC-4303-A2DA-9C44EA3CD720,665E0363-0052-4AF0-97F2-9E89BCF7E71E,7194382C-6701-4D05-AE72-9ED0A744616F,4A8B9D33-98B7-4FEE-B2EF-A7AA4D049193,A7FC0C74-55B4-4D49-A53D-ACF91DEF55A9,2A3B4AED-D098-48BF-9E83-B1097655238D,2A7929C5-A16E-4017-B109-B27C9ABDB7DA,E0511870-D81F-448B-A1AC-B358D031B4B0,DC3F180F-8796-4B3A-9C3B-B418F37AE0CC,FF7B2038-44DD-4003-9129-B9483F01A4F5,56BC413A-915E-4E2F-9F07-BDB720B52B87,39D1D9BA-5022-4E91-BC11-BE8E7DD85111,463DBB61-A4C5-48EE-8A2A-BEEAB6088BB5,9C33B022-6A56-45B8-97EA-CE4822D3AA63,0713861C-8625-46BA-8CEB-D1EF16CF7CBF,72762B69-6C8C-45D6-9684-D570A3CBBAB3,8E98AFC8-FEB5-4557-A79B-D725C6CCDE24,AB166FB4-5F5D-4942-AF47-D750BF0DEBE1,C373AC98-5B99-47F0-A877-D87799C83964,C4471874-605E-4A28-B2C6-DA020EFD8573,C3E76A3C-5E01-4CC3-99B3-DB7DB54F308E,04A08ACE-C3D1-4BCE-8993-DC842D518433,FD2FA0D1-F547-424E-B5D6-E27C22F70B41,18A73E80-0DB6-48CA-B300-E422A582C5D4,EF8A086E-330E-4168-ABCD-E82849C09136,813E060A-7EA6-42D9-A185-E8C0CE37DF3E,BD7585BD-E277-4ED0-9AE6-E8C2D5394DBD,258C2303-4F9F-4DF1-9E87-ED41017DB667,5A2CA3C9-AB29-4DE5-8249-FA9CDCDC7A53,F8B5E6F0-B8E5-44A9-9CC0-FC2D4D71DDFF,AA7EEF8C-C384-44AC-B974-FC65649A58AE,5A9B7A4E-8E38-4DDE-A81D-FDFB17A1DB0F,D51D0811-AEF1-487D-8E40-FFB916437C99'
	--SET @uid = N'3C29A1A3-95A5-46B6-A416-39AEE33B5D98'
	--SET @sdate = '2015-07-13 00:00'
	--SET @edate = '2015-07-13 23:59'

	DECLARE	@ldids varchar(max),
		@lsdate datetime,
		@ledate datetime,
		@luid uniqueidentifier

	SET @ldids = @dids
	SET @lsdate = @sdate
	SET @ledate = @edate
	SET @luid = @uid



	DECLARE @dintid INT,
			@diststr VARCHAR(20),
			@distmult FLOAT,
			@custid UNIQUEIDENTIFIER
		
	SELECT @diststr = [dbo].UserPref(@luid, 203)
	SELECT @distmult = [dbo].UserPref(@luid, 202)
	SELECT @custid = CustomerID FROM [User] WHERE userID = @luid

	SET @lsdate = dbo.TZ_ToUtc(@lsdate, DEFAULT, @luid)
	SET @ledate = dbo.TZ_ToUtc(@ledate, DEFAULT, @luid)

	--SET @dintid = dbo.GetDriverIntFromId(@did)

	SELECT  d.DriverId,
			dbo.FormatDriverNameByUser(d.DriverId, @luid) AS DriverName,
			v.VehicleId,
			v.Registration,
			tt.StartLat,
			tt.StartLong,
			dbo.GetGeofenceNameFromLongLat (tt.StartLat, tt.StartLong, @luid, .dbo.GetAddressFromLongLat (tt.StartLat, tt.StartLong)) as StartLocation,
			dbo.TZ_GetTime(tt.StartEventDateTime, DEFAULT, @luid) AS StartEventdateTime,
			tt.EndLat,
			tt.EndLong,
			.dbo.GetGeofenceNameFromLongLat (tt.EndLat, tt.EndLong, @luid, dbo.GetAddressFromLongLat (tt.EndLat, tt.EndLong)) as EndLocation,        
			dbo.TZ_GetTime(tt.EndEventDateTime, DEFAULT, @luid) AS EndEventDateTime,
			DATEDIFF(mi, tt.StartEventDateTime, tt.EndEventDateTime) AS TripDuration,
			tt.TripDistance * @distmult AS TripDistance,
			ttPeriod.PeriodShiftTime,
			ttPeriod.PeriodDriveTime,
			ttPeriod.PeriodDistance * @distmult AS PeriodDistance,
			ttPeriod.PeriodStopTime,
			dbo.TZ_GetTime(ttday.StartDateTime, DEFAULT, @luid) AS StartDayTime,
			dbo.TZ_GetTime(ttday.EndDateTime, DEFAULT, @luid) AS EndDayTime,
			ttday.ShiftTime AS DayShiftTime,
			ISNULL(DATEDIFF(mi, ttyesterday.EndDateTime, ttday.StartDateTime),0) AS DayRestTime,
			ttday.DriveTime AS DayDriveTime,
			ttday.Distance * @distmult AS DayDriveDistance,
			ttday.StopTime AS DayStopTime,
			@diststr AS DistanceUnit
	FROM dbo.DriverTrip tt
	INNER JOIN dbo.Driver d ON d.DriverIntId = tt.DriverIntId
	INNER JOIN dbo.Vehicle v ON tt.VehicleIntId = v.VehicleIntId
	INNER JOIN (SELECT	ROW_NUMBER() OVER(ORDER BY CONVERT(CHAR(6),starteventdatetime, 12)) AS DayNum,
					    d.DriverIntId,
						CONVERT(CHAR(6),starteventdatetime, 12) AS ttDay,
						MIN(StartEventDateTime) AS StartDateTime,
						MAX(EndEventDateTime) AS EndDateTime,
						DATEDIFF(mi, MIN(StartEventDateTime), MAX(EndEventDateTime)) AS ShiftTime,
						1440 - DATEDIFF(mi, MIN(StartEventDateTime), MAX(EndEventDateTime)) AS RestTime,
						SUM(DATEDIFF(mi, StartEventDateTime, EndEventDateTime)) AS DriveTime,
						DATEDIFF(mi, MIN(StartEventDateTime), MAX(EndEventDateTime)) - SUM(DATEDIFF(mi, StartEventDateTime, EndEventDateTime)) AS StopTime,
						SUM(CAST(TripDistance AS BIGINT)) AS Distance
				FROM dbo.DriverTrip dt
					INNER JOIN dbo.Driver d ON d.DriverIntId = dt.DriverIntId
				WHERE d.DriverId IN (SELECT Value FROM dbo.Split(@ldids, ','))
					AND StartEventDateTime BETWEEN @lsdate AND @ledate
				GROUP BY CONVERT(CHAR(6),starteventdatetime, 12), d.DriverIntId) ttday ON CONVERT(CHAR(6),tt.starteventdatetime, 12) = ttday.ttDay AND tt.DriverIntId = ttday.DriverIntId

	LEFT JOIN (SELECT	ROW_NUMBER() OVER(ORDER BY CONVERT(CHAR(6),starteventdatetime, 12)) AS DayNum,
						d.DriverIntId,
						MIN(StartEventDateTime) AS StartDateTime,
						MAX(EndEventDateTime) AS EndDateTime
				FROM dbo.DriverTrip dt
					INNER JOIN dbo.Driver d ON d.DriverIntId = dt.DriverIntId
				WHERE d.DriverId IN (SELECT Value FROM dbo.Split(@ldids, ','))
				  AND StartEventDateTime BETWEEN @lsdate AND @ledate
				GROUP BY CONVERT(CHAR(6),starteventdatetime, 12), d.DriverIntId) ttyesterday ON ttday.DayNum = ttyesterday.DayNum + 1 AND ttyesterday.DriverIntId = tt.DriverIntId
									
	LEFT JOIN (SELECT SUM(ShiftTime) AS PeriodShiftTime, SUM(DriveTime) AS PeriodDriveTime, SUM(StopTime) AS PeriodStopTime, SUM(Distance) AS PeriodDistance, DriverIntId
				FROM (SELECT CONVERT(CHAR(6),starteventdatetime, 12) AS ttDay,
						MIN(StartEventDateTime) AS StartDateTime,
						MAX(EndEventDateTime) AS EndDateTime,
						d.DriverIntId,
						DATEDIFF(mi, MIN(StartEventDateTime), MAX(EndEventDateTime)) AS ShiftTime,
						SUM(DATEDIFF(mi, StartEventDateTime, EndEventDateTime)) AS DriveTime,
						DATEDIFF(mi, MIN(StartEventDateTime), MAX(EndEventDateTime)) - SUM(DATEDIFF(mi, StartEventDateTime, EndEventDateTime)) AS StopTime,
						SUM(CAST(TripDistance AS BIGINT)) AS Distance
					  FROM dbo.DriverTrip dt
							INNER JOIN dbo.Driver d ON d.DriverIntId = dt.DriverIntId
					  WHERE d.DriverId IN (SELECT Value FROM dbo.Split(@ldids, ','))
							AND StartEventDateTime BETWEEN @lsdate AND @ledate
					  GROUP BY CONVERT(CHAR(6),starteventdatetime, 12),d.DriverIntId) ttday
				GROUP BY DriverIntId) ttPeriod ON ttPeriod.DriverIntId = tt.DriverIntId
	WHERE d.DriverId IN (SELECT Value FROM dbo.Split(@ldids, ','))
	  AND tt.StartEventDateTime BETWEEN @lsdate AND @ledate
	  AND tt.TripDistance > 0 -- remove trips of zero distance
	ORDER BY d.Surname, d.DriverIntId, tt.StartEventDateTime

GO
