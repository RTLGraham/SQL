SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportMaintenanceTrends]
    (
	@vids varchar(max) = NULL,
	@sdate datetime,
	@edate datetime,
	@uid uniqueidentifier
    )
AS 
SET NOCOUNT ON

--	DECLARE @vids VARCHAR(MAX),
--			@sdate DATETIME,
--			@edate DATETIME,
--			@uid UNIQUEIDENTIFIER
--
----	SET @vids = N'8016F50D-A2D1-49A9-BC1E-13AE27953390,486A43F1-70D9-46CC-A745-542B6A4D77CE,5DE385BF-BFCB-4179-90CB-5AEE460B14AD,67B44E7F-6A0E-42E0-9DCF-5DDCA2AF502E,2C1A82DE-6DCB-4D03-BC21-5F65198B9A84,DB3AC174-1CFE-404C-914B-6BE9DB1B7038,D075F7EF-C02E-46E4-91C3-8191F2167F59,6CD1331B-F7FC-4866-A333-8FEE45667F33,91D26E73-DBD4-45DA-935C-997766C44AA2,3708F23A-F7CA-44F0-BB96-A94E80C40DFF'
--	SET @vids = N'8016F50D-A2D1-49A9-BC1E-13AE27953390,486A43F1-70D9-46CC-A745-542B6A4D77CE,5DE385BF-BFCB-4179-90CB-5AEE460B14AD,67B44E7F-6A0E-42E0-9DCF-5DDCA2AF502E,2C1A82DE-6DCB-4D03-BC21-5F65198B9A84,DB3AC174-1CFE-404C-914B-6BE9DB1B7038,D075F7EF-C02E-46E4-91C3-8191F2167F59,6CD1331B-F7FC-4866-A333-8FEE45667F33,91D26E73-DBD4-45DA-935C-997766C44AA2,3708F23A-F7CA-44F0-BB96-A94E80C40DFF'
--	SET @sdate = '2013-12-01 00:00'
--	SET @edate = '2013-12-31 23:59'
--	SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'

	DECLARE @lvids varchar(max),
			@lsdate datetime,
			@ledate datetime,
			@luid UNIQUEIDENTIFIER
			
	SET @lvids = @vids
	SET @lsdate = @sdate
	SET @ledate = @edate
	SET @luid = @uid

	SET @lsdate = CAST(FLOOR(CAST(@lsdate AS FLOAT)) AS DATETIME)

	DECLARE @vehicles TABLE
	(
		VehicleId UNIQUEIDENTIFIER,
		VehicleintId INT
	)

	INSERT INTO @vehicles (VehicleId, VehicleintId)
	SELECT v.VehicleId, v.VehicleIntId
	FROM dbo.Vehicle v
	INNER JOIN (SELECT Value AS VehicleId
				FROM dbo.Split(@lvids, ',')) veh ON v.VehicleId = veh.VehicleId

	DECLARE @diststr varchar(20),
			@distmult float

	SELECT @diststr = [dbo].UserPref(@luid, 203)
	SELECT @distmult = [dbo].UserPref(@luid, 202)

	SELECT	m.Date, 
			v.VehicleId,	
			v.Registration,
			mpoll.NumPolling / CASE WHEN mcount.NumVehicles = 0 THEN NULL ELSE mcount.NumVehicles END * 100 AS Availability,			
			m.BatteryDisconnect,
			m.HardwareErrors,
			m.GPRSRetries,
			m.TXFails,
			m.DaysSincePoll,
			m.DaysSinceDrive,
			CASE WHEN m.GPSDriveDistance > m.CANDriveDistance 
				THEN m.CANDriveDistance / CASE WHEN m.GPSDriveDistance = 0 THEN NULL ELSE m.GPSDriveDistance END 
				ELSE m.GPSDriveDistance / CASE WHEN m.CANDriveDistance = 0 THEN NULL ELSE m.CANDriveDistance END
			END * 100.0 AS GPStoCANratio,
			ISNULL(m.CANDriveDistanceNoID / CASE WHEN m.CANDriveDistance = 0 THEN NULL ELSE m.CANDriveDistance END, 0) * 100.0 AS NoIdPercent,
			CAST(m.t0 AS INT) + CAST(m.T1 AS INT) + CAST(m.T2 AS INT) + CAST(m.T3 AS INT) AS NumSensors,
			m.MaxDataAgeMins,
			((CAST(m.MinBatteryCharge AS FLOAT) * 10) + 2500) / 1000 AS MinBatteryCharge,
			((CAST(m.MaxBatteryCharge AS FLOAT) * 10) + 2500) / 1000 AS MaxBatteryCharge,
			((CAST(m.AvgBatteryCharge AS FLOAT) * 10) + 2500) / 1000 AS AvgBatteryCharge,
			CAST(m.MaxExternalVoltage AS FLOAT) * 0.5 AS MaxExternalVoltage,
			CAST(m.MinExternalVoltage AS FLOAT) * 0.5 AS MinExternalVoltage,
			CAST(m.AvgExternalVoltage AS FLOAT) * 0.5 AS AvgExternalVoltage,			
			m.Acceleration,
			m.Braking,
			m.Cornering
									
		FROM dbo.Maintenance m
		INNER JOIN @vehicles veh ON m.VehicleIntId = veh.VehicleintId
		INNER JOIN dbo.Vehicle v ON veh.VehicleId = v.VehicleId
		
		INNER JOIN (
			SELECT m.Date, CAST(COUNT(m.VehicleIntId) AS FLOAT) AS NumVehicles
			FROM dbo.Maintenance m
			INNER JOIN @vehicles v ON m.VehicleIntId = v.VehicleintId
			WHERE m.Date BETWEEN @lsdate AND @ledate
			  AND m.TANCheckout IS NULL
			GROUP BY m.Date
		) mcount ON m.Date = mcount.Date 
		
		INNER JOIN (
			SELECT m.Date, CAST(COUNT(m.VehicleIntId) AS FLOAT) AS NumPolling
			FROM dbo.Maintenance m
			INNER JOIN @vehicles v ON m.VehicleIntId = v.VehicleintId
			WHERE m.Date BETWEEN @lsdate AND @ledate
			  AND m.TANCheckout IS NULL
			  AND m.DaysSincePoll <= 1
			GROUP BY m.Date
		) mpoll ON m.Date = mpoll.Date
		
		WHERE m.Date BETWEEN @lsdate AND @ledate

	ORDER BY m.Date, v.Registration





GO
