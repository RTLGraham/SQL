SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_EfficiencyReportCustombyDriverGroup_Standard]
(
	@sdate DATETIME,
	@edate DATETIME,
	@gids NVARCHAR(MAX),
	@dids NVARCHAR(MAX),
	@uid UNIQUEIDENTIFIER,
	@configid UNIQUEIDENTIFIER
)
AS



--DECLARE @sdate DATETIME,
--	@edate DATETIME,
--	@gids NVARCHAR(MAX),
--	@dids NVARCHAR(MAX),
--	@uid UNIQUEIDENTIFIER,
--	@configid UNIQUEIDENTIFIER
--SET @gids = N'7C1AF9C4-8319-44E4-82D1-5CE1C3756C4F,67595B08-8B2F-4248-AC97-767593433F00,BAF02D7F-4791-4833-B719-7E295769ACD7'
--SET @dids = N'983AEB57-6600-42C3-BA24-8D307F5AD57F,64844794-79A0-454B-999B-D2B30C33992A'
--SET @sdate = '2020-10-23 00:00'
--SET @edate = '2020-10-23 23:59'
--SET @uid = N'5AADE864-607A-4D10-ACB0-27D63936124D'
--SET @configid = N'67AB199F-1975-4E3D-9D10-719CCB3F733A'

DECLARE @customerName NVARCHAR(MAX)
SELECT TOP 1 @customerName = c.Name
FROM dbo.[User] u
	INNER JOIN dbo.Customer c ON u.CustomerID = c.CustomerId
WHERE u.UserID = @uid AND u.Archived = 0

DECLARE @contracts TABLE
(
	ContractName NVARCHAR(MAX),
	GroupId UNIQUEIDENTIFIER
)

-- The insert into @contracts must return only ONE (arbitrary) driver group or it causes duplicate rows
-- in the standard safety and efficiency RDLs. In the case of Hoyer, for whom the driver group is added,
-- their business rules ensure a driver exists in only one driver group 
INSERT INTO @contracts ( ContractName, GroupId )
SELECT DISTINCT c.ContractName, c.GroupId
FROM
	(SELECT ROW_NUMBER() OVER(PARTITION BY g.GroupId ORDER BY g.GroupId) AS RowNum,
		CASE WHEN g.GroupName IS NULL 
			THEN @customerName
			ELSE g.GroupName 
		END AS ContractName, 
		g.GroupId
	/*here was a join error*/
	FROM dbo.Driver d
		LEFT OUTER JOIN dbo.GroupDetail gd ON d.DriverId = gd.EntityDataId
		LEFT OUTER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId AND g.GroupName LIKE '%:%'
	WHERE g.IsParameter = 0 AND g.Archived = 0 AND g.GroupTypeId = 2
		AND gd.EntityDataId IN (SELECT Value FROM dbo.Split(@dids, ','))) c
WHERE c.RowNum = 1

DECLARE @depid INT,
		@depotNames VARCHAR(MAX),
		@contractNames VARCHAR(MAX)
		
SET @depid = NULL

	DECLARE @ResultSet TABLE
	(
			GroupId UNIQUEIDENTIFIER,
			GroupName VARCHAR(MAX),
			GroupTypeID INT,
		
			--ReportConfigId UNIQUEIDENTIFIER,

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
			FuelWastageCost FLOAT,

		OverspeedCount FLOAT,
		OverspeedHighCount FLOAT,
		StabilityControl FLOAT,
		CollisionWarningLow FLOAT,
		CollisionWarningMed FLOAT,
		CollisionWarningHigh FLOAT,
		LaneDepartureDisable FLOAT,
		LaneDepartureLeftRight FLOAT,
		Fatigue FLOAT,
		Distraction FLOAT,
		SweetSpotTime FLOAT,
		OverRevTime FLOAT,
		TopGearTime FLOAT,

			SweetSpotComponent FLOAT,
			OverRevWithFuelComponent FLOAT,
			TopGearComponent FLOAT,
			CruiseComponent FLOAT,
			CruiseInTopGearsComponent FLOAT,
			IdleComponent FLOAT,
			EngineServiceBrakeComponent FLOAT,
			OverRevWithoutFuelComponent FLOAT,
			RopComponent FLOAT,
			Rop2Component FLOAT,
			OverSpeedComponent FLOAT,
			--OverSpeedHighComponent FLOAT,
			OverSpeedDistanceComponent FLOAT,
			IVHOverSpeedComponent FLOAT,

			SpeedGaugeComponent FLOAT,

			CoastOutOfGearComponent FLOAT,
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
		FatigueComponent FLOAT,
		DistractionComponent FLOAT,
		SweetSpotTimeComponent FLOAT,
		OverRevTimeComponent FLOAT,
		TopGearTimeComponent FLOAT,


			Efficiency FLOAT, 
			Safety FLOAT,

			TotalTime FLOAT,
			TotalDrivingDistance FLOAT,
			ServiceBrakeUsage FLOAT,	
			OverRevCount FLOAT,

			sdate DATETIME,
			edate DATETIME,
			CreationDateTime DATETIME,
			ClosureDateTime DATETIME,

			DistanceUnit VARCHAR(MAX),
			FuelUnit VARCHAR(MAX),
			Co2Unit VARCHAR(MAX),
			FuelMult FLOAT,

			--Currency NVARCHAR(10),
			SweetSpotColour VARCHAR(MAX),
			--SweetSpotMix BIT,
			OverRevWithFuelColour VARCHAR(MAX),
			--OverRevWithFuelMix BIT,
			TopGearColour VARCHAR(MAX),
			--TopGearMix BIT,
			CruiseColour VARCHAR(MAX),
			--CruiseMix BIT,
			CruiseInTopGearsColour NVARCHAR(MAX),
			--CruiseInTopGearsMix BIT,
			CoastInGearColour VARCHAR(MAX),
			--CoastInGearMix BIT,
			IdleColour VARCHAR(MAX),
			--IdleMix BIT,
			EngineServiceBrakeColour VARCHAR(MAX),
			--EngineServiceBrakeMix BIT,	
			OverRevWithoutFuelColour VARCHAR(MAX),
			--OverRevWithoutFuelMix BIT,
			RopColour VARCHAR(MAX),
			--RopMix BIT,
			Rop2Colour VARCHAR(MAX),
			--Rop2Mix BIT,
			OverSpeedColour VARCHAR(MAX), 
			--OverSpeedMix BIT,
			OverSpeedHighColour NVARCHAR(MAX),
			--OverSpeedHighMix BIT,
			IVHOverSpeedColour VARCHAR(MAX),
			--IVHOverSpeedMix BIT,
			CoastOutOfGearColour VARCHAR(MAX),
			--CoastOutOfGearMix BIT,
			HarshBrakingColour VARCHAR(MAX),
			--HarshBrakingMix BIT,
			EfficiencyColour VARCHAR(MAX),
			--EfficiencyMix BIT,
			SafetyColour VARCHAR(MAX),
			--SafetyMix BIT,
			KPLColour VARCHAR(MAX),
			--KPLMix BIT,
			Co2Colour VARCHAR(MAX),
			--Co2Mix BIT,
			OverSpeedDistanceColour VARCHAR(MAX),
			--OverSpeedDistanceMix BIT,
			AccelerationColour VARCHAR(MAX),
			--AccelerationMix BIT,
			BrakingColour VARCHAR(MAX),
			--BrakingMix BIT,
			CorneringColour VARCHAR(MAX),
			--CorneringMix BIT,
			AccelerationLowColour VARCHAR(MAX),
			--AccelerationLowMix BIT,
			BrakingLowColour VARCHAR(MAX),
			--BrakingLowMix BIT,
			CorneringLowColour VARCHAR(MAX),
			--CorneringLowMix BIT,
			AccelerationHighColour VARCHAR(MAX),
			--AccelerationHighMix BIT,
			BrakingHighColour VARCHAR(MAX),
			--BrakingHighMix BIT,
			CorneringHighColour VARCHAR(MAX),
			--CorneringHighMix BIT,
			ManoeuvresLowColour VARCHAR(MAX),
			--ManoeuvresLowMix BIT,
			ManoeuvresMedColour VARCHAR(MAX),
			--ManoeuvresMedMix BIT,
			CruiseTopGearRatioColour VARCHAR(MAX),
			--CruiseTopGearRatioMix BIT,
			OverRevCountColour VARCHAR(MAX),
			--OverRevCountMix BIT,
			PtoColour VARCHAR(MAX),
			--PtoMix BIT,
			CruiseOverspeedColour VARCHAR(MAX),
			--CruiseOverspeedMix BIT,
			TopGearOverspeedColour VARCHAR(MAX),
			--TopGearOverspeedMix BIT,
			FuelWastageCostColour VARCHAR(MAX),

		OverspeedCountColour VARCHAR(MAX),
		OverspeedHighCountColour VARCHAR(MAX),
		StabilityControlColour VARCHAR(MAX),
		CollisionWarningLowColour VARCHAR(MAX),
		CollisionWarningMedColour VARCHAR(MAX),
		CollisionWarningHighColour VARCHAR(MAX),
		LaneDepartureDisableColour VARCHAR(MAX),
		LaneDepartureLeftRightColour VARCHAR(MAX),
		FatigueColour VARCHAR(MAX),
		DistractionColour VARCHAR(MAX),
		SweetSpotTimeColour VARCHAR(MAX),
		OverRevTimeColour VARCHAR(MAX),
		TopGearTimeColour VARCHAR(MAX),
		SpeedgaugeColour VARCHAR(MAX)			
	)

INSERT INTO @ResultSet
EXECUTE dbo.[proc_ReportByConfigId_DriverGroups] 
   @gids
  ,@dids
  ,@sdate
  ,@edate
  ,@uid
  ,@configid


DECLARE @scoreRounding INT

SET @scoreRounding = CASE WHEN CAST(ISNULL([dbo].UserPref(@uid, 217), '0') AS INT) = 1 THEN 2 ELSE 0 END

SELECT 
	c.ContractName AS DepotName,
	NULL AS DepotId,
	NULL AS InternalId,
	NULL AS Identifier,
	NULL AS DriverNumber,
	r1.GroupName,
	r1.GroupId,
	r1.GroupTypeID,
	r1.sdate,
	r1.edate,
	r1.CreationDateTime,
	r1.ClosureDateTime,
	r1.Efficiency,
	r1.TotalDrivingDistance, 
	r1.DistanceUnit,
	r1.FuelUnit,
	r1.Co2Unit,
	r1.SweetSpot,
	r1.OverRevWithFuel,
	r1.TopGear,
	r1.Cruise,
	r1.CruiseInTopGears,
	r1.CoastInGear,
	r1.Idle,
	r1.TotalTime,
	r1.EngineServiceBrake,
	r1.OverRevWithoutFuel,

	r1.Speedgauge,
	r1.AccelerationHighCount,
	r1.BrakingHighCount,
	r1.CorneringHighCount,
	r1.ManoeuvresLowCount,
	r1.ManoeuvresMedCount,
	r1.RopCount,
	r1.Rop2Count,

	r1.Rop,
	r1.OverSpeed,
	r1.OverSpeedHigh,
	r1.CoastOutOfGear,
	r1.HarshBraking,
	r1.TopGearOverspeed,
	r1.CruiseOverspeed,
	r1.FuelWastageCost,
	r1.FuelEcon,
	r1.Pto,
	r1.Co2,
	r1.CruiseTopGearRatio,

			r1.OverspeedCount,
			r1.OverspeedHighCount,
			r1.StabilityControl,
			r1.CollisionWarningLow,
			r1.CollisionWarningMed,
			r1.CollisionWarningHigh,
			r1.LaneDepartureDisable,
			r1.LaneDepartureLeftRight,
			r1.Fatigue,
			r1.Distraction,
			r1.SweetSpotTime,
			r1.OverRevTime,
			r1.TopGearTime,

	r1.EfficiencyColour,
	r1.SweetSpotColour,
	r1.OverRevWithFuelColour,
	r1.TopGearColour,
	r1.CruiseColour,
	r1.CruiseInTopGearsColour,
	r1.CoastInGearColour,
	r1.IdleColour,
	r1.EngineServiceBrakeColour,
	r1.OverRevWithoutFuelColour,
	r1.RopColour,
	r1.KPLColour,
	r1.HarshBrakingColour,
	r1.CruiseTopGearRatioColour,
	r1.TopGearOverspeedColour,
	r1.CruiseOverspeedColour,
	r1.FuelWastageCostColour,
	
			r1.OverspeedCountColour,
			r1.OverspeedHighCountColour,
			r1.StabilityControlColour,
			r1.CollisionWarningLowColour,
			r1.CollisionWarningMedColour,
			r1.CollisionWarningHighColour,
			r1.LaneDepartureDisableColour,
			r1.LaneDepartureLeftRightColour,
			r1.FatigueColour,
			r1.DistractionColour,
			r1.SweetSpotTimeColour,
			r1.OverRevTimeColour,
			r1.SpeedgaugeColour,

	ent.Efficiency AS EfficiencyEntity,
	ent.TotalDrivingDistance AS TotalDrivingDistanceEntity, 
	ent.SweetSpot AS SweetSpotEntity,
	ent.OverRevWithFuel AS OverRevWithFuelEntity,
	ent.TopGear AS TopGearEntity,
	ent.Cruise AS CruiseEntity,
	ent.CruiseInTopGears AS CruiseInTopGearsEntity,
	ent.CoastInGear AS CoastInGearEntity,
	ent.Idle AS IdleEntity,
	ent.TotalTime AS TotalTimeEntity,
	ent.EngineServiceBrake AS EngineServiceBrakeEntity,
	ent.OverRevWithoutFuel AS OverRevWithoutFuelEntity,

	ent.Speedgauge AS SpeedgaugeEntity,
	ent.AccelerationHighCount AS AccelerationHighCountEntity,
	ent.BrakingHighCount AS BrakingHighCountEntity,
	ent.CorneringHighCount AS CorneringHighCountEntity,
	ent.ManoeuvresLowCount AS ManoeuvresLowCountEntity,
	ent.ManoeuvresMedCount AS ManoeuvresMedCountEntity,
	ent.RopCount AS RopCountEntity,
	ent.Rop2Count AS Rop2CountEntity,

	ent.Rop AS RopEntity, 
	ent.OverSpeed AS OverSpeedEntity,
	ent.OverSpeedHigh AS OverSpeedHighEntity,
	ent.CoastOutOfGear AS CoastOutOfGearEntity,
	ent.HarshBraking AS HarshBrakingEntity,
	ent.TopGearOverspeed AS TopGearOverspeedEntity,
	ent.CruiseOverspeed AS CruiseOverspeedEntity,
	ent.FuelWastageCost AS FuelWastageCostEntity,
	ent.FuelEcon AS FuelEconEntity,
	ent.Pto AS PtoEntity,
	ent.Co2 AS Co2Entity,
	ent.CruiseTopGearRatio AS CruiseTopGearRatioEntity,
	
		ent.OverspeedCount AS OverspeedCountEntity,
		ent.OverspeedHighCount AS OverspeedHighCountEntity,
		ent.StabilityControl AS StabilityControlEntity,
		ent.CollisionWarningLow AS CollisionWarningLowEntity,
		ent.CollisionWarningMed AS CollisionWarningMedEntity,
		ent.CollisionWarningHigh AS CollisionWarningHighEntity,
		ent.LaneDepartureDisable AS LaneDepartureDisableEntity,
		ent.LaneDepartureLeftRight AS LaneDepartureLeftRightEntity,
		ent.Fatigue AS FatigueEntity,
		ent.Distraction AS DistractionEntity,
		ent.SweetSpotTime AS SweetSpotTimeEntity, 
		ent.OverRevTime AS OverRevTimeEntity,
		ent.TopGearTime AS TopGearTimeEntity,

	ent.EfficiencyColour AS EfficiencyColourEntity,
	ent.SweetSpotColour AS SweetSpotColourEntity,
	ent.OverRevWithFuelColour AS OverRevWithFuelColourEntity,
	ent.TopGearColour AS TopGearColourEntity,
	ent.CruiseColour AS CruiseColourEntity,
	ent.CruiseInTopGearsColour AS CruiseInTopGearsColourEntity,
	ent.CoastInGearColour AS CoastInGearColourEntity,
	ent.IdleColour AS IdleColourEntity,
	ent.EngineServiceBrakeColour AS EngineServiceBrakeColourEntity,
	ent.OverRevWithoutFuelColour AS OverRevWithoutFuelColourEntity,
	ent.RopColour AS RopColourEntity,
	ent.KPLColour AS KPLColourEntity,
	ent.HarshBrakingColour AS HarshBrakingColourEntity,
	ent.CruiseTopGearRatioColour AS CruiseTopGearRatioColourEntity,
	ent.TopGearOverspeedColour AS TopGearOverspeedColourEntity,
	ent.CruiseOverspeedColour AS CruiseOverspeedColourEntity,
	ent.FuelWastageCostColour AS FuelWastageCostColourEntity,

		ent.OverspeedCountColour AS OverspeedCountColourEntity,
		ent.OverspeedHighCountColour AS OverspeedHighCountColourEntity,
		ent.StabilityControlColour AS StabilityControlColourEntity,
		ent.CollisionWarningLowColour AS CollisionWarningLowColourEntity,
		ent.CollisionWarningMedColour AS CollisionWarningMedColourEntity,
		ent.CollisionWarningHighColour AS CollisionWarningHighColourEntity,
		ent.LaneDepartureDisableColour AS LaneDepartureDisableColourEntity,
		ent.LaneDepartureLeftRightColour AS LaneDepartureLeftRightColourEntity,
		ent.FatigueColour AS FatigueColourEntity,
		ent.DistractionColour AS DistractionColourEntity,
		ent.SweetSpotTimeColour AS SweetSpotTimeColourEntity, 
		ent.OverRevTimeColour AS OverRevTimeColourEntity,
		ent.TopGearTimeColour AS TopGearTimeColourEntity,
		ent.SpeedgaugeColour AS SpeedgaugeColourEntity,

	rep.Efficiency AS EfficiencyReport,
	rep.TotalDrivingDistance AS TotalDrivingDistanceReport, 
	rep.SweetSpot AS SweetSpotReport,
	rep.OverRevWithFuel AS OverRevWithFuelReport,
	rep.TopGear AS TopGearReport,
	rep.Cruise AS CruiseReport,
	rep.CruiseInTopGears AS CruiseInTopGearsReport,
	rep.CoastInGear AS CoastInGearReport,
	rep.Idle AS IdleReport,
	rep.TotalTime AS TotalTimeReport,
	rep.EngineServiceBrake AS EngineServiceBrakeReport,
	rep.OverRevWithoutFuel AS OverRevWithoutFuelReport,

	rep.Speedgauge AS SpeedgaugeReport,
	rep.AccelerationHighCount AS AccelerationHighCountReport,
	rep.BrakingHighCount AS BrakingHighCountReport,
	rep.CorneringHighCount AS CorneringHighCountReport,
	rep.ManoeuvresLowCount AS ManoeuvresLowCountReport,
	rep.ManoeuvresMedCount AS ManoeuvresMedCountReport,
	rep.RopCount AS RopCountReport,
	rep.Rop2Count AS Rop2CountReport,

	rep.Rop AS RopReport, 
	rep.OverSpeed AS OverSpeedReport,
	rep.OverSpeedHigh AS OverSpeedHighReport,
	rep.CoastOutOfGear AS CoastOutOfGearReport,
	rep.HarshBraking AS HarshBrakingReport,
	rep.TopGearOverspeed AS TopGearOverspeedReport,
	rep.CruiseOverspeed AS CruiseOverspeedReport,
	rep.FuelWastageCost AS FuelWastageCostReport,
	rep.FuelEcon AS FuelEconReport,
	rep.Pto AS PtoReport,
	rep.Co2 AS Co2Report,
	rep.CruiseTopGearRatio AS CruiseTopGearRatioReport,
		
		rep.OverspeedCount AS OverspeedCountReport,
		rep.OverspeedHighCount AS OverspeedHighCountReport,
		rep.StabilityControl AS StabilityControlReport,
		rep.CollisionWarningLow AS CollisionWarningLowReport,
		rep.CollisionWarningMed AS CollisionWarningMedReport,
		rep.CollisionWarningHigh AS CollisionWarningHighReport,
		rep.LaneDepartureDisable AS LaneDepartureDisableReport,
		rep.LaneDepartureLeftRight AS LaneDepartureLeftRightReport,
		rep.Fatigue AS FatigueReport,
		rep.Distraction AS DistractionReport,
		rep.SweetSpotTime AS SweetSpotTimeReport, 
		rep.OverRevTime AS OverRevTimeReport,
		rep.TopGearTime AS TopGearTimeReport,

	rep.EfficiencyColour AS EfficiencyColourReport,
	rep.SweetSpotColour AS SweetSpotColourReport,
	rep.OverRevWithFuelColour AS OverRevWithFuelColourReport,
	rep.TopGearColour AS TopGearColourReport,
	rep.CruiseColour AS CruiseColourReport,
	rep.CruiseInTopGearsColour AS CruiseInTopGearsColourReport,
	rep.CoastInGearColour AS CoastInGearColourReport,
	rep.IdleColour AS IdleColourReport,
	rep.EngineServiceBrakeColour AS EngineServiceBrakeColourReport,
	rep.OverRevWithoutFuelColour AS OverRevWithoutFuelColourReport,
	rep.RopColour AS RopColourReport,
	rep.KPLColour AS KPLColourReport,
	rep.HarshBrakingColour AS HarshBrakingColourReport,
	rep.CruiseTopGearRatioColour AS CruiseTopGearRatioColourReport,
	rep.TopGearOverspeedColour AS TopGearOverspeedColourReport,
	rep.CruiseOverspeedColour AS CruiseOverspeedColourReport,
	rep.FuelWastageCostColour AS FuelWastageCostColourReport,
		
		rep.OverspeedCountColour AS OverspeedCountColourReport,
		rep.OverspeedHighCountColour AS OverspeedHighCountColourReport,
		rep.StabilityControlColour AS StabilityControlColourReport,
		rep.CollisionWarningLowColour AS CollisionWarningLowColourReport,
		rep.CollisionWarningMedColour AS CollisionWarningMedColourReport,
		rep.CollisionWarningHighColour AS CollisionWarningHighColourReport,
		rep.LaneDepartureDisableColour AS LaneDepartureDisableColourReport,
		rep.LaneDepartureLeftRightColour AS LaneDepartureLeftRightColourReport,
		rep.SweetSpotTimeColour AS SweetSpotTimeColourReport, 
		rep.FatigueColour AS FatigueColourReport,
		rep.DistractionColour AS DistractionColourReport,
		rep.OverRevTimeColour AS OverRevTimeColourReport,
		rep.TopGearTimeColour AS TopGearTimeColourReport,
		rep.SpeedgaugeColour AS SpeedgaugeColourReport,
	@scoreRounding AS ScoreRounding
FROM @ResultSet r1
INNER JOIN @ResultSet ent ON r1.GroupId = ent.GroupId 
INNER JOIN @ResultSet rep ON rep.GroupId IS NULL 
LEFT OUTER JOIN @contracts c ON r1.GroupId = c.GroupId
ORDER BY ent.Efficiency DESC


GO
