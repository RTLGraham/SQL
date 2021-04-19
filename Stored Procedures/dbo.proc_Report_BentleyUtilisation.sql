SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_Report_BentleyUtilisation]
	@vids NVARCHAR(MAX),
	@gids NVARCHAR(MAX),
	@sdate DATETIME,
	@edate DATETIME,
	@uid UNIQUEIDENTIFIER,
	@exclWeekends TINYINT,
	@exclBankHols TINYINT
--	@reportId TINYINT	
AS

--DECLARE @vids NVARCHAR(MAX),
--		@gids NVARCHAR(MAX),
--		@sdate DATETIME,
--		@edate DATETIME,
--		@uid UNIQUEIDENTIFIER,
--		@exclWeekends TINYINT,
--		@exclBankHols TINYINT
--		--@reportId TINYINT

--SET @vids = N'A0393401-3253-4AAF-994A-039B7E8D33AB,AAD630C3-FB84-41BF-A100-41652F33E943,401729E2-8202-4199-9579-183109AE819A,BC34F808-0D3B-4EA5-B642-F349015D3FA9,DD31291F-DCE7-4A83-882D-6D502145ABD8,FCF746C0-318E-457D-AAF8-26B8D0DF4D04,C1336E80-050D-41E5-A231-488DB29CE27B,F61F5B19-F4F9-425D-BF32-AE8AFD2ADF10,AFF44E4B-CECC-4777-97F2-28D5BA6746C3,829891A7-2C5D-4790-B639-F07F87A15EF1,9E08C01C-2E46-4580-B7E1-4DAC9E53F0FE,7A9EF254-1A89-4E1A-B517-4C96888460F5,B151B81B-8613-4F2C-A2D2-9E8526C117E3,722B92C6-8B4D-4B26-921E-77ACE68948F1,52E9C8BC-4F26-45B9-89A2-1406D823A47C,A8489A25-8018-4C8D-9B65-F6EE20280467,AAFD73C1-77BF-4701-A192-60B1290D91E4,B7870283-1003-48A8-AC26-2343E4486B86,03B45574-9791-4CBA-8AC0-FB327BE18C2B,1FB0C460-300B-46C4-B5AA-B0AA5038CFE6,DF9D0BAB-0889-44F2-8B51-FAD443BECE44,18D5BF87-BD1A-4143-8FC5-77E9B579A310,624F122F-C565-4BBF-9AA5-CCB4F42FD0B7,80546983-4FBC-4087-8FD6-619CDDE2C14E,DB110A3D-8F5A-40BC-B1EC-8879A5CE7B47,5843D4A1-612D-4422-AE8C-D4337B32BD38,581D0B97-65CE-4F8F-BAB0-F77A541E2E7F,4111ADD5-BEC0-4EA4-8ED4-FC5B82A86CF4,978B3402-214D-4B2B-B268-6DED326B3685,B4497CC5-520E-43E1-A5C0-2BFA78857944,82F76291-408C-498D-B28C-798DFCA4D1ED,D599C2B8-E9A4-4A14-AEDE-3207945F9C32,D5AAB674-CB4C-4824-B384-DBCDFA77937F,E257DC9E-DBFE-4757-88EC-9CA6EABA0445,7AF6C01F-9D86-47E6-8B5F-B812C2C5E9A6,A493A24D-ECC8-43E5-A60F-99C989320BDD,89372428-6F95-4B8F-9D49-4C4AB90D4778,ACF0A0FB-DF54-4E61-B50A-C28C2649A921,C0C12069-1974-400D-A030-274DF475C270,AE514979-8FE6-4D61-A732-0118D738D319,A8E32067-72B7-4F54-9052-94ADB5D209D5,3C001802-6E99-432F-8C2D-A9480AF1A4BA,7233BFF5-2C45-4D18-A5F6-5CCAAAD57593,B203AE74-4654-4B5B-B750-D5FA21CC0986,3A41A973-91FE-4314-B556-8DBB5AFDAFB4,42710A1B-16AC-439F-A48E-9202229219B6,64BA5503-CD7C-4736-BFE7-FC532DABCFFC,BA737DE6-910C-41EE-ADAB-D77D0DD9F40D,DD400D00-A2E5-4E90-B567-59FD5DE836D0,9E42730A-4A6A-4566-98D2-364D5B1A9B3B,8E42C8A8-F083-4BAB-BC33-2A21109CC291,DE1A2535-05D5-49F8-9DC5-C2BB1022C6A6,883783EA-D568-4F33-AA56-4BFB74E2A125,7CAE6029-28F5-47A9-B5F5-D742D6543DC6,5A381C7A-37C6-4C90-B591-6AA5871E5DC4,9194A793-F17E-41B3-BE22-014C2741AB3C,1D931134-9EEB-4E4A-BFDE-F28C4B42886B,5342EFC5-92D8-45F1-9CCC-D0638D6B6C8C,DC56B36E-A42E-4DA0-875A-83C8C36AB7F3,FDF07500-1F86-43AE-9DD2-08B660127A95,CDD498B3-3473-4E34-AEE8-C489527C27D3,A5D0DB9E-DD66-44D0-8A20-23CCEB679FB6,20807CFE-96BC-44E2-BCFE-8B07276B22E0,7741CF72-3285-48E0-86EA-19261F94E0F3,4C233D14-2061-4E0A-A1EB-A05FC8DC79D6,602950AB-CB63-4EEE-944A-64879EA45EC2,D3AE0EF0-23FB-47F0-B786-36A9C6B34E96,3D1CA627-2CB7-4494-959E-35419BAD1B8F,D08E2C94-5EF5-4D87-971A-1C9A0B5A8762,71F85A03-B450-466C-83FA-B1DEE7938ED6,AC6C33C9-DE42-484B-AFD8-A531A4E3CCB3,49A96197-640E-4173-B3E7-8F2615CF78F9,D4693CBE-AC97-4337-B9FB-6DE60A8F2B64,B1577436-B2B7-4FE9-889A-622B523A077A,59A01E34-1524-4C30-8935-50D3997D0291,D8E30F44-DC16-4FD7-998D-4F37D18E4DEF,6497E6DB-51D5-4C40-9968-0910CF4E298A,5890D35E-1CA2-48B5-B558-9E5E64A62A55,37EF5EA1-B28D-4BD8-8DCB-14554E98B497,1EC75AEE-CE7F-47E2-8ED5-F395DE483B16,4F565C0E-E101-4A1F-97C8-2B46968B9A24,E518A81F-7E8C-4036-AC03-A21C818F886B,F09EACE9-F6C6-428D-A3E7-CDBE0428B1AD,1D9F37D5-5DDB-410C-8FE4-5E3496398907,1AC2F42D-C36F-460B-867B-78767C443208,7E8B04F0-FCFF-409B-A9D0-CF953798985B,C02C4558-3ED4-4BED-A9FF-A9A4968907CC,9DC65BC6-5612-4748-94D3-28B2880F51AE,BEA68FDE-84DB-47E0-8561-F2174322AB0E,1330AE02-C96E-4932-945A-724763FFF5DB,E00F7E03-D3A2-4EBC-A793-C61721333F85,4DCF8BAB-4C2B-45A6-AC58-A6B942919EE5,0D111B88-45D7-4E36-9ADB-04C414873B0A,670F1540-AACC-41C9-ACBC-DB005F8AEBF3,CEFBF55A-61C6-4F5B-952A-35764F46738E,E8F96975-6309-47CE-A5BC-C300C86DC630,CE6E3D32-A31D-4BFC-BFB5-2E47E4BD6D67,5C61EDF6-A5F1-4AD1-A79E-BEF5F20D37B2,13C51A50-665C-41A3-83F9-B046EA3C48AB,CCEE0827-18AB-471E-8B02-243DFCDD9891,A91D9AA8-833A-4176-A0EE-E213C96CC627,85A4BB91-0438-4768-8A46-2FFC87E0A9EA,69DD19B8-4084-4F35-9207-CABA8B639876,FB77E8D8-B4A7-4525-BB4D-8782940CD452,42A73E39-5868-4473-976F-0E3656CB9162,F27E02A9-20F6-4588-AA4D-7FFF0790BB6A,A9279685-6B01-44C9-B8F6-C81D02F22F96,F5DE660F-D51A-43B4-B217-ED390401AF01,A6AC625D-D22D-4933-A460-8E2FA5E14E32,50DCC55C-FB52-4637-864A-A24FB98F8F43,E9B737D8-C384-4D2A-B2E8-E0504CCAD231,D2475BD5-BA55-4345-9F0F-7C136ED83680,B758F3FA-8E84-4323-8F06-909A3D59E693,56F2E2F5-30BD-4B4F-A8C1-81202ABBCAC6,9DEFF201-43E5-42F7-9A41-12A36EAFEAEA,1C560B71-F4BD-4663-9795-ADB7CF270249,0A30A7C1-B669-4034-9EC4-823A0367EBA7,8179F044-4FBD-4737-8194-91B306602237,7A372849-4F88-4CD7-9889-7A88F28C1BFA,424225F4-08E0-4171-8C41-0D844F980B2C,E5991A52-B85F-4837-A1AB-2DCC2CE18EDA,FFE0A7FE-F913-4FAE-9738-8516E7CF9093,E9E6CC26-15FF-4B69-8554-C9593B0D2771'
--SET @gids = N'E845E7D8-0215-42AD-875B-01E33ED42AD3,78E7B165-E613-4AAA-BEFF-1B29E83005A3,DF63F2AA-B9F0-4DA0-A1E2-3088B1E9268B,98FB64F6-8D01-4376-8E58-41E3836433CC,7693068D-B848-4DC2-B286-52E6AB0BECF8,327A6062-8290-48C1-985A-66C1E8494BB6,8DFD1633-0151-4FB4-B53B-CD6D2BD2F0D4,B8E4E666-F6EA-4C3D-B22D-DC7C2B6249F9,FF0AB65A-4FA9-455F-A29E-F39C84C15FC8,A1D96AF2-6DFE-487E-8A3C-F67239AAEFDB'
--SET @sdate = '2018-11-21 00:00'
--SET @edate = '2018-11-21 23:59'
--SET @uid = N'3796EB07-5745-4C29-BE23-89A65FDC27AD'
--SET @exclWeekends = 1
--SET @exclBankHols = 0
----SET @reportId = 3  -- 1=Period, 2=Hour, 3=Shift

DECLARE @vehCount INT
SELECT @vehCount = COUNT(DISTINCT Value) FROM dbo.Split(@vids, ',')

DECLARE @shift_times TABLE (ShiftNum SMALLINT, ShiftStart TIME, ShiftEnd TIME)
INSERT INTO @shift_times (ShiftNum, ShiftStart, ShiftEnd) VALUES (1, '06:30:00', '08:59:59')
INSERT INTO @shift_times (ShiftNum, ShiftStart, ShiftEnd) VALUES (2, '09:00:00', '11:59:59')
INSERT INTO @shift_times (ShiftNum, ShiftStart, ShiftEnd) VALUES (3, '12:00:00', '14:59:59')
INSERT INTO @shift_times (ShiftNum, ShiftStart, ShiftEnd) VALUES (4, '15:00:00', '19:59:59')

DECLARE @days TABLE (StartDate DATETIME, EndDate DATETIME)
INSERT INTO @days
        (StartDate, EndDate)
SELECT  StartDate, EndDate
FROM    dbo.CreateDependentDateRange_UTC(@sdate, @edate, @uid, 1, 0, 1)

DECLARE @shift_dates TABLE (
		ShiftId BIGINT IDENTITY (1,1),
		StartDate DATETIME,
		EndDate DATETIME)
INSERT INTO @shift_dates (StartDate, EndDate)
SELECT d.StartDate + t.ShiftStart, d.StartDate + t.ShiftEnd
FROM @days d
CROSS JOIN @shift_times t
ORDER BY d.StartDate + t.ShiftStart

DECLARE @hour_dates TABLE (
		HourId BIGINT IDENTITY (1,1),
		StartDate DATETIME,
		EndDate DATETIME)
INSERT  INTO @hour_dates (StartDate, EndDate)
SELECT  StartDate, EndDate
FROM    dbo.CreateDependentDateRange_UTC(@sdate, @edate, @uid, 1, 0, 5)

DECLARE @period_dates TABLE (
		PeriodId BIGINT IDENTITY (1,1),
		HourId BIGINT,
		ShiftId BIGINT,
		StartDate DATETIME,
		EndDate DATETIME)
INSERT  INTO @period_dates (HourId, ShiftId, StartDate, EndDate)
SELECT  hd.HourId, sd.ShiftId, pd.StartDate, pd.EndDate
FROM    dbo.CreateDependentDateRange_UTC(@sdate, @edate, @uid, 1, 0, 6) pd
INNER JOIN @hour_dates hd ON pd.StartDate BETWEEN hd.StartDate AND hd.EndDate
INNER JOIN @shift_dates sd ON pd.StartDate BETWEEN sd.StartDate AND sd.EndDate

IF @exclWeekends = 1
BEGIN	
	DELETE 
	FROM @period_dates
	WHERE DATEPART(WEEKDAY, StartDate) IN (1,7)  

	DELETE 
	FROM @shift_dates
	WHERE DATEPART(WEEKDAY, StartDate) IN (1,7)  

	DELETE 
	FROM @hour_dates
	WHERE DATEPART(WEEKDAY, StartDate) IN (1,7)  
END	

DECLARE @vehicle_utilisation TABLE
(
	PeriodTypeId INT,
	VehicleIntId INT,
	GroupId UNIQUEIDENTIFIER,
	PeriodId BIGINT,
	StartDate DATETIME,
	EndDate DATETIME
)


---- Identifies vehicles in 'Eng Workship' during period
--SELECT *
--FROM dbo.VehicleGeofenceHistory vgh
--INNER JOIN dbo.Vehicle v ON v.VehicleIntId = vgh.VehicleIntId
--WHERE v.VehicleId IN (SELECT Value FROM dbo.Split(@vids, ','))
--  AND v.Archived = 0
--  AND v.IVHId IS NOT NULL
--  AND vgh.EntryDateTime <= @edate 
--  AND (vgh.ExitDateTime > @sdate OR vgh.ExitDateTime IS NULL)
--  AND vgh.GeofenceId = N'2EE6E1AD-854B-4146-9AFE-F22E1EB01A42'

--IF @reportId = 1 -- Report by Individual 15 min period
--BEGIN
	INSERT INTO @vehicle_utilisation (PeriodTypeId,VehicleIntId, GroupId, PeriodId, StartDate, EndDate)
	SELECT DISTINCT 1, te.VehicleIntID, gd.GroupId, pd.PeriodId, pd.StartDate, pd.EndDate
	FROM dbo.TripsAndStops te
	INNER JOIN dbo.TripsAndStops ts ON te.PreviousID = ts.TripsAndStopsID
	INNER JOIN dbo.Vehicle v ON v.VehicleIntId = te.VehicleIntId
	INNER JOIN dbo.GroupDetail gd ON v.VehicleId = gd.EntityDataId
	INNER JOIN @period_dates pd ON ts.Timestamp <= pd.EndDate AND te.Timestamp >= pd.StartDate
	WHERE v.VehicleId IN (SELECT Value FROM dbo.Split(@vids, ','))
	  AND v.Archived = 0
	  AND v.IVHId IS NOT NULL
	  AND te.Timestamp BETWEEN @sdate AND @edate
	  AND te.VehicleState = 5
	  AND gd.GroupId IN (SELECT Value FROM dbo.Split(@gids, ','))
	ORDER BY te.VehicleIntID, pd.PeriodId
--END

--IF @reportId = 2 -- Report by hourly period
--BEGIN
	INSERT INTO @vehicle_utilisation (PeriodTypeId, VehicleIntId, GroupId, PeriodId, StartDate, EndDate)
	SELECT DISTINCT 2, te.VehicleIntID, gd.GroupId, pd.HourId, hd.StartDate, hd.EndDate
	FROM dbo.TripsAndStops te
	INNER JOIN dbo.TripsAndStops ts ON te.PreviousID = ts.TripsAndStopsID
	INNER JOIN dbo.Vehicle v ON v.VehicleIntId = te.VehicleIntId
	INNER JOIN dbo.GroupDetail gd ON v.VehicleId = gd.EntityDataId
	INNER JOIN @period_dates pd ON ts.Timestamp <= pd.EndDate AND te.Timestamp >= pd.StartDate
	INNER JOIN @hour_dates hd ON pd.HourId = hd.HourId
	WHERE v.VehicleId IN (SELECT Value FROM dbo.Split(@vids, ','))
	  AND v.Archived = 0
	  AND v.IVHId IS NOT NULL
	  AND te.Timestamp BETWEEN @sdate AND @edate
	  AND te.VehicleState = 5
	  AND gd.GroupId IN (SELECT Value FROM dbo.Split(@gids, ','))
	ORDER BY te.VehicleIntID, pd.HourId
--END

--IF @reportId = 3 -- Report by Shift period
--BEGIN
	INSERT INTO @vehicle_utilisation (PeriodTypeId, VehicleIntId, GroupId, PeriodId, StartDate, EndDate)
	SELECT DISTINCT 3, te.VehicleIntID, gd.GroupId, pd.ShiftId, sd.StartDate, sd.EndDate
	FROM dbo.TripsAndStops te
	INNER JOIN dbo.TripsAndStops ts ON te.PreviousID = ts.TripsAndStopsID
	INNER JOIN dbo.Vehicle v ON v.VehicleIntId = te.VehicleIntId
	INNER JOIN dbo.GroupDetail gd ON v.VehicleId = gd.EntityDataId
	INNER JOIN @period_dates pd ON ts.Timestamp <= pd.EndDate AND te.Timestamp >= pd.StartDate
	INNER JOIN @shift_dates sd ON pd.ShiftId = sd.ShiftId
	WHERE v.VehicleId IN (SELECT Value FROM dbo.Split(@vids, ','))
	  AND v.Archived = 0
	  AND v.IVHId IS NOT NULL
	  AND te.Timestamp BETWEEN @sdate AND @edate
	  AND te.VehicleState = 5
	  AND gd.GroupId IN (SELECT Value FROM dbo.Split(@gids, ','))
	ORDER BY te.VehicleIntID, pd.ShiftId
--END

--SELECT DISTINCT PeriodTypeId, PeriodId, StartDate, EndDate
--FROM @vehicle_utilisation

--SELECT *
--FROM @vehicle_utilisation

DECLARE --@utilCount FLOAT,
		@periodCount FLOAT
--SELECT @utilCount = COUNT(*) FROM @vehicle_utilisation WHERE PeriodTypeId = 3

--IF @reportId = 1
--	SELECT @periodCount = COUNT(*) * @vehCount FROM @period_dates
--IF @reportId = 2
--	SELECT @periodCount = COUNT(*) * @vehCount FROM @hour_dates
--IF @reportId = 3
	SELECT @periodCount = COUNT(*) * @vehCount FROM @shift_dates

--SELECT @utilCount AS 'Utilised Periods', @periodCount AS 'Total Periods', @utilCount / @periodCount AS UtilisationPercent

SELECT g.GroupName, COUNT(*) AS 'Utilised Periods', @periodCount AS 'Total Periods', COUNT(*) / @periodCount AS UtilisationPercent
FROM @vehicle_utilisation u
INNER JOIN dbo.[Group] g ON g.GroupId = u.GroupId
WHERE u.PeriodTypeId = 3
GROUP BY g.GroupName






GO