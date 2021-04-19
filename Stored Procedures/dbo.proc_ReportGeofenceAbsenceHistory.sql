SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportGeofenceAbsenceHistory]
( 
	@vids nvarchar(MAX),
	@geoid UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME,
	@uid UNIQUEIDENTIFIER
)
AS

/*************************************************************************************************/
/*	14/09/20	BM	Added Driver Name to the result set                                          */
/*************************************************************************************************/

--DECLARE @vids NVARCHAR(MAX),
--		@geoid UNIQUEIDENTIFIER,
--		@sdate DATETIME,
--		@edate DATETIME,
--		@uid UNIQUEIDENTIFIER

----SET @vids = N'5F3CEA35-DCBE-4120-9301-09FF638BF9DF,46D70EB7-624A-4F2D-92D7-1DB630EE116F,9DFE074E-F8B7-44C0-8BAA-3FB046ED29A2,49482BB6-B7CC-40C1-9F61-48728BF61A8E,F30F1966-C7B8-4980-BFFE-5B930071D32D,991F0624-E911-4A0A-9E34-632B912A9C38,202B4D58-3993-43D1-A8C5-7BC46C7CEFA5,747C1E8B-7F86-4BB3-9AC3-8C4E319272B2,1D3D521A-9CFF-4B73-BC2E-97ADB314A3A2,767A5BB3-0077-4799-AC91-9E88279E99F1,7F0079D1-5D4E-47D8-AFEA-A9835C3A3D00,09504D20-457C-49EC-A6EE-CC7DAA4C4252,28E3452A-A515-45BC-B95F-DED8A0EB1CD8'
--SET @vids = N'67B44E7F-6A0E-42E0-9DCF-5DDCA2AF502E'
--SET @sdate = '2020-09-08 00:00'
--SET @edate = '2020-09-08 23:59'
--SET @uid = N'3C65E267-ED53-4599-98C5-CBF5AFD85A66'
----SET @geoid = N'336E3B59-E3D9-4974-83CD-CC2F12DAF33A'
--SET @geoid = N'EC5CEEAC-9E02-4951-B87C-1DC95CF6F642'

SET @sdate = dbo.TZ_ToUtc(@sdate, DEFAULT, @uid)
SET @edate = dbo.TZ_ToUtc(@edate, DEFAULT, @uid)
	  
SELECT	g.GeofenceId, g.Name AS Geofencename, g.GeofenceCategoryId AS Geofencecategory, g.GeofenceTypeId AS GeofenceType, NULL AS Note,
		v.Registration, v.VehicleId,
		dbo.TZ_GetTime(vghexit.ExitDateTime, DEFAULT, @uid) AS DateLeftGeofence,
		CASE WHEN vghentry.EntryDateTime IS NULL THEN NULL ELSE dbo.TZ_GetTime(vghentry.EntryDateTime,DEFAULT,@uid) END AS DateEnteredGeofence,	
		dbo.ConvertDuration(CASE WHEN vghentry.EntryDateTime IS NULL THEN 0 ELSE DATEDIFF(ss,vghexit.ExitDateTime,vghentry.EntryDateTime) END) AS TimeSpentOutsideGeofenceText,
		CASE WHEN vghentry.EntryDateTime IS NULL THEN 0 ELSE DATEDIFF(ss,vghexit.ExitDateTime,vghentry.EntryDateTime) END AS TimeSpentOutsideGeofence,dbo.FormatDriverNameByUser(d.DriverId,@uid) AS DriverName

FROM dbo.Vehicle v 


INNER JOIN (SELECT vgh.*, ROW_NUMBER() OVER(PARTITION BY v.VehicleIntId ORDER BY VehicleGeofenceHistoryId) AS RowNum
			FROM dbo.VehicleGeofenceHistory vgh
			INNER JOIN dbo.Vehicle v ON vgh.VehicleIntId = v.VehicleIntId
			WHERE v.VehicleId IN (SELECT Value FROM dbo.Split(@vids, ','))
			  AND vgh.GeofenceId = @geoid
			  AND vgh.ExitDateTime <= @edate
			  AND vgh.ExitDateTime >= @sdate
			) vghexit ON v.VehicleIntId = vghexit.VehicleIntId

LEFT JOIN (SELECT vgh.*, ROW_NUMBER() OVER(PARTITION BY v.VehicleIntId ORDER BY VehicleGeofenceHistoryId) AS RowNum
			FROM dbo.VehicleGeofenceHistory vgh
			INNER JOIN dbo.Vehicle v ON vgh.VehicleIntId = v.VehicleIntId
			WHERE v.VehicleId IN (SELECT Value FROM dbo.Split(@vids, ','))
			  AND vgh.GeofenceId = @geoid
			  AND ISNULL(vgh.ExitDateTime, @edate) >= @sdate
			  AND vgh.EntryDateTime <= @edate
			) vghentry ON vghexit.VehicleIntId = vghentry.VehicleIntId AND vghexit.RowNum + 1 = vghentry.RowNum

INNER JOIN dbo.Geofence g ON vghexit.GeofenceId = g.GeofenceId
INNER JOIN dbo.Driver d ON d.DriverIntId = vghexit.ExitDriverIntId			  
WHERE v.VehicleId IN (SELECT Value FROM dbo.Split(@vids, ','))
  AND vghexit.GeofenceId IN (SELECT VALUE FROM dbo.Split(@geoid, ','))

ORDER BY v.Registration, vghexit.ExitDateTime




GO
