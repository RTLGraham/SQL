SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportTemperatureCheckout]
    (
      @vids VARCHAR(MAX),
      @uid UNIQUEIDENTIFIER,
      @sdate DATETIME,
	  @edate DATETIME
    )
AS 

BEGIN	

	--DECLARE	@vids VARCHAR(MAX),
	--		@uid UNIQUEIDENTIFIER,
	--		@sdate DATETIME,
	--		@edate DATETIME

	--SET @vids = N'87A3B70E-9B8D-42CB-BB13-2E1C9427331C,486A43F1-70D9-46CC-A745-542B6A4D77CE'
	--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
	--SET @sdate = '2020-05-01 00:00'
	--SET @edate = '2020-06-30 23:59'

	DECLARE	@lvids VARCHAR(MAX),
			@luid UNIQUEIDENTIFIER,
			@lsdate DATETIME,
			@ledate DATETIME

	SET @lvids = @vids
	SET @luid = @uid
	SET @lsdate = @sdate
	SET @ledate = @edate

	DECLARE @stime DATETIME,
			@etime DATETIME

	SET @lsdate = dbo.TZ_ToUtc(@lsdate,DEFAULT,@luid) 
	SET @ledate = dbo.TZ_ToUtc(@ledate,DEFAULT,@luid)
   
	-- Set 'real' departure and return time limits
	-- Use today's date so that DST time conversion is applied p[roperly
	SET @stime = dbo.TZ_ToUtc(CAST(CONVERT(VARCHAR(11), GETDATE(), 120) + '05:00' AS DATETIME), DEFAULT, @luid)
	SET @etime = dbo.TZ_ToUtc(CAST(CONVERT(VARCHAR(11), GETDATE(), 120) + '20:00' AS DATETIME), DEFAULT, @luid)
	-- Now convert to 1900-01-01 date so that time comparisons using FLOOR will function correctly later
	SET @stime = '1900-01-01 ' + CONVERT(VARCHAR(5), @stime, 114)
	SET @etime = '1900-01-01 ' + CONVERT(VARCHAR(5), @etime, 114)

	DECLARE @tempmult FLOAT,
		@liquidmult FLOAT
	SET @tempmult = ISNULL(.[dbo].[UserPref](@luid, 214), 1)
	SET @liquidmult = ISNULL(.[dbo].[UserPref](@luid, 200), 1)
	
-- Create a table of vehicles and associated static data
	DECLARE @Vehicle TABLE
	(
		VehicleId UNIQUEIDENTIFIER,
		VehicleIntId INT,
		Registration NVARCHAR(MAX),
		Analog2Scaling FLOAT
	)
	INSERT INTO @Vehicle (VehicleId, VehicleIntId, Registration, Analog2Scaling)
	SELECT v.VehicleId, v.VehicleIntId, v.Registration, vs2.AnalogSensorScaleFactor
	FROM dbo.Vehicle v
	LEFT JOIN dbo.VehicleSensor vs2 ON v.VehicleIntId = vs2.VehicleIntId AND vs2.SensorId = 2
	WHERE v.VehicleId IN (SELECT VALUE FROM dbo.Split(@lvids, ','))

	DECLARE @Checkout TABLE
    (
		CheckOutId INT IDENTITY (1,1),
		VehicleId UNIQUEIDENTIFIER,
		CheckOutDateTime DATETIME,
		CheckOutUserId UNIQUEIDENTIFIER,
		CheckOutReason NVARCHAR(MAX),
		CheckInDateTime DATETIME
	)

	INSERT INTO @Checkout (VehicleId, CheckOutDateTime, CheckOutUserId, CheckOutReason, CheckInDateTime)
	SELECT v.VehicleId, tec.CheckOutDateTime, tec.CheckOutUserId, tec.CheckOutReason, tec.CheckInDateTime
	FROM dbo.TAN_EntityCheckOut tec
	INNER JOIN @Vehicle v ON tec.EntityId = v.VehicleId
	WHERE @lsdate BETWEEN tec.CheckOutDateTime AND ISNULL(tec.CheckInDateTime, '2199-12-31 23:59')
	   OR @ledate BETWEEN tec.CheckOutDateTime AND ISNULL(tec.CheckInDateTime, '2199-12-31 23:59')
	   OR tec.CheckOutDateTime BETWEEN @lsdate AND @ledate
	   OR (tec.CheckInDateTime IS NULL AND tec.CheckOutDateTime BETWEEN @lsdate AND @ledate)

	-- Create a temporary table for real geofence exits / entries for the required vehicles
	DECLARE @RealTrips TABLE
	(
		CheckOutId INT,
		VehicleIntId INT,
		GeofenceId UNIQUEIDENTIFIER,
		ExitDateTime DATETIME,
		ExitEventId BIGINT,
		EntryDateTime DATETIME,
		EntryEventId BIGINT,
		ExitSeconds INT,
		OverLimitDuration INT,
		RowNum INT
	)

	INSERT INTO @RealTrips (CheckOutId, VehicleIntId, GeofenceId, ExitDateTime, ExitEventId, EntryDateTime, EntryEventId, ExitSeconds, RowNum)
	SELECT DISTINCT gexit.CheckOutId, gexit.VehicleIntId AS vehicleIntId, gexit.GeofenceId AS GeofenceId, gexit.ExitDateTime, gexit.ExitEventId, gentry.EntryDateTime, gentry.EntryEventId, DATEDIFF(ss, gexit.ExitDateTime, gentry.EntryDateTime) AS ExitSeconds, ROW_NUMBER() OVER(PARTITION BY gexit.CheckOutId ORDER BY gexit.ExitDateTime)
	FROM

		(SELECT ROW_NUMBER() OVER (PARTITION BY c.CheckOutId, vgh.VehicleIntId, vgh.GeofenceId ORDER BY vgh.EntryDateTime) AS RowNum, c.CheckOutId, vgh.VehicleIntId, vgh.GeofenceId, vgh.ExitDateTime, vgh.ExitEventId
		FROM dbo.VehicleGeofenceHistory vgh
		INNER JOIN dbo.Geofence geo ON geo.GeofenceId = vgh.GeofenceId AND geo.IsTemperatureMonitored = 1
		INNER JOIN @Vehicle v ON v.VehicleIntId = vgh.VehicleIntId
		INNER JOIN @Checkout c ON c.VehicleId = v.VehicleId
		WHERE EntryDateTime BETWEEN c.CheckOutDateTime AND c.CheckInDateTime OR ExitDateTime BETWEEN c.CheckOutDateTime AND c.CheckInDateTime
		  ) gexit
	  
	INNER JOIN 

		(SELECT ROW_NUMBER() OVER (PARTITION BY c.CheckOutId, vgh.VehicleIntId, vgh.GeofenceId ORDER BY EntryDateTime) AS RowNum, c.CheckOutId, vgh.VehicleIntId, vgh.GeofenceId, vgh.EntryDateTime, vgh.EntryEventId
		FROM dbo.VehicleGeofenceHistory vgh
		INNER JOIN dbo.Geofence geo ON geo.GeofenceId = vgh.GeofenceId AND geo.IsTemperatureMonitored = 1
		INNER JOIN @Vehicle v ON v.VehicleIntId = vgh.VehicleIntId
		INNER JOIN @Checkout c ON c.VehicleId = v.VehicleId
		WHERE EntryDateTime BETWEEN c.CheckOutDateTime AND c.CheckInDateTime OR ExitDateTime BETWEEN c.CheckOutDateTime AND c.CheckInDateTime
		  ) gentry ON gexit.VehicleIntId = gentry.VehicleIntId AND gexit.GeofenceId = gentry.GeofenceId AND gentry.RowNum = gexit.RowNum + 1
	  
	INNER JOIN @Vehicle v ON v.VehicleIntId = gexit.VehicleIntId
	WHERE DATEDIFF(ss, gexit.ExitDateTime, gentry.EntryDateTime) BETWEEN 2700 AND 43200 -- Real trips are between 30mins and 12 hours in duration
	  AND CAST(gexit.ExitDateTime AS FLOAT) - FLOOR(CAST(gexit.ExitDateTime AS FLOAT)) > CAST(@stime AS FLOAT)
	  AND CAST(gentry.EntryDateTime AS FLOAT) - FLOOR(CAST(gentry.EntryDateTime AS FLOAT)) < CAST(@etime AS FLOAT)

	-- Now remove all but the first real trip per checkout
	DELETE
    FROM @RealTrips
	WHERE RowNum != 1

	SELECT	v.VehicleId,
			v.Registration,
			dbo.TZ_GetTime(c.CheckOutDateTime, DEFAULT, @uid) AS CheckOutDateTime,
			dbo.FormatUserNameByUser(c.CheckOutUserId, @uid) AS CheckOutUserName,
			c.CheckOutReason,
			dbo.TZ_GetTime(c.CheckInDateTime, DEFAULT, @uid) AS CheckInDateTime,
			(ein.OdoGPS - eout.OdoGPS) / 1000.0 AS Distance,
			DATEDIFF(MINUTE, eout.EventDateTime, ein.EventDateTime) AS OutsideDurationMins,
			dbo.ScaleConvertAnalogValue(ein.AnalogData1, v.Analog2Scaling, @tempmult, @liquidmult) AS FirstEntryTemperature,
			dbo.TZ_GetTime(ein.EventDateTime, DEFAULT, @uid) AS FirstEntryDateTime,
			rt.OverLimitDuration
	FROM @Checkout c
	INNER JOIN @Vehicle v ON v.VehicleId = c.VehicleId
	LEFT JOIN @RealTrips rt ON rt.CheckOutId = c.CheckOutId
	LEFT JOIN dbo.Event eout ON eout.EventId = rt.ExitEventId
	LEFT JOIN dbo.Event ein ON ein.EventId = rt.EntryEventId
	ORDER BY CheckOutDateTime

END
    

GO
