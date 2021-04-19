SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_ReportDriverWorkDiary]
(
	@did UNIQUEIDENTIFIER,
	@uid UNIQUEIDENTIFIER,
	@date DATETIME
)
AS

--DECLARE @did UNIQUEIDENTIFIER,
--		@uid UNIQUEIDENTIFIER,
--		@date DATETIME
----SET @did = N'BA3D9B4C-C852-46A7-8951-60A44BE0FB12' --918
--SET @did = N'7346136E-4A92-4CC7-BC50-4590C1DBDEE3' --708
--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
--SET @date = '2013-08-18 00:00'
 
DECLARE @dintid INT,
		@vehicleintid INT,
		@diststr VARCHAR(20),
		@distmult FLOAT,
                    @custid UNIQUEIDENTIFIER
		
SELECT @diststr = [dbo].UserPref(@uid, 203)
SELECT @distmult = [dbo].UserPref(@uid, 202)

SET @dintid = dbo.GetDriverIntFromId(@did)

SELECT	wd.Number AS WorkDiaryNumber,
		@did AS DriverId,
		dbo.FormatDriverNameByUser(@did, @uid) AS DriverName,
		wdp.Date AS WorkDiaryPageDate,
		'AFM' AS AccreditationType,
		d.LicenceNumber,
		d.IssuingAuthority,
		'Melbourne Time' AS DriverBase,
		DATEADD(minute, 450, wdp.Date) AS DailyCheckTime,
		wdp.DriverSignature,
		wdp.SignDate AS Signdate,
		CASE	
			WHEN d2.DriverId IS NULL
			THEN NULL
			ELSE 'AFM'
		END AS TwoUpAccreditationType,
		dbo.FormatDriverNameByUser(d2.DriverId, @uid) AS TwoUpDrivername,
		d2.LicenceNumber AS TwoUpLicenceNumber,
		d2.IssuingAuthority AS TwoUpIssuingAuthority,
		wd2.Number AS TwoUpWorkDiaryNumber,
		CASE	
			WHEN d2.DriverId IS NULL
			THEN NULL
			ELSE 'Melbourne Time'
		END AS TwoUpDriverBase,
		wdp2.DriverSignature AS TwoUpDriverSignature,
		wdp2.SignDate AS TwoUpSignDate,
		wdt.TransitionDateTime,
		v.Registration,
		wst.WorkStateTypeId,
		wst.Name AS WorkRestState,
		wdt.Odometer,
		wdt.Lat,
		wdt.Long,
		CASE	
			WHEN wdt.Location IS NULL 
			THEN [dbo].[GetGeofenceNameFromLongLat] (wdt.Lat, wdt.Long, @uid, [dbo].[GetAddressFromLongLat] (wdt.Lat, wdt.Long)) 
			ELSE wdt.Location 
		END AS Location,
		wdt.TwoUpInd,
		wdt.Note
FROM dbo.WKD_WorkDiary wd
INNER JOIN dbo.WKD_WorkDiaryPage wdp ON wd.WorkDiaryId = wdp.WorkDiaryId
INNER JOIN dbo.WKD_WorkDiaryTransition wdt ON wdp.WorkDiaryPageId = wdt.WorkDiaryPageId
INNER JOIN dbo.Driver d ON wd.DriverIntId = d.DriverIntId
INNER JOIN dbo.WKD_WorkStateType wst ON wdt.WorkStateTypeId = wst.WorkStateTypeId
LEFT JOIN dbo.WKD_WorkDiaryPage wdp2 ON wdp.TwoUpWorkDiaryPageId = wdp2.WorkDiaryPageId
LEFT JOIN dbo.WKD_WorkDiary wd2 ON wdp2.WorkDiaryId = wd2.WorkDiaryId
LEFT JOIN dbo.Driver d2 ON wd2.DriverIntId = d2.DriverIntId
INNER JOIN dbo.Vehicle v ON wdt.VehicleIntId = v.VehicleIntId
WHERE wd.DriverIntId = @dintid
  AND @date = wdp.Date
  
  


GO
