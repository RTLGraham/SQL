SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_ReportDriverWorkDiaryHistory]
(
	@did UNIQUEIDENTIFIER,
	@uid UNIQUEIDENTIFIER
)
AS

--DECLARE @did UNIQUEIDENTIFIER,
--		@uid UNIQUEIDENTIFIER
--SET @did = N'BA3D9B4C-C852-46A7-8951-60A44BE0FB12' --918
----SET @did = N'7346136E-4A92-4CC7-BC50-4590C1DBDEE3' --708
--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
 
DECLARE @dintid INT,
		@vehicleintid INT,
		@diststr VARCHAR(20),
		@distmult FLOAT,
                    @custid UNIQUEIDENTIFIER
		
SELECT @diststr = [dbo].UserPref(@uid, 203)
SELECT @distmult = [dbo].UserPref(@uid, 202)

SET @dintid = dbo.GetDriverIntFromId(@did)

SELECT	wd.Number AS WorkDiaryNumber,
		dbo.FormatDriverNameByUser(@did, @uid) AS DriverName,
		wdp.Date AS WorkDiaryPageDate,
		d.LicenceNumber,
		d.IssuingAuthority,
		wdp.DriverSignature,
		wdp.SignDate AS Signdate,
		dbo.FormatDriverNameByUser(d2.DriverId, @uid) AS TwoUpDrivername,
		d2.LicenceNumber AS TwoUpLicenceNumber,
		d2.IssuingAuthority AS TwoUpIssuingAuthority,
		wd2.Number AS TwoUpWorkDiaryNumber,
		wdp2.DriverSignature AS TwoUpDriverSignature,
		wdp2.SignDate AS TwoUpSignDate,
		wdt.TransitionDateTime,
		v.Registration,
		wst.Name AS WorkRestState,
		wdt.Odometer,
		wdt.Lat,
		wdt.Long,
		wdt.Location,
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
  AND wdp.Date > DATEADD(dd, -30, GETUTCDATE())
  
  


GO
