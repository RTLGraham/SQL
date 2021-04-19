SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_SetUnplannedPlay]
(
	@vid UNIQUEIDENTIFIER, 
	@start DATETIME, 
	@end DATETIME, 
	@reason NVARCHAR(MAX)=NULL, 
	@uid UNIQUEIDENTIFIER
)
AS

--DECLARE @vid UNIQUEIDENTIFIER,
--		@start DATETIME,
--		@end DATETIME,
--		@reason NVARCHAR(MAX),
--		@uid UNIQUEIDENTIFIER 
--SET @vid = N'909FB8A2-A973-4253-99C1-03EAF670C13B'
--SET @start = '2016-01-01 00:00'
--SET @end = '2016-01-08 23:59'
--SET @reason = 'Holiday'
--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'

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

INSERT INTO dbo.VehicleUnplannedPlay (VehicleIntId, PlayStartDateTime, PlayEndDateTime, Reason, UserId, LastOperation)
SELECT	v.VehicleIntId,
		dbo.TZ_ToUtc(@start, @timezone, NULL),
		dbo.TZ_ToUtc(@end, @timezone, NULL),
		@reason,
		@uid,
		GETDATE()
FROM dbo.Vehicle v
WHERE v.VehicleId = @vid

GO
