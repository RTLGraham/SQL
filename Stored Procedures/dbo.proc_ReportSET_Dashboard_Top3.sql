SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportSET_Dashboard_Top3]
(
	@uid UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME,
	@rprtcfgid UNIQUEIDENTIFIER,
	@groups BIT
) 
AS

--DECLARE	@uid UNIQUEIDENTIFIER,
--		@sdate DATETIME,
--		@edate DATETIME,
--		@rprtcfgid UNIQUEIDENTIFIER,
--		@groups BIT

--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
--SET @sdate = '2019-08-01 00:00'
--SET @edate = '2019-08-11 23:59'
--SET @rprtcfgid = N'E671E529-196F-4C6A-83FE-5F51B1257862'
--SET @groups = 0

DECLARE @luid UNIQUEIDENTIFIER,
		@lsdate DATETIME,
		@ledate DATETIME,
		@lrprtcfgid UNIQUEIDENTIFIER,
		@lgroups BIT

SET @luid = @uid
SET @lsdate = @sdate
SET @ledate = @edate
SET @lrprtcfgid = @rprtcfgid
SET @lgroups = @groups 

DECLARE	@distmult FLOAT,
		@tempmult FLOAT,
		@liquidmult FLOAT,
		@co2mult FLOAT

SELECT @distmult = [dbo].UserPref(@luid, 202)
SELECT @tempmult = ISNULL(dbo.[UserPref](@luid, 214),1)
SELECT @liquidmult = ISNULL(dbo.[UserPref](@luid, 200),1)
SELECT @co2mult = ISNULL(dbo.UserPref(@luid, 210),1)

DECLARE @tdata TABLE (
	VehicleIntId INT,
	GroupId UNIQUEIDENTIFIER,
	Temperature FLOAT)

DECLARE @Results TABLE (
	Registration VARCHAR(100),
	DriverName VARCHAR(100),
	GroupName VARCHAR(100),
	Safety FLOAT,
	Efficiency FLOAT,
	Temperature FLOAT)
	
DECLARE @GroupTable TABLE (
	GroupTypeId INT,
	GroupId UNIQUEIDENTIFIER)
	
DECLARE @Vehicles TABLE (
	VehicleId UNIQUEIDENTIFIER,
	VehicleIntId INT,
	Registration NVARCHAR(MAX))
	
DECLARE @Drivers TABLE (
	DriverId UNIQUEIDENTIFIER,
	DriverIntId INT)
	
DECLARE @Top3 TABLE (
	Type VARCHAR(30),
	EntityType VARCHAR(30),
	Entity	VARCHAR(100),
	Top3Value FLOAT)
	
INSERT INTO @GroupTable
SELECT g.GroupTypeId, g.GroupId
FROM dbo.UserGroup ug
INNER JOIN dbo.[Group] g ON ug.GroupId = g.GroupId
WHERE ug.UserId = @luid
  AND g.GroupTypeId IN (1,2)
  AND g.Archived = 0
  AND g.IsParameter = 0 

INSERT INTO @Vehicles
        ( VehicleId, VehicleIntId, Registration )
SELECT v.Vehicleid, v.VehicleIntId, v.Registration
FROM dbo.Vehicle v
INNER JOIN GroupDetail gd ON gd.EntityDataId = v.VehicleId
INNER JOIN @GroupTable g ON gd.GroupId = g.GroupId
WHERE v.Archived = 0

INSERT INTO @Drivers
		( Driverid, DriverintId )
SELECT DISTINCT d.DriverId, d.DriverIntId
FROM dbo.Driver d
INNER JOIN dbo.GroupDetail gd ON d.DriverId = gd.EntityDataId
INNER JOIN @GroupTable g ON gd.GroupId = g.GroupId
WHERE d.Archived = 0
  AND d.Number != 'No ID'


IF @groups = 0
BEGIN -- Get data for individual drivers

	-- Create string of driver ids to use as parameter
	DECLARE @dids NVARCHAR(MAX)
	SELECT @dids = COALESCE(@dids + CAST(DriverId AS NVARCHAR(MAX)) + ',', '')
	FROM @Drivers
	SET @dids = LEFT(@dids, LEN(@dids) - 1)

	DECLARE @driverdata TABLE
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

	INSERT INTO @driverdata
	EXEC dbo.proc_ReportByVehicleConfigId @vids = NULL, -- varchar(max)
	    @dids = @dids, -- varchar(max)
	    @sdate = @lsdate, -- datetime
	    @edate = @ledate, -- datetime
	    @uid = @luid, -- uniqueidentifier
	    @rprtcfgid = @lrprtcfgid -- uniqueidentifier
	
	-- Now insert the individual driver data into the results table
	INSERT INTO @Results (DriverName, Safety, Efficiency)
	SELECT dd.DriverName, dd.Safety, dd.Efficiency
	FROM @driverdata dd
	WHERE dd.DriverId IS NOT NULL AND dd.VehicleId IS NULL	

END ELSE	
BEGIN -- get data for driver groups

	-- Create string of driver group ids to use as parameter
	DECLARE @gids NVARCHAR(MAX)
	SELECT @gids = COALESCE(@gids + CAST(GroupId AS NVARCHAR(MAX)) + ',', '')
	FROM @GroupTable
	WHERE GroupTypeId = 2
	SET @gids = LEFT(@gids, LEN(@gids) - 1)

	DECLARE @groupdata TABLE	
	(
		GroupId UNIQUEIDENTIFIER,
		GroupName VARCHAR(MAX),
		GroupTypeID INT,
		
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
		FuelWastageCostColour VARCHAR(MAX)
	)

	INSERT INTO @groupdata
	EXEC dbo.proc_ReportByVehicleConfigId_DriverGroups @gids = @gids, -- nvarchar(max)
	    @dids = NULL, -- varchar(max)	    
		@sdate = @lsdate, -- datetime
	    @edate = @ledate, -- datetime
	    @uid = @luid, -- uniqueidentifier
	    @rprtcfgid = @lrprtcfgid -- uniqueidentifier
	
	INSERT INTO @Results (GroupName, Safety, Efficiency)
	SELECT gd.GroupName, gd.Safety, gd.Efficiency
	FROM @groupdata gd

END	

--Calculate Temperature by VEHICLE
INSERT INTO @tdata
SELECT

	CASE WHEN (GROUPING(r.VehicleIntId) = 1) THEN NULL
		ELSE ISNULL(r.VehicleIntId, NULL)
	END AS VehicleIntId,
	
	CASE WHEN (GROUPING(g.GroupId) = 1) THEN NULL
		ELSE ISNULL(g.GroupId, NULL)
	END AS GroupId,
	
	100 - (SUM(CAST(ISNULL(nce.OverLimitDuration, 0) AS FLOAT)) * 100 / CAST(SUM(CASE WHEN nce.OutsideDuration > 0 THEN nce.OutsideDuration ELSE NULL END) AS FLOAT))
		
FROM 	dbo.ReportingNCE r
	INNER JOIN @Vehicles v ON r.VehicleIntId = v.VehicleIntId
	INNER JOIN GroupDetail gd ON gd.EntityDataId = v.VehicleId
	INNER JOIN @GroupTable g ON gd.GroupId = g.GroupId
	LEFT JOIN dbo.ReportingNCE nce ON r.VehicleIntId = nce.VehicleIntId AND r.Date = nce.Date
	
WHERE r.Date BETWEEN @lsdate AND @ledate
GROUP BY r.VehicleIntId, g.GroupId WITH CUBE

--Now delete unwanted rows from the cube
DELETE 
FROM @tdata
WHERE VehicleIntId IS NOT NULL AND GroupId IS NOT NULL

INSERT INTO @Results
        ( Registration, GroupName, Temperature )
SELECT v.Registration, g.GroupName, t.Temperature
FROM @tdata t
LEFT JOIN dbo.Vehicle v ON t.VehicleIntId = v.VehicleIntId
LEFT JOIN dbo.[Group] g ON t.GroupId = g.GroupId
	
-- Obtain top 3 data from @Results and insert into @Top3 table according to Top 3 Type requirements
IF @lgroups = 0
BEGIN

	INSERT INTO @Top3 
	SELECT TOP 3 'Safety', 'Driver', DriverName, Safety
	FROM @Results s
	WHERE s.Registration IS NULL AND s.DriverName IS NOT NULL AND s.GroupName IS NULL
	ORDER BY s.Safety DESC

	INSERT INTO @top3
	SELECT TOP 3 'Efficiency', 'Driver', Drivername, Efficiency
	FROM @Results e
	WHERE e.Registration IS NULL AND e.DriverName IS NOT NULL AND e.GroupName IS NULL
	ORDER BY e.Efficiency DESC
		
	INSERT INTO @top3
	SELECT TOP 3 'Temperature', 'Vehicle', Registration, Temperature
	FROM @Results t
	WHERE t.Registration IS NOT NULL AND t.DriverName IS NULL AND t.GroupName IS NULL AND t.Temperature IS NOT NULL
	ORDER BY t.Temperature ASC
END
ELSE IF @lgroups = 1
BEGIN
	INSERT INTO @Top3 
	SELECT TOP 3 'Safety', 'DriverGroup', GroupName, Safety
	FROM @Results s
	WHERE s.Registration IS NULL AND s.DriverName IS NULL AND s.GroupName IS NOT NULL
	ORDER BY s.Safety DESC

	INSERT INTO @top3
	SELECT TOP 3 'Efficiency', 'DriverGroup', GroupName, Efficiency
	FROM @Results e
	WHERE e.Registration IS NULL AND e.DriverName IS NULL AND e.GroupName IS NOT NULL
	ORDER BY e.Efficiency DESC
		
	INSERT INTO @top3
	SELECT TOP 3 'Temperature', 'VehicleGroup', GroupName, Temperature
	FROM @Results t
	WHERE t.Registration IS NULL AND t.DriverName IS NULL AND t.GroupName IS NOT NULL AND t.Temperature IS NOT NULL
	ORDER BY t.Temperature ASC
END

SELECT Type, EntityType, Entity, Top3Value, dbo.GYRColourConfig(Top3Value, CASE Type WHEN 'Efficiency' THEN 14 WHEN 'Safety' THEN 15 ELSE 27 END, @lrprtcfgid) AS Colour
FROM @Top3

GO
