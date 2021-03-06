SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Driver_Report_Coaching]
(
	@dids varchar(max),
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER,
	@drilldown TINYINT,
	@calendar TINYINT,
	@groupBy INT
)
AS

--declare	@dids varchar(max),
--		@sdate datetime,
--		@edate datetime,
--		@uid UNIQUEIDENTIFIER,
--		@rprtcfgid UNIQUEIDENTIFIER,
--		@drilldown TINYINT,
--		@calendar TINYINT,
--		@groupBy INT

--SET @dids = N'64844794-79A0-454B-999B-D2B30C33992A'
--	SET @sdate = '2020-03-23 00:00'
--	SET @edate = '2020-03-23 23:59'
--SET @uid = N'6E39B5F2-1CD4-4069-A562-0311E2584DDF'
--SET @rprtcfgid = N'1453f8c7-e0b5-4195-a10f-14e034f421b9'
--SET @drilldown = 1
--SET @calendar = 1
--SET @groupBy = 3



DECLARE @Results TABLE
(
		-- Week identification columns
 		PeriodNum INT,
		PeriodStartDate DATETIME,
		PeriodEndDate DATETIME,
		
		-- Vehicle and Driver Identification columns
		VehicleId UNIQUEIDENTIFIER,	
		Registration VARCHAR(MAX),
		
		DriverId UNIQUEIDENTIFIER,
 		DisplayName VARCHAR(MAX),
 		DriverName VARCHAR(MAX), -- included for backward compatibility
 		FirstName VARCHAR(MAX),
 		Surname VARCHAR(MAX),
 		MiddleNames VARCHAR(MAX),
 		Number VARCHAR(MAX),
 		NumberAlternate VARCHAR(MAX),
 		NumberAlternate2 VARCHAR(MAX),

		-- Coaching figures
		Coached INT,
		NotRequired INT,
		NotCoached INT,
 		
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
		FuelWastageCost FLOAT,
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
		CruiseTopGearRatioComponent FLOAT,
		IdleComponent FLOAT,
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
		CoastInGearComponent FLOAT,
		HarshBrakingComponent FLOAT,
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
		SAFETY FLOAT,

		-- Additional columns with no corresponding colour	
		TotalTime FLOAT,
		TotalDrivingDistance FLOAT,
		ServiceBrakeUsage FLOAT,	
		OverRevCount FLOAT,
		
		-- Date and Unit columns 
		sdate DATETIME,
		edate DATETIME,
		CreationDateTime DATETIME,
		ClosureDateTime DATETIME,

		DistanceUnit VARCHAR(MAX),
		FuelUnit VARCHAR(MAX),
		Co2Unit VARCHAR(MAX),
		FuelMult FLOAT,
		Currency VARCHAR(10),

		-- Colour columns corresponding to data columns above (all set to NULL for Fleet Report)
		SweetSpotColour VARCHAR(30), SweetSpotMix SMALLINT,
		OverRevWithFuelColour VARCHAR(30), OverRevWithFuelMix SMALLINT,
		TopGearColour VARCHAR(30), TopGearMix SMALLINT,
		CruiseColour VARCHAR(30), CruiseMix SMALLINT,
		CruiseInTopGearsColour VARCHAR(30), CruiseInTopGearsMix SMALLINT,
		CoastInGearColour VARCHAR(30), CoastInGearMix SMALLINT,
		IdleColour VARCHAR(30), IdleMix SMALLINT,
		EngineServiceBrakeColour VARCHAR(30), EngineServiceBrakeMix SMALLINT,
		OverRevWithoutFuelColour VARCHAR(30), OverRevWithoutFuelMix SMALLINT,
		RopColour VARCHAR(30), RopMix SMALLINT,
		Rop2Colour VARCHAR(30), Rop2Mix SMALLINT,
		OverSpeedColour VARCHAR(30), OverSpeedMix SMALLINT,
		OverSpeedHighColour VARCHAR(30), OverSpeedHighMix SMALLINT,
		IVHOverSpeedColour VARCHAR(30), IVHOverSpeedMix SMALLINT,

		SpeedGaugeColour VARCHAR(30),SpeedGaugeMix SMALLINT,

		CoastOutOfGearColour VARCHAR(30), CoastOutOfGearMix SMALLINT,
		HarshBrakingColour VARCHAR(30), HarshBrakingMix SMALLINT,
		EfficiencyColour VARCHAR(30), EfficiencyMix SMALLINT,
		SafetyColour VARCHAR(30), SafetyMix SMALLINT,
		KPLColour VARCHAR(30), KPLMix SMALLINT,
		Co2Colour VARCHAR(30), Co2Mix SMALLINT,
		OverSpeedDistanceColour VARCHAR(30), OverSpeedDistanceMix SMALLINT,
		AccelerationColour VARCHAR(30), AccelerationMix SMALLINT,
		BrakingColour VARCHAR(30), BrakingMix SMALLINT,
		CorneringColour VARCHAR(30), CorneringMix SMALLINT,
		AccelerationLowColour VARCHAR(30), AccelerationLowMix SMALLINT,
		BrakingLowColour VARCHAR(30), BrakingLowMix SMALLINT,
		CorneringLowColour VARCHAR(30), CorneringLowMix SMALLINT,
		AccelerationHighColour VARCHAR(30), AccelerationHighMix SMALLINT,
		BrakingHighColour VARCHAR(30), BrakingHighMix SMALLINT,
		CorneringHighColour VARCHAR(30), CorneringHighMix SMALLINT,
		ManoeuvresLowColour VARCHAR(30), ManoeuvresLowMix SMALLINT,
		ManoeuvresMedColour VARCHAR(30), ManoeuvresMedMix SMALLINT,
		CruiseTopGearRatioColour VARCHAR(30), CruiseTopGearRatioMix SMALLINT,
		OverRevCountColour VARCHAR(30), OverRevCountMix SMALLINT,
		PtoColour VARCHAR(30), PtoMix SMALLINT,
		CruiseOverspeedColour VARCHAR(30), CruiseOverspeedMix SMALLINT,
		TopGearOverspeedColour VARCHAR(30), TopGearOverspeedMix SMALLINT,
		FuelWastageCostColour VARCHAR(30),
		OverspeedCountColour VARCHAR(30), OverspeedCountMix SMALLINT,
		OverspeedHighCountColour VARCHAR(30), OverspeedHighCountMix SMALLINT,
		StabilityControlColour VARCHAR(30), StabilityControlMix SMALLINT,
		CollisionWarningLowColour VARCHAR(30), CollisionWarningLowMix SMALLINT,
		CollisionWarningMedColour VARCHAR(30), CollisionWarningMedMix SMALLINT,
		CollisionWarningHighColour VARCHAR(30), CollisionWarningHighMix SMALLINT,
		LaneDepartureDisableColour VARCHAR(30), LaneDepartureDisableMix SMALLINT,
		LaneDepartureLeftRightColour VARCHAR(30), LaneDepartureLeftRightMix SMALLINT,
		SweetSpotTimeColour VARCHAR(30), SweetSpotTimeMix SMALLINT,
		OverRevTimeColour VARCHAR(30), OverRevTimeMix SMALLINT,
		TopGearTimeColour VARCHAR(30), TopGearTimeMix SMALLINT,
		FatigueColour VARCHAR(30), FatigueMix SMALLINT,
		DistractionColour VARCHAR(30), DistractionMix SMALLINT
)

-- Driver values by week and for period
INSERT INTO @Results
EXEC dbo.proc_ReportCoaching
	@dids, @sdate, @edate, @uid, @rprtcfgid, @drilldown, @calendar, @groupBy

DELETE FROM @Results
WHERE PeriodNum IS NULL AND DriverId IS NULL AND VehicleId IS NULL

-- Fleet averages
INSERT INTO @Results
EXEC dbo.proc_ReportCoaching_Fleet
	@sdate, @edate, @uid, @rprtcfgid  -- pass NULLs so that the Fleet average for all vehicles will be calculated

DECLARE @did UNIQUEIDENTIFIER
--SELECT TOP 1 @did = DriverId FROM @Results WHERE DriverId IS NOT NULL ORDER BY DriverId DESC
SET @did = CAST(@dids AS UNIQUEIDENTIFIER)

INSERT INTO dbo.CAM_CoachingSession
        ( CoachingStatusId ,
          CoachUserId ,
          CoachedDriverId ,
          Archived ,
          LastOperation
        )
VALUES  (   1,	-- CoachingStatusId - int
			@uid ,	-- CoachUserId - uniqueidentifier
			@did ,	-- CoachedDriverId - uniqueidentifier
			0 ,		-- Archived - bit
			GETDATE() -- LastOperation - datetime
        )

DECLARE @cid INT
SELECT @cid = SCOPE_IDENTITY()

INSERT INTO dbo.CAM_Coaching
        ( CoachingSessionId ,
          PeriodNum ,
          PeriodStartDate ,
          PeriodEndDate ,
          VehicleId ,
          DriverId ,
          Safety ,
          Efficiency ,
          FuelEcon ,
          TotalDrivingDistance ,
          TotalTime ,
          Coached ,
          NotRequired ,
          NotCoached ,
          EngineServiceBrake ,
          OverRevWithoutFuel ,
          OverSpeed ,
          OverSpeedHigh ,
          IVHOverSpeed ,

		  SpeedGauge,

          CoastOutOfGear ,
          HarshBraking ,
          Rop ,
          Rop2 ,
          Acceleration ,
          Braking ,
          Cornering ,
          ManoeuvresLow ,
          ManoeuvresMed ,
          AccelerationHigh ,
          BrakingHigh ,
          CorneringHigh ,
          OverRevCount ,
          SweetSpot ,
          OverRevWithFuel ,
          TopGear ,
          Cruise ,
          CruiseInTopGears ,
          CruiseTopGearRatio ,
          CoastInGear ,
          Idle ,
          Co2 ,
          Pto ,
          SweetSpotComponent ,
          OverRevWithFuelComponent ,
          TopGearComponent ,
          CruiseComponent ,
          CruiseInTopGearsComponent ,
          CruiseTopGearRatioComponent ,
          IdleComponent ,
          EngineServiceBrakeComponent ,
          OverRevWithoutFuelComponent ,
          RopComponent ,
          Rop2Component ,
          OverSpeedComponent ,
          OverSpeedHighComponent ,
          OverSpeedDistanceComponent ,
          IVHOverSpeedComponent ,

		  SpeedGaugeComponent,

          CoastOutOfGearComponent ,
          CoastInGearComponent ,
          HarshBrakingComponent ,
          AccelerationComponent ,
          BrakingComponent ,
          CorneringComponent ,
          AccelerationLowComponent ,
          BrakingLowComponent ,
          CorneringLowComponent ,
          AccelerationHighComponent ,
          BrakingHighComponent ,
          CorneringHighComponent ,
          ManoeuvresLowComponent ,
          ManoeuvresMedComponent ,
          FuelMult ,
          CreationDateTime ,
          ClosureDateTime ,
          SweetSpotColour ,
          SweetSpotMix ,
          OverRevWithFuelColour ,
          OverRevWithFuelMix ,
          TopGearColour ,
          TopGearMix ,
          CruiseColour ,
          CruiseMix ,
          CruiseInTopGearsColour ,
          CruiseInTopGearsMix ,
          CoastInGearColour ,
          CoastInGearMix ,
          IdleColour ,
          IdleMix ,
          EngineServiceBrakeColour ,
          EngineServiceBrakeMix ,
          OverRevWithoutFuelColour ,
          OverRevWithoutFuelMix ,
          RopColour ,
          RopMix ,
          Rop2Colour ,
          Rop2Mix ,
          OverSpeedColour ,
          OverSpeedMix ,
          OverSpeedHighColour ,
          OverSpeedHighMix ,
          IVHOverSpeedColour ,
          IVHOverSpeedMix ,

		  SpeedGaugeColour,
		  SpeedGaugeMix,

          CoastOutOfGearColour ,
          CoastOutOfGearMix ,
          HarshBrakingColour ,
          HarshBrakingMix ,
          EfficiencyColour ,
          EfficiencyMix ,
          SafetyColour ,
          SafetyMix ,
          KPLColour ,
          KPLMix ,
          Co2Colour ,
          Co2Mix ,
          OverSpeedDistanceColour ,
          OverSpeedDistanceMix ,
          AccelerationColour ,
          AccelerationMix ,
          BrakingColour ,
          BrakingMix ,
          CorneringColour ,
          CorneringMix ,
          AccelerationLowColour ,
          AccelerationLowMix ,
          BrakingLowColour ,
          BrakingLowMix ,
          CorneringLowColour ,
          CorneringLowMix ,
          AccelerationHighColour ,
          AccelerationHighMix ,
          BrakingHighColour ,
          BrakingHighMix ,
          CorneringHighColour ,
          CorneringHighMix ,
          ManoeuvresLowColour ,
          ManoeuvresLowMix ,
          ManoeuvresMedColour ,
          ManoeuvresMedMix ,
          CruiseTopGearRatioColour ,
          CruiseTopGearRatioMix ,
          OverRevCountColour ,
          OverRevCountMix ,
          PtoColour ,
          PtoMix,
		  CruiseOverspeed,
		  CruiseOverspeedComponent,
		  CruiseOverspeedColour,
		  CruiseOverspeedMix,
		  TopGearOverspeed,
		  TopGearOverspeedComponent,
		  TopGearOverspeedColour,
		  TopGearOverspeedMix,
		  FuelWastageCost,
		  FuelWastageCostColour,
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
		  OverspeedCountColour,
		  OverspeedCountMix,
		  OverspeedHighCountColour, 
		  OverspeedHighCountMix,
		  StabilityControlColour, 
		  StabilityControlMix,
		  CollisionWarningLowColour, 
		  CollisionWarningLowMix,
		  CollisionWarningMedColour, 
		  CollisionWarningMedMix,
		  CollisionWarningHighColour, 
		  CollisionWarningHighMix,
		  LaneDepartureDisableColour, 
		  LaneDepartureDisableMix,
		  LaneDepartureLeftRightColour, 
		  LaneDepartureLeftRightMix,
		  SweetSpotTimeColour, 
		  SweetSpotTimeMix,
		  OverRevTimeColour, 
		  OverRevTimeMix,
		  TopGearTimeColour, 
		  TopGearTimeMix,
		  FatigueColour, 
		  FatigueMix,
		  DistractionColour, 
		  DistractionMix
        )
SELECT @cid, --CoachingSessionId
	--IDs
	PeriodNum,
	PeriodStartDate,
	PeriodEndDate,
	VehicleId,
	DriverId,

	--Scores
	[Safety],
	Efficiency,
	FuelEcon,

	--Common
	TotalDrivingDistance,
	TotalTime,

	--Coaching Figures
	Coached,
	NotRequired,
	NotCoached,

	--Safety values
	EngineServiceBrake,
	OverRevWithoutFuel,
	OverSpeed,
	OverSpeedHigh,
	IVHOverSpeed,

	SpeedGauge,

	CoastOutOfGear,
	HarshBraking,
	Rop,
	Rop2,
	Acceleration,
	Braking,
	Cornering,
	ManoeuvresLow,
	ManoeuvresMed,
	AccelerationHigh,
	BrakingHigh,
	CorneringHigh,

	OverRevCount,
	
	--Efficiency Values
	SweetSpot,
	OverRevWithFuel,
	TopGear,
	Cruise,
	CruiseInTopGears,
	CruiseTopGearRatio,
	CoastInGear,
	Idle,
	Co2,
	Pto,

	-- Component values
	SweetSpotComponent,
	OverRevWithFuelComponent,
	TopGearComponent,
	CruiseComponent,
	CruiseInTopGearsComponent,
	CruiseTopGearRatioComponent,
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
	CoastInGearComponent,
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

	--Technical fields
	FuelMult,
	PeriodStartDate AS CreationDateTime,
	PeriodEndDate AS ClosureDateTime,

	-- Colour columns corresponding to data columns above
	SweetSpotColour, SweetSpotMix,
	OverRevWithFuelColour, OverRevWithFuelMix,
	TopGearColour, TopGearMix,
	CruiseColour, CruiseMix,
	CruiseInTopGearsColour, CruiseInTopGearsMix,
	CoastInGearColour, CoastInGearMix,
	IdleColour, IdleMix,
	EngineServiceBrakeColour, EngineServiceBrakeMix,
	OverRevWithoutFuelColour, OverRevWithoutFuelMix,
	RopColour, RopMix,
	Rop2Colour, Rop2Mix,
	OverSpeedColour, OverSpeedMix,
	OverSpeedHighColour, OverSpeedHighMix,
	IVHOverSpeedColour, IVHOverSpeedMix,

	SpeedGaugeColour, SpeedGaugeMix,

	CoastOutOfGearColour, CoastOutOfGearMix,
	HarshBrakingColour, HarshBrakingMix,
	EfficiencyColour, EfficiencyMix,
	SafetyColour, SafetyMix,
	KPLColour, KPLMix,
	Co2Colour, Co2Mix,
	OverSpeedDistanceColour, OverSpeedDistanceMix,
	AccelerationColour, AccelerationMix,
	BrakingColour, BrakingMix,
	CorneringColour, CorneringMix,
	AccelerationLowColour, AccelerationLowMix,
	BrakingLowColour, BrakingLowMix,
	CorneringLowColour, CorneringLowMix,
	AccelerationHighColour, AccelerationHighMix,
	BrakingHighColour, BrakingHighMix,
	CorneringHighColour, CorneringHighMix,
	ManoeuvresLowColour, ManoeuvresLowMix,
	ManoeuvresMedColour, ManoeuvresMedMix,
	CruiseTopGearRatioColour, CruiseTopGearRatioMix,
	OverRevCountColour, OverRevCountMix,
	PtoColour, PtoMix,
	CruiseOverspeed,
	CruiseOverspeedComponent,
	CruiseOverspeedColour,
	CruiseOverspeedMix,
	TopGearOverspeed,
	TopGearOverspeedComponent,
	TopGearOverspeedColour,
	TopGearOverspeedMix,
	FuelWastageCost,
	FuelWastageCostColour,
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
	OverspeedCountColour,
	OverspeedCountMix,
	OverspeedHighCountColour, 
	OverspeedHighCountMix,
	StabilityControlColour, 
	StabilityControlMix,
	CollisionWarningLowColour, 
	CollisionWarningLowMix,
	CollisionWarningMedColour, 
	CollisionWarningMedMix,
	CollisionWarningHighColour, 
	CollisionWarningHighMix,
	LaneDepartureDisableColour, 
	LaneDepartureDisableMix,
	LaneDepartureLeftRightColour, 
	LaneDepartureLeftRightMix,
	SweetSpotTimeColour, 
	SweetSpotTimeMix,
	OverRevTimeColour, 
	OverRevTimeMix,
	TopGearTimeColour, 
	TopGearTimeMix,
	FatigueColour, 
	FatigueMix,
	DistractionColour, 
	DistractionMix

FROM @Results r
WHERE (PeriodNum IS NOT NULL AND DriverId IN (SELECT VALUE FROM Split(@dids, ',')) AND VehicleId IS NULL) -- detailed driver rows by week
   OR (PeriodNum IS NULL AND DriverId IN (SELECT VALUE FROM Split(@dids, ',')) AND VehicleId IS NULL) -- Driver Average
   OR (PeriodNum IS NULL AND DriverId IS NULL AND VehicleId IS NULL) -- Fleet Average


SELECT	  cs.CoachingSessionId,
		  cs.CoachingStatusId,
		  cs.LastOperation AS CoachingDate,
		  PeriodNum ,
          PeriodStartDate ,
          PeriodEndDate ,
          VehicleId ,
          DriverId ,
          Safety ,
          Efficiency ,
          FuelEcon ,
          TotalDrivingDistance ,
          TotalTime ,
          Coached ,
          NotRequired ,
          NotCoached ,
          EngineServiceBrake ,
          OverRevWithoutFuel ,
          OverSpeed ,
          OverSpeedHigh ,
          IVHOverSpeed ,

		  SpeedGauge,

          CoastOutOfGear ,
          HarshBraking ,
          Rop ,
          Rop2 ,
          Acceleration ,
          Braking ,
          Cornering ,
          ManoeuvresLow ,
          ManoeuvresMed ,
		  CruiseOverspeed ,
		  TopGearOverspeed ,
		  FuelwastageCost ,
          AccelerationHigh ,
          BrakingHigh ,
          CorneringHigh ,
          OverRevCount ,
          SweetSpot ,
          OverRevWithFuel ,
          TopGear ,
          Cruise ,
          CruiseInTopGears ,
          CruiseTopGearRatio ,
          CoastInGear ,
          Idle ,
          Co2 ,
          Pto ,
		  OverspeedCount ,
		  OverspeedHighCount ,
		  StabilityControl ,
		  CollisionWarningLow ,
		  CollisionWarningMed ,
		  CollisionWarningHigh ,
		  LaneDepartureDisable ,
		  LaneDepartureLeftRight ,
		  SweetSpotTime ,
		  OverRevTime ,
		  TopGearTime ,
		  Fatigue ,
		  Distraction ,
          SweetSpotComponent ,
          OverRevWithFuelComponent ,
          TopGearComponent ,
          CruiseComponent ,
          CruiseInTopGearsComponent ,
          CruiseTopGearRatioComponent ,
          IdleComponent ,
          EngineServiceBrakeComponent ,
          OverRevWithoutFuelComponent ,
          RopComponent ,
          Rop2Component ,
          OverSpeedComponent ,
          OverSpeedHighComponent ,
          OverSpeedDistanceComponent ,
          IVHOverSpeedComponent ,

		  SpeedGaugeComponent,

          CoastOutOfGearComponent ,
          CoastInGearComponent ,
          HarshBrakingComponent ,
          AccelerationComponent ,
          BrakingComponent ,
          CorneringComponent ,
          AccelerationLowComponent ,
          BrakingLowComponent ,
          CorneringLowComponent ,
          AccelerationHighComponent ,
          BrakingHighComponent ,
          CorneringHighComponent ,
          ManoeuvresLowComponent ,
          ManoeuvresMedComponent ,
		  CruiseOverspeedComponent ,
		  TopGearOverspeedComponent ,
		  OverspeedCountComponent ,
		  OverspeedHighCountComponent ,
		  StabilityControlComponent ,
		  CollisionWarningLowComponent ,
		  CollisionWarningMedComponent ,
		  CollisionWarningHighComponent ,
		  LaneDepartureDisableComponent ,
		  LaneDepartureLeftRightComponent ,
		  SweetSpotTimeComponent ,
		  OverRevTimeComponent ,
		  TopGearTimeComponent ,
		  FatigueComponent ,
		  DistractionComponent ,
		  FuelMult ,
          CreationDateTime ,
          ClosureDateTime ,
          SweetSpotColour ,
          SweetSpotMix ,
          OverRevWithFuelColour ,
          OverRevWithFuelMix ,
          TopGearColour ,
          TopGearMix ,
          CruiseColour ,
          CruiseMix ,
          CruiseInTopGearsColour ,
          CruiseInTopGearsMix ,
          CoastInGearColour ,
          CoastInGearMix ,
          IdleColour ,
          IdleMix ,
          EngineServiceBrakeColour ,
          EngineServiceBrakeMix ,
          OverRevWithoutFuelColour ,
          OverRevWithoutFuelMix ,
          RopColour ,
          RopMix ,
          Rop2Colour ,
          Rop2Mix ,
          OverSpeedColour ,
          OverSpeedMix ,
          OverSpeedHighColour ,
          OverSpeedHighMix ,
          IVHOverSpeedColour ,
          IVHOverSpeedMix ,

		  SpeedGaugeColour,
		  SpeedGaugeMix,

          CoastOutOfGearColour ,
          CoastOutOfGearMix ,
          HarshBrakingColour ,
          HarshBrakingMix ,
          EfficiencyColour ,
          EfficiencyMix ,
          SafetyColour ,
          SafetyMix ,
          KPLColour ,
          KPLMix ,
          Co2Colour ,
          Co2Mix ,
          OverSpeedDistanceColour ,
          OverSpeedDistanceMix ,
          AccelerationColour ,
          AccelerationMix ,
          BrakingColour ,
          BrakingMix ,
          CorneringColour ,
          CorneringMix ,
          AccelerationLowColour ,
          AccelerationLowMix ,
          BrakingLowColour ,
          BrakingLowMix ,
          CorneringLowColour ,
          CorneringLowMix ,
          AccelerationHighColour ,
          AccelerationHighMix ,
          BrakingHighColour ,
          BrakingHighMix ,
          CorneringHighColour ,
          CorneringHighMix ,
          ManoeuvresLowColour ,
          ManoeuvresLowMix ,
          ManoeuvresMedColour ,
          ManoeuvresMedMix ,
		  CruiseOverspeedColour,
		  CruiseOverspeedMix ,
		  TopGearOverspeedColour ,
		  TopGearOverspeedMix ,
		  FuelWastageCostColour ,
          CruiseTopGearRatioColour ,
          CruiseTopGearRatioMix ,
          OverRevCountColour ,
          OverRevCountMix ,
          PtoColour ,
          PtoMix ,
		  OverspeedCountColour ,
		  OverspeedCountMix ,
		  OverspeedHighCountColour ,
		  OverspeedHighCountMix ,
		  StabilityControlColour ,
		  StabilityControlMix ,
		  CollisionWarningLowColour ,
		  CollisionWarningLowMix ,
		  CollisionWarningMedColour ,
		  CollisionWarningMedMix ,
		  CollisionWarningHighColour ,
		  CollisionWarningHighMix ,
		  LaneDepartureDisableColour ,
		  LaneDepartureDisableMix ,
		  LaneDepartureLeftRightColour ,
		  LaneDepartureLeftRightMix ,
		  SweetSpotTimeColour ,
		  SweetSpotTimeMix ,
		  OverRevTimeColour ,
		  OverRevTimeMix ,
		  TopGearTimeColour ,
		  TopGearTimeMix ,
		  FatigueColour ,
		  FatigueMix ,
		  DistractionColour ,
		  DistractionMix
FROM dbo.CAM_Coaching c
	INNER JOIN dbo.CAM_CoachingSession cs ON cs.CoachingSessionId = c.CoachingSessionId
WHERE cs.CoachingSessionId = @cid

SELECT DriverId ,
       DriverIntId ,
       Number ,
       NumberAlternate ,
       NumberAlternate2 ,
       FirstName ,
       Surname ,
       MiddleNames ,
       LastOperation ,
       Archived ,
       LanguageCultureId ,
       LicenceNumber ,
       IssuingAuthority ,
       LicenceExpiry ,
       MedicalCertExpiry
FROM dbo.Driver
WHERE DriverId IN (SELECT Value FROM dbo.Split(@dids,','))






GO
