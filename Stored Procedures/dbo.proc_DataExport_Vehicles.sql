SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_DataExport_Vehicles]
(
	@cid UNIQUEIDENTIFIER,
	@uid UNIQUEIDENTIFIER
)
AS

--DECLARE @cid UNIQUEIDENTIFIER,
--		@uid UNIQUEIDENTIFIER

--SET @uid = N'EE221130-FCEE-4CA4-88C5-052FA7FE7BDE'

DECLARE @timezone VARCHAR(255)

SELECT  @timezone = dbo.UserPref(@uid, 600)

SELECT 
	c.Name AS CustomerName,
	
	STUFF((SELECT DISTINCT '; ' + g.GroupName
            FROM dbo.[User] u
				INNER JOIN dbo.UserGroup ug ON u.UserID = ug.UserId
				INNER JOIN dbo.[Group] g ON g.GroupId = ug.GroupId
				INNER JOIN dbo.GroupDetail gd ON ug.GroupId = gd.GroupId
				INNER JOIN dbo.Vehicle veh ON gd.EntityDataId = veh.VehicleId
            WHERE veh.VehicleId = v.VehicleId
				AND g.Archived = 0 AND g.IsParameter = 0 AND g.GroupTypeId = 1
				AND u.UserID = @uid
            FOR XML PATH('')),1,1,''
    ) AS Groups,
	
	v.Registration,
	v.FleetNumber,
	v.MakeModel,
	v.BodyManufacturer AS Manufacturer,
	v.BodyType,
	v.ChassisNumber AS Chassis,
	v.IsCAN,
	ISNULL(vt.Name, 'Unknown') AS VehicleType,

	i.TrackerNumber,
	it.Name AS TrackerType,
	i.Manufacturer AS Manufacturer1,
	i.Model,
	i.SerialNumber,
	i.PhoneNumber,
	i.SIMCardNumber AS SIMNumber,
	i.ServiceProvider,
	i.FirmwareVersion,
		
	[dbo].[TZ_GetTime](vle.EventDateTime, @timezone, @uid) AS LastPoll,
	
	(
		SELECT COUNT(*) 
		FROM dbo.VehicleSensor vs 
			INNER JOIN dbo.Sensor s ON vs.SensorId = s.SensorId
		WHERE v.VehicleIntId = vs.VehicleIntId AND vs.Enabled = 1 AND s.SensorType = 'A'
	 ) AS SensorsA,
	 
	 (
		SELECT COUNT(*) 
		FROM dbo.VehicleSensor vs 
			INNER JOIN dbo.Sensor s ON vs.SensorId = s.SensorId
		WHERE v.VehicleIntId = vs.VehicleIntId AND vs.Enabled = 1 AND s.SensorType = 'D'
	 ) AS SensorsD,
	 
	 d.Surname + ' ' + d.FirstName AS AssignedDriver,

	 ISNULL(cam.Serial, '') AS CameraNr
	 
FROM dbo.Vehicle v
	LEFT OUTER JOIN dbo.VehicleCamera vc ON vc.VehicleId = v.VehicleId AND vc.Archived = 0 AND vc.EndDate IS NULL
	LEFT OUTER JOIN dbo.Camera cam ON cam.CameraId = vc.CameraId AND cam.Archived = 0
	LEFT OUTER JOIN dbo.VehicleDriver vd ON v.VehicleId = vd.VehicleId 
														 AND vd.Archived = 0
	LEFT OUTER JOIN dbo.Driver d ON vd.DriverId = d.DriverId
	LEFT OUTER JOIN dbo.VehicleLatestEvent vle ON v.VehicleId = vle.VehicleId
	LEFT OUTER JOIN dbo.IVH i ON v.IVHId = i.IVHId
	LEFT OUTER JOIN dbo.IVHType it ON i.IVHTypeId = it.IVHTypeId
	LEFT OUTER JOIN dbo.VehicleType vt ON vt.VehicleTypeID = v.VehicleTypeID
	INNER JOIN dbo.GroupDetail gd ON gd.EntityDataId = v.VehicleId
	INNER JOIN dbo.[Group] g ON gd.GroupId = g.GroupId
	INNER JOIN dbo.UserGroup ug ON g.GroupId = ug.GroupId
	INNER JOIN dbo.[User] u ON ug.UserId = u.UserID
	INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
	INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId AND c.CustomerId = u.CustomerID
WHERE u.UserID = @uid
	AND v.Archived = 0 
GROUP BY c.Name, v.VehicleIntId, v.VehicleId, v.Registration, v.MakeModel, v.BodyManufacturer, v.BodyType, v.ChassisNumber, v.IsCAN, vt.Name, i.TrackerNumber, it.Name, i.Manufacturer,
	i.Model, i.SerialNumber, i.PhoneNumber, i.SIMCardNumber, i.ServiceProvider, i.FirmwareVersion, vle.EventDateTime, d.Surname, d.FirstName, v.FleetNumber, v.VehicleTypeID,
	cam.Serial
ORDER BY c.Name, v.Registration


GO
