SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportMaintenanceHealthCheckByDate_Simplified]
    (
      @vids VARCHAR(MAX) = NULL,
      @uid UNIQUEIDENTIFIER,
      @date DATETIME = NULL
    )
AS 
SET NOCOUNT ON

--	DECLARE @vids varchar(max),
--			@uid UNIQUEIDENTIFIER,
--			@date DATETIME

----	SET @vids = N'8016F50D-A2D1-49A9-BC1E-13AE27953390,486A43F1-70D9-46CC-A745-542B6A4D77CE,5DE385BF-BFCB-4179-90CB-5AEE460B14AD,67B44E7F-6A0E-42E0-9DCF-5DDCA2AF502E,2C1A82DE-6DCB-4D03-BC21-5F65198B9A84,DB3AC174-1CFE-404C-914B-6BE9DB1B7038,D075F7EF-C02E-46E4-91C3-8191F2167F59,6CD1331B-F7FC-4866-A333-8FEE45667F33,91D26E73-DBD4-45DA-935C-997766C44AA2,3708F23A-F7CA-44F0-BB96-A94E80C40DFF'
----	SET @vids = N'8016F50D-A2D1-49A9-BC1E-13AE27953390,486A43F1-70D9-46CC-A745-542B6A4D77CE,5DE385BF-BFCB-4179-90CB-5AEE460B14AD,67B44E7F-6A0E-42E0-9DCF-5DDCA2AF502E,2C1A82DE-6DCB-4D03-BC21-5F65198B9A84,DB3AC174-1CFE-404C-914B-6BE9DB1B7038,D075F7EF-C02E-46E4-91C3-8191F2167F59,6CD1331B-F7FC-4866-A333-8FEE45667F33,91D26E73-DBD4-45DA-935C-997766C44AA2,3708F23A-F7CA-44F0-BB96-A94E80C40DFF'
--	SET @vids = NULL
--	SET @uid = N'66726073-4763-46BD-847A-DABFA92F23B5'
--	SET @date = NULL
	
	IF @date IS NULL
		SET @date = DATEADD(dd, -1, GETUTCDATE())
		
	SET @date = CAST(FLOOR(CAST(@date AS FLOAT)) AS DATETIME)

	DECLARE @vehicles TABLE
	(
		VehicleId UNIQUEIDENTIFIER,
		VehicleintId INT
	)

	IF @vids IS NULL OR @vids = ''
	BEGIN
		--run for all vehicles
		INSERT INTO @vehicles (VehicleId, VehicleintId)
		SELECT DISTINCT v.VehicleId, v.VehicleIntId
		FROM dbo.Vehicle v
			INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
			INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
		WHERE v.Archived = 0 AND cv.Archived = 0 AND cv.EndDate IS NULL AND c.Archived = 0 AND v.IVHId IS NOT NULL
			AND c.Name != 'Default Customer'
	END
	ELSE BEGIN
		INSERT INTO @vehicles (VehicleId, VehicleintId)
		SELECT DISTINCT v.VehicleId, v.VehicleIntId
		FROM dbo.Vehicle v
		INNER JOIN (SELECT Value AS VehicleId
					FROM dbo.Split(@vids, ',')) veh ON v.VehicleId = veh.VehicleId
	END
	

	DECLARE @diststr varchar(20),
			@distmult float

	SELECT @diststr = [dbo].UserPref(@uid, 203)
	SELECT @distmult = [dbo].UserPref(@uid, 202)
	
	SELECT c.Name AS CustomerName,
			v.VehicleId,
			v.Registration,
			v.VehicleTypeID,
			i.FirmwareVersion,
			m.SS1,
			m.DaysSincePoll AS daysNotPolled,
			vle.EventDateTime AS LastPoll,
			vle.Lat AS PollLat,
			vle.Long AS PollLon,
			'Unknown' as PollLocation,
			CASE WHEN m.TANCheckOut IS NOT NULL THEN 1 ELSE 0 END AS IsCheckedOut,
			m.TANCheckout AS CheckOutReason,
			m.Ignition,
			m.GPSDriveDistance AS OdoGPS,
			m.DriverIdInUse AS DriverIdCount,
			m.CANDriveDistance - m.CANDriveDistanceNoID AS IdDistance,
			CASE WHEN m.CANDriveDistanceNoID < 10 THEN NULL ELSE m.CANDriveDistanceNoId END AS NoIdDistance,
			NULL AS NoIdLatestTime,	
			CASE WHEN ISNULL(m.CANDriveDistance, 0) = 0 THEN NULL ELSE CASE WHEN m.CANDriveDistance / CASE WHEN m.GPSDriveDistance = 0 THEN NULL ELSE m.GPSDriveDistance END BETWEEN 0.9 AND 1.1 THEN 1 ELSE 0 END END AS CAN,
			m.DrivingFuel,
			m.iButton,
			m.Tacho,
			m.CheetahFaults,
			m.SS1Faults,		
			CASE WHEN ISNULL(m.Sensor01,0) = 1 THEN 'Active' ELSE 'Inactive' END AS Sensor01,
			CASE WHEN ISNULL(m.Sensor02,0) = 1 THEN 'Active' ELSE 'Inactive' END AS Sensor02,
			CASE WHEN ISNULL(m.Sensor03,0) = 1 THEN 'Active' ELSE 'Inactive' END AS Sensor03,
			CASE WHEN ISNULL(m.Sensor04,0) = 1 THEN 'Active' ELSE 'Inactive' END AS Sensor04,
			CASE WHEN m.T0 = 0 THEN 1 ELSE 0 END AS Sensor01Faults,
			CASE WHEN m.T1 = 0 THEN 1 ELSE 0 END AS Sensor02Faults,
			CASE WHEN m.T2 = 0 THEN 1 ELSE 0 END AS Sensor03Faults,
			CASE WHEN m.T3 = 0 THEN 1 ELSE 0 END AS Sensor04Faults,
			m.MaxDataAgeMins AS LateData,
			CAST(m.MinExternalVoltage AS FLOAT) / 2 AS MinBatteryVoltage,
			ISNULL(m.TXFails, 0) AS TXFails,
			ISNULL(m.GPRSRetries ,0) AS GPRSRetries	
	FROM dbo.Maintenance m 
		INNER JOIN @Vehicles veh ON m.VehicleIntId = veh.VehicleIntId
		LEFT OUTER JOIN dbo.VehicleCamera vc ON vc.VehicleId = veh.VehicleId
		LEFT OUTER JOIN dbo.Camera cam ON cam.CameraId = vc.CameraId
		INNER JOIN dbo.VehicleLatestAllEvent vle ON vle.VehicleId = veh.VehicleId
		INNER JOIN dbo.Vehicle v ON v.VehicleId = veh.vehicleId	
		INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
		INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
		LEFT OUTER JOIN dbo.IVH i ON m.IVHIntId = i.IVHIntId
	WHERE m.Date = @date
	  AND cv.Archived = 0
	  AND (cam.Serial IS NOT NULL OR i.TrackerNumber IS NOT NULL)
	ORDER BY m.DaysSincePoll DESC, v.Registration ASC


GO
