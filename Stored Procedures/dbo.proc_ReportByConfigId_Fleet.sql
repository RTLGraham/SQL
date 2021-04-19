SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_ReportByConfigId_Fleet]
(
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER
)
AS

DECLARE	@lsdate datetime,
		@ledate datetime,
		@luid UNIQUEIDENTIFIER,
		@lrprtcfgid UNIQUEIDENTIFIER
		
SET @lsdate = @sdate
SET @ledate = @edate
SET @luid = @uid
SET @lrprtcfgid = @rprtcfgid

--SET	@lsdate = '2013-01-07 00:00:00.000'
--SET	@ledate = '2013-02-10 23:59:00.000'
--SET	@luid = N'DC29EE2F-2F71-475D-94E1-87C95C05EF7C'
--SET	@lrprtcfgid = N'687403B7-249F-47B0-961C-C5CAC3F0B190'

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
		LEFT JOIN dbo.FuelType f ON f.FuelTypeId = v.FuelTypeId
	WHERE ug.UserID = @luid
		AND v.Archived = 0
		AND g.Archived = 0 AND g.IsParameter = 0 AND g.GroupTypeId = 1 AND ug.Archived = 0
END ELSE
BEGIN
	INSERT INTO @vehicles
			( VehicleId, VehicleIntId )
	SELECT DISTINCT v.VehicleId, v.VehicleIntId
	FROM dbo.Vehicle v
		LEFT JOIN dbo.FuelType f ON f.FuelTypeId = v.FuelTypeId
		INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
		INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
		INNER JOIN dbo.[User] u ON c.CustomerId = u.CustomerId
	WHERE u.UserID = @luid
		AND v.Archived = 0
		AND cv.Archived = 0
		AND cv.EndDate IS NULL
END

SELECT
		-- Week identifiers
		NULL AS WeekNum,
		NULL AS WeekStartDate,
		NULL AS WeekEndDate,
		
		-- Vehicle and Driver Identification columns
		NULL AS	VehicleId,	
		NULL AS Registration,
		
		NULL AS DriverId,
 		NULL AS DisplayName,
 		NULL AS DriverName, -- included for backward compatibility
 		NULL AS FirstName,
 		NULL AS Surname,
 		NULL AS MiddleNames,
 		NULL AS Number,
 		NULL AS NumberAlternate,
 		NULL AS NumberAlternate2,
 		
 		-- Data columns with corresponding colours below 
		SweetSpot, 
		OverRevWithFuel, 
		TopGear, 
		Cruise, 
		CruiseInTopGears,
		CoastInGear, 
		Idle, 
		EngineServiceBrake, 
		OverRevWithoutFuel, 
		Rop, 
		Rop2,
		OverSpeed,
		OverSpeedHigh,
		OverSpeedDistance, 
		IVHOverSpeed,

		 SpeedGauge,
		 AccelerationHighCount,
		 BrakingHighCount,
		 CorneringHighCount,
		 ManoeuvresLowCount,
		 ManoeuvresMedCount,
		 RopCount,
		 Rop2Count,

		CoastOutOfGear, 
		HarshBraking, 
		FuelEcon,
		Pto, 
		Co2, 
		CruiseTopGearRatio,
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
		NULL AS CruiseOverspeed,
		NULL AS TopGearOverspeed,
		NULL AS FuelWastageCost,
		
		-- Component Columns
		SweetSpotComponent,
		OverRevWithFuelComponent,
		TopGearComponent,
		CruiseComponent,
		CruiseInTopGearsComponent,
		CruiseTopGearRatio,
		IdleComponent,
		EngineServiceBrakeComponent,
		OverRevWithoutFuelComponent,
		RopComponent,
		Rop2Component,
		OverSpeedComponent,
		OverSpeedHighComponent,
		OverSpeedDistanceComponent,
		IVHOverSpeedComponent,

		SpeedGaugeComponent,

		CoastOutOfGearComponent,
		CoastInGear,
		HarshBrakingComponent,
		AccelerationComponent,
		BrakingComponent,
		CorneringComponent,
		AccelerationLowComponent,
		BrakingLowComponent,
		CorneringLowComponent,
		AccelerationHighComponent,
		BrakingHighComponent,
		CorneringHighComponent,
		ManoeuvresLowComponent,
		ManoeuvresMedComponent,
		NULL AS CruiseOverspeedComponent,
		NULL AS TopGearOverspeedComponent,
				
		-- Score columns
		Efficiency, 
		Safety,

		-- Additional columns with no corresponding colour	
		TotalTime,
		TotalDrivingDistance,
		ServiceBrakeUsage,	
		OverRevCount,
		
		-- Date and Unit columns 
		@lsdate AS sdate,
		@ledate AS edate,
		@lsdate AS CreationDateTime,
		@ledate AS ClosureDateTime,
		--[dbo].TZ_GetTime(@lsdate,default,@luid) AS CreationDateTime,
		--[dbo].TZ_GetTime(@ledate,default,@luid) AS ClosureDateTime,

		@diststr AS DistanceUnit,
		@fuelstr AS FuelUnit,
		@co2str AS Co2Unit,
		@fuelmult AS FuelMult,

		-- Colour columns corresponding to data columns above
		dbo.GYRColourConfig(SweetSpot*100, 1, @lrprtcfgid) AS SweetSpotColour,
		dbo.GYRColourConfig(OverRevWithFuel*100, 2, @lrprtcfgid) AS OverRevWithFuelColour,
		dbo.GYRColourConfig(TopGear*100, 3, @lrprtcfgid) AS TopGearColour,
		dbo.GYRColourConfig(Cruise*100, 4, @lrprtcfgid) AS CruiseColour,
		dbo.GYRColourConfig(CruiseInTopGears*100, 32, @lrprtcfgid) AS CruiseInTopGearsColour,
		dbo.GYRColourConfig(CoastInGear*100, 5, @lrprtcfgid) AS CoastInGearColour,
		dbo.GYRColourConfig(Idle*100, 6, @lrprtcfgid) AS IdleColour,
		dbo.GYRColourConfig(EngineServiceBrake*100, 7, @lrprtcfgid) AS EngineServiceBrakeColour,
		dbo.GYRColourConfig(OverRevWithoutFuel*100, 8, @lrprtcfgid) AS OverRevWithoutFuelColour,
		dbo.GYRColourConfig(Rop, 9, @lrprtcfgid) AS RopColour,
		dbo.GYRColourConfig(Rop2, 41, @lrprtcfgid) AS Rop2Colour,
		dbo.GYRColourConfig(OverSpeed*100, 10, @lrprtcfgid) AS OverSpeedColour, 
		dbo.GYRColourConfig(OverSpeedHigh*100, 32, @lrprtcfgid) AS OverSpeedHighColour, 
		dbo.GYRColourConfig(IVHOverSpeed*100, 30, @lrprtcfgid) AS IVHOverSpeedColour,
		dbo.GYRColourConfig(CoastOutOfGear*100, 11, @lrprtcfgid) AS CoastOutOfGearColour,
		dbo.GYRColourConfig(HarshBraking, 12, @lrprtcfgid) AS HarshBrakingColour,
		dbo.GYRColourConfig(Efficiency, 14, @lrprtcfgid) AS EfficiencyColour,
		dbo.GYRColourConfig(Safety, 15, @lrprtcfgid) AS SafetyColour,
		dbo.GYRColourConfig(FuelEcon, 16, @lrprtcfgid) AS KPLColour,
		dbo.GYRColourConfig(Co2, 20, @lrprtcfgid) AS Co2Colour,
		dbo.GYRColourConfig(OverSpeedDistance * 100, 21, @lrprtcfgid) AS OverSpeedDistanceColour,
		dbo.GYRColourConfig(Acceleration, 22, @lrprtcfgid) AS AccelerationColour,
		dbo.GYRColourConfig(Braking, 23, @lrprtcfgid) AS BrakingColour,
		dbo.GYRColourConfig(Cornering, 24, @lrprtcfgid) AS CorneringColour,
		dbo.GYRColourConfig(AccelerationLow, 33, @lrprtcfgid) AS AccelerationLowColour,
		dbo.GYRColourConfig(BrakingLow, 34, @lrprtcfgid) AS BrakingLowColour,
		dbo.GYRColourConfig(CorneringLow, 35, @lrprtcfgid) AS CorneringLowColour,
		dbo.GYRColourConfig(AccelerationHigh, 36, @lrprtcfgid) AS AccelerationHighColour,
		dbo.GYRColourConfig(BrakingHigh, 37, @lrprtcfgid) AS BrakingHighColour,
		dbo.GYRColourConfig(CorneringHigh, 38, @lrprtcfgid) AS CorneringHighColour,
		dbo.GYRColourConfig(AccelerationLow + BrakingLow + CorneringLow, 39, @lrprtcfgid) AS ManoeuvresLowColour,
		dbo.GYRColourConfig(Acceleration + Braking + Cornering, 40, @lrprtcfgid) AS ManoeuvresMedColour,
		dbo.GYRColourConfig(CruiseTopGearRatio*100, 25, @lrprtcfgid) AS CruiseTopGearRatioColour,
		dbo.GYRColourConfig(OverRevCount, 28, @lrprtcfgid) AS OverRevCountColour,
		dbo.GYRColourConfig(Pto*100, 29, @lrprtcfgid) AS PtoColour,
		dbo.GYRColourConfig(SpeedGauge*100, 59, @lrprtcfgid) AS SpeedGaugeColour,
		NULL AS CruiseOverspeedColour,
		NULL AS TopGearOverspeedColour,
		NULL AS FuelWastageCostColour
FROM
	(SELECT *,
		
		Safety = dbo.ScoreByClassConfig('S', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, @lrprtcfgid),
		Efficiency = dbo.ScoreByClassConfig('E', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, @lrprtcfgid),
		
		SweetSpotComponent = dbo.ScoreComponentValueConfig(1, SweetSpot, @lrprtcfgid),
		OverRevWithFuelComponent = dbo.ScoreComponentValueConfig(2, OverRevWithFuel, @lrprtcfgid),
		TopGearComponent = dbo.ScoreComponentValueConfig(3, TopGear, @lrprtcfgid),
		CruiseComponent = dbo.ScoreComponentValueConfig(4, Cruise, @lrprtcfgid),
		CruiseInTopGearsComponent = dbo.ScoreComponentValueConfig(31, CruiseInTopGears, @lrprtcfgid),
		CruiseTopGearratioComponent = dbo.ScoreComponentValueConfig(25, CruiseTopGearRatio, @lrprtcfgid),
		IdleComponent = dbo.ScoreComponentValueConfig(6, Idle, @lrprtcfgid),
		
		AccelerationComponent = dbo.ScoreComponentValueConfig(22, Acceleration, @lrprtcfgid),
		BrakingComponent = dbo.ScoreComponentValueConfig(23, Braking, @lrprtcfgid),
		CorneringComponent = dbo.ScoreComponentValueConfig(24, Cornering, @lrprtcfgid),
				
		AccelerationLowComponent = dbo.ScoreComponentValueConfig(33, AccelerationLow, @lrprtcfgid),
		BrakingLowComponent = dbo.ScoreComponentValueConfig(34, BrakingLow, @lrprtcfgid),
		CorneringLowComponent = dbo.ScoreComponentValueConfig(35, CorneringLow, @lrprtcfgid),
		
		AccelerationHighComponent = dbo.ScoreComponentValueConfig(36, AccelerationHigh, @lrprtcfgid),
		BrakingHighComponent = dbo.ScoreComponentValueConfig(37, BrakingHigh, @lrprtcfgid),
		CorneringHighComponent = dbo.ScoreComponentValueConfig(38, CorneringHigh, @lrprtcfgid),

		ManoeuvresLowComponent = dbo.ScoreComponentValueConfig(39, AccelerationLow + BrakingLow + CorneringLow, @lrprtcfgid),
		ManoeuvresMedComponent = dbo.ScoreComponentValueConfig(40, Acceleration + Braking + Cornering, @lrprtcfgid),
		
		EngineServiceBrakeComponent = dbo.ScoreComponentValueConfig(7, EngineServiceBrake, @lrprtcfgid),
		OverRevWithoutFuelComponent = dbo.ScoreComponentValueConfig(8, OverRevWithoutFuel, @lrprtcfgid),
		RopComponent = dbo.ScoreComponentValueConfig(9, Rop, @lrprtcfgid),
		Rop2Component = dbo.ScoreComponentValueConfig(41, Rop2, @lrprtcfgid),
		OverSpeedComponent = dbo.ScoreComponentValueConfig(10, OverSpeed, @lrprtcfgid),
		OverSpeedHighComponent = dbo.ScoreComponentValueConfig(32, OverSpeedHigh, @lrprtcfgid),
		OverSpeedDistanceComponent = dbo.ScoreComponentValueConfig(21, OverSpeedDistance, @lrprtcfgid),
		IVHOverSpeedComponent = dbo.ScoreComponentValueConfig(30, IVHOverSpeed, @lrprtcfgid),
		CoastOutOfGearComponent = dbo.ScoreComponentValueConfig(11, CoastOutOfGear, @lrprtcfgid),
		CostInGearComponent = dbo.ScoreComponentValueConfig(5, CoastInGear, @lrprtcfgid),
		HarshBrakingComponent = dbo.ScoreComponentValueConfig(12, HarshBraking, @lrprtcfgid),
		SpeedGaugeComponent = dbo.ScoreComponentValueConfig(59, SpeedGauge, @lrprtcfgid)

	FROM
		(SELECT
			SUM(InSweetSpotDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0))) AS SweetSpot,
			SUM(FueledOverRPMDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0))) AS OverRevWithFuel,
			SUM(TopGearDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0))) AS TopGear,
			SUM(CruiseControlDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0))) AS Cruise,
			--Proof of concept. CruiseInTopGearsDistance should be used in production as soon as firmware is released.
			dbo.CAP(SUM(CruiseControlDistance) / dbo.ZeroYieldNull(SUM(TopGearDistance + ISNULL(GearDownDistance,0))), 1.0) AS CruiseInTopGears,
			--SUM(CruiseInTopGearsDistance) / dbo.ZeroYieldNull(SUM(TopGearDistance + ISNULL(GearDownDistance,0))) AS CruiseInTopGears,
			SUM(CoastInGearDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0))) AS CoastInGear,
			SUM(CruiseControlDistance) / dbo.ZeroYieldNull(SUM(TopGearDistance)) AS CruiseTopGearRatio,
			CAST(SUM(IdleTime) AS float) / dbo.ZeroYieldNull(SUM(TotalTime)) AS Idle,
			CAST(SUM(PTOMovingTime) + SUM(PTONonMovingTime) AS float) / dbo.ZeroYieldNull(SUM(TotalTime)) AS Pto,
			--ISNULL((SUM(TotalFuel) * 2639.1 * @co2mult) / dbo.ZeroYieldNull(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0))),0) AS Co2, --@co2mult: 1 for g/km, 1.6 for g/miles
			ISNULL((SUM(TotalFuel * ISNULL(f.CO2ScaleFactor, 2639.1) * @co2mult)) / dbo.ZeroYieldNull(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0))),0) AS Co2, --@co2mult: 1 for g/km, 1.6 for g/miles
			SUM(TotalTime) AS TotalTime,
			SUM(ServiceBrakeDistance) / CASE WHEN SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) = 0 THEN NULL ELSE SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) END AS ServiceBrakeUsage,
			ISNULL(SUM(EngineBrakeDistance) / dbo.ZeroYieldNull(SUM(ServiceBrakeDistance + EngineBrakeDistance)),0) AS EngineServiceBrake,
			ISNULL(SUM(EngineBrakeOverRPMDistance) / dbo.ZeroYieldNull(SUM(EngineBrakeDistance)),0) AS OverRevWithoutFuel,
			ISNULL((SUM(ROPCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS Rop,
			ISNULL((SUM(ROP2Count) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS Rop2,
			ISNULL(SUM(ro.OverSpeedDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0))),0) AS OverSpeed,
			ISNULL(SUM(ro.OverSpeedHighDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0))),0) AS OverSpeedHigh,
			ISNULL(SUM(ro.OverSpeedDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0))),0) AS OverSpeedDistance, 
			ISNULL(SUM(r.OverSpeedDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0))),0) AS IVHOverSpeed,

			ISNULL(SUM(ro.Incidents) / CAST(SUM(ro.Observations) AS FLOAT), 0) AS SpeedGauge,
			ISNULL(SUM(abc.AccelerationHigh),0) AS AccelerationHighCount,
			ISNULL(SUM(abc.BrakingHigh),0) AS BrakingHighCount,
			ISNULL(SUM(abc.CorneringHigh),0) AS CorneringHighCount,
			ISNULL(SUM(abc.AccelerationLow + abc.BrakingLow + abc.CorneringLow),0) AS ManoeuvresLowCount,
			ISNULL(SUM(abc.Acceleration + abc.Braking + abc.Cornering),0) AS ManoeuvresMedCount,
			ISNULL(SUM(ROPCount),0) AS RopCount,
			ISNULL(SUM(ROP2Count),0) AS Rop2Count,

			ISNULL(SUM(CoastOutOfGearDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0))),0) AS CoastOutOfGear,
			ISNULL((SUM(PanicStopCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS HarshBraking,
			SUM(DrivingDistance * 1000 * @distmult) AS TotalDrivingDistance,
			ISNULL((SUM(ORCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS OverRevCount,
			
			ISNULL((SUM(abc.Acceleration) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS Acceleration,
			ISNULL((SUM(abc.Braking) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS Braking,
			ISNULL((SUM(abc.Cornering) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS Cornering,

			ISNULL((SUM(abc.AccelerationLow) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS AccelerationLow,
			ISNULL((SUM(abc.BrakingLow) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS BrakingLow,
			ISNULL((SUM(abc.CorneringLow) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS CorneringLow,
		
			ISNULL((SUM(abc.AccelerationHigh) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS AccelerationHigh,
			ISNULL((SUM(abc.BrakingHigh) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS BrakingHigh,
			ISNULL((SUM(abc.CorneringHigh) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS CorneringHigh,

			ISNULL((SUM(abc.AccelerationLow + abc.BrakingLow + abc.CorneringLow) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS ManoeuvresLow,
			ISNULL((SUM(abc.Acceleration + abc.Braking + abc.Cornering) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS ManoeuvresMed,

			(CASE WHEN @fuelmult = 0.1 THEN
				(CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel * ISNULL(FuelMultiplier,1.0))*100 END)/SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) 
			ELSE
				(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * 1000) / (CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel * ISNULL(FuelMultiplier,1.0)) END) * @fuelmult END) AS FuelEcon
				
		FROM dbo.Reporting r
			INNER JOIN @vehicles veh ON r.VehicleIntId = veh.VehicleIntId
			INNER JOIN dbo.Vehicle v ON r.VehicleIntId = v.VehicleIntId
			LEFT JOIN dbo.FuelType f ON f.FuelTypeId = v.FuelTypeId
			LEFT JOIN dbo.ReportingABC abc ON r.VehicleIntId = abc.VehicleIntId AND r.DriverIntId = abc.DriverIntId AND r.Date = abc.Date --AND r.RouteID = abc.RouteId
			LEFT JOIN dbo.ReportingOverspeed ro ON r.VehicleIntId = ro.VehicleIntId AND r.DriverIntId = ro.DriverIntId AND r.Date = ro.Date --AND r.RouteID = ro.RouteId

		WHERE r.Date BETWEEN @lsdate AND @ledate 
		  --AND (v.VehicleId IN (SELECT Value FROM dbo.Split(dbo.GetFleetVids(@luid), ',')) OR dbo.GetFleetVids(@luid) IS NULL)
          AND r.DrivingDistance > 0
		HAVING SUM(DrivingDistance) > 10 ) o
	) p





GO
