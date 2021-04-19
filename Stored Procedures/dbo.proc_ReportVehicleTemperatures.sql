SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_ReportVehicleTemperatures]
(
	@uid UNIQUEIDENTIFIER
)
AS

--DECLARE @uid UNIQUEIDENTIFIER;
--SET @uid = 'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'

DECLARE @timediff NVARCHAR(30),
		@curUtcDate DATETIME,
		@vid UNIQUEIDENTIFIER,
		@date DATETIME,
		@queryTime DATETIME,
		@tempmult FLOAT,
		@liquidmult FLOAT,
		@tempunit NVARCHAR(5)

SET @timediff = dbo.UserPref(@uid, 600)
SET @tempmult = ISNULL(dbo.UserPref(@uid, 214),1)
SET @liquidmult = ISNULL(dbo.UserPref(@uid, 200),1)
SET @curUtcDate = GETUTCDATE()
SET @queryTime = dbo.TZ_GetTime(@curUtcDate, @timediff, @uid)
SET @tempunit = ISNULL(dbo.UserPref(@uid, 215),'°C')

SELECT
	g.GroupName,
	v.Registration,
	dbo.TZ_GetTime( vle.EventDateTime, @timediff, @uid) AS EventDateTime,
	@queryTime AS QueryTime,
	dbo.GetScaleConvertAnalogValue(vle.AnalogData0, 0, vle.VehicleId, @tempmult, @liquidmult) AS AnalogData0,
	vs1.Description AS Name1,
	dbo.GetScaleConvertAnalogValue(vle.AnalogData1, 1, vle.VehicleId, @tempmult, @liquidmult) AS AnalogData1,
	vs2.Description AS Name2,
	dbo.GetScaleConvertAnalogValue(vle.AnalogData2, 2, vle.VehicleId, @tempmult, @liquidmult) AS AnalogData2,
	vs3.Description AS Name3,
	dbo.GetScaleConvertAnalogValue(vle.AnalogData3, 3, vle.VehicleId, @tempmult, @liquidmult) AS AnalogData3,
	vs4.Description AS Name4,
	@tempunit AS TempUnit
FROM dbo.VehicleLatestAllEvent vle
INNER JOIN dbo.Vehicle v ON vle.VehicleId = v.VehicleId
INNER JOIN dbo.GroupDetail gd ON v.VehicleId = gd.EntityDataId
INNER JOIN dbo.[Group] g ON gd.GroupId = g.GroupId
LEFT JOIN dbo.VehicleSensor vs1 ON v.VehicleIntId = vs1.VehicleIntId AND vs1.SensorId = 1 AND vs1.Enabled = 1
LEFT JOIN dbo.VehicleSensor vs2 ON v.VehicleIntId = vs2.VehicleIntId AND vs2.SensorId = 2 AND vs2.Enabled = 1
LEFT JOIN dbo.VehicleSensor vs3 ON v.VehicleIntId = vs3.VehicleIntId AND vs3.SensorId = 3 AND vs3.Enabled = 1
LEFT JOIN dbo.VehicleSensor vs4 ON v.VehicleIntId = vs4.VehicleIntId AND vs4.SensorId = 4 AND vs4.Enabled = 1
INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
INNER JOIN dbo.[User] u ON c.CustomerId = u.CustomerID
INNER JOIN dbo.UserGroup ug ON g.GroupId = ug.GroupId AND ug.UserId = u.UserID
WHERE u.UserID = @uid
  AND v.Archived = 0
  AND v.IVHId IS NOT NULL
  AND g.GroupTypeId = 1
  AND g.IsParameter = 0
  AND g.Archived = 0
  AND ug.Archived = 0
ORDER BY g.GroupName, v.Registration
GO
