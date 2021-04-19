SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportMaintenanceHealthCheckByDate]
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
--	SET @vids = NULL--N'8016F50D-A2D1-49A9-BC1E-13AE27953390,486A43F1-70D9-46CC-A745-542B6A4D77CE,5DE385BF-BFCB-4179-90CB-5AEE460B14AD,67B44E7F-6A0E-42E0-9DCF-5DDCA2AF502E,2C1A82DE-6DCB-4D03-BC21-5F65198B9A84,DB3AC174-1CFE-404C-914B-6BE9DB1B7038,D075F7EF-C02E-46E4-91C3-8191F2167F59,6CD1331B-F7FC-4866-A333-8FEE45667F33,91D26E73-DBD4-45DA-935C-997766C44AA2,3708F23A-F7CA-44F0-BB96-A94E80C40DFF'
--	set @vids = N'AB2E895D-CB6F-4BD9-8CF1-71E976E6F335,BF808915-A86D-4EB8-9804-C64375223662'
--	SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
--	SET @date = NULL--'2015-10-21'
	
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

	SELECT	c.Name AS CustomerName,
			v.VehicleId,
			v.Registration,
			v.VehicleTypeID,
			i.FirmwareVersion,
			m.SS1,
			m.DaysSincePoll AS daysNotPolled,
			CASE WHEN @uid IS NOT NULL THEN dbo.TZ_GetTime(vlae.EventDateTime, DEFAULT, @uid) ELSE vlae.EventDateTime END AS LastPoll,
			vlae.Lat AS PollLat,
			vlae.Long AS PollLon,
			dbo.GetGeofenceNameFromLongLat (vle.Lat, vle.Long, @uid, dbo.GetAddressFromLongLat(vle.Lat, vle.Long)) as PollLocation,
			CASE WHEN m.TANCheckOut IS NOT NULL THEN 1 ELSE 0 END AS IsCheckedOut,
			m.TANCheckout AS CheckOutReason,
			m7.Ignition,
			m7.GPSDriveDistance AS OdoGPS,
			m7.DriverIdInUse AS DriverIdCount,
			dbo.ZeroYieldNull(m.CANDriveDistance - m.CANDriveDistanceNoID) AS IdDistance,
			CASE WHEN dbo.ZeroYieldNull(m.CANDriveDistanceNoID) < 10 THEN NULL ELSE dbo.ZeroYieldNull(m.CANDriveDistanceNoID) END AS NoIdDistance,
			NULL AS NoIdLatestTime,	
			--CASE WHEN ISNULL(m7.CANDriveDistance, 0) = 0 THEN NULL ELSE CASE WHEN m7.CANDriveDistance / CASE WHEN m7.GPSDriveDistance = 0 THEN NULL ELSE m7.GPSDriveDistance END BETWEEN 0.9 AND 1.1 THEN 1 ELSE 0 END END AS CAN,
			CASE WHEN ISNULL(m7.GPSDriveDistance, 0) = 0 THEN NULL ELSE CASE WHEN ISNULL(m7.AverageRPM,0) > 0 AND ISNULL(m7.ConsumedFuel,0) > 0 THEN 1 ELSE CASE WHEN ISNULL(m7.AverageRPM,0) = 0 AND ISNULL(m7.ConsumedFuel,0) = 0 THEN 0 ELSE NULL END END END AS CAN,
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
			ISNULL(m7.TXFails, 0) AS TXFails,
			ISNULL(m7.GPRSRetries ,0) AS GPRSRetries								
	FROM dbo.Maintenance m
	INNER JOIN @Vehicles veh ON m.VehicleIntId = veh.VehicleIntId
	INNER JOIN dbo.Vehicle v ON v.VehicleId = veh.vehicleId	
	INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
	INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
	INNER JOIN dbo.IVH i ON m.IVHIntId = i.IVHIntId
	INNER JOIN dbo.VehicleLatestAllEvent vlae ON vlae.VehicleId = v.VehicleId
	INNER JOIN dbo.VehicleLatestEvent vle ON vle.VehicleId = v.VehicleId

	
	LEFT JOIN  (SELECT	m.VehicleIntId, 
						MAX(CAST(m.Ignition AS INT)) AS Ignition,
						SUM(m.CANDriveDistance) AS CANDriveDistance,
						SUM(m.GPSDriveDistance) AS GPSDriveDistance,
						SUM(m.TXFails) AS TXFails,
						SUM(m.GPRSRetries) AS GPRSRetries,
						MAX(CAST(m.DriverIdInUse AS INT)) AS DriverIdInUse,
						AVG(m.AverageRPM) AS AverageRPM,
						SUM(m.ConsumedFuel) AS ConsumedFuel
				FROM dbo.Maintenance m
				INNER JOIN @Vehicles veh ON m.VehicleIntId = veh.VehicleIntId
				WHERE m.Date BETWEEN DATEADD(dd, -7, @date) AND @date
				GROUP BY m.VehicleIntId) m7 ON m.VehicleIntId = m7.VehicleIntId

	WHERE m.Date = @date
	  AND cv.Archived = 0
	ORDER BY m.DaysSincePoll DESC, v.Registration ASC






GO
