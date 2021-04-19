SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportSET_Dashboard_Gauges]
(
	@uid UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME,
	@rprtcfgid UNIQUEIDENTIFIER
) 
AS

--DECLARE	@uid UNIQUEIDENTIFIER,
--		@sdate DATETIME,
--		@edate DATETIME,
--		@rprtcfgid UNIQUEIDENTIFIER

--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
----SET @uid = N'48E7EBEA-2DF5-4884-ADDC-DD2C59A7AF23'
--SET @sdate = '2019-08-02 00:00'
--SET @edate = '2019-08-11 23:59'
--SET @rprtcfgid = N'E671E529-196F-4C6A-83FE-5F51B1257862'

DECLARE @luid UNIQUEIDENTIFIER,
		@lsdate DATETIME,
		@ledate DATETIME,
		@lrprtcfgid UNIQUEIDENTIFIER

SET @luid = @uid
SET @lsdate = @sdate
SET @ledate = @edate
SET @lrprtcfgid = @rprtcfgid

DECLARE	@distmult FLOAT,
		@tempmult FLOAT,
		@liquidmult FLOAT,
		@co2mult FLOAT

SET @lsdate = dbo.TZ_ToUtc(@lsdate, DEFAULT, @luid)
SET @ledate = dbo.TZ_ToUtc(@ledate, DEFAULT, @luid)

SELECT @distmult = [dbo].UserPref(@luid, 202)
SELECT @tempmult = ISNULL(dbo.[UserPref](@luid, 214),1)
SELECT @liquidmult = ISNULL(dbo.[UserPref](@luid, 200),1)
SELECT @co2mult = ISNULL(dbo.UserPref(@luid, 210),1)

DECLARE @Results TABLE (
	Safety FLOAT,
	Efficiency FLOAT,
	Temperature FLOAT)
	
DECLARE @Groups TABLE (
	GroupTypeId INT,
	GroupId UNIQUEIDENTIFIER)
	
DECLARE @Vehicles TABLE (
	VehicleId UNIQUEIDENTIFIER,
	VehicleIntId INT,
	Registration NVARCHAR(MAX))
	
DECLARE @drivers TABLE (
	DriverId UNIQUEIDENTIFIER,
	DriverIntId INT)
	
-- Determine the groups for this user
INSERT INTO @Groups
SELECT g.GroupTypeId, g.GroupId
FROM dbo.UserGroup ug
INNER JOIN dbo.[Group] g ON ug.GroupId = g.GroupId
WHERE ug.UserId = @luid
  AND g.GroupTypeId IN (1,2) -- vehicle and driver groups
  AND g.Archived = 0
  AND g.IsParameter = 0 

INSERT INTO @Vehicles
        ( VehicleId, VehicleIntId, Registration) 
SELECT v.Vehicleid, v.VehicleIntId, v.Registration
FROM dbo.Vehicle v
INNER JOIN GroupDetail gd ON gd.EntityDataId = v.VehicleId
INNER JOIN @Groups g ON gd.GroupId = g.GroupId AND g.GroupTypeId = 1
WHERE v.Archived = 0

INSERT INTO @Drivers
		( Driverid, DriverintId )
SELECT DISTINCT d.DriverId, d.DriverIntId
FROM dbo.Driver d
INNER JOIN dbo.GroupDetail gd ON d.DriverId = gd.EntityDataId
INNER JOIN @Groups g ON gd.GroupId = g.GroupId AND g.GroupTypeId = 2
WHERE d.Archived = 0
  AND d.Number != 'No ID'

-- Create string of driver group ids to use as parameter
DECLARE @gids NVARCHAR(MAX)
SELECT @gids = COALESCE(@gids + ',', '') + CAST(GroupId AS NVARCHAR(MAX))
FROM @Groups
WHERE GroupTypeId = 2

------------ Calculate Safety and Efficiency by DRIVER
DECLARE @ResultSet TABLE
	(	GroupId UNIQUEIDENTIFIER,
		GroupName NVARCHAR(200),
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
EXECUTE dbo.[proc_ReportByVehicleConfigId_DriverGroups] 
   @gids
  ,NULL
  ,@sdate
  ,@edate
  ,@uid
  ,@rprtcfgid

INSERT INTO @Results (Safety, Efficiency)
SELECT Safety, Efficiency
FROM @ResultSet
WHERE GroupId IS NULL	

--Calculate Temperature by VEHICLE
UPDATE @Results
SET Temperature = 
 100 - (CAST(OverTempDuration AS FLOAT) / CAST(CASE WHEN OutsideDuration > 0 THEN OutsideDuration ELSE NULL END AS FLOAT) * 100)
FROM 
		(SELECT
			ISNULL(SUM(r.OverLimitDuration),0) AS OverTempDuration,
			ISNULL(SUM(r.OutsideDuration), 0) AS OutsideDuration
				
		FROM 	dbo.ReportingNCE r
			INNER JOIN @Vehicles v ON v.VehicleIntId = r.VehicleIntId
			
		WHERE r.Date BETWEEN @lsdate AND @ledate
		) data

SELECT 'Type' = CASE WHEN i.IndicatorId = 14 THEN 'Efficiency' WHEN i.IndicatorId = 15 THEN 'Safety' WHEN i.IndicatorId = 27 THEN 'Temperature' END, 
	   'Value' = CASE WHEN i.IndicatorId = 14 THEN Efficiency WHEN i.IndicatorId = 15 THEN Safety WHEN i.IndicatorId = 27 THEN Temperature END,
	   ic.GYRGreenMax, ic.GYRAmberMax, ic.Min, ic.Max, i.HighLow
FROM @Results r
CROSS JOIN dbo.ReportConfiguration rc
INNER JOIN dbo.IndicatorConfig ic ON rc.ReportConfigurationId = ic.ReportConfigurationId
INNER JOIN dbo.Indicator i ON ic.IndicatorId = i.IndicatorId
WHERE ic.ReportConfigurationId = @lrprtcfgid
  AND i.IndicatorId IN (14,15,27) -- Efficiency, Safety, Temperature
  AND ic.Archived = 0
  AND i.Archived = 0

GO
