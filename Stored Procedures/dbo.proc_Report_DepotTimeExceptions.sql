SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_Report_DepotTimeExceptions]
	@uid      UNIQUEIDENTIFIER,
    @gids     NVARCHAR(MAX),
    @dids     NVARCHAR(MAX),
    @sdate    DATETIME,
    @edate    DATETIME
AS
	SET NOCOUNT ON;
	
	--DECLARE	@uid      UNIQUEIDENTIFIER,
	--		@gids     NVARCHAR(MAX),
	--		@dids     NVARCHAR(MAX),
	--		@sdate    DATETIME,
	--		@edate    DATETIME
	
				
	--SET @dids = N'BF48CB72-BEC8-475E-A8E3-511D485F15BF,486A43F1-70D9-46CC-A745-542B6A4D77CE,AC4A7F16-ACAF-41E5-B7CB-57C1C3123C20,339C8146-9790-4CFE-B974-5819ECC299C0,5DE385BF-BFCB-4179-90CB-5AEE460B14AD,C5868274-5850-4762-8EA8-5B5B7C1C2B5B,F30F1966-C7B8-4980-BFFE-5B930071D32D,C83D509F-26C0-4ED6-9D12-5C5D9716789D,67B44E7F-6A0E-42E0-9DCF-5DDCA2AF502E,2C1A82DE-6DCB-4D03-BC21-5F65198B9A84,991F0624-E911-4A0A-9E34-632B912A9C38,BD15D85F-F591-4AB5-881A-65E296715D18,24D1F780-C878-4FF0-A6D8-68B5FDA92CBB'
	--SET @gids = N'4CE8ACB6-4E5C-4412-9067-195F270EE83E'--NULL--N'1B5600D4-85AE-4A78-B071-2EE555EB3300,843EEAB8-EC94-4923-8327-402B09F64F1F,5E9679AC-1B6F-4700-97E8-53BB46B0BC01,0D572BAC-D832-4D53-A192-7F7C56E1D37B,98E7ECE2-6AA1-41D9-BAA9-8B9CAB5D5FD2,983AEB57-6600-42C3-BA24-8D307F5AD57F,BB3428A6-B8A5-4E7A-A081-99806369285F,071410D1-1B88-40E7-8D81-ADE51D9683E9,26C8A9B2-2EB9-49A1-8C8D-DFBA04C697C3,0071EDE5-3222-4A5F-A00C-EB679C17B6FC,51D84E06-84FB-451C-8A02-F86F0219C39A'
	--SET @sdate = '2014-07-08 00:00'
	--SET @edate = '2014-07-08 23:59'
	--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
	
		
	DECLARE @s_date DATETIME,
			@e_date DATETIME,
			@Culture NCHAR(5)


			
	SET @s_date = @sdate
	SET @e_date = @edate
	SET @sdate = dbo.TZ_ToUtc(@sdate, DEFAULT, @uid)
	SET @edate = dbo.TZ_ToUtc(@edate, DEFAULT, @uid) 
	
	

	SELECT TOP 1 @Culture = up.Value
	FROM dbo.[User] u
		INNER JOIN dbo.UserPreference up ON up.UserID = u.UserID
	WHERE u.Archived = 0 AND u.UserID = @uid AND up.NameID = 310
	

	-- TODO: convert StartTime and EndTime from UTC to User Time Zone
	SELECT 
		ka.DriverId ,
		(ISNULL(d.Surname, '') + ' ' + ISNULL(d.FirstName,'')) AS DriverName,
		ka.KronosAbsenseTypeId ,
		katt.DisplayName AS KronosAbsenseName,
		ka.Date AS AbsenseStartTime,
		ka.Date AS AbsenseEndTime,
		ka.Duration AS AbsenseDurationSeconds,
		ka.UserId AS AddedById,
		(ISNULL(u.Surname, '') + ' ' + ISNULL(u.FirstName,'')) AS AddedByName,
		ka.Comment
	FROM dbo.KronosAbsense ka
		INNER JOIN dbo.[User] u ON u.UserID = ka.UserId
		INNER JOIN dbo.Driver d ON d.DriverId = ka.DriverId
		INNER JOIN dbo.KronosAbsenseType kat ON kat.KronosAbsenseTypeId = ka.KronosAbsenseTypeId
		INNER JOIN dbo.KronosAbsenseTypeTranslation katt ON katt.KronosAbsenseTypeId = kat.KronosAbsenseTypeId AND ISNULL(katt.LanguageCulture, 'en-GB') = @Culture
	WHERE ka.DriverId IN (SELECT VALUE FROM dbo.Split(@dids, ','))
		AND ka.Date BETWEEN @sdate AND @edate
		AND ka.Archived = 0

GO
