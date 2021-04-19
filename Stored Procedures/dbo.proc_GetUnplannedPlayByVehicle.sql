SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_GetUnplannedPlayByVehicle]
(
	@vid UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME,
	@uid UNIQUEIDENTIFIER
)
AS

--DECLARE @vid UNIQUEIDENTIFIER,
--		@sdate DATETIME,
--		@edate DATETIME,
--		@uid UNIQUEIDENTIFIER
--SET @vid = N'909FB8A2-A973-4253-99C1-03EAF670C13B'
--SET @sdate = '2016-01-01 00:00'
--SET @edate = '2016-12-31 23:59'
--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'

-- Convert sdate and edate to UTC
SET @sdate = dbo.TZ_ToUtc(@sdate, DEFAULT, @uid)
SET @edate = dbo.TZ_ToUtc(@edate, DEFAULT, @uid)

-- Identify the timezone for the vehicle, but use customer timezone if none present. Default to GMT_Time if necessary
DECLARE @timezone VARCHAR(35)
SELECT @timezone = ISNULL(ISNULL(vtz.TimeZoneName, ctz.TimeZoneName), 'GMT Time')
FROM dbo.Vehicle v
INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
LEFT JOIN dbo.VehicleWorkingHours w ON v.VehicleIntId = w.VehicleIntId
LEFT JOIN dbo.CustomerPreference cp ON cp.CustomerID = cv.CustomerId AND cp.NameID = 3004
LEFT JOIN dbo.TZ_TimeZones vtz ON vtz.TimeZoneId = w.TimeZoneId
LEFT JOIN dbo.TZ_TimeZones ctz ON ctz.TimeZoneId = w.TimeZoneId
WHERE v.VehicleId = @vid
	AND cv.EndDate IS NULL
    AND cv.Archived = 0

SELECT	up.VehicleUnplannedPlayId,
		v.VehicleId,
		v.VehicleTypeID,
		v.Registration,
		dbo.TZ_GetTime(up.PlayStartDateTime, @timezone, NULL) AS PlayStartDateTime,
		dbo.TZ_GetTime(up.PlayEndDateTime, @timezone, NULL) AS PlayEndDateTime,
		@timezone AS Timezone,
		up.Reason,
		u.UserID,
		u.Name AS UserName
FROM dbo.VehicleUnplannedPlay up
INNER JOIN dbo.Vehicle v ON v.VehicleIntId = up.VehicleIntId
INNER JOIN dbo.[User] u ON u.UserID = up.UserId
WHERE v.VehicleId = @vid
  AND up.PlayStartDateTime BETWEEN @sdate AND @edate
  AND up.Archived = 0
ORDER BY up.PlayStartDateTime DESC	
GO
