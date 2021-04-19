SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--INSERT INTO dbo.MaintenanceFaultType(FaultTypeId,Name,Description,LastOperation,Archived)
--VALUES  (30, 'High Over Rev MPG', 'Over Rev fuel economy is close to Sweet Spot economy', GETDATE(), 0)
--INSERT INTO dbo.MaintenanceFaultType(FaultTypeId,Name,Description,LastOperation,Archived)
--VALUES  (31, 'No Over Rev Distance', 'No over rev distance', GETDATE(), 0)
--INSERT INTO dbo.MaintenanceFaultType(FaultTypeId,Name,Description,LastOperation,Archived)
--VALUES  (32, 'High Below Sweet Spot', 'Below Sweet Spot distance is too high', GETDATE(), 0)

--GO

CREATE PROCEDURE [dbo].[proc_PopulateMaintenanceFaults]
AS 
SET NOCOUNT ON

DECLARE @date DATETIME
SET @date = DATEADD(dd, -1, GETUTCDATE())
SET @date = CAST(FLOOR(CAST(@date AS FLOAT)) AS DATETIME)

DECLARE @vehicles TABLE (VehicleId UNIQUEIDENTIFIER, VehicleintId INT)
DECLARE @faultData TABLE (VehicleIntId INT, MaintenanceJobId INT, FaultTypeId SMALLINT, AssetTypeId SMALLINT, AssetReference NVARCHAR(100))
DECLARE @faultTypeId SMALLINT,
		@VehicleIntId INT,
		@MaintenanceJobId INT,
		@faultId INT

--Run for all vehicles
INSERT INTO @vehicles (VehicleId, VehicleintId)
SELECT DISTINCT v.VehicleId, v.VehicleIntId
FROM dbo.Vehicle v
	INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
	INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
WHERE v.Archived = 0 AND cv.Archived = 0 AND cv.EndDate IS NULL AND c.Archived = 0 AND v.IVHId IS NOT NULL
	AND c.Name != 'Default Customer';

DECLARE @minimumCanDistance FLOAT,
		@maximumBelowSwetSpotDistance FLOAT,
		@overRevMPGToSweetSpotMPRatio FLOAT

SELECT	@minimumCanDistance = 100.0, --Vehicle should driver at least 100km
		@maximumBelowSwetSpotDistance = 0.1, --Acceptable to have less than 10% distance below sweet spot
		@overRevMPGToSweetSpotMPRatio = 2 -- Over rev MPG should be at least 2x worse than Sweet Spot MPG

DECLARE	@MaintData TABLE	
(
	VehicleId UNIQUEIDENTIFIER,
	SS1 VARCHAR(MAX) NULL,
	DaysNotPolled INT NULL,
	LastPoll DATETIME NULL,
	IsCheckedOut BIT NULL,
	Ignition BIT NULL,
	OdoGPS FLOAT NULL,
	DriverIdCount INT NULL,
	IdDistance FLOAT NULL,
	NoIdDistance FLOAT NULL,
	CAN BIT NULL,
	DrivingFuel FLOAT NULL,
	iButton BIT NULL,
	Tacho BIT NULL,
	CheetahFaults INT NULL,
	SS1Faults INT NULL,
	S01 BIT,
	S02 BIT,
	S03 BIT,
	S04 BIT,
	S01Faults BIT,
	S02Faults BIT,
	S03Faults BIT,
	S04Faults BIT,
	Accelerometer BIT,
	LateData INT,
	OverRevFuelEconomy INT,
	ZeroOverRev INT,
	HighBelowSweetSpot INT,
	Camera BIT,
	Video BIT,
	Corruption BIT
)

INSERT INTO @MaintData (VehicleId, SS1, DaysNotPolled, LastPoll, IsCheckedOut, Ignition, OdoGPS, DriverIdCount, IdDistance, NoIdDistance, CAN, DrivingFuel,
						iButton, Tacho, CheetahFaults, SS1Faults, S01, S02, S03, S04, S01Faults, S02Faults, S03Faults, S04Faults, Accelerometer, LateData,
						OverRevFuelEconomy, ZeroOverRev, HighBelowSweetSpot,Camera,Video,Corruption)
(
	SELECT	DISTINCT v.VehicleId,
			m.SS1,
			m.DaysSincePoll,
			vlae.EventDateTime,
			CASE WHEN m.TANCheckOut IS NOT NULL THEN 1 ELSE 0 END,
			m.Ignition,
			m7.GPSDriveDistance,
			m7.DriverIdInUse,
			dbo.ZeroYieldNull(m.CANDriveDistance - m.CANDriveDistanceNoID),
			CASE WHEN dbo.ZeroYieldNull(m.CANDriveDistanceNoID) < 10 THEN NULL ELSE dbo.ZeroYieldNull(m.CANDriveDistanceNoID) END,
			CASE WHEN ISNULL(m7.GPSDriveDistance, 0) = 0 THEN NULL ELSE CASE WHEN ISNULL(m7.AverageRPM,0) > 0 AND ISNULL(m7.ConsumedFuel,0) > 0 THEN 1 ELSE CASE WHEN ISNULL(m7.AverageRPM,0) = 0 AND ISNULL(m7.ConsumedFuel,0) = 0 THEN 0 ELSE NULL END END END,
			m.DrivingFuel,
			m.iButton,
			m.Tacho,
			m.CheetahFaults,
			m.SS1Faults,		
			ISNULL(m.Sensor01,0),
			ISNULL(m.Sensor02,0),
			ISNULL(m.Sensor03,0),
			ISNULL(m.Sensor04,0),
			CASE WHEN m.T0 = 0 THEN 1 ELSE 0 END,
			CASE WHEN m.T1 = 0 THEN 1 ELSE 0 END,
			CASE WHEN m.T2 = 0 THEN 1 ELSE 0 END,
			CASE WHEN m.T3 = 0 THEN 1 ELSE 0 END,
			m.Accelerometer,
			m.MaxDataAgeMins,

			CASE 
				WHEN ISNULL(m.CANDriveDistance, 0) < @minimumCanDistance OR m.OverRevFuel IS NULL
				THEN NULL
				ELSE
				CASE
					WHEN ISNULL((ISNULL(m.OverRevDistance, 0) / dbo.ZeroYieldNull(m.OverRevFuel) * 2.82481) * @overRevMPGToSweetSpotMPRatio, 0) < ISNULL((ISNULL(m.SweetSpotDistance, 0) / dbo.ZeroYieldNull(m.SweetSpotFuel) * 2.82481), 0)
					THEN NULL
					ELSE 1
				END
			END AS OverRevFuelEconomy,
			CASE 
				WHEN ISNULL(m.CANDriveDistance, 0) < @minimumCanDistance 
				THEN NULL
				ELSE
				CASE
					WHEN ISNULL(m.OverRevDistance, 0) > 0
					THEN NULL
					ELSE 1
				END
			END AS ZeroOverRev,
			CASE 
				WHEN ISNULL(m.CANDriveDistance, 0) < @minimumCanDistance 
				THEN NULL
				ELSE
				CASE
					WHEN ISNULL(ISNULL(m.BelowSweetSpotDistance, 0) / dbo.ZeroYieldNull(m.SweetSpotDistance), 0) < @maximumBelowSwetSpotDistance
					THEN NULL
					ELSE 1
				END
			END AS HighBelowSweetSpot,
			m.Camera,
			m.Video,
			m.Corruption
	FROM dbo.Maintenance m
	INNER JOIN @Vehicles veh ON m.VehicleIntId = veh.VehicleIntId
	INNER JOIN dbo.Vehicle v ON v.VehicleId = veh.vehicleId	
	INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
	INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
	INNER JOIN dbo.IVH i ON m.IVHIntId = i.IVHIntId
	INNER JOIN dbo.VehicleLatestAllEvent vlae ON vlae.VehicleId = v.VehicleId
	LEFT JOIN  (SELECT	m.VehicleIntId, 
						MAX(CAST(m.Ignition AS INT)) AS Ignition,
						SUM(m.CANDriveDistance) AS CANDriveDistance,
						SUM(m.GPSDriveDistance) AS GPSDriveDistance,
						MAX(CAST(m.DriverIdInUse AS INT)) AS DriverIdInUse,
						AVG(m.AverageRPM) AS AverageRPM,
						SUM(m.ConsumedFuel) AS ConsumedFuel
				FROM dbo.Maintenance m
				INNER JOIN @Vehicles veh ON m.VehicleIntId = veh.VehicleIntId
				WHERE m.Date BETWEEN DATEADD(dd, -7, @date) AND @date
				GROUP BY m.VehicleIntId) m7 ON m.VehicleIntId = m7.VehicleIntId

	WHERE m.Date = @date
		AND cv.Archived = 0
)

---------------------------------------------------------------------------------------
-- Now check for each fault type in turn and insert data into temporary FaultData table
---------------------------------------------------------------------------------------

-- 0. None -- Fault Type used to signify all fault types -- not used by this stored procedure

-- 1. Polling -- Criteria: days not polled > 3
SET @faultTypeId = 1
INSERT INTO @faultData (VehicleIntId, MaintenanceJobId, FaultTypeId, AssetTypeId, AssetReference)
SELECT v.VehicleIntId, mj.MaintenanceJobId, @faultTypeId, 1, i.TrackerNumber
FROM @MaintData m
INNER JOIN dbo.Vehicle v ON v.VehicleId = m.VehicleId
INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId
LEFT JOIN dbo.MaintenanceExclusion ex ON ex.VehicleIntId = v.VehicleIntId AND (ex.FaultTypeId = 0 OR ex.FaultTypeId = @faultTypeId) AND GETDATE() < ISNULL(ex.ExcludeUntil, '2999-12-31')
LEFT JOIN dbo.MaintenanceJob mj ON mj.VehicleIntId = v.VehicleIntId AND mj.ResolvedDateTime IS NULL	AND mj.Archived = 0
LEFT JOIN dbo.MaintenanceFault mf ON mf.MaintenanceJobId = mj.MaintenanceJobId AND mf.Archived = 0 AND mf.FaultTypeId = @faultTypeId
WHERE DaysNotPolled > 3
  --AND IsCheckedOut = 0
  AND ex.MaintenanceExclusionId IS NULL		
  AND mf.MaintenanceFaultId IS NULL	

-- 2. Tracking -- Criteria: odogps < 1 and more than 20 events with 0 Lat/Long (excluding CCId = 0)
SET @faultTypeId = 2
INSERT INTO @faultData (VehicleIntId, MaintenanceJobId, FaultTypeId, AssetTypeId, AssetReference)
SELECT d.VehicleIntId, d.MaintenanceJobId, @faultTypeId, 1, d.TrackerNumber
FROM (SELECT v.VehicleIntId, mj.MaintenanceJobId, i.TrackerNumber, COUNT(*) AS Num
	FROM @MaintData m
	INNER JOIN dbo.Vehicle v ON v.VehicleId = m.VehicleId
	INNER JOIN dbo.Event e WITH (NOLOCK) ON e.VehicleIntId = v.VehicleIntId AND e.EventDateTime BETWEEN DATEADD(dd, -7, @date) AND @date 
	INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId
	LEFT JOIN dbo.MaintenanceExclusion ex ON ex.VehicleIntId = v.VehicleIntId AND (ex.FaultTypeId = 0 OR ex.FaultTypeId = @faultTypeId) AND GETDATE() < ISNULL(ex.ExcludeUntil, '2999-12-31')
	LEFT JOIN dbo.MaintenanceJob mj ON mj.VehicleIntId = v.VehicleIntId AND mj.ResolvedDateTime IS NULL	AND mj.Archived = 0
	LEFT JOIN dbo.MaintenanceFault mf ON mf.MaintenanceJobId = mj.MaintenanceJobId AND mf.Archived = 0 AND mf.FaultTypeId = @faultTypeId
	WHERE m.OdoGPS < 1
	  AND e.CreationCodeId != 0
	  AND e.Lat = 0
	  AND e.Long = 0
	  --AND IsCheckedOut = 0
	  AND ex.MaintenanceExclusionId IS NULL	
	  AND mf.MaintenanceFaultId IS NULL
	GROUP BY v.VehicleIntId, mj.MaintenanceJobId, i.TrackerNumber
	HAVING COUNT(*) > 20) d

-- 3. Analog Sensor 1 -- Criteria: Sensor01 is Active AND shows faults
SET @faultTypeId = 3
INSERT INTO @faultData (VehicleIntId, MaintenanceJobId, FaultTypeId)
SELECT v.VehicleIntId, mj.MaintenanceJobId, @faultTypeId
FROM @MaintData m
INNER JOIN dbo.Vehicle v ON v.VehicleId = m.VehicleId
LEFT JOIN dbo.MaintenanceExclusion ex ON ex.VehicleIntId = v.VehicleIntId AND (ex.FaultTypeId = 0 OR ex.FaultTypeId = @faultTypeId) AND GETDATE() < ISNULL(ex.ExcludeUntil, '2999-12-31')
LEFT JOIN dbo.MaintenanceJob mj ON mj.VehicleIntId = v.VehicleIntId AND mj.ResolvedDateTime IS NULL	AND mj.Archived = 0
LEFT JOIN dbo.MaintenanceFault mf ON mf.MaintenanceJobId = mj.MaintenanceJobId AND mf.Archived = 0 AND mf.FaultTypeId = @faultTypeId
WHERE m.S01 = 1 AND m.S01Faults = 1
  --AND IsCheckedOut = 0
  AND ex.MaintenanceExclusionId IS NULL		
  AND mf.MaintenanceFaultId IS NULL	

-- 4. Analog Sensor 2 -- Criteria: Sensor02 is Active AND shows faults
SET @faultTypeId = 4
INSERT INTO @faultData (VehicleIntId, MaintenanceJobId, FaultTypeId)
SELECT v.VehicleIntId, mj.MaintenanceJobId, @faultTypeId
FROM @MaintData m
INNER JOIN dbo.Vehicle v ON v.VehicleId = m.VehicleId
LEFT JOIN dbo.MaintenanceExclusion ex ON ex.VehicleIntId = v.VehicleIntId AND (ex.FaultTypeId = 0 OR ex.FaultTypeId = @faultTypeId) AND GETDATE() < ISNULL(ex.ExcludeUntil, '2999-12-31')
LEFT JOIN dbo.MaintenanceJob mj ON mj.VehicleIntId = v.VehicleIntId AND mj.ResolvedDateTime IS NULL	AND mj.Archived = 0
LEFT JOIN dbo.MaintenanceFault mf ON mf.MaintenanceJobId = mj.MaintenanceJobId AND mf.Archived = 0 AND mf.FaultTypeId = @faultTypeId
WHERE m.S02 = 1 AND m.S02Faults = 1
  --AND IsCheckedOut = 0
  AND ex.MaintenanceExclusionId IS NULL		
  AND mf.MaintenanceFaultId IS NULL

-- 5. Analog Sensor 3 -- Criteria: Sensor03 is Active AND shows faults
SET @faultTypeId = 5
INSERT INTO @faultData (VehicleIntId, MaintenanceJobId, FaultTypeId)
SELECT v.VehicleIntId, mj.MaintenanceJobId, @faultTypeId
FROM @MaintData m
INNER JOIN dbo.Vehicle v ON v.VehicleId = m.VehicleId
LEFT JOIN dbo.MaintenanceExclusion ex ON ex.VehicleIntId = v.VehicleIntId AND (ex.FaultTypeId = 0 OR ex.FaultTypeId = @faultTypeId) AND GETDATE() < ISNULL(ex.ExcludeUntil, '2999-12-31')
LEFT JOIN dbo.MaintenanceJob mj ON mj.VehicleIntId = v.VehicleIntId AND mj.ResolvedDateTime IS NULL	AND mj.Archived = 0
LEFT JOIN dbo.MaintenanceFault mf ON mf.MaintenanceJobId = mj.MaintenanceJobId AND mf.Archived = 0 AND mf.FaultTypeId = @faultTypeId
WHERE m.S03 = 1 AND m.S03Faults = 1
  --AND IsCheckedOut = 0
  AND ex.MaintenanceExclusionId IS NULL	
  AND mf.MaintenanceFaultId IS NULL

-- 6. Analog Sensor 4 -- Criteria: Sensor04 is Active AND shows faults
SET @faultTypeId = 6
INSERT INTO @faultData (VehicleIntId, MaintenanceJobId, FaultTypeId)
SELECT v.VehicleIntId, mj.MaintenanceJobId, @faultTypeId
FROM @MaintData m
INNER JOIN dbo.Vehicle v ON v.VehicleId = m.VehicleId
LEFT JOIN dbo.MaintenanceExclusion ex ON ex.VehicleIntId = v.VehicleIntId AND (ex.FaultTypeId = 0 OR ex.FaultTypeId = @faultTypeId) AND GETDATE() < ISNULL(ex.ExcludeUntil, '2999-12-31')
LEFT JOIN dbo.MaintenanceJob mj ON mj.VehicleIntId = v.VehicleIntId AND mj.ResolvedDateTime IS NULL	AND mj.Archived = 0
LEFT JOIN dbo.MaintenanceFault mf ON mf.MaintenanceJobId = mj.MaintenanceJobId AND mf.Archived = 0 AND mf.FaultTypeId = @faultTypeId
WHERE m.S04 = 1 AND m.S04Faults = 1
  --AND IsCheckedOut = 0
  AND ex.MaintenanceExclusionId IS NULL		
  AND mf.MaintenanceFaultId IS NULL

-- 7. Digital Sensor 1 -- Criteria: Not currently tested
-- 8. Digital Sensor 2 -- Criteria: Not currently tested
-- 9. Digital Sensor 3 -- Criteria: Not currently tested
-- 10. Digital Sensor 4 -- Criteria: Not currently tested

-- 11. CAN -- Criteria: Average RPM and Fuel (CAN = 0)
SET @faultTypeId = 11
INSERT INTO @faultData (VehicleIntId, MaintenanceJobId, FaultTypeId, AssetTypeId, AssetReference)
SELECT v.VehicleIntId, mj.MaintenanceJobId, @faultTypeId, 1, i.TrackerNumber
FROM @MaintData m
INNER JOIN dbo.Vehicle v ON v.VehicleId = m.VehicleId
INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId
LEFT JOIN dbo.MaintenanceExclusion ex ON ex.VehicleIntId = v.VehicleIntId AND (ex.FaultTypeId = 0 OR ex.FaultTypeId = @faultTypeId) AND GETDATE() < ISNULL(ex.ExcludeUntil, '2999-12-31')
LEFT JOIN dbo.MaintenanceJob mj ON mj.VehicleIntId = v.VehicleIntId AND mj.ResolvedDateTime IS NULL	AND mj.Archived = 0
LEFT JOIN dbo.MaintenanceFault mf ON mf.MaintenanceJobId = mj.MaintenanceJobId AND mf.Archived = 0 AND mf.FaultTypeId = @faultTypeId
WHERE m.CAN = 0
  --AND IsCheckedOut = 0
  AND ex.MaintenanceExclusionId IS NULL		
  AND mf.MaintenanceFaultId IS NULL

-- 12. DriverId -- Criteria: DriverIdCount (last 7 days) = 0 and OdoGPS > 10
SET @faultTypeId = 12
INSERT INTO @faultData (VehicleIntId, MaintenanceJobId, FaultTypeId, AssetTypeId, AssetReference)
SELECT v.VehicleIntId, mj.MaintenanceJobId, @faultTypeId, 1, i.TrackerNumber
FROM @MaintData m
INNER JOIN dbo.Vehicle v ON v.VehicleId = m.VehicleId
INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId
LEFT JOIN dbo.MaintenanceExclusion ex ON ex.VehicleIntId = v.VehicleIntId AND (ex.FaultTypeId = 0 OR ex.FaultTypeId = @faultTypeId) AND GETDATE() < ISNULL(ex.ExcludeUntil, '2999-12-31')
LEFT JOIN dbo.MaintenanceJob mj ON mj.VehicleIntId = v.VehicleIntId AND mj.ResolvedDateTime IS NULL	AND mj.Archived = 0
LEFT JOIN dbo.MaintenanceFault mf ON mf.MaintenanceJobId = mj.MaintenanceJobId AND mf.Archived = 0 AND mf.FaultTypeId = @faultTypeId
WHERE m.DriverIdCount = 0
  AND m.OdoGPS > 10
  --AND IsCheckedOut = 0
  AND ex.MaintenanceExclusionId IS NULL		
  AND mf.MaintenanceFaultId IS NULL

-- 13. Ignition -- Criteria: Ignition (last 7 days) = 0.
SET @faultTypeId = 13
INSERT INTO @faultData (VehicleIntId, MaintenanceJobId, FaultTypeId, AssetTypeId, AssetReference)
SELECT v.VehicleIntId, mj.MaintenanceJobId, @faultTypeId, 1, i.TrackerNumber
FROM @MaintData m
INNER JOIN dbo.Vehicle v ON v.VehicleId = m.VehicleId
INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId
LEFT JOIN dbo.MaintenanceExclusion ex ON ex.VehicleIntId = v.VehicleIntId AND (ex.FaultTypeId = 0 OR ex.FaultTypeId = @faultTypeId) AND GETDATE() < ISNULL(ex.ExcludeUntil, '2999-12-31')
LEFT JOIN dbo.MaintenanceJob mj ON mj.VehicleIntId = v.VehicleIntId AND mj.ResolvedDateTime IS NULL	AND mj.Archived = 0
LEFT JOIN dbo.MaintenanceFault mf ON mf.MaintenanceJobId = mj.MaintenanceJobId AND mf.Archived = 0 AND mf.FaultTypeId = @faultTypeId
WHERE m.Ignition = 0
  --AND IsCheckedOut = 0
  AND ex.MaintenanceExclusionId IS NULL		
  AND mf.MaintenanceFaultId IS NULL

-- 14. Average data Delay -- Criteria: LateData > 600
SET @faultTypeId = 14
INSERT INTO @faultData (VehicleIntId, MaintenanceJobId, FaultTypeId, AssetTypeId, AssetReference)
SELECT v.VehicleIntId, mj.MaintenanceJobId, @faultTypeId, 1, i.TrackerNumber
FROM @MaintData m
INNER JOIN dbo.Vehicle v ON v.VehicleId = m.VehicleId
INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId
LEFT JOIN dbo.MaintenanceExclusion ex ON ex.VehicleIntId = v.VehicleIntId AND (ex.FaultTypeId = 0 OR ex.FaultTypeId = @faultTypeId) AND GETDATE() < ISNULL(ex.ExcludeUntil, '2999-12-31')
LEFT JOIN dbo.MaintenanceJob mj ON mj.VehicleIntId = v.VehicleIntId AND mj.ResolvedDateTime IS NULL	AND mj.Archived = 0
LEFT JOIN dbo.MaintenanceFault mf ON mf.MaintenanceJobId = mj.MaintenanceJobId AND mf.Archived = 0 AND mf.FaultTypeId = @faultTypeId
WHERE m.LateData > 600
  --AND IsCheckedOut = 0
  AND ex.MaintenanceExclusionId IS NULL		
  AND mf.MaintenanceFaultId IS NULL

-- 15. ABC Data -- Criteria: Acceleromer = 0 (not currently populated in Maintenance table)
SET @faultTypeId = 15
INSERT INTO @faultData (VehicleIntId, MaintenanceJobId, FaultTypeId)
SELECT v.VehicleIntId, mj.MaintenanceJobId, @faultTypeId
FROM @MaintData m
INNER JOIN dbo.Vehicle v ON v.VehicleId = m.VehicleId
LEFT JOIN dbo.MaintenanceExclusion ex ON ex.VehicleIntId = v.VehicleIntId AND (ex.FaultTypeId = 0 OR ex.FaultTypeId = @faultTypeId) AND GETDATE() < ISNULL(ex.ExcludeUntil, '2999-12-31')
LEFT JOIN dbo.MaintenanceJob mj ON mj.VehicleIntId = v.VehicleIntId AND mj.ResolvedDateTime IS NULL	AND mj.Archived = 0
LEFT JOIN dbo.MaintenanceFault mf ON mf.MaintenanceJobId = mj.MaintenanceJobId AND mf.Archived = 0 AND mf.FaultTypeId = @faultTypeId
WHERE m.Accelerometer = 1
  --AND IsCheckedOut = 0
  AND ex.MaintenanceExclusionId IS NULL		
  AND mf.MaintenanceFaultId IS NULL

-- 16. Speaker		-- Criteria: Manual fault type
-- 17. Microphone	-- Criteria: Manual fault type
-- 18. Screen		-- Criteria: Manual fault type
-- 19. Screen Loom	-- Criteria: Manual fault type
-- 20. Camera 1		-- Criteria: Manual fault type

-- 21. SS1 -- Criteria: SS1Faults > 0
SET @faultTypeId = 21
INSERT INTO @faultData (VehicleIntId, MaintenanceJobId, FaultTypeId, AssetTypeId, AssetReference)
SELECT v.VehicleIntId, mj.MaintenanceJobId, @faultTypeId, 2, m.SS1
FROM @MaintData m
INNER JOIN dbo.Vehicle v ON v.VehicleId = m.VehicleId
LEFT JOIN dbo.MaintenanceExclusion ex ON ex.VehicleIntId = v.VehicleIntId AND (ex.FaultTypeId = 0 OR ex.FaultTypeId = @faultTypeId) AND GETDATE() < ISNULL(ex.ExcludeUntil, '2999-12-31')
LEFT JOIN dbo.MaintenanceJob mj ON mj.VehicleIntId = v.VehicleIntId AND mj.ResolvedDateTime IS NULL	AND mj.Archived = 0
LEFT JOIN dbo.MaintenanceFault mf ON mf.MaintenanceJobId = mj.MaintenanceJobId AND mf.Archived = 0 AND mf.FaultTypeId = @faultTypeId
WHERE m.SS1Faults > 10 -- arbitrary value as a starting point for SS1 action required
  --AND IsCheckedOut = 0
  AND ex.MaintenanceExclusionId IS NULL		
  AND mf.MaintenanceFaultId IS NULL

-- 22. Phone		-- Criteria: Manual fault type
-- 23. Camera 2		-- Criteria: Manual fault type


--30 OverRevFuelEconomy
SET @faultTypeId = 30
INSERT INTO @faultData (VehicleIntId, MaintenanceJobId, FaultTypeId, AssetTypeId, AssetReference)
SELECT v.VehicleIntId, mj.MaintenanceJobId, @faultTypeId, 5, i.TrackerNumber
FROM @MaintData m
INNER JOIN dbo.Vehicle v ON v.VehicleId = m.VehicleId
INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId
LEFT JOIN dbo.MaintenanceExclusion ex ON ex.VehicleIntId = v.VehicleIntId AND (ex.FaultTypeId = 0 OR ex.FaultTypeId = @faultTypeId) AND GETDATE() < ISNULL(ex.ExcludeUntil, '2999-12-31')
LEFT JOIN dbo.MaintenanceJob mj ON mj.VehicleIntId = v.VehicleIntId AND mj.ResolvedDateTime IS NULL	AND mj.Archived = 0
LEFT JOIN dbo.MaintenanceFault mf ON mf.MaintenanceJobId = mj.MaintenanceJobId AND mf.Archived = 0 AND mf.FaultTypeId = @faultTypeId
WHERE m.OverRevFuelEconomy = 1
  --AND IsCheckedOut = 0
  AND ex.MaintenanceExclusionId IS NULL		
  AND mf.MaintenanceFaultId IS NULL

--31 ZeroOverRev
SET @faultTypeId = 31
INSERT INTO @faultData (VehicleIntId, MaintenanceJobId, FaultTypeId, AssetTypeId, AssetReference)
SELECT v.VehicleIntId, mj.MaintenanceJobId, @faultTypeId, 5, i.TrackerNumber
FROM @MaintData m
INNER JOIN dbo.Vehicle v ON v.VehicleId = m.VehicleId
INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId
LEFT JOIN dbo.MaintenanceExclusion ex ON ex.VehicleIntId = v.VehicleIntId AND (ex.FaultTypeId = 0 OR ex.FaultTypeId = @faultTypeId) AND GETDATE() < ISNULL(ex.ExcludeUntil, '2999-12-31')
LEFT JOIN dbo.MaintenanceJob mj ON mj.VehicleIntId = v.VehicleIntId AND mj.ResolvedDateTime IS NULL	AND mj.Archived = 0
LEFT JOIN dbo.MaintenanceFault mf ON mf.MaintenanceJobId = mj.MaintenanceJobId AND mf.Archived = 0 AND mf.FaultTypeId = @faultTypeId
WHERE m.ZeroOverRev = 1
  --AND IsCheckedOut = 0
  AND ex.MaintenanceExclusionId IS NULL		
  AND mf.MaintenanceFaultId IS NULL

--32 HighBelowSweetSpot
SET @faultTypeId = 32
INSERT INTO @faultData (VehicleIntId, MaintenanceJobId, FaultTypeId, AssetTypeId, AssetReference)
SELECT v.VehicleIntId, mj.MaintenanceJobId, @faultTypeId, 5, i.TrackerNumber
FROM @MaintData m
INNER JOIN dbo.Vehicle v ON v.VehicleId = m.VehicleId
INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId
LEFT JOIN dbo.MaintenanceExclusion ex ON ex.VehicleIntId = v.VehicleIntId AND (ex.FaultTypeId = 0 OR ex.FaultTypeId = @faultTypeId) AND GETDATE() < ISNULL(ex.ExcludeUntil, '2999-12-31')
LEFT JOIN dbo.MaintenanceJob mj ON mj.VehicleIntId = v.VehicleIntId AND mj.ResolvedDateTime IS NULL	AND mj.Archived = 0
LEFT JOIN dbo.MaintenanceFault mf ON mf.MaintenanceJobId = mj.MaintenanceJobId AND mf.Archived = 0 AND mf.FaultTypeId = @faultTypeId
WHERE m.HighBelowSweetSpot = 1
  --AND IsCheckedOut = 0
  AND ex.MaintenanceExclusionId IS NULL		
  AND mf.MaintenanceFaultId IS NULL

--37 Camera
SET @faultTypeId = 37
INSERT INTO @faultData (VehicleIntId, MaintenanceJobId, FaultTypeId, AssetTypeId, AssetReference)
SELECT v.VehicleIntId, mj.MaintenanceJobId, @faultTypeId, 5, i.TrackerNumber
FROM @MaintData m
INNER JOIN dbo.Vehicle v ON v.VehicleId = m.VehicleId
INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId
LEFT JOIN dbo.MaintenanceExclusion ex ON ex.VehicleIntId = v.VehicleIntId AND (ex.FaultTypeId = 0 OR ex.FaultTypeId = @faultTypeId) AND GETDATE() < ISNULL(ex.ExcludeUntil, '2999-12-31')
LEFT JOIN dbo.MaintenanceJob mj ON mj.VehicleIntId = v.VehicleIntId AND mj.ResolvedDateTime IS NULL	AND mj.Archived = 0
LEFT JOIN dbo.MaintenanceFault mf ON mf.MaintenanceJobId = mj.MaintenanceJobId AND mf.Archived = 0 AND mf.FaultTypeId = @faultTypeId
WHERE m.Camera = 0
AND m.Video = 0
  --AND IsCheckedOut = 0
  AND ex.MaintenanceExclusionId IS NULL		
  AND mf.MaintenanceFaultId IS NULL


--38 Video
  SET @faultTypeId = 38
INSERT INTO @faultData (VehicleIntId, MaintenanceJobId, FaultTypeId, AssetTypeId, AssetReference)
SELECT v.VehicleIntId, mj.MaintenanceJobId, @faultTypeId, 5, i.TrackerNumber
FROM @MaintData m
INNER JOIN dbo.Vehicle v ON v.VehicleId = m.VehicleId
INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId
LEFT JOIN dbo.MaintenanceExclusion ex ON ex.VehicleIntId = v.VehicleIntId AND (ex.FaultTypeId = 0 OR ex.FaultTypeId = @faultTypeId) AND GETDATE() < ISNULL(ex.ExcludeUntil, '2999-12-31')
LEFT JOIN dbo.MaintenanceJob mj ON mj.VehicleIntId = v.VehicleIntId AND mj.ResolvedDateTime IS NULL	AND mj.Archived = 0
LEFT JOIN dbo.MaintenanceFault mf ON mf.MaintenanceJobId = mj.MaintenanceJobId AND mf.Archived = 0 AND mf.FaultTypeId = @faultTypeId
WHERE m.Video = 0
  --AND IsCheckedOut = 0
  AND ex.MaintenanceExclusionId IS NULL		
  AND mf.MaintenanceFaultId IS NULL

  --39 Cheetah Corruption
    SET @faultTypeId = 39
INSERT INTO @faultData (VehicleIntId, MaintenanceJobId, FaultTypeId, AssetTypeId, AssetReference)
SELECT v.VehicleIntId, mj.MaintenanceJobId, @faultTypeId, 5, i.TrackerNumber
FROM @MaintData m
INNER JOIN dbo.Vehicle v ON v.VehicleId = m.VehicleId
INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId
LEFT JOIN dbo.MaintenanceExclusion ex ON ex.VehicleIntId = v.VehicleIntId AND (ex.FaultTypeId = 0 OR ex.FaultTypeId = @faultTypeId) AND GETDATE() < ISNULL(ex.ExcludeUntil, '2999-12-31')
LEFT JOIN dbo.MaintenanceJob mj ON mj.VehicleIntId = v.VehicleIntId AND mj.ResolvedDateTime IS NULL	AND mj.Archived = 0
LEFT JOIN dbo.MaintenanceFault mf ON mf.MaintenanceJobId = mj.MaintenanceJobId AND mf.Archived = 0 AND mf.FaultTypeId = @faultTypeId
WHERE m.Corruption = 0
  --AND IsCheckedOut = 0
  AND ex.MaintenanceExclusionId IS NULL		
  AND mf.MaintenanceFaultId IS NULL

--------------------------------------------------------------------------------------------------------------------
-- Use cursor to read through fault data and insert appropriate rows into MaintenanceJob and MaintenanceFault tables
-- If a MaintenanceJob already exists the fault data is added to that job, otherwise a MaintenanceJob is created
--------------------------------------------------------------------------------------------------------------------

DECLARE VCursor CURSOR FAST_FORWARD READ_ONLY
FOR 
	SELECT DISTINCT VehicleIntId, MaintenanceJobId
	FROM @faultData				
		
OPEN VCursor
FETCH NEXT FROM VCursor INTO @VehicleIntId, @MaintenanceJobId
WHILE @@FETCH_STATUS = 0
BEGIN
	-- Create new MaintenanceJob if no currently open job	
	IF @MaintenanceJobId IS NULL	
	BEGIN
		INSERT INTO dbo.MaintenanceJob (VehicleIntId, IVHIntId, CreationDateTime, Archived, LastOperation)
		SELECT v.VehicleIntId, i.IVHIntId, GETUTCDATE(), 0, GETDATE()
		FROM dbo.Vehicle v
		INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId
		WHERE v.VehicleIntId = @VehicleIntId

		SET @MaintenanceJobId = SCOPE_IDENTITY()
	END	

	-- Now add new faults to the MaintenanceJob
	INSERT INTO dbo.MaintenanceFault (MaintenanceJobId, FaultTypeId, FaultDateTime, AssetTypeId, AssetReference, AcknowledgedBy, Archived, LastOperation)
	SELECT @MaintenanceJobId, FaultTypeId, GETUTCDATE(), AssetTypeId, AssetReference, NULL, 0, GETDATE()
	FROM @faultData
	WHERE VehicleIntId = @VehicleIntId

	FETCH NEXT FROM VCursor INTO @VehicleIntId, @MaintenanceJobId

END
CLOSE VCursor
DEALLOCATE VCursor

--------------------------------------------------------------------------------------------------------------------
-- AUTO CORRECTION SECTION
-- The following section removes faults where the maintenance table suggests a fault has rectified itself
-- Only certain faults are auto corrected so as not to lose intermittent faults
--------------------------------------------------------------------------------------------------------------------

-- Create a temporary table to hold the ids of faults that will be auto-removed
DECLARE	@autoRemove TABLE
(
	FaultId INT
)

-- 1. Polling -- Criteria: tracker has polled since reporting original fault

INSERT INTO @autoRemove
        ( FaultId )
SELECT mf.MaintenanceFaultId
FROM dbo.MaintenanceFault mf
INNER JOIN dbo.MaintenanceJob mj ON mj.MaintenanceJobId = mf.MaintenanceJobId
INNER JOIN dbo.Maintenance m ON m.VehicleIntId = mj.VehicleIntId
INNER JOIN dbo.Vehicle v ON v.VehicleIntId = mj.VehicleIntId
INNER JOIN dbo.Customer c ON c.CustomerIntId = m.CustomerIntId 
WHERE mf.FaultTypeId = 1 
  AND m.DaysSincePoll < DATEDIFF(dd, mf.FaultDateTime, GETDATE())
  AND m.Date = @date
  AND mj.ResolvedDateTime IS NULL 
  AND mj.Archived = 0
  AND mf.Archived = 0 
  AND m.DaysSincePoll = 0

-- 12. DriverId -- Criteria: DriverIdInUse is true for the previous day (therefore DriverId is currently working)

INSERT INTO @autoRemove
        ( FaultId )
SELECT mf.MaintenanceFaultId
FROM dbo.MaintenanceFault mf
INNER JOIN dbo.MaintenanceJob mj ON mj.MaintenanceJobId = mf.MaintenanceJobId
INNER JOIN dbo.Maintenance m ON m.VehicleIntId = mj.VehicleIntId
INNER JOIN dbo.Vehicle v ON v.VehicleIntId = mj.VehicleIntId
INNER JOIN dbo.Customer c ON c.CustomerIntId = m.CustomerIntId 
WHERE mf.FaultTypeId = 12 
  AND m.DriverIdInUse = 1
  AND m.Date = @date
  AND mj.ResolvedDateTime IS NULL 
  AND mj.Archived = 0
  AND mf.Archived = 0 

-- 3. Analog Sensor 1 -- Criteria: Sensor01 has no faults for the previous day (therefore Sensor01 is currently working)

INSERT INTO @autoRemove
        ( FaultId )
SELECT mf.MaintenanceFaultId
FROM dbo.MaintenanceFault mf
INNER JOIN dbo.MaintenanceJob mj ON mj.MaintenanceJobId = mf.MaintenanceJobId
INNER JOIN dbo.Maintenance m ON m.VehicleIntId = mj.VehicleIntId
INNER JOIN dbo.Vehicle v ON v.VehicleIntId = mj.VehicleIntId
INNER JOIN dbo.Customer c ON c.CustomerIntId = m.CustomerIntId 
WHERE mf.FaultTypeId = 3 
  AND m.Sensor01 = 1 AND m.T0 = 1
  AND m.Date = @date
  AND mj.ResolvedDateTime IS NULL 
  AND mj.Archived = 0
  AND mf.Archived = 0 

-- 4. Analog Sensor 2 -- Criteria: Sensor02 has no faults for the previous day (therefore Sensor02 is currently working)

INSERT INTO @autoRemove
        ( FaultId )
SELECT mf.MaintenanceFaultId
FROM dbo.MaintenanceFault mf
INNER JOIN dbo.MaintenanceJob mj ON mj.MaintenanceJobId = mf.MaintenanceJobId
INNER JOIN dbo.Maintenance m ON m.VehicleIntId = mj.VehicleIntId
INNER JOIN dbo.Vehicle v ON v.VehicleIntId = mj.VehicleIntId
INNER JOIN dbo.Customer c ON c.CustomerIntId = m.CustomerIntId 
WHERE mf.FaultTypeId = 4
  AND m.Sensor02 = 1 AND m.T1 = 1
  AND m.Date = @date
  AND mj.ResolvedDateTime IS NULL 
  AND mj.Archived = 0
  AND mf.Archived = 0 

-- 5. Analog Sensor 3 -- Criteria: Sensor03 has no faults for the previous day (therefore Sensor03 is currently working)

INSERT INTO @autoRemove
        ( FaultId )
SELECT mf.MaintenanceFaultId
FROM dbo.MaintenanceFault mf
INNER JOIN dbo.MaintenanceJob mj ON mj.MaintenanceJobId = mf.MaintenanceJobId
INNER JOIN dbo.Maintenance m ON m.VehicleIntId = mj.VehicleIntId
INNER JOIN dbo.Vehicle v ON v.VehicleIntId = mj.VehicleIntId
INNER JOIN dbo.Customer c ON c.CustomerIntId = m.CustomerIntId 
WHERE mf.FaultTypeId = 5
  AND m.Sensor03 = 1 AND m.T2 = 1
  AND m.Date = @date
  AND mj.ResolvedDateTime IS NULL 
  AND mj.Archived = 0
  AND mf.Archived = 0 

-- 6. Analog Sensor 4 -- Criteria: Sensor04 has no faults for the previous day (therefore Sensor04 is currently working)

INSERT INTO @autoRemove
        ( FaultId )
SELECT mf.MaintenanceFaultId
FROM dbo.MaintenanceFault mf
INNER JOIN dbo.MaintenanceJob mj ON mj.MaintenanceJobId = mf.MaintenanceJobId
INNER JOIN dbo.Maintenance m ON m.VehicleIntId = mj.VehicleIntId
INNER JOIN dbo.Vehicle v ON v.VehicleIntId = mj.VehicleIntId
INNER JOIN dbo.Customer c ON c.CustomerIntId = m.CustomerIntId 
WHERE mf.FaultTypeId = 6
  AND m.Sensor04 = 1 AND m.T3 = 1
  AND m.Date = @date
  AND mj.ResolvedDateTime IS NULL 
  AND mj.Archived = 0
  AND mf.Archived = 0 

  -- 37. Camera -- Criteria: Camera has no faults for the previous day  (therefore Camera is currently working)

INSERT INTO @autoRemove
        ( FaultId )
SELECT mf.MaintenanceFaultId
FROM dbo.MaintenanceFault mf
INNER JOIN dbo.MaintenanceJob mj ON mj.MaintenanceJobId = mf.MaintenanceJobId
INNER JOIN dbo.Maintenance m ON m.VehicleIntId = mj.VehicleIntId
INNER JOIN dbo.Vehicle v ON v.VehicleIntId = mj.VehicleIntId
INNER JOIN dbo.Customer c ON c.CustomerIntId = m.CustomerIntId 
WHERE mf.FaultTypeId = 37 
  AND m.Camera = 1
  AND m.Date = @date
  AND mj.ResolvedDateTime IS NULL 
  AND mj.Archived = 0
  AND mf.Archived = 0 

  -- 38. Video -- Criteria: Video has no faults for the previous day (therefore Video is currently working)

INSERT INTO @autoRemove
        ( FaultId )
SELECT mf.MaintenanceFaultId
FROM dbo.MaintenanceFault mf
INNER JOIN dbo.MaintenanceJob mj ON mj.MaintenanceJobId = mf.MaintenanceJobId
INNER JOIN dbo.Maintenance m ON m.VehicleIntId = mj.VehicleIntId
INNER JOIN dbo.Vehicle v ON v.VehicleIntId = mj.VehicleIntId
INNER JOIN dbo.Customer c ON c.CustomerIntId = m.CustomerIntId 
WHERE mf.FaultTypeId = 38 
  AND m.Video = 1
  AND m.Date = @date
  AND mj.ResolvedDateTime IS NULL 
  AND mj.Archived = 0
  AND mf.Archived = 0 


-- Finally cursor round the faults to be removed and call proc_DeleteMaintenanceFault which will delete the faults correctly and log results

DECLARE RCursor CURSOR FAST_FORWARD READ_ONLY
FOR 
	SELECT DISTINCT FaultId
	FROM @autoRemove				
		
OPEN RCursor
FETCH NEXT FROM RCursor INTO @faultId
WHILE @@FETCH_STATUS = 0
BEGIN

	EXEC dbo.proc_DeleteMaintenanceFault @faultId = @faultId

	FETCH NEXT FROM RCursor INTO @faultId

END
CLOSE RCursor
DEALLOCATE RCursor


GO
