SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[proc_EfficiencyReportCustombyDriver_Fair]
(
	@sdate DATETIME,
	@edate DATETIME,
	@dids NVARCHAR(MAX),
	@uid UNIQUEIDENTIFIER,
	@configid UNIQUEIDENTIFIER
)
AS

--DECLARE @sdate DATETIME,
--	@edate DATETIME,
--	@dids NVARCHAR(MAX),
--	@uid UNIQUEIDENTIFIER,
--	@configid UNIQUEIDENTIFIER
----SET @dids = N'6913DDBF-6FAC-4E5B-A33D-0D61CA692791,5AAB0E74-D39E-483B-AAFF-200FB5A56850,1860348D-20B5-42CF-BA66-203864BA0461'
--SET @dids = N'54268AAC-E6E5-41C8-98B0-17594DA54800,B16A7BA1-6503-46E6-8B8E-2F2F83931D17,98DB0E28-E8D8-4A1B-BB6C-4CFC9C645250,A5773C2F-21FF-4B4B-AFB4-53A83A1F839F,9854721D-7CF3-47A4-90B8-56E148DFC694,4F34516F-9674-4A60-9C33-5FF0A1B51E51,E75EF09A-D9B0-425A-BB07-663135024488,638AEFE8-6CDA-4EFF-9E28-698EB8AA8982,E32C0085-6ED0-486A-B67F-6F7B7F8AF091,598F8D62-0B34-4CBF-A4AE-91A9358F4E72,CD8F2681-D0AE-4466-946D-A8A6E7B57AE9,C38F5207-D209-4A14-A291-AF9DDDE69B4B,F4AF34DD-25A9-4BB3-B10E-E88B92EC66CF,E179369C-203B-4B1E-9C11-EF4B00A96528,7FB2EA17-4F26-4D65-9209-F3F7D1C73A19,539EB10F-A2DA-4ECB-BBFC-FCC2AA9FA333'
--SET @sdate = '2015-12-15 00:00'
--SET @edate = '2015-12-21 23:59'
--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
--SET @configid = N'E671E529-196F-4C6A-83FE-5F51B1257862'

-- Section added to allow the report to be automatically scheduled
IF datepart(yyyy, @sdate) IN  ('1960', '1961')
BEGIN
	SET @edate = dbo.Calc_Schedule_EndDate(@sdate, @uid)
	SET @sdate = dbo.Calc_Schedule_StartDate(@sdate, @uid)
END

DECLARE @customerName NVARCHAR(MAX)
SELECT TOP 1 @customerName = c.Name
FROM dbo.[User] u
	INNER JOIN dbo.Customer c ON u.CustomerID = c.CustomerId
WHERE u.UserID = @uid AND u.Archived = 0

DECLARE @contracts TABLE
(
	ContractName NVARCHAR(MAX),
	DriverId UNIQUEIDENTIFIER
)

-- The insert into @contracts must return only ONE (arbitrary) driver group or it causes duplicate rows
-- in the standard safety and efficiency RDLs. In the case of Hoyer, for whom the driver group is added,
-- their business rules ensure a driver exists in only one driver group 
INSERT INTO @contracts ( ContractName, DriverId )
SELECT c.ContractName, c.DriverId
FROM
	(SELECT ROW_NUMBER() OVER(PARTITION BY DriverId ORDER BY DriverId) AS RowNum,
		CASE WHEN g.GroupName IS NULL 
			THEN @customerName
			ELSE g.GroupName 
		END AS ContractName, 
		d.DriverId
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
		VehicleId UNIQUEIDENTIFIER,	
		Registration VARCHAR(MAX),
		VehicleTypeID INT,
		DriverId UNIQUEIDENTIFIER,
 		DisplayName VARCHAR(MAX),
 		DriverName VARCHAR(MAX), 
 		FirstName VARCHAR(MAX),
 		Surname VARCHAR(MAX),
 		MiddleNames VARCHAR(MAX),
 		Number VARCHAR(MAX),
 		NumberAlternate VARCHAR(MAX),
 		NumberAlternate2 VARCHAR(MAX),
		ReportConfigId UNIQUEIDENTIFIER,
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
		OverSpeedHighComponent FLOAT,
		OverSpeedDistanceComponent FLOAT,
		IVHOverSpeedComponent FLOAT,
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
		Currency NVARCHAR(10),
		SweetSpotColour VARCHAR(MAX),
		SweetSpotMix BIT,
		OverRevWithFuelColour VARCHAR(MAX),
		OverRevWithFuelMix BIT,
		TopGearColour VARCHAR(MAX),
		TopGearMix BIT,
		CruiseColour VARCHAR(MAX),
		CruiseMix BIT,
		CruiseInTopGearsColour NVARCHAR(MAX),
		CruiseInTopGearsMix BIT,
		CoastInGearColour VARCHAR(MAX),
		CoastInGearMix BIT,
		IdleColour VARCHAR(MAX),
		IdleMix BIT,
		EngineServiceBrakeColour VARCHAR(MAX),
		EngineServiceBrakeMix BIT,	
		OverRevWithoutFuelColour VARCHAR(MAX),
		OverRevWithoutFuelMix BIT,
		RopColour VARCHAR(MAX),
		RopMix BIT,
		Rop2Colour VARCHAR(MAX),
		Rop2Mix BIT,
		OverSpeedColour VARCHAR(MAX), 
		OverSpeedMix BIT,
		OverSpeedHighColour NVARCHAR(MAX),
		OverSpeedHighMix BIT,
		IVHOverSpeedColour VARCHAR(MAX),
		IVHOverSpeedMix BIT,
		CoastOutOfGearColour VARCHAR(MAX),
		CoastOutOfGearMix BIT,
		HarshBrakingColour VARCHAR(MAX),
		HarshBrakingMix BIT,
		EfficiencyColour VARCHAR(MAX),
		EfficiencyMix BIT,
		SafetyColour VARCHAR(MAX),
		SafetyMix BIT,
		KPLColour VARCHAR(MAX),
		KPLMix BIT,
		Co2Colour VARCHAR(MAX),
		Co2Mix BIT,
		OverSpeedDistanceColour VARCHAR(MAX),
		OverSpeedDistanceMix BIT,
		AccelerationColour VARCHAR(MAX),
		AccelerationMix BIT,
		BrakingColour VARCHAR(MAX),
		BrakingMix BIT,
		CorneringColour VARCHAR(MAX),
		CorneringMix BIT,
		AccelerationLowColour VARCHAR(MAX),
		AccelerationLowMix BIT,
		BrakingLowColour VARCHAR(MAX),
		BrakingLowMix BIT,
		CorneringLowColour VARCHAR(MAX),
		CorneringLowMix BIT,
		AccelerationHighColour VARCHAR(MAX),
		AccelerationHighMix BIT,
		BrakingHighColour VARCHAR(MAX),
		BrakingHighMix BIT,
		CorneringHighColour VARCHAR(MAX),
		CorneringHighMix BIT,
		ManoeuvresLowColour VARCHAR(MAX),
		ManoeuvresLowMix BIT,
		ManoeuvresMedColour VARCHAR(MAX),
		ManoeuvresMedMix BIT,
		CruiseTopGearRatioColour VARCHAR(MAX),
		CruiseTopGearRatioMix BIT,
		OverRevCountColour VARCHAR(MAX),
		OverRevCountMix BIT,
		PtoColour VARCHAR(MAX),
		PtoMix BIT,
		CruiseOverspeedColour VARCHAR(MAX),
		CruiseOverspeedMix BIT,
		TopGearOverspeedColour VARCHAR(MAX),
		TopGearOverspeedMix BIT,
		FuelWastageCostColour VARCHAR(MAX),

	OverspeedCountColour VARCHAR(MAX),
	OverspeedCountMix BIT,
	OverspeedHighCountColour VARCHAR(MAX),
	OverspeedHighCountMix BIT,
	StabilityControlColour VARCHAR(MAX),
	StabilityControlMix BIT,
	CollisionWarningLowColour VARCHAR(MAX),
	CollisionWarningLowMix BIT,
	CollisionWarningMedColour VARCHAR(MAX),
	CollisionWarningMedMix BIT,
	CollisionWarningHighColour VARCHAR(MAX),
	CollisionWarningHighMix BIT,
	LaneDepartureDisableColour VARCHAR(MAX),
	LaneDepartureDisableMix BIT,
	LaneDepartureLeftRightColour VARCHAR(MAX),
	LaneDepartureLeftRightMix BIT,
	FatigueColour VARCHAR(MAX),
	FatigueMix BIT,
	DistractionColour VARCHAR(MAX),
	DistractionMix BIT,
	SweetSpotTimeColour VARCHAR(MAX),
	SweetSpotTimeMix BIT,
	OverRevTimeColour VARCHAR(MAX),
	OverRevTimeMix BIT,
	TopGearTimeColour VARCHAR(MAX),	
	TopGearTimeMix BIT
)

INSERT INTO @ResultSet
EXECUTE dbo.[proc_ReportByVehicleConfigId] 
   NULL
  ,@dids
  ,@sdate
  ,@edate
  ,@uid
  ,@configid

DECLARE @fleetNumber VARCHAR(1025),
		@showFleetNumber BIT,
		@scoreRounding INT

SET @fleetNumber = ISNULL([dbo].UserPref(@uid, 379), 'Fleet Number')
SET @showFleetNumber = CAST(ISNULL([dbo].UserPref(@uid, 378), '0') AS BIT)
SET @scoreRounding = CASE WHEN CAST(ISNULL([dbo].UserPref(@uid, 217), '0') AS INT) = 1 THEN 2 ELSE 0 END


SELECT 
	c.ContractName as DepotName,
	NULL as DepotId,
	r1.Registration as Identifier,
	r1.VehicleId as InternalId,
	r1.VehicleTypeID,
	r1.DriverId,
	CASE WHEN r1.Number = 'No ID' 
	THEN 'UNKNOWN (No ID)' 
	ELSE
		CASE WHEN r1.Surname = 'UNKNOWN' 
		THEN r1.Number 
		--ELSE r1.DisplayName
		ELSE r1.Surname + ' ' + r1.FirstName 
		END
	END as DriverName,
	r1.Number AS DriverNumber,
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
		r1.TopGearTimeColour,

	ent.Efficiency as EfficiencyEntity,
	ent.TotalDrivingDistance as TotalDrivingDistanceEntity, 
	ent.SweetSpot as SweetSpotEntity,
	ent.OverRevWithFuel as OverRevWithFuelEntity,
	ent.TopGear as TopGearEntity,
	ent.Cruise as CruiseEntity,
	ent.CruiseInTopGears AS CruiseInTopGearsEntity,
	ent.CoastInGear as CoastInGearEntity,
	ent.Idle as IdleEntity,
	ent.TotalTime as TotalTimeEntity,
	ent.EngineServiceBrake as EngineServiceBrakeEntity,
	ent.OverRevWithoutFuel as OverRevWithoutFuelEntity,
	ent.Rop as RopEntity, 
	ent.OverSpeed as OverSpeedEntity,
	ent.OverSpeedHigh AS OverSpeedHighEntity,
	ent.CoastOutOfGear as CoastOutOfGearEntity,
	ent.HarshBraking as HarshBrakingEntity,
	ent.TopGearOverspeed AS TopGearOverspeedEntity,
	ent.CruiseOverspeed AS CruiseOverspeedEntity,
	ent.FuelWastageCost AS FuelWastageCostEntity,
	ent.FuelEcon as FuelEconEntity,
	ent.Pto as PtoEntity,
	ent.Co2 as Co2Entity,
	ent.CruiseTopGearRatio as CruiseTopGearRatioEntity,
	
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

	ent.EfficiencyColour as EfficiencyColourEntity,
	ent.SweetSpotColour as SweetSpotColourEntity,
	ent.OverRevWithFuelColour as OverRevWithFuelColourEntity,
	ent.TopGearColour as TopGearColourEntity,
	ent.CruiseColour as CruiseColourEntity,
	ent.CruiseInTopGearsColour AS CruiseInTopGearsColourEntity,
	ent.CoastInGearColour AS CoastInGearColourEntity,
	ent.IdleColour as IdleColourEntity,
	ent.EngineServiceBrakeColour as EngineServiceBrakeColourEntity,
	ent.OverRevWithoutFuelColour as OverRevWithoutFuelColourEntity,
	ent.RopColour as RopColourEntity,
	ent.KPLColour as KPLColourEntity,
	ent.HarshBrakingColour as HarshBrakingColourEntity,
	ent.CruiseTopGearRatioColour as CruiseTopGearRatioColourEntity,
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

	rep.Efficiency as EfficiencyReport,
	rep.TotalDrivingDistance as TotalDrivingDistanceReport, 
	rep.SweetSpot as SweetSpotReport,
	rep.OverRevWithFuel as OverRevWithFuelReport,
	rep.TopGear as TopGearReport,
	rep.Cruise as CruiseReport,
	rep.CruiseInTopGears AS CruiseInTopGearsReport,
	rep.CoastInGear as CoastInGearReport,
	rep.Idle as IdleReport,
	rep.TotalTime as TotalTimeReport,
	rep.EngineServiceBrake as EngineServiceBrakeReport,
	rep.OverRevWithoutFuel as OverRevWithoutFuelReport,
	rep.Rop as RopReport, 
	rep.OverSpeed as OverSpeedReport,
	rep.OverSpeedHigh AS OverSpeedHighReport,
	rep.CoastOutOfGear as CoastOutOfGearReport,
	rep.HarshBraking as HarshBrakingReport,
	rep.TopGearOverspeed AS TopGearOverspeedReport,
	rep.CruiseOverspeed AS CruiseOverspeedReport,
	rep.FuelWastageCost AS FuelWastageCostReport,
	rep.FuelEcon as FuelEconReport,
	rep.Pto as PtoReport,
	rep.Co2 as Co2Report,
	rep.CruiseTopGearRatio as CruiseTopGearRatioReport,
		
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

	rep.EfficiencyColour as EfficiencyColourReport,
	rep.SweetSpotColour as SweetSpotColourReport,
	rep.OverRevWithFuelColour as OverRevWithFuelColourReport,
	rep.TopGearColour as TopGearColourReport,
	rep.CruiseColour as CruiseColourReport,
	rep.CruiseInTopGearsColour AS CruiseInTopGearsColourReport,
	rep.CoastInGearColour AS CoastInGearColourReport,
	rep.IdleColour as IdleColourReport,
	rep.EngineServiceBrakeColour as EngineServiceBrakeColourReport,
	rep.OverRevWithoutFuelColour as OverRevWithoutFuelColourReport,
	rep.RopColour as RopColourReport,
	rep.KPLColour as KPLColourReport,
	rep.HarshBrakingColour as HarshBrakingColourReport,
	rep.CruiseTopGearRatioColour as CruiseTopGearRatioColourReport,
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

	@fleetNumber AS FleetNumberText,
	@showFleetNumber AS ShowFleetNumber,
	@scoreRounding AS ScoreRounding
FROM @ResultSet r1
INNER JOIN @ResultSet ent ON r1.DriverId = ent.DriverId AND ent.VehicleId IS NULL
INNER JOIN @ResultSet rep ON rep.DriverId IS NULL AND rep.VehicleId IS NULL
LEFT OUTER JOIN @contracts c ON r1.DriverId = c.DriverId
WHERE r1.VehicleId IS NOT NULL
  AND r1.DriverId IS NOT NULL
ORDER BY ent.Efficiency DESC



GO
