SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_Report_VehiclesAWOL]
( 
	@vids nvarchar(MAX),
	@sdate DATETIME,
	@edate DATETIME,
	@hours INT,
	@uid UNIQUEIDENTIFIER
)
AS

--DECLARE @vids NVARCHAR(MAX),
--		@sdate DATETIME,
--		@edate DATETIME,
--		@hours INT,
--		@uid UNIQUEIDENTIFIER

--SET @vids = N'AB7EB9A5-37C3-4932-95EF-4BA47CADBF5C'
--SET @sdate = '2019-05-28 00:00'
--SET @edate = '2019-05-29 23:59'
--SET @hours = 8
--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'

SET @sdate = dbo.TZ_ToUtc(@sdate, DEFAULT, @uid)
SET @edate = dbo.TZ_ToUtc(@edate, DEFAULT, @uid)
	  
SELECT	hg.GroupName AS HomeGroup, home.GeofenceId AS HomeGeofenceId, 
		home.Name AS HomeGeofenceName,
		home.GeofenceSpatialId AS HomeGeofenceSpatialId,
		v.Registration, v.VehicleId, 
		vg.GroupName AS VisitingGroup, geo.GeofenceId AS VisitingGeofenceId,
		geo.Name AS VisitingGeofenceName,
		geo.GeofenceSpatialId AS VisitingGeofenceSpatialId,
		dbo.TZ_GetTime(vgh.EntryDateTime, DEFAULT, @uid) AS DateEnteredGeofence, 
		CASE WHEN vgh.ExitDateTime IS NULL THEN NULL ELSE dbo.TZ_GetTime(vgh.ExitDateTime,DEFAULT,@uid) END AS DateLeftGeofence,
		dbo.ConvertDuration(CASE WHEN vgh.ExitDateTime IS NULL THEN 0 ELSE DATEDIFF(ss,vgh.EntryDateTime,vgh.ExitDateTime) END) AS TimeSpentInGeofenceText,
		CASE WHEN vgh.ExitDateTime IS NULL THEN 0 ELSE DATEDIFF(ss,vgh.EntryDateTime,vgh.ExitDateTime) END AS TimeSpentInGeofence
FROM dbo.Vehicle v
INNER JOIN dbo.GroupDetail hgd ON v.VehicleId = hgd.EntityDataId
INNER JOIN dbo.[Group] hg ON hg.GroupId = hgd.GroupId AND hg.IsPhysical = 1
INNER JOIN dbo.Geofence home ON home.GeofenceId = hg.GeofenceId
INNER JOIN dbo.VehicleGeofenceHistory vgh ON v.VehicleIntId = vgh.VehicleIntId
INNER JOIN dbo.Geofence geo ON vgh.GeofenceId = geo.GeofenceId AND geo.GeofenceId != home.GeofenceId
INNER JOIN dbo.[Group] vg ON vg.GeofenceId = geo.GeofenceId AND vg.IsPhysical = 1
WHERE v.VehicleId IN (SELECT Value FROM dbo.Split(@vids, ','))
  AND vgh.EntryDateTime <= @edate
  AND ISNULL(vgh.ExitDateTime, @edate) >= @sdate
  AND DATEDIFF(MINUTE, vgh.EntryDateTime, vgh.ExitDateTime) > @hours * 60
ORDER BY hg.GroupName, v.Registration, vgh.EntryDateTime



GO
