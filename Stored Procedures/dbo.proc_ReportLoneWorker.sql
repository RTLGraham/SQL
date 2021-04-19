SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_ReportLoneWorker]
(
	@gids varchar(max),
	@vids varchar(max),
	@sdate datetime,
	@edate datetime,
	@uid uniqueidentifier
)
AS

--DECLARE	@gids VARCHAR(max),
--		@vids varchar(max),
--		@sdate datetime,
--		@edate datetime,
--		@uid UNIQUEIDENTIFIER

--SET @gids = N'25B2C58E-FB99-4B43-A12A-9B6376564110'		
--SET @vids = NULL--N'D71E0807-0CC8-E011-A26E-001C23C37503'
--SET @sdate = '2012-02-01 05:00'
--SET @edate = '2012-06-28 08:59'
--SET	@uid = N'96C9A837-153E-4EA1-9824-668F1FA47858'

-- Section added to allow the report to be automatically scheduled
IF datepart(yyyy, @sdate) = '1960'
BEGIN
	SET @edate = dbo.Calc_Schedule_EndDate(@sdate, @uid)
	SET @sdate = dbo.Calc_Schedule_StartDate(@sdate, @uid)
END

DECLARE @Vehicles TABLE (VehicleId UNIQUEIDENTIFIER)
IF @vids IS NULL -- populate vehicle list from Group Ids provided
BEGIN
	INSERT INTO @Vehicles ( VehicleId )
	SELECT EntityDataId
	FROM dbo.GroupDetail gd
	INNER JOIN dbo.[Group] g ON gd.GroupId = g.GroupId
	WHERE g.GroupTypeId = 1
	  AND g.IsParameter = 0
	  AND g.Archived = 0
	  AND g.GroupId IN (SELECT VALUE FROM dbo.Split(@gids, ','))
END ELSE -- populate from list of Vehicle Ids provided
BEGIN
	INSERT INTO	@Vehicles ( VehicleId )
	SELECT VALUE FROM dbo.Split(@vids, ',')
END

DECLARE @sdate_in DATETIME
DECLARE @edate_in DATETIME

SET @sdate_in = @sdate
SET @edate_in = @edate
SET @sdate = dbo.TZ_ToUtc(@sdate, DEFAULT, @uid)
SET @edate = dbo.TZ_ToUtc(@edate, DEFAULT, @uid)

SELECT	gr.GroupId,
		v.VehicleId,
		d.DriverId,
		
		gr.GroupName,
		v.Registration,
		
		--dbo.FormatDriverNameByUser(d.DriverId, @uid) AS DriverName,
		dbo.FormatDriverNameByUser(dbo.GetDriverIdFromEvent_CFSeries(v.VehicleId, MIN(e.EventDateTime)), @uid) AS DriverName,
		
		d.Number AS DriverNumber,
		
		MAX(
		CASE WHEN e.Lat IS NOT NULL AND e.Long IS NOT NULL 
			THEN dbo.GetGeofenceNameFromLongLat (e.Lat, e.Long, @uid, dbo.GetAddressFromLongLat(e.Lat, e.Long))
			ELSE 'Unknown Location'
		END) as Location,
		
		dbo.TZ_GetTime(LoneWorkingStart,default,@uid) AS LoneWorkingStart,
		dbo.TZ_GetTime(LoneWorkingEnd,default,@uid) AS LoneWorkingEnd,
		dbo.TZ_GetTime(AlarmTriggeredDateTime,default,@uid) AS AlarmTriggeredDateTime,
		
		@sdate AS sdate ,
		@edate AS edate ,
		@sdate_in AS CreationDateTime ,
		@edate_in AS ClosureDateTime
FROM	dbo.LoneWorking lw
INNER JOIN dbo.Vehicle v ON lw.VehicleID = v.VehicleId
LEFT OUTER JOIN dbo.Event e ON e.CustomerIntId = lw.CustomerIntId
											AND e.VehicleIntId = v.VehicleIntId
											AND e.EventDateTime BETWEEN lw.LoneWorkingStart AND lw.LoneWorkingEnd
INNER JOIN @Vehicles vt ON v.VehicleId = vt.VehicleId
INNER JOIN dbo.GroupDetail gd ON gd.EntityDataId = v.VehicleId
INNER JOIN dbo.[Group] gr ON gr.GroupId = gd.GroupId
INNER JOIN dbo.Driver d ON lw.DriverId = d.DriverId
WHERE gr.GroupId IN (SELECT VALUE FROM dbo.Split(@gids, ','))
  AND lw.LoneWorkingStart BETWEEN @sdate AND @edate
GROUP BY gr.GroupId, v.VehicleId, d.DriverId, gr.GroupName, v.Registration, d.DriverId, d.Number, LoneWorkingStart, LoneWorkingEnd, AlarmTriggeredDateTime
ORDER BY lw.LoneWorkingStart DESC

GO
