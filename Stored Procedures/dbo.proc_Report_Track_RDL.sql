SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_Report_Track_RDL]
          @uid uniqueidentifier,
          @gids nvarchar(MAX),
          @vids nvarchar(MAX),
          @modes nvarchar(MAX)
AS

--DECLARE @uid UNIQUEIDENTIFIER,
--		@gids NVARCHAR(MAX),
--		@vids NVARCHAR(MAX),
--		@modes NVARCHAR(MAX)
--
--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
--SET @gids = N'F0F5ED40-A37B-4718-863D-FECA640FC5CD'
--SET @vids = N'5F3CEA35-DCBE-4120-9301-09FF638BF9DF,46D70EB7-624A-4F2D-92D7-1DB630EE116F,49482BB6-B7CC-40C1-9F61-48728BF61A8E,F30F1966-C7B8-4980-BFFE-5B930071D32D,991F0624-E911-4A0A-9E34-632B912A9C38,7F0079D1-5D4E-47D8-AFEA-A9835C3A3D00,09504D20-457C-49EC-A6EE-CC7DAA4C4252'
--SET @modes = NULL

SET NOCOUNT ON;

DECLARE @tempmult FLOAT,
		@liquidmult FLOAT
		
SET @tempmult = ISNULL(dbo.[UserPref](@uid, 214),1)
SET @liquidmult = ISNULL(dbo.[UserPref](@uid, 200),1)

SELECT	g.GroupID, g.GroupName,
        v.VehicleID, v.Registration, v.VehicleTypeID,
        vle.DriverID, dbo.FormatDriverNameByUser(vle.DriverID, @uid) AS DriverName,
        dbo.GetAddressFromLongLat(vle.Lat, vle.Long) AS Address,
		dbo.TZ_GetTime(vle.EventDateTime, DEFAULT, @uid) AS EventDateTime,
        vle.Heading, vle.VehicleMode,
        CASE 
			WHEN vle.VehicleMode != 1 AND vle.Speed = 254 THEN 0 --vehicle stationary and speed is n/a
			WHEN vle.VehicleMode = 1 AND vle.Speed = 254 THEN NULL -- vehicle driving and speed is n/a
			ELSE CONVERT(int, CONVERT(float, vle.Speed)*dbo.UserPref(@uid, 208)) 
		END AS Speed, 
		dbo.UserPref(@uid, 209) AS SpeedUnit,
        vle.AnalogIOAlertTypeID, vle.DigitalIO,
		dbo.GetScaleConvertAnalogValue(vle.AnalogData0, 0, vle.VehicleId, @tempmult, @liquidmult) AS AnalogData0,
		dbo.GetScaleConvertAnalogValue(vle.AnalogData1, 1, vle.VehicleId, @tempmult, @liquidmult) AS AnalogData1,
		dbo.GetScaleConvertAnalogValue(vle.AnalogData2, 2, vle.VehicleId, @tempmult, @liquidmult) AS AnalogData2,
		dbo.GetScaleConvertAnalogValue(vle.AnalogData3, 3, vle.VehicleId, @tempmult, @liquidmult) AS AnalogData3,
		NULL AS AnalogData4,
		NULL AS AnalogData5
--        vle.AnalogData0, vle.AnalogData1, vle.AnalogData2, vle.AnalogData3, vle.AnalogData4, vle.AnalogData5
FROM    dbo.VehicleLatestEvent vle
        INNER JOIN dbo.Vehicle v ON vle.VehicleID = v.VehicleID
        INNER JOIN GroupDetail gd ON gd.EntityDataID = vle.VehicleID AND gd.GroupTypeID = 1
        INNER JOIN [Group] g ON g.GroupID = gd.GroupID AND g.GroupTypeID = 1 AND g.IsParameter = 0 AND g.Archived = 0
WHERE v.VehicleId IN (SELECT value FROM dbo.Split(@vids, ','))
  AND g.groupid	 IN (SELECT VALUE FROM dbo.Split(@gids, ','))
  AND (vle.VehicleMode IN (SELECT VALUE FROM dbo.Split(@modes,',')) OR @modes IS NULL)
ORDER BY  V.Registration;





GO
