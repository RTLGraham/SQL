SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_Report_Combined_Linq]
(
	@dids varchar(max),
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER
)
AS

--declare	@dids varchar(max),
--		@sdate datetime,
--		@edate datetime,
--		@uid UNIQUEIDENTIFIER,
--		@rprtcfgid UNIQUEIDENTIFIER

--SET @dids = N'FB52A2E1-A64D-4F17-820F-DD328E5BD001'
--SET @sdate = '2017-07-17 00:00'
--SET @edate = '2017-08-20 23:59'
--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
--SET	@rprtcfgid = N'E671E529-196F-4C6A-83FE-5F51B1257862'

DECLARE @Results TABLE
(
		-- Week identification columns
 		WeekNum INT,
		WeekStartDate DATETIME,
		WeekEndDate DATETIME,
		
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

		ReportConfigId UNIQUEIDENTIFIER,
 		
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
		FuelwastageCost FLOAT,
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
		CoastOutOfGearComponent	FLOAT,
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
		CruiseOverSpeedComponent FLOAT,
		TopGearOverspeedComponent FLOAT,
		
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
		FuelMult FLOAT
)

-- Driver values by week and for period
INSERT INTO @Results
EXEC dbo.proc_ReportByVehicleConfigIdByPeriod
	NULL, @dids, @sdate, @edate, @uid, @rprtcfgid, NULL

DELETE FROM @Results
WHERE WeekNum IS NULL AND DriverId IS NULL AND VehicleId IS NULL

-- Fleet averages
INSERT INTO @Results
EXEC dbo.proc_ReportByVehicleConfigId_Fleet
	@sdate, @edate, @uid, @rprtcfgid  -- pass NULLs so that the Fleet average for all vehicles will be calculated

-- Now calculate temperature score data
DECLARE	@TemperatureData TABLE
(
	DriverId UNIQUEIDENTIFIER,
	PeriodId INT,
	OutsideTime BIGINT,
	OverTempDuration BIGINT,
	OverTemp2Duration BIGINT,
	OverTemp3Duration BIGINT
)

-- Values by period
INSERT INTO @TemperatureData
EXEC dbo.proc_CombinedTemperatureScoreByPeriod
	@dids, @sdate, @edate, NULL, @uid

-- Fleet values
INSERT INTO @TemperatureData
EXEC dbo.proc_CombinedTemperatureScoreFleet
	NULL, @sdate, @edate, NULL, @uid
		
SELECT 	--IDs
	WeekNum,
	r.DriverId,
	--Scores
	[Safety],
	Efficiency,
	FuelEcon,

	--Common
	TotalDrivingDistance,
	TotalTime,

	--Safety values
	EngineServiceBrake,
	OverRevWithoutFuel,
	OverSpeed,
	OverSpeedHigh,
	IVHOverSpeed,
	CoastOutOfGear,
	HarshBraking,
	Rop,
	Rop2,
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

	OverRevCount,

	--Safety components
	EngineServiceBrakeComponent,
	OverRevWithoutFuelComponent,
	OverSpeedComponent,
	OverSpeedHighComponent,
	IVHOverSpeedComponent,
	CoastOutOfGearComponent,
	HarshBrakingComponent,
	RopComponent,
	Rop2Component,
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
	CruiseOverspeed,
	TopGearOverspeed,
	
	--Efficiency components
	SweetSpotComponent,
	OverRevWithFuelComponent,
	TopGearComponent,
	IdleComponent,
	CruiseComponent,
	CruiseInTopGearsComponent,
	CruiseTopGearRatioComponent,
	CoastInGearComponent,
	CruiseOverspeedComponent,
	TopGearOverspeedComponent,

	--Technical fields
	FuelMult,
	WeekStartDate AS CreationDateTime,
	WeekEndDate AS ClosureDateTime,

	-- Additional Temperature Score Data
	1.0 - (CAST(t.OverTempDuration AS FLOAT) / CAST(t.OutsideTime AS FLOAT)) AS TScore
	
FROM @Results r
LEFT JOIN @TemperatureData t ON ISNULL(r.WeekNum, 0) = ISNULL(t.PeriodId, 0) AND ISNULL(r.DriverId, '00000000-0000-0000-0000-000000000000') = ISNULL(t.DriverId, '00000000-0000-0000-0000-000000000000')
WHERE (WeekNum IS NOT NULL AND r.DriverId IN (SELECT VALUE FROM Split(@dids, ',')) AND VehicleId IS NULL) -- detailed driver rows by week
   OR (Weeknum IS NULL AND r.DriverId IN (SELECT VALUE FROM Split(@dids, ',')) AND VehicleId IS NULL) -- Driver Average
   OR (WeekNum IS NULL AND r.DriverId IS NULL AND VehicleId IS NULL) -- Fleet Average
 
GO
