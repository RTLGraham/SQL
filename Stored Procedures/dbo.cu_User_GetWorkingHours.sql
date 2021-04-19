SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[cu_User_GetWorkingHours]
    (
      @userId UNIQUEIDENTIFIER
    )
AS 

	--DECLARE @userid UNIQUEIDENTIFIER
	--SET @userid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'

	-- Get the timezone of the customer if known. Otherwise use GMT Time as the default timezone.
	DECLARE @timezone VARCHAR(30),
			@timezoneid INT

	SELECT @timezone = ISNULL(cp.Value, 'GMT Time'), @timezoneid = ISNULL(tz.TimeZoneId, 85)
	FROM dbo.[User] u
	LEFT JOIN dbo.CustomerPreference cp ON cp.CustomerID = u.CustomerID AND cp.NameID = 3004
	LEFT JOIN dbo.TZ_TimeZones tz ON cp.Value = tz.TimeZoneName
	WHERE u.UserID = @userid
	
	SELECT  dbo.TZ_GetTimeNoDaylightSavings(w.MonStart,@timezone,NULL) AS MonStart,
	        dbo.TZ_GetTimeNoDaylightSavings(w.MonEnd,@timezone,NULL) AS MonEnd,
	        dbo.TZ_GetTimeNoDaylightSavings(w.TueStart,@timezone,NULL) AS TueStart,
	        dbo.TZ_GetTimeNoDaylightSavings(w.TueEnd,@timezone,NULL) AS TueEnd,
	        dbo.TZ_GetTimeNoDaylightSavings(w.WedStart,@timezone,NULL) AS WedStart,
	        dbo.TZ_GetTimeNoDaylightSavings(w.WedEnd,@timezone,NULL) AS WedEnd,
	        dbo.TZ_GetTimeNoDaylightSavings(w.ThuStart,@timezone,NULL) AS ThuStart,
	        dbo.TZ_GetTimeNoDaylightSavings(w.ThuEnd,@timezone,NULL) AS ThuEnd,
	        dbo.TZ_GetTimeNoDaylightSavings(w.FriStart,@timezone,NULL) AS FriStart,
	        dbo.TZ_GetTimeNoDaylightSavings(w.FriEnd,@timezone,NULL) AS FriEnd,
	        dbo.TZ_GetTimeNoDaylightSavings(w.SatStart,@timezone,NULL) AS SatStart,
	        dbo.TZ_GetTimeNoDaylightSavings(w.SatEnd,@timezone,NULL) AS SatEnd,
	        dbo.TZ_GetTimeNoDaylightSavings(w.SunStart,@timezone,NULL) AS SunStart,
	        dbo.TZ_GetTimeNoDaylightSavings(w.SunEnd,@timezone,NULL) AS SunEnd,
			@TimezoneId
	FROM dbo.WorkingHours w
	INNER JOIN dbo.[User] u ON w.CustomerId = u.CustomerID
	WHERE u.UserID = @userid


GO
