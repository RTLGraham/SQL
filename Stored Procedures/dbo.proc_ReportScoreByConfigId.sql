SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportScoreByConfigId]
(
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER
)
AS

--DECLARE	@sdate datetime,
--		@edate datetime,
--		@uid uniqueidentifier,
--		@rprtcfgid uniqueidentifier
--
--SET	@rprtcfgid = N'e8bf08bd-595d-4e40-98af-0b07e5242021'
--SET @sdate = '2013-08-01 00:00'
--SET @edate = '2013-08-31 23:59'
--SET @uid = N'c21039e7-58be-4748-9a92-9aab74aed58e'

DECLARE	@lsdate datetime,
		@ledate datetime,
		@luid uniqueidentifier,
		@lrprtcfgid UNIQUEIDENTIFIER
		
SET @lsdate = @sdate
SET @ledate = @edate
SET @luid = @uid
SET @lrprtcfgid = @rprtcfgid
		
DECLARE @diststr varchar(20),
		@distmult float,
		@fuelstr varchar(20),
		@fuelmult float,
		@co2str varchar(20),
		@co2mult FLOAT,
		@custintid INT

SELECT @diststr = [dbo].UserPref(@luid, 203)
SELECT @distmult = [dbo].UserPref(@luid, 202)
SELECT @fuelstr = [dbo].UserPref(@luid, 205)
SELECT @fuelmult = [dbo].UserPref(@luid, 204)
SELECT @co2str = [dbo].UserPref(@luid, 211)
SELECT @co2mult = [dbo].UserPref(@luid, 210)

SET @lsdate = [dbo].TZ_ToUTC(@lsdate,default,@luid)
SET @ledate = [dbo].TZ_ToUTC(@ledate,default,@luid)

DECLARE @vehicles TABLE
(
	VehicleId UNIQUEIDENTIFIER,
	VehicleIntId INT
)

/*TODO: decide what way is correct and wrap it into GetFleet function*/
/* Decided on a fork to handle Hoyer's split fleet vs all other customers single fleet*/

SELECT @custintid = c.CustomerIntId
FROM dbo.[User] u
INNER JOIN dbo.Customer c ON u.CustomerID = c.CustomerId
WHERE u.UserID = @luid

IF @custintid = 28 -- Hoyer
BEGIN
	INSERT INTO @vehicles
			( VehicleId, VehicleIntId )
	SELECT DISTINCT v.VehicleId, v.VehicleIntId
	FROM dbo.UserGroup ug
		INNER JOIN dbo.[Group] g ON ug.GroupId = g.GroupId
		INNER JOIN dbo.GroupDetail gd ON g.GroupId = gd.GroupId
		INNER JOIN dbo.Vehicle v ON gd.EntityDataId = v.VehicleId
	WHERE ug.UserID = @luid
		AND v.Archived = 0
		AND g.Archived = 0 AND g.IsParameter = 0 AND g.GroupTypeId = 1 AND ug.Archived = 0
END ELSE
BEGIN
	INSERT INTO @vehicles
			( VehicleId, VehicleIntId )
	SELECT DISTINCT v.VehicleId, v.VehicleIntId
	FROM dbo.Vehicle v
		INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
		INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
		INNER JOIN dbo.[User] u ON c.CustomerId = u.CustomerId
	WHERE u.UserID = @luid
		AND v.Archived = 0
		AND cv.Archived = 0
		AND cv.EndDate IS NULL
END

SELECT 	NULL AS VehicleId, 
		NULL AS DriverId, 
		NULL AS Registration,
		NULL AS DriverName,
		Safety = dbo.ScoreByClassConfig('S', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, @lrprtcfgid),
		Efficiency = dbo.ScoreByClassConfig('E', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, @lrprtcfgid),
		EngineServiceBrake,
		OverSpeed,
		OverSpeedHigh,
		CoastOutOfGear,
		Acceleration,
		Braking,
		Cornering,
		AccelerationLow,
		BrakingLow,
		CorneringLow,
		AccelerationHigh,
		BrakingHigh,
		CorneringHigh,
		ManoeuvresLow,
		ManoeuvresMed,
		SweetSpot,
		OverRevWithFuel,
		TopGear,
		Cruise,
		CruiseInTopGears,
		Idle
FROM
(	SELECT
		NULL AS VehicleId,
		NULL AS Registration,
		NULL AS DriverId,
		SUM(InSweetSpotDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS SweetSpot,
		SUM(FueledOverRPMDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS OverRevWithFuel,
		SUM(TopGearDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS TopGear,
		SUM(CruiseControlDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS Cruise,
		dbo.CAP(SUM(CruiseControlDistance) / dbo.ZeroYieldNull(SUM(TopGearDistance + ISNULL(GearDownDistance,0))), 1.0) AS CruiseInTopGears,
		SUM(CoastInGearDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS CoastInGear,
		SUM(CruiseControlDistance) / dbo.ZeroYieldNull(SUM(TopGearDistance)) AS CruiseTopGearRatio,
		CAST(SUM(IdleTime) AS float) / dbo.ZeroYieldNull(SUM(TotalTime)) AS Idle,
		CAST(SUM(PTOMovingTime) + SUM(PTONonMovingTime) AS float) / dbo.ZeroYieldNull(SUM(TotalTime)) AS Pto,
		NULL AS Co2, --@co2mult: 1 for g/km, 1.6 for g/miles
		SUM(TotalTime) AS TotalTime,
		SUM(ServiceBrakeDistance) / CASE WHEN SUM(DrivingDistance + PTOMovingDistance) = 0 THEN NULL ELSE SUM(DrivingDistance + PTOMovingDistance) END AS ServiceBrakeUsage,
		ISNULL(SUM(EngineBrakeDistance) / dbo.ZeroYieldNull(SUM(ServiceBrakeDistance + EngineBrakeDistance)),0) AS EngineServiceBrake,
		ISNULL(SUM(EngineBrakeOverRPMDistance) / dbo.ZeroYieldNull(SUM(EngineBrakeDistance)),0) AS OverRevWithoutFuel,
		ISNULL((SUM(ROPCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000))))),0) AS Rop,
		ISNULL((SUM(ROP2Count) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000))))),0) AS Rop2,
		ISNULL(SUM(ro.OverSpeedDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)),0) AS OverSpeed,
		ISNULL(SUM(ro.OverSpeedHighDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)),0) AS OverSpeedHigh,
		ISNULL(SUM(ro.OverSpeedDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)),0) AS OverSpeedDistance, 
		ISNULL(SUM(r.OverSpeedDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)),0) AS IVHOverSpeed,
		ISNULL(SUM(CoastOutOfGearDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)),0) AS CoastOutOfGear,
		ISNULL((SUM(PanicStopCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000))))),0) AS HarshBraking,
		SUM(DrivingDistance * 1000 * @distmult) AS TotalDrivingDistance,
		ISNULL((SUM(ORCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000))))),0) AS OverRevCount,
		
		ISNULL((SUM(abc.Acceleration) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000))))),0) AS Acceleration,
		ISNULL((SUM(abc.Braking) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000))))),0) AS Braking,
		ISNULL((SUM(abc.Cornering) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000))))),0) AS Cornering,
		
		ISNULL((SUM(abc.AccelerationLow) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000))))),0) AS AccelerationLow,
		ISNULL((SUM(abc.BrakingLow) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000))))),0) AS BrakingLow,
		ISNULL((SUM(abc.CorneringLow) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000))))),0) AS CorneringLow,
		
		ISNULL((SUM(abc.AccelerationHigh) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000))))),0) AS AccelerationHigh,
		ISNULL((SUM(abc.BrakingHigh) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000))))),0) AS BrakingHigh,
		ISNULL((SUM(abc.CorneringHigh) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000))))),0) AS CorneringHigh,
				
		ISNULL((SUM(abc.AccelerationLow + abc.BrakingLow + abc.CorneringLow) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS ManoeuvresLow,
		ISNULL((SUM(abc.Acceleration + abc.Braking + abc.Cornering) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS ManoeuvresMed,

		NULL AS FuelEcon
			
	FROM dbo.Reporting r
		INNER JOIN @vehicles veh ON r.VehicleIntId = veh.VehicleIntId
		INNER JOIN dbo.Vehicle v ON r.VehicleIntId = v.VehicleIntId
		INNER JOIN dbo.Driver d ON r.DriverIntId = d.DriverIntId
		LEFT JOIN dbo.ReportingABC abc ON r.VehicleIntId = abc.VehicleIntId AND r.DriverIntId = abc.DriverIntId AND r.Date = abc.Date --AND r.RouteID = abc.RouteId
		LEFT JOIN dbo.ReportingOverspeed ro ON r.VehicleIntId = ro.VehicleIntId AND r.DriverIntId = ro.DriverIntId AND r.Date = ro.Date --AND r.RouteID = ro.RouteId

	WHERE r.Date BETWEEN @lsdate AND @ledate 
--		AND (v.VehicleId IN (SELECT Value FROM dbo.Split(dbo.GetFleetVids(@luid), ',')) OR dbo.GetFleetVids(@luid) IS NULL)
		AND r.DrivingDistance > 0
	HAVING SUM(DrivingDistance) > 10 
)o

GO
