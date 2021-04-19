SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_LoneWorker_Mobile]
    (
	  @uid UNIQUEIDENTIFIER,
      @gids NVARCHAR(MAX),
      @dids NVARCHAR(MAX),
      @sdate DATETIME,
      @edate DATETIME
    )
AS 

	--DECLARE	@sdate DATETIME,
	--		@edate DATETIME,
	--		@uid UNIQUEIDENTIFIER,
	--		@dids NVARCHAR(MAX),
	--		@gids VARCHAR(MAX)
			
	--SET @sdate = '2020-08-24 00:00:00'
	--SET @edate = '2020-08-24 23:59:59'
	--SET @uid = N'988D25DE-65E9-4FC5-8981-3D2B4EA0FEAB'
	--SET @dids = N'B3B43D25-48A1-4338-9133-2CA79FEF53B6'
	--SET @gids = N'59886EF0-88D5-4537-8F7C-D82835D58AB0'

    SET @sdate = [dbo].TZ_ToUTC(@sdate, DEFAULT, @uid)
    SET @edate = [dbo].TZ_ToUTC(@edate, DEFAULT, @uid)

	DECLARE @maxDiam FLOAT
	SELECT @maxDiam = dbo.GetUserGeoMaxDiam(@uid)
	
	SELECT	
			g.GroupId,
			g.GroupName,
			lw.LoneWorkerId,
			d.DriverId,
			d.FirstName,
			d.Surname,
			--lw.StartTime,
			dbo.TZ_GetTime(lw.StartTime, DEFAULT, @uid) AS StartTime,
			lw.Duration,
			dbo.TZ_GetTime(lw.AlarmTriggeredDateTime, DEFAULT, @uid) AS AlarmTriggeredDateTime,
			--lw.StopTime,
			dbo.TZ_GetTime(lw.StopTime, DEFAULT, @uid) AS StopTime,
			lw.Lat,
			lw.Lon,
			[dbo].[GetGeofenceNameFromLongLat_Ltd] (lw.Lat, lw.Lon, @uid, [dbo].[GetAddressFromLongLat](lw.Lat, lw.Lon), @maxDiam) as ReverseGeoCode,
			dbo.TZ_GetTime(lwa.ResponseDateTime, DEFAULT, @uid) AS AcknowledgedAt,
			dbo.FormatUserNameByUser(lwa.UserId, lwa.UserId) AS AcknowledgedBy,
			lwa.Comment,
			t.ResponseTypeId AS ResponseId,
			t.Name AS Response,
			v.Registration,
			dbo.DistanceBetweenPoints(lw.Lat,lw.Lon,dle.Lat,dle.Long) AS Distance,
			v.VehicleId
	FROM dbo.LW_LoneWorker lw
		LEFT JOIN dbo.LW_LoneWorkerAck lwa ON lwa.LoneWorkerId = lw.LoneWorkerId
		LEFT JOIN dbo.LW_LoneWorkerResponseType t ON t.ResponseTypeId = lwa.ResponseTypeId
		INNER JOIN dbo.Driver d ON d.DriverId = lw.DriverId
		INNER JOIN dbo.GroupDetail gd ON gd.EntityDataId = d.DriverId
		INNER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId
		LEFT JOIN dbo.DriverLatestEvent dle ON dle.DriverId = lw.DriverId
		LEFT JOIN dbo.Vehicle v ON v.VehicleId = dle.VehicleId AND v.Archived = 0
	WHERE lw.StartTime BETWEEN @sdate AND @edate
		AND lw.DriverId IN (SELECT Value FROM dbo.Split(@dids, ','))
		AND g.IsParameter = 0 AND g.Archived = 0
		AND g.GroupId IN (SELECT Value FROM dbo.Split(@gids, ','))
	ORDER BY g.GroupName, lw.StartTime

	


GO
