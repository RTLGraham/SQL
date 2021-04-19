SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportSpeedingVehicles_Out]
	@uid UNIQUEIDENTIFIER = NULL
AS
BEGIN

	DECLARE --@uid UNIQUEIDENTIFIER,
			@sdate DATETIME,
			@edate DATETIME

	SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
	SET @sdate = DATEADD(DAY, -1, GETDATE())
	SET @edate = GETDATE()
	
	/* Swap parameters */
	DECLARE	@lsdate datetime,
			@ledate datetime,
			@luid UNIQUEIDENTIFIER

	SET @lsdate = @sdate
	SET @ledate = @edate
	SET @luid = @uid

	/* Declare and Set essential variables */
	DECLARE @speedunit VARCHAR(10), 
			@timezone VARCHAR(255),
			@s_date DATETIME,
			@e_date DATETIME,
			@speedmult FLOAT,
			@vehicleId UNIQUEIDENTIFIER,
			@did INT,
			@sql NVARCHAR(MAX),
			@eventtime DATETIME, 
			@depid INT,
			@cid UNIQUEIDENTIFIER,
			@thpercent FLOAT,
			@thvalue FLOAT

	SELECT @speedunit = dbo.UserPref(@luid, 209)
	SELECT @timezone = dbo.UserPref(@luid, 600)
	SET @s_date = [dbo].TZ_ToUTC(@lsdate,@timezone,@luid)
	SET @e_date = [dbo].TZ_ToUTC(@ledate,@timezone,@luid)
	SET @speedmult = CAST([dbo].[UserPref](@luid,208) AS FLOAT)

	SELECT @cid = CustomerID FROM dbo.[User] WHERE UserID = @luid
	SELECT TOP 1 @thvalue = OverSpeedValue, @thpercent = OverSpeedPercent FROM dbo.Customer WHERE CustomerId = @cid
	IF @thpercent IS NULL SET @thpercent = 0
	IF @thvalue IS NULL SET @thvalue = 0

	SELECT	v.VehicleId,  
			v.Registration,  
			v.VehicleTypeID,
			CAST(e.Speed * @speedmult AS INT) as Speed,  
			CAST(ISNULL(e.SpeedLimit, es.SpeedLimit) AS INT) AS SpeedLimit,  
			[dbo].[TZ_GetTime]( e.EventDateTime, @timezone, @luid) as EventDateTime, 
			e.Lat,  
			e.Long AS SafeNameLong,  
            e.Heading,
			@speedunit AS SpeedUnit,  
			ISNULL(es.StreetName,ISNULL([dbo].[GetNavteqAddressFromLongLat] (e.Lat, e.Long), 
				[dbo].[GetGeofenceNameFromLongLat] (e.Lat, e.Long, @uid, [dbo].[GetAddressFromLongLat] (e.Lat, e.Long))
				)) AS RevGeocode,
			dbo.FormatDriverNameByUser(
				dbo.GetCurrentDriverByEventDateTime( e.VehicleIntId, ISNULL(i.IVHTypeId,0), e.EventDateTime, d.DriverId ),
				@luid) AS Drivername
	FROM	dbo.Event e 
				LEFT OUTER JOIN dbo.EventSpeeding es ON es.EventId = e.EventId
				LEFT OUTER JOIN dbo.Driver d ON e.DriverIntId = d.DriverIntId
				INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
				INNER JOIN dbo.GroupDetail gd ON gd.EntityDataId = v.VehicleId
				INNER JOIN dbo.[Group] g ON gd.GroupId = g.GroupId
				INNER JOIN dbo.UserGroup ug ON g.GroupId = ug.GroupId
				/* LEFT JOIN to support cameras*/
				LEFT OUTER JOIN dbo.IVH i ON v.IVHId = i.IVHId
				INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
				INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId AND e.CustomerIntId = c.CustomerIntId 
	WHERE	e.EventDateTime BETWEEN @s_date AND @e_date  
			AND ((e.SpeedLimit BETWEEN 1 AND 240) OR (es.SpeedLimit BETWEEN 1 AND 240))
			AND ug.UserId = @uid AND g.Archived = 0 AND g.IsParameter = 0 AND g.GroupTypeId = 1
			AND (((e.Speed * @speedmult) * 100) / dbo.ZeroYieldNull(ISNULL(e.SpeedLimit, es.SpeedLimit))) - 100 > @thpercent
			AND ROUND(e.Speed * @speedmult, 0, 1) > ISNULL(e.SpeedLimit, es.SpeedLimit) + @thvalue
			/* !! ## DO NOT DEPLOY ## !!! */
			/* !! ## FOR TRIAL ONLY ## !!! */
			AND CAST(e.Speed * @speedmult AS INT) > 90
	ORDER BY e.EventDateTime ASC
END



GO
