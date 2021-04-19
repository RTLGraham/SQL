SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_Report_Combined_RS]
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

--SET @dids = N'1b5600d4-85ae-4a78-b071-2ee555eb3300'
--SET @sdate = '2020-02-04 00:00'
--SET @edate = '2020-02-04 23:59'
--SET @uid = N'fe90ce6b-0973-4d7b-8157-1c89cfa422f5'
--SET	@rprtcfgid = N'e671e529-196f-4c6a-83fe-5f51b1257862'

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
		FuelWastageCost FLOAT,
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
WHERE WeekNum IS NULL AND DriverId IS NULL AND VehicleId IS NULL;

-- Fleet averages
INSERT INTO @Results
EXEC dbo.proc_ReportByvehicleConfigId_Fleet
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

SELECT 	DISTINCT
          --IDs
	r.WeekNum,
	r.DriverId,
    r.DisplayName AS DriverName,

    CONVERT(nchar(6), r.WeekStartDate, 106) + ' to ' + CONVERT(nchar(6), r.WeekEndDate, 106) AS WeekStr,

	--Scores
	r.[Safety],
	r.Efficiency,
	ISNULL(r.FuelEcon, 0) AS FuelEcon,

	--Common
	r.TotalDrivingDistance,
	r.TotalTime,

	--Safety values
	r.EngineServiceBrake,
	r.OverRevWithoutFuel,
	r.OverSpeed,
	r.OverSpeedHigh,
	r.IVHOverSpeed,
	r.CoastOutOfGear,
    r.Rop AS RopCount,
	r.Rop2 AS Rop2Count,
    r.HarshBraking,
	r.Acceleration,
	r.Braking,
	r.Cornering,
	r.AccelerationLow, 
	r.BrakingLow, 
	r.CorneringLow,
	r.AccelerationHigh, 
	r.BrakingHigh, 
	r.CorneringHigh,
	r.ManoeuvresLow,
	r.ManoeuvresMed,
	r.OverRevCount,
	
          --Safety components
	r.EngineServiceBrakeComponent,
	r.OverRevWithoutFuelComponent,
	r.OverSpeedComponent,
	r.OverSpeedHighComponent,
	r.IVHOverSpeedComponent,
	r.CoastOutOfGearComponent,
    r.RopComponent AS RopCountComponent,
	r.Rop2Component AS Rop2CountComponent,
    r.HarshBrakingComponent,
	r.AccelerationComponent,
	r.BrakingComponent,
	r.CorneringComponent,
	r.AccelerationLowComponent, 
	r.BrakingLowComponent, 
	r.CorneringLowComponent,
	r.AccelerationHighComponent, 
	r.BrakingHighComponent, 
	r.CorneringHighComponent,
	r.ManoeuvresLowComponent,
	r.ManoeuvresMedComponent,
	
	--Efficiency Values
	r.SweetSpot,
	r.OverRevWithFuel,
	r.TopGear,
	r.Cruise,
	r.CruiseTopGearRatio,
	r.CruiseInTopGears,
	r.CoastInGear,
	r.Idle,
	r.Co2,
	r.Pto,
	r.TopGearOverspeed,
	r.CruiseOverspeed,
	r.FuelWastageCost,
	
          --Efficiency components
	r.SweetSpotComponent,
	r.OverRevWithFuelComponent,
	r.TopGearComponent,
	r.IdleComponent,
	r.CruiseComponent,
	r.CruiseInTopGearsComponent,
	r.TopGearOverspeedComponent,
	r.CruiseOverspeedComponent,

	--Technical fields
	r.FuelMult,
	r.WeekStartDate AS CreationDateTime,
	r.WeekEndDate AS ClosureDateTime,

	--Temperature fields
	1.0 - (CAST(tr.OverTempDuration AS FLOAT) / CAST(tr.OutsideTime AS FLOAT)) AS TScore,

	--Driver Scores
	d.[Safety] AS SafetyDriverAverage,
	d.Efficiency AS EfficiencyDriverAverage,
	ISNULL(d.FuelEcon, 0) AS FuelEconomyDriverAverage,

	--Driver Common
	d.TotalDrivingDistance AS TotalDrivingDistanceDriverAverage,
	d.TotalTime AS TotalTimeDriverAverage,

	--Driver Safety values
	d.EngineServiceBrake AS EngineServiceBrakeDriverAverage,
	d.OverRevWithoutFuel AS OverRevWithoutFuelDriverAverage,
	d.OverSpeed AS OverSpeedDriverAverage,
	d.OverSpeedHigh AS OverSpeedHighDriverAverage,
	d.IVHOverSpeed AS IVHOverSpeedDriverAverage,
	d.CoastOutOfGear AS CoastOutOfGearDriverAverage,
    d.Rop AS RopCountDriverAverage,
    d.Rop2 AS Rop2CountDriverAverage,
    d.HarshBraking AS HarshBrakingDriverAverage,
	d.Acceleration AS AccelerationDriverAverage,
	d.Braking AS BrakingDriverAverage,
	d.Cornering AS CorneringDriverAverage,
	d.AccelerationLow AS AccelerationLowDriverAverage, 
	d.BrakingLow AS BrakingLowDriverAverage, 
	d.CorneringLow AS CorneringLowDriverAverage,
	d.AccelerationHigh AS AccelerationHighDriverAverage, 
	d.BrakingHigh AS BrakingHighDriverAverage, 
	d.CorneringHigh AS CorneringHighDriverAverage,
	d.ManoeuvresLow AS ManoeuvresLowDriverAverage,
	d.ManoeuvresMed AS ManoeuvresMedDriverAverage,
	d.OverRevCount AS OverRevCountDriverAverage,
	
	--Driver Efficiency Values
	d.SweetSpot AS SweetSpotDriverAverage,
	d.OverRevWithFuel AS OverRevWithFuelDriverAverage,
	d.TopGear AS TopGearDriverAverage,
	d.Cruise AS CruiseDriverAverage,
	d.CruiseTopGearRatio AS CruiseTopGearRatioDriverAverage,
	d.CruiseInTopGears AS CruiseInTopGearsDriverAverage,
	d.CoastInGear AS CoastInGearDriverAverage,
	d.Idle AS IdleDriverAverage,
	d.Co2 AS Co2DriverAverage,
	d.Pto AS PtoDriverAverage,
	d.TopGearOverspeed AS TopGearOverspeedDriverAverage,
	d.CruiseOverspeed AS CruiseOverspeedDriverAverage,
	d.FuelWastageCost AS FuelWastageCostDriverAverage,

	--Driver Temperature Values
	1.0 - (CAST(td.OverTempDuration AS FLOAT) / CAST(td.OutsideTime AS FLOAT)) AS TScoreDriverAverage,
	
	--Fleet Scores
	f.[Safety] AS SafetyAverage,
	f.Efficiency AS EfficiencyAverage,
	ISNULL(f.FuelEcon, 0) AS FuelEconomyAverage,

	--Fleet Common
	f.TotalDrivingDistance AS TotalDrivingDistanceAverage,
	f.TotalTime AS TotalTimeAverage,

	--Fleet Safety values
	f.EngineServiceBrake AS EngineServiceBrakeAverage,
	f.OverRevWithoutFuel AS OverRevWithoutFuelAverage,
	f.OverSpeed AS OverSpeedAverage,
	f.OverSpeedHigh AS OverSpeedHighAverage,
	f.IVHOverSpeed AS IVHOverSpeedAverage,
	f.CoastOutOfGear AS CoastOutOfGearAverage,
    f.Rop AS RopCountAverage,
    f.Rop2 AS Rop2CountAverage,
    f.HarshBraking AS HarshBrakingAverage,
	f.Acceleration AS AccelerationAverage,
	f.Braking AS BrakingAverage,
	f.Cornering AS CorneringAverage,
	f.AccelerationLow AS AccelerationLowAverage, 
	f.BrakingLow AS BrakingLowAverage, 
	f.CorneringLow AS CorneringLowAverage,
	f.AccelerationHigh AS AccelerationHighAverage, 
	f.BrakingHigh AS BrakingHighAverage, 
	f.CorneringHigh AS CorneringHighAverage,
	f.ManoeuvresLow AS ManoeuvresLowAverage,
	f.ManoeuvresMed AS ManoeuvresMedAverage,
	f.OverRevCount AS OverRevCountAverage,
	
	--Fleet Efficiency Values
	f.SweetSpot AS SweetSpotAverage,
	f.OverRevWithFuel AS OverRevWithFuelAverage,
	f.TopGear AS TopGearAverage,
	f.Cruise AS CruiseAverage,
	f.CruiseTopGearRatio AS CruiseTopGearRatioAverage,
	f.CruiseInTopGears AS CruiseInTopGearsAverage,
	f.CoastInGear AS CoastInGearAverage,
	f.Idle AS IdleAverage,
	f.Co2 AS Co2Average,
	f.Pto AS PtoAverage,
	f.TopGearOverspeed AS TopGearOverspeedAverage,
	f.CruiseOverspeed AS CruiseOverspeedAverage,
	f.FuelWastageCost AS FuelWastageCostAverage,

	--Fleet Temperature Values
	(CASE WHEN tf.OutsideTime = 0 THEN 0 ELSE 1.0 - (CAST(tf.OverTempDuration AS FLOAT) / CAST(tf.OutsideTime AS FLOAT)) END) AS TScoreAverage,
	--CAST(tf.OutsideTime AS FLOAT) AS TScoreAverage,

    --Units
    r.DistanceUnit,
    r.FuelUnit,
    r.Co2Unit,
    r.FuelMult,

	--Data view
    ISNULL(r.FuelEcon - f.FuelEcon, 0) AS FuelEconomyChart,
	r.Efficiency - f.Efficiency AS EfficiencyChart,
	r.[Safety] - f.[Safety] AS SafetyChart,

          --Is Better
          CASE
                    WHEN d.[Safety] > f.[Safety] THEN 'DarkGreen'
                    WHEN d.[Safety] < f.[Safety] THEN 'Red'
                    ELSE 'Black'
          END AS SafetyScoreBetter,
          CASE
                    WHEN d.Efficiency > f.Efficiency THEN 'DarkGreen'
                    WHEN d.Efficiency < f.Efficiency THEN 'Red'
                    ELSE 'Black'
          END AS EfficiencyScoreBetter,
          CASE
                    WHEN (d.FuelEcon/r.FuelMult) > (f.FuelEcon/r.FuelMult) THEN 'Red'
                    WHEN (d.FuelEcon/r.FuelMult) < (f.FuelEcon/r.FuelMult) THEN 'DarkGreen'
                    ELSE 'Black'
          END AS FuelEconomyBetter,

          CASE
                    WHEN d.EngineServiceBrake > f.EngineServiceBrake THEN 'DarkGreen'
                    WHEN d.EngineServiceBrake < f.EngineServiceBrake THEN 'Red'
                    ELSE 'Black'
          END AS EngineBrakeDistanceBetter,
          CASE
                    WHEN d.OverRevWithoutFuel > f.OverRevWithoutFuel THEN 'DarkGreen'
                    WHEN d.OverRevWithoutFuel < f.OverRevWithoutFuel THEN 'Red'
                    ELSE 'Black'
          END AS OverRevWithoutFuelDistanceBetter,
          CASE
                    WHEN d.OverSpeed > f.OverSpeed THEN 'Red'
                    WHEN d.OverSpeed < f.OverSpeed THEN 'DarkGreen'
                    ELSE 'Black'
          END AS TimeOverspeedBetter,
          CASE
                    WHEN d.OverSpeedHigh > f.OverSpeedHigh THEN 'Red'
                    WHEN d.OverSpeedHigh < f.OverSpeedHigh THEN 'DarkGreen'
                    ELSE 'Black'
          END AS TimeOverspeedHighBetter,
          CASE
                    WHEN d.IVHOverSpeed > f.IVHOverSpeed THEN 'Red'
                    WHEN d.IVHOverSpeed < f.IVHOverSpeed THEN 'DarkGreen'
                    ELSE 'Black'
          END AS TimeIVHOverspeedBetter,
          CASE
                    WHEN d.CoastOutOfGear > f.CoastOutOfGear THEN 'Red'
                    WHEN d.CoastOutOfGear < f.CoastOutOfGear THEN 'DarkGreen'
                    ELSE 'Black'
          END AS TimeOutOfGearBetter,
          CASE
                    WHEN d.Rop > f.Rop THEN 'Red'
                    WHEN d.Rop < f.Rop THEN 'DarkGreen'
                    ELSE 'Black'
          END AS RopBetter,
          CASE
                    WHEN d.Rop2 > f.Rop2 THEN 'Red'
                    WHEN d.Rop2 < f.Rop2 THEN 'DarkGreen'
                    ELSE 'Black'
          END AS Rop2Better,
          CASE
                    WHEN d.HarshBraking > f.HarshBraking THEN 'Red'
                    WHEN d.HarshBraking < f.HarshBraking THEN 'DarkGreen'
                    ELSE 'Black'
          END AS HarshBrakingBetter,
          CASE
                    WHEN d.Acceleration > f.Acceleration THEN 'Red'
                    WHEN d.Acceleration < f.Acceleration THEN 'DarkGreen'
                    ELSE 'Black'
          END AS AccelerationBetter,
          CASE
                    WHEN d.Braking > f.Braking THEN 'Red'
                    WHEN d.Braking < f.Braking THEN 'DarkGreen'
                    ELSE 'Black'
          END AS BrakingBetter,
          CASE
                    WHEN d.Cornering > f.Cornering THEN 'Red'
                    WHEN d.Cornering < f.Cornering THEN 'DarkGreen'
                    ELSE 'Black'
          END AS CorneringBetter,
          CASE
                    WHEN d.AccelerationHigh > f.AccelerationHigh THEN 'Red'
                    WHEN d.AccelerationHigh < f.AccelerationHigh THEN 'DarkGreen'
                    ELSE 'Black'
          END AS AccelerationHighBetter,
          CASE
                    WHEN d.AccelerationLow > f.AccelerationLow THEN 'Red'
                    WHEN d.AccelerationLow < f.AccelerationLow THEN 'DarkGreen'
                    ELSE 'Black'
          END AS AccelerationLowBetter,
          CASE
                    WHEN d.BrakingHigh > f.BrakingHigh THEN 'Red'
                    WHEN d.BrakingHigh < f.BrakingHigh THEN 'DarkGreen'
                    ELSE 'Black'
          END AS BrakingHighBetter,
          CASE
                    WHEN d.BrakingLow > f.BrakingLow THEN 'Red'
                    WHEN d.BrakingLow < f.BrakingLow THEN 'DarkGreen'
                    ELSE 'Black'
          END AS BrakingLowBetter, 
          CASE
                    WHEN d.ManoeuvresMed > f.ManoeuvresMed THEN 'Red'
                    WHEN d.ManoeuvresMed < f.ManoeuvresMed THEN 'DarkGreen'
                    ELSE 'Black'
          END AS ManoeuvresMedBetter, 
          CASE
                    WHEN d.ManoeuvresLow > f.ManoeuvresLow THEN 'Red'
                    WHEN d.ManoeuvresLow < f.ManoeuvresLow THEN 'DarkGreen'
                    ELSE 'Black'
          END AS ManoeuvresLowBetter, 
          CASE
                    WHEN d.OverRevCount > f.OverRevCount THEN 'Red'
                    WHEN d.OverRevCount < f.OverRevCount THEN 'DarkGreen'
                    ELSE 'Black'
          END AS OverRevCountBetter,        
          CASE
                    WHEN d.SweetSpot > f.SweetSpot THEN 'DarkGreen'
                    WHEN d.SweetSpot < f.SweetSpot THEN 'Red'
                    ELSE 'Black'
          END AS SweetSpotBetter,
          CASE
                    WHEN d.OverRevWithFuel > f.OverRevWithFuel THEN 'Red'
                    WHEN d.OverRevWithFuel < f.OverRevWithFuel THEN 'DarkGreen'
                    ELSE 'Black'
          END AS OverRevWithFuelBetter,
          CASE
                    WHEN d.TopGear > f.TopGear THEN 'DarkGreen'
                    WHEN d.TopGear < f.TopGear THEN 'Red'
                    ELSE 'Black'
          END AS TopGearBetter,
          CASE
                    WHEN d.Cruise > f.Cruise THEN 'DarkGreen'
                    WHEN d.Cruise < f.Cruise THEN 'Red'
                    ELSE 'Black'
          END AS CruiseBetter,
          CASE
                    WHEN d.CruiseTopGearRatio > f.CruiseTopGearRatio THEN 'DarkGreen'
                    WHEN d.CruiseTopGearRatio < f.CruiseTopGearRatio THEN 'Red'
                    ELSE 'Black'
          END AS CruiseTopGearBetter,
          CASE
                    WHEN d.CruiseInTopGears > f.CruiseInTopGears THEN 'DarkGreen'
                    WHEN d.CruiseInTopGears < f.CruiseInTopGears THEN 'Red'
                    ELSE 'Black'
          END AS CruiseInTopGearsBetter,
          CASE
                    WHEN d.CoastInGear > f.CoastInGear THEN 'DarkGreen'
                    WHEN d.CoastInGear < f.CoastInGear THEN 'Red'
                    ELSE 'Black'
          END AS CoastInGearBetter,
          CASE
                    WHEN d.Idle > f.Idle THEN 'Red'
                    WHEN d.Idle < f.Idle THEN 'DarkGreen'
                    ELSE 'Black'
          END AS IdleBetter,
          CASE
                    WHEN d.Co2 > f.Co2 THEN 'Red'
                    WHEN d.Co2 < f.Co2 THEN 'DarkGreen'
                    ELSE 'Black'
          END AS Co2Better,
          CASE
                    WHEN d.Pto > f.Pto THEN 'Black'
                    WHEN d.Pto < f.Pto THEN 'Black'
                    ELSE 'Black'
          END AS PtoBetter,
          CASE
                    WHEN d.TopGearOverspeed > f.TopGearOverspeed THEN 'DarkGreen'
                    WHEN d.TopGearOverspeed < f.TopGearOverspeed THEN 'Red'
                    ELSE 'Black'
          END AS TopGearOverspeedBetter,
          CASE
                    WHEN d.CruiseOverspeed > f.CruiseOverspeed THEN 'DarkGreen'
                    WHEN d.CruiseOverspeed < f.CruiseOverspeed THEN 'Red'
                    ELSE 'Black'
          END AS CruiseOverspeedBetter

FROM @Results r
	LEFT JOIN @TemperatureData tr ON tr.DriverId = r.DriverId AND tr.PeriodId = r.WeekNum
	INNER JOIN @Results d ON d.VehicleId IS NULL AND d.DriverId IS NOT NULL AND d.WeekNum IS NULL
	LEFT JOIN @TemperatureData td ON td.DriverId = d.DriverId AND td.PeriodId IS NULL	
	INNER JOIN @Results f ON f.VehicleId IS NULL AND f.DriverId IS NULL AND f.WeekNum IS NULL
	LEFT JOIN @TemperatureData tf ON ISNULL(tf.DriverId, '00000000-0000-0000-0000-000000000000') = ISNULL(f.DriverId, '00000000-0000-0000-0000-000000000000') AND tf.PeriodId IS NULL	
WHERE r.WeekNum IS NOT NULL AND r.DriverId IS NOT NULL AND r.VehicleId IS NULL

GO
