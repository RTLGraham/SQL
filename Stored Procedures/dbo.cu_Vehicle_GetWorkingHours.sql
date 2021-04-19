SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[cu_Vehicle_GetWorkingHours]
    (
	  @vehicleid UNIQUEIDENTIFIER
    )
AS 

	--DECLARE @vehicleid UNIQUEIDENTIFIER
	--SET @vehicleid = N'EBE7CEB3-6571-4460-B44B-71597C846C5B'

	-- Get the timezone of the vehicle if known. Otherwise use the default timezone of the customer. Use GMT Time as overall default.
	DECLARE @timezone VARCHAR(30),
			@timezoneid INT

	SELECT @timezone = ISNULL(ISNULL(vtz.TimeZoneName, ctz.TimeZoneName), 'GMT Time'), @timezoneid = ISNULL(ISNULL(vtz.TimeZoneId, ctz.TimeZoneId), 85)
	FROM dbo.Vehicle v
	INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
	LEFT JOIN dbo.VehicleWorkingHours w ON v.VehicleIntId = w.VehicleIntId
	LEFT JOIN dbo.CustomerPreference cp ON cp.CustomerID = cv.CustomerId AND cp.NameID = 3004
	LEFT JOIN dbo.TZ_TimeZones vtz ON vtz.TimeZoneId = w.TimeZoneId
	LEFT JOIN dbo.TZ_TimeZones ctz ON ctz.TimeZoneId = w.TimeZoneId
	WHERE v.VehicleId = @vehicleid
	  AND cv.EndDate IS NULL
      AND cv.Archived = 0
	
	--SELECT  dbo.TZ_GetTimeNoDaylightSavings(w.MonStart,@timezone,NULL) AS MonStart,
	--        dbo.TZ_GetTimeNoDaylightSavings(w.MonEnd,@timezone,NULL) AS MonEnd,
	--        dbo.TZ_GetTimeNoDaylightSavings(w.TueStart,@timezone,NULL) AS TueStart,
	--        dbo.TZ_GetTimeNoDaylightSavings(w.TueEnd,@timezone,NULL) AS TueEnd,
	--        dbo.TZ_GetTimeNoDaylightSavings(w.WedStart,@timezone,NULL) AS WedStart,
	--        dbo.TZ_GetTimeNoDaylightSavings(w.WedEnd,@timezone,NULL) AS WedEnd,
	--        dbo.TZ_GetTimeNoDaylightSavings(w.ThuStart,@timezone,NULL) AS ThuStart,
	--        dbo.TZ_GetTimeNoDaylightSavings(w.ThuEnd,@timezone,NULL) AS ThuEnd,
	--        dbo.TZ_GetTimeNoDaylightSavings(w.FriStart,@timezone,NULL) AS FriStart,
	--        dbo.TZ_GetTimeNoDaylightSavings(w.FriEnd,@timezone,NULL) AS FriEnd,
	--        dbo.TZ_GetTimeNoDaylightSavings(w.SatStart,@timezone,NULL) AS SatStart,
	--        dbo.TZ_GetTimeNoDaylightSavings(w.SatEnd,@timezone,NULL) AS SatEnd,
	--        dbo.TZ_GetTimeNoDaylightSavings(w.SunStart,@timezone,NULL) AS SunStart,
	--        dbo.TZ_GetTimeNoDaylightSavings(w.SunEnd,@timezone,NULL) AS SunEnd,
	--		@timezoneid AS Timezone
	--FROM dbo.VehicleWorkingHours w
	--INNER JOIN dbo.Vehicle v ON v.VehicleIntId = w.VehicleIntId
	--WHERE v.VehicleId = @vehicleid

	SELECT  w.MonStart AS MonStart,
	        w.MonEnd AS MonEnd,
	        w.TueStart AS TueStart,
	        w.TueEnd AS TueEnd,
	        w.WedStart AS WedStart,
	        w.WedEnd AS WedEnd,
	        w.ThuStart AS ThuStart,
	        w.ThuEnd AS ThuEnd,
	        w.FriStart AS FriStart,
	        w.FriEnd AS FriEnd,
	        w.SatStart AS SatStart,
	        w.SatEnd AS SatEnd,
	        w.SunStart AS SunStart,
	        w.SunEnd AS SunEnd,
			@timezoneid AS Timezone
	FROM dbo.VehicleWorkingHours w
	INNER JOIN dbo.Vehicle v ON v.VehicleIntId = w.VehicleIntId
	WHERE v.VehicleId = @vehicleid


GO
