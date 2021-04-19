SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_ReportGeofenceTrigger]
    (
	  @gids VARCHAR(MAX),
      @vids VARCHAR(MAX),
      @sdate DATETIME,
      @edate DATETIME,
      @uid UNIQUEIDENTIFIER
    )
AS 
--DECLARE	@gids VARCHAR(max),
--		@vids varchar(max),
--		@sdate datetime,
--		@edate datetime,
--		@uid uniqueidentifier

--SET @gids = N'10E832C1-A6A6-42B9-B1BD-53D1573C474A' -- Aldi All Vehicles
--SET @vids = N'59733029-B49F-DF11-85AD-0015173D1551,7D7BD944-B49F-DF11-85AD-0015173D1551,D1109586-B49F-DF11-85AD-0015173D1551,75BBC8A8-ABD5-4A29-9DB0-581C2F963EBC,79095E32-0C43-4739-9DF5-75A6844D33FF,545DB846-295C-4BEA-B7FA-5F67AE3D3A58,AFFE4CD6-542E-467E-8919-2B65DCF43CD2,C87E8AE8-D2E5-4BFA-9B29-99CBE702A8F0,368735B2-D6F5-4DC7-B151-0F44173B2722,A4C46AC9-A57D-47FE-934D-70DC116BEEE2,C72FFE13-BAF0-4BD0-A5CA-B0D60294AE54,A8B0D171-27A1-43B5-A976-BDBBDDBFAB9C,E8AE6DDC-C9E3-43A6-933C-A5E64D3AC57A,80E32D36-6CB0-4559-9764-DA1E2554F16A,6DAA52DD-02A8-4D7C-B9DC-7A98F668BC0D,6C155DEE-FBAC-4DF8-AEF8-95BE3CB255B0,AC65CCCB-D34E-473A-8A93-C6CA7D177A26,231AF06F-C319-4AD7-8729-FB254772A6D2,BE1E710E-5DBF-4229-B70C-520A2AE17233,44A2FAC7-23CE-4AC3-8851-1BA7F9DF8B37,E967EFD9-7578-47FA-91BB-E9F4AEE62E74,351F7DAD-8EBB-488D-98CC-3C2973BEFA4D'
--SET @sdate = '2014-01-01 00:00:00'
--SET @edate = '2014-01-30 23:59:59'
--SET @uid = N'CB4E745A-514B-47A4-9C29-2ECBE2CD85D1'  -- AldiTriggerOwner

    SET @sdate = [dbo].TZ_ToUTC(@sdate, DEFAULT, @uid)
    SET @edate = [dbo].TZ_ToUTC(@edate, DEFAULT, @uid)
    
	SELECT DISTINCT g.GroupName, 
					v.Registration, 
					t.TriggerTypeId,
					t.Name AS TriggerName,
                    dbo.FormatDriverNameByUser(d.DriverId, @uid) AS Drivername,
					geo.Name AS 'Site Name', 
					dbo.TZ_GetTime(np.TriggerDateTime, DEFAULT, @uid) AS 'Entered Geofence', 
					dbo.TZ_GetTime(dbo.TZ_ToUtc(np.LastOperation, 'GMT Time',@uid), DEFAULT, @uid) AS 'Notified at',
					@sdate AS sdate,
					@edate AS edate,
					dbo.TZ_GetTime(@sdate, DEFAULT, @uid) AS CreationDateTime,
					dbo.TZ_GetTime(@edate, DEFAULT, @uid) AS ClosureDateTime
	FROM dbo.TAN_NotificationPending np
	INNER JOIN dbo.TAN_Trigger t ON np.TriggerId = t.TriggerId
	INNER JOIN dbo.Vehicle v ON np.VehicleId = v.VehicleId
	INNER JOIN dbo.Driver d ON np.DriverId = d.DriverId
	INNER JOIN dbo.GroupDetail gd ON v.VehicleId = gd.EntityDataId
	INNER JOIN dbo.[Group] g ON gd.GroupId = g.GroupId AND gd.GroupTypeId = g.GroupTypeId
	INNER JOIN dbo.Geofence geo ON np.GeofenceId = geo.GeofenceId
	WHERE t.TriggerTypeId IN (23) --,24,25)
      AND v.VehicleId IN ( SELECT Value FROM dbo.Split(@vids, ',') )
      AND g.GroupId IN ( SELECT Value FROM dbo.Split(@gids, ',') )
      AND np.TriggerDateTime BETWEEN @sdate AND @edate
   	ORDER BY dbo.TZ_GetTime(np.TriggerDateTime, DEFAULT, @uid)



GO
