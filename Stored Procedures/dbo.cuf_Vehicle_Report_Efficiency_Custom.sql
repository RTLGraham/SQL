SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--COMMIT
--ALTER TABLE dbo.CAM_Coaching 
--ADD SpeedGauge	VARCHAR(50) NULL,
--SpeedGaugeComponent VARCHAR(50) NULL,
--SpeedGaugeColour VARCHAR(50) NULL,
--SpeedGaugeMix VARCHAR(50) NULL	
--GO
--COMMIT

CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_Efficiency_Custom]
(
	@vids VARCHAR(MAX),
	@sdate datetime,
	@edate datetime,
	@uid uniqueidentifier,
	@rprtcfgid UNIQUEIDENTIFIER
)
AS
BEGIN
--DECLARE @vehicleId uniqueidentifier,
--		@CustomerIntId int,
--		@customerId uniqueidentifier,
--		@startDate datetime,
--		@endDate datetime,
--		@userId uniqueidentifier;

--SET @startdate = '2009-07-21'
--SET @enddate = '2009-07-25'
--SET @vehicleId = N'F9931F36-8D99-4C1A-A730-7D60B4DAE00C'		

--EXEC dbo.[proc_ReportByConfigID]
--	@vids = @vids,
--	@dids = NULL,
--	@sdate = @sdate,
--	@edate = @edate,
--	@uid = @uid,
--	@rprtcfgid = @rprtcfgid
	DECLARE @fmtonlyon bit
    SELECT @fmtonlyon = 0
-- this will evaluate to true when FMTONLY is ON, because 'if' statements aren't actually evaluated.
IF 1 = 0 SELECT @fmtonlyon = 1

IF @fmtonlyon = 1 
BEGIN
SET FMTONLY ON
--this is a model for Entity framework
DECLARE @fmtData TABLE
(
		VehicleId UNIQUEIDENTIFIER,	
		DriverId UNIQUEIDENTIFIER,
		Registration NVARCHAR,
		FleetNumber VARCHAR,
		VehicleTypeID INT,
		DisplayName NVARCHAR,
		DriverName NVARCHAR,
		FirstName VARCHAR,
		Surname VARCHAR,
		MiddleNames VARCHAR,
		Number VARCHAR,
		NumberAlternate VARCHAR,
		NumberAlternate2 VARCHAR,

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
		SweetSpotTime FLOAT,
		OverRevTime FLOAT,
		TopGearTime FLOAT,
		Fatigue FLOAT,
		Distraction FLOAT,

		-- Component Columns
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
		SweetSpotTimeComponent FLOAT,
		OverRevTimeComponent FLOAT,
		TopGearTimeComponent FLOAT,
		FatigueComponent FLOAT,
		DistractionComponent FLOAT,

		-- Score columns
		Efficiency FLOAT, 
		Safety FLOAT,

		-- Additional columns with no corresponding colour	
		TotalTime FLOAT,
		TotalDrivingDistance FLOAT,
		ServiceBrakeUsage FLOAT,	
		OverRevCount FLOAT,
		sdate DATETIME,
		edate DATETIME,
		CreationDateTime DATETIME,
		ClosureDateTime DATETIME,
		DistanceUnit VARCHAR,
		FuelUnit VARCHAR,
		Co2Unit VARCHAR,


		SweetSpotColour VARCHAR,
		OverRevWithFuelColour VARCHAR,
		TopGearColour VARCHAR,
		CruiseColour VARCHAR,
		CruiseInTopGearsColour VARCHAR,
		CoastInGearColour VARCHAR,
		IdleColour VARCHAR,
		EngineServiceBrakeColour VARCHAR,
		OverRevWithoutFuelColour VARCHAR,
		RopColour VARCHAR,
		Rop2Colour VARCHAR,
		OverSpeedColour VARCHAR,
		OverSpeedHighColour VARCHAR,
		IVHOverSpeedColour VARCHAR,
		CoastOutOfGearColour VARCHAR,
		HarshBrakingColour VARCHAR,
		EfficiencyColour VARCHAR,
		SafetyColour VARCHAR,
		KPLColour VARCHAR,
		Co2Colour VARCHAR,
		OverSpeedDistanceColour VARCHAR,
		AccelerationColour VARCHAR,
		BrakingColour VARCHAR,
		CorneringColour VARCHAR,
		AccelerationLowColour VARCHAR,
		BrakingLowColour VARCHAR,
		CorneringLowColour VARCHAR,
		AccelerationHighColour VARCHAR,
		BrakingHighColour VARCHAR,
		CorneringHighColour VARCHAR,
		ManoeuvresLowColour VARCHAR,
		ManoeuvresMedColour VARCHAR,
		CruiseTopGearRatioColour VARCHAR,
		OverRevCountColour VARCHAR,
		PtoColour VARCHAR,
		CruiseOverspeedColour VARCHAR,
		TopGearOverspeedColour VARCHAR,
		FuelWastageCostColour VARCHAR,
		OverspeedCountColour VARCHAR,
		OverspeedHighCountColour VARCHAR,
		StabilityControlColour VARCHAR,
		CollisionWarningLowColour VARCHAR,
		CollisionWarningMedColour VARCHAR,
		CollisionWarningHighColour VARCHAR,
		LaneDepartureDisableColour VARCHAR,
		LaneDepartureLeftRightColour VARCHAR,
		FatigueColour VARCHAR,
		DistractionColour VARCHAR,
		SweetSpotTimeColour VARCHAR,
		OverRevTimeColour VARCHAR,
		TopGearTimeColour VARCHAR,
		SpeedGaugeColour VARCHAR
)

SELECT *
FROM @fmtData
	return
	SET FMTONLY OFF
END
IF @fmtonlyon = 0 
BEGIN
	EXEC dbo.[proc_ReportByConfigID_Vehicle]
		@vids = @vids,
		@sdate = @sdate,
		@edate = @edate,
		@uid = @uid,
		@rprtcfgid = @rprtcfgid

	SELECT * FROM [dbo].[Vehicle] WHERE VehicleId in (select value from dbo.[Split](@vids, ','))
	END
END


GO
