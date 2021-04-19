SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_ReportTemperatureStatusAccount]
(
	@gids NVARCHAR(MAX),
	@vids NVARCHAR(MAX),
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER
) 
AS

--DECLARE @gids NVARCHAR(MAX),
--		@vids NVARCHAR(MAX),
--		@sdate datetime,
--		@edate datetime,
--		@uid UNIQUEIDENTIFIER
--		
--SET @gids = N'F0F5ED40-A37B-4718-863D-FECA640FC5CD' -- Lausen
--SET @vids = N'5F3CEA35-DCBE-4120-9301-09FF638BF9DF,46D70EB7-624A-4F2D-92D7-1DB630EE116F,9DFE074E-F8B7-44C0-8BAA-3FB046ED29A2,49482BB6-B7CC-40C1-9F61-48728BF61A8E,F30F1966-C7B8-4980-BFFE-5B930071D32D,991F0624-E911-4A0A-9E34-632B912A9C38,202B4D58-3993-43D1-A8C5-7BC46C7CEFA5,747C1E8B-7F86-4BB3-9AC3-8C4E319272B2,1D3D521A-9CFF-4B73-BC2E-97ADB314A3A2,767A5BB3-0077-4799-AC91-9E88279E99F1,7F0079D1-5D4E-47D8-AFEA-A9835C3A3D00,09504D20-457C-49EC-A6EE-CC7DAA4C4252,28E3452A-A515-45BC-B95F-DED8A0EB1CD8' -- Lausen vehicles
--SET	@sdate = '2012-10-01 00:00'
--SET	@edate = '2012-10-31 23:59'
--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'

DECLARE @tempmult FLOAT,
		@liquidmult FLOAT

SET @tempmult = ISNULL([dbo].[UserPref](@uid, 214),1)
SET @liquidmult = ISNULL([dbo].[UserPref](@uid, 200),1)

SET @sdate = dbo.TZ_ToUtc(@sdate, DEFAULT, @uid)
SET @edate = dbo.TZ_ToUtc(@edate, DEFAULT, @uid)

SELECT  g.GroupName, 
		v.Registration, 
		t.CheckOutReason, 
		dbo.TZ_GetTime(t.CheckOutDateTime,DEFAULT,@uid) AS CheckOutDateTime, 
		uout.Name AS CheckOutUser, 
		uout.Surname AS CheckOutSurname, 
		uout.FirstName AS CheckOutFirstName, 
		dbo.TZ_GetTime(t.CheckInDateTime,DEFAULT,@uid) AS CheckInDateTime, 
		uin.Name AS CheckInUser, 
		uin.Surname AS CheckInSurname, 
		uin.FirstName AS CheckInFirstName,
		dbo.GetScaleConvertAnalogValue(t.AnalogData0, 0, v.VehicleId, @tempmult, @liquidmult) AS Analog0Temp,
		dbo.GetScaleConvertAnalogValue(t.AnalogData1, 1, v.VehicleId, @tempmult, @liquidmult) AS Analog1Temp,
		dbo.GetScaleConvertAnalogValue(t.AnalogData2, 2, v.VehicleId, @tempmult, @liquidmult) AS Analog2Temp,
		dbo.GetScaleConvertAnalogValue(t.AnalogData3, 3, v.VehicleId, @tempmult, @liquidmult) AS Analog3Temp
FROM dbo.TAN_EntityCheckOut t
INNER JOIN dbo.Vehicle v ON t.EntityId = v.VehicleId
INNER JOIN dbo.GroupDetail gd ON v.VehicleId = gd.EntityDataId
INNER JOIN dbo.[Group] g ON gd.GroupId = g.GroupId
LEFT JOIN dbo.[User] uin ON uin.UserID = t.CheckInUserId
LEFT JOIN dbo.[User] uout ON uout.UserID = t.CheckOutUserId
WHERE t.Archived = 0
  AND t.CheckOutDateTime BETWEEN @sdate AND @edate
  AND v.VehicleId IN (SELECT VALUE FROM dbo.Split(@vids, ','))
  AND g.GroupId IN (SELECT VALUE FROM dbo.Split(@gids, ','))
ORDER BY g.GroupName, v.Registration


GO
