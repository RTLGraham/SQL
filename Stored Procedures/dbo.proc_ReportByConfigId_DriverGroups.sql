SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportByConfigId_DriverGroups]
(
	@gids VARCHAR(MAX),
	@dids varchar(max),
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER
)
AS




--DECLARE	@gids VARCHAR(MAX),
--		@dids VARCHAR(MAX),
--		@sdate datetime,
--		@edate datetime,
--		@uid uniqueidentifier,
--		@rprtcfgid uniqueidentifier

--SET @gids = N'7E59A031-E9F3-445D-872E-D841F6F8FC19'
----SET @dids = N'1B5600D4-85AE-4A78-B071-2EE555EB3300,5E9679AC-1B6F-4700-97E8-53BB46B0BC01,0D572BAC-D832-4D53-A192-7F7C56E1D37B,98E7ECE2-6AA1-41D9-BAA9-8B9CAB5D5FD2,983AEB57-6600-42C3-BA24-8D307F5AD57F,BB3428A6-B8A5-4E7A-A081-99806369285F,071410D1-1B88-40E7-8D81-ADE51D9683E9,26C8A9B2-2EB9-49A1-8C8D-DFBA04C697C3,0071EDE5-3222-4A5F-A00C-EB679C17B6FC,51D84E06-84FB-451C-8A02-F86F0219C39A,653D6FF3-89F4-4F3F-A077-0C6E47900018,B8706BAA-802A-4D6F-AD48-2483EB3F1440,4093F926-6641-4B3B-B685-27580A8F744C,1AC3CD49-6437-432A-B997-2F4E75D8E5F0,8E1599F9-6B40-4618-A763-51DF2AE45D33,B29B651E-A445-43FD-8612-52DB8C864C1B,22F3197D-8AFC-4C99-BA0F-5D56BDBB3AE7,C246B423-566E-4515-85F7-86483E18E53D,2717171E-55E3-448F-8247-AD28A14BE218,E8DB0498-41E8-4BD5-A86E-D205529026E6,632F6669-E03E-4F95-B01A-E5CE3385209E,74777228-5642-45D2-999A-E83B62290D4A,AB0B496F-0659-495D-AD3D-EB5274BDC73C,0DDD3AC9-DC29-4C91-B3BE-F2B192F30C59,301367B7-8822-417A-B9D6-F3513907B2D4'
--SET @dids = N'0BA5EB36-4A1F-4A72-8D31-E7A08DD27501'
--SET @sdate = '2020-04-01 00:00'
--SET @edate = '2020-06-30 23:59'
--SET @uid = N'5AADE864-607A-4D10-ACB0-27D63936124D'
--SET @rprtcfgid = N'29DBEDE3-A407-4D13-9FA7-59F2002C9A50'

DECLARE @lgids VARCHAR(MAX),
		@ldids varchar(max),
		@lsdate datetime,
		@ledate datetime,
		@luid UNIQUEIDENTIFIER,
		@lrprtcfgid UNIQUEIDENTIFIER
		
SET @lgids = @gids
SET @ldids = @dids
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

SELECT @diststr = [dbo].UserPref(@luid, 203)
SELECT @distmult = [dbo].UserPref(@luid, 202)
SELECT @fuelstr = [dbo].UserPref(@luid, 205)
SELECT @fuelmult = [dbo].UserPref(@luid, 204)
SELECT @co2str = [dbo].UserPref(@luid, 211)
SELECT @co2mult = [dbo].UserPref(@luid, 210)

--SET @lsdate = [dbo].TZ_ToUTC(@lsdate,default,@luid)
--SET @ledate = [dbo].TZ_ToUTC(@ledate,default,@luid)

SELECT
		--Group
		
		g.GroupId,
		g.GroupName,
		g.GroupTypeID,
 		
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
		CruiseOverspeed,
		TopGearOverspeed,
		0 AS FuelWastageCost,

			OverspeedCount,
			OverspeedHighCount,
			StabilityControl,
			CollisionWarningLow,
			CollisionWarningMed,
			CollisionWarningHigh,
			LaneDepartureDisable,
			LaneDepartureLeftRight,
			Fatigue,
			Distraction,
			SweetSpotTime,
			OverRevTime,
			TopGearTime,
				
		-- Component Columns
		SweetSpotComponent,
		OverRevWithFuelComponent,
		TopGearComponent,
		CruiseComponent,
		CruiseInTopGearsComponent,
		IdleComponent,
		EngineServiceBrakeComponent,
		OverRevWithoutFuelComponent,
		RopComponent,
		Rop2Component,
		OverSpeedComponent,
		OverSpeedDistanceComponent,
		IVHOverSpeedComponent,

		SpeedGaugeComponent,

		CoastOutOfGearComponent,
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
		CruiseOverspeedComponent,
		TopGearOverspeedComponent,
			
			OverspeedCountComponent,
			OverspeedHighCountComponent,
			StabilityControlComponent,
			CollisionWarningLowComponent,
			CollisionWarningMedComponent,
			CollisionWarningHighComponent,
			LaneDepartureDisableComponent,
			LaneDepartureLeftRightComponent,
			FatigueComponent,
			DistractionComponent,
			SweetSpotTimeComponent,
			OverRevTimeComponent,
			TopGearTimeComponent,
						
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
		dbo.GYRColourConfig(CruiseInTopGears*100, 31, @lrprtcfgid) AS CruiseInTopGearsColour,
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
		dbo.GYRColourConfig(CruiseOverspeed*100, 43, @lrprtcfgid) AS CruiseOverspeedColour,
		dbo.GYRColourConfig(TopGearOverspeed*100, 42, @lrprtcfgid) AS TopGearOverspeedColour,
		NULL AS FuelWastageCostColour,

			dbo.GYRColourConfig(OverspeedCount, 46, @lrprtcfgid) AS OverspeedCountColour,
			dbo.GYRColourConfig(OverspeedHighCount, 47, @lrprtcfgid) AS OverspeedHighCountColour,
			dbo.GYRColourConfig(StabilityControl, 48, @lrprtcfgid) AS StabilityControlColour,
			dbo.GYRColourConfig(CollisionWarningLow, 49, @lrprtcfgid) AS CollisionWarningLowColour,
			dbo.GYRColourConfig(CollisionWarningMed, 50, @lrprtcfgid) AS CollisionWarningMedColour,
			dbo.GYRColourConfig(CollisionWarningHigh, 51, @lrprtcfgid) AS CollisionWarningHighColour,
			dbo.GYRColourConfig(LaneDepartureDisable, 52, @lrprtcfgid) AS LaneDepartureDisableColour,
			dbo.GYRColourConfig(LaneDepartureLeftRight, 53, @lrprtcfgid) AS LaneDepartureLeftRightColour,
			dbo.GYRColourConfig(Fatigue, 57, @lrprtcfgid) AS FatigueColour,
			dbo.GYRColourConfig(Distraction, 58, @lrprtcfgid) AS DistractionColour,
			dbo.GYRColourConfig(SweetSpotTime*100, 54, @lrprtcfgid) AS SweetSpotTimeColour,
			dbo.GYRColourConfig(OverRevTime*100, 55, @lrprtcfgid) AS OverRevTimeColour,
			dbo.GYRColourConfig(TopGearTime*100, 56, @lrprtcfgid) AS TopGearTimeColour,
			dbo.GYRColourConfig(SpeedGauge*100, 59, @lrprtcfgid) AS SpeedGaugeColour
FROM
	(
		SELECT *,
		
		Safety = dbo.ScoreByClassAndConfigPlus('S', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2,  CruiseOverspeed,TopGearOverspeed, OverspeedCount, OverspeedHighCount, StabilityControl, CollisionWarningLow, CollisionWarningMed, CollisionWarningHigh, LaneDepartureDisable, LaneDepartureLeftRight, SweetSpotTime, OverRevTime, TopGearTime, Fatigue, Distraction,SpeedGauge, @lrprtcfgid),
		Efficiency = dbo.ScoreByClassAndConfigPlus('E', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2,  CruiseOverspeed,TopGearOverspeed, OverspeedCount, OverspeedHighCount, StabilityControl, CollisionWarningLow, CollisionWarningMed, CollisionWarningHigh, LaneDepartureDisable, LaneDepartureLeftRight, SweetSpotTime, OverRevTime, TopGearTime, Fatigue, Distraction,SpeedGauge, @lrprtcfgid),
		
		SweetSpotComponent = dbo.ScoreComponentValueConfig(1, SweetSpot, @lrprtcfgid),
		OverRevWithFuelComponent = dbo.ScoreComponentValueConfig(2, OverRevWithFuel, @lrprtcfgid),
		TopGearComponent = dbo.ScoreComponentValueConfig(3, TopGear, @lrprtcfgid),
		CruiseComponent = dbo.ScoreComponentValueConfig(4, Cruise, @lrprtcfgid),
		CruiseInTopGearsComponent = dbo.ScoreComponentValueConfig(31, CruiseInTopGears, @lrprtcfgid),
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
		HarshBrakingComponent = dbo.ScoreComponentValueConfig(12, HarshBraking, @lrprtcfgid),

		CruiseOverspeedComponent = dbo.ScoreComponentValueConfig(43, CruiseOverspeed, @lrprtcfgid),
		TopGearOverspeedComponent = dbo.ScoreComponentValueConfig(42, TopGearOverspeed, @lrprtcfgid),

			OverspeedCountComponent = dbo.ScoreComponentValueConfig(46, OverspeedCount, @lrprtcfgid),
			OverspeedHighCountComponent = dbo.ScoreComponentValueConfig(47, OverspeedHighCount, @lrprtcfgid),
			StabilityControlComponent = dbo.ScoreComponentValueConfig(48, StabilityControl, @lrprtcfgid),
			CollisionWarningLowComponent = dbo.ScoreComponentValueConfig(49, CollisionWarningLow, @lrprtcfgid),
			CollisionWarningMedComponent = dbo.ScoreComponentValueConfig(50, CollisionWarningMed, @lrprtcfgid),
			CollisionWarningHighComponent = dbo.ScoreComponentValueConfig(51, CollisionWarningHigh, @lrprtcfgid),
			LaneDepartureDisableComponent = dbo.ScoreComponentValueConfig(52, LaneDepartureDisable, @lrprtcfgid),
			LaneDepartureLeftRightComponent = dbo.ScoreComponentValueConfig(53, LaneDepartureLeftRight, @lrprtcfgid),
			FatigueComponent = dbo.ScoreComponentValueConfig(57, Fatigue, @lrprtcfgid),
			DistractionComponent = dbo.ScoreComponentValueConfig(58, Distraction, @lrprtcfgid),
			SweetSpotTimeComponent = dbo.ScoreComponentValueConfig(54, SweetSpotTime, @lrprtcfgid),
			OverRevTimeComponent = dbo.ScoreComponentValueConfig(55, OverRevTime, @lrprtcfgid),
			TopGearTimeComponent = dbo.ScoreComponentValueConfig(56, TopGearTime, @lrprtcfgid),
			SpeedGaugeComponent = dbo.ScoreComponentValueConfig(59, SpeedGauge, @lrprtcfgid)

	FROM
		(SELECT
			CASE WHEN (GROUPING(dg.GroupId) = 1) THEN NULL
				ELSE ISNULL(dg.GroupId, NULL)
			END AS GroupId,

			SUM(InSweetSpotDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0))) AS SweetSpot,
			SUM(FueledOverRPMDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0))) AS OverRevWithFuel,
			SUM(TopGearDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0))) AS TopGear,
			SUM(CruiseControlDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0))) AS Cruise,
			--Proof of concept. CruiseInTopGearsDistance should be used in production as soon as firmware is released.
			--dbo.CAP(SUM(CruiseControlDistance) / dbo.ZeroYieldNull(SUM(TopGearDistance + ISNULL(GearDownDistance,0))), 1.0) AS CruiseInTopGears,
			SUM(CruiseInTopGearsDistance) / dbo.ZeroYieldNull(SUM(TopGearDistance + ISNULL(GearDownDistance,0))) AS CruiseInTopGears,
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

			ISNULL(SUM(r.CruiseSpeedingDistance) / dbo.ZeroYieldNull(SUM(r.OverSpeedThresholdDistance)), 0) AS CruiseOverspeed,
			ISNULL(SUM(r.TopGearSpeedingDistance) / dbo.ZeroYieldNull(SUM(r.OverSpeedThresholdDistance)), 0) AS TopGearOverspeed,

			SUM(FuelWastage) AS FuelWastage,

				ISNULL((SUM(re.OverspeedCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS OverspeedCount,
				ISNULL((SUM(re.OverspeedHighCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS OverspeedHighCount,
				ISNULL((SUM(re.StabilityCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS StabilityControl,
				ISNULL((SUM(re.CollisionWarningLow) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS CollisionWarningLow,
				ISNULL((SUM(re.CollisionWarningMed) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS CollisionWarningMed,
				ISNULL((SUM(re.CollisionWarningHigh) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS CollisionWarningHigh,
				ISNULL((SUM(re.LaneDepartureDisableCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS LaneDepartureDisable,
				ISNULL((SUM(re.LaneDepartureLeftRightCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS LaneDepartureLeftRight,
				ISNULL((SUM(re.Fatigue) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS Fatigue,
				ISNULL((SUM(re.Distraction) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS Distraction,
				ISNULL(CAST(SUM(re.SweetSpotTime) AS float) / dbo.ZeroYieldNull(SUM(r.TotalTime)), 0) AS SweetSpotTime,
				ISNULL(CAST(SUM(re.OverRPMTime) AS float) / dbo.ZeroYieldNull(SUM(r.TotalTime)), 0) AS OverRevTime,
				ISNULL(CAST(SUM(re.TopGearTime) AS float) / dbo.ZeroYieldNull(SUM(r.TotalTime)), 0) AS TopGearTime,

			(CASE WHEN @fuelmult = 0.1 THEN
				(CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel * ISNULL(FuelMultiplier,1.0))*100 END)/SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) 
			ELSE
				(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * 1000) / (CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel * ISNULL(FuelMultiplier,1.0)) END) * @fuelmult END) AS FuelEcon
				
		FROM dbo.Reporting r
			INNER JOIN dbo.Vehicle v ON r.VehicleIntId = v.VehicleIntId
			INNER JOIN dbo.Driver d ON r.DriverIntId = d.DriverIntId
			LEFT OUTER JOIN dbo.GroupDetail dgd ON d.DriverId = dgd.EntityDataId
			LEFT OUTER JOIN dbo.[Group] dg ON dgd.GroupId = dg.GroupId 
			LEFT JOIN dbo.ReportingABC abc ON r.VehicleIntId = abc.VehicleIntId AND r.DriverIntId = abc.DriverIntId AND r.Date = abc.Date --AND r.RouteID = abc.RouteId
			LEFT JOIN dbo.ReportingOverspeed ro ON r.VehicleIntId = ro.VehicleIntId AND r.DriverIntId = ro.DriverIntId AND r.Date = ro.Date --AND r.RouteID = ro.RouteId
			LEFT JOIN dbo.ReportingExtra re ON r.VehicleIntId = re.VehicleIntId AND r.DriverIntId = re.DriverIntId AND r.Date = re.Date

		WHERE r.Date BETWEEN @lsdate AND @ledate 
			AND (d.DriverId IN (SELECT Value FROM dbo.Split(@ldids, ',')) OR @ldids IS NULL)
			AND r.DrivingDistance > 0
			AND dg.IsParameter = 0 
			AND dg.Archived = 0 
			AND dg.GroupId IN (SELECT Value FROM dbo.Split(@lgids, ','))
		GROUP BY dg.GroupId WITH CUBE
		HAVING SUM(DrivingDistance) > 10 ) o
	) p
LEFT JOIN dbo.[Group] g ON p.GroupId = g.GroupId AND g.IsParameter = 0 AND g.Archived = 0

ORDER BY GroupName


GO
