SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_Report_Idling]
	@uid    UNIQUEIDENTIFIER,
	@vids   NVARCHAR(MAX),
	@dids   NVARCHAR(MAX),
	@sdate  DATETIME,
	@edate  DATETIME,
	@mingap	INT
AS
SET NOCOUNT ON;

/*********************************************************************************/
/*                                                                               */
/* 01/07/19	GKP	Modified to calculate idle start using idle config (keyid = 62)  */
/*				if present - otherwise uses default of 3 minutes.				 */
/*																				 */
/*********************************************************************************/

--DECLARE	@uid	UNIQUEIDENTIFIER,
--		@vids   NVARCHAR(MAX),
--		@dids   NVARCHAR(MAX),
--		@sdate  DATETIME,
--		@edate  DATETIME,
--		@mingap	INT
		
--SET @uid = N'82FCE434-9E5E-4040-8FBF-585B76BC67CA'
--SET @vids = NULL--'5591D2C0-DD3F-4234-8377-276D46C1BE68,846E20CC-70B5-47B0-84FB-917FA7F17273,6954D437-7A1D-4D14-836F-D64689C184CE,3ABD43AF-10C8-4481-822C-09B40CC3AF15,0010297A-01DA-43D5-A005-58B81BAA7DD5,17D35F35-C1DC-425C-A7C1-44569422C5A3,F60E527E-42C4-45A5-BB01-43AC860327DD'
--SET @dids = N'524919D4-F5ED-41A9-8BA6-FB06E8EEA32E'
--SET @sdate = '2019-06-03 00:00'
--SET @edate = '2019-06-03 23:59'
--SET @mingap	= 5

IF @vids = ''
	SET @vids = NULL

IF @dids = ''
	SET @dids = NULL

SET @sdate = dbo.TZ_ToUtc(@sdate, DEFAULT, @uid)
SET @edate = dbo.TZ_ToUtc(@edate, DEFAULT, @uid)

IF @dids IS NULL	
BEGIN -- Run report by Vehicle
	SELECT  v.VehicleId,
			v.Registration,
			d.DriverId,
			dbo.FormatDriverNameByUser(d.DriverId, @uid) AS DriverName,
			dbo.TZ_GetTime(CASE WHEN ch.KeyValue IS NOT NULL THEN DATEADD(MINUTE, CAST(ch.keyvalue AS INT) / 60 * -1, vma.StartDate) ELSE DATEADD(MINUTE, -3, vma.StartDate) END, DEFAULT, @uid) AS StartDate,
						vma.StartLat AS Lat,
						vma.StartLon AS Lon,
			ISNULL([dbo].[GetGeofenceNameFromLongLat] (vma.StartLat, vma.StartLon, @uid, [dbo].GetAddressFromLongLat(vma.StartLat, vma.StartLon)), 'Address Unknown') AS Location,
			dbo.TZ_GetTime(vma.EndDate, DEFAULT, @uid) AS EndDate,
			(DATEDIFF(ss, vma.StartDate, vma.EndDate) + CASE WHEN ch.KeyValue IS NOT NULL THEN CAST(ch.KeyValue AS INT) ELSE 180 END) / 60 AS Duration,
			DATEDIFF(ss, vma.StartDate, vma.EndDate) + CASE WHEN ch.KeyValue IS NOT NULL THEN CAST(ch.KeyValue AS INT) ELSE 180 END AS DurationSecs	
	FROM dbo.VehicleModeActivity vma
	INNER JOIN dbo.VehicleMode vm ON vma.VehicleModeId = vm.VehicleModeID
	INNER JOIN dbo.Vehicle v ON vma.VehicleIntId = v.VehicleIntId
	LEFT JOIN dbo.IVH i ON i.IVHId = v.IVHId
	INNER JOIN dbo.Driver d ON vma.StartDriverIntId = d.DriverIntId
	LEFT JOIN dbo.CFG_History ch ON ch.IVHIntId = i.IVHIntId AND ch.EndDate IS NULL AND ch.Status = 1 AND ch.KeyId = 62
	WHERE vma.StartDate >= @sdate AND vma.EndDate <= @edate
	  AND v.VehicleId IN (SELECT VALUE FROM dbo.Split(@vids, ','))
	  --AND (d.DriverId IN (SELECT VALUE FROM dbo.Split(@dids, ',')) OR @dids IS NULL)
	  AND vma.VehicleModeId = 2 -- Idle
	  AND DATEDIFF(mi, CASE WHEN i.IVHTypeId = 7 THEN DATEADD(MINUTE, -3, vma.StartDate) ELSE vma.StartDate END, vma.EndDate) >= @mingap
	ORDER BY StartDate
END ELSE
BEGIN -- Run report by Driver
	SELECT  v.VehicleId,
			v.Registration,
			d.DriverId,
			dbo.FormatDriverNameByUser(d.DriverId, @uid) AS DriverName,
			dbo.TZ_GetTime(CASE WHEN ch.KeyValue IS NOT NULL THEN DATEADD(MINUTE, CAST(ch.keyvalue AS INT) / 60 * -1, vma.StartDate) ELSE DATEADD(MINUTE, -3, vma.StartDate) END, DEFAULT, @uid) AS StartDate,
						vma.StartLat AS Lat,
						vma.StartLon AS Lon,
			ISNULL([dbo].[GetGeofenceNameFromLongLat] (vma.StartLat, vma.StartLon, @uid, [dbo].GetAddressFromLongLat(vma.StartLat, vma.StartLon)), 'Address Unknown') AS Location,
			dbo.TZ_GetTime(vma.EndDate, DEFAULT, @uid) AS EndDate,
			(DATEDIFF(ss, vma.StartDate, vma.EndDate) + CASE WHEN ch.KeyValue IS NOT NULL THEN CAST(ch.KeyValue AS INT) ELSE 180 END) / 60 AS Duration,
			DATEDIFF(ss, vma.StartDate, vma.EndDate) + CASE WHEN ch.KeyValue IS NOT NULL THEN CAST(ch.KeyValue AS INT) ELSE 180 END AS DurationSecs			
	FROM dbo.VehicleModeActivity vma
	INNER JOIN dbo.VehicleMode vm ON vma.VehicleModeId = vm.VehicleModeID
	INNER JOIN dbo.Vehicle v ON vma.VehicleIntId = v.VehicleIntId
	LEFT JOIN dbo.IVH i ON i.IVHId = v.IVHId
	INNER JOIN dbo.Driver d ON vma.StartDriverIntId = d.DriverIntId
	LEFT JOIN dbo.CFG_History ch ON ch.IVHIntId = i.IVHIntId AND ch.EndDate IS NULL AND ch.Status = 1 AND ch.KeyId = 62
	WHERE vma.StartDate >= @sdate AND vma.EndDate <= @edate
	  AND d.DriverId IN (SELECT VALUE FROM dbo.Split(@dids, ','))
	  AND vma.VehicleModeId = 2 -- Idle
	  AND DATEDIFF(mi, CASE WHEN i.IVHTypeId = 7 THEN DATEADD(MINUTE, -3, vma.StartDate) ELSE vma.StartDate END, vma.EndDate) >= @mingap
	ORDER BY StartDate
END		  
	  


GO
