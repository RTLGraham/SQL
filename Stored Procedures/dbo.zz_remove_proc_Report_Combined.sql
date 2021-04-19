SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[zz_remove_proc_Report_Combined]
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
--
--SET	@dids = N'983AEB57-6600-42C3-BA24-8D307F5AD57F'
--SET	@sdate = '2012-10-08 00:00'
--SET	@edate = '2012-11-11 23:59'
--SET	@uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
--SET	@rprtcfgid = N'583B4D46-F49F-4C93-B55C-4E0BC1E2A96C'

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
 		
 		-- Data columns with corresponding colours below 
		SweetSpot FLOAT, 
		OverRevWithFuel FLOAT, 
		TopGear FLOAT, 
		Cruise FLOAT, 
		CoastInGear FLOAT, 
		Idle FLOAT, 
		EngineServiceBrake FLOAT, 
		OverRevWithoutFuel FLOAT, 
		Rop FLOAT, 
		OverSpeed FLOAT,
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
		
		-- Component Columns
		SweetSpotComponent FLOAT,
		OverRevWithFuelComponent FLOAT,
		TopGearComponent FLOAT,
		CruiseComponent FLOAT,
		CruiseTopGearRatioComponent FLOAT,
		IdleComponent FLOAT,
		EngineServiceBrakeComponent FLOAT,
		OverRevWithoutFuelComponent FLOAT,
		RopComponent FLOAT,
		OverSpeedComponent FLOAT,
		OverSpeedDistanceComponent FLOAT,
		IVHOverSpeedComponent FLOAT,
		CoastOutOfGearComponent	FLOAT,
		CoastInGearComponent FLOAT,
		HarshBrakingComponent FLOAT,
		AccelerationComponent FLOAT,
		BrakingComponent FLOAT,
		CorneringComponent FLOAT,
		
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

		-- Colour columns corresponding to data columns above
		SweetSpotColour VARCHAR(MAX),
		OverRevWithFuelColour VARCHAR(MAX),
		TopGearColour VARCHAR(MAX),
		CruiseColour VARCHAR(MAX),
		CoastInGearColour VARCHAR(MAX),
		IdleColour VARCHAR(MAX),
		EngineServiceBrakeColour VARCHAR(MAX),
		OverRevWithoutFuelColour VARCHAR(MAX),
		RopColour VARCHAR(MAX),
		OverSpeedColour VARCHAR(MAX), 
		IVHOverSpeedColour VARCHAR(MAX),
		CoastOutOfGearColour VARCHAR(MAX),
		HarshBrakingColour VARCHAR(MAX),
		EfficiencyColour VARCHAR(MAX),
		SafetyColour VARCHAR(MAX),
		KPLColour VARCHAR(MAX),
		Co2Colour VARCHAR(MAX),
		OverSpeedDistanceColour VARCHAR(MAX),
		AccelerationColour VARCHAR(MAX),
		BrakingColour VARCHAR(MAX),
		CorneringColour VARCHAR(MAX),
		CruiseTopGearRatioColour VARCHAR(MAX),
		OverRevCountColour VARCHAR(MAX),
		PtoColour VARCHAR(MAX)
)

-- Driver values by week and for period
INSERT INTO @Results
EXEC dbo.proc_ReportByConfigIdByWeek
	NULL, @dids, @sdate, @edate, @uid, @rprtcfgid

DELETE FROM @Results
WHERE WeekNum IS NULL AND DriverId IS NULL AND VehicleId IS NULL

-- Fleet averages
INSERT INTO @Results
EXEC dbo.proc_ReportByConfigId_Fleet
	@sdate, @edate, @uid, @rprtcfgid  -- pass NULLs so that the Fleet average for all vehicles will be calculated
		
SELECT 	--IDs
	WeekNum,
	DriverId,
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
	IVHOverSpeed,
	CoastOutOfGear,
	HarshBraking,
	Rop,
	Acceleration,
	Braking,
	Cornering,
	OverRevCount,

	--Safety components
	EngineServiceBrakeComponent,
	OverRevWithoutFuelComponent,
	OverSpeedComponent,
	IVHOverSpeedComponent,
	CoastOutOfGearComponent,
	HarshBrakingComponent,
	RopComponent,
	AccelerationComponent,
	BrakingComponent,
	CorneringComponent,
	
	--Efficiency Values
	SweetSpot,
	OverRevWithFuel,
	TopGear,
	Cruise,
	CruiseTopGearRatio,
	CoastInGear,
	Idle,
	Co2,
	Pto,
	
	--Efficiency components
	SweetSpotComponent,
	OverRevWithFuelComponent,
	TopGearComponent,
	IdleComponent,
	CruiseComponent,
	CruiseTopGearRatioComponent,
	CoastInGearComponent,

	--Technical fields
	FuelMult,
	WeekStartDate AS CreationDateTime,
	WeekEndDate AS ClosureDateTime
	
FROM @Results
WHERE (WeekNum IS NOT NULL AND DriverId IN (SELECT VALUE FROM Split(@dids, ',')) AND VehicleId IS NULL) -- detailed driver rows by week
   OR (Weeknum IS NULL AND DriverId IN (SELECT VALUE FROM Split(@dids, ',')) AND VehicleId IS NULL) -- Driver Average
   OR (WeekNum IS NULL AND DriverId IS NULL AND VehicleId IS NULL) -- Fleet Average
   
-- Return Target values as Second ResultSet
SELECT 
	NULL AS WeekNum,
	NULL AS DriverId,

	--Scores
	[dbo].GetTargetByIndicatorConfigId(15, @rprtcfgid, @uid) AS [Safety],
	[dbo].GetTargetByIndicatorConfigId(14, @rprtcfgid, @uid) AS Efficiency,
	[dbo].GetTargetByIndicatorConfigId(16, @rprtcfgid, @uid) AS FuelEcon,

	--Common
	NULL AS TotalDrivingDistance,
	NULL AS TotalTime,

	--Safety values
	[dbo].GetTargetByIndicatorConfigId(7, @rprtcfgid, @uid) / 100 as EngineServiceBrake,
	[dbo].GetTargetByIndicatorConfigId(8, @rprtcfgid, @uid) / 100 as OverRevWithoutFuel,
	[dbo].GetTargetByIndicatorConfigId(10, @rprtcfgid, @uid) / 100 as OverSpeed,
	[dbo].GetTargetByIndicatorConfigId(30, @rprtcfgid, @uid) / 100 as IVHOverSpeed,
	[dbo].GetTargetByIndicatorConfigId(11, @rprtcfgid, @uid) / 100 as CoastOutOfGear,
	[dbo].GetTargetByIndicatorConfigId(12, @rprtcfgid, @uid) as HarshBraking,
	[dbo].GetTargetByIndicatorConfigId(9, @rprtcfgid, @uid) as Rop,
	[dbo].GetTargetByIndicatorConfigId(22, @rprtcfgid, @uid) as Acceleration,
	[dbo].GetTargetByIndicatorConfigId(23, @rprtcfgid, @uid) as Braking,
	[dbo].GetTargetByIndicatorConfigId(24, @rprtcfgid, @uid) as Cornering,
	[dbo].GetTargetByIndicatorConfigId(28, @rprtcfgid, @uid) as OverRevCount,
	
	--Safety components
	NULL AS EngineServiceBrakeComponent,
	NULL AS OverRevWithoutFuelComponent,
	NULL AS OverSpeedComponent,
	NULL AS IVHOverSpeedComponent,
	NULL AS CoastOutOfGearComponent,
	NULL AS HarshBrakingComponent,
	NULL AS RopComponent,
	NULL AS AccelerationComponent,
	NULL AS BrakingComponent,
	NULL AS CorneringComponent,

	--Efficiency Values
	[dbo].GetTargetByIndicatorConfigId(1, @rprtcfgid, @uid) / 100 AS SweetSpot,
	[dbo].GetTargetByIndicatorConfigId(2, @rprtcfgid, @uid) / 100 AS OverRevWithFuel,
	[dbo].GetTargetByIndicatorConfigId(3, @rprtcfgid, @uid) / 100 AS TopGear,
	[dbo].GetTargetByIndicatorConfigId(4, @rprtcfgid, @uid) / 100 AS Cruise,
	[dbo].GetTargetByIndicatorConfigId(25, @rprtcfgid, @uid) / 100 AS CruiseTopGearRatio,
	[dbo].GetTargetByIndicatorConfigId(5, @rprtcfgid, @uid) / 100 AS CoastInGear,
	[dbo].GetTargetByIndicatorConfigId(6, @rprtcfgid, @uid) / 100 AS Idle,
	NULL AS Co2,
	NULL AS Pto,
	
	--Efficiency components
	NULL AS SweetSpotComponent,
	NULL AS OverRevWithFuelComponent,
	NULL AS TopGearComponent,
	NULL AS IdleComponent,
	NULL AS CruiseComponent,
	NULL AS CruiseTopGearRatioComponent,
	NULL AS CoastInGearComponent,

	--Technical fields
	NULL AS FuelMult,
	NULL AS CreationDateTime,
	NULL AS ClosureDateTime

GO
