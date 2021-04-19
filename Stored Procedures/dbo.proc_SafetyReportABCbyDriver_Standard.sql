SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_SafetyReportABCbyDriver_Standard]
(
	@sdate DATETIME,
	@edate DATETIME,
	@dids NVARCHAR(MAX),
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER
)
AS

--	DECLARE @sdate DATETIME,
--		@edate DATETIME,
--		@dids NVARCHAR(MAX),
--		@uid UNIQUEIDENTIFIER,
--		@rprtcfgid UNIQUEIDENTIFIER
	
--SET @sdate = '2020-03-23 00:00'
--SET @edate = '2020-03-23 23:59'
--SET @dids = N'983AEB57-6600-42C3-BA24-8D307F5AD57F,64844794-79A0-454B-999B-D2B30C33992A'
--SET @uid = N'5AADE864-607A-4D10-ACB0-27D63936124D'
--SET @rprtcfgid = N'67AB199F-1975-4E3D-9D10-719CCB3F733A'

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

	DECLARE @ResultSet TABLE
	(
			VehicleId UNIQUEIDENTIFIER,	
			Registration VARCHAR(MAX),
			FleetNumber NVARCHAR(30),
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

--			ReportConfigId UNIQUEIDENTIFIER,
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
		SpeedGaugeColour VARCHAR(MAX)
	)

	INSERT INTO @ResultSet
	EXECUTE [dbo].[proc_ReportByConfigId] 
	   NULL
	  ,@dids
	  ,@sdate
	  ,@edate
	  ,@uid
	  ,@rprtcfgid

  
	DECLARE @fleetNumber VARCHAR(1025),
			@showFleetNumber BIT,
			@scoreRounding INT,
			@abcRounding INT

	SET @fleetNumber = ISNULL([dbo].UserPref(@uid, 379), 'Fleet Number')
	SET @showFleetNumber = CAST(ISNULL([dbo].UserPref(@uid, 378), '0') AS BIT)
	SET @scoreRounding = CASE WHEN CAST(ISNULL([dbo].UserPref(@uid, 217), '0') AS INT) = 1 THEN 2 ELSE 0 END
	SET @abcRounding = CASE WHEN CAST(ISNULL([dbo].UserPref(@uid, 218), '0') AS INT) = 1 THEN 2 ELSE 0 END

	SELECT 
		c.ContractName as DepotName,
		NULL as DepotId,
		r1.Registration as Identifier,
		v.FleetNumber,
		@fleetNumber AS FleetNumberText,
		r1.VehicleId as InternalId,
		r1.VehicleTypeID,
		r1.DriverId,
		CASE WHEN r1.Number = 'No ID' 
		THEN 'UNKNOWN (No ID)' 
		ELSE
			CASE WHEN r1.Surname = 'UNKNOWN' 
			THEN r1.Number 
			ELSE r1.DisplayName--r1.Surname + ' ' + r1.FirstName 
			END
		END as DriverName,
		r1.Number AS DriverNumber,
		r1.sdate,
		r1.edate,
		r1.CreationDateTime,
		r1.ClosureDateTime,
		r1.DistanceUnit,
		r1.TotalDrivingDistance,
		r1.Safety,
		r1.CoastInGear,
		r1.OverSpeed AS OverSpeedDistance,
		r1.OverSpeedHigh,
		r1.IVHOverSpeed AS IVHOverSpeedDistance,
			
		r1.SpeedGauge,
		r1.AccelerationHighCount,
		r1.BrakingHighCount,
		r1.CorneringHighCount,
		r1.ManoeuvresLowCount,
		r1.ManoeuvresMedCount,
		r1.RopCount,
		r1.Rop2Count,

		r1.Rop AS RopCount,
		r1.Rop2 AS Rop2Count,
		r1.HarshBraking,
		r1.Acceleration,
		r1.Braking,
		r1.Cornering,
		r1.AccelerationHigh,
		r1.BrakingHigh,
		r1.CorneringHigh,
		r1.ManoeuvresLow,
		r1.ManoeuvresMed,
		r1.EngineServiceBrake,
		r1.OverRevWithoutFuel,
		r1.CoastOutOfGear,
		r1.OverRevCount,

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
	
		r1.SafetyColour,
		r1.CoastInGearColour,
		r1.OverSpeedColour AS OverSpeedDistanceColour,
		r1.OverSpeedHighColour,
		r1.IVHOverSpeedColour AS IVHOverSpeedDistanceColour,
		r1.RopColour AS RopCountColour,
		r1.Rop2Colour AS Rop2CountColour,
		r1.HarshBrakingColour,
		r1.AccelerationColour,
		r1.BrakingColour,
		r1.CorneringColour,
		r1.AccelerationHighColour,
		r1.BrakingHighColour,
		r1.CorneringHighColour,
		r1.ManoeuvresLowColour,
		r1.ManoeuvresMedColour,
		r1.EngineServiceBrakeColour,
		r1.OverRevWithoutFuelColour,
		r1.CoastOutOfGearColour,
		r1.OverRevCountColour,
	
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
			r1.SpeedGaugeColour,

		ent.TotalDrivingDistance as TotalDrivingDistanceEntity,
		ent.Safety as SafetyEntity,
		ent.CoastInGear as CoastInGearEntity,
		ent.OverSpeed as OverSpeedDistanceEntity,
		ent.OverSpeedHigh AS OverSpeedHighEntity,
		ent.IVHOverSpeed as IVHOverSpeedDistanceEntity,

		ent.SpeedGauge AS SpeedGaugeEntity,
		ent.AccelerationHighCount AS AccelerationHighCountEntity,
		ent.BrakingHighCount AS BrakingHighCountEntity,
		ent.CorneringHighCount AS CorneringHighCountEntity,
		ent.ManoeuvresLowCount AS ManoeuvresLowCountEntity,
		ent.ManoeuvresMedCount AS ManoeuvresMedCountEntity,
		ent.RopCount AS RopCountEntity,
		ent.Rop2Count AS Rop2CountEntity,

		ent.Rop AS RopCountEntity,
		ent.Rop2 AS Rop2CountEntity,
		ent.HarshBraking AS HarshBrakingEntity,
		ent.Acceleration as AccelerationEntity,
		ent.Braking as BrakingEntity,
		ent.Cornering as CorneringEntity,
		ent.AccelerationHigh as AccelerationHighEntity,
		ent.BrakingHigh as BrakingHighEntity,
		ent.CorneringHigh as CorneringHighEntity,
		ent.ManoeuvresLow as ManoeuvresLowEntity,
		ent.ManoeuvresMed as ManoeuvresMedEntity,
		ent.EngineServiceBrake AS EngineServiceBrakeEntity,
		ent.OverRevWithoutFuel AS OverRevWithoutFuelEntity,
		ent.CoastOutOfGear AS CoastOutOfGearEntity,
		ent.OverRevCount AS OverRevCountEntity,
	
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
	
		ent.SafetyColour as SafetyColourEntity,
		ent.CoastInGearColour as CoastInGearColourEntity,
		ent.OverSpeedColour as OverSpeedDistanceColourEntity,
		ent.OverSpeedHighColour AS OverSpeedHighColourEntity,
		ent.IVHOverSpeedColour as IVHOverSpeedDistanceColourEntity,

	


		ent.RopColour AS RopCountColourEntity,
		ent.Rop2Colour AS Rop2CountColourEntity,
		ent.HarshBrakingColour AS HarshBrakingColourEntity,
		ent.AccelerationColour as AccelerationColourEntity,
		ent.BrakingColour as BrakingColourEntity,
		ent.CorneringColour as CorneringColourEntity,
		ent.AccelerationHighColour as AccelerationHighColourEntity,
		ent.BrakingHighColour as BrakingHighColourEntity,
		ent.CorneringHighColour as CorneringHighColourEntity,
		ent.ManoeuvresLowColour as ManoeuvresLowColourEntity,
		ent.ManoeuvresMedColour as ManoeuvresMedColourEntity,
		ent.EngineServiceBrakeColour AS EngineServiceBrakeColourEntity,
		ent.OverRevWithoutFuelColour AS OverRevWithoutFuelColourEntity,
		ent.CoastOutOfGearColour AS CoastOutOfGearColourEntity,
		ent.OverRevCountColour AS OverRevCountColourEntity,

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
			ent.SpeedGaugeColour AS SpeedGaugeColourEntity,
		rep.TotalDrivingDistance as TotalDrivingDistanceReport,
		rep.Safety as SafetyReport,
		rep.CoastInGear as CoastInGearReport,
		rep.OverSpeed as OverSpeedDistanceReport,
		rep.OverSpeedHigh AS OverSpeedHighReport,
		rep.IVHOverSpeed as IVHOverSpeedDistanceReport,

		rep.SpeedGauge as SpeedGaugeReport,
		rep.AccelerationHighCount AS AccelerationHighCountReport,
		rep.BrakingHighCount AS BrakingHighCountReport,
		rep.CorneringHighCount AS CorneringHighCountReport,
		rep.ManoeuvresLowCount AS ManoeuvresLowCountReport,
		rep.ManoeuvresMedCount AS ManoeuvresMedCountReport,
		rep.RopCount AS RopCountReport,
		rep.Rop2Count AS Rop2CountReport,

		rep.Rop AS RopCountReport,
		rep.Rop2 AS Rop2CountReport,
		rep.HarshBraking AS HarshBrakingReport,
		rep.Acceleration as AccelerationReport,
		rep.Braking as BrakingReport,
		rep.Cornering as CorneringReport,
		rep.AccelerationHigh as AccelerationHighReport,
		rep.BrakingHigh as BrakingHighReport,
		rep.CorneringHigh as CorneringHighReport,
		rep.ManoeuvresLow as ManoeuvresLowReport,
		rep.ManoeuvresMed as ManoeuvresMedReport,
		rep.EngineServiceBrake AS EngineServiceBrakeReport,
		rep.OverRevWithoutFuel AS OverRevWithoutFuelReport,
		rep.CoastOutOfGear AS CoastOutOfGearReport,
		rep.OverRevCount AS OverRevCountReport,
		
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
	
		rep.SafetyColour as SafetyColourReport,
		rep.CoastInGearColour as CoastInGearColourReport,
		rep.OverSpeedColour as OverSpeedDistanceColourReport,
		rep.OverSpeedHighColour AS OverSpeedHighColourReport,
		rep.IVHOverSpeedColour as IVHOverSpeedDistanceColourReport,

		

		rep.RopColour AS RopCountColourReport,
		rep.Rop2Colour AS Rop2CountColourReport,
		rep.HarshBrakingColour AS HarshBrakingColourReport,
		rep.AccelerationColour as AccelerationColourReport,
		rep.BrakingColour as BrakingColourReport,
		rep.CorneringColour as CorneringColourReport,
		rep.AccelerationHighColour as AccelerationHighColourReport,
		rep.BrakingHighColour as BrakingHighColourReport,
		rep.CorneringHighColour as CorneringHighColourReport,
		rep.ManoeuvresLowColour as ManoeuvresLowColourReport,
		rep.ManoeuvresMedColour as ManoeuvresMedColourReport,
		rep.EngineServiceBrakeColour AS EngineServiceBrakeColourReport,
		rep.OverRevWithoutFuelColour AS OverRevWithoutFuelColourReport,
		rep.CoastOutOfGearColour AS CoastOutOfGearColourReport,
		rep.OverRevCountColour AS OverRevCountColourReport,
		
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
			rep.SpeedGaugeColour AS SpeedGaugeColourReport,
		@showFleetNumber AS ShowFleetNumber,
		@scoreRounding AS ScoreRounding,
		@abcRounding AS ABCRounding
	FROM @ResultSet r1
	LEFT OUTER JOIN dbo.Vehicle v ON r1.VehicleId = v.VehicleId
	INNER JOIN @ResultSet ent ON r1.DriverId = ent.DriverId AND ent.VehicleId IS NULL
	INNER JOIN @ResultSet rep ON rep.DriverId IS NULL AND rep.VehicleId IS NULL
	LEFT OUTER JOIN @contracts c ON r1.DriverId = c.DriverId
	WHERE r1.VehicleId IS NOT NULL
	  AND r1.DriverId IS NOT NULL
	ORDER BY ent.Safety DESC

GO
