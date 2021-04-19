SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_Report_CombinedGroups_RS]
(
	@gids varchar(max),
	@uid UNIQUEIDENTIFIER,
	@configid UNIQUEIDENTIFIER,
	@sdate datetime,
	@edate datetime,
	@grouptypeid INT
)
AS

--declare	@gids NVARCHAR(MAX),
--	@grouptypeid INT,
--	@sdate datetime,
--	@edate datetime,
--	@uid UNIQUEIDENTIFIER,
--	@configid UNIQUEIDENTIFIER

--SET @gids=N'5C3153C6-FA67-471B-8008-3122D35CFEED'
--set @uid=N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
--SET @configid=N'6FAD9660-775F-4E1D-94B2-613CD4F94D65'
--SET @sdate='2015-12-01 00:00'
--SET @edate='2015-12-24 23:59'
--SET @grouptypeid=2


DECLARE @dids nvarchar(MAX)
SET @dids = N''

SELECT    @dids = @dids + ',' + CONVERT(nvarchar(MAX), EntityDataID)
FROM      GroupDetail
WHERE     GroupTypeID = @grouptypeid
AND       GroupID IN (SELECT Value FROM dbo.Split(@gids, ','))

SET @dids = SUBSTRING(@dids, 2, LEN(@dids))

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
		CruiseOverspeedComponent FLOAT,
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
EXEC dbo.proc_ReportByVehicleConfigIdDriversByPeriod
	NULL, @dids, @sdate, @edate, @uid, @configid, 0

DELETE FROM @Results
WHERE WeekNum IS NULL AND DriverId IS NULL AND VehicleId IS NULL;

-- Fleet averages
INSERT INTO @Results
EXEC dbo.proc_ReportByVehicleConfigId_Fleet
	@sdate, @edate, @uid, @configid  -- pass NULLs so that the Fleet average for all vehicles will be calculated

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

    --Units
    r.DistanceUnit,
    r.FuelUnit,
    r.Co2Unit,
    r.FuelMult,

    ISNULL(r.FuelEcon - f.FuelEcon, 0) AS FuelEconomyChart,
	r.Efficiency - f.Efficiency AS EfficiencyChart,
	r.[Safety] - f.[Safety] AS SafetyChart
	
FROM @Results r
	INNER JOIN @Results d ON d.VehicleId IS NULL AND d.DriverId = r.DriverID AND d.WeekNum IS NULL
	INNER JOIN @Results f ON f.VehicleId IS NULL AND f.DriverId IS NULL AND f.WeekNum IS NULL
WHERE r.WeekNum IS NOT NULL AND r.DriverId IS NOT NULL AND r.VehicleId IS NULL

GO
