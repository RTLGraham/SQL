SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_AirProductsSafety_Fleet]
(
	@gids NVARCHAR(MAX),
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

	--SET @sdate = '2016-04-01 00:00'
	--SET @edate = '2016-04-30 23:59'
	--SET @uid = N'988d25de-65e9-4fc5-8981-3d2b4ea0feab'
	--SET	@rprtcfgid = N'dda2fb34-1ab1-4ed7-a53e-bb974edd2941'

	--DECLARE @gids NVARCHAR(MAX)

	--SELECT @gids = COALESCE(@gids + ',', '') + CAST(g.GroupId AS VARCHAR(MAX))
	--FROM Vehicle v
	--	INNER JOIN dbo.GroupDetail gd ON gd.EntityDataId = v.VehicleId
	--	INNER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId
	--	INNER JOIN dbo.UserGroup ug ON ug.GroupId = g.GroupId
	--WHERE g.GroupTypeId = 1 
	--	AND g.GroupName NOT LIKE '%*%' 
	--	AND g.GroupName NOT LIKE '%$%' 
	--	AND g.GroupName NOT LIKE '%Manage%' 
	--	AND g.GroupName NOT LIKE '%Phil%'
	--	AND g.IsParameter = 0 
	--	AND g.Archived = 0
	--	AND ug.UserId = @uid


	DECLARE @lsdate datetime,
			@ledate datetime,
			@luid UNIQUEIDENTIFIER,
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
			@co2mult FLOAT


	SELECT @diststr = dbo.UserPref(@luid, 203)
	SELECT @distmult = dbo.UserPref(@luid, 202)
	SELECT @fuelstr = dbo.UserPref(@luid, 205)
	SELECT @fuelmult = dbo.UserPref(@luid, 204)
	SELECT @co2str = dbo.UserPref(@luid, 211)
	SELECT @co2mult = dbo.UserPref(@luid, 210)

	--SET @lsdate = dbo.TZ_ToUTC(@lsdate,default,@luid)
	--SET @ledate = dbo.TZ_ToUTC(@ledate,default,@luid)

	SELECT
			--Group
		
			g.GroupId,
			g.GroupName,
 		
			TotalDrivingDistance,

 			-- Data columns with corresponding colours below 
			ROUND(Efficiency, 4) AS Efficiency, 
			ROUND(SweetSpot, 4) AS SweetSpot, 
			ROUND(OverRevWithFuel, 4) AS OverRev,  
			ROUND(Idle, 4) AS Idle, 
			ROUND(FuelEcon, 2) AS FuelEcon,
		
			ROUND(Safety, 4) AS Safety,
			ROUND(OverSpeedDistance, 4) AS OverSpeed,
			ROUND(Rop, 2) AS Rop, 
			ROUND(Rop2, 2) AS Rop2,
			ROUND(ManoeuvresLow, 2) AS Low,
			ROUND(ManoeuvresMed, 2) AS Med,
			ROUND(AccelerationHigh, 2) AS Acceleration, 
			ROUND(BrakingHigh, 2) AS Braking, 
			ROUND(CorneringHigh, 2) AS Cornering
		
			--,

		

			--OverSpeedHigh,
			--OverSpeedDistance, 
			--IVHOverSpeed,
			--CoastOutOfGear, 
			--HarshBraking, 
			--Pto, 
			--Co2, 
			--CruiseTopGearRatio,
			--Acceleration, 
			--Braking, 
			--Cornering,
			--AccelerationLow, 
			--BrakingLow, 
			--CorneringLow,
				
			-- Component Columns
			--SweetSpotComponent,
			--OverRevWithFuelComponent,
			--TopGearComponent,
			--CruiseComponent,
			--CruiseInTopGearsComponent,
			--IdleComponent,
			--EngineServiceBrakeComponent,
			--OverRevWithoutFuelComponent,
			--RopComponent,
			--Rop2Component,
			--OverSpeedComponent,
			--OverSpeedHighComponent,
			--OverSpeedDistanceComponent,
			--IVHOverSpeedComponent,
			--CoastOutOfGearComponent,
			--HarshBrakingComponent,
			--AccelerationComponent,
			--BrakingComponent,
			--CorneringComponent,
			--AccelerationLowComponent,
			--BrakingLowComponent,
			--CorneringLowComponent,
			--AccelerationHighComponent,
			--BrakingHighComponent,
			--CorneringHighComponent,
			--ManoeuvresLowComponent,
			--ManoeuvresMedComponent,
		
			-- Score columns

			-- Additional columns with no corresponding colour	
			--TotalTime,
			--ServiceBrakeUsage,	
			--OverRevCount,
		
			-- Date and Unit columns 
			,@lsdate AS sdate,
			@ledate AS edate
			--dbo.TZ_GetTime(@lsdate,default,@luid) AS CreationDateTime,
			--dbo.TZ_GetTime(@ledate,default,@luid) AS ClosureDateTime,

			--@diststr AS DistanceUnit,
			--@fuelstr AS FuelUnit,
			--@co2str AS Co2Unit,
			--@fuelmult AS FuelMult,

			---- Colour columns corresponding to data columns above
			,dbo.GYRColourConfig(Efficiency, 14, @lrprtcfgid) AS EfficiencyColour,
			dbo.GYRColourConfig(SweetSpot*100, 1, @lrprtcfgid) AS SweetSpotColour,
			dbo.GYRColourConfig(OverRevWithFuel*100, 2, @lrprtcfgid) AS OverRevWithFuelColour,
			dbo.GYRColourConfig(Idle*100, 6, @lrprtcfgid) AS IdleColour,
		
			dbo.GYRColourConfig(Safety, 15, @lrprtcfgid) AS SafetyColour,
			dbo.GYRColourConfig(OverSpeed*100, 10, @lrprtcfgid) AS OverSpeedColour, 
			dbo.GYRColourConfig(OverSpeedDistance * 100, 21, @lrprtcfgid) AS OverSpeedDistanceColour,
			dbo.GYRColourConfig(Rop, 9, @lrprtcfgid) AS RopColour,
			dbo.GYRColourConfig(Rop2, 41, @lrprtcfgid) AS Rop2Colour,
			dbo.GYRColourConfig(AccelerationLow + BrakingLow + CorneringLow, 39, @lrprtcfgid) AS ManoeuvresLowColour,
			dbo.GYRColourConfig(Acceleration + Braking + Cornering, 40, @lrprtcfgid) AS ManoeuvresMedColour,
			dbo.GYRColourConfig(AccelerationHigh, 36, @lrprtcfgid) AS AccelerationHighColour,
			dbo.GYRColourConfig(BrakingHigh, 37, @lrprtcfgid) AS BrakingHighColour,
			dbo.GYRColourConfig(CorneringHigh, 38, @lrprtcfgid) AS CorneringHighColour
	FROM
		(
			SELECT *,
		
			Safety = dbo.ScoreByClassConfig('S', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, @lrprtcfgid),
			Efficiency = dbo.ScoreByClassConfig('E', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, @lrprtcfgid)
		
			--,
			--SweetSpotComponent = dbo.ScoreComponentValueConfig(1, SweetSpot, @lrprtcfgid),
			--OverRevWithFuelComponent = dbo.ScoreComponentValueConfig(2, OverRevWithFuel, @lrprtcfgid),
			--TopGearComponent = dbo.ScoreComponentValueConfig(3, TopGear, @lrprtcfgid),
			--CruiseComponent = dbo.ScoreComponentValueConfig(4, Cruise, @lrprtcfgid),
			--CruiseInTopGearsComponent = dbo.ScoreComponentValueConfig(31, CruiseInTopGears, @lrprtcfgid),
			--IdleComponent = dbo.ScoreComponentValueConfig(6, Idle, @lrprtcfgid),
		
			--AccelerationComponent = dbo.ScoreComponentValueConfig(22, Acceleration, @lrprtcfgid),
			--BrakingComponent = dbo.ScoreComponentValueConfig(23, Braking, @lrprtcfgid),
			--CorneringComponent = dbo.ScoreComponentValueConfig(24, Cornering, @lrprtcfgid),
						
			--AccelerationLowComponent = dbo.ScoreComponentValueConfig(33, AccelerationLow, @lrprtcfgid),
			--BrakingLowComponent = dbo.ScoreComponentValueConfig(34, BrakingLow, @lrprtcfgid),
			--CorneringLowComponent = dbo.ScoreComponentValueConfig(35, CorneringLow, @lrprtcfgid),
		
			--AccelerationHighComponent = dbo.ScoreComponentValueConfig(36, AccelerationHigh, @lrprtcfgid),
			--BrakingHighComponent = dbo.ScoreComponentValueConfig(37, BrakingHigh, @lrprtcfgid),
			--CorneringHighComponent = dbo.ScoreComponentValueConfig(38, CorneringHigh, @lrprtcfgid),

			--ManoeuvresLowComponent = dbo.ScoreComponentValueConfig(39, AccelerationLow + BrakingLow + CorneringLow, @lrprtcfgid),
			--ManoeuvresMedComponent = dbo.ScoreComponentValueConfig(40, Acceleration + Braking + Cornering, @lrprtcfgid),
		
			--EngineServiceBrakeComponent = dbo.ScoreComponentValueConfig(7, EngineServiceBrake, @lrprtcfgid),
			--OverRevWithoutFuelComponent = dbo.ScoreComponentValueConfig(8, OverRevWithoutFuel, @lrprtcfgid),
			--RopComponent = dbo.ScoreComponentValueConfig(9, Rop, @lrprtcfgid),
			--Rop2Component = dbo.ScoreComponentValueConfig(41, Rop2, @lrprtcfgid),
			--OverSpeedComponent = dbo.ScoreComponentValueConfig(10, OverSpeed, @lrprtcfgid),
			--OverSpeedHighComponent = dbo.ScoreComponentValueConfig(32, OverSpeedHigh, @lrprtcfgid),
			--OverSpeedDistanceComponent = dbo.ScoreComponentValueConfig(21, OverSpeedDistance, @lrprtcfgid),
			--IVHOverSpeedComponent = dbo.ScoreComponentValueConfig(30, IVHOverSpeed, @lrprtcfgid),
			--CoastOutOfGearComponent = dbo.ScoreComponentValueConfig(11, CoastOutOfGear, @lrprtcfgid),
			--HarshBrakingComponent = dbo.ScoreComponentValueConfig(12, HarshBraking, @lrprtcfgid)

		FROM
			(SELECT
				CASE WHEN (GROUPING(vg.GroupId) = 1) THEN NULL
					ELSE ISNULL(vg.GroupId, NULL)
				END AS GroupId,
			
				--CASE WHEN (GROUPING(v.VehicleId) = 1) THEN NULL
				--	ELSE ISNULL(v.VehicleId, NULL)
				--END AS VehicleId,

				--CASE WHEN (GROUPING(d.DriverId) = 1) THEN NULL
				--	ELSE ISNULL(d.DriverId, NULL)
				--END AS DriverId,

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
				ISNULL((SUM(TotalFuel) * 2639.1 * @co2mult) / dbo.ZeroYieldNull(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0))),0) AS Co2, --@co2mult: 1 for g/km, 1.6 for g/miles
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
				
			FROM [dbo].Reporting r
				INNER JOIN dbo.Vehicle v ON r.VehicleIntId = v.VehicleIntId
				INNER JOIN dbo.GroupDetail vgd ON v.VehicleId = vgd.EntityDataId
				INNER JOIN dbo.[Group] vg ON vgd.GroupId = vg.GroupId 
				LEFT JOIN dbo.ReportingABC abc ON r.VehicleIntId = abc.VehicleIntId AND r.DriverIntId = abc.DriverIntId AND r.Date = abc.Date --AND r.RouteID = abc.RouteId
				LEFT JOIN dbo.ReportingOverspeed ro ON r.VehicleIntId = ro.VehicleIntId AND r.DriverIntId = ro.DriverIntId AND r.Date = ro.Date --AND r.RouteID = ro.RouteId

			WHERE r.Date BETWEEN @lsdate AND @ledate 
				AND r.DrivingDistance > 0
				AND vg.IsParameter = 0 
				AND vg.Archived = 0 
				AND vg.GroupId IN (SELECT Value FROM dbo.Split(@gids, ','))
			GROUP BY vg.GroupId WITH CUBE
			HAVING SUM(DrivingDistance) > 10 ) o
		) p
	LEFT JOIN dbo.[Group] g ON p.GroupId = g.GroupId AND g.IsParameter = 0 AND g.Archived = 0
	WHERE p.GroupId IS NULL

GO
