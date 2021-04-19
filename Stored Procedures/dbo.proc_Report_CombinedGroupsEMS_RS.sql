SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_Report_CombinedGroupsEMS_RS]
(
	@gids varchar(max),
	@uid UNIQUEIDENTIFIER,
	@configid UNIQUEIDENTIFIER,
	@sdate datetime,
	@edate datetime,
	@grouptypeid INT
)
AS

--DECLARE	@gids varchar(max),
--		@uid UNIQUEIDENTIFIER,
--		@configid UNIQUEIDENTIFIER,
--		@sdate datetime,
--		@edate datetime,
--		@grouptypeid INT
		
--SET @grouptypeid = 1
--SET @gids = N'026BCE9E-2F77-4A36-A211-4F4A0989F972'
--SET @sdate = '2015-01-01 00:00'
--SET @edate = '2015-01-21 00:00'
--SET @uid = N'D33F39B8-963E-4896-8572-54222D0DBE75' 
----SET @configid = N'687403B7-249F-47B0-961C-C5CAC3F0B190' --default
--SET @configid = N'7E2C3415-B59B-420E-9768-79E595496F7D' --aldi

/************************/
/*		Set targets		*/
/************************/
DECLARE @targetSweetSpot FLOAT,
		@targetOverRevWithFuel FLOAT,
		@targetCruise FLOAT,
		@targetIdle FLOAT,
		@targetHarshBrake FLOAT,
		@targetFuelCon FLOAT,
		@targetCO2 FLOAT,
		@speedUnits NVARCHAR(MAX),
		@liquidstr varchar(20)

SELECT @speedUnits = [dbo].UserPref(@uid, 209)
SELECT @liquidstr = [dbo].UserPref(@uid, 201)

DECLARE @targets TABLE
(
	IndicatorId INT, [Name] NVARCHAR(MAX), [Target] FLOAT
)
INSERT INTO @targets
EXEC dbo.[cuf_Indicators_GetTargetsByConfigId] @configid, @uid

SELECT TOP 1 @targetSweetSpot = [Target] FROM @targets WHERE [Name] = 'SweetSpot'
SELECT TOP 1 @targetOverRevWithFuel = [Target] FROM @targets WHERE [Name] = 'OverRevWithFuel'
SELECT TOP 1 @targetCruise = [Target] FROM @targets WHERE [Name] = 'Cruise'
SELECT TOP 1 @targetIdle = [Target] FROM @targets WHERE [Name] = 'Idle'
SELECT TOP 1 @targetHarshBrake = [Target] FROM @targets WHERE [Name] = 'HarshBrake'
SELECT TOP 1 @targetFuelCon = [Target] FROM @targets WHERE [Name] = 'FuelCon'
SELECT TOP 1 @targetCO2 = [Target] FROM @targets WHERE [Name] = 'CO2'


DECLARE @isSS BIT

SELECT @isSS = CASE WHEN COUNT(*) = 0 THEN 0 ELSE 1 END
FROM dbo.IndicatorConfig C
	INNER JOIN dbo.Indicator I ON I.IndicatorId = C.IndicatorId
WHERE C.ReportConfigurationId = @configid
  AND C.Archived = 0
  AND I.Archived = 0
  AND I.IndicatorId = 1

/************************/
/*		Get Data		*/
/************************/
DECLARE @results TABLE (GroupId UNIQUEIDENTIFIER, GroupName NVARCHAR(MAX), SweetSpot FLOAT, OverRevWithFuel FLOAT, TopGear FLOAT, Cruise FLOAT, CoastInGear FLOAT, Idle FLOAT, TotalTime FLOAT, ServiceBrakeUsage FLOAT, EngineServiceBrake FLOAT, OverRevWithoutFuel FLOAT, Rop FLOAT, OverSpeed FLOAT, CoastOutOfGear FLOAT, HarshBraking FLOAT, TotalDrivingDistance FLOAT, FuelEcon FLOAT, TotalFuel FLOAT, Pto FLOAT, Co2 FLOAT, CruiseTopGearRatio FLOAT, AverageSpeed FLOAT, Efficiency FLOAT, Safety FLOAT, sdate DATETIME, edate DATETIME, CreationDateTime DATETIME, ClosureDateTime DATETIME, DistanceUnit NVARCHAR(MAX), FuelUnit NVARCHAR(MAX), SpeedUnit NVARCHAR(MAX), Co2Unit NVARCHAR(MAX), IdleColour NVARCHAR(MAX), SweetSpotColour NVARCHAR(MAX), OverRevWithFuelColour NVARCHAR(MAX), TopgearColour NVARCHAR(MAX), CruiseColour NVARCHAR(MAX), KPLColour NVARCHAR(MAX), EfficiencyColour NVARCHAR(MAX), SafetyColour NVARCHAR(MAX), EngineServiceBrakeColour NVARCHAR(MAX), OverRevWithoutFuelColour NVARCHAR(MAX), RopColour NVARCHAR(MAX), TimeOverSpeedColour NVARCHAR(MAX), TimeOutOfGearCoastingColour NVARCHAR(MAX), HarshBrakingColour NVARCHAR(MAX), CruiseTopGearRatioColour NVARCHAR(MAX))
IF @grouptypeid = 1
BEGIN
	INSERT INTO @results (GroupId, GroupName, SweetSpot, OverRevWithFuel, TopGear, Cruise, CoastInGear, Idle, TotalTime, ServiceBrakeUsage, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, CoastOutOfGear, HarshBraking, TotalDrivingDistance, FuelEcon, TotalFuel, Pto, Co2, CruiseTopGearRatio, AverageSpeed, Efficiency, Safety, sdate, edate, CreationDateTime, ClosureDateTime, DistanceUnit, FuelUnit, SpeedUnit, Co2Unit, IdleColour, SweetSpotColour, OverRevWithFuelColour, TopgearColour, CruiseColour, KPLColour, EfficiencyColour, SafetyColour, EngineServiceBrakeColour, OverRevWithoutFuelColour, RopColour, TimeOverSpeedColour, TimeOutOfGearCoastingColour, HarshBrakingColour, CruiseTopGearRatioColour)
	EXECUTE [dbo].[proc_Report_CombinedGroups_Vehicles] 
	   @gids
	  ,@sdate
	  ,@edate
	  ,@uid
	  ,@configid
END
ELSE BEGIN
	INSERT INTO @results (GroupId, GroupName, SweetSpot, OverRevWithFuel, TopGear, Cruise, CoastInGear, Idle, TotalTime, ServiceBrakeUsage, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, CoastOutOfGear, HarshBraking, TotalDrivingDistance, FuelEcon, TotalFuel, Pto, Co2, CruiseTopGearRatio, AverageSpeed, Efficiency, Safety, sdate, edate, CreationDateTime, ClosureDateTime, DistanceUnit, FuelUnit, SpeedUnit, Co2Unit, IdleColour, SweetSpotColour, OverRevWithFuelColour, TopgearColour, CruiseColour, KPLColour, EfficiencyColour, SafetyColour, EngineServiceBrakeColour, OverRevWithoutFuelColour, RopColour, TimeOverSpeedColour, TimeOutOfGearCoastingColour, HarshBrakingColour, CruiseTopGearRatioColour)
	EXECUTE [dbo].[proc_Report_CombinedGroups_Drivers] 
	   @gids
	  ,@sdate
	  ,@edate
	  ,@uid
	  ,@configid
END

/************************/
/*		Uncube data		*/
/************************/
SELECT 
	v.GroupName AS GroupName,
	v.Co2 AS DriverCo2,
	v.TotalDrivingDistance AS DriverTotalDrivingDistance,
	v.ServiceBrakeUsage * 100 AS DriverEngineServiceBrake,
	v.TopGear * 100 AS DriverTopGear,
	v.AverageSpeed AS DriverAverageSpeed,
	v.HarshBraking AS DriverHarshBraking,
	v.SweetSpot * 100 AS DriverSweetSpot,
	v.Cruise * 100 AS DriverCruise,
	v.FuelEcon AS DriverFuelEcon,
	v.TotalFuel AS DriverTotalFuel,
	v.OverRevWithFuel * 100 AS DriverOverRevWithFuel,
	v.Idle * 100 AS DriverIdle, 

	fa.Co2 AS FleetAvgCo2,
	fa.TotalDrivingDistance AS FleetAvgTotalDrivingDistance,
	fa.ServiceBrakeUsage * 100 AS FleetAvgEngineServiceBrake,
	fa.TopGear * 100 AS FleetAvgTopGear,
	fa.AverageSpeed AS FleetAvgAverageSpeed,
	fa.HarshBraking AS FleetAvgHarshBraking,
	fa.SweetSpot * 100 AS FleetAvgSweetSpot,
	fa.Cruise * 100 AS FleetAvgCruise,
	fa.FuelEcon AS FleetAvgFuelEcon,
	fa.TotalFuel AS FleetAvgTotalFuel,
	@liquidstr AS LiquidUnit,
	fa.OverRevWithFuel * 100 AS FleetAvgOverRevWithFuel,
	fa.Idle * 100 AS FleetAvgIdle,

	@sdate AS sdate,
	@edate AS edate,
	v.DistanceUnit,
	v.FuelUnit,
	v.Co2Unit,
	@speedUnits AS SpeedUnit,
	
	@targetSweetSpot AS TargetSweetSpot,
	@targetOverRevWithFuel AS TargetOverRevWithFuel,
	@targetCruise AS TargetCruise,
	@targetIdle AS TargetIdle,
	@targetHarshBrake AS TargetHarshBrake,
	@targetFuelCon AS TargetFuelEcon,
	@targetCO2 AS TargetCO2,
	
	@isSS AS IsSweetSpotEnabled
FROM @results v
	INNER JOIN @results fa ON fa.GroupId IS NULL
WHERE v.GroupId IS NOT NULL

--GO



GO
