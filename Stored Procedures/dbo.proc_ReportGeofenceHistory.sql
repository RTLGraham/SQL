SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportGeofenceHistory]
( 
	@vids nvarchar(MAX),
	@geoids nvarchar(MAX),
	@sdate DATETIME,
	@edate DATETIME,
	@uid UNIQUEIDENTIFIER
)
AS

--DECLARE @vids NVARCHAR(MAX),
--		@geoids NVARCHAR(MAX),
--		@sdate DATETIME,
--		@edate DATETIME,
--		@uid UNIQUEIDENTIFIER
--
--SET @vids = N'5F3CEA35-DCBE-4120-9301-09FF638BF9DF,46D70EB7-624A-4F2D-92D7-1DB630EE116F,9DFE074E-F8B7-44C0-8BAA-3FB046ED29A2,49482BB6-B7CC-40C1-9F61-48728BF61A8E,F30F1966-C7B8-4980-BFFE-5B930071D32D,991F0624-E911-4A0A-9E34-632B912A9C38,202B4D58-3993-43D1-A8C5-7BC46C7CEFA5,747C1E8B-7F86-4BB3-9AC3-8C4E319272B2,1D3D521A-9CFF-4B73-BC2E-97ADB314A3A2,767A5BB3-0077-4799-AC91-9E88279E99F1,7F0079D1-5D4E-47D8-AFEA-A9835C3A3D00,09504D20-457C-49EC-A6EE-CC7DAA4C4252,28E3452A-A515-45BC-B95F-DED8A0EB1CD8'
--SET @sdate = '2012-10-29 00:00'
--SET @edate = '2012-10-29 23:59'
--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
--SET @geoids = N'336E3B59-E3D9-4974-83CD-CC2F12DAF33A'

-- Section added to allow the report to be automatically scheduled
IF datepart(yyyy, @sdate) = '1960'
BEGIN
	SET @edate = dbo.Calc_Schedule_EndDate(@sdate, @uid)
	SET @sdate = dbo.Calc_Schedule_StartDate(@sdate, @uid)
END

SET @sdate = dbo.TZ_ToUtc(@sdate, DEFAULT, @uid)
SET @edate = dbo.TZ_ToUtc(@edate, DEFAULT, @uid)
	  
SELECT	g.GeofenceId, g.Name AS Geofencename, g.GeofenceCategoryId AS Geofencecategory, g.GeofenceTypeId AS GeofenceType, NULL AS Note,
		v.Registration, v.VehicleId, 
		dbo.TZ_GetTime(vgh.EntryDateTime, DEFAULT, @uid) AS DateEnteredGeofence, 
		--CASE WHEN vgh.ExitDateTime IS NULL THEN 'N/A' ELSE CONVERT(VARCHAR(MAX),dbo.TZ_GetTime(vgh.ExitDateTime,DEFAULT,@uid),121) END AS DateLeftGeofence,
		CASE WHEN vgh.ExitDateTime IS NULL THEN NULL ELSE dbo.TZ_GetTime(vgh.ExitDateTime,DEFAULT,@uid) END AS DateLeftGeofence,
		dbo.ConvertDuration(CASE WHEN vgh.ExitDateTime IS NULL THEN 0 ELSE DATEDIFF(ss,vgh.EntryDateTime,vgh.ExitDateTime) END) AS TimeSpentInGeofenceText,
		CASE WHEN vgh.ExitDateTime IS NULL THEN 0 ELSE DATEDIFF(ss,vgh.EntryDateTime,vgh.ExitDateTime) END AS TimeSpentInGeofence
FROM dbo.Vehicle v
INNER JOIN dbo.VehicleGeofenceHistory vgh ON v.VehicleIntId = vgh.VehicleIntId
INNER JOIN dbo.Geofence g ON vgh.GeofenceId = g.GeofenceId
WHERE v.VehicleId IN (SELECT Value FROM dbo.Split(@vids, ','))
  AND g.GeofenceId IN (SELECT VALUE FROM dbo.Split(@geoids, ','))
  AND vgh.EntryDateTime <= @edate
  AND ISNULL(vgh.ExitDateTime, @edate) >= @sdate
ORDER BY v.Registration, vgh.EntryDateTime



GO
