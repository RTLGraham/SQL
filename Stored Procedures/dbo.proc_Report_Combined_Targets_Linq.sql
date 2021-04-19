SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_Report_Combined_Targets_Linq]
(
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER
)
AS

--declare	
--		@uid UNIQUEIDENTIFIER,
--		@rprtcfgid UNIQUEIDENTIFIER

--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
--SET	@rprtcfgid = N'E671E529-196F-4C6A-83FE-5F51B1257862'


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
	[dbo].GetTargetByIndicatorConfigId(32, @rprtcfgid, @uid) / 100 as OverSpeedHigh,
	[dbo].GetTargetByIndicatorConfigId(30, @rprtcfgid, @uid) / 100 as IVHOverSpeed,
	[dbo].GetTargetByIndicatorConfigId(11, @rprtcfgid, @uid) / 100 as CoastOutOfGear,
	[dbo].GetTargetByIndicatorConfigId(12, @rprtcfgid, @uid) as HarshBraking,
	[dbo].GetTargetByIndicatorConfigId(9, @rprtcfgid, @uid) as Rop,
	[dbo].GetTargetByIndicatorConfigId(41, @rprtcfgid, @uid) as Rop2,
	[dbo].GetTargetByIndicatorConfigId(22, @rprtcfgid, @uid) as Acceleration,
	[dbo].GetTargetByIndicatorConfigId(23, @rprtcfgid, @uid) as Braking,
	[dbo].GetTargetByIndicatorConfigId(24, @rprtcfgid, @uid) as Cornering,

	[dbo].GetTargetByIndicatorConfigId(33, @rprtcfgid, @uid) as AccelerationLow, 
	[dbo].GetTargetByIndicatorConfigId(34, @rprtcfgid, @uid) as BrakingLow, 
	[dbo].GetTargetByIndicatorConfigId(35, @rprtcfgid, @uid) as CorneringLow,
	[dbo].GetTargetByIndicatorConfigId(36, @rprtcfgid, @uid) as AccelerationHigh, 
	[dbo].GetTargetByIndicatorConfigId(37, @rprtcfgid, @uid) as BrakingHigh, 
	[dbo].GetTargetByIndicatorConfigId(38, @rprtcfgid, @uid) as CorneringHigh,
	[dbo].GetTargetByIndicatorConfigId(39, @rprtcfgid, @uid) as ManoeuvresLow,
	[dbo].GetTargetByIndicatorConfigId(40, @rprtcfgid, @uid) as ManoeuvresMed,

	[dbo].GetTargetByIndicatorConfigId(28, @rprtcfgid, @uid) as OverRevCount,
	
	--Safety components
	NULL AS EngineServiceBrakeComponent,
	NULL AS OverRevWithoutFuelComponent,
	NULL AS OverSpeedComponent,
	NULL AS OverSpeedHighComponent,
	NULL AS IVHOverSpeedComponent,
	NULL AS CoastOutOfGearComponent,
	NULL AS HarshBrakingComponent,
	NULL AS RopComponent,
	NULL AS Rop2Component,
	NULL AS AccelerationComponent,
	NULL AS BrakingComponent,
	NULL AS CorneringComponent,
	NULL AS AccelerationLowComponent, 
	NULL AS BrakingLowComponent, 
	NULL AS CorneringLowComponent,
	NULL AS AccelerationHighComponent, 
	NULL AS BrakingHighComponent, 
	NULL AS CorneringHighComponent,
	NULL AS ManoeuvresLowComponent,
	NULL AS ManoeuvresMedComponent,

	--Efficiency Values
	[dbo].GetTargetByIndicatorConfigId(1, @rprtcfgid, @uid) / 100 AS SweetSpot,
	[dbo].GetTargetByIndicatorConfigId(2, @rprtcfgid, @uid) / 100 AS OverRevWithFuel,
	[dbo].GetTargetByIndicatorConfigId(3, @rprtcfgid, @uid) / 100 AS TopGear,
	[dbo].GetTargetByIndicatorConfigId(4, @rprtcfgid, @uid) / 100 AS Cruise,
	[dbo].GetTargetByIndicatorConfigId(31, @rprtcfgid, @uid) / 100 AS CruiseInTopGears,
	[dbo].GetTargetByIndicatorConfigId(25, @rprtcfgid, @uid) / 100 AS CruiseTopGearRatio,
	[dbo].GetTargetByIndicatorConfigId(5, @rprtcfgid, @uid) / 100 AS CoastInGear,
	[dbo].GetTargetByIndicatorConfigId(6, @rprtcfgid, @uid) / 100 AS Idle,
	[dbo].GetTargetByIndicatorConfigId(42, @rprtcfgid, @uid) / 100 AS TopGearOverSpeed,
	[dbo].GetTargetByIndicatorConfigId(43, @rprtcfgid, @uid) / 100 AS CruiseOverspeed,
	NULL AS Co2,
	NULL AS Pto,
	
	--Efficiency components
	NULL AS SweetSpotComponent,
	NULL AS OverRevWithFuelComponent,
	NULL AS TopGearComponent,
	NULL AS IdleComponent,
	NULL AS CruiseComponent,
	NULL AS CruiseInTopGearsComponent,
	NULL AS CruiseTopGearRatioComponent,
	NULL AS CoastInGearComponent,
	NULL AS TopGearOverspeedComponent,
	NULL AS CruiseOverspeedComponent,

	--Technical fields
	NULL AS FuelMult,
	NULL AS CreationDateTime,
	NULL AS ClosureDateTime

GO
