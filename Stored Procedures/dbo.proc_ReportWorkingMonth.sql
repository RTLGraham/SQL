SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_ReportWorkingMonth]
		@vids NVARCHAR(MAX),
		@uid UNIQUEIDENTIFIER,
		@sdate DATETIME,
		@edate DATETIME
AS 

--DECLARE @vids NVARCHAR(MAX),
--		@uid UNIQUEIDENTIFIER,
--		@sdate DATETIME,
--		@edate DATETIME
--SET @vids = N'8016F50D-A2D1-49A9-BC1E-13AE27953390,486A43F1-70D9-46CC-A745-542B6A4D77CE,5DE385BF-BFCB-4179-90CB-5AEE460B14AD,67B44E7F-6A0E-42E0-9DCF-5DDCA2AF502E,2C1A82DE-6DCB-4D03-BC21-5F65198B9A84,DB3AC174-1CFE-404C-914B-6BE9DB1B7038,D075F7EF-C02E-46E4-91C3-8191F2167F59,6CD1331B-F7FC-4866-A333-8FEE45667F33,91D26E73-DBD4-45DA-935C-997766C44AA2,3708F23A-F7CA-44F0-BB96-A94E80C40DFF'
--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
--SET @sdate = '2013-12-01 00:00'
--SET @edate = '2013-12-31 23:59'

DECLARE @sdateUT DATETIME,
		@edateUT DATETIME
SET @sdateUT = @sdate
SET @edateUT = @edate

SET @sdate = dbo.TZ_ToUtc(@sdate, DEFAULT, @uid)
SET @edate = dbo.TZ_ToUtc(@edate, DEFAULT, @uid)

SELECT  Registration,
		SUM(TripDistance) AS TripDistance,
		SUM(DrivingHours) AS DrivingHours,
		SUM(WorkingHours) AS WorkingHours,
		SUM(TripDistance) / (SUM(DrivingHours)/60.0/60.0) AS AverageDrivingSpeed,
		@sdateUT AS StartDate,
		@edateUT AS EndDate	
FROM
(
	SELECT	v.Registration,
			CONVERT(VARCHAR(11),[AU_Fleetseek_App].[dbo].[TZ_GetTime](dt.StartEventDateTime, DEFAULT, @uid),121) AS [Date],
			[AU_Fleetseek_App].[dbo].[TZ_GetTime](MIN(dt.StartEventDateTime), DEFAULT, @uid) AS FirstKeyOn,
			[AU_Fleetseek_App].[dbo].[TZ_GetTime](MAX(dt.EndEventDateTime), DEFAULT, @uid) AS LastKeyOff,
			DATEDIFF(second, MIN(dt.StartEventDateTime), MAX(dt.EndEventDateTime)) AS WorkingHours,
			SUM(dt.TripDuration * 60) AS DrivingHours,
			SUM(dt.TripDistance / 1000.0) AS TripDistance		
	FROM dbo.DriverTrip dt
		INNER JOIN dbo.Vehicle v ON dt.VehicleIntId = v.VehicleIntId
	WHERE v.VehicleId IN (SELECT value FROM dbo.Split(@vids, ',')) 
	  AND v.Archived = 0 AND v.IVHId IS NOT NULL
	  AND dt.EndEventDateTime BETWEEN @sdate AND @edate
	GROUP BY v.Registration, CONVERT(VARCHAR(11),[AU_Fleetseek_App].[dbo].[TZ_GetTime](dt.StartEventDateTime, DEFAULT, @uid),121)
) r
GROUP BY Registration, CONVERT(VARCHAR(7),[AU_Fleetseek_App].[dbo].[TZ_GetTime]([Date], DEFAULT, @uid),121)
ORDER BY Registration
GO
