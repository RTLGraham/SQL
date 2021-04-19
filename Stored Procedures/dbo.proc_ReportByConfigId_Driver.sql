SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportByConfigId_Driver]
(
	@dids VARCHAR(MAX),
	@sdate DATETIME,
	@edate DATETIME,
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER
)
AS


--DECLARE	@dids VARCHAR(MAX),
--		@sdate datetime,
--		@edate datetime,
--		@uid uniqueidentifier,
--		@rprtcfgid uniqueidentifier

--SET @dids = N'0BA5EB36-4A1F-4A72-8D31-E7A08DD27501'
--SET @sdate = '2020-04-01 00:00'
--SET @edate = '2020-06-30 23:59'
--SET @uid = N'5AADE864-607A-4D10-ACB0-27D63936124D'
--SET @rprtcfgid = N'29DBEDE3-A407-4D13-9FA7-59F2002C9A50'


DECLARE	@lvids varchar(max),
		@ldids VARCHAR(MAX),
		@lsdate datetime,
		@ledate datetime,
		@luid uniqueidentifier,
		@lrprtcfgid UNIQUEIDENTIFIER
		
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
		@co2mult float

SELECT @diststr = [dbo].UserPref(@luid, 203)
SELECT @distmult = [dbo].UserPref(@luid, 202)
SELECT @fuelstr = [dbo].UserPref(@luid, 205)
SELECT @fuelmult = [dbo].UserPref(@luid, 204)
SELECT @co2str = [dbo].UserPref(@luid, 211)
SELECT @co2mult = [dbo].UserPref(@luid, 210)

--SET @lsdate = [dbo].TZ_ToUTC(@lsdate,default,@luid)
--SET @ledate = [dbo].TZ_ToUTC(@ledate,default,@luid)

DECLARE @RedColour VARCHAR(50)
DECLARE @YellowColour VARCHAR(50)
DECLARE @GreenColour VARCHAR(50)
DECLARE @GoldColour VARCHAR(50)
DECLARE @SilverColour VARCHAR(50)
DECLARE @BronzeColour VARCHAR(50)
DECLARE @CopperColour VARCHAR(50)
SET @RedColour = 'Red'
SET @YellowColour = 'Amber'
SET @GreenColour = 'Green'
SET @GoldColour = 'Gold'
SET @SilverColour = 'Silver'
SET @BronzeColour = 'Bronze'
SET @CopperColour = 'Copper'



DECLARE @assets TABLE
(
	Id UNIQUEIDENTIFIER,
	IntId INT 
)
INSERT INTO @assets (Id, IntId)
SELECT DISTINCT DriverId, DriverIntId
FROM dbo.Driver
WHERE DriverId IN (SELECT Value FROM dbo.Split(@dids, ','))
	AND Archived = 0

-- Declare Table for interim data collection
DECLARE @data TABLE
(
		VehicleId UNIQUEIDENTIFIER,	
		DriverId UNIQUEIDENTIFIER,


 		-- Data columns with corresponding colours below 
		SweetSpot FLOAT, 
		OverRevWithFuel FLOAT, 
		TopGear FLOAT, 
		Cruise FLOAT, 
		CruiseInTopGears FLOAT,
		CoastInGear FLOAT, 
		Idle FLOAT, 
		EngineServiceBrake FLOAT, 
		OverRevWithoutFuel FLOAT, 
		Rop FLOAT,
		Rop2 FLOAT, 
		OverSpeed FLOAT,
		OverSpeedHigh FLOAT,
		OverSpeedDistance FLOAT, 
		IVHOverSpeed FLOAT,

		SpeedGauge FLOAT,
		AccelerationHighCount FLOAT,
		BrakingHighCount FLOAT,
		CorneringHighCount FLOAT,
		ManoeuvresLowCount FLOAT,
		ManoeuvresMedCount FLOAT,
		RopCount FLOAT,
		Rop2Count FLOAT,

		CoastOutOfGear FLOAT, 
		HarshBraking FLOAT, 
		FuelEcon FLOAT,
		Pto FLOAT, 
		Co2 FLOAT, 
		CruiseTopGearRatio FLOAT,
		Acceleration FLOAT, 
		Braking FLOAT, 
		Cornering FLOAT,
		AccelerationLow FLOAT, 
		BrakingLow FLOAT, 
		CorneringLow FLOAT,
		AccelerationHigh FLOAT, 
		BrakingHigh FLOAT, 
		CorneringHigh FLOAT,
		ManoeuvresLow FLOAT,
		ManoeuvresMed FLOAT,
		CruiseOverspeed FLOAT,
		TopGearOverspeed FLOAT,
		OverspeedCount FLOAT,
		OverspeedHighCount FLOAT,
		StabilityControl FLOAT,
		CollisionWarningLow FLOAT,
		CollisionWarningMed FLOAT,
		CollisionWarningHigh FLOAT,
		LaneDepartureDisable FLOAT,
		LaneDepartureLeftRight FLOAT,
		SweetSpotTime FLOAT,
		OverRevTime FLOAT,
		TopGearTime FLOAT,
		Fatigue FLOAT,
		Distraction FLOAT,

		-- Component Columns
		SweetSpotComponent FLOAT,
		OverRevWithFuelComponent FLOAT,
		TopGearComponent FLOAT,
		CruiseComponent FLOAT,
		CruiseInTopGearsComponent FLOAT,
		IdleComponent FLOAT,
		AccelerationComponent FLOAT,
		BrakingComponent FLOAT,
		CorneringComponent FLOAT,
		AccelerationLowComponent FLOAT,
		BrakingLowComponent FLOAT,
		CorneringLowComponent FLOAT,
		AccelerationHighComponent FLOAT,
		BrakingHighComponent FLOAT,
		CorneringHighComponent FLOAT,
		ManoeuvresLowComponent FLOAT,
		ManoeuvresMedComponent FLOAT,				
		EngineServiceBrakeComponent FLOAT,
		OverRevWithoutFuelComponent FLOAT,
		RopComponent FLOAT,
		Rop2Component FLOAT,
		OverSpeedComponent FLOAT,
		OverSpeedHighComponent FLOAT,
		OverSpeedDistanceComponent FLOAT,
		IVHOverSpeedComponent FLOAT,

		SpeedGaugeComponent FLOAT,

		CoastOutOfGearComponent FLOAT,
		HarshBrakingComponent FLOAT,
		CruiseOverspeedComponent FLOAT,
		TopGearOverspeedComponent FLOAT,
		OverspeedCountComponent FLOAT,
		OverspeedHighCountComponent FLOAT,
		StabilityControlComponent FLOAT,
		CollisionWarningLowComponent FLOAT,
		CollisionWarningMedComponent FLOAT,
		CollisionWarningHighComponent FLOAT,
		LaneDepartureDisableComponent FLOAT,
		LaneDepartureLeftRightComponent FLOAT,
		SweetSpotTimeComponent FLOAT,
		OverRevTimeComponent FLOAT,
		TopGearTimeComponent FLOAT,
		FatigueComponent FLOAT,
		DistractionComponent FLOAT,

		-- Score columns
		Efficiency FLOAT, 
		Safety FLOAT,

		-- Additional columns with no corresponding colour	
		TotalTime FLOAT,
		TotalDrivingDistance FLOAT,
		ServiceBrakeUsage FLOAT,	
		OverRevCount FLOAT
)
INSERT INTO @data
        (VehicleId,
         DriverId,
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
         OverspeedCount,
         OverspeedHighCount,
         StabilityControl,
         CollisionWarningLow,
         CollisionWarningMed,
         CollisionWarningHigh,
         LaneDepartureDisable,
         LaneDepartureLeftRight,
         SweetSpotTime,
         OverRevTime,
         TopGearTime,
         Fatigue,
         Distraction,
         SweetSpotComponent,
         OverRevWithFuelComponent,
         TopGearComponent,
         CruiseComponent,
         CruiseInTopGearsComponent,
         IdleComponent,
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
         HarshBrakingComponent,
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
         SweetSpotTimeComponent,
         OverRevTimeComponent,
         TopGearTimeComponent,
         FatigueComponent,
         DistractionComponent,
         Efficiency,
         Safety,
         TotalTime,
         TotalDrivingDistance,
         ServiceBrakeUsage,
         OverRevCount
        )
SELECT
		VehicleId,	
		DriverId,

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
		OverspeedCount,
		OverspeedHighCount,
		StabilityControl,
		CollisionWarningLow,
		CollisionWarningMed,
		CollisionWarningHigh,
		LaneDepartureDisable,
		LaneDepartureLeftRight,
		SweetSpotTime,
		OverRevTime,
		TopGearTime,
		Fatigue,
		Distraction,

		-- Component Columns
		SweetSpotComponent,
		OverRevWithFuelComponent,
		TopGearComponent,
		CruiseComponent,
		CruiseInTopGearsComponent,
		IdleComponent,
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
		HarshBrakingComponent,
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
		SweetSpotTimeComponent,
		OverRevTimeComponent,
		TopGearTimeComponent,
		FatigueComponent,
		DistractionComponent,

		-- Score columns
		SweetSpotComponent + OverRevWithFuelComponent + TopGearComponent + CruiseComponent + CoastInGearComponent + IdleComponent + CruiseTopGearRatioComponent +PtoComponent + CruiseInTopGearsComponent + TopGearOverspeedComponent + CruiseOverspeedComponent + SweetSpotTimeComponent + OverRevTimeComponent + TopGearTimeComponent AS Efficiency, 

		EngineServiceBrakeComponent + OverRevWithoutFuelComponent + RopComponent + Rop2Component + OverSpeedComponent + OverSpeedHighComponent + OverSpeedDistanceComponent + IVHOverSpeedComponent + CoastOutOfGearComponent 
			+ HarshBrakingComponent + CruiseOverspeedComponent + TopGearOverspeedComponent 
			+ AccelerationComponent + BrakingComponent + CorneringComponent + AccelerationLowComponent + BrakingLowComponent + CorneringLowComponent + AccelerationHighComponent + BrakingHighComponent + CorneringHighComponent 
			+ ManoeuvresLowComponent + ManoeuvresMedComponent 
			+ OverspeedCountComponent + OverspeedHighCountComponent + StabilityControlComponent + CollisionWarningLowComponent + CollisionWarningMedComponent + CollisionWarningHighComponent + LaneDepartureDisableComponent + LaneDepartureLeftRightComponent
			+ FatigueComponent + DistractionComponent + SpeedGaugeComponent AS Safety,

		-- Additional columns with no corresponding colour	
		TotalTime,
		TotalDrivingDistance,
		ServiceBrakeUsage,	
		OverRevCount

FROM
	(SELECT o.*,

		--0 AS Safety,-- = dbo.ScoreByClassConfig('S', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, @lrprtcfgid),
		--0 AS Efficiency-- = dbo.ScoreByClassConfig('E', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, @lrprtcfgid)

		CASE WHEN ric1.HighLow = 1 THEN 
			CAST(ric1.Weight * (CASE WHEN ric1.Type='P' THEN SweetSpot * 100 ELSE SweetSpot END - ric1.Min) / CASE WHEN (ric1.Max - ric1.Min) = 0 THEN 1 ELSE (ric1.Max - ric1.Min) END AS FLOAT)
		ELSE CASE WHEN ric1.HighLow = 0 THEN 
			CAST(ric1.Weight * (ric1.Min - CASE WHEN ric1.Type='P' THEN SweetSpot * 100 ELSE SweetSpot END) / CASE WHEN (ric1.Min - ric1.Max) = 0 THEN 1 ELSE (ric1.Min - ric1.Max) END  AS FLOAT)
		ELSE 0
		END END AS SweetSpotComponent,
		CASE WHEN ric2.HighLow = 1 THEN 
			CAST(ric2.Weight * (CASE WHEN ric2.Type='P' THEN OverRevWithFuel * 100 ELSE OverRevWithFuel END - ric2.Min) / CASE WHEN (ric2.Max - ric2.Min) = 0 THEN 1 ELSE (ric2.Max - ric2.Min) END AS FLOAT)
		ELSE CASE WHEN ric2.HighLow = 0 THEN 
			CAST(ric2.Weight * (ric2.Min - CASE WHEN ric2.Type='P' THEN OverRevWithFuel * 100 ELSE OverRevWithFuel END) / CASE WHEN (ric2.Min - ric2.Max) = 0 THEN 1 ELSE (ric2.Min - ric2.Max) END  AS FLOAT)
		ELSE 0
		END END AS OverRevWithFuelComponent,
		CASE WHEN ric3.HighLow = 1 THEN 
			CAST(ric3.Weight * (CASE WHEN ric3.Type='P' THEN TopGear * 100 ELSE TopGear END - ric3.Min) / CASE WHEN (ric3.Max - ric3.Min) = 0 THEN 1 ELSE (ric3.Max - ric3.Min) END AS FLOAT)
		ELSE CASE WHEN ric3.HighLow = 0 THEN 
			CAST(ric3.Weight * (ric3.Min - CASE WHEN ric3.Type='P' THEN TopGear * 100 ELSE TopGear END) / CASE WHEN (ric3.Min - ric3.Max) = 0 THEN 1 ELSE (ric3.Min - ric3.Max) END  AS FLOAT)
		ELSE 0
		END END AS TopGearComponent,
		CASE WHEN ric4.HighLow = 1 THEN 
			CAST(ric4.Weight * (CASE WHEN ric4.Type='P' THEN Cruise * 100 ELSE Cruise END - ric4.Min) / CASE WHEN (ric4.Max - ric4.Min) = 0 THEN 1 ELSE (ric4.Max - ric4.Min) END AS FLOAT)
		ELSE CASE WHEN ric4.HighLow = 0 THEN 
			CAST(ric4.Weight * (ric4.Min - CASE WHEN ric4.Type='P' THEN Cruise * 100 ELSE Cruise END) / CASE WHEN (ric4.Min - ric4.Max) = 0 THEN 1 ELSE (ric4.Min - ric4.Max) END  AS FLOAT)
		ELSE 0
		END END AS CruiseComponent,
		CASE WHEN ric5.HighLow = 1 THEN 
			CAST(ric5.Weight * (CASE WHEN ric5.Type='P' THEN CoastInGear * 100 ELSE CoastInGear END - ric5.Min) / CASE WHEN (ric5.Max - ric5.Min) = 0 THEN 1 ELSE (ric5.Max - ric5.Min) END AS FLOAT)
		ELSE CASE WHEN ric5.HighLow = 0 THEN 
			CAST(ric5.Weight * (ric5.Min - CASE WHEN ric5.Type='P' THEN CoastInGear * 100 ELSE CoastInGear END) / CASE WHEN (ric5.Min - ric5.Max) = 0 THEN 1 ELSE (ric5.Min - ric5.Max) END  AS FLOAT)
		ELSE 0
		END END AS CoastInGearComponent,

		CASE WHEN ric31.HighLow = 1 THEN 
			CAST(ric31.Weight * (CASE WHEN ric31.Type='P' THEN CruiseInTopGears * 100 ELSE CruiseInTopGears END - ric31.Min) / CASE WHEN (ric31.Max - ric31.Min) = 0 THEN 1 ELSE (ric31.Max - ric31.Min) END AS FLOAT)
		ELSE CASE WHEN ric31.HighLow = 0 THEN 
			CAST(ric31.Weight * (ric31.Min - CASE WHEN ric31.Type='P' THEN CruiseInTopGears * 100 ELSE CruiseInTopGears END) / CASE WHEN (ric31.Min - ric31.Max) = 0 THEN 1 ELSE (ric31.Min - ric31.Max) END  AS FLOAT)
		ELSE 0
		END END AS CruiseInTopGearsComponent,
				CASE WHEN ric6.HighLow = 1 THEN 
			CAST(ric6.Weight * (CASE WHEN ric6.Type='P' THEN Idle * 100 ELSE Idle END - ric6.Min) / CASE WHEN (ric6.Max - ric6.Min) = 0 THEN 1 ELSE (ric6.Max - ric6.Min) END AS FLOAT)
		ELSE CASE WHEN ric6.HighLow = 0 THEN 
			CAST(ric6.Weight * (ric6.Min - CASE WHEN ric6.Type='P' THEN Idle * 100 ELSE Idle END) / CASE WHEN (ric6.Min - ric6.Max) = 0 THEN 1 ELSE (ric6.Min - ric6.Max) END  AS FLOAT)
		ELSE 0
		END END AS IdleComponent,
		CASE WHEN ric22.HighLow = 1 THEN 
			CAST(ric22.Weight * (CASE WHEN ric22.Type='P' THEN Acceleration * 100 ELSE Acceleration END - ric22.Min) / CASE WHEN (ric22.Max - ric22.Min) = 0 THEN 1 ELSE (ric22.Max - ric22.Min) END AS FLOAT)
		ELSE CASE WHEN ric22.HighLow = 0 THEN 
			CAST(ric22.Weight * (ric22.Min - CASE WHEN ric22.Type='P' THEN Acceleration * 100 ELSE Acceleration END) / CASE WHEN (ric22.Min - ric22.Max) = 0 THEN 1 ELSE (ric22.Min - ric22.Max) END  AS FLOAT)
		ELSE 0
		END END AS AccelerationComponent,
		CASE WHEN ric23.HighLow = 1 THEN 
			CAST(ric23.Weight * (CASE WHEN ric23.Type='P' THEN Braking * 100 ELSE Braking END - ric23.Min) / CASE WHEN (ric23.Max - ric23.Min) = 0 THEN 1 ELSE (ric23.Max - ric23.Min) END AS FLOAT)
		ELSE CASE WHEN ric23.HighLow = 0 THEN 
			CAST(ric23.Weight * (ric23.Min - CASE WHEN ric23.Type='P' THEN Braking * 100 ELSE Braking END) / CASE WHEN (ric23.Min - ric23.Max) = 0 THEN 1 ELSE (ric23.Min - ric23.Max) END  AS FLOAT)
		ELSE 0
		END END AS BrakingComponent,
				CASE WHEN ric24.HighLow = 1 THEN 
			CAST(ric24.Weight * (CASE WHEN ric24.Type='P' THEN Cornering * 100 ELSE Cornering END - ric24.Min) / CASE WHEN (ric24.Max - ric24.Min) = 0 THEN 1 ELSE (ric24.Max - ric24.Min) END AS FLOAT)
		ELSE CASE WHEN ric24.HighLow = 0 THEN 
			CAST(ric24.Weight * (ric24.Min - CASE WHEN ric24.Type='P' THEN Cornering * 100 ELSE Cornering END) / CASE WHEN (ric24.Min - ric24.Max) = 0 THEN 1 ELSE (ric24.Min - ric24.Max) END  AS FLOAT)
		ELSE 0
		END END AS CorneringComponent,
		CASE WHEN ric25.HighLow = 1 THEN 
			CAST(ric25.Weight * (CASE WHEN ric25.Type='P' THEN CruiseTopGearRatio * 100 ELSE CruiseTopGearRatio END - ric25.Min) / CASE WHEN (ric25.Max - ric25.Min) = 0 THEN 1 ELSE (ric25.Max - ric25.Min) END AS FLOAT)
		ELSE CASE WHEN ric25.HighLow = 0 THEN 
			CAST(ric25.Weight * (ric25.Min - CASE WHEN ric25.Type='P' THEN CruiseTopGearRatio * 100 ELSE CruiseTopGearRatio END) / CASE WHEN (ric25.Min - ric25.Max) = 0 THEN 1 ELSE (ric25.Min - ric25.Max) END  AS FLOAT)
		ELSE 0
		END END AS CruiseTopGearRatioComponent,
		CASE WHEN ric29.HighLow = 1 THEN 
			CAST(ric29.Weight * (CASE WHEN ric29.Type='P' THEN PTO * 100 ELSE PTO END - ric29.Min) / CASE WHEN (ric29.Max - ric29.Min) = 0 THEN 1 ELSE (ric29.Max - ric29.Min) END AS FLOAT)
		ELSE CASE WHEN ric29.HighLow = 0 THEN 
			CAST(ric29.Weight * (ric29.Min - CASE WHEN ric29.Type='P' THEN PTO * 100 ELSE PTO END) / CASE WHEN (ric29.Min - ric29.Max) = 0 THEN 1 ELSE (ric29.Min - ric29.Max) END  AS FLOAT)
		ELSE 0
		END END AS PTOComponent,


		CASE WHEN ric33.HighLow = 1 THEN 
			CAST(ric33.Weight * (CASE WHEN ric33.Type='P' THEN AccelerationLow * 100 ELSE AccelerationLow END - ric33.Min) / CASE WHEN (ric33.Max - ric33.Min) = 0 THEN 1 ELSE (ric33.Max - ric33.Min) END AS FLOAT)
		ELSE CASE WHEN ric33.HighLow = 0 THEN 
			CAST(ric33.Weight * (ric33.Min - CASE WHEN ric33.Type='P' THEN AccelerationLow * 100 ELSE AccelerationLow END) / CASE WHEN (ric33.Min - ric33.Max) = 0 THEN 1 ELSE (ric33.Min - ric33.Max) END  AS FLOAT)
		ELSE 0
		END END AS AccelerationLowComponent,
		CASE WHEN ric34.HighLow = 1 THEN 
			CAST(ric34.Weight * (CASE WHEN ric34.Type='P' THEN BrakingLow * 100 ELSE BrakingLow END - ric34.Min) / CASE WHEN (ric34.Max - ric34.Min) = 0 THEN 1 ELSE (ric34.Max - ric34.Min) END AS FLOAT)
		ELSE CASE WHEN ric34.HighLow = 0 THEN 
			CAST(ric34.Weight * (ric34.Min - CASE WHEN ric34.Type='P' THEN BrakingLow * 100 ELSE BrakingLow END) / CASE WHEN (ric34.Min - ric34.Max) = 0 THEN 1 ELSE (ric34.Min - ric34.Max) END  AS FLOAT)
		ELSE 0
		END END AS BrakingLowComponent,
		CASE WHEN ric35.HighLow = 1 THEN 
			CAST(ric35.Weight * (CASE WHEN ric35.Type='P' THEN CorneringLow * 100 ELSE CorneringLow END - ric35.Min) / CASE WHEN (ric35.Max - ric35.Min) = 0 THEN 1 ELSE (ric35.Max - ric35.Min) END AS FLOAT)
		ELSE CASE WHEN ric35.HighLow = 0 THEN 
			CAST(ric35.Weight * (ric35.Min - CASE WHEN ric35.Type='P' THEN CorneringLow * 100 ELSE CorneringLow END) / CASE WHEN (ric35.Min - ric35.Max) = 0 THEN 1 ELSE (ric35.Min - ric35.Max) END  AS FLOAT)
		ELSE 0
		END END AS CorneringLowComponent,
		CASE WHEN ric36.HighLow = 1 THEN 
			CAST(ric36.Weight * (CASE WHEN ric36.Type='P' THEN AccelerationHigh * 100 ELSE AccelerationHigh END - ric36.Min) / CASE WHEN (ric36.Max - ric36.Min) = 0 THEN 1 ELSE (ric36.Max - ric36.Min) END AS FLOAT)
		ELSE CASE WHEN ric36.HighLow = 0 THEN 
			CAST(ric36.Weight * (ric36.Min - CASE WHEN ric36.Type='P' THEN AccelerationHigh * 100 ELSE AccelerationHigh END) / CASE WHEN (ric36.Min - ric36.Max) = 0 THEN 1 ELSE (ric36.Min - ric36.Max) END  AS FLOAT)
		ELSE 0
		END END AS AccelerationHighComponent,
		CASE WHEN ric37.HighLow = 1 THEN 
			CAST(ric37.Weight * (CASE WHEN ric37.Type='P' THEN BrakingHigh * 100 ELSE BrakingHigh END - ric37.Min) / CASE WHEN (ric37.Max - ric37.Min) = 0 THEN 1 ELSE (ric37.Max - ric37.Min) END AS FLOAT)
		ELSE CASE WHEN ric37.HighLow = 0 THEN 
			CAST(ric37.Weight * (ric37.Min - CASE WHEN ric37.Type='P' THEN BrakingHigh * 100 ELSE BrakingHigh END) / CASE WHEN (ric37.Min - ric37.Max) = 0 THEN 1 ELSE (ric37.Min - ric37.Max) END  AS FLOAT)
		ELSE 0
		END END AS BrakingHighComponent,
		CASE WHEN ric38.HighLow = 1 THEN 
			CAST(ric38.Weight * (CASE WHEN ric38.Type='P' THEN CorneringHigh * 100 ELSE CorneringHigh END - ric38.Min) / CASE WHEN (ric38.Max - ric38.Min) = 0 THEN 1 ELSE (ric38.Max - ric38.Min) END AS FLOAT)
		ELSE CASE WHEN ric38.HighLow = 0 THEN 
			CAST(ric38.Weight * (ric38.Min - CASE WHEN ric38.Type='P' THEN CorneringHigh * 100 ELSE CorneringHigh END) / CASE WHEN (ric38.Min - ric38.Max) = 0 THEN 1 ELSE (ric38.Min - ric38.Max) END  AS FLOAT)
		ELSE 0
		END END AS CorneringHighComponent,
		CASE WHEN ric39.HighLow = 1 THEN 
			CAST(ric39.Weight * (CASE WHEN ric39.Type='P' THEN (AccelerationLow + BrakingLow + CorneringLow) * 100 ELSE (AccelerationLow + BrakingLow + CorneringLow) END - ric39.Min) / CASE WHEN (ric39.Max - ric39.Min) = 0 THEN 1 ELSE (ric39.Max - ric39.Min) END AS FLOAT)
		ELSE CASE WHEN ric39.HighLow = 0 THEN 
			CAST(ric39.Weight * (ric39.Min - CASE WHEN ric39.Type='P' THEN (AccelerationLow + BrakingLow + CorneringLow) * 100 ELSE (AccelerationLow + BrakingLow + CorneringLow) END) / CASE WHEN (ric39.Min - ric39.Max) = 0 THEN 1 ELSE (ric39.Min - ric39.Max) END  AS FLOAT)
		ELSE 0
		END END AS ManoeuvresLowComponent,
		CASE WHEN ric40.HighLow = 1 THEN 
			CAST(ric40.Weight * (CASE WHEN ric40.Type='P' THEN (Acceleration + Braking + Cornering) * 100 ELSE (Acceleration + Braking + Cornering) END - ric40.Min) / CASE WHEN (ric40.Max - ric40.Min) = 0 THEN 1 ELSE (ric40.Max - ric40.Min) END AS FLOAT)
		ELSE CASE WHEN ric40.HighLow = 0 THEN 
			CAST(ric40.Weight * (ric40.Min - CASE WHEN ric40.Type='P' THEN (Acceleration + Braking + Cornering) * 100 ELSE (Acceleration + Braking + Cornering) END) / CASE WHEN (ric40.Min - ric40.Max) = 0 THEN 1 ELSE (ric40.Min - ric40.Max) END  AS FLOAT)
		ELSE 0
		END END AS ManoeuvresMedComponent,				
		CASE WHEN ric7.HighLow = 1 THEN 
			CAST(ric7.Weight * (CASE WHEN ric7.Type='P' THEN EngineServiceBrake * 100 ELSE EngineServiceBrake END - ric7.Min) / CASE WHEN (ric7.Max - ric7.Min) = 0 THEN 1 ELSE (ric7.Max - ric7.Min) END AS FLOAT)
		ELSE CASE WHEN ric7.HighLow = 0 THEN 
			CAST(ric7.Weight * (ric7.Min - CASE WHEN ric7.Type='P' THEN EngineServiceBrake * 100 ELSE EngineServiceBrake END) / CASE WHEN (ric7.Min - ric7.Max) = 0 THEN 1 ELSE (ric7.Min - ric7.Max) END  AS FLOAT)
		ELSE 0
		END END AS EngineServiceBrakeComponent,
		CASE WHEN ric8.HighLow = 1 THEN 
			CAST(ric8.Weight * (CASE WHEN ric8.Type='P' THEN OverRevWithoutFuel * 100 ELSE OverRevWithoutFuel END - ric8.Min) / CASE WHEN (ric8.Max - ric8.Min) = 0 THEN 1 ELSE (ric8.Max - ric8.Min) END AS FLOAT)
		ELSE CASE WHEN ric8.HighLow = 0 THEN 
			CAST(ric8.Weight * (ric8.Min - CASE WHEN ric8.Type='P' THEN OverRevWithoutFuel * 100 ELSE OverRevWithoutFuel END) / CASE WHEN (ric8.Min - ric8.Max) = 0 THEN 1 ELSE (ric8.Min - ric8.Max) END  AS FLOAT)
		ELSE 0
		END END AS OverRevWithoutFuelComponent,
		CASE WHEN ric9.HighLow = 1 THEN 
			CAST(ric9.Weight * (CASE WHEN ric9.Type='P' THEN Rop * 100 ELSE Rop END - ric9.Min) / CASE WHEN (ric9.Max - ric9.Min) = 0 THEN 1 ELSE (ric9.Max - ric9.Min) END AS FLOAT)
		ELSE CASE WHEN ric9.HighLow = 0 THEN 
			CAST(ric9.Weight * (ric9.Min - CASE WHEN ric9.Type='P' THEN Rop * 100 ELSE Rop END) / CASE WHEN (ric9.Min - ric9.Max) = 0 THEN 1 ELSE (ric9.Min - ric9.Max) END  AS FLOAT)
		ELSE 0
		END END AS RopComponent,
		CASE WHEN ric41.HighLow = 1 THEN 
			CAST(ric41.Weight * (CASE WHEN ric41.Type='P' THEN Rop2 * 100 ELSE Rop2 END - ric41.Min) / CASE WHEN (ric41.Max - ric41.Min) = 0 THEN 1 ELSE (ric41.Max - ric41.Min) END AS FLOAT)
		ELSE CASE WHEN ric41.HighLow = 0 THEN 
			CAST(ric41.Weight * (ric41.Min - CASE WHEN ric41.Type='P' THEN Rop2 * 100 ELSE Rop2 END) / CASE WHEN (ric41.Min - ric41.Max) = 0 THEN 1 ELSE (ric41.Min - ric41.Max) END  AS FLOAT)
		ELSE 0
		END END AS Rop2Component,
		CASE WHEN ric10.HighLow = 1 THEN 
			CAST(ric10.Weight * (CASE WHEN ric10.Type='P' THEN OverSpeed * 100 ELSE OverSpeed END - ric10.Min) / CASE WHEN (ric10.Max - ric10.Min) = 0 THEN 1 ELSE (ric10.Max - ric10.Min) END AS FLOAT)
		ELSE CASE WHEN ric10.HighLow = 0 THEN 
			CAST(ric10.Weight * (ric10.Min - CASE WHEN ric10.Type='P' THEN OverSpeed * 100 ELSE OverSpeed END) / CASE WHEN (ric10.Min - ric10.Max) = 0 THEN 1 ELSE (ric10.Min - ric10.Max) END  AS FLOAT)
		ELSE 0
		END END AS OverSpeedComponent,
		CASE WHEN ric32.HighLow = 1 THEN 
			CAST(ric32.Weight * (CASE WHEN ric32.Type='P' THEN OverSpeedHigh * 100 ELSE OverSpeedHigh END - ric32.Min) / CASE WHEN (ric32.Max - ric32.Min) = 0 THEN 1 ELSE (ric32.Max - ric32.Min) END AS FLOAT)
		ELSE CASE WHEN ric32.HighLow = 0 THEN 
			CAST(ric32.Weight * (ric32.Min - CASE WHEN ric32.Type='P' THEN OverSpeedHigh * 100 ELSE OverSpeedHigh END) / CASE WHEN (ric32.Min - ric32.Max) = 0 THEN 1 ELSE (ric32.Min - ric32.Max) END  AS FLOAT)
		ELSE 0
		END END AS OverSpeedHighComponent,
		CASE WHEN ric21.HighLow = 1 THEN 
			CAST(ric21.Weight * (CASE WHEN ric21.Type='P' THEN OverSpeedDistance * 100 ELSE OverSpeedDistance END - ric21.Min) / CASE WHEN (ric21.Max - ric21.Min) = 0 THEN 1 ELSE (ric21.Max - ric21.Min) END AS FLOAT)
		ELSE CASE WHEN ric21.HighLow = 0 THEN 
			CAST(ric21.Weight * (ric21.Min - CASE WHEN ric21.Type='P' THEN OverSpeedDistance * 100 ELSE OverSpeedDistance END) / CASE WHEN (ric21.Min - ric21.Max) = 0 THEN 1 ELSE (ric21.Min - ric21.Max) END  AS FLOAT)
		ELSE 0
		END END AS OverSpeedDistanceComponent,
		CASE WHEN ric30.HighLow = 1 THEN 
			CAST(ric30.Weight * (CASE WHEN ric30.Type='P' THEN IVHOverSpeed * 100 ELSE IVHOverSpeed END - ric30.Min) / CASE WHEN (ric30.Max - ric30.Min) = 0 THEN 1 ELSE (ric30.Max - ric30.Min) END AS FLOAT)
		ELSE CASE WHEN ric30.HighLow = 0 THEN 
			CAST(ric30.Weight * (ric30.Min - CASE WHEN ric30.Type='P' THEN IVHOverSpeed * 100 ELSE IVHOverSpeed END) / CASE WHEN (ric30.Min - ric30.Max) = 0 THEN 1 ELSE (ric30.Min - ric30.Max) END  AS FLOAT)
		ELSE 0
		END END AS IVHOverSpeedComponent,
		CASE WHEN ric11.HighLow = 1 THEN 
			CAST(ric11.Weight * (CASE WHEN ric11.Type='P' THEN CoastOutOfGear * 100 ELSE CoastOutOfGear END - ric11.Min) / CASE WHEN (ric11.Max - ric11.Min) = 0 THEN 1 ELSE (ric11.Max - ric11.Min) END AS FLOAT)
		ELSE CASE WHEN ric11.HighLow = 0 THEN 
			CAST(ric11.Weight * (ric11.Min - CASE WHEN ric11.Type='P' THEN CoastOutOfGear * 100 ELSE CoastOutOfGear END) / CASE WHEN (ric11.Min - ric11.Max) = 0 THEN 1 ELSE (ric11.Min - ric11.Max) END  AS FLOAT)
		ELSE 0
		END END AS CoastOutOfGearComponent,
		CASE WHEN ric12.HighLow = 1 THEN 
			CAST(ric12.Weight * (CASE WHEN ric12.Type='P' THEN HarshBraking * 100 ELSE HarshBraking END - ric12.Min) / CASE WHEN (ric12.Max - ric12.Min) = 0 THEN 1 ELSE (ric12.Max - ric12.Min) END AS FLOAT)
		ELSE CASE WHEN ric12.HighLow = 0 THEN 
			CAST(ric12.Weight * (ric12.Min - CASE WHEN ric12.Type='P' THEN HarshBraking * 100 ELSE HarshBraking END) / CASE WHEN (ric12.Min - ric12.Max) = 0 THEN 1 ELSE (ric12.Min - ric12.Max) END  AS FLOAT)
		ELSE 0
		END END AS HarshBrakingComponent,
		CASE WHEN ric43.HighLow = 1 THEN 
			CAST(ric43.Weight * (CASE WHEN ric43.Type='P' THEN CruiseOverspeed * 100 ELSE CruiseOverspeed END - ric43.Min) / CASE WHEN (ric43.Max - ric43.Min) = 0 THEN 1 ELSE (ric43.Max - ric43.Min) END AS FLOAT)
		ELSE CASE WHEN ric43.HighLow = 0 THEN 
			CAST(ric43.Weight * (ric43.Min - CASE WHEN ric43.Type='P' THEN CruiseOverspeed * 100 ELSE CruiseOverspeed END) / CASE WHEN (ric43.Min - ric43.Max) = 0 THEN 1 ELSE (ric43.Min - ric43.Max) END  AS FLOAT)
		ELSE 0
		END END AS CruiseOverspeedComponent,
		CASE WHEN ric42.HighLow = 1 THEN 
			CAST(ric42.Weight * (CASE WHEN ric42.Type='P' THEN TopGearOverspeed * 100 ELSE TopGearOverspeed END - ric42.Min) / CASE WHEN (ric42.Max - ric42.Min) = 0 THEN 1 ELSE (ric42.Max - ric42.Min) END AS FLOAT)
		ELSE CASE WHEN ric42.HighLow = 0 THEN 
			CAST(ric42.Weight * (ric42.Min - CASE WHEN ric42.Type='P' THEN TopGearOverspeed * 100 ELSE TopGearOverspeed END) / CASE WHEN (ric42.Min - ric42.Max) = 0 THEN 1 ELSE (ric42.Min - ric42.Max) END  AS FLOAT)
		ELSE 0
		END END AS TopGearOverspeedComponent,
		CASE WHEN ric46.HighLow = 1 THEN 
			CAST(ric46.Weight * (CASE WHEN ric46.Type='P' THEN OverspeedCount * 100 ELSE OverspeedCount END - ric46.Min) / CASE WHEN (ric46.Max - ric46.Min) = 0 THEN 1 ELSE (ric46.Max - ric46.Min) END AS FLOAT)
		ELSE CASE WHEN ric46.HighLow = 0 THEN 
			CAST(ric46.Weight * (ric46.Min - CASE WHEN ric46.Type='P' THEN OverspeedCount * 100 ELSE OverspeedCount END) / CASE WHEN (ric46.Min - ric46.Max) = 0 THEN 1 ELSE (ric46.Min - ric46.Max) END  AS FLOAT)
		ELSE 0
		END END AS OverspeedCountComponent,
		CASE WHEN ric47.HighLow = 1 THEN 
			CAST(ric47.Weight * (CASE WHEN ric47.Type='P' THEN OverspeedHighCount * 100 ELSE OverspeedHighCount END - ric47.Min) / CASE WHEN (ric47.Max - ric47.Min) = 0 THEN 1 ELSE (ric47.Max - ric47.Min) END AS FLOAT)
		ELSE CASE WHEN ric47.HighLow = 0 THEN 
			CAST(ric47.Weight * (ric47.Min - CASE WHEN ric47.Type='P' THEN OverspeedHighCount * 100 ELSE OverspeedHighCount END) / CASE WHEN (ric47.Min - ric47.Max) = 0 THEN 1 ELSE (ric47.Min - ric47.Max) END  AS FLOAT)
		ELSE 0
		END END AS OverspeedHighCountComponent,
		CASE WHEN ric48.HighLow = 1 THEN 
			CAST(ric48.Weight * (CASE WHEN ric48.Type='P' THEN StabilityControl * 100 ELSE StabilityControl END - ric48.Min) / CASE WHEN (ric48.Max - ric48.Min) = 0 THEN 1 ELSE (ric48.Max - ric48.Min) END AS FLOAT)
		ELSE CASE WHEN ric48.HighLow = 0 THEN 
			CAST(ric48.Weight * (ric48.Min - CASE WHEN ric48.Type='P' THEN StabilityControl * 100 ELSE StabilityControl END) / CASE WHEN (ric48.Min - ric48.Max) = 0 THEN 1 ELSE (ric48.Min - ric48.Max) END  AS FLOAT)
		ELSE 0
		END END AS StabilityControlComponent,
		CASE WHEN ric49.HighLow = 1 THEN 
			CAST(ric49.Weight * (CASE WHEN ric49.Type='P' THEN CollisionWarningLow * 100 ELSE CollisionWarningLow END - ric49.Min) / CASE WHEN (ric49.Max - ric49.Min) = 0 THEN 1 ELSE (ric49.Max - ric49.Min) END AS FLOAT)
		ELSE CASE WHEN ric49.HighLow = 0 THEN 
			CAST(ric49.Weight * (ric49.Min - CASE WHEN ric49.Type='P' THEN CollisionWarningLow * 100 ELSE CollisionWarningLow END) / CASE WHEN (ric49.Min - ric49.Max) = 0 THEN 1 ELSE (ric49.Min - ric49.Max) END  AS FLOAT)
		ELSE 0
		END END AS CollisionWarningLowComponent,
		CASE WHEN ric50.HighLow = 1 THEN 
			CAST(ric50.Weight * (CASE WHEN ric50.Type='P' THEN CollisionWarningMed * 100 ELSE CollisionWarningMed END - ric50.Min) / CASE WHEN (ric50.Max - ric50.Min) = 0 THEN 1 ELSE (ric50.Max - ric50.Min) END AS FLOAT)
		ELSE CASE WHEN ric50.HighLow = 0 THEN 
			CAST(ric50.Weight * (ric50.Min - CASE WHEN ric50.Type='P' THEN CollisionWarningMed * 100 ELSE CollisionWarningMed END) / CASE WHEN (ric50.Min - ric50.Max) = 0 THEN 1 ELSE (ric50.Min - ric50.Max) END  AS FLOAT)
		ELSE 0
		END END AS CollisionWarningMedComponent,
		CASE WHEN ric51.HighLow = 1 THEN 
			CAST(ric51.Weight * (CASE WHEN ric51.Type='P' THEN CollisionWarningHigh * 100 ELSE CollisionWarningHigh END - ric51.Min) / CASE WHEN (ric51.Max - ric51.Min) = 0 THEN 1 ELSE (ric51.Max - ric51.Min) END AS FLOAT)
		ELSE CASE WHEN ric51.HighLow = 0 THEN 
			CAST(ric51.Weight * (ric51.Min - CASE WHEN ric51.Type='P' THEN CollisionWarningHigh * 100 ELSE CollisionWarningHigh END) / CASE WHEN (ric51.Min - ric51.Max) = 0 THEN 1 ELSE (ric51.Min - ric51.Max) END  AS FLOAT)
		ELSE 0
		END END AS CollisionWarningHighComponent,
		CASE WHEN ric52.HighLow = 1 THEN 
			CAST(ric52.Weight * (CASE WHEN ric52.Type='P' THEN LaneDepartureDisable * 100 ELSE LaneDepartureDisable END - ric52.Min) / CASE WHEN (ric52.Max - ric52.Min) = 0 THEN 1 ELSE (ric52.Max - ric52.Min) END AS FLOAT)
		ELSE CASE WHEN ric52.HighLow = 0 THEN 
			CAST(ric52.Weight * (ric52.Min - CASE WHEN ric52.Type='P' THEN LaneDepartureDisable * 100 ELSE LaneDepartureDisable END) / CASE WHEN (ric52.Min - ric52.Max) = 0 THEN 1 ELSE (ric52.Min - ric52.Max) END  AS FLOAT)
		ELSE 0
		END END AS LaneDepartureDisableComponent,
		CASE WHEN ric53.HighLow = 1 THEN 
			CAST(ric53.Weight * (CASE WHEN ric53.Type='P' THEN LaneDepartureLeftRight * 100 ELSE LaneDepartureLeftRight END - ric53.Min) / CASE WHEN (ric53.Max - ric53.Min) = 0 THEN 1 ELSE (ric53.Max - ric53.Min) END AS FLOAT)
		ELSE CASE WHEN ric53.HighLow = 0 THEN 
			CAST(ric53.Weight * (ric53.Min - CASE WHEN ric53.Type='P' THEN LaneDepartureLeftRight * 100 ELSE LaneDepartureLeftRight END) / CASE WHEN (ric53.Min - ric53.Max) = 0 THEN 1 ELSE (ric53.Min - ric53.Max) END  AS FLOAT)
		ELSE 0
		END END AS LaneDepartureLeftRightComponent,
		CASE WHEN ric57.HighLow = 1 THEN 
			CAST(ric57.Weight * (CASE WHEN ric57.Type='P' THEN Fatigue * 100 ELSE Fatigue END - ric57.Min) / CASE WHEN (ric57.Max - ric57.Min) = 0 THEN 1 ELSE (ric57.Max - ric57.Min) END AS FLOAT)
		ELSE CASE WHEN ric57.HighLow = 0 THEN 
			CAST(ric57.Weight * (ric57.Min - CASE WHEN ric57.Type='P' THEN Fatigue * 100 ELSE Fatigue END) / CASE WHEN (ric57.Min - ric57.Max) = 0 THEN 1 ELSE (ric57.Min - ric57.Max) END  AS FLOAT)
		ELSE 0
		END END AS FatigueComponent,
		CASE WHEN ric58.HighLow = 1 THEN 
			CAST(ric58.Weight * (CASE WHEN ric58.Type='P' THEN Distraction * 100 ELSE Distraction END - ric58.Min) / CASE WHEN (ric58.Max - ric58.Min) = 0 THEN 1 ELSE (ric58.Max - ric58.Min) END AS FLOAT)
		ELSE CASE WHEN ric58.HighLow = 0 THEN 
			CAST(ric58.Weight * (ric58.Min - CASE WHEN ric58.Type='P' THEN Distraction * 100 ELSE Distraction END) / CASE WHEN (ric58.Min - ric58.Max) = 0 THEN 1 ELSE (ric58.Min - ric58.Max) END  AS FLOAT)
		ELSE 0
		END END AS DistractionComponent,
		CASE WHEN ric54.HighLow = 1 THEN 
			CAST(ric54.Weight * (CASE WHEN ric54.Type='P' THEN SweetSpotTime * 100 ELSE SweetSpotTime END - ric54.Min) / CASE WHEN (ric54.Max - ric54.Min) = 0 THEN 1 ELSE (ric54.Max - ric54.Min) END AS FLOAT)
		ELSE CASE WHEN ric54.HighLow = 0 THEN 
			CAST(ric54.Weight * (ric54.Min - CASE WHEN ric54.Type='P' THEN SweetSpotTime * 100 ELSE SweetSpotTime END) / CASE WHEN (ric54.Min - ric54.Max) = 0 THEN 1 ELSE (ric54.Min - ric54.Max) END  AS FLOAT)
		ELSE 0
		END END AS SweetSpotTimeComponent,
		CASE WHEN ric55.HighLow = 1 THEN 
			CAST(ric55.Weight * (CASE WHEN ric55.Type='P' THEN OverRevTime * 100 ELSE OverRevTime END - ric55.Min) / CASE WHEN (ric55.Max - ric55.Min) = 0 THEN 1 ELSE (ric55.Max - ric55.Min) END AS FLOAT)
		ELSE CASE WHEN ric55.HighLow = 0 THEN 
			CAST(ric55.Weight * (ric55.Min - CASE WHEN ric55.Type='P' THEN OverRevTime * 100 ELSE OverRevTime END) / CASE WHEN (ric55.Min - ric55.Max) = 0 THEN 1 ELSE (ric55.Min - ric55.Max) END  AS FLOAT)
		ELSE 0
		END END AS OverRevTimeComponent,
		CASE WHEN ric56.HighLow = 1 THEN 
			CAST(ric56.Weight * (CASE WHEN ric56.Type='P' THEN TopGearTime * 100 ELSE TopGearTime END - ric56.Min) / CASE WHEN (ric56.Max - ric56.Min) = 0 THEN 1 ELSE (ric56.Max - ric56.Min) END AS FLOAT)
		ELSE CASE WHEN ric56.HighLow = 0 THEN 
			CAST(ric56.Weight * (ric56.Min - CASE WHEN ric56.Type='P' THEN TopGearTime * 100 ELSE TopGearTime END) / CASE WHEN (ric56.Min - ric56.Max) = 0 THEN 1 ELSE (ric56.Min - ric56.Max) END  AS FLOAT)
		ELSE 0
		END END AS TopGearTimeComponent,
		CASE WHEN ric59.HighLow = 1 THEN 
			CAST(ric59.Weight * (CASE WHEN ric59.Type='P' THEN SpeedGauge * 100 ELSE SpeedGauge END - ric59.Min) / CASE WHEN (ric59.Max - ric59.Min) = 0 THEN 1 ELSE (ric59.Max - ric59.Min) END AS FLOAT)
		ELSE CASE WHEN ric59.HighLow = 0 THEN 
			CAST(ric59.Weight * (ric59.Min - CASE WHEN ric59.Type='P' THEN SpeedGauge * 100 ELSE SpeedGauge END) / CASE WHEN (ric59.Min - ric59.Max) = 0 THEN 1 ELSE (ric59.Min - ric59.Max) END  AS FLOAT)
		ELSE 0
		END END AS SpeedGaugeComponent

	FROM
		(SELECT
			CASE WHEN (GROUPING(v.VehicleId) = 1) THEN NULL
				ELSE ISNULL(v.VehicleId, NULL)
			END AS VehicleId,

			CASE WHEN (GROUPING(d.DriverId) = 1) THEN NULL
				ELSE ISNULL(d.DriverId, NULL)
			END AS DriverId,

			SUM(InSweetSpotDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0))) AS SweetSpot,
			SUM(FueledOverRPMDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0))) AS OverRevWithFuel,
			SUM(TopGearDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0))) AS TopGear,
			SUM(CruiseControlDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0))) AS Cruise,
			--Proof of concept. CruiseInTopGearsDistance should be used in production as soon as firmware is released.
			--dbo.CAP(SUM(CruiseControlDistance) / dbo.ZeroYieldNull(SUM(TopGearDistance + ISNULL(GearDownDistance,0))), 1.0) AS CruiseInTopGears,
			SUM(CruiseInTopGearsDistance) / dbo.ZeroYieldNull(SUM(TopGearDistance + ISNULL(GearDownDistance,0))) AS CruiseInTopGears,
			SUM(CoastInGearDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0))) AS CoastInGear,
			SUM(CruiseControlDistance) / dbo.ZeroYieldNull(SUM(TopGearDistance)) AS CruiseTopGearRatio,
			CAST(SUM(IdleTime) AS FLOAT) / dbo.ZeroYieldNull(SUM(TotalTime)) AS Idle,
			CAST(SUM(PTOMovingTime) + SUM(PTONonMovingTime) AS FLOAT) / dbo.ZeroYieldNull(SUM(TotalTime)) AS Pto,
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
			ISNULL(CAST(SUM(re.SweetSpotTime) AS float) / dbo.ZeroYieldNull(SUM(r.TotalTime)),0) AS SweetSpotTime,
			ISNULL(CAST(SUM(re.OverRPMTime) AS float) / dbo.ZeroYieldNull(SUM(r.TotalTime)),0) AS OverRevTime,
			ISNULL(CAST(SUM(re.TopGearTime) AS float) / dbo.ZeroYieldNull(SUM(r.TotalTime)),0) AS TopGearTime,
			ISNULL((SUM(re.Fatigue) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS Fatigue,
			ISNULL((SUM(re.Distraction) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS Distraction,

			(CASE WHEN @fuelmult = 0.1 THEN
				(CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel * ISNULL(FuelMultiplier,1.0))*100 END)/SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) 
			ELSE
				(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * 1000) / (CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel * ISNULL(FuelMultiplier,1.0)) END) * @fuelmult END) AS FuelEcon

		FROM dbo.Reporting r
			INNER JOIN @assets ass ON r.DriverIntId = ass.IntId
			INNER JOIN dbo.Vehicle v ON r.VehicleIntId = v.VehicleIntId
			INNER JOIN dbo.Driver d ON r.DriverIntId = d.DriverIntId
			LEFT JOIN dbo.ReportingABC abc ON r.VehicleIntId = abc.VehicleIntId AND r.DriverIntId = abc.DriverIntId AND r.Date = abc.Date --AND r.RouteID = abc.RouteId
			LEFT JOIN dbo.ReportingOverspeed ro ON r.VehicleIntId = ro.VehicleIntId AND r.DriverIntId = ro.DriverIntId AND r.Date = ro.Date --AND r.RouteID = ro.RouteId
			LEFT JOIN dbo.ReportingExtra re ON r.VehicleIntId = re.VehicleIntId AND r.DriverIntId = re.DriverIntId AND r.Date = re.Date

		WHERE r.Date BETWEEN @lsdate AND @ledate 
          AND r.DrivingDistance > 0
		GROUP BY d.DriverId, v.VehicleId WITH CUBE 
	
	HAVING SUM(DrivingDistance) > 10 ) o

	LEFT JOIN dbo.ReportIndicatorConfig ric1 ON ric1.ReportConfigurationId = @lrprtcfgid AND ric1.IndicatorId = 1
	LEFT JOIN dbo.ReportIndicatorConfig ric2 ON ric2.ReportConfigurationId = @lrprtcfgid AND ric2.IndicatorId = 2
	LEFT JOIN dbo.ReportIndicatorConfig ric3 ON ric3.ReportConfigurationId = @lrprtcfgid AND ric3.IndicatorId = 3
	LEFT JOIN dbo.ReportIndicatorConfig ric4 ON ric4.ReportConfigurationId = @lrprtcfgid AND ric4.IndicatorId = 4
	LEFT JOIN dbo.ReportIndicatorConfig ric5 ON ric5.ReportConfigurationId = @lrprtcfgid AND ric5.IndicatorId = 5
	LEFT JOIN dbo.ReportIndicatorConfig ric6 ON ric6.ReportConfigurationId = @lrprtcfgid AND ric6.IndicatorId = 6
	LEFT JOIN dbo.ReportIndicatorConfig ric7 ON ric7.ReportConfigurationId = @lrprtcfgid AND ric7.IndicatorId = 7
	LEFT JOIN dbo.ReportIndicatorConfig ric8 ON ric8.ReportConfigurationId = @lrprtcfgid AND ric8.IndicatorId = 8
	LEFT JOIN dbo.ReportIndicatorConfig ric9 ON ric9.ReportConfigurationId = @lrprtcfgid AND ric9.IndicatorId = 9
	LEFT JOIN dbo.ReportIndicatorConfig ric10 ON ric10.ReportConfigurationId = @lrprtcfgid AND ric10.IndicatorId = 10
	LEFT JOIN dbo.ReportIndicatorConfig ric11 ON ric11.ReportConfigurationId = @lrprtcfgid AND ric11.IndicatorId = 11
	LEFT JOIN dbo.ReportIndicatorConfig ric12 ON ric12.ReportConfigurationId = @lrprtcfgid AND ric12.IndicatorId = 12
	LEFT JOIN dbo.ReportIndicatorConfig ric14 ON ric14.ReportConfigurationId = @lrprtcfgid AND ric14.IndicatorId = 14
	LEFT JOIN dbo.ReportIndicatorConfig ric15 ON ric15.ReportConfigurationId = @lrprtcfgid AND ric15.IndicatorId = 15
	LEFT JOIN dbo.ReportIndicatorConfig ric16 ON ric16.ReportConfigurationId = @lrprtcfgid AND ric16.IndicatorId = 16
	LEFT JOIN dbo.ReportIndicatorConfig ric20 ON ric20.ReportConfigurationId = @lrprtcfgid AND ric20.IndicatorId = 20
	LEFT JOIN dbo.ReportIndicatorConfig ric21 ON ric21.ReportConfigurationId = @lrprtcfgid AND ric21.IndicatorId = 21
	LEFT JOIN dbo.ReportIndicatorConfig ric22 ON ric22.ReportConfigurationId = @lrprtcfgid AND ric22.IndicatorId = 22
	LEFT JOIN dbo.ReportIndicatorConfig ric23 ON ric23.ReportConfigurationId = @lrprtcfgid AND ric23.IndicatorId = 23
	LEFT JOIN dbo.ReportIndicatorConfig ric24 ON ric24.ReportConfigurationId = @lrprtcfgid AND ric24.IndicatorId = 24
	LEFT JOIN dbo.ReportIndicatorConfig ric25 ON ric25.ReportConfigurationId = @lrprtcfgid AND ric25.IndicatorId = 25
	LEFT JOIN dbo.ReportIndicatorConfig ric28 ON ric28.ReportConfigurationId = @lrprtcfgid AND ric28.IndicatorId = 28
	LEFT JOIN dbo.ReportIndicatorConfig ric29 ON ric29.ReportConfigurationId = @lrprtcfgid AND ric29.IndicatorId = 29
	LEFT JOIN dbo.ReportIndicatorConfig ric30 ON ric30.ReportConfigurationId = @lrprtcfgid AND ric30.IndicatorId = 30
	LEFT JOIN dbo.ReportIndicatorConfig ric31 ON ric31.ReportConfigurationId = @lrprtcfgid AND ric31.IndicatorId = 31
	LEFT JOIN dbo.ReportIndicatorConfig ric32 ON ric32.ReportConfigurationId = @lrprtcfgid AND ric32.IndicatorId = 32
	LEFT JOIN dbo.ReportIndicatorConfig ric33 ON ric33.ReportConfigurationId = @lrprtcfgid AND ric33.IndicatorId = 33
	LEFT JOIN dbo.ReportIndicatorConfig ric34 ON ric34.ReportConfigurationId = @lrprtcfgid AND ric34.IndicatorId = 34
	LEFT JOIN dbo.ReportIndicatorConfig ric35 ON ric35.ReportConfigurationId = @lrprtcfgid AND ric35.IndicatorId = 35
	LEFT JOIN dbo.ReportIndicatorConfig ric36 ON ric36.ReportConfigurationId = @lrprtcfgid AND ric36.IndicatorId = 36
	LEFT JOIN dbo.ReportIndicatorConfig ric37 ON ric37.ReportConfigurationId = @lrprtcfgid AND ric37.IndicatorId = 37
	LEFT JOIN dbo.ReportIndicatorConfig ric38 ON ric38.ReportConfigurationId = @lrprtcfgid AND ric38.IndicatorId = 38
	LEFT JOIN dbo.ReportIndicatorConfig ric39 ON ric39.ReportConfigurationId = @lrprtcfgid AND ric39.IndicatorId = 39
	LEFT JOIN dbo.ReportIndicatorConfig ric40 ON ric40.ReportConfigurationId = @lrprtcfgid AND ric40.IndicatorId = 40
	LEFT JOIN dbo.ReportIndicatorConfig ric41 ON ric41.ReportConfigurationId = @lrprtcfgid AND ric41.IndicatorId = 41
	LEFT JOIN dbo.ReportIndicatorConfig ric42 ON ric42.ReportConfigurationId = @lrprtcfgid AND ric42.IndicatorId = 42
	LEFT JOIN dbo.ReportIndicatorConfig ric43 ON ric43.ReportConfigurationId = @lrprtcfgid AND ric43.IndicatorId = 43
	LEFT JOIN dbo.ReportIndicatorConfig ric46 ON ric46.ReportConfigurationId = @lrprtcfgid AND ric46.IndicatorId = 46
	LEFT JOIN dbo.ReportIndicatorConfig ric47 ON ric47.ReportConfigurationId = @lrprtcfgid AND ric47.IndicatorId = 47
	LEFT JOIN dbo.ReportIndicatorConfig ric48 ON ric48.ReportConfigurationId = @lrprtcfgid AND ric48.IndicatorId = 48
	LEFT JOIN dbo.ReportIndicatorConfig ric49 ON ric49.ReportConfigurationId = @lrprtcfgid AND ric49.IndicatorId = 49
	LEFT JOIN dbo.ReportIndicatorConfig ric50 ON ric50.ReportConfigurationId = @lrprtcfgid AND ric50.IndicatorId = 50
	LEFT JOIN dbo.ReportIndicatorConfig ric51 ON ric51.ReportConfigurationId = @lrprtcfgid AND ric51.IndicatorId = 51
	LEFT JOIN dbo.ReportIndicatorConfig ric52 ON ric52.ReportConfigurationId = @lrprtcfgid AND ric52.IndicatorId = 52
	LEFT JOIN dbo.ReportIndicatorConfig ric53 ON ric53.ReportConfigurationId = @lrprtcfgid AND ric53.IndicatorId = 53
	LEFT JOIN dbo.ReportIndicatorConfig ric54 ON ric54.ReportConfigurationId = @lrprtcfgid AND ric54.IndicatorId = 54
	LEFT JOIN dbo.ReportIndicatorConfig ric55 ON ric55.ReportConfigurationId = @lrprtcfgid AND ric55.IndicatorId = 55
	LEFT JOIN dbo.ReportIndicatorConfig ric56 ON ric56.ReportConfigurationId = @lrprtcfgid AND ric56.IndicatorId = 56
	LEFT JOIN dbo.ReportIndicatorConfig ric57 ON ric57.ReportConfigurationId = @lrprtcfgid AND ric57.IndicatorId = 57
	LEFT JOIN dbo.ReportIndicatorConfig ric58 ON ric58.ReportConfigurationId = @lrprtcfgid AND ric58.IndicatorId = 58
	LEFT JOIN dbo.ReportIndicatorConfig ric59 ON ric59.ReportConfigurationId = @lrprtcfgid AND ric59.IndicatorId = 59
) p

-- Now select final data set and incorporate colours

SELECT
		-- Vehicle and Driver Identification columns
		v.VehicleId,	
		v.Registration,
		v.FleetNumber,
		v.VehicleTypeID,
		d.DriverId,
 		dbo.FormatDriverNameByUser(d.DriverId, @luid) AS DisplayName,
 		dbo.FormatDriverNameByUser(d.DriverId, @luid) AS DriverName, -- included for backward compatibility
 		d.FirstName,
 		d.Surname,
 		d.MiddleNames,
 		d.Number,
 		d.NumberAlternate,
 		d.NumberAlternate2,

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
		cast(0 as FLOAT) AS FuelWastageCost,

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
		HarshBrakingComponent,
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

		---- Date and Unit columns 
		@lsdate AS sdate,
		@ledate AS edate,
		@lsdate AS CreationDateTime,
		@ledate AS ClosureDateTime,
		--[dbo].TZ_GetTime(@lsdate,DEFAULT,@luid) AS CreationDateTime,
		--[dbo].TZ_GetTime(@ledate,DEFAULT,@luid) AS ClosureDateTime,

		@diststr AS DistanceUnit,
		@fuelstr AS FuelUnit,
		@co2str AS Co2Unit,
		@fuelmult AS FuelMult,

		-- Colour columns corresponding to data columns above
		CASE ric1.HighLow	WHEN 1 THEN
								CASE
									WHEN ric1.GYRAmberMax = 0 AND ric1.GYRGreenMax = 0 AND ISNULL(ric1.GYRRedMax,0) = 0 THEN NULL
									WHEN ric1.GYRRedMax IS NULL AND ROUND(SweetSpot*100, ric1.Rounding) >= ric1.GYRGreenMax THEN @GreenColour
									WHEN ric1.GYRRedMax IS NULL AND ROUND(SweetSpot*100, ric1.Rounding) >= ric1.GYRAmberMax AND ROUND(SweetSpot*100, ric1.Rounding) < ric1.GYRGreenMax THEN @YellowColour
									WHEN ric1.GYRRedMax IS NULL AND ROUND(SweetSpot*100, ric1.Rounding) < ric1.GYRAmberMax THEN @RedColour
									WHEN ric1.GYRRedMax IS NOT NULL AND ROUND(SweetSpot*100, ric1.Rounding) >= ric1.GYRRedMax THEN @GoldColour
									WHEN ric1.GYRRedMax IS NOT NULL AND ROUND(SweetSpot*100, ric1.Rounding) >= ric1.GYRAmberMax AND ROUND(SweetSpot*100, ric1.Rounding) < ric1.GYRRedMax THEN @SilverColour
									WHEN ric1.GYRRedMax IS NOT NULL AND ROUND(SweetSpot*100, ric1.Rounding) >= ric1.GYRGreenMax AND ROUND(SweetSpot*100, ric1.Rounding) < ric1.GYRAmberMax THEN @BronzeColour
									WHEN ric1.GYRRedMax IS NOT NULL AND ROUND(SweetSpot*100, ric1.Rounding) < ric1.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric1.GYRAmberMax = 0 AND ric1.GYRGreenMax = 0 AND ISNULL(ric1.GYRRedMax,0) = 0 THEN NULL
									WHEN ric1.GYRRedMAX IS NULL AND ROUND(SweetSpot*100, ric1.Rounding) <= ric1.GYRAmberMax THEN @GreenColour
									WHEN ric1.GYRRedMax IS NULL AND ROUND(SweetSpot*100, ric1.Rounding) <= ric1.GYRGreenMax AND ROUND(SweetSpot*100, ric1.Rounding) > ric1.GYRAmberMax THEN @YellowColour
									WHEN ric1.GYRRedMax IS NULL AND ROUND(SweetSpot*100, ric1.Rounding) > ric1.GYRGreenMax THEN @RedColour
									WHEN ric1.GYRRedMax IS NOT NULL AND ROUND(SweetSpot*100, ric1.Rounding) <= ric1.GYRRedMax THEN @GoldColour
									WHEN ric1.GYRRedMax IS NOT NULL AND ROUND(SweetSpot*100, ric1.Rounding) <= ric1.GYRAmberMax AND ROUND(SweetSpot*100, ric1.Rounding) > ric1.GYRRedMax THEN @SilverColour
									WHEN ric1.GYRRedMAx IS NOT NULL AND ROUND(SweetSpot*100, ric1.Rounding) <= ric1.GYRGreenMax AND ROUND(SweetSpot*100, ric1.Rounding) > ric1.GYRAmberMax THEN @BronzeColour
									WHEN ric1.GYRRedMax IS NOT NULL AND ROUND(SweetSpot*100, ric1.Rounding) > ric1.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS SweetSpotColour,

		CASE ric2.HighLow	WHEN 1 THEN
								CASE
									WHEN ric2.GYRAmberMax = 0 AND ric2.GYRGreenMax = 0 AND ISNULL(ric2.GYRRedMax,0) = 0 THEN NULL
									WHEN ric2.GYRRedMax IS NULL AND ROUND(OverRevWithFuel*100, ric2.Rounding) >= ric2.GYRGreenMax THEN @GreenColour
									WHEN ric2.GYRRedMax IS NULL AND ROUND(OverRevWithFuel*100, ric2.Rounding) >= ric2.GYRAmberMax AND ROUND(OverRevWithFuel*100, ric2.Rounding) < ric2.GYRGreenMax THEN @YellowColour
									WHEN ric2.GYRRedMax IS NULL AND ROUND(OverRevWithFuel*100, ric2.Rounding) < ric2.GYRAmberMax THEN @RedColour
									WHEN ric2.GYRRedMax IS NOT NULL AND ROUND(OverRevWithFuel*100, ric2.Rounding) >= ric2.GYRRedMax THEN @GoldColour
									WHEN ric2.GYRRedMax IS NOT NULL AND ROUND(OverRevWithFuel*100, ric2.Rounding) >= ric2.GYRAmberMax AND ROUND(OverRevWithFuel*100, ric2.Rounding) < ric2.GYRRedMax THEN @SilverColour
									WHEN ric2.GYRRedMax IS NOT NULL AND ROUND(OverRevWithFuel*100, ric2.Rounding) >= ric2.GYRGreenMax AND ROUND(OverRevWithFuel*100, ric2.Rounding) < ric2.GYRAmberMax THEN @BronzeColour
									WHEN ric2.GYRRedMax IS NOT NULL AND ROUND(OverRevWithFuel*100, ric2.Rounding) < ric2.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric2.GYRAmberMax = 0 AND ric2.GYRGreenMax = 0 AND ISNULL(ric2.GYRRedMax,0) = 0 THEN NULL
									WHEN ric2.GYRRedMAX IS NULL AND ROUND(OverRevWithFuel*100, ric2.Rounding) <= ric2.GYRAmberMax THEN @GreenColour
									WHEN ric2.GYRRedMax IS NULL AND ROUND(OverRevWithFuel*100, ric2.Rounding) <= ric2.GYRGreenMax AND ROUND(OverRevWithFuel*100, ric2.Rounding) > ric2.GYRAmberMax THEN @YellowColour
									WHEN ric2.GYRRedMax IS NULL AND ROUND(OverRevWithFuel*100, ric2.Rounding) > ric2.GYRGreenMax THEN @RedColour
									WHEN ric2.GYRRedMax IS NOT NULL AND ROUND(OverRevWithFuel*100, ric2.Rounding) <= ric2.GYRRedMax THEN @GoldColour
									WHEN ric2.GYRRedMax IS NOT NULL AND ROUND(OverRevWithFuel*100, ric2.Rounding) <= ric2.GYRAmberMax AND ROUND(OverRevWithFuel*100, ric2.Rounding) > ric2.GYRRedMax THEN @SilverColour
									WHEN ric2.GYRRedMAx IS NOT NULL AND ROUND(OverRevWithFuel*100, ric2.Rounding) <= ric2.GYRGreenMax AND ROUND(OverRevWithFuel*100, ric2.Rounding) > ric2.GYRAmberMax THEN @BronzeColour
									WHEN ric2.GYRRedMax IS NOT NULL AND ROUND(OverRevWithFuel*100, ric2.Rounding) > ric2.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS OverRevWithFuelColour,

		CASE ric3.HighLow	WHEN 1 THEN
								CASE
									WHEN ric3.GYRAmberMax = 0 AND ric3.GYRGreenMax = 0 AND ISNULL(ric3.GYRRedMax,0) = 0 THEN NULL
									WHEN ric3.GYRRedMax IS NULL AND ROUND(TopGear*100, ric3.Rounding) >= ric3.GYRGreenMax THEN @GreenColour
									WHEN ric3.GYRRedMax IS NULL AND ROUND(TopGear*100, ric3.Rounding) >= ric3.GYRAmberMax AND ROUND(TopGear*100, ric3.Rounding) < ric3.GYRGreenMax THEN @YellowColour
									WHEN ric3.GYRRedMax IS NULL AND ROUND(TopGear*100, ric3.Rounding) < ric3.GYRAmberMax THEN @RedColour
									WHEN ric3.GYRRedMax IS NOT NULL AND ROUND(TopGear*100, ric3.Rounding) >= ric3.GYRRedMax THEN @GoldColour
									WHEN ric3.GYRRedMax IS NOT NULL AND ROUND(TopGear*100, ric3.Rounding) >= ric3.GYRAmberMax AND ROUND(TopGear*100, ric3.Rounding) < ric3.GYRRedMax THEN @SilverColour
									WHEN ric3.GYRRedMax IS NOT NULL AND ROUND(TopGear*100, ric3.Rounding) >= ric3.GYRGreenMax AND ROUND(TopGear*100, ric3.Rounding) < ric3.GYRAmberMax THEN @BronzeColour
									WHEN ric3.GYRRedMax IS NOT NULL AND ROUND(TopGear*100, ric3.Rounding) < ric3.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric3.GYRAmberMax = 0 AND ric3.GYRGreenMax = 0 AND ISNULL(ric3.GYRRedMax,0) = 0 THEN NULL
									WHEN ric3.GYRRedMAX IS NULL AND ROUND(TopGear*100, ric3.Rounding) <= ric3.GYRAmberMax THEN @GreenColour
									WHEN ric3.GYRRedMax IS NULL AND ROUND(TopGear*100, ric3.Rounding) <= ric3.GYRGreenMax AND ROUND(TopGear*100, ric3.Rounding) > ric3.GYRAmberMax THEN @YellowColour
									WHEN ric3.GYRRedMax IS NULL AND ROUND(TopGear*100, ric3.Rounding) > ric3.GYRGreenMax THEN @RedColour
									WHEN ric3.GYRRedMax IS NOT NULL AND ROUND(TopGear*100, ric3.Rounding) <= ric3.GYRRedMax THEN @GoldColour
									WHEN ric3.GYRRedMax IS NOT NULL AND ROUND(TopGear*100, ric3.Rounding) <= ric3.GYRAmberMax AND ROUND(TopGear*100, ric3.Rounding) > ric3.GYRRedMax THEN @SilverColour
									WHEN ric3.GYRRedMAx IS NOT NULL AND ROUND(TopGear*100, ric3.Rounding) <= ric3.GYRGreenMax AND ROUND(TopGear*100, ric3.Rounding) > ric3.GYRAmberMax THEN @BronzeColour
									WHEN ric3.GYRRedMax IS NOT NULL AND ROUND(TopGear*100, ric3.Rounding) > ric3.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS TopGearColour,

		CASE ric4.HighLow	WHEN 1 THEN
								CASE
									WHEN ric4.GYRAmberMax = 0 AND ric4.GYRGreenMax = 0 AND ISNULL(ric4.GYRRedMax,0) = 0 THEN NULL
									WHEN ric4.GYRRedMax IS NULL AND ROUND(Cruise*100, ric4.Rounding) >= ric4.GYRGreenMax THEN @GreenColour
									WHEN ric4.GYRRedMax IS NULL AND ROUND(Cruise*100, ric4.Rounding) >= ric4.GYRAmberMax AND ROUND(Cruise*100, ric4.Rounding) < ric4.GYRGreenMax THEN @YellowColour
									WHEN ric4.GYRRedMax IS NULL AND ROUND(Cruise*100, ric4.Rounding) < ric4.GYRAmberMax THEN @RedColour
									WHEN ric4.GYRRedMax IS NOT NULL AND ROUND(Cruise*100, ric4.Rounding) >= ric4.GYRRedMax THEN @GoldColour
									WHEN ric4.GYRRedMax IS NOT NULL AND ROUND(Cruise*100, ric4.Rounding) >= ric4.GYRAmberMax AND ROUND(Cruise*100, ric4.Rounding) < ric4.GYRRedMax THEN @SilverColour
									WHEN ric4.GYRRedMax IS NOT NULL AND ROUND(Cruise*100, ric4.Rounding) >= ric4.GYRGreenMax AND ROUND(Cruise*100, ric4.Rounding) < ric4.GYRAmberMax THEN @BronzeColour
									WHEN ric4.GYRRedMax IS NOT NULL AND ROUND(Cruise*100, ric4.Rounding) < ric4.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric4.GYRAmberMax = 0 AND ric4.GYRGreenMax = 0 AND ISNULL(ric4.GYRRedMax,0) = 0 THEN NULL
									WHEN ric4.GYRRedMAX IS NULL AND ROUND(Cruise*100, ric4.Rounding) <= ric4.GYRAmberMax THEN @GreenColour
									WHEN ric4.GYRRedMax IS NULL AND ROUND(Cruise*100, ric4.Rounding) <= ric4.GYRGreenMax AND ROUND(Cruise*100, ric4.Rounding) > ric4.GYRAmberMax THEN @YellowColour
									WHEN ric4.GYRRedMax IS NULL AND ROUND(Cruise*100, ric4.Rounding) > ric4.GYRGreenMax THEN @RedColour
									WHEN ric4.GYRRedMax IS NOT NULL AND ROUND(Cruise*100, ric4.Rounding) <= ric4.GYRRedMax THEN @GoldColour
									WHEN ric4.GYRRedMax IS NOT NULL AND ROUND(Cruise*100, ric4.Rounding) <= ric4.GYRAmberMax AND ROUND(Cruise*100, ric4.Rounding) > ric4.GYRRedMax THEN @SilverColour
									WHEN ric4.GYRRedMAx IS NOT NULL AND ROUND(Cruise*100, ric4.Rounding) <= ric4.GYRGreenMax AND ROUND(Cruise*100, ric4.Rounding) > ric4.GYRAmberMax THEN @BronzeColour
									WHEN ric4.GYRRedMax IS NOT NULL AND ROUND(Cruise*100, ric4.Rounding) > ric4.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS CruiseColour,

		CASE ric31.HighLow	WHEN 1 THEN
								CASE
									WHEN ric31.GYRAmberMax = 0 AND ric31.GYRGreenMax = 0 AND ISNULL(ric31.GYRRedMax,0) = 0 THEN NULL
									WHEN ric31.GYRRedMax IS NULL AND ROUND(CruiseInTopGears*100, ric31.Rounding) >= ric31.GYRGreenMax THEN @GreenColour
									WHEN ric31.GYRRedMax IS NULL AND ROUND(CruiseInTopGears*100, ric31.Rounding) >= ric31.GYRAmberMax AND ROUND(CruiseInTopGears*100, ric31.Rounding) < ric31.GYRGreenMax THEN @YellowColour
									WHEN ric31.GYRRedMax IS NULL AND ROUND(CruiseInTopGears*100, ric31.Rounding) < ric31.GYRAmberMax THEN @RedColour
									WHEN ric31.GYRRedMax IS NOT NULL AND ROUND(CruiseInTopGears*100, ric31.Rounding) >= ric31.GYRRedMax THEN @GoldColour
									WHEN ric31.GYRRedMax IS NOT NULL AND ROUND(CruiseInTopGears*100, ric31.Rounding) >= ric31.GYRAmberMax AND ROUND(CruiseInTopGears*100, ric31.Rounding) < ric31.GYRRedMax THEN @SilverColour
									WHEN ric31.GYRRedMax IS NOT NULL AND ROUND(CruiseInTopGears*100, ric31.Rounding) >= ric31.GYRGreenMax AND ROUND(CruiseInTopGears*100, ric31.Rounding) < ric31.GYRAmberMax THEN @BronzeColour
									WHEN ric31.GYRRedMax IS NOT NULL AND ROUND(CruiseInTopGears*100, ric31.Rounding) < ric31.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric31.GYRAmberMax = 0 AND ric31.GYRGreenMax = 0 AND ISNULL(ric31.GYRRedMax,0) = 0 THEN NULL
									WHEN ric31.GYRRedMAX IS NULL AND ROUND(CruiseInTopGears*100, ric31.Rounding) <= ric31.GYRAmberMax THEN @GreenColour
									WHEN ric31.GYRRedMax IS NULL AND ROUND(CruiseInTopGears*100, ric31.Rounding) <= ric31.GYRGreenMax AND ROUND(CruiseInTopGears*100, ric31.Rounding) > ric31.GYRAmberMax THEN @YellowColour
									WHEN ric31.GYRRedMax IS NULL AND ROUND(CruiseInTopGears*100, ric31.Rounding) > ric31.GYRGreenMax THEN @RedColour
									WHEN ric31.GYRRedMax IS NOT NULL AND ROUND(CruiseInTopGears*100, ric31.Rounding) <= ric31.GYRRedMax THEN @GoldColour
									WHEN ric31.GYRRedMax IS NOT NULL AND ROUND(CruiseInTopGears*100, ric31.Rounding) <= ric31.GYRAmberMax AND ROUND(CruiseInTopGears*100, ric31.Rounding) > ric31.GYRRedMax THEN @SilverColour
									WHEN ric31.GYRRedMAx IS NOT NULL AND ROUND(CruiseInTopGears*100, ric31.Rounding) <= ric31.GYRGreenMax AND ROUND(CruiseInTopGears*100, ric31.Rounding) > ric31.GYRAmberMax THEN @BronzeColour
									WHEN ric31.GYRRedMax IS NOT NULL AND ROUND(CruiseInTopGears*100, ric31.Rounding) > ric31.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS CruiseInTopGearsColour,

		CASE ric5.HighLow	WHEN 1 THEN
								CASE
									WHEN ric5.GYRAmberMax = 0 AND ric5.GYRGreenMax = 0 AND ISNULL(ric5.GYRRedMax,0) = 0 THEN NULL
									WHEN ric5.GYRRedMax IS NULL AND ROUND(CoastInGear*100, ric5.Rounding) >= ric5.GYRGreenMax THEN @GreenColour
									WHEN ric5.GYRRedMax IS NULL AND ROUND(CoastInGear*100, ric5.Rounding) >= ric5.GYRAmberMax AND ROUND(CoastInGear*100, ric5.Rounding) < ric5.GYRGreenMax THEN @YellowColour
									WHEN ric5.GYRRedMax IS NULL AND ROUND(CoastInGear*100, ric5.Rounding) < ric5.GYRAmberMax THEN @RedColour
									WHEN ric5.GYRRedMax IS NOT NULL AND ROUND(CoastInGear*100, ric5.Rounding) >= ric5.GYRRedMax THEN @GoldColour
									WHEN ric5.GYRRedMax IS NOT NULL AND ROUND(CoastInGear*100, ric5.Rounding) >= ric5.GYRAmberMax AND ROUND(CoastInGear*100, ric5.Rounding) < ric5.GYRRedMax THEN @SilverColour
									WHEN ric5.GYRRedMax IS NOT NULL AND ROUND(CoastInGear*100, ric5.Rounding) >= ric5.GYRGreenMax AND ROUND(CoastInGear*100, ric5.Rounding) < ric5.GYRAmberMax THEN @BronzeColour
									WHEN ric5.GYRRedMax IS NOT NULL AND ROUND(CoastInGear*100, ric5.Rounding) < ric5.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric5.GYRAmberMax = 0 AND ric5.GYRGreenMax = 0 AND ISNULL(ric5.GYRRedMax,0) = 0 THEN NULL
									WHEN ric5.GYRRedMAX IS NULL AND ROUND(CoastInGear*100, ric5.Rounding) <= ric5.GYRAmberMax THEN @GreenColour
									WHEN ric5.GYRRedMax IS NULL AND ROUND(CoastInGear*100, ric5.Rounding) <= ric5.GYRGreenMax AND ROUND(CoastInGear*100, ric5.Rounding) > ric5.GYRAmberMax THEN @YellowColour
									WHEN ric5.GYRRedMax IS NULL AND ROUND(CoastInGear*100, ric5.Rounding) > ric5.GYRGreenMax THEN @RedColour
									WHEN ric5.GYRRedMax IS NOT NULL AND ROUND(CoastInGear*100, ric5.Rounding) <= ric5.GYRRedMax THEN @GoldColour
									WHEN ric5.GYRRedMax IS NOT NULL AND ROUND(CoastInGear*100, ric5.Rounding) <= ric5.GYRAmberMax AND ROUND(CoastInGear*100, ric5.Rounding) > ric5.GYRRedMax THEN @SilverColour
									WHEN ric5.GYRRedMAx IS NOT NULL AND ROUND(CoastInGear*100, ric5.Rounding) <= ric5.GYRGreenMax AND ROUND(CoastInGear*100, ric5.Rounding) > ric5.GYRAmberMax THEN @BronzeColour
									WHEN ric5.GYRRedMax IS NOT NULL AND ROUND(CoastInGear*100, ric5.Rounding) > ric5.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS CoastInGearColour,

		CASE ric6.HighLow	WHEN 1 THEN
								CASE
									WHEN ric6.GYRAmberMax = 0 AND ric6.GYRGreenMax = 0 AND ISNULL(ric6.GYRRedMax,0) = 0 THEN NULL
									WHEN ric6.GYRRedMax IS NULL AND ROUND(Idle*100, ric6.Rounding) >= ric6.GYRGreenMax THEN @GreenColour
									WHEN ric6.GYRRedMax IS NULL AND ROUND(Idle*100, ric6.Rounding) >= ric6.GYRAmberMax AND ROUND(Idle*100, ric6.Rounding) < ric6.GYRGreenMax THEN @YellowColour
									WHEN ric6.GYRRedMax IS NULL AND ROUND(Idle*100, ric6.Rounding) < ric6.GYRAmberMax THEN @RedColour
									WHEN ric6.GYRRedMax IS NOT NULL AND ROUND(Idle*100, ric6.Rounding) >= ric6.GYRRedMax THEN @GoldColour
									WHEN ric6.GYRRedMax IS NOT NULL AND ROUND(Idle*100, ric6.Rounding) >= ric6.GYRAmberMax AND ROUND(Idle*100, ric6.Rounding) < ric6.GYRRedMax THEN @SilverColour
									WHEN ric6.GYRRedMax IS NOT NULL AND ROUND(Idle*100, ric6.Rounding) >= ric6.GYRGreenMax AND ROUND(Idle*100, ric6.Rounding) < ric6.GYRAmberMax THEN @BronzeColour
									WHEN ric6.GYRRedMax IS NOT NULL AND ROUND(Idle*100, ric6.Rounding) < ric6.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric6.GYRAmberMax = 0 AND ric6.GYRGreenMax = 0 AND ISNULL(ric6.GYRRedMax,0) = 0 THEN NULL
									WHEN ric6.GYRRedMAX IS NULL AND ROUND(Idle*100, ric6.Rounding) <= ric6.GYRAmberMax THEN @GreenColour
									WHEN ric6.GYRRedMax IS NULL AND ROUND(Idle*100, ric6.Rounding) <= ric6.GYRGreenMax AND ROUND(Idle*100, ric6.Rounding) > ric6.GYRAmberMax THEN @YellowColour
									WHEN ric6.GYRRedMax IS NULL AND ROUND(Idle*100, ric6.Rounding) > ric6.GYRGreenMax THEN @RedColour
									WHEN ric6.GYRRedMax IS NOT NULL AND ROUND(Idle*100, ric6.Rounding) <= ric6.GYRRedMax THEN @GoldColour
									WHEN ric6.GYRRedMax IS NOT NULL AND ROUND(Idle*100, ric6.Rounding) <= ric6.GYRAmberMax AND ROUND(Idle*100, ric6.Rounding) > ric6.GYRRedMax THEN @SilverColour
									WHEN ric6.GYRRedMAx IS NOT NULL AND ROUND(Idle*100, ric6.Rounding) <= ric6.GYRGreenMax AND ROUND(Idle*100, ric6.Rounding) > ric6.GYRAmberMax THEN @BronzeColour
									WHEN ric6.GYRRedMax IS NOT NULL AND ROUND(Idle*100, ric6.Rounding) > ric6.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS IdleColour,

		CASE ric7.HighLow	WHEN 1 THEN
								CASE
									WHEN ric7.GYRAmberMax = 0 AND ric7.GYRGreenMax = 0 AND ISNULL(ric7.GYRRedMax,0) = 0 THEN NULL
									WHEN ric7.GYRRedMax IS NULL AND ROUND(EngineServiceBrake*100, ric7.Rounding) >= ric7.GYRGreenMax THEN @GreenColour
									WHEN ric7.GYRRedMax IS NULL AND ROUND(EngineServiceBrake*100, ric7.Rounding) >= ric7.GYRAmberMax AND ROUND(EngineServiceBrake*100, ric7.Rounding) < ric7.GYRGreenMax THEN @YellowColour
									WHEN ric7.GYRRedMax IS NULL AND ROUND(EngineServiceBrake*100, ric7.Rounding) < ric7.GYRAmberMax THEN @RedColour
									WHEN ric7.GYRRedMax IS NOT NULL AND ROUND(EngineServiceBrake*100, ric7.Rounding) >= ric7.GYRRedMax THEN @GoldColour
									WHEN ric7.GYRRedMax IS NOT NULL AND ROUND(EngineServiceBrake*100, ric7.Rounding) >= ric7.GYRAmberMax AND ROUND(EngineServiceBrake*100, ric7.Rounding) < ric7.GYRRedMax THEN @SilverColour
									WHEN ric7.GYRRedMax IS NOT NULL AND ROUND(EngineServiceBrake*100, ric7.Rounding) >= ric7.GYRGreenMax AND ROUND(EngineServiceBrake*100, ric7.Rounding) < ric7.GYRAmberMax THEN @BronzeColour
									WHEN ric7.GYRRedMax IS NOT NULL AND ROUND(EngineServiceBrake*100, ric7.Rounding) < ric7.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric7.GYRAmberMax = 0 AND ric7.GYRGreenMax = 0 AND ISNULL(ric7.GYRRedMax,0) = 0 THEN NULL
									WHEN ric7.GYRRedMAX IS NULL AND ROUND(EngineServiceBrake*100, ric7.Rounding) <= ric7.GYRAmberMax THEN @GreenColour
									WHEN ric7.GYRRedMax IS NULL AND ROUND(EngineServiceBrake*100, ric7.Rounding) <= ric7.GYRGreenMax AND ROUND(EngineServiceBrake*100, ric7.Rounding) > ric7.GYRAmberMax THEN @YellowColour
									WHEN ric7.GYRRedMax IS NULL AND ROUND(EngineServiceBrake*100, ric7.Rounding) > ric7.GYRGreenMax THEN @RedColour
									WHEN ric7.GYRRedMax IS NOT NULL AND ROUND(EngineServiceBrake*100, ric7.Rounding) <= ric7.GYRRedMax THEN @GoldColour
									WHEN ric7.GYRRedMax IS NOT NULL AND ROUND(EngineServiceBrake*100, ric7.Rounding) <= ric7.GYRAmberMax AND ROUND(EngineServiceBrake*100, ric7.Rounding) > ric7.GYRRedMax THEN @SilverColour
									WHEN ric7.GYRRedMAx IS NOT NULL AND ROUND(EngineServiceBrake*100, ric7.Rounding) <= ric7.GYRGreenMax AND ROUND(EngineServiceBrake*100, ric7.Rounding) > ric7.GYRAmberMax THEN @BronzeColour
									WHEN ric7.GYRRedMax IS NOT NULL AND ROUND(EngineServiceBrake*100, ric7.Rounding) > ric7.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS EngineServiceBrakeColour,

		CASE ric8.HighLow	WHEN 1 THEN
								CASE
									WHEN ric8.GYRAmberMax = 0 AND ric8.GYRGreenMax = 0 AND ISNULL(ric8.GYRRedMax,0) = 0 THEN NULL
									WHEN ric8.GYRRedMax IS NULL AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) >= ric8.GYRGreenMax THEN @GreenColour
									WHEN ric8.GYRRedMax IS NULL AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) >= ric8.GYRAmberMax AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) < ric8.GYRGreenMax THEN @YellowColour
									WHEN ric8.GYRRedMax IS NULL AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) < ric8.GYRAmberMax THEN @RedColour
									WHEN ric8.GYRRedMax IS NOT NULL AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) >= ric8.GYRRedMax THEN @GoldColour
									WHEN ric8.GYRRedMax IS NOT NULL AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) >= ric8.GYRAmberMax AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) < ric8.GYRRedMax THEN @SilverColour
									WHEN ric8.GYRRedMax IS NOT NULL AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) >= ric8.GYRGreenMax AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) < ric8.GYRAmberMax THEN @BronzeColour
									WHEN ric8.GYRRedMax IS NOT NULL AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) < ric8.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric8.GYRAmberMax = 0 AND ric8.GYRGreenMax = 0 AND ISNULL(ric8.GYRRedMax,0) = 0 THEN NULL
									WHEN ric8.GYRRedMAX IS NULL AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) <= ric8.GYRAmberMax THEN @GreenColour
									WHEN ric8.GYRRedMax IS NULL AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) <= ric8.GYRGreenMax AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) > ric8.GYRAmberMax THEN @YellowColour
									WHEN ric8.GYRRedMax IS NULL AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) > ric8.GYRGreenMax THEN @RedColour
									WHEN ric8.GYRRedMax IS NOT NULL AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) <= ric8.GYRRedMax THEN @GoldColour
									WHEN ric8.GYRRedMax IS NOT NULL AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) <= ric8.GYRAmberMax AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) > ric8.GYRRedMax THEN @SilverColour
									WHEN ric8.GYRRedMAx IS NOT NULL AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) <= ric8.GYRGreenMax AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) > ric8.GYRAmberMax THEN @BronzeColour
									WHEN ric8.GYRRedMax IS NOT NULL AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) > ric8.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS OverRevWithoutFuelColour,

		CASE ric9.HighLow	WHEN 1 THEN
								CASE
									WHEN ric9.GYRAmberMax = 0 AND ric9.GYRGreenMax = 0 AND ISNULL(ric9.GYRRedMax,0) = 0 THEN NULL
									WHEN ric9.GYRRedMax IS NULL AND ROUND(Rop, ric9.Rounding) >= ric9.GYRGreenMax THEN @GreenColour
									WHEN ric9.GYRRedMax IS NULL AND ROUND(Rop, ric9.Rounding) >= ric9.GYRAmberMax AND ROUND(Rop, ric9.Rounding) < ric9.GYRGreenMax THEN @YellowColour
									WHEN ric9.GYRRedMax IS NULL AND ROUND(Rop, ric9.Rounding) < ric9.GYRAmberMax THEN @RedColour
									WHEN ric9.GYRRedMax IS NOT NULL AND ROUND(Rop, ric9.Rounding) >= ric9.GYRRedMax THEN @GoldColour
									WHEN ric9.GYRRedMax IS NOT NULL AND ROUND(Rop, ric9.Rounding) >= ric9.GYRAmberMax AND ROUND(Rop, ric9.Rounding) < ric9.GYRRedMax THEN @SilverColour
									WHEN ric9.GYRRedMax IS NOT NULL AND ROUND(Rop, ric9.Rounding) >= ric9.GYRGreenMax AND ROUND(Rop, ric9.Rounding) < ric9.GYRAmberMax THEN @BronzeColour
									WHEN ric9.GYRRedMax IS NOT NULL AND ROUND(Rop, ric9.Rounding) < ric9.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric9.GYRAmberMax = 0 AND ric9.GYRGreenMax = 0 AND ISNULL(ric9.GYRRedMax,0) = 0 THEN NULL
									WHEN ric9.GYRRedMAX IS NULL AND ROUND(Rop, ric9.Rounding) <= ric9.GYRAmberMax THEN @GreenColour
									WHEN ric9.GYRRedMax IS NULL AND ROUND(Rop, ric9.Rounding) <= ric9.GYRGreenMax AND ROUND(Rop, ric9.Rounding) > ric9.GYRAmberMax THEN @YellowColour
									WHEN ric9.GYRRedMax IS NULL AND ROUND(Rop, ric9.Rounding) > ric9.GYRGreenMax THEN @RedColour
									WHEN ric9.GYRRedMax IS NOT NULL AND ROUND(Rop, ric9.Rounding) <= ric9.GYRRedMax THEN @GoldColour
									WHEN ric9.GYRRedMax IS NOT NULL AND ROUND(Rop, ric9.Rounding) <= ric9.GYRAmberMax AND ROUND(Rop, ric9.Rounding) > ric9.GYRRedMax THEN @SilverColour
									WHEN ric9.GYRRedMAx IS NOT NULL AND ROUND(Rop, ric9.Rounding) <= ric9.GYRGreenMax AND ROUND(Rop, ric9.Rounding) > ric9.GYRAmberMax THEN @BronzeColour
									WHEN ric9.GYRRedMax IS NOT NULL AND ROUND(Rop, ric9.Rounding) > ric9.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS RopColour,

		CASE ric41.HighLow	WHEN 1 THEN
								CASE
									WHEN ric41.GYRAmberMax = 0 AND ric41.GYRGreenMax = 0 AND ISNULL(ric41.GYRRedMax,0) = 0 THEN NULL
									WHEN ric41.GYRRedMax IS NULL AND ROUND(Rop2, ric41.Rounding) >= ric41.GYRGreenMax THEN @GreenColour
									WHEN ric41.GYRRedMax IS NULL AND ROUND(Rop2, ric41.Rounding) >= ric41.GYRAmberMax AND ROUND(Rop2, ric41.Rounding) < ric41.GYRGreenMax THEN @YellowColour
									WHEN ric41.GYRRedMax IS NULL AND ROUND(Rop2, ric41.Rounding) < ric41.GYRAmberMax THEN @RedColour
									WHEN ric41.GYRRedMax IS NOT NULL AND ROUND(Rop2, ric41.Rounding) >= ric41.GYRRedMax THEN @GoldColour
									WHEN ric41.GYRRedMax IS NOT NULL AND ROUND(Rop2, ric41.Rounding) >= ric41.GYRAmberMax AND ROUND(Rop2, ric41.Rounding) < ric41.GYRRedMax THEN @SilverColour
									WHEN ric41.GYRRedMax IS NOT NULL AND ROUND(Rop2, ric41.Rounding) >= ric41.GYRGreenMax AND ROUND(Rop2, ric41.Rounding) < ric41.GYRAmberMax THEN @BronzeColour
									WHEN ric41.GYRRedMax IS NOT NULL AND ROUND(Rop2, ric41.Rounding) < ric41.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric41.GYRAmberMax = 0 AND ric41.GYRGreenMax = 0 AND ISNULL(ric41.GYRRedMax,0) = 0 THEN NULL
									WHEN ric41.GYRRedMAX IS NULL AND ROUND(Rop2, ric41.Rounding) <= ric41.GYRAmberMax THEN @GreenColour
									WHEN ric41.GYRRedMax IS NULL AND ROUND(Rop2, ric41.Rounding) <= ric41.GYRGreenMax AND ROUND(Rop2, ric41.Rounding) > ric41.GYRAmberMax THEN @YellowColour
									WHEN ric41.GYRRedMax IS NULL AND ROUND(Rop2, ric41.Rounding) > ric41.GYRGreenMax THEN @RedColour
									WHEN ric41.GYRRedMax IS NOT NULL AND ROUND(Rop2, ric41.Rounding) <= ric41.GYRRedMax THEN @GoldColour
									WHEN ric41.GYRRedMax IS NOT NULL AND ROUND(Rop2, ric41.Rounding) <= ric41.GYRAmberMax AND ROUND(Rop2, ric41.Rounding) > ric41.GYRRedMax THEN @SilverColour
									WHEN ric41.GYRRedMAx IS NOT NULL AND ROUND(Rop2, ric41.Rounding) <= ric41.GYRGreenMax AND ROUND(Rop2, ric41.Rounding) > ric41.GYRAmberMax THEN @BronzeColour
									WHEN ric41.GYRRedMax IS NOT NULL AND ROUND(Rop2, ric41.Rounding) > ric41.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS Rop2Colour,

		CASE ric10.HighLow	WHEN 1 THEN
								CASE
									WHEN ric10.GYRAmberMax = 0 AND ric10.GYRGreenMax = 0 AND ISNULL(ric10.GYRRedMax,0) = 0 THEN NULL
									WHEN ric10.GYRRedMax IS NULL AND ROUND(OverSpeed*100, ric10.Rounding) >= ric10.GYRGreenMax THEN @GreenColour
									WHEN ric10.GYRRedMax IS NULL AND ROUND(OverSpeed*100, ric10.Rounding) >= ric10.GYRAmberMax AND ROUND(OverSpeed*100, ric10.Rounding) < ric10.GYRGreenMax THEN @YellowColour
									WHEN ric10.GYRRedMax IS NULL AND ROUND(OverSpeed*100, ric10.Rounding) < ric10.GYRAmberMax THEN @RedColour
									WHEN ric10.GYRRedMax IS NOT NULL AND ROUND(OverSpeed*100, ric10.Rounding) >= ric10.GYRRedMax THEN @GoldColour
									WHEN ric10.GYRRedMax IS NOT NULL AND ROUND(OverSpeed*100, ric10.Rounding) >= ric10.GYRAmberMax AND ROUND(OverSpeed*100, ric10.Rounding) < ric10.GYRRedMax THEN @SilverColour
									WHEN ric10.GYRRedMax IS NOT NULL AND ROUND(OverSpeed*100, ric10.Rounding) >= ric10.GYRGreenMax AND ROUND(OverSpeed*100, ric10.Rounding) < ric10.GYRAmberMax THEN @BronzeColour
									WHEN ric10.GYRRedMax IS NOT NULL AND ROUND(OverSpeed*100, ric10.Rounding) < ric10.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric10.GYRAmberMax = 0 AND ric10.GYRGreenMax = 0 AND ISNULL(ric10.GYRRedMax,0) = 0 THEN NULL
									WHEN ric10.GYRRedMAX IS NULL AND ROUND(OverSpeed*100, ric10.Rounding) <= ric10.GYRAmberMax THEN @GreenColour
									WHEN ric10.GYRRedMax IS NULL AND ROUND(OverSpeed*100, ric10.Rounding) <= ric10.GYRGreenMax AND ROUND(OverSpeed*100, ric10.Rounding) > ric10.GYRAmberMax THEN @YellowColour
									WHEN ric10.GYRRedMax IS NULL AND ROUND(OverSpeed*100, ric10.Rounding) > ric10.GYRGreenMax THEN @RedColour
									WHEN ric10.GYRRedMax IS NOT NULL AND ROUND(OverSpeed*100, ric10.Rounding) <= ric10.GYRRedMax THEN @GoldColour
									WHEN ric10.GYRRedMax IS NOT NULL AND ROUND(OverSpeed*100, ric10.Rounding) <= ric10.GYRAmberMax AND ROUND(OverSpeed*100, ric10.Rounding) > ric10.GYRRedMax THEN @SilverColour
									WHEN ric10.GYRRedMAx IS NOT NULL AND ROUND(OverSpeed*100, ric10.Rounding) <= ric10.GYRGreenMax AND ROUND(OverSpeed*100, ric10.Rounding) > ric10.GYRAmberMax THEN @BronzeColour
									WHEN ric10.GYRRedMax IS NOT NULL AND ROUND(OverSpeed*100, ric10.Rounding) > ric10.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS OverSpeedColour,

		CASE ric32.HighLow	WHEN 1 THEN
								CASE
									WHEN ric32.GYRAmberMax = 0 AND ric32.GYRGreenMax = 0 AND ISNULL(ric32.GYRRedMax,0) = 0 THEN NULL
									WHEN ric32.GYRRedMax IS NULL AND ROUND(OverSpeedHigh*100, ric32.Rounding) >= ric32.GYRGreenMax THEN @GreenColour
									WHEN ric32.GYRRedMax IS NULL AND ROUND(OverSpeedHigh*100, ric32.Rounding) >= ric32.GYRAmberMax AND ROUND(OverSpeedHigh*100, ric32.Rounding) < ric32.GYRGreenMax THEN @YellowColour
									WHEN ric32.GYRRedMax IS NULL AND ROUND(OverSpeedHigh*100, ric32.Rounding) < ric32.GYRAmberMax THEN @RedColour
									WHEN ric32.GYRRedMax IS NOT NULL AND ROUND(OverSpeedHigh*100, ric32.Rounding) >= ric32.GYRRedMax THEN @GoldColour
									WHEN ric32.GYRRedMax IS NOT NULL AND ROUND(OverSpeedHigh*100, ric32.Rounding) >= ric32.GYRAmberMax AND ROUND(OverSpeedHigh*100, ric32.Rounding) < ric32.GYRRedMax THEN @SilverColour
									WHEN ric32.GYRRedMax IS NOT NULL AND ROUND(OverSpeedHigh*100, ric32.Rounding) >= ric32.GYRGreenMax AND ROUND(OverSpeedHigh*100, ric32.Rounding) < ric32.GYRAmberMax THEN @BronzeColour
									WHEN ric32.GYRRedMax IS NOT NULL AND ROUND(OverSpeedHigh*100, ric32.Rounding) < ric32.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric32.GYRAmberMax = 0 AND ric32.GYRGreenMax = 0 AND ISNULL(ric32.GYRRedMax,0) = 0 THEN NULL
									WHEN ric32.GYRRedMAX IS NULL AND ROUND(OverSpeedHigh*100, ric32.Rounding) <= ric32.GYRAmberMax THEN @GreenColour
									WHEN ric32.GYRRedMax IS NULL AND ROUND(OverSpeedHigh*100, ric32.Rounding) <= ric32.GYRGreenMax AND ROUND(OverSpeedHigh*100, ric32.Rounding) > ric32.GYRAmberMax THEN @YellowColour
									WHEN ric32.GYRRedMax IS NULL AND ROUND(OverSpeedHigh*100, ric32.Rounding) > ric32.GYRGreenMax THEN @RedColour
									WHEN ric32.GYRRedMax IS NOT NULL AND ROUND(OverSpeedHigh*100, ric32.Rounding) <= ric32.GYRRedMax THEN @GoldColour
									WHEN ric32.GYRRedMax IS NOT NULL AND ROUND(OverSpeedHigh*100, ric32.Rounding) <= ric32.GYRAmberMax AND ROUND(OverSpeedHigh*100, ric32.Rounding) > ric32.GYRRedMax THEN @SilverColour
									WHEN ric32.GYRRedMAx IS NOT NULL AND ROUND(OverSpeedHigh*100, ric32.Rounding) <= ric32.GYRGreenMax AND ROUND(OverSpeedHigh*100, ric32.Rounding) > ric32.GYRAmberMax THEN @BronzeColour
									WHEN ric32.GYRRedMax IS NOT NULL AND ROUND(OverSpeedHigh*100, ric32.Rounding) > ric32.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS OverSpeedHighColour,

		CASE ric30.HighLow	WHEN 1 THEN
								CASE
									WHEN ric30.GYRAmberMax = 0 AND ric30.GYRGreenMax = 0 AND ISNULL(ric30.GYRRedMax,0) = 0 THEN NULL
									WHEN ric30.GYRRedMax IS NULL AND ROUND(IVHOverSpeed*100, ric30.Rounding) >= ric30.GYRGreenMax THEN @GreenColour
									WHEN ric30.GYRRedMax IS NULL AND ROUND(IVHOverSpeed*100, ric30.Rounding) >= ric30.GYRAmberMax AND ROUND(IVHOverSpeed*100, ric30.Rounding) < ric30.GYRGreenMax THEN @YellowColour
									WHEN ric30.GYRRedMax IS NULL AND ROUND(IVHOverSpeed*100, ric30.Rounding) < ric30.GYRAmberMax THEN @RedColour
									WHEN ric30.GYRRedMax IS NOT NULL AND ROUND(IVHOverSpeed*100, ric30.Rounding) >= ric30.GYRRedMax THEN @GoldColour
									WHEN ric30.GYRRedMax IS NOT NULL AND ROUND(IVHOverSpeed*100, ric30.Rounding) >= ric30.GYRAmberMax AND ROUND(IVHOverSpeed*100, ric30.Rounding) < ric30.GYRRedMax THEN @SilverColour
									WHEN ric30.GYRRedMax IS NOT NULL AND ROUND(IVHOverSpeed*100, ric30.Rounding) >= ric30.GYRGreenMax AND ROUND(IVHOverSpeed*100, ric30.Rounding) < ric30.GYRAmberMax THEN @BronzeColour
									WHEN ric30.GYRRedMax IS NOT NULL AND ROUND(IVHOverSpeed*100, ric30.Rounding) < ric30.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric30.GYRAmberMax = 0 AND ric30.GYRGreenMax = 0 AND ISNULL(ric30.GYRRedMax,0) = 0 THEN NULL
									WHEN ric30.GYRRedMAX IS NULL AND ROUND(IVHOverSpeed*100, ric30.Rounding) <= ric30.GYRAmberMax THEN @GreenColour
									WHEN ric30.GYRRedMax IS NULL AND ROUND(IVHOverSpeed*100, ric30.Rounding) <= ric30.GYRGreenMax AND ROUND(IVHOverSpeed*100, ric30.Rounding) > ric30.GYRAmberMax THEN @YellowColour
									WHEN ric30.GYRRedMax IS NULL AND ROUND(IVHOverSpeed*100, ric30.Rounding) > ric30.GYRGreenMax THEN @RedColour
									WHEN ric30.GYRRedMax IS NOT NULL AND ROUND(IVHOverSpeed*100, ric30.Rounding) <= ric30.GYRRedMax THEN @GoldColour
									WHEN ric30.GYRRedMax IS NOT NULL AND ROUND(IVHOverSpeed*100, ric30.Rounding) <= ric30.GYRAmberMax AND ROUND(IVHOverSpeed*100, ric30.Rounding) > ric30.GYRRedMax THEN @SilverColour
									WHEN ric30.GYRRedMAx IS NOT NULL AND ROUND(IVHOverSpeed*100, ric30.Rounding) <= ric30.GYRGreenMax AND ROUND(IVHOverSpeed*100, ric30.Rounding) > ric30.GYRAmberMax THEN @BronzeColour
									WHEN ric30.GYRRedMax IS NOT NULL AND ROUND(IVHOverSpeed*100, ric30.Rounding) > ric30.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS IVHOverSpeedColour,

		CASE ric11.HighLow	WHEN 1 THEN
								CASE
									WHEN ric11.GYRAmberMax = 0 AND ric11.GYRGreenMax = 0 AND ISNULL(ric11.GYRRedMax,0) = 0 THEN NULL
									WHEN ric11.GYRRedMax IS NULL AND ROUND(CoastOutOfGear*100, ric11.Rounding) >= ric11.GYRGreenMax THEN @GreenColour
									WHEN ric11.GYRRedMax IS NULL AND ROUND(CoastOutOfGear*100, ric11.Rounding) >= ric11.GYRAmberMax AND ROUND(CoastOutOfGear*100, ric11.Rounding) < ric11.GYRGreenMax THEN @YellowColour
									WHEN ric11.GYRRedMax IS NULL AND ROUND(CoastOutOfGear*100, ric11.Rounding) < ric11.GYRAmberMax THEN @RedColour
									WHEN ric11.GYRRedMax IS NOT NULL AND ROUND(CoastOutOfGear*100, ric11.Rounding) >= ric11.GYRRedMax THEN @GoldColour
									WHEN ric11.GYRRedMax IS NOT NULL AND ROUND(CoastOutOfGear*100, ric11.Rounding) >= ric11.GYRAmberMax AND ROUND(CoastOutOfGear*100, ric11.Rounding) < ric11.GYRRedMax THEN @SilverColour
									WHEN ric11.GYRRedMax IS NOT NULL AND ROUND(CoastOutOfGear*100, ric11.Rounding) >= ric11.GYRGreenMax AND ROUND(CoastOutOfGear*100, ric11.Rounding) < ric11.GYRAmberMax THEN @BronzeColour
									WHEN ric11.GYRRedMax IS NOT NULL AND ROUND(CoastOutOfGear*100, ric11.Rounding) < ric11.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric11.GYRAmberMax = 0 AND ric11.GYRGreenMax = 0 AND ISNULL(ric11.GYRRedMax,0) = 0 THEN NULL
									WHEN ric11.GYRRedMAX IS NULL AND ROUND(CoastOutOfGear*100, ric11.Rounding) <= ric11.GYRAmberMax THEN @GreenColour
									WHEN ric11.GYRRedMax IS NULL AND ROUND(CoastOutOfGear*100, ric11.Rounding) <= ric11.GYRGreenMax AND ROUND(CoastOutOfGear*100, ric11.Rounding) > ric11.GYRAmberMax THEN @YellowColour
									WHEN ric11.GYRRedMax IS NULL AND ROUND(CoastOutOfGear*100, ric11.Rounding) > ric11.GYRGreenMax THEN @RedColour
									WHEN ric11.GYRRedMax IS NOT NULL AND ROUND(CoastOutOfGear*100, ric11.Rounding) <= ric11.GYRRedMax THEN @GoldColour
									WHEN ric11.GYRRedMax IS NOT NULL AND ROUND(CoastOutOfGear*100, ric11.Rounding) <= ric11.GYRAmberMax AND ROUND(CoastOutOfGear*100, ric11.Rounding) > ric11.GYRRedMax THEN @SilverColour
									WHEN ric11.GYRRedMAx IS NOT NULL AND ROUND(CoastOutOfGear*100, ric11.Rounding) <= ric11.GYRGreenMax AND ROUND(CoastOutOfGear*100, ric11.Rounding) > ric11.GYRAmberMax THEN @BronzeColour
									WHEN ric11.GYRRedMax IS NOT NULL AND ROUND(CoastOutOfGear*100, ric11.Rounding) > ric11.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS CoastOutOfGearColour,

		CASE ric12.HighLow	WHEN 1 THEN
								CASE
									WHEN ric12.GYRAmberMax = 0 AND ric12.GYRGreenMax = 0 AND ISNULL(ric12.GYRRedMax,0) = 0 THEN NULL
									WHEN ric12.GYRRedMax IS NULL AND ROUND(HarshBraking, ric12.Rounding) >= ric12.GYRGreenMax THEN @GreenColour
									WHEN ric12.GYRRedMax IS NULL AND ROUND(HarshBraking, ric12.Rounding) >= ric12.GYRAmberMax AND ROUND(HarshBraking, ric12.Rounding) < ric12.GYRGreenMax THEN @YellowColour
									WHEN ric12.GYRRedMax IS NULL AND ROUND(HarshBraking, ric12.Rounding) < ric12.GYRAmberMax THEN @RedColour
									WHEN ric12.GYRRedMax IS NOT NULL AND ROUND(HarshBraking, ric12.Rounding) >= ric12.GYRRedMax THEN @GoldColour
									WHEN ric12.GYRRedMax IS NOT NULL AND ROUND(HarshBraking, ric12.Rounding) >= ric12.GYRAmberMax AND ROUND(HarshBraking, ric12.Rounding) < ric12.GYRRedMax THEN @SilverColour
									WHEN ric12.GYRRedMax IS NOT NULL AND ROUND(HarshBraking, ric12.Rounding) >= ric12.GYRGreenMax AND ROUND(HarshBraking, ric12.Rounding) < ric12.GYRAmberMax THEN @BronzeColour
									WHEN ric12.GYRRedMax IS NOT NULL AND ROUND(HarshBraking, ric12.Rounding) < ric12.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric12.GYRAmberMax = 0 AND ric12.GYRGreenMax = 0 AND ISNULL(ric12.GYRRedMax,0) = 0 THEN NULL
									WHEN ric12.GYRRedMAX IS NULL AND ROUND(HarshBraking, ric12.Rounding) <= ric12.GYRAmberMax THEN @GreenColour
									WHEN ric12.GYRRedMax IS NULL AND ROUND(HarshBraking, ric12.Rounding) <= ric12.GYRGreenMax AND ROUND(HarshBraking, ric12.Rounding) > ric12.GYRAmberMax THEN @YellowColour
									WHEN ric12.GYRRedMax IS NULL AND ROUND(HarshBraking, ric12.Rounding) > ric12.GYRGreenMax THEN @RedColour
									WHEN ric12.GYRRedMax IS NOT NULL AND ROUND(HarshBraking, ric12.Rounding) <= ric12.GYRRedMax THEN @GoldColour
									WHEN ric12.GYRRedMax IS NOT NULL AND ROUND(HarshBraking, ric12.Rounding) <= ric12.GYRAmberMax AND ROUND(HarshBraking, ric12.Rounding) > ric12.GYRRedMax THEN @SilverColour
									WHEN ric12.GYRRedMAx IS NOT NULL AND ROUND(HarshBraking, ric12.Rounding) <= ric12.GYRGreenMax AND ROUND(HarshBraking, ric12.Rounding) > ric12.GYRAmberMax THEN @BronzeColour
									WHEN ric12.GYRRedMax IS NOT NULL AND ROUND(HarshBraking, ric12.Rounding) > ric12.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS HarshBrakingColour,

		CASE ric14.HighLow	WHEN 1 THEN
								CASE
									WHEN ric14.GYRAmberMax = 0 AND ric14.GYRGreenMax = 0 AND ISNULL(ric14.GYRRedMax,0) = 0 THEN NULL
									WHEN ric14.GYRRedMax IS NULL AND ROUND(Efficiency, ric14.Rounding) >= ric14.GYRGreenMax THEN @GreenColour
									WHEN ric14.GYRRedMax IS NULL AND ROUND(Efficiency, ric14.Rounding) >= ric14.GYRAmberMax AND ROUND(Efficiency, ric14.Rounding) < ric14.GYRGreenMax THEN @YellowColour
									WHEN ric14.GYRRedMax IS NULL AND ROUND(Efficiency, ric14.Rounding) < ric14.GYRAmberMax THEN @RedColour
									WHEN ric14.GYRRedMax IS NOT NULL AND ROUND(Efficiency, ric14.Rounding) >= ric14.GYRRedMax THEN @GoldColour
									WHEN ric14.GYRRedMax IS NOT NULL AND ROUND(Efficiency, ric14.Rounding) >= ric14.GYRAmberMax AND ROUND(Efficiency, ric14.Rounding) < ric14.GYRRedMax THEN @SilverColour
									WHEN ric14.GYRRedMax IS NOT NULL AND ROUND(Efficiency, ric14.Rounding) >= ric14.GYRGreenMax AND ROUND(Efficiency, ric14.Rounding) < ric14.GYRAmberMax THEN @BronzeColour
									WHEN ric14.GYRRedMax IS NOT NULL AND ROUND(Efficiency, ric14.Rounding) < ric14.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric14.GYRAmberMax = 0 AND ric14.GYRGreenMax = 0 AND ISNULL(ric14.GYRRedMax,0) = 0 THEN NULL
									WHEN ric14.GYRRedMAX IS NULL AND ROUND(Efficiency, ric14.Rounding) <= ric14.GYRAmberMax THEN @GreenColour
									WHEN ric14.GYRRedMax IS NULL AND ROUND(Efficiency, ric14.Rounding) <= ric14.GYRGreenMax AND ROUND(Efficiency, ric14.Rounding) > ric14.GYRAmberMax THEN @YellowColour
									WHEN ric14.GYRRedMax IS NULL AND ROUND(Efficiency, ric14.Rounding) > ric14.GYRGreenMax THEN @RedColour
									WHEN ric14.GYRRedMax IS NOT NULL AND ROUND(Efficiency, ric14.Rounding) <= ric14.GYRRedMax THEN @GoldColour
									WHEN ric14.GYRRedMax IS NOT NULL AND ROUND(Efficiency, ric14.Rounding) <= ric14.GYRAmberMax AND ROUND(Efficiency, ric14.Rounding) > ric14.GYRRedMax THEN @SilverColour
									WHEN ric14.GYRRedMAx IS NOT NULL AND ROUND(Efficiency, ric14.Rounding) <= ric14.GYRGreenMax AND ROUND(Efficiency, ric14.Rounding) > ric14.GYRAmberMax THEN @BronzeColour
									WHEN ric14.GYRRedMax IS NOT NULL AND ROUND(Efficiency, ric14.Rounding) > ric14.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS EfficiencyColour,

		CASE ric15.HighLow	WHEN 1 THEN
								CASE
									WHEN ric15.GYRAmberMax = 0 AND ric15.GYRGreenMax = 0 AND ISNULL(ric15.GYRRedMax,0) = 0 THEN NULL
									WHEN ric15.GYRRedMax IS NULL AND ROUND(Safety, ric15.Rounding) >= ric15.GYRGreenMax THEN @GreenColour
									WHEN ric15.GYRRedMax IS NULL AND ROUND(Safety, ric15.Rounding) >= ric15.GYRAmberMax AND ROUND(Safety, ric15.Rounding) < ric15.GYRGreenMax THEN @YellowColour
									WHEN ric15.GYRRedMax IS NULL AND ROUND(Safety, ric15.Rounding) < ric15.GYRAmberMax THEN @RedColour
									WHEN ric15.GYRRedMax IS NOT NULL AND ROUND(Safety, ric15.Rounding) >= ric15.GYRRedMax THEN @GoldColour
									WHEN ric15.GYRRedMax IS NOT NULL AND ROUND(Safety, ric15.Rounding) >= ric15.GYRAmberMax AND ROUND(Safety, ric15.Rounding) < ric15.GYRRedMax THEN @SilverColour
									WHEN ric15.GYRRedMax IS NOT NULL AND ROUND(Safety, ric15.Rounding) >= ric15.GYRGreenMax AND ROUND(Safety, ric15.Rounding) < ric15.GYRAmberMax THEN @BronzeColour
									WHEN ric15.GYRRedMax IS NOT NULL AND ROUND(Safety, ric15.Rounding) < ric15.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric15.GYRAmberMax = 0 AND ric15.GYRGreenMax = 0 AND ISNULL(ric15.GYRRedMax,0) = 0 THEN NULL
									WHEN ric15.GYRRedMAX IS NULL AND ROUND(Safety, ric15.Rounding) <= ric15.GYRAmberMax THEN @GreenColour
									WHEN ric15.GYRRedMax IS NULL AND ROUND(Safety, ric15.Rounding) <= ric15.GYRGreenMax AND ROUND(Safety, ric15.Rounding) > ric15.GYRAmberMax THEN @YellowColour
									WHEN ric15.GYRRedMax IS NULL AND ROUND(Safety, ric15.Rounding) > ric15.GYRGreenMax THEN @RedColour
									WHEN ric15.GYRRedMax IS NOT NULL AND ROUND(Safety, ric15.Rounding) <= ric15.GYRRedMax THEN @GoldColour
									WHEN ric15.GYRRedMax IS NOT NULL AND ROUND(Safety, ric15.Rounding) <= ric15.GYRAmberMax AND ROUND(Safety, ric15.Rounding) > ric15.GYRRedMax THEN @SilverColour
									WHEN ric15.GYRRedMAx IS NOT NULL AND ROUND(Safety, ric15.Rounding) <= ric15.GYRGreenMax AND ROUND(Safety, ric15.Rounding) > ric15.GYRAmberMax THEN @BronzeColour
									WHEN ric15.GYRRedMax IS NOT NULL AND ROUND(Safety, ric15.Rounding) > ric15.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS SafetyColour,

		CASE ric16.HighLow	WHEN 1 THEN
								CASE
									WHEN ric16.GYRAmberMax = 0 AND ric16.GYRGreenMax = 0 AND ISNULL(ric16.GYRRedMax,0) = 0 THEN NULL
									WHEN ric16.GYRRedMax IS NULL AND ROUND(FuelEcon, ric16.Rounding) >= ric16.GYRGreenMax THEN @GreenColour
									WHEN ric16.GYRRedMax IS NULL AND ROUND(FuelEcon, ric16.Rounding) >= ric16.GYRAmberMax AND ROUND(FuelEcon, ric16.Rounding) < ric16.GYRGreenMax THEN @YellowColour
									WHEN ric16.GYRRedMax IS NULL AND ROUND(FuelEcon, ric16.Rounding) < ric16.GYRAmberMax THEN @RedColour
									WHEN ric16.GYRRedMax IS NOT NULL AND ROUND(FuelEcon, ric16.Rounding) >= ric16.GYRRedMax THEN @GoldColour
									WHEN ric16.GYRRedMax IS NOT NULL AND ROUND(FuelEcon, ric16.Rounding) >= ric16.GYRAmberMax AND ROUND(FuelEcon, ric16.Rounding) < ric16.GYRRedMax THEN @SilverColour
									WHEN ric16.GYRRedMax IS NOT NULL AND ROUND(FuelEcon, ric16.Rounding) >= ric16.GYRGreenMax AND ROUND(FuelEcon, ric16.Rounding) < ric16.GYRAmberMax THEN @BronzeColour
									WHEN ric16.GYRRedMax IS NOT NULL AND ROUND(FuelEcon, ric16.Rounding) < ric16.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric16.GYRAmberMax = 0 AND ric16.GYRGreenMax = 0 AND ISNULL(ric16.GYRRedMax,0) = 0 THEN NULL
									WHEN ric16.GYRRedMAX IS NULL AND ROUND(FuelEcon, ric16.Rounding) <= ric16.GYRAmberMax THEN @GreenColour
									WHEN ric16.GYRRedMax IS NULL AND ROUND(FuelEcon, ric16.Rounding) <= ric16.GYRGreenMax AND ROUND(FuelEcon, ric16.Rounding) > ric16.GYRAmberMax THEN @YellowColour
									WHEN ric16.GYRRedMax IS NULL AND ROUND(FuelEcon, ric16.Rounding) > ric16.GYRGreenMax THEN @RedColour
									WHEN ric16.GYRRedMax IS NOT NULL AND ROUND(FuelEcon, ric16.Rounding) <= ric16.GYRRedMax THEN @GoldColour
									WHEN ric16.GYRRedMax IS NOT NULL AND ROUND(FuelEcon, ric16.Rounding) <= ric16.GYRAmberMax AND ROUND(FuelEcon, ric16.Rounding) > ric16.GYRRedMax THEN @SilverColour
									WHEN ric16.GYRRedMAx IS NOT NULL AND ROUND(FuelEcon, ric16.Rounding) <= ric16.GYRGreenMax AND ROUND(FuelEcon, ric16.Rounding) > ric16.GYRAmberMax THEN @BronzeColour
									WHEN ric16.GYRRedMax IS NOT NULL AND ROUND(FuelEcon, ric16.Rounding) > ric16.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS KPLColour,

		CASE ric20.HighLow	WHEN 1 THEN
								CASE
									WHEN ric20.GYRAmberMax = 0 AND ric20.GYRGreenMax = 0 AND ISNULL(ric20.GYRRedMax,0) = 0 THEN NULL
									WHEN ric20.GYRRedMax IS NULL AND ROUND(Co2, ric20.Rounding) >= ric20.GYRGreenMax THEN @GreenColour
									WHEN ric20.GYRRedMax IS NULL AND ROUND(Co2, ric20.Rounding) >= ric20.GYRAmberMax AND ROUND(Co2, ric20.Rounding) < ric20.GYRGreenMax THEN @YellowColour
									WHEN ric20.GYRRedMax IS NULL AND ROUND(Co2, ric20.Rounding) < ric20.GYRAmberMax THEN @RedColour
									WHEN ric20.GYRRedMax IS NOT NULL AND ROUND(Co2, ric20.Rounding) >= ric20.GYRRedMax THEN @GoldColour
									WHEN ric20.GYRRedMax IS NOT NULL AND ROUND(Co2, ric20.Rounding) >= ric20.GYRAmberMax AND ROUND(Co2, ric20.Rounding) < ric20.GYRRedMax THEN @SilverColour
									WHEN ric20.GYRRedMax IS NOT NULL AND ROUND(Co2, ric20.Rounding) >= ric20.GYRGreenMax AND ROUND(Co2, ric20.Rounding) < ric20.GYRAmberMax THEN @BronzeColour
									WHEN ric20.GYRRedMax IS NOT NULL AND ROUND(Co2, ric20.Rounding) < ric20.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric20.GYRAmberMax = 0 AND ric20.GYRGreenMax = 0 AND ISNULL(ric20.GYRRedMax,0) = 0 THEN NULL
									WHEN ric20.GYRRedMAX IS NULL AND ROUND(Co2, ric20.Rounding) <= ric20.GYRAmberMax THEN @GreenColour
									WHEN ric20.GYRRedMax IS NULL AND ROUND(Co2, ric20.Rounding) <= ric20.GYRGreenMax AND ROUND(Co2, ric20.Rounding) > ric20.GYRAmberMax THEN @YellowColour
									WHEN ric20.GYRRedMax IS NULL AND ROUND(Co2, ric20.Rounding) > ric20.GYRGreenMax THEN @RedColour
									WHEN ric20.GYRRedMax IS NOT NULL AND ROUND(Co2, ric20.Rounding) <= ric20.GYRRedMax THEN @GoldColour
									WHEN ric20.GYRRedMax IS NOT NULL AND ROUND(Co2, ric20.Rounding) <= ric20.GYRAmberMax AND ROUND(Co2, ric20.Rounding) > ric20.GYRRedMax THEN @SilverColour
									WHEN ric20.GYRRedMAx IS NOT NULL AND ROUND(Co2, ric20.Rounding) <= ric20.GYRGreenMax AND ROUND(Co2, ric20.Rounding) > ric20.GYRAmberMax THEN @BronzeColour
									WHEN ric20.GYRRedMax IS NOT NULL AND ROUND(Co2, ric20.Rounding) > ric20.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS Co2Colour,

		CASE ric21.HighLow	WHEN 1 THEN
								CASE
									WHEN ric21.GYRAmberMax = 0 AND ric21.GYRGreenMax = 0 AND ISNULL(ric21.GYRRedMax,0) = 0 THEN NULL
									WHEN ric21.GYRRedMax IS NULL AND ROUND(OverSpeedDistance*100, ric21.Rounding) >= ric21.GYRGreenMax THEN @GreenColour
									WHEN ric21.GYRRedMax IS NULL AND ROUND(OverSpeedDistance*100, ric21.Rounding) >= ric21.GYRAmberMax AND ROUND(OverSpeedDistance*100, ric21.Rounding) < ric21.GYRGreenMax THEN @YellowColour
									WHEN ric21.GYRRedMax IS NULL AND ROUND(OverSpeedDistance*100, ric21.Rounding) < ric21.GYRAmberMax THEN @RedColour
									WHEN ric21.GYRRedMax IS NOT NULL AND ROUND(OverSpeedDistance*100, ric21.Rounding) >= ric21.GYRRedMax THEN @GoldColour
									WHEN ric21.GYRRedMax IS NOT NULL AND ROUND(OverSpeedDistance*100, ric21.Rounding) >= ric21.GYRAmberMax AND ROUND(OverSpeedDistance*100, ric21.Rounding) < ric21.GYRRedMax THEN @SilverColour
									WHEN ric21.GYRRedMax IS NOT NULL AND ROUND(OverSpeedDistance*100, ric21.Rounding) >= ric21.GYRGreenMax AND ROUND(OverSpeedDistance*100, ric21.Rounding) < ric21.GYRAmberMax THEN @BronzeColour
									WHEN ric21.GYRRedMax IS NOT NULL AND ROUND(OverSpeedDistance*100, ric21.Rounding) < ric21.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric21.GYRAmberMax = 0 AND ric21.GYRGreenMax = 0 AND ISNULL(ric21.GYRRedMax,0) = 0 THEN NULL
									WHEN ric21.GYRRedMAX IS NULL AND ROUND(OverSpeedDistance*100, ric21.Rounding) <= ric21.GYRAmberMax THEN @GreenColour
									WHEN ric21.GYRRedMax IS NULL AND ROUND(OverSpeedDistance*100, ric21.Rounding) <= ric21.GYRGreenMax AND ROUND(OverSpeedDistance*100, ric21.Rounding) > ric21.GYRAmberMax THEN @YellowColour
									WHEN ric21.GYRRedMax IS NULL AND ROUND(OverSpeedDistance*100, ric21.Rounding) > ric21.GYRGreenMax THEN @RedColour
									WHEN ric21.GYRRedMax IS NOT NULL AND ROUND(OverSpeedDistance*100, ric21.Rounding) <= ric21.GYRRedMax THEN @GoldColour
									WHEN ric21.GYRRedMax IS NOT NULL AND ROUND(OverSpeedDistance*100, ric21.Rounding) <= ric21.GYRAmberMax AND ROUND(OverSpeedDistance*100, ric21.Rounding) > ric21.GYRRedMax THEN @SilverColour
									WHEN ric21.GYRRedMAx IS NOT NULL AND ROUND(OverSpeedDistance*100, ric21.Rounding) <= ric21.GYRGreenMax AND ROUND(OverSpeedDistance*100, ric21.Rounding) > ric21.GYRAmberMax THEN @BronzeColour
									WHEN ric21.GYRRedMax IS NOT NULL AND ROUND(OverSpeedDistance*100, ric21.Rounding) > ric21.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS OverSpeedDistanceColour,

		CASE ric22.HighLow	WHEN 1 THEN
								CASE
									WHEN ric22.GYRAmberMax = 0 AND ric22.GYRGreenMax = 0 AND ISNULL(ric22.GYRRedMax,0) = 0 THEN NULL
									WHEN ric22.GYRRedMax IS NULL AND ROUND(Acceleration, ric22.Rounding) >= ric22.GYRGreenMax THEN @GreenColour
									WHEN ric22.GYRRedMax IS NULL AND ROUND(Acceleration, ric22.Rounding) >= ric22.GYRAmberMax AND ROUND(Acceleration, ric22.Rounding) < ric22.GYRGreenMax THEN @YellowColour
									WHEN ric22.GYRRedMax IS NULL AND ROUND(Acceleration, ric22.Rounding) < ric22.GYRAmberMax THEN @RedColour
									WHEN ric22.GYRRedMax IS NOT NULL AND ROUND(Acceleration, ric22.Rounding) >= ric22.GYRRedMax THEN @GoldColour
									WHEN ric22.GYRRedMax IS NOT NULL AND ROUND(Acceleration, ric22.Rounding) >= ric22.GYRAmberMax AND ROUND(Acceleration, ric22.Rounding) < ric22.GYRRedMax THEN @SilverColour
									WHEN ric22.GYRRedMax IS NOT NULL AND ROUND(Acceleration, ric22.Rounding) >= ric22.GYRGreenMax AND ROUND(Acceleration, ric22.Rounding) < ric22.GYRAmberMax THEN @BronzeColour
									WHEN ric22.GYRRedMax IS NOT NULL AND ROUND(Acceleration, ric22.Rounding) < ric22.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric22.GYRAmberMax = 0 AND ric22.GYRGreenMax = 0 AND ISNULL(ric22.GYRRedMax,0) = 0 THEN NULL
									WHEN ric22.GYRRedMAX IS NULL AND ROUND(Acceleration, ric22.Rounding) <= ric22.GYRAmberMax THEN @GreenColour
									WHEN ric22.GYRRedMax IS NULL AND ROUND(Acceleration, ric22.Rounding) <= ric22.GYRGreenMax AND ROUND(Acceleration, ric22.Rounding) > ric22.GYRAmberMax THEN @YellowColour
									WHEN ric22.GYRRedMax IS NULL AND ROUND(Acceleration, ric22.Rounding) > ric22.GYRGreenMax THEN @RedColour
									WHEN ric22.GYRRedMax IS NOT NULL AND ROUND(Acceleration, ric22.Rounding) <= ric22.GYRRedMax THEN @GoldColour
									WHEN ric22.GYRRedMax IS NOT NULL AND ROUND(Acceleration, ric22.Rounding) <= ric22.GYRAmberMax AND ROUND(Acceleration, ric22.Rounding) > ric22.GYRRedMax THEN @SilverColour
									WHEN ric22.GYRRedMAx IS NOT NULL AND ROUND(Acceleration, ric22.Rounding) <= ric22.GYRGreenMax AND ROUND(Acceleration, ric22.Rounding) > ric22.GYRAmberMax THEN @BronzeColour
									WHEN ric22.GYRRedMax IS NOT NULL AND ROUND(Acceleration, ric22.Rounding) > ric22.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS AccelerationColour,

		CASE ric23.HighLow	WHEN 1 THEN
								CASE
									WHEN ric23.GYRAmberMax = 0 AND ric23.GYRGreenMax = 0 AND ISNULL(ric23.GYRRedMax,0) = 0 THEN NULL
									WHEN ric23.GYRRedMax IS NULL AND ROUND(Braking, ric23.Rounding) >= ric23.GYRGreenMax THEN @GreenColour
									WHEN ric23.GYRRedMax IS NULL AND ROUND(Braking, ric23.Rounding) >= ric23.GYRAmberMax AND ROUND(Braking, ric23.Rounding) < ric23.GYRGreenMax THEN @YellowColour
									WHEN ric23.GYRRedMax IS NULL AND ROUND(Braking, ric23.Rounding) < ric23.GYRAmberMax THEN @RedColour
									WHEN ric23.GYRRedMax IS NOT NULL AND ROUND(Braking, ric23.Rounding) >= ric23.GYRRedMax THEN @GoldColour
									WHEN ric23.GYRRedMax IS NOT NULL AND ROUND(Braking, ric23.Rounding) >= ric23.GYRAmberMax AND ROUND(Braking, ric23.Rounding) < ric23.GYRRedMax THEN @SilverColour
									WHEN ric23.GYRRedMax IS NOT NULL AND ROUND(Braking, ric23.Rounding) >= ric23.GYRGreenMax AND ROUND(Braking, ric23.Rounding) < ric23.GYRAmberMax THEN @BronzeColour
									WHEN ric23.GYRRedMax IS NOT NULL AND ROUND(Braking, ric23.Rounding) < ric23.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric23.GYRAmberMax = 0 AND ric23.GYRGreenMax = 0 AND ISNULL(ric23.GYRRedMax,0) = 0 THEN NULL
									WHEN ric23.GYRRedMAX IS NULL AND ROUND(Braking, ric23.Rounding) <= ric23.GYRAmberMax THEN @GreenColour
									WHEN ric23.GYRRedMax IS NULL AND ROUND(Braking, ric23.Rounding) <= ric23.GYRGreenMax AND ROUND(Braking, ric23.Rounding) > ric23.GYRAmberMax THEN @YellowColour
									WHEN ric23.GYRRedMax IS NULL AND ROUND(Braking, ric23.Rounding) > ric23.GYRGreenMax THEN @RedColour
									WHEN ric23.GYRRedMax IS NOT NULL AND ROUND(Braking, ric23.Rounding) <= ric23.GYRRedMax THEN @GoldColour
									WHEN ric23.GYRRedMax IS NOT NULL AND ROUND(Braking, ric23.Rounding) <= ric23.GYRAmberMax AND ROUND(Braking, ric23.Rounding) > ric23.GYRRedMax THEN @SilverColour
									WHEN ric23.GYRRedMAx IS NOT NULL AND ROUND(Braking, ric23.Rounding) <= ric23.GYRGreenMax AND ROUND(Braking, ric23.Rounding) > ric23.GYRAmberMax THEN @BronzeColour
									WHEN ric23.GYRRedMax IS NOT NULL AND ROUND(Braking, ric23.Rounding) > ric23.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS BrakingColour,

		CASE ric24.HighLow	WHEN 1 THEN
								CASE
									WHEN ric24.GYRAmberMax = 0 AND ric24.GYRGreenMax = 0 AND ISNULL(ric24.GYRRedMax,0) = 0 THEN NULL
									WHEN ric24.GYRRedMax IS NULL AND ROUND(Cornering, ric24.Rounding) >= ric24.GYRGreenMax THEN @GreenColour
									WHEN ric24.GYRRedMax IS NULL AND ROUND(Cornering, ric24.Rounding) >= ric24.GYRAmberMax AND ROUND(Cornering, ric24.Rounding) < ric24.GYRGreenMax THEN @YellowColour
									WHEN ric24.GYRRedMax IS NULL AND ROUND(Cornering, ric24.Rounding) < ric24.GYRAmberMax THEN @RedColour
									WHEN ric24.GYRRedMax IS NOT NULL AND ROUND(Cornering, ric24.Rounding) >= ric24.GYRRedMax THEN @GoldColour
									WHEN ric24.GYRRedMax IS NOT NULL AND ROUND(Cornering, ric24.Rounding) >= ric24.GYRAmberMax AND ROUND(Cornering, ric24.Rounding) < ric24.GYRRedMax THEN @SilverColour
									WHEN ric24.GYRRedMax IS NOT NULL AND ROUND(Cornering, ric24.Rounding) >= ric24.GYRGreenMax AND ROUND(Cornering, ric24.Rounding) < ric24.GYRAmberMax THEN @BronzeColour
									WHEN ric24.GYRRedMax IS NOT NULL AND ROUND(Cornering, ric24.Rounding) < ric24.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric24.GYRAmberMax = 0 AND ric24.GYRGreenMax = 0 AND ISNULL(ric24.GYRRedMax,0) = 0 THEN NULL
									WHEN ric24.GYRRedMAX IS NULL AND ROUND(Cornering, ric24.Rounding) <= ric24.GYRAmberMax THEN @GreenColour
									WHEN ric24.GYRRedMax IS NULL AND ROUND(Cornering, ric24.Rounding) <= ric24.GYRGreenMax AND ROUND(Cornering, ric24.Rounding) > ric24.GYRAmberMax THEN @YellowColour
									WHEN ric24.GYRRedMax IS NULL AND ROUND(Cornering, ric24.Rounding) > ric24.GYRGreenMax THEN @RedColour
									WHEN ric24.GYRRedMax IS NOT NULL AND ROUND(Cornering, ric24.Rounding) <= ric24.GYRRedMax THEN @GoldColour
									WHEN ric24.GYRRedMax IS NOT NULL AND ROUND(Cornering, ric24.Rounding) <= ric24.GYRAmberMax AND ROUND(Cornering, ric24.Rounding) > ric24.GYRRedMax THEN @SilverColour
									WHEN ric24.GYRRedMAx IS NOT NULL AND ROUND(Cornering, ric24.Rounding) <= ric24.GYRGreenMax AND ROUND(Cornering, ric24.Rounding) > ric24.GYRAmberMax THEN @BronzeColour
									WHEN ric24.GYRRedMax IS NOT NULL AND ROUND(Cornering, ric24.Rounding) > ric24.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS CorneringColour,

		CASE ric33.HighLow	WHEN 1 THEN
								CASE
									WHEN ric33.GYRAmberMax = 0 AND ric33.GYRGreenMax = 0 AND ISNULL(ric33.GYRRedMax,0) = 0 THEN NULL
									WHEN ric33.GYRRedMax IS NULL AND ROUND(AccelerationLow, ric33.Rounding) >= ric33.GYRGreenMax THEN @GreenColour
									WHEN ric33.GYRRedMax IS NULL AND ROUND(AccelerationLow, ric33.Rounding) >= ric33.GYRAmberMax AND ROUND(AccelerationLow, ric33.Rounding) < ric33.GYRGreenMax THEN @YellowColour
									WHEN ric33.GYRRedMax IS NULL AND ROUND(AccelerationLow, ric33.Rounding) < ric33.GYRAmberMax THEN @RedColour
									WHEN ric33.GYRRedMax IS NOT NULL AND ROUND(AccelerationLow, ric33.Rounding) >= ric33.GYRRedMax THEN @GoldColour
									WHEN ric33.GYRRedMax IS NOT NULL AND ROUND(AccelerationLow, ric33.Rounding) >= ric33.GYRAmberMax AND ROUND(AccelerationLow, ric33.Rounding) < ric33.GYRRedMax THEN @SilverColour
									WHEN ric33.GYRRedMax IS NOT NULL AND ROUND(AccelerationLow, ric33.Rounding) >= ric33.GYRGreenMax AND ROUND(AccelerationLow, ric33.Rounding) < ric33.GYRAmberMax THEN @BronzeColour
									WHEN ric33.GYRRedMax IS NOT NULL AND ROUND(AccelerationLow, ric33.Rounding) < ric33.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric33.GYRAmberMax = 0 AND ric33.GYRGreenMax = 0 AND ISNULL(ric33.GYRRedMax,0) = 0 THEN NULL
									WHEN ric33.GYRRedMAX IS NULL AND ROUND(AccelerationLow, ric33.Rounding) <= ric33.GYRAmberMax THEN @GreenColour
									WHEN ric33.GYRRedMax IS NULL AND ROUND(AccelerationLow, ric33.Rounding) <= ric33.GYRGreenMax AND ROUND(AccelerationLow, ric33.Rounding) > ric33.GYRAmberMax THEN @YellowColour
									WHEN ric33.GYRRedMax IS NULL AND ROUND(AccelerationLow, ric33.Rounding) > ric33.GYRGreenMax THEN @RedColour
									WHEN ric33.GYRRedMax IS NOT NULL AND ROUND(AccelerationLow, ric33.Rounding) <= ric33.GYRRedMax THEN @GoldColour
									WHEN ric33.GYRRedMax IS NOT NULL AND ROUND(AccelerationLow, ric33.Rounding) <= ric33.GYRAmberMax AND ROUND(AccelerationLow, ric33.Rounding) > ric33.GYRRedMax THEN @SilverColour
									WHEN ric33.GYRRedMAx IS NOT NULL AND ROUND(AccelerationLow, ric33.Rounding) <= ric33.GYRGreenMax AND ROUND(AccelerationLow, ric33.Rounding) > ric33.GYRAmberMax THEN @BronzeColour
									WHEN ric33.GYRRedMax IS NOT NULL AND ROUND(AccelerationLow, ric33.Rounding) > ric33.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS AccelerationLowColour,

		CASE ric34.HighLow	WHEN 1 THEN
								CASE
									WHEN ric34.GYRAmberMax = 0 AND ric34.GYRGreenMax = 0 AND ISNULL(ric34.GYRRedMax,0) = 0 THEN NULL
									WHEN ric34.GYRRedMax IS NULL AND ROUND(BrakingLow, ric34.Rounding) >= ric34.GYRGreenMax THEN @GreenColour
									WHEN ric34.GYRRedMax IS NULL AND ROUND(BrakingLow, ric34.Rounding) >= ric34.GYRAmberMax AND ROUND(BrakingLow, ric34.Rounding) < ric34.GYRGreenMax THEN @YellowColour
									WHEN ric34.GYRRedMax IS NULL AND ROUND(BrakingLow, ric34.Rounding) < ric34.GYRAmberMax THEN @RedColour
									WHEN ric34.GYRRedMax IS NOT NULL AND ROUND(BrakingLow, ric34.Rounding) >= ric34.GYRRedMax THEN @GoldColour
									WHEN ric34.GYRRedMax IS NOT NULL AND ROUND(BrakingLow, ric34.Rounding) >= ric34.GYRAmberMax AND ROUND(BrakingLow, ric34.Rounding) < ric34.GYRRedMax THEN @SilverColour
									WHEN ric34.GYRRedMax IS NOT NULL AND ROUND(BrakingLow, ric34.Rounding) >= ric34.GYRGreenMax AND ROUND(BrakingLow, ric34.Rounding) < ric34.GYRAmberMax THEN @BronzeColour
									WHEN ric34.GYRRedMax IS NOT NULL AND ROUND(BrakingLow, ric34.Rounding) < ric34.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric34.GYRAmberMax = 0 AND ric34.GYRGreenMax = 0 AND ISNULL(ric34.GYRRedMax,0) = 0 THEN NULL
									WHEN ric34.GYRRedMAX IS NULL AND ROUND(BrakingLow, ric34.Rounding) <= ric34.GYRAmberMax THEN @GreenColour
									WHEN ric34.GYRRedMax IS NULL AND ROUND(BrakingLow, ric34.Rounding) <= ric34.GYRGreenMax AND ROUND(BrakingLow, ric34.Rounding) > ric34.GYRAmberMax THEN @YellowColour
									WHEN ric34.GYRRedMax IS NULL AND ROUND(BrakingLow, ric34.Rounding) > ric34.GYRGreenMax THEN @RedColour
									WHEN ric34.GYRRedMax IS NOT NULL AND ROUND(BrakingLow, ric34.Rounding) <= ric34.GYRRedMax THEN @GoldColour
									WHEN ric34.GYRRedMax IS NOT NULL AND ROUND(BrakingLow, ric34.Rounding) <= ric34.GYRAmberMax AND ROUND(BrakingLow, ric34.Rounding) > ric34.GYRRedMax THEN @SilverColour
									WHEN ric34.GYRRedMAx IS NOT NULL AND ROUND(BrakingLow, ric34.Rounding) <= ric34.GYRGreenMax AND ROUND(BrakingLow, ric34.Rounding) > ric34.GYRAmberMax THEN @BronzeColour
									WHEN ric34.GYRRedMax IS NOT NULL AND ROUND(BrakingLow, ric34.Rounding) > ric34.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS BrakingLowColour,

		CASE ric35.HighLow	WHEN 1 THEN
								CASE
									WHEN ric35.GYRAmberMax = 0 AND ric35.GYRGreenMax = 0 AND ISNULL(ric35.GYRRedMax,0) = 0 THEN NULL
									WHEN ric35.GYRRedMax IS NULL AND ROUND(CorneringLow, ric35.Rounding) >= ric35.GYRGreenMax THEN @GreenColour
									WHEN ric35.GYRRedMax IS NULL AND ROUND(CorneringLow, ric35.Rounding) >= ric35.GYRAmberMax AND ROUND(CorneringLow, ric35.Rounding) < ric35.GYRGreenMax THEN @YellowColour
									WHEN ric35.GYRRedMax IS NULL AND ROUND(CorneringLow, ric35.Rounding) < ric35.GYRAmberMax THEN @RedColour
									WHEN ric35.GYRRedMax IS NOT NULL AND ROUND(CorneringLow, ric35.Rounding) >= ric35.GYRRedMax THEN @GoldColour
									WHEN ric35.GYRRedMax IS NOT NULL AND ROUND(CorneringLow, ric35.Rounding) >= ric35.GYRAmberMax AND ROUND(CorneringLow, ric35.Rounding) < ric35.GYRRedMax THEN @SilverColour
									WHEN ric35.GYRRedMax IS NOT NULL AND ROUND(CorneringLow, ric35.Rounding) >= ric35.GYRGreenMax AND ROUND(CorneringLow, ric35.Rounding) < ric35.GYRAmberMax THEN @BronzeColour
									WHEN ric35.GYRRedMax IS NOT NULL AND ROUND(CorneringLow, ric35.Rounding) < ric35.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric35.GYRAmberMax = 0 AND ric35.GYRGreenMax = 0 AND ISNULL(ric35.GYRRedMax,0) = 0 THEN NULL
									WHEN ric35.GYRRedMAX IS NULL AND ROUND(CorneringLow, ric35.Rounding) <= ric35.GYRAmberMax THEN @GreenColour
									WHEN ric35.GYRRedMax IS NULL AND ROUND(CorneringLow, ric35.Rounding) <= ric35.GYRGreenMax AND ROUND(CorneringLow, ric35.Rounding) > ric35.GYRAmberMax THEN @YellowColour
									WHEN ric35.GYRRedMax IS NULL AND ROUND(CorneringLow, ric35.Rounding) > ric35.GYRGreenMax THEN @RedColour
									WHEN ric35.GYRRedMax IS NOT NULL AND ROUND(CorneringLow, ric35.Rounding) <= ric35.GYRRedMax THEN @GoldColour
									WHEN ric35.GYRRedMax IS NOT NULL AND ROUND(CorneringLow, ric35.Rounding) <= ric35.GYRAmberMax AND ROUND(CorneringLow, ric35.Rounding) > ric35.GYRRedMax THEN @SilverColour
									WHEN ric35.GYRRedMAx IS NOT NULL AND ROUND(CorneringLow, ric35.Rounding) <= ric35.GYRGreenMax AND ROUND(CorneringLow, ric35.Rounding) > ric35.GYRAmberMax THEN @BronzeColour
									WHEN ric35.GYRRedMax IS NOT NULL AND ROUND(CorneringLow, ric35.Rounding) > ric35.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS CorneringLowColour,

		CASE ric36.HighLow	WHEN 1 THEN
								CASE
									WHEN ric36.GYRAmberMax = 0 AND ric36.GYRGreenMax = 0 AND ISNULL(ric36.GYRRedMax,0) = 0 THEN NULL
									WHEN ric36.GYRRedMax IS NULL AND ROUND(AccelerationHigh, ric36.Rounding) >= ric36.GYRGreenMax THEN @GreenColour
									WHEN ric36.GYRRedMax IS NULL AND ROUND(AccelerationHigh, ric36.Rounding) >= ric36.GYRAmberMax AND ROUND(AccelerationHigh, ric36.Rounding) < ric36.GYRGreenMax THEN @YellowColour
									WHEN ric36.GYRRedMax IS NULL AND ROUND(AccelerationHigh, ric36.Rounding) < ric36.GYRAmberMax THEN @RedColour
									WHEN ric36.GYRRedMax IS NOT NULL AND ROUND(AccelerationHigh, ric36.Rounding) >= ric36.GYRRedMax THEN @GoldColour
									WHEN ric36.GYRRedMax IS NOT NULL AND ROUND(AccelerationHigh, ric36.Rounding) >= ric36.GYRAmberMax AND ROUND(AccelerationHigh, ric36.Rounding) < ric36.GYRRedMax THEN @SilverColour
									WHEN ric36.GYRRedMax IS NOT NULL AND ROUND(AccelerationHigh, ric36.Rounding) >= ric36.GYRGreenMax AND ROUND(AccelerationHigh, ric36.Rounding) < ric36.GYRAmberMax THEN @BronzeColour
									WHEN ric36.GYRRedMax IS NOT NULL AND ROUND(AccelerationHigh, ric36.Rounding) < ric36.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric36.GYRAmberMax = 0 AND ric36.GYRGreenMax = 0 AND ISNULL(ric36.GYRRedMax,0) = 0 THEN NULL
									WHEN ric36.GYRRedMAX IS NULL AND ROUND(AccelerationHigh, ric36.Rounding) <= ric36.GYRAmberMax THEN @GreenColour
									WHEN ric36.GYRRedMax IS NULL AND ROUND(AccelerationHigh, ric36.Rounding) <= ric36.GYRGreenMax AND ROUND(AccelerationHigh, ric36.Rounding) > ric36.GYRAmberMax THEN @YellowColour
									WHEN ric36.GYRRedMax IS NULL AND ROUND(AccelerationHigh, ric36.Rounding) > ric36.GYRGreenMax THEN @RedColour
									WHEN ric36.GYRRedMax IS NOT NULL AND ROUND(AccelerationHigh, ric36.Rounding) <= ric36.GYRRedMax THEN @GoldColour
									WHEN ric36.GYRRedMax IS NOT NULL AND ROUND(AccelerationHigh, ric36.Rounding) <= ric36.GYRAmberMax AND ROUND(AccelerationHigh, ric36.Rounding) > ric36.GYRRedMax THEN @SilverColour
									WHEN ric36.GYRRedMAx IS NOT NULL AND ROUND(AccelerationHigh, ric36.Rounding) <= ric36.GYRGreenMax AND ROUND(AccelerationHigh, ric36.Rounding) > ric36.GYRAmberMax THEN @BronzeColour
									WHEN ric36.GYRRedMax IS NOT NULL AND ROUND(AccelerationHigh, ric36.Rounding) > ric36.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS AccelerationHighColour,

		CASE ric37.HighLow	WHEN 1 THEN
								CASE
									WHEN ric37.GYRAmberMax = 0 AND ric37.GYRGreenMax = 0 AND ISNULL(ric37.GYRRedMax,0) = 0 THEN NULL
									WHEN ric37.GYRRedMax IS NULL AND ROUND(BrakingHigh, ric37.Rounding) >= ric37.GYRGreenMax THEN @GreenColour
									WHEN ric37.GYRRedMax IS NULL AND ROUND(BrakingHigh, ric37.Rounding) >= ric37.GYRAmberMax AND ROUND(BrakingHigh, ric37.Rounding) < ric37.GYRGreenMax THEN @YellowColour
									WHEN ric37.GYRRedMax IS NULL AND ROUND(BrakingHigh, ric37.Rounding) < ric37.GYRAmberMax THEN @RedColour
									WHEN ric37.GYRRedMax IS NOT NULL AND ROUND(BrakingHigh, ric37.Rounding) >= ric37.GYRRedMax THEN @GoldColour
									WHEN ric37.GYRRedMax IS NOT NULL AND ROUND(BrakingHigh, ric37.Rounding) >= ric37.GYRAmberMax AND ROUND(BrakingHigh, ric37.Rounding) < ric37.GYRRedMax THEN @SilverColour
									WHEN ric37.GYRRedMax IS NOT NULL AND ROUND(BrakingHigh, ric37.Rounding) >= ric37.GYRGreenMax AND ROUND(BrakingHigh, ric37.Rounding) < ric37.GYRAmberMax THEN @BronzeColour
									WHEN ric37.GYRRedMax IS NOT NULL AND ROUND(BrakingHigh, ric37.Rounding) < ric37.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric37.GYRAmberMax = 0 AND ric37.GYRGreenMax = 0 AND ISNULL(ric37.GYRRedMax,0) = 0 THEN NULL
									WHEN ric37.GYRRedMAX IS NULL AND ROUND(BrakingHigh, ric37.Rounding) <= ric37.GYRAmberMax THEN @GreenColour
									WHEN ric37.GYRRedMax IS NULL AND ROUND(BrakingHigh, ric37.Rounding) <= ric37.GYRGreenMax AND ROUND(BrakingHigh, ric37.Rounding) > ric37.GYRAmberMax THEN @YellowColour
									WHEN ric37.GYRRedMax IS NULL AND ROUND(BrakingHigh, ric37.Rounding) > ric37.GYRGreenMax THEN @RedColour
									WHEN ric37.GYRRedMax IS NOT NULL AND ROUND(BrakingHigh, ric37.Rounding) <= ric37.GYRRedMax THEN @GoldColour
									WHEN ric37.GYRRedMax IS NOT NULL AND ROUND(BrakingHigh, ric37.Rounding) <= ric37.GYRAmberMax AND ROUND(BrakingHigh, ric37.Rounding) > ric37.GYRRedMax THEN @SilverColour
									WHEN ric37.GYRRedMAx IS NOT NULL AND ROUND(BrakingHigh, ric37.Rounding) <= ric37.GYRGreenMax AND ROUND(BrakingHigh, ric37.Rounding) > ric37.GYRAmberMax THEN @BronzeColour
									WHEN ric37.GYRRedMax IS NOT NULL AND ROUND(BrakingHigh, ric37.Rounding) > ric37.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS BrakingHighColour,

		CASE ric38.HighLow	WHEN 1 THEN
								CASE
									WHEN ric38.GYRAmberMax = 0 AND ric38.GYRGreenMax = 0 AND ISNULL(ric38.GYRRedMax,0) = 0 THEN NULL
									WHEN ric38.GYRRedMax IS NULL AND ROUND(CorneringHigh, ric38.Rounding) >= ric38.GYRGreenMax THEN @GreenColour
									WHEN ric38.GYRRedMax IS NULL AND ROUND(CorneringHigh, ric38.Rounding) >= ric38.GYRAmberMax AND ROUND(CorneringHigh, ric38.Rounding) < ric38.GYRGreenMax THEN @YellowColour
									WHEN ric38.GYRRedMax IS NULL AND ROUND(CorneringHigh, ric38.Rounding) < ric38.GYRAmberMax THEN @RedColour
									WHEN ric38.GYRRedMax IS NOT NULL AND ROUND(CorneringHigh, ric38.Rounding) >= ric38.GYRRedMax THEN @GoldColour
									WHEN ric38.GYRRedMax IS NOT NULL AND ROUND(CorneringHigh, ric38.Rounding) >= ric38.GYRAmberMax AND ROUND(CorneringHigh, ric38.Rounding) < ric38.GYRRedMax THEN @SilverColour
									WHEN ric38.GYRRedMax IS NOT NULL AND ROUND(CorneringHigh, ric38.Rounding) >= ric38.GYRGreenMax AND ROUND(CorneringHigh, ric38.Rounding) < ric38.GYRAmberMax THEN @BronzeColour
									WHEN ric38.GYRRedMax IS NOT NULL AND ROUND(CorneringHigh, ric38.Rounding) < ric38.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric38.GYRAmberMax = 0 AND ric38.GYRGreenMax = 0 AND ISNULL(ric38.GYRRedMax,0) = 0 THEN NULL
									WHEN ric38.GYRRedMAX IS NULL AND ROUND(CorneringHigh, ric38.Rounding) <= ric38.GYRAmberMax THEN @GreenColour
									WHEN ric38.GYRRedMax IS NULL AND ROUND(CorneringHigh, ric38.Rounding) <= ric38.GYRGreenMax AND ROUND(CorneringHigh, ric38.Rounding) > ric38.GYRAmberMax THEN @YellowColour
									WHEN ric38.GYRRedMax IS NULL AND ROUND(CorneringHigh, ric38.Rounding) > ric38.GYRGreenMax THEN @RedColour
									WHEN ric38.GYRRedMax IS NOT NULL AND ROUND(CorneringHigh, ric38.Rounding) <= ric38.GYRRedMax THEN @GoldColour
									WHEN ric38.GYRRedMax IS NOT NULL AND ROUND(CorneringHigh, ric38.Rounding) <= ric38.GYRAmberMax AND ROUND(CorneringHigh, ric38.Rounding) > ric38.GYRRedMax THEN @SilverColour
									WHEN ric38.GYRRedMAx IS NOT NULL AND ROUND(CorneringHigh, ric38.Rounding) <= ric38.GYRGreenMax AND ROUND(CorneringHigh, ric38.Rounding) > ric38.GYRAmberMax THEN @BronzeColour
									WHEN ric38.GYRRedMax IS NOT NULL AND ROUND(CorneringHigh, ric38.Rounding) > ric38.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS CorneringHighColour,

		CASE ric39.HighLow	WHEN 1 THEN
								CASE
									WHEN ric39.GYRAmberMax = 0 AND ric39.GYRGreenMax = 0 AND ISNULL(ric39.GYRRedMax,0) = 0 THEN NULL
									WHEN ric39.GYRRedMax IS NULL AND ROUND(AccelerationLow + BrakingLow + CorneringLow, ric39.Rounding) >= ric39.GYRGreenMax THEN @GreenColour
									WHEN ric39.GYRRedMax IS NULL AND ROUND(AccelerationLow + BrakingLow + CorneringLow, ric39.Rounding) >= ric39.GYRAmberMax AND ROUND(AccelerationLow + BrakingLow + CorneringLow, ric39.Rounding) < ric39.GYRGreenMax THEN @YellowColour
									WHEN ric39.GYRRedMax IS NULL AND ROUND(AccelerationLow + BrakingLow + CorneringLow, ric39.Rounding) < ric39.GYRAmberMax THEN @RedColour
									WHEN ric39.GYRRedMax IS NOT NULL AND ROUND(AccelerationLow + BrakingLow + CorneringLow, ric39.Rounding) >= ric39.GYRRedMax THEN @GoldColour
									WHEN ric39.GYRRedMax IS NOT NULL AND ROUND(AccelerationLow + BrakingLow + CorneringLow, ric39.Rounding) >= ric39.GYRAmberMax AND ROUND(AccelerationLow + BrakingLow + CorneringLow, ric39.Rounding) < ric39.GYRRedMax THEN @SilverColour
									WHEN ric39.GYRRedMax IS NOT NULL AND ROUND(AccelerationLow + BrakingLow + CorneringLow, ric39.Rounding) >= ric39.GYRGreenMax AND ROUND(AccelerationLow + BrakingLow + CorneringLow, ric39.Rounding) < ric39.GYRAmberMax THEN @BronzeColour
									WHEN ric39.GYRRedMax IS NOT NULL AND ROUND(AccelerationLow + BrakingLow + CorneringLow, ric39.Rounding) < ric39.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric39.GYRAmberMax = 0 AND ric39.GYRGreenMax = 0 AND ISNULL(ric39.GYRRedMax,0) = 0 THEN NULL
									WHEN ric39.GYRRedMAX IS NULL AND ROUND(AccelerationLow + BrakingLow + CorneringLow, ric39.Rounding) <= ric39.GYRAmberMax THEN @GreenColour
									WHEN ric39.GYRRedMax IS NULL AND ROUND(AccelerationLow + BrakingLow + CorneringLow, ric39.Rounding) <= ric39.GYRGreenMax AND ROUND(AccelerationLow + BrakingLow + CorneringLow, ric39.Rounding) > ric39.GYRAmberMax THEN @YellowColour
									WHEN ric39.GYRRedMax IS NULL AND ROUND(AccelerationLow + BrakingLow + CorneringLow, ric39.Rounding) > ric39.GYRGreenMax THEN @RedColour
									WHEN ric39.GYRRedMax IS NOT NULL AND ROUND(AccelerationLow + BrakingLow + CorneringLow, ric39.Rounding) <= ric39.GYRRedMax THEN @GoldColour
									WHEN ric39.GYRRedMax IS NOT NULL AND ROUND(AccelerationLow + BrakingLow + CorneringLow, ric39.Rounding) <= ric39.GYRAmberMax AND ROUND(AccelerationLow + BrakingLow + CorneringLow, ric39.Rounding) > ric39.GYRRedMax THEN @SilverColour
									WHEN ric39.GYRRedMAx IS NOT NULL AND ROUND(AccelerationLow + BrakingLow + CorneringLow, ric39.Rounding) <= ric39.GYRGreenMax AND ROUND(AccelerationLow + BrakingLow + CorneringLow, ric39.Rounding) > ric39.GYRAmberMax THEN @BronzeColour
									WHEN ric39.GYRRedMax IS NOT NULL AND ROUND(AccelerationLow + BrakingLow + CorneringLow, ric39.Rounding) > ric39.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS ManoeuvresLowColour,

		CASE ric40.HighLow	WHEN 1 THEN
								CASE
									WHEN ric40.GYRAmberMax = 0 AND ric40.GYRGreenMax = 0 AND ISNULL(ric40.GYRRedMax,0) = 0 THEN NULL
									WHEN ric40.GYRRedMax IS NULL AND ROUND(Acceleration + Braking + Cornering, ric40.Rounding) >= ric40.GYRGreenMax THEN @GreenColour
									WHEN ric40.GYRRedMax IS NULL AND ROUND(Acceleration + Braking + Cornering, ric40.Rounding) >= ric40.GYRAmberMax AND ROUND(Acceleration + Braking + Cornering, ric40.Rounding) < ric40.GYRGreenMax THEN @YellowColour
									WHEN ric40.GYRRedMax IS NULL AND ROUND(Acceleration + Braking + Cornering, ric40.Rounding) < ric40.GYRAmberMax THEN @RedColour
									WHEN ric40.GYRRedMax IS NOT NULL AND ROUND(Acceleration + Braking + Cornering, ric40.Rounding) >= ric40.GYRRedMax THEN @GoldColour
									WHEN ric40.GYRRedMax IS NOT NULL AND ROUND(Acceleration + Braking + Cornering, ric40.Rounding) >= ric40.GYRAmberMax AND ROUND(Acceleration + Braking + Cornering, ric40.Rounding) < ric40.GYRRedMax THEN @SilverColour
									WHEN ric40.GYRRedMax IS NOT NULL AND ROUND(Acceleration + Braking + Cornering, ric40.Rounding) >= ric40.GYRGreenMax AND ROUND(Acceleration + Braking + Cornering, ric40.Rounding) < ric40.GYRAmberMax THEN @BronzeColour
									WHEN ric40.GYRRedMax IS NOT NULL AND ROUND(Acceleration + Braking + Cornering, ric40.Rounding) < ric40.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric40.GYRAmberMax = 0 AND ric40.GYRGreenMax = 0 AND ISNULL(ric40.GYRRedMax,0) = 0 THEN NULL
									WHEN ric40.GYRRedMAX IS NULL AND ROUND(Acceleration + Braking + Cornering, ric40.Rounding) <= ric40.GYRAmberMax THEN @GreenColour
									WHEN ric40.GYRRedMax IS NULL AND ROUND(Acceleration + Braking + Cornering, ric40.Rounding) <= ric40.GYRGreenMax AND ROUND(Acceleration + Braking + Cornering, ric40.Rounding) > ric40.GYRAmberMax THEN @YellowColour
									WHEN ric40.GYRRedMax IS NULL AND ROUND(Acceleration + Braking + Cornering, ric40.Rounding) > ric40.GYRGreenMax THEN @RedColour
									WHEN ric40.GYRRedMax IS NOT NULL AND ROUND(Acceleration + Braking + Cornering, ric40.Rounding) <= ric40.GYRRedMax THEN @GoldColour
									WHEN ric40.GYRRedMax IS NOT NULL AND ROUND(Acceleration + Braking + Cornering, ric40.Rounding) <= ric40.GYRAmberMax AND ROUND(Acceleration + Braking + Cornering, ric40.Rounding) > ric40.GYRRedMax THEN @SilverColour
									WHEN ric40.GYRRedMAx IS NOT NULL AND ROUND(Acceleration + Braking + Cornering, ric40.Rounding) <= ric40.GYRGreenMax AND ROUND(Acceleration + Braking + Cornering, ric40.Rounding) > ric40.GYRAmberMax THEN @BronzeColour
									WHEN ric40.GYRRedMax IS NOT NULL AND ROUND(Acceleration + Braking + Cornering, ric40.Rounding) > ric40.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS ManoeuvresMedColour,


		CASE ric25.HighLow	WHEN 1 THEN
								CASE
									WHEN ric25.GYRAmberMax = 0 AND ric25.GYRGreenMax = 0 AND ISNULL(ric25.GYRRedMax,0) = 0 THEN NULL
									WHEN ric25.GYRRedMax IS NULL AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) >= ric25.GYRGreenMax THEN @GreenColour
									WHEN ric25.GYRRedMax IS NULL AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) >= ric25.GYRAmberMax AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) < ric25.GYRGreenMax THEN @YellowColour
									WHEN ric25.GYRRedMax IS NULL AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) < ric25.GYRAmberMax THEN @RedColour
									WHEN ric25.GYRRedMax IS NOT NULL AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) >= ric25.GYRRedMax THEN @GoldColour
									WHEN ric25.GYRRedMax IS NOT NULL AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) >= ric25.GYRAmberMax AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) < ric25.GYRRedMax THEN @SilverColour
									WHEN ric25.GYRRedMax IS NOT NULL AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) >= ric25.GYRGreenMax AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) < ric25.GYRAmberMax THEN @BronzeColour
									WHEN ric25.GYRRedMax IS NOT NULL AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) < ric25.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric25.GYRAmberMax = 0 AND ric25.GYRGreenMax = 0 AND ISNULL(ric25.GYRRedMax,0) = 0 THEN NULL
									WHEN ric25.GYRRedMAX IS NULL AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) <= ric25.GYRAmberMax THEN @GreenColour
									WHEN ric25.GYRRedMax IS NULL AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) <= ric25.GYRGreenMax AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) > ric25.GYRAmberMax THEN @YellowColour
									WHEN ric25.GYRRedMax IS NULL AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) > ric25.GYRGreenMax THEN @RedColour
									WHEN ric25.GYRRedMax IS NOT NULL AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) <= ric25.GYRRedMax THEN @GoldColour
									WHEN ric25.GYRRedMax IS NOT NULL AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) <= ric25.GYRAmberMax AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) > ric25.GYRRedMax THEN @SilverColour
									WHEN ric25.GYRRedMAx IS NOT NULL AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) <= ric25.GYRGreenMax AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) > ric25.GYRAmberMax THEN @BronzeColour
									WHEN ric25.GYRRedMax IS NOT NULL AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) > ric25.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS CruiseTopGearRatioColour,

		CASE ric28.HighLow	WHEN 1 THEN
								CASE
									WHEN ric28.GYRAmberMax = 0 AND ric28.GYRGreenMax = 0 AND ISNULL(ric28.GYRRedMax,0) = 0 THEN NULL
									WHEN ric28.GYRRedMax IS NULL AND ROUND(OverRevCount, ric28.Rounding) >= ric28.GYRGreenMax THEN @GreenColour
									WHEN ric28.GYRRedMax IS NULL AND ROUND(OverRevCount, ric28.Rounding) >= ric28.GYRAmberMax AND ROUND(OverRevCount, ric28.Rounding) < ric28.GYRGreenMax THEN @YellowColour
									WHEN ric28.GYRRedMax IS NULL AND ROUND(OverRevCount, ric28.Rounding) < ric28.GYRAmberMax THEN @RedColour
									WHEN ric28.GYRRedMax IS NOT NULL AND ROUND(OverRevCount, ric28.Rounding) >= ric28.GYRRedMax THEN @GoldColour
									WHEN ric28.GYRRedMax IS NOT NULL AND ROUND(OverRevCount, ric28.Rounding) >= ric28.GYRAmberMax AND ROUND(OverRevCount, ric28.Rounding) < ric28.GYRRedMax THEN @SilverColour
									WHEN ric28.GYRRedMax IS NOT NULL AND ROUND(OverRevCount, ric28.Rounding) >= ric28.GYRGreenMax AND ROUND(OverRevCount, ric28.Rounding) < ric28.GYRAmberMax THEN @BronzeColour
									WHEN ric28.GYRRedMax IS NOT NULL AND ROUND(OverRevCount, ric28.Rounding) < ric28.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric28.GYRAmberMax = 0 AND ric28.GYRGreenMax = 0 AND ISNULL(ric28.GYRRedMax,0) = 0 THEN NULL
									WHEN ric28.GYRRedMAX IS NULL AND ROUND(OverRevCount, ric28.Rounding) <= ric28.GYRAmberMax THEN @GreenColour
									WHEN ric28.GYRRedMax IS NULL AND ROUND(OverRevCount, ric28.Rounding) <= ric28.GYRGreenMax AND ROUND(OverRevCount, ric28.Rounding) > ric28.GYRAmberMax THEN @YellowColour
									WHEN ric28.GYRRedMax IS NULL AND ROUND(OverRevCount, ric28.Rounding) > ric28.GYRGreenMax THEN @RedColour
									WHEN ric28.GYRRedMax IS NOT NULL AND ROUND(OverRevCount, ric28.Rounding) <= ric28.GYRRedMax THEN @GoldColour
									WHEN ric28.GYRRedMax IS NOT NULL AND ROUND(OverRevCount, ric28.Rounding) <= ric28.GYRAmberMax AND ROUND(OverRevCount, ric28.Rounding) > ric28.GYRRedMax THEN @SilverColour
									WHEN ric28.GYRRedMAx IS NOT NULL AND ROUND(OverRevCount, ric28.Rounding) <= ric28.GYRGreenMax AND ROUND(OverRevCount, ric28.Rounding) > ric28.GYRAmberMax THEN @BronzeColour
									WHEN ric28.GYRRedMax IS NOT NULL AND ROUND(OverRevCount, ric28.Rounding) > ric28.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS OverRevCountColour,


		CASE ric29.HighLow	WHEN 1 THEN
								CASE
									WHEN ric29.GYRAmberMax = 0 AND ric29.GYRGreenMax = 0 AND ISNULL(ric29.GYRRedMax,0) = 0 THEN NULL
									WHEN ric29.GYRRedMax IS NULL AND ROUND(Pto*100, ric29.Rounding) >= ric29.GYRGreenMax THEN @GreenColour
									WHEN ric29.GYRRedMax IS NULL AND ROUND(Pto*100, ric29.Rounding) >= ric29.GYRAmberMax AND ROUND(Pto*100, ric29.Rounding) < ric29.GYRGreenMax THEN @YellowColour
									WHEN ric29.GYRRedMax IS NULL AND ROUND(Pto*100, ric29.Rounding) < ric29.GYRAmberMax THEN @RedColour
									WHEN ric29.GYRRedMax IS NOT NULL AND ROUND(Pto*100, ric29.Rounding) >= ric29.GYRRedMax THEN @GoldColour
									WHEN ric29.GYRRedMax IS NOT NULL AND ROUND(Pto*100, ric29.Rounding) >= ric29.GYRAmberMax AND ROUND(Pto*100, ric29.Rounding) < ric29.GYRRedMax THEN @SilverColour
									WHEN ric29.GYRRedMax IS NOT NULL AND ROUND(Pto*100, ric29.Rounding) >= ric29.GYRGreenMax AND ROUND(Pto*100, ric29.Rounding) < ric29.GYRAmberMax THEN @BronzeColour
									WHEN ric29.GYRRedMax IS NOT NULL AND ROUND(Pto*100, ric29.Rounding) < ric29.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric29.GYRAmberMax = 0 AND ric29.GYRGreenMax = 0 AND ISNULL(ric29.GYRRedMax,0) = 0 THEN NULL
									WHEN ric29.GYRRedMAX IS NULL AND ROUND(Pto*100, ric29.Rounding) <= ric29.GYRAmberMax THEN @GreenColour
									WHEN ric29.GYRRedMax IS NULL AND ROUND(Pto*100, ric29.Rounding) <= ric29.GYRGreenMax AND ROUND(Pto*100, ric29.Rounding) > ric29.GYRAmberMax THEN @YellowColour
									WHEN ric29.GYRRedMax IS NULL AND ROUND(Pto*100, ric29.Rounding) > ric29.GYRGreenMax THEN @RedColour
									WHEN ric29.GYRRedMax IS NOT NULL AND ROUND(Pto*100, ric29.Rounding) <= ric29.GYRRedMax THEN @GoldColour
									WHEN ric29.GYRRedMax IS NOT NULL AND ROUND(Pto*100, ric29.Rounding) <= ric29.GYRAmberMax AND ROUND(Pto*100, ric29.Rounding) > ric29.GYRRedMax THEN @SilverColour
									WHEN ric29.GYRRedMAx IS NOT NULL AND ROUND(Pto*100, ric29.Rounding) <= ric29.GYRGreenMax AND ROUND(Pto*100, ric29.Rounding) > ric29.GYRAmberMax THEN @BronzeColour
									WHEN ric29.GYRRedMax IS NOT NULL AND ROUND(Pto*100, ric29.Rounding) > ric29.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS PtoColour,

		CASE ric43.HighLow	WHEN 1 THEN
								CASE
									WHEN ric43.GYRAmberMax = 0 AND ric43.GYRGreenMax = 0 AND ISNULL(ric43.GYRRedMax,0) = 0 THEN NULL
									WHEN ric43.GYRRedMax IS NULL AND ROUND(CruiseOverspeed*100, ric43.Rounding) >= ric43.GYRGreenMax THEN @GreenColour
									WHEN ric43.GYRRedMax IS NULL AND ROUND(CruiseOverspeed*100, ric43.Rounding) >= ric43.GYRAmberMax AND ROUND(CruiseOverspeed*100, ric43.Rounding) < ric43.GYRGreenMax THEN @YellowColour
									WHEN ric43.GYRRedMax IS NULL AND ROUND(CruiseOverspeed*100, ric43.Rounding) < ric43.GYRAmberMax THEN @RedColour
									WHEN ric43.GYRRedMax IS NOT NULL AND ROUND(CruiseOverspeed*100, ric43.Rounding) >= ric43.GYRRedMax THEN @GoldColour
									WHEN ric43.GYRRedMax IS NOT NULL AND ROUND(CruiseOverspeed*100, ric43.Rounding) >= ric43.GYRAmberMax AND ROUND(CruiseOverspeed*100, ric43.Rounding) < ric43.GYRRedMax THEN @SilverColour
									WHEN ric43.GYRRedMax IS NOT NULL AND ROUND(CruiseOverspeed*100, ric43.Rounding) >= ric43.GYRGreenMax AND ROUND(CruiseOverspeed*100, ric43.Rounding) < ric43.GYRAmberMax THEN @BronzeColour
									WHEN ric43.GYRRedMax IS NOT NULL AND ROUND(CruiseOverspeed*100, ric43.Rounding) < ric43.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric43.GYRAmberMax = 0 AND ric43.GYRGreenMax = 0 AND ISNULL(ric43.GYRRedMax,0) = 0 THEN NULL
									WHEN ric43.GYRRedMAX IS NULL AND ROUND(CruiseOverspeed*100, ric43.Rounding) <= ric43.GYRAmberMax THEN @GreenColour
									WHEN ric43.GYRRedMax IS NULL AND ROUND(CruiseOverspeed*100, ric43.Rounding) <= ric43.GYRGreenMax AND ROUND(CruiseOverspeed*100, ric43.Rounding) > ric43.GYRAmberMax THEN @YellowColour
									WHEN ric43.GYRRedMax IS NULL AND ROUND(CruiseOverspeed*100, ric43.Rounding) > ric43.GYRGreenMax THEN @RedColour
									WHEN ric43.GYRRedMax IS NOT NULL AND ROUND(CruiseOverspeed*100, ric43.Rounding) <= ric43.GYRRedMax THEN @GoldColour
									WHEN ric43.GYRRedMax IS NOT NULL AND ROUND(CruiseOverspeed*100, ric43.Rounding) <= ric43.GYRAmberMax AND ROUND(CruiseOverspeed*100, ric43.Rounding) > ric43.GYRRedMax THEN @SilverColour
									WHEN ric43.GYRRedMAx IS NOT NULL AND ROUND(CruiseOverspeed*100, ric43.Rounding) <= ric43.GYRGreenMax AND ROUND(CruiseOverspeed*100, ric43.Rounding) > ric43.GYRAmberMax THEN @BronzeColour
									WHEN ric43.GYRRedMax IS NOT NULL AND ROUND(CruiseOverspeed*100, ric43.Rounding) > ric43.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS CruiseOverspeedColour,

		CASE ric42.HighLow	WHEN 1 THEN
								CASE
									WHEN ric42.GYRAmberMax = 0 AND ric42.GYRGreenMax = 0 AND ISNULL(ric42.GYRRedMax,0) = 0 THEN NULL
									WHEN ric42.GYRRedMax IS NULL AND ROUND(TopGearOverspeed*100, ric42.Rounding) >= ric42.GYRGreenMax THEN @GreenColour
									WHEN ric42.GYRRedMax IS NULL AND ROUND(TopGearOverspeed*100, ric42.Rounding) >= ric42.GYRAmberMax AND ROUND(TopGearOverspeed*100, ric42.Rounding) < ric42.GYRGreenMax THEN @YellowColour
									WHEN ric42.GYRRedMax IS NULL AND ROUND(TopGearOverspeed*100, ric42.Rounding) < ric42.GYRAmberMax THEN @RedColour
									WHEN ric42.GYRRedMax IS NOT NULL AND ROUND(TopGearOverspeed*100, ric42.Rounding) >= ric42.GYRRedMax THEN @GoldColour
									WHEN ric42.GYRRedMax IS NOT NULL AND ROUND(TopGearOverspeed*100, ric42.Rounding) >= ric42.GYRAmberMax AND ROUND(TopGearOverspeed*100, ric42.Rounding) < ric42.GYRRedMax THEN @SilverColour
									WHEN ric42.GYRRedMax IS NOT NULL AND ROUND(TopGearOverspeed*100, ric42.Rounding) >= ric42.GYRGreenMax AND ROUND(TopGearOverspeed*100, ric42.Rounding) < ric42.GYRAmberMax THEN @BronzeColour
									WHEN ric42.GYRRedMax IS NOT NULL AND ROUND(TopGearOverspeed*100, ric42.Rounding) < ric42.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric42.GYRAmberMax = 0 AND ric42.GYRGreenMax = 0 AND ISNULL(ric42.GYRRedMax,0) = 0 THEN NULL
									WHEN ric42.GYRRedMAX IS NULL AND ROUND(TopGearOverspeed*100, ric42.Rounding) <= ric42.GYRAmberMax THEN @GreenColour
									WHEN ric42.GYRRedMax IS NULL AND ROUND(TopGearOverspeed*100, ric42.Rounding) <= ric42.GYRGreenMax AND ROUND(TopGearOverspeed*100, ric42.Rounding) > ric42.GYRAmberMax THEN @YellowColour
									WHEN ric42.GYRRedMax IS NULL AND ROUND(TopGearOverspeed*100, ric42.Rounding) > ric42.GYRGreenMax THEN @RedColour
									WHEN ric42.GYRRedMax IS NOT NULL AND ROUND(TopGearOverspeed*100, ric42.Rounding) <= ric42.GYRRedMax THEN @GoldColour
									WHEN ric42.GYRRedMax IS NOT NULL AND ROUND(TopGearOverspeed*100, ric42.Rounding) <= ric42.GYRAmberMax AND ROUND(TopGearOverspeed*100, ric42.Rounding) > ric42.GYRRedMax THEN @SilverColour
									WHEN ric42.GYRRedMAx IS NOT NULL AND ROUND(TopGearOverspeed*100, ric42.Rounding) <= ric42.GYRGreenMax AND ROUND(TopGearOverspeed*100, ric42.Rounding) > ric42.GYRAmberMax THEN @BronzeColour
									WHEN ric42.GYRRedMax IS NOT NULL AND ROUND(TopGearOverspeed*100, ric42.Rounding) > ric42.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS TopGearOverspeedColour,

		NULL AS FuelWastageCostColour,

		CASE ric46.HighLow	WHEN 1 THEN
								CASE
									WHEN ric46.GYRAmberMax = 0 AND ric46.GYRGreenMax = 0 AND ISNULL(ric46.GYRRedMax,0) = 0 THEN NULL
									WHEN ric46.GYRRedMax IS NULL AND ROUND(OverspeedCount, ric46.Rounding) >= ric46.GYRGreenMax THEN @GreenColour
									WHEN ric46.GYRRedMax IS NULL AND ROUND(OverspeedCount, ric46.Rounding) >= ric46.GYRAmberMax AND ROUND(OverspeedCount, ric46.Rounding) < ric46.GYRGreenMax THEN @YellowColour
									WHEN ric46.GYRRedMax IS NULL AND ROUND(OverspeedCount, ric46.Rounding) < ric46.GYRAmberMax THEN @RedColour
									WHEN ric46.GYRRedMax IS NOT NULL AND ROUND(OverspeedCount, ric46.Rounding) >= ric46.GYRRedMax THEN @GoldColour
									WHEN ric46.GYRRedMax IS NOT NULL AND ROUND(OverspeedCount, ric46.Rounding) >= ric46.GYRAmberMax AND ROUND(OverspeedCount, ric46.Rounding) < ric46.GYRRedMax THEN @SilverColour
									WHEN ric46.GYRRedMax IS NOT NULL AND ROUND(OverspeedCount, ric46.Rounding) >= ric46.GYRGreenMax AND ROUND(OverspeedCount, ric46.Rounding) < ric46.GYRAmberMax THEN @BronzeColour
									WHEN ric46.GYRRedMax IS NOT NULL AND ROUND(OverspeedCount, ric46.Rounding) < ric46.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric46.GYRAmberMax = 0 AND ric46.GYRGreenMax = 0 AND ISNULL(ric46.GYRRedMax,0) = 0 THEN NULL
									WHEN ric46.GYRRedMAX IS NULL AND ROUND(OverspeedCount, ric46.Rounding) <= ric46.GYRAmberMax THEN @GreenColour
									WHEN ric46.GYRRedMax IS NULL AND ROUND(OverspeedCount, ric46.Rounding) <= ric46.GYRGreenMax AND ROUND(OverspeedCount, ric46.Rounding) > ric46.GYRAmberMax THEN @YellowColour
									WHEN ric46.GYRRedMax IS NULL AND ROUND(OverspeedCount, ric46.Rounding) > ric46.GYRGreenMax THEN @RedColour
									WHEN ric46.GYRRedMax IS NOT NULL AND ROUND(OverspeedCount, ric46.Rounding) <= ric46.GYRRedMax THEN @GoldColour
									WHEN ric46.GYRRedMax IS NOT NULL AND ROUND(OverspeedCount, ric46.Rounding) <= ric46.GYRAmberMax AND ROUND(OverspeedCount, ric46.Rounding) > ric46.GYRRedMax THEN @SilverColour
									WHEN ric46.GYRRedMAx IS NOT NULL AND ROUND(OverspeedCount, ric46.Rounding) <= ric46.GYRGreenMax AND ROUND(OverspeedCount, ric46.Rounding) > ric46.GYRAmberMax THEN @BronzeColour
									WHEN ric46.GYRRedMax IS NOT NULL AND ROUND(OverspeedCount, ric46.Rounding) > ric46.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS OverspeedCountColour,

		CASE ric47.HighLow	WHEN 1 THEN
								CASE
									WHEN ric47.GYRAmberMax = 0 AND ric47.GYRGreenMax = 0 AND ISNULL(ric47.GYRRedMax,0) = 0 THEN NULL
									WHEN ric47.GYRRedMax IS NULL AND ROUND(OverspeedHighCount, ric47.Rounding) >= ric47.GYRGreenMax THEN @GreenColour
									WHEN ric47.GYRRedMax IS NULL AND ROUND(OverspeedHighCount, ric47.Rounding) >= ric47.GYRAmberMax AND ROUND(OverspeedHighCount, ric47.Rounding) < ric47.GYRGreenMax THEN @YellowColour
									WHEN ric47.GYRRedMax IS NULL AND ROUND(OverspeedHighCount, ric47.Rounding) < ric47.GYRAmberMax THEN @RedColour
									WHEN ric47.GYRRedMax IS NOT NULL AND ROUND(OverspeedHighCount, ric47.Rounding) >= ric47.GYRRedMax THEN @GoldColour
									WHEN ric47.GYRRedMax IS NOT NULL AND ROUND(OverspeedHighCount, ric47.Rounding) >= ric47.GYRAmberMax AND ROUND(OverspeedHighCount, ric47.Rounding) < ric47.GYRRedMax THEN @SilverColour
									WHEN ric47.GYRRedMax IS NOT NULL AND ROUND(OverspeedHighCount, ric47.Rounding) >= ric47.GYRGreenMax AND ROUND(OverspeedHighCount, ric47.Rounding) < ric47.GYRAmberMax THEN @BronzeColour
									WHEN ric47.GYRRedMax IS NOT NULL AND ROUND(OverspeedHighCount, ric47.Rounding) < ric47.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric47.GYRAmberMax = 0 AND ric47.GYRGreenMax = 0 AND ISNULL(ric47.GYRRedMax,0) = 0 THEN NULL
									WHEN ric47.GYRRedMAX IS NULL AND ROUND(OverspeedHighCount, ric47.Rounding) <= ric47.GYRAmberMax THEN @GreenColour
									WHEN ric47.GYRRedMax IS NULL AND ROUND(OverspeedHighCount, ric47.Rounding) <= ric47.GYRGreenMax AND ROUND(OverspeedHighCount, ric47.Rounding) > ric47.GYRAmberMax THEN @YellowColour
									WHEN ric47.GYRRedMax IS NULL AND ROUND(OverspeedHighCount, ric47.Rounding) > ric47.GYRGreenMax THEN @RedColour
									WHEN ric47.GYRRedMax IS NOT NULL AND ROUND(OverspeedHighCount, ric47.Rounding) <= ric47.GYRRedMax THEN @GoldColour
									WHEN ric47.GYRRedMax IS NOT NULL AND ROUND(OverspeedHighCount, ric47.Rounding) <= ric47.GYRAmberMax AND ROUND(OverspeedHighCount, ric47.Rounding) > ric47.GYRRedMax THEN @SilverColour
									WHEN ric47.GYRRedMAx IS NOT NULL AND ROUND(OverspeedHighCount, ric47.Rounding) <= ric47.GYRGreenMax AND ROUND(OverspeedHighCount, ric47.Rounding) > ric47.GYRAmberMax THEN @BronzeColour
									WHEN ric47.GYRRedMax IS NOT NULL AND ROUND(OverspeedHighCount, ric47.Rounding) > ric47.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS OverspeedHighCountColour,

		CASE ric48.HighLow	WHEN 1 THEN
								CASE
									WHEN ric48.GYRAmberMax = 0 AND ric48.GYRGreenMax = 0 AND ISNULL(ric48.GYRRedMax,0) = 0 THEN NULL
									WHEN ric48.GYRRedMax IS NULL AND ROUND(StabilityControl, ric48.Rounding) >= ric48.GYRGreenMax THEN @GreenColour
									WHEN ric48.GYRRedMax IS NULL AND ROUND(StabilityControl, ric48.Rounding) >= ric48.GYRAmberMax AND ROUND(StabilityControl, ric48.Rounding) < ric48.GYRGreenMax THEN @YellowColour
									WHEN ric48.GYRRedMax IS NULL AND ROUND(StabilityControl, ric48.Rounding) < ric48.GYRAmberMax THEN @RedColour
									WHEN ric48.GYRRedMax IS NOT NULL AND ROUND(StabilityControl, ric48.Rounding) >= ric48.GYRRedMax THEN @GoldColour
									WHEN ric48.GYRRedMax IS NOT NULL AND ROUND(StabilityControl, ric48.Rounding) >= ric48.GYRAmberMax AND ROUND(StabilityControl, ric48.Rounding) < ric48.GYRRedMax THEN @SilverColour
									WHEN ric48.GYRRedMax IS NOT NULL AND ROUND(StabilityControl, ric48.Rounding) >= ric48.GYRGreenMax AND ROUND(StabilityControl, ric48.Rounding) < ric48.GYRAmberMax THEN @BronzeColour
									WHEN ric48.GYRRedMax IS NOT NULL AND ROUND(StabilityControl, ric48.Rounding) < ric48.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric48.GYRAmberMax = 0 AND ric48.GYRGreenMax = 0 AND ISNULL(ric48.GYRRedMax,0) = 0 THEN NULL
									WHEN ric48.GYRRedMAX IS NULL AND ROUND(StabilityControl, ric48.Rounding) <= ric48.GYRAmberMax THEN @GreenColour
									WHEN ric48.GYRRedMax IS NULL AND ROUND(StabilityControl, ric48.Rounding) <= ric48.GYRGreenMax AND ROUND(StabilityControl, ric48.Rounding) > ric48.GYRAmberMax THEN @YellowColour
									WHEN ric48.GYRRedMax IS NULL AND ROUND(StabilityControl, ric48.Rounding) > ric48.GYRGreenMax THEN @RedColour
									WHEN ric48.GYRRedMax IS NOT NULL AND ROUND(StabilityControl, ric48.Rounding) <= ric48.GYRRedMax THEN @GoldColour
									WHEN ric48.GYRRedMax IS NOT NULL AND ROUND(StabilityControl, ric48.Rounding) <= ric48.GYRAmberMax AND ROUND(StabilityControl, ric48.Rounding) > ric48.GYRRedMax THEN @SilverColour
									WHEN ric48.GYRRedMAx IS NOT NULL AND ROUND(StabilityControl, ric48.Rounding) <= ric48.GYRGreenMax AND ROUND(StabilityControl, ric48.Rounding) > ric48.GYRAmberMax THEN @BronzeColour
									WHEN ric48.GYRRedMax IS NOT NULL AND ROUND(StabilityControl, ric48.Rounding) > ric48.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS StabilityControlColour,

		CASE ric49.HighLow	WHEN 1 THEN
								CASE
									WHEN ric49.GYRAmberMax = 0 AND ric49.GYRGreenMax = 0 AND ISNULL(ric49.GYRRedMax,0) = 0 THEN NULL
									WHEN ric49.GYRRedMax IS NULL AND ROUND(CollisionWarningLow, ric49.Rounding) >= ric49.GYRGreenMax THEN @GreenColour
									WHEN ric49.GYRRedMax IS NULL AND ROUND(CollisionWarningLow, ric49.Rounding) >= ric49.GYRAmberMax AND ROUND(CollisionWarningLow, ric49.Rounding) < ric49.GYRGreenMax THEN @YellowColour
									WHEN ric49.GYRRedMax IS NULL AND ROUND(CollisionWarningLow, ric49.Rounding) < ric49.GYRAmberMax THEN @RedColour
									WHEN ric49.GYRRedMax IS NOT NULL AND ROUND(CollisionWarningLow, ric49.Rounding) >= ric49.GYRRedMax THEN @GoldColour
									WHEN ric49.GYRRedMax IS NOT NULL AND ROUND(CollisionWarningLow, ric49.Rounding) >= ric49.GYRAmberMax AND ROUND(CollisionWarningLow, ric49.Rounding) < ric49.GYRRedMax THEN @SilverColour
									WHEN ric49.GYRRedMax IS NOT NULL AND ROUND(CollisionWarningLow, ric49.Rounding) >= ric49.GYRGreenMax AND ROUND(CollisionWarningLow, ric49.Rounding) < ric49.GYRAmberMax THEN @BronzeColour
									WHEN ric49.GYRRedMax IS NOT NULL AND ROUND(CollisionWarningLow, ric49.Rounding) < ric49.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric49.GYRAmberMax = 0 AND ric49.GYRGreenMax = 0 AND ISNULL(ric49.GYRRedMax,0) = 0 THEN NULL
									WHEN ric49.GYRRedMAX IS NULL AND ROUND(CollisionWarningLow, ric49.Rounding) <= ric49.GYRAmberMax THEN @GreenColour
									WHEN ric49.GYRRedMax IS NULL AND ROUND(CollisionWarningLow, ric49.Rounding) <= ric49.GYRGreenMax AND ROUND(CollisionWarningLow, ric49.Rounding) > ric49.GYRAmberMax THEN @YellowColour
									WHEN ric49.GYRRedMax IS NULL AND ROUND(CollisionWarningLow, ric49.Rounding) > ric49.GYRGreenMax THEN @RedColour
									WHEN ric49.GYRRedMax IS NOT NULL AND ROUND(CollisionWarningLow, ric49.Rounding) <= ric49.GYRRedMax THEN @GoldColour
									WHEN ric49.GYRRedMax IS NOT NULL AND ROUND(CollisionWarningLow, ric49.Rounding) <= ric49.GYRAmberMax AND ROUND(CollisionWarningLow, ric49.Rounding) > ric49.GYRRedMax THEN @SilverColour
									WHEN ric49.GYRRedMAx IS NOT NULL AND ROUND(CollisionWarningLow, ric49.Rounding) <= ric49.GYRGreenMax AND ROUND(CollisionWarningLow, ric49.Rounding) > ric49.GYRAmberMax THEN @BronzeColour
									WHEN ric49.GYRRedMax IS NOT NULL AND ROUND(CollisionWarningLow, ric49.Rounding) > ric49.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS CollisionWarningLowColour,

		CASE ric50.HighLow	WHEN 1 THEN
								CASE
									WHEN ric50.GYRAmberMax = 0 AND ric50.GYRGreenMax = 0 AND ISNULL(ric50.GYRRedMax,0) = 0 THEN NULL
									WHEN ric50.GYRRedMax IS NULL AND ROUND(CollisionWarningMed, ric50.Rounding) >= ric50.GYRGreenMax THEN @GreenColour
									WHEN ric50.GYRRedMax IS NULL AND ROUND(CollisionWarningMed, ric50.Rounding) >= ric50.GYRAmberMax AND ROUND(CollisionWarningMed, ric50.Rounding) < ric50.GYRGreenMax THEN @YellowColour
									WHEN ric50.GYRRedMax IS NULL AND ROUND(CollisionWarningMed, ric50.Rounding) < ric50.GYRAmberMax THEN @RedColour
									WHEN ric50.GYRRedMax IS NOT NULL AND ROUND(CollisionWarningMed, ric50.Rounding) >= ric50.GYRRedMax THEN @GoldColour
									WHEN ric50.GYRRedMax IS NOT NULL AND ROUND(CollisionWarningMed, ric50.Rounding) >= ric50.GYRAmberMax AND ROUND(CollisionWarningMed, ric50.Rounding) < ric50.GYRRedMax THEN @SilverColour
									WHEN ric50.GYRRedMax IS NOT NULL AND ROUND(CollisionWarningMed, ric50.Rounding) >= ric50.GYRGreenMax AND ROUND(CollisionWarningMed, ric50.Rounding) < ric50.GYRAmberMax THEN @BronzeColour
									WHEN ric50.GYRRedMax IS NOT NULL AND ROUND(CollisionWarningMed, ric50.Rounding) < ric50.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric50.GYRAmberMax = 0 AND ric50.GYRGreenMax = 0 AND ISNULL(ric50.GYRRedMax,0) = 0 THEN NULL
									WHEN ric50.GYRRedMAX IS NULL AND ROUND(CollisionWarningMed, ric50.Rounding) <= ric50.GYRAmberMax THEN @GreenColour
									WHEN ric50.GYRRedMax IS NULL AND ROUND(CollisionWarningMed, ric50.Rounding) <= ric50.GYRGreenMax AND ROUND(CollisionWarningMed, ric50.Rounding) > ric50.GYRAmberMax THEN @YellowColour
									WHEN ric50.GYRRedMax IS NULL AND ROUND(CollisionWarningMed, ric50.Rounding) > ric50.GYRGreenMax THEN @RedColour
									WHEN ric50.GYRRedMax IS NOT NULL AND ROUND(CollisionWarningMed, ric50.Rounding) <= ric50.GYRRedMax THEN @GoldColour
									WHEN ric50.GYRRedMax IS NOT NULL AND ROUND(CollisionWarningMed, ric50.Rounding) <= ric50.GYRAmberMax AND ROUND(CollisionWarningMed, ric50.Rounding) > ric50.GYRRedMax THEN @SilverColour
									WHEN ric50.GYRRedMAx IS NOT NULL AND ROUND(CollisionWarningMed, ric50.Rounding) <= ric50.GYRGreenMax AND ROUND(CollisionWarningMed, ric50.Rounding) > ric50.GYRAmberMax THEN @BronzeColour
									WHEN ric50.GYRRedMax IS NOT NULL AND ROUND(CollisionWarningMed, ric50.Rounding) > ric50.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS CollisionWarningMedColour,

		CASE ric51.HighLow	WHEN 1 THEN
								CASE
									WHEN ric51.GYRAmberMax = 0 AND ric51.GYRGreenMax = 0 AND ISNULL(ric51.GYRRedMax,0) = 0 THEN NULL
									WHEN ric51.GYRRedMax IS NULL AND ROUND(CollisionWarningHigh, ric51.Rounding) >= ric51.GYRGreenMax THEN @GreenColour
									WHEN ric51.GYRRedMax IS NULL AND ROUND(CollisionWarningHigh, ric51.Rounding) >= ric51.GYRAmberMax AND ROUND(CollisionWarningHigh, ric51.Rounding) < ric51.GYRGreenMax THEN @YellowColour
									WHEN ric51.GYRRedMax IS NULL AND ROUND(CollisionWarningHigh, ric51.Rounding) < ric51.GYRAmberMax THEN @RedColour
									WHEN ric51.GYRRedMax IS NOT NULL AND ROUND(CollisionWarningHigh, ric51.Rounding) >= ric51.GYRRedMax THEN @GoldColour
									WHEN ric51.GYRRedMax IS NOT NULL AND ROUND(CollisionWarningHigh, ric51.Rounding) >= ric51.GYRAmberMax AND ROUND(CollisionWarningHigh, ric51.Rounding) < ric51.GYRRedMax THEN @SilverColour
									WHEN ric51.GYRRedMax IS NOT NULL AND ROUND(CollisionWarningHigh, ric51.Rounding) >= ric51.GYRGreenMax AND ROUND(CollisionWarningHigh, ric51.Rounding) < ric51.GYRAmberMax THEN @BronzeColour
									WHEN ric51.GYRRedMax IS NOT NULL AND ROUND(CollisionWarningHigh, ric51.Rounding) < ric51.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric51.GYRAmberMax = 0 AND ric51.GYRGreenMax = 0 AND ISNULL(ric51.GYRRedMax,0) = 0 THEN NULL
									WHEN ric51.GYRRedMAX IS NULL AND ROUND(CollisionWarningHigh, ric51.Rounding) <= ric51.GYRAmberMax THEN @GreenColour
									WHEN ric51.GYRRedMax IS NULL AND ROUND(CollisionWarningHigh, ric51.Rounding) <= ric51.GYRGreenMax AND ROUND(CollisionWarningHigh, ric51.Rounding) > ric51.GYRAmberMax THEN @YellowColour
									WHEN ric51.GYRRedMax IS NULL AND ROUND(CollisionWarningHigh, ric51.Rounding) > ric51.GYRGreenMax THEN @RedColour
									WHEN ric51.GYRRedMax IS NOT NULL AND ROUND(CollisionWarningHigh, ric51.Rounding) <= ric51.GYRRedMax THEN @GoldColour
									WHEN ric51.GYRRedMax IS NOT NULL AND ROUND(CollisionWarningHigh, ric51.Rounding) <= ric51.GYRAmberMax AND ROUND(CollisionWarningHigh, ric51.Rounding) > ric51.GYRRedMax THEN @SilverColour
									WHEN ric51.GYRRedMAx IS NOT NULL AND ROUND(CollisionWarningHigh, ric51.Rounding) <= ric51.GYRGreenMax AND ROUND(CollisionWarningHigh, ric51.Rounding) > ric51.GYRAmberMax THEN @BronzeColour
									WHEN ric51.GYRRedMax IS NOT NULL AND ROUND(CollisionWarningHigh, ric51.Rounding) > ric51.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS CollisionWarningHighColour,

		CASE ric52.HighLow	WHEN 1 THEN
								CASE
									WHEN ric52.GYRAmberMax = 0 AND ric52.GYRGreenMax = 0 AND ISNULL(ric52.GYRRedMax,0) = 0 THEN NULL
									WHEN ric52.GYRRedMax IS NULL AND ROUND(LaneDepartureDisable, ric52.Rounding) >= ric52.GYRGreenMax THEN @GreenColour
									WHEN ric52.GYRRedMax IS NULL AND ROUND(LaneDepartureDisable, ric52.Rounding) >= ric52.GYRAmberMax AND ROUND(LaneDepartureDisable, ric52.Rounding) < ric52.GYRGreenMax THEN @YellowColour
									WHEN ric52.GYRRedMax IS NULL AND ROUND(LaneDepartureDisable, ric52.Rounding) < ric52.GYRAmberMax THEN @RedColour
									WHEN ric52.GYRRedMax IS NOT NULL AND ROUND(LaneDepartureDisable, ric52.Rounding) >= ric52.GYRRedMax THEN @GoldColour
									WHEN ric52.GYRRedMax IS NOT NULL AND ROUND(LaneDepartureDisable, ric52.Rounding) >= ric52.GYRAmberMax AND ROUND(LaneDepartureDisable, ric52.Rounding) < ric52.GYRRedMax THEN @SilverColour
									WHEN ric52.GYRRedMax IS NOT NULL AND ROUND(LaneDepartureDisable, ric52.Rounding) >= ric52.GYRGreenMax AND ROUND(LaneDepartureDisable, ric52.Rounding) < ric52.GYRAmberMax THEN @BronzeColour
									WHEN ric52.GYRRedMax IS NOT NULL AND ROUND(LaneDepartureDisable, ric52.Rounding) < ric52.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric52.GYRAmberMax = 0 AND ric52.GYRGreenMax = 0 AND ISNULL(ric52.GYRRedMax,0) = 0 THEN NULL
									WHEN ric52.GYRRedMAX IS NULL AND ROUND(LaneDepartureDisable, ric52.Rounding) <= ric52.GYRAmberMax THEN @GreenColour
									WHEN ric52.GYRRedMax IS NULL AND ROUND(LaneDepartureDisable, ric52.Rounding) <= ric52.GYRGreenMax AND ROUND(LaneDepartureDisable, ric52.Rounding) > ric52.GYRAmberMax THEN @YellowColour
									WHEN ric52.GYRRedMax IS NULL AND ROUND(LaneDepartureDisable, ric52.Rounding) > ric52.GYRGreenMax THEN @RedColour
									WHEN ric52.GYRRedMax IS NOT NULL AND ROUND(LaneDepartureDisable, ric52.Rounding) <= ric52.GYRRedMax THEN @GoldColour
									WHEN ric52.GYRRedMax IS NOT NULL AND ROUND(LaneDepartureDisable, ric52.Rounding) <= ric52.GYRAmberMax AND ROUND(LaneDepartureDisable, ric52.Rounding) > ric52.GYRRedMax THEN @SilverColour
									WHEN ric52.GYRRedMAx IS NOT NULL AND ROUND(LaneDepartureDisable, ric52.Rounding) <= ric52.GYRGreenMax AND ROUND(LaneDepartureDisable, ric52.Rounding) > ric52.GYRAmberMax THEN @BronzeColour
									WHEN ric52.GYRRedMax IS NOT NULL AND ROUND(LaneDepartureDisable, ric52.Rounding) > ric52.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS LaneDepartureDisableColour,

		CASE ric53.HighLow	WHEN 1 THEN
								CASE
									WHEN ric53.GYRAmberMax = 0 AND ric53.GYRGreenMax = 0 AND ISNULL(ric53.GYRRedMax,0) = 0 THEN NULL
									WHEN ric53.GYRRedMax IS NULL AND ROUND(LaneDepartureLeftRight, ric53.Rounding) >= ric53.GYRGreenMax THEN @GreenColour
									WHEN ric53.GYRRedMax IS NULL AND ROUND(LaneDepartureLeftRight, ric53.Rounding) >= ric53.GYRAmberMax AND ROUND(LaneDepartureLeftRight*100, ric53.Rounding) < ric53.GYRGreenMax THEN @YellowColour
									WHEN ric53.GYRRedMax IS NULL AND ROUND(LaneDepartureLeftRight, ric53.Rounding) < ric53.GYRAmberMax THEN @RedColour
									WHEN ric53.GYRRedMax IS NOT NULL AND ROUND(LaneDepartureLeftRight, ric53.Rounding) >= ric53.GYRRedMax THEN @GoldColour
									WHEN ric53.GYRRedMax IS NOT NULL AND ROUND(LaneDepartureLeftRight, ric53.Rounding) >= ric53.GYRAmberMax AND ROUND(LaneDepartureLeftRight*100, ric53.Rounding) < ric53.GYRRedMax THEN @SilverColour
									WHEN ric53.GYRRedMax IS NOT NULL AND ROUND(LaneDepartureLeftRight, ric53.Rounding) >= ric53.GYRGreenMax AND ROUND(LaneDepartureLeftRight*100, ric53.Rounding) < ric53.GYRAmberMax THEN @BronzeColour
									WHEN ric53.GYRRedMax IS NOT NULL AND ROUND(LaneDepartureLeftRight, ric53.Rounding) < ric53.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric53.GYRAmberMax = 0 AND ric53.GYRGreenMax = 0 AND ISNULL(ric53.GYRRedMax,0) = 0 THEN NULL
									WHEN ric53.GYRRedMAX IS NULL AND ROUND(LaneDepartureLeftRight, ric53.Rounding) <= ric53.GYRAmberMax THEN @GreenColour
									WHEN ric53.GYRRedMax IS NULL AND ROUND(LaneDepartureLeftRight, ric53.Rounding) <= ric53.GYRGreenMax AND ROUND(LaneDepartureLeftRight*100, ric53.Rounding) > ric53.GYRAmberMax THEN @YellowColour
									WHEN ric53.GYRRedMax IS NULL AND ROUND(LaneDepartureLeftRight, ric53.Rounding) > ric53.GYRGreenMax THEN @RedColour
									WHEN ric53.GYRRedMax IS NOT NULL AND ROUND(LaneDepartureLeftRight, ric53.Rounding) <= ric53.GYRRedMax THEN @GoldColour
									WHEN ric53.GYRRedMax IS NOT NULL AND ROUND(LaneDepartureLeftRight, ric53.Rounding) <= ric53.GYRAmberMax AND ROUND(LaneDepartureLeftRight*100, ric53.Rounding) > ric53.GYRRedMax THEN @SilverColour
									WHEN ric53.GYRRedMAx IS NOT NULL AND ROUND(LaneDepartureLeftRight, ric53.Rounding) <= ric53.GYRGreenMax AND ROUND(LaneDepartureLeftRight*100, ric53.Rounding) > ric53.GYRAmberMax THEN @BronzeColour
									WHEN ric53.GYRRedMax IS NOT NULL AND ROUND(LaneDepartureLeftRight, ric53.Rounding) > ric53.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS LaneDepartureLeftRightColour,

		CASE ric57.HighLow	WHEN 1 THEN
								CASE
									WHEN ric57.GYRAmberMax = 0 AND ric57.GYRGreenMax = 0 AND ISNULL(ric57.GYRRedMax,0) = 0 THEN NULL
									WHEN ric57.GYRRedMax IS NULL AND ROUND(Fatigue, ric57.Rounding) >= ric57.GYRGreenMax THEN @GreenColour
									WHEN ric57.GYRRedMax IS NULL AND ROUND(Fatigue, ric57.Rounding) >= ric57.GYRAmberMax AND ROUND(Fatigue, ric57.Rounding) < ric57.GYRGreenMax THEN @YellowColour
									WHEN ric57.GYRRedMax IS NULL AND ROUND(Fatigue, ric57.Rounding) < ric57.GYRAmberMax THEN @RedColour
									WHEN ric57.GYRRedMax IS NOT NULL AND ROUND(Fatigue, ric57.Rounding) >= ric57.GYRRedMax THEN @GoldColour
									WHEN ric57.GYRRedMax IS NOT NULL AND ROUND(Fatigue, ric57.Rounding) >= ric57.GYRAmberMax AND ROUND(Fatigue, ric57.Rounding) < ric57.GYRRedMax THEN @SilverColour
									WHEN ric57.GYRRedMax IS NOT NULL AND ROUND(Fatigue, ric57.Rounding) >= ric57.GYRGreenMax AND ROUND(Fatigue, ric57.Rounding) < ric57.GYRAmberMax THEN @BronzeColour
									WHEN ric57.GYRRedMax IS NOT NULL AND ROUND(Fatigue, ric57.Rounding) < ric57.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric57.GYRAmberMax = 0 AND ric57.GYRGreenMax = 0 AND ISNULL(ric57.GYRRedMax,0) = 0 THEN NULL
									WHEN ric57.GYRRedMAX IS NULL AND ROUND(Fatigue, ric57.Rounding) <= ric57.GYRAmberMax THEN @GreenColour
									WHEN ric57.GYRRedMax IS NULL AND ROUND(Fatigue, ric57.Rounding) <= ric57.GYRGreenMax AND ROUND(Fatigue, ric57.Rounding) > ric57.GYRAmberMax THEN @YellowColour
									WHEN ric57.GYRRedMax IS NULL AND ROUND(Fatigue, ric57.Rounding) > ric57.GYRGreenMax THEN @RedColour
									WHEN ric57.GYRRedMax IS NOT NULL AND ROUND(Fatigue, ric57.Rounding) <= ric57.GYRRedMax THEN @GoldColour
									WHEN ric57.GYRRedMax IS NOT NULL AND ROUND(Fatigue, ric57.Rounding) <= ric57.GYRAmberMax AND ROUND(Fatigue, ric57.Rounding) > ric57.GYRRedMax THEN @SilverColour
									WHEN ric57.GYRRedMAx IS NOT NULL AND ROUND(Fatigue, ric57.Rounding) <= ric57.GYRGreenMax AND ROUND(Fatigue, ric57.Rounding) > ric57.GYRAmberMax THEN @BronzeColour
									WHEN ric57.GYRRedMax IS NOT NULL AND ROUND(Fatigue, ric57.Rounding) > ric57.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS FatigueColour,

		CASE ric58.HighLow	WHEN 1 THEN
								CASE
									WHEN ric58.GYRAmberMax = 0 AND ric58.GYRGreenMax = 0 AND ISNULL(ric58.GYRRedMax,0) = 0 THEN NULL
									WHEN ric58.GYRRedMax IS NULL AND ROUND(Distraction, ric58.Rounding) >= ric58.GYRGreenMax THEN @GreenColour
									WHEN ric58.GYRRedMax IS NULL AND ROUND(Distraction, ric58.Rounding) >= ric58.GYRAmberMax AND ROUND(Distraction, ric58.Rounding) < ric58.GYRGreenMax THEN @YellowColour
									WHEN ric58.GYRRedMax IS NULL AND ROUND(Distraction, ric58.Rounding) < ric58.GYRAmberMax THEN @RedColour
									WHEN ric58.GYRRedMax IS NOT NULL AND ROUND(Distraction, ric58.Rounding) >= ric58.GYRRedMax THEN @GoldColour
									WHEN ric58.GYRRedMax IS NOT NULL AND ROUND(Distraction, ric58.Rounding) >= ric58.GYRAmberMax AND ROUND(Distraction, ric58.Rounding) < ric58.GYRRedMax THEN @SilverColour
									WHEN ric58.GYRRedMax IS NOT NULL AND ROUND(Distraction, ric58.Rounding) >= ric58.GYRGreenMax AND ROUND(Distraction, ric58.Rounding) < ric58.GYRAmberMax THEN @BronzeColour
									WHEN ric58.GYRRedMax IS NOT NULL AND ROUND(Distraction, ric58.Rounding) < ric58.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric58.GYRAmberMax = 0 AND ric58.GYRGreenMax = 0 AND ISNULL(ric58.GYRRedMax,0) = 0 THEN NULL
									WHEN ric58.GYRRedMAX IS NULL AND ROUND(Distraction, ric58.Rounding) <= ric58.GYRAmberMax THEN @GreenColour
									WHEN ric58.GYRRedMax IS NULL AND ROUND(Distraction, ric58.Rounding) <= ric58.GYRGreenMax AND ROUND(Distraction, ric58.Rounding) > ric58.GYRAmberMax THEN @YellowColour
									WHEN ric58.GYRRedMax IS NULL AND ROUND(Distraction, ric58.Rounding) > ric58.GYRGreenMax THEN @RedColour
									WHEN ric58.GYRRedMax IS NOT NULL AND ROUND(Distraction, ric58.Rounding) <= ric58.GYRRedMax THEN @GoldColour
									WHEN ric58.GYRRedMax IS NOT NULL AND ROUND(Distraction, ric58.Rounding) <= ric58.GYRAmberMax AND ROUND(Distraction, ric58.Rounding) > ric58.GYRRedMax THEN @SilverColour
									WHEN ric58.GYRRedMAx IS NOT NULL AND ROUND(Distraction, ric58.Rounding) <= ric58.GYRGreenMax AND ROUND(Distraction, ric58.Rounding) > ric58.GYRAmberMax THEN @BronzeColour
									WHEN ric58.GYRRedMax IS NOT NULL AND ROUND(Distraction, ric58.Rounding) > ric58.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS DistractionColour,

		CASE ric54.HighLow	WHEN 1 THEN
								CASE
									WHEN ric54.GYRAmberMax = 0 AND ric54.GYRGreenMax = 0 AND ISNULL(ric54.GYRRedMax,0) = 0 THEN NULL
									WHEN ric54.GYRRedMax IS NULL AND ROUND(SweetSpotTime*100, ric54.Rounding) >= ric54.GYRGreenMax THEN @GreenColour
									WHEN ric54.GYRRedMax IS NULL AND ROUND(SweetSpotTime*100, ric54.Rounding) >= ric54.GYRAmberMax AND ROUND(SweetSpotTime*100, ric54.Rounding) < ric54.GYRGreenMax THEN @YellowColour
									WHEN ric54.GYRRedMax IS NULL AND ROUND(SweetSpotTime*100, ric54.Rounding) < ric54.GYRAmberMax THEN @RedColour
									WHEN ric54.GYRRedMax IS NOT NULL AND ROUND(SweetSpotTime*100, ric54.Rounding) >= ric54.GYRRedMax THEN @GoldColour
									WHEN ric54.GYRRedMax IS NOT NULL AND ROUND(SweetSpotTime*100, ric54.Rounding) >= ric54.GYRAmberMax AND ROUND(SweetSpotTime*100, ric54.Rounding) < ric54.GYRRedMax THEN @SilverColour
									WHEN ric54.GYRRedMax IS NOT NULL AND ROUND(SweetSpotTime*100, ric54.Rounding) >= ric54.GYRGreenMax AND ROUND(SweetSpotTime*100, ric54.Rounding) < ric54.GYRAmberMax THEN @BronzeColour
									WHEN ric54.GYRRedMax IS NOT NULL AND ROUND(SweetSpotTime*100, ric54.Rounding) < ric54.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric54.GYRAmberMax = 0 AND ric54.GYRGreenMax = 0 AND ISNULL(ric54.GYRRedMax,0) = 0 THEN NULL
									WHEN ric54.GYRRedMAX IS NULL AND ROUND(SweetSpotTime*100, ric54.Rounding) <= ric54.GYRAmberMax THEN @GreenColour
									WHEN ric54.GYRRedMax IS NULL AND ROUND(SweetSpotTime*100, ric54.Rounding) <= ric54.GYRGreenMax AND ROUND(SweetSpotTime*100, ric54.Rounding) > ric54.GYRAmberMax THEN @YellowColour
									WHEN ric54.GYRRedMax IS NULL AND ROUND(SweetSpotTime*100, ric54.Rounding) > ric54.GYRGreenMax THEN @RedColour
									WHEN ric54.GYRRedMax IS NOT NULL AND ROUND(SweetSpotTime*100, ric54.Rounding) <= ric54.GYRRedMax THEN @GoldColour
									WHEN ric54.GYRRedMax IS NOT NULL AND ROUND(SweetSpotTime*100, ric54.Rounding) <= ric54.GYRAmberMax AND ROUND(SweetSpotTime*100, ric54.Rounding) > ric54.GYRRedMax THEN @SilverColour
									WHEN ric54.GYRRedMAx IS NOT NULL AND ROUND(SweetSpotTime*100, ric54.Rounding) <= ric54.GYRGreenMax AND ROUND(SweetSpotTime*100, ric54.Rounding) > ric54.GYRAmberMax THEN @BronzeColour
									WHEN ric54.GYRRedMax IS NOT NULL AND ROUND(SweetSpotTime*100, ric54.Rounding) > ric54.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS SweetSpotTimeColour,

		CASE ric55.HighLow	WHEN 1 THEN
								CASE
									WHEN ric55.GYRAmberMax = 0 AND ric55.GYRGreenMax = 0 AND ISNULL(ric55.GYRRedMax,0) = 0 THEN NULL
									WHEN ric55.GYRRedMax IS NULL AND ROUND(OverRevTime*100, ric55.Rounding) >= ric55.GYRGreenMax THEN @GreenColour
									WHEN ric55.GYRRedMax IS NULL AND ROUND(OverRevTime*100, ric55.Rounding) >= ric55.GYRAmberMax AND ROUND(OverRevTime*100, ric55.Rounding) < ric55.GYRGreenMax THEN @YellowColour
									WHEN ric55.GYRRedMax IS NULL AND ROUND(OverRevTime*100, ric55.Rounding) < ric55.GYRAmberMax THEN @RedColour
									WHEN ric55.GYRRedMax IS NOT NULL AND ROUND(OverRevTime*100, ric55.Rounding) >= ric55.GYRRedMax THEN @GoldColour
									WHEN ric55.GYRRedMax IS NOT NULL AND ROUND(OverRevTime*100, ric55.Rounding) >= ric55.GYRAmberMax AND ROUND(OverRevTime*100, ric55.Rounding) < ric55.GYRRedMax THEN @SilverColour
									WHEN ric55.GYRRedMax IS NOT NULL AND ROUND(OverRevTime*100, ric55.Rounding) >= ric55.GYRGreenMax AND ROUND(OverRevTime*100, ric55.Rounding) < ric55.GYRAmberMax THEN @BronzeColour
									WHEN ric55.GYRRedMax IS NOT NULL AND ROUND(OverRevTime*100, ric55.Rounding) < ric55.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric55.GYRAmberMax = 0 AND ric55.GYRGreenMax = 0 AND ISNULL(ric55.GYRRedMax,0) = 0 THEN NULL
									WHEN ric55.GYRRedMAX IS NULL AND ROUND(OverRevTime*100, ric55.Rounding) <= ric55.GYRAmberMax THEN @GreenColour
									WHEN ric55.GYRRedMax IS NULL AND ROUND(OverRevTime*100, ric55.Rounding) <= ric55.GYRGreenMax AND ROUND(OverRevTime*100, ric55.Rounding) > ric55.GYRAmberMax THEN @YellowColour
									WHEN ric55.GYRRedMax IS NULL AND ROUND(OverRevTime*100, ric55.Rounding) > ric55.GYRGreenMax THEN @RedColour
									WHEN ric55.GYRRedMax IS NOT NULL AND ROUND(OverRevTime*100, ric55.Rounding) <= ric55.GYRRedMax THEN @GoldColour
									WHEN ric55.GYRRedMax IS NOT NULL AND ROUND(OverRevTime*100, ric55.Rounding) <= ric55.GYRAmberMax AND ROUND(OverRevTime*100, ric55.Rounding) > ric55.GYRRedMax THEN @SilverColour
									WHEN ric55.GYRRedMAx IS NOT NULL AND ROUND(OverRevTime*100, ric55.Rounding) <= ric55.GYRGreenMax AND ROUND(OverRevTime*100, ric55.Rounding) > ric55.GYRAmberMax THEN @BronzeColour
									WHEN ric55.GYRRedMax IS NOT NULL AND ROUND(OverRevTime*100, ric55.Rounding) > ric55.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS OverRevTimeColour,

		CASE ric56.HighLow	WHEN 1 THEN
								CASE
									WHEN ric56.GYRAmberMax = 0 AND ric56.GYRGreenMax = 0 AND ISNULL(ric56.GYRRedMax,0) = 0 THEN NULL
									WHEN ric56.GYRRedMax IS NULL AND ROUND(TopGearTime*100, ric56.Rounding) >= ric56.GYRGreenMax THEN @GreenColour
									WHEN ric56.GYRRedMax IS NULL AND ROUND(TopGearTime*100, ric56.Rounding) >= ric56.GYRAmberMax AND ROUND(TopGearTime*100, ric56.Rounding) < ric56.GYRGreenMax THEN @YellowColour
									WHEN ric56.GYRRedMax IS NULL AND ROUND(TopGearTime*100, ric56.Rounding) < ric56.GYRAmberMax THEN @RedColour
									WHEN ric56.GYRRedMax IS NOT NULL AND ROUND(TopGearTime*100, ric56.Rounding) >= ric56.GYRRedMax THEN @GoldColour
									WHEN ric56.GYRRedMax IS NOT NULL AND ROUND(TopGearTime*100, ric56.Rounding) >= ric56.GYRAmberMax AND ROUND(TopGearTime*100, ric56.Rounding) < ric56.GYRRedMax THEN @SilverColour
									WHEN ric56.GYRRedMax IS NOT NULL AND ROUND(TopGearTime*100, ric56.Rounding) >= ric56.GYRGreenMax AND ROUND(TopGearTime*100, ric56.Rounding) < ric56.GYRAmberMax THEN @BronzeColour
									WHEN ric56.GYRRedMax IS NOT NULL AND ROUND(TopGearTime*100, ric56.Rounding) < ric56.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric56.GYRAmberMax = 0 AND ric56.GYRGreenMax = 0 AND ISNULL(ric56.GYRRedMax,0) = 0 THEN NULL
									WHEN ric56.GYRRedMAX IS NULL AND ROUND(TopGearTime*100, ric56.Rounding) <= ric56.GYRAmberMax THEN @GreenColour
									WHEN ric56.GYRRedMax IS NULL AND ROUND(TopGearTime*100, ric56.Rounding) <= ric56.GYRGreenMax AND ROUND(TopGearTime*100, ric56.Rounding) > ric56.GYRAmberMax THEN @YellowColour
									WHEN ric56.GYRRedMax IS NULL AND ROUND(TopGearTime*100, ric56.Rounding) > ric56.GYRGreenMax THEN @RedColour
									WHEN ric56.GYRRedMax IS NOT NULL AND ROUND(TopGearTime*100, ric56.Rounding) <= ric56.GYRRedMax THEN @GoldColour
									WHEN ric56.GYRRedMax IS NOT NULL AND ROUND(TopGearTime*100, ric56.Rounding) <= ric56.GYRAmberMax AND ROUND(TopGearTime*100, ric56.Rounding) > ric56.GYRRedMax THEN @SilverColour
									WHEN ric56.GYRRedMAx IS NOT NULL AND ROUND(TopGearTime*100, ric56.Rounding) <= ric56.GYRGreenMax AND ROUND(TopGearTime*100, ric56.Rounding) > ric56.GYRAmberMax THEN @BronzeColour
									WHEN ric56.GYRRedMax IS NOT NULL AND ROUND(TopGearTime*100, ric56.Rounding) > ric56.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS TopGearTimeColour,


		CASE ric59.HighLow	WHEN 1 THEN
								CASE
									WHEN ric59.GYRAmberMax = 0 AND ric59.GYRGreenMax = 0 AND ISNULL(ric59.GYRRedMax,0) = 0 THEN NULL
									WHEN ric59.GYRRedMax IS NULL AND ROUND(SpeedGauge*100, ric59.Rounding) >= ric59.GYRGreenMax THEN @GreenColour
									WHEN ric59.GYRRedMax IS NULL AND ROUND(SpeedGauge*100, ric59.Rounding) >= ric59.GYRAmberMax AND ROUND(SpeedGauge*100, ric59.Rounding) < ric59.GYRGreenMax THEN @YellowColour
									WHEN ric59.GYRRedMax IS NULL AND ROUND(SpeedGauge*100, ric59.Rounding) < ric59.GYRAmberMax THEN @RedColour
									WHEN ric59.GYRRedMax IS NOT NULL AND ROUND(SpeedGauge*100, ric59.Rounding) >= ric59.GYRRedMax THEN @GoldColour
									WHEN ric59.GYRRedMax IS NOT NULL AND ROUND(SpeedGauge*100, ric59.Rounding) >= ric59.GYRAmberMax AND ROUND(SpeedGauge*100, ric59.Rounding) < ric59.GYRRedMax THEN @SilverColour
									WHEN ric59.GYRRedMax is NOT NULL AND ROUND(SpeedGauge*100, ric59.Rounding) >= ric59.GYRGreenMax AND ROUND(SpeedGauge*100, ric59.Rounding) < ric59.GYRAmberMax THEN @BronzeColour
									WHEN ric59.GYRRedMax IS NOT NULL AND ROUND(SpeedGauge*100, ric59.Rounding) < ric59.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric59.GYRAmberMax = 0 AND ric59.GYRGreenMax = 0 AND ISNULL(ric59.GYRRedMax,0) = 0 THEN NULL
									WHEN ric59.GYRRedMAX IS NULL AND ROUND(SpeedGauge*100, ric59.Rounding) <= ric59.GYRAmberMax THEN @GreenColour
									WHEN ric59.GYRRedMax IS NULL AND ROUND(SpeedGauge*100, ric59.Rounding) <= ric59.GYRGreenMax AND ROUND(SpeedGauge*100, ric59.Rounding) > ric59.GYRAmberMax THEN @YellowColour
									WHEN ric59.GYRRedMax IS NULL AND ROUND(SpeedGauge*100, ric59.Rounding) > ric59.GYRGreenMax THEN @RedColour
									WHEN ric59.GYRRedMax IS NOT NULL AND ROUND(SpeedGauge*100, ric59.Rounding) <= ric59.GYRRedMax THEN @GoldColour
									WHEN ric59.GYRRedMax IS NOT NULL AND ROUND(SpeedGauge*100, ric59.Rounding) <= ric59.GYRAmberMax AND ROUND(SpeedGauge*100, ric59.Rounding) > ric59.GYRRedMax THEN @SilverColour
									WHEN ric59.GYRRedMAx IS NOT NULL AND ROUND(SpeedGauge*100, ric59.Rounding) <= ric59.GYRGreenMax AND ROUND(SpeedGauge*100, ric59.Rounding) > ric59.GYRAmberMax THEN @BronzeColour
									WHEN ric59.GYRRedMax IS NOT NULL AND ROUND(SpeedGauge*100, ric59.Rounding) > ric59.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END AS SpeedGaugeColour

FROM @data dd
LEFT JOIN dbo.Vehicle v ON dd.VehicleId = v.VehicleId
LEFT JOIN dbo.Driver d ON dd.DriverId = d.DriverId
LEFT JOIN dbo.ReportIndicatorConfig ric1 ON ric1.ReportConfigurationId = @lrprtcfgid AND ric1.IndicatorId = 1
LEFT JOIN dbo.ReportIndicatorConfig ric2 ON ric2.ReportConfigurationId = @lrprtcfgid AND ric2.IndicatorId = 2
LEFT JOIN dbo.ReportIndicatorConfig ric3 ON ric3.ReportConfigurationId = @lrprtcfgid AND ric3.IndicatorId = 3
LEFT JOIN dbo.ReportIndicatorConfig ric4 ON ric4.ReportConfigurationId = @lrprtcfgid AND ric4.IndicatorId = 4
LEFT JOIN dbo.ReportIndicatorConfig ric5 ON ric5.ReportConfigurationId = @lrprtcfgid AND ric5.IndicatorId = 5
LEFT JOIN dbo.ReportIndicatorConfig ric6 ON ric6.ReportConfigurationId = @lrprtcfgid AND ric6.IndicatorId = 6
LEFT JOIN dbo.ReportIndicatorConfig ric7 ON ric7.ReportConfigurationId = @lrprtcfgid AND ric7.IndicatorId = 7
LEFT JOIN dbo.ReportIndicatorConfig ric8 ON ric8.ReportConfigurationId = @lrprtcfgid AND ric8.IndicatorId = 8
LEFT JOIN dbo.ReportIndicatorConfig ric9 ON ric9.ReportConfigurationId = @lrprtcfgid AND ric9.IndicatorId = 9
LEFT JOIN dbo.ReportIndicatorConfig ric10 ON ric10.ReportConfigurationId = @lrprtcfgid AND ric10.IndicatorId = 10
LEFT JOIN dbo.ReportIndicatorConfig ric11 ON ric11.ReportConfigurationId = @lrprtcfgid AND ric11.IndicatorId = 11
LEFT JOIN dbo.ReportIndicatorConfig ric12 ON ric12.ReportConfigurationId = @lrprtcfgid AND ric12.IndicatorId = 12
LEFT JOIN dbo.ReportIndicatorConfig ric14 ON ric14.ReportConfigurationId = @lrprtcfgid AND ric14.IndicatorId = 14
LEFT JOIN dbo.ReportIndicatorConfig ric15 ON ric15.ReportConfigurationId = @lrprtcfgid AND ric15.IndicatorId = 15
LEFT JOIN dbo.ReportIndicatorConfig ric16 ON ric16.ReportConfigurationId = @lrprtcfgid AND ric16.IndicatorId = 16
LEFT JOIN dbo.ReportIndicatorConfig ric20 ON ric20.ReportConfigurationId = @lrprtcfgid AND ric20.IndicatorId = 20
LEFT JOIN dbo.ReportIndicatorConfig ric21 ON ric21.ReportConfigurationId = @lrprtcfgid AND ric21.IndicatorId = 21
LEFT JOIN dbo.ReportIndicatorConfig ric22 ON ric22.ReportConfigurationId = @lrprtcfgid AND ric22.IndicatorId = 22
LEFT JOIN dbo.ReportIndicatorConfig ric23 ON ric23.ReportConfigurationId = @lrprtcfgid AND ric23.IndicatorId = 23
LEFT JOIN dbo.ReportIndicatorConfig ric24 ON ric24.ReportConfigurationId = @lrprtcfgid AND ric24.IndicatorId = 24
LEFT JOIN dbo.ReportIndicatorConfig ric25 ON ric25.ReportConfigurationId = @lrprtcfgid AND ric25.IndicatorId = 25
LEFT JOIN dbo.ReportIndicatorConfig ric28 ON ric28.ReportConfigurationId = @lrprtcfgid AND ric28.IndicatorId = 28
LEFT JOIN dbo.ReportIndicatorConfig ric29 ON ric29.ReportConfigurationId = @lrprtcfgid AND ric29.IndicatorId = 29
LEFT JOIN dbo.ReportIndicatorConfig ric30 ON ric30.ReportConfigurationId = @lrprtcfgid AND ric30.IndicatorId = 30
LEFT JOIN dbo.ReportIndicatorConfig ric31 ON ric31.ReportConfigurationId = @lrprtcfgid AND ric31.IndicatorId = 31
LEFT JOIN dbo.ReportIndicatorConfig ric32 ON ric32.ReportConfigurationId = @lrprtcfgid AND ric32.IndicatorId = 32
LEFT JOIN dbo.ReportIndicatorConfig ric33 ON ric33.ReportConfigurationId = @lrprtcfgid AND ric33.IndicatorId = 33
LEFT JOIN dbo.ReportIndicatorConfig ric34 ON ric34.ReportConfigurationId = @lrprtcfgid AND ric34.IndicatorId = 34
LEFT JOIN dbo.ReportIndicatorConfig ric35 ON ric35.ReportConfigurationId = @lrprtcfgid AND ric35.IndicatorId = 35
LEFT JOIN dbo.ReportIndicatorConfig ric36 ON ric36.ReportConfigurationId = @lrprtcfgid AND ric36.IndicatorId = 36
LEFT JOIN dbo.ReportIndicatorConfig ric37 ON ric37.ReportConfigurationId = @lrprtcfgid AND ric37.IndicatorId = 37
LEFT JOIN dbo.ReportIndicatorConfig ric38 ON ric38.ReportConfigurationId = @lrprtcfgid AND ric38.IndicatorId = 38
LEFT JOIN dbo.ReportIndicatorConfig ric39 ON ric39.ReportConfigurationId = @lrprtcfgid AND ric39.IndicatorId = 39
LEFT JOIN dbo.ReportIndicatorConfig ric40 ON ric40.ReportConfigurationId = @lrprtcfgid AND ric40.IndicatorId = 40
LEFT JOIN dbo.ReportIndicatorConfig ric41 ON ric41.ReportConfigurationId = @lrprtcfgid AND ric41.IndicatorId = 41
LEFT JOIN dbo.ReportIndicatorConfig ric42 ON ric42.ReportConfigurationId = @lrprtcfgid AND ric42.IndicatorId = 42
LEFT JOIN dbo.ReportIndicatorConfig ric43 ON ric43.ReportConfigurationId = @lrprtcfgid AND ric43.IndicatorId = 43
LEFT JOIN dbo.ReportIndicatorConfig ric46 ON ric46.ReportConfigurationId = @lrprtcfgid AND ric46.IndicatorId = 46
LEFT JOIN dbo.ReportIndicatorConfig ric47 ON ric47.ReportConfigurationId = @lrprtcfgid AND ric47.IndicatorId = 47
LEFT JOIN dbo.ReportIndicatorConfig ric48 ON ric48.ReportConfigurationId = @lrprtcfgid AND ric48.IndicatorId = 48
LEFT JOIN dbo.ReportIndicatorConfig ric49 ON ric49.ReportConfigurationId = @lrprtcfgid AND ric49.IndicatorId = 49
LEFT JOIN dbo.ReportIndicatorConfig ric50 ON ric50.ReportConfigurationId = @lrprtcfgid AND ric50.IndicatorId = 50
LEFT JOIN dbo.ReportIndicatorConfig ric51 ON ric51.ReportConfigurationId = @lrprtcfgid AND ric51.IndicatorId = 51
LEFT JOIN dbo.ReportIndicatorConfig ric52 ON ric52.ReportConfigurationId = @lrprtcfgid AND ric52.IndicatorId = 52
LEFT JOIN dbo.ReportIndicatorConfig ric53 ON ric53.ReportConfigurationId = @lrprtcfgid AND ric53.IndicatorId = 53
LEFT JOIN dbo.ReportIndicatorConfig ric54 ON ric54.ReportConfigurationId = @lrprtcfgid AND ric54.IndicatorId = 54
LEFT JOIN dbo.ReportIndicatorConfig ric55 ON ric55.ReportConfigurationId = @lrprtcfgid AND ric55.IndicatorId = 55
LEFT JOIN dbo.ReportIndicatorConfig ric56 ON ric56.ReportConfigurationId = @lrprtcfgid AND ric56.IndicatorId = 56
LEFT JOIN dbo.ReportIndicatorConfig ric57 ON ric57.ReportConfigurationId = @lrprtcfgid AND ric57.IndicatorId = 57
LEFT JOIN dbo.ReportIndicatorConfig ric58 ON ric58.ReportConfigurationId = @lrprtcfgid AND ric58.IndicatorId = 58
LEFT JOIN dbo.ReportIndicatorConfig ric59 ON ric59.ReportConfigurationId = @lrprtcfgid AND ric59.IndicatorId = 59
ORDER BY Registration, Surname


GO
