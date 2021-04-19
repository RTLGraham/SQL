SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportCoaching_Fleet_temporary]
(
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER
)
AS

--DECLARE	@sdate datetime,
--		@edate datetime,
--		@uid UNIQUEIDENTIFIER,
--		@rprtcfgid UNIQUEIDENTIFIER

--SET	@sdate = '2015-08-01 00:00:00.000'
--SET	@edate = '2015-08-30 23:59:00.000'
--SET	@uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
--SET	@rprtcfgid = N'583B4D46-F49F-4C93-B55C-4E0BC1E2A96C'

DECLARE	@lsdate datetime,
		@ledate datetime,
		@luid UNIQUEIDENTIFIER,
		@lrprtcfgid UNIQUEIDENTIFIER
		
SET @lsdate = @sdate
SET @ledate = @edate
SET @luid = @uid
SET @lrprtcfgid = @rprtcfgid

DECLARE @diststr varchar(20),
		@distmult float,
		@fuelstr varchar(20),
		@fuelcost FLOAT,
		@currency NVARCHAR(10),
		@fuelmult float,
		@co2str varchar(20),
		@co2mult FLOAT,
		@custintid INT

SELECT @diststr = [dbo].UserPref(@luid, 203)
SELECT @distmult = [dbo].UserPref(@luid, 202)
SELECT @fuelstr = [dbo].UserPref(@luid, 205)
SELECT @fuelmult = [dbo].UserPref(@luid, 204)
SELECT @co2str = [dbo].UserPref(@luid, 211)
SELECT @co2mult = [dbo].UserPref(@luid, 210)
SELECT @currency = [dbo].UserPref(@luid, 381)

SELECT @fuelcost = CAST(cp.Value AS FLOAT)
FROM dbo.[User] u
INNER JOIN dbo.CustomerPreference cp ON cp.CustomerID = u.CustomerID
WHERE u.UserID = @luid
  AND cp.NameID = 3007

SET @lsdate = [dbo].TZ_ToUTC(@lsdate,default,@luid)
SET @ledate = [dbo].TZ_ToUTC(@ledate,default,@luid)

-- Create temporary table for vehicle configs
DECLARE @VehicleConfig TABLE
(
	Vid UNIQUEIDENTIFIER,
	ReportConfigId UNIQUEIDENTIFIER
)

SELECT @custintid = c.CustomerIntId
FROM dbo.[User] u
INNER JOIN dbo.Customer c ON u.CustomerID = c.CustomerId
WHERE u.UserID = @luid


INSERT INTO @VehicleConfig (Vid, ReportConfigId)
SELECT v.VehicleId, ISNULL(vrc.ReportConfigurationId, @lrprtcfgid)	
FROM dbo.Vehicle v
	INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
	INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
	INNER JOIN dbo.[User] u ON c.CustomerId = u.CustomerId
	LEFT JOIN dbo.VehicleReportConfiguration vrc ON v.VehicleId = vrc.VehicleId
WHERE u.UserID = @luid
	AND v.Archived = 0
	AND cv.Archived = 0
	AND cv.EndDate IS NULL

-- Pre-Process Data to get weighted distances
DECLARE @weightedData TABLE
(
	VehicleIntId INT,
	wInSweetSpotDistance FLOAT, InSweetSpotTotal FLOAT, --InSweetSpotUsed INT,
	wFueledOverRPMDistance FLOAT, FueledOverRPMTotal FLOAT, --FueledOverRPMUsed INT,
	wTopGearDistance FLOAT, TopGearTotal FLOAT, --TopGearUsed INT,
	wCruiseControlDistance FLOAT, CruiseTotal FLOAT, --CruiseUsed INT,
	wCruiseInTopGearsDistance FLOAT, CruiseInTopGearsTotal FLOAT, --CruiseInTopGearsUsed INT,
	wCoastInGearDistance FLOAT, CoastInGearTotal FLOAT, --CoastInGearUsed INT,
	wIdleTime FLOAT, IdleTotal FLOAT, --IdleUsed INT,
	wServiceBrakeDistance FLOAT, ServiceBrakeTotal FLOAT, --ServiceBrakeUsed INT, 
	wEngineBrakeOverRPMDistance FLOAT, EngineBrakeOverRPMTotal FLOAT, --EngineBrakeOverRPMUsed INT,
	wROPCount FLOAT, ROPTotal FLOAT, --ROPUsed INT,
	wROP2Count FLOAT, ROP2Total FLOAT, --ROP2Used INT,
	wOverspeedDistance FLOAT, OverSpeedTotal FLOAT, --OverSpeedUsed INT,
	wOverSpeedHighDistance FLOAT, OverSpeedHighTotal FLOAT, --OverSpeedHighUsed INT,
	wIVHOverSpeedDistance FLOAT, IVHOverSpeedTotal FLOAT, --IVHOverSpeedUsed INT,
	wCoastOutOfGearDistance FLOAT, CoastOutOfGearTotal FLOAT, --CoastOutOfGearUsed INT,
	wPanicStopCount FLOAT, PanicStopTotal FLOAT, --PanicStopUsed INT,
	wAcceleration FLOAT, AccelerationTotal FLOAT, --AccelerationUsed INT,
	wBraking FLOAT, BrakingTotal FLOAT, --BrakingUsed INT,
	wCornering FLOAT, CorneringTotal FLOAT, --CorneringUsed INT,
	wAccelerationLow FLOAT, AccelerationLowTotal FLOAT, --AccelerationLowUsed INT,
	wBrakingLow FLOAT, BrakingLowTotal FLOAT, --BrakingLowUsed INT,
	wCorneringLow FLOAT, CorneringLowTotal FLOAT, --CorneringLowUsed INT,
	wAccelerationHigh FLOAT, AccelerationHighTotal FLOAT, --AccelerationHighUsed INT,
	wBrakingHigh FLOAT, BrakingHighTotal FLOAT, --BrakingHighUsed INT,
	wCorneringHigh FLOAT, CorneringHighTotal FLOAT, --CorneringHighUsed INT,
	wManoeuvresLow FLOAT, ManoeuvresLowTotal FLOAT, --ManoeuvresLowUsed TINYINT,		
	wManoeuvresMed FLOAT, ManoeuvresMedTotal FLOAT, --ManoeuvresMedUsed TINYINT,		
	wORCount FLOAT, ORCountTotal FLOAT, --ORCountUsed INT,
	wPTOTime FLOAT, PTOTotal FLOAT, --PTOUsed INT
	wTotalFuel FLOAT, FuelEconTotal FLOAT,
	wTopGearOverSpeed FLOAT, TopGearOverSpeedTotal FLOAT, --TopGearOverSpeedUsed TINYINT,
	wCruiseOverSpeed FLOAT, CruiseOverSpeedTotal FLOAT, --CruiseOverSpeedUsed TINYINT,
	wFuelWastage FLOAT
)

INSERT INTO @weightedData  (VehicleIntId, 
							wInSweetSpotDistance, InSweetSpotTotal,
							wFueledOverRPMDistance, FueledOverRPMTotal,
							wTopGearDistance, TopGearTotal, 
							wCruiseControlDistance, CruiseTotal, 
							wCruiseInTopGearsDistance, CruiseInTopGearsTotal, 
							wCoastInGearDistance, CoastInGearTotal, 
							wIdleTime, IdleTotal, 
							wServiceBrakeDistance, ServiceBrakeTotal, 
							wEngineBrakeOverRPMDistance, EngineBrakeOverRPMTotal, 
							wROPCount, ROPTotal,
							wROP2Count, ROP2Total, 
							wOverspeedDistance, OverSpeedTotal, 
							wOverSpeedHighDistance, OverSpeedHighTotal, 
							wIVHOverSpeedDistance, IVHOverSpeedTotal, 
							wCoastOutOfGearDistance, CoastOutOfGearTotal, 
							wPanicStopCount, PanicStopTotal, 
							wAcceleration, AccelerationTotal, 
							wBraking, BrakingTotal, 
							wCornering, CorneringTotal, 
							wAccelerationLow, AccelerationLowTotal, 
							wBrakingLow, BrakingLowTotal, 
							wCorneringLow, CorneringLowTotal, 
							wAccelerationHigh, AccelerationHighTotal, 
							wBrakingHigh, BrakingHighTotal, 
							wCorneringHigh, CorneringHighTotal, 	
							wManoeuvresLow, ManoeuvresLowTotal, 
							wManoeuvresMed, ManoeuvresMedTotal, 													
							wORCount, ORCountTotal, 
							wPTOTime, PTOTotal,
							wTotalFuel, FuelEconTotal,
							wTopGearOverSpeed, TopGearOverSpeedTotal, 
							wCruiseOverSpeed, CruiseOverSpeedTotal,
							wFuelWastage)
SELECT	VehicleIntId, 
		SUM(wInSweetSpotDistance), SUM(InSweetSpotTotal), 
		SUM(wFueledOverRPMDistance), SUM(FueledOverRPMTotal), 
		SUM(wTopGearDistance), SUM(TopGearTotal), 
		SUM(wCruiseControlDistance), SUM(CruiseTotal), 
		SUM(wCruiseInTopGearsDistance), SUM(CruiseInTopGearsTotal), 
		SUM(wCoastInGearDistance), SUM(CoastInGearTotal),
		SUM(wIdleTime), SUM(IdleTotal), 
		SUM(wServiceBrakeDistance), SUM(ServiceBrakeTotal), 
		SUM(wEngineBrakeOverRPMDistance), SUM(EngineBrakeOverRPMTotal), 
		SUM(wROPCount), SUM(ROPTotal),
		SUM(wROP2Count), SUM(ROP2Total), 
		SUM(wOverspeedDistance), SUM(OverSpeedTotal), 
		SUM(wOverSpeedHighDistance), SUM(OverSpeedHighTotal), 
		SUM(wIVHOverSpeedDistance), SUM(IVHOverSpeedTotal), 
		SUM(wCoastOutOfGearDistance), SUM(CoastOutOfGearTotal),
		SUM(wPanicStopCount), SUM(PanicStopTotal), 
		SUM(wAcceleration), SUM(AccelerationTotal), 
		SUM(wBraking), SUM(BrakingTotal), 
		SUM(wCornering), SUM(CorneringTotal),
		SUM(wAccelerationLow), SUM(AccelerationLowTotal),
		SUM(wBrakingLow), SUM(BrakingLowTotal), 
		SUM(wCorneringLow), SUM(CorneringLowTotal), 
		SUM(wAccelerationHigh), SUM(AccelerationHighTotal),
		SUM(wBrakingHigh), SUM(BrakingHighTotal), 
		SUM(wCorneringHigh), SUM(CorneringHighTotal), 
		SUM(wManoeuvresLow), SUM(ManoeuvresLowTotal), 
		SUM(wManoeuvresMed), SUM(ManoeuvresMedTotal), 
		SUM(wORCount), SUM(ORCountUsed),
		SUM(wPTOTime), SUM(PTOTotal),
		SUM(wTotalFuel), SUM(FuelEconTotal),
		SUM(wTopGearOverSpeed), SUM(TopGearOverSpeedTotal),
		SUM(wCruiseOverSpeed), SUM(CruiseOverSpeedTotal), 
		SUM(wFuelWastage)
FROM	
	(
	SELECT	r.VehicleIntId,
			-- For each component calculate the weighted value and the weighted total (i.e. where the indicator is being used (IS NOT NULL))	
			CASE WHEN ic.IndicatorId = 1 THEN r.InSweetSpotDistance END AS wInSweetSpotDistance,
			CASE WHEN ic.IndicatorId = 1 THEN r.DrivingDistance + r.PTOMovingDistance END AS InSweetSpotTotal,
			CASE WHEN ic.IndicatorId = 1 THEN 1 END AS InSweetSpotUsed,
		
			CASE WHEN ic.IndicatorId = 2 THEN r.FueledOverRPMDistance END AS wFueledOverRPMDistance,
			CASE WHEN ic.IndicatorId = 2 THEN r.DrivingDistance + r.PTOMovingDistance END AS FueledOverRPMTotal,
			CASE WHEN ic.IndicatorId = 2 THEN 1 END AS FueledOverRPMUsed,
		
			CASE WHEN ic.IndicatorId = 3 THEN r.TopGearDistance END AS wTopGearDistance,
			CASE WHEN ic.IndicatorId = 3 THEN r.DrivingDistance + r.PTOMovingDistance END AS TopGearTotal,
			CASE WHEN ic.IndicatorId = 3 THEN 1 END AS TopGearUsed,
		
			CASE WHEN ic.IndicatorId = 4 THEN r.CruiseControlDistance END AS wCruiseControlDistance,
			CASE WHEN ic.IndicatorId = 4 THEN r.DrivingDistance + r.PTOMovingDistance END AS CruiseTotal,
			CASE WHEN ic.IndicatorId = 4 THEN 1 END AS CruiseUsed,
		
			CASE WHEN ic.IndicatorId = 31 THEN r.CruiseControlDistance END AS wCruiseInTopGearsDistance,
			CASE WHEN ic.IndicatorId = 31 THEN r.TopGearDistance + r.GearDownDistance END AS CruiseInTopGearsTotal,
			CASE WHEN ic.IndicatorId = 31 THEN 1 END AS CruiseInTopGearsUsed,
		
			CASE WHEN ic.IndicatorId = 5 THEN r.CoastInGearDistance END AS wCoastInGearDistance,
			CASE WHEN ic.IndicatorId = 5 THEN r.DrivingDistance + r.PTOMovingDistance END AS CoastInGearTotal,
			CASE WHEN ic.IndicatorId = 5 THEN 1 END AS CoastInGearUsed,
		
			CASE WHEN ic.IndicatorId = 6 THEN r.IdleTime END AS wIdleTime,
			CASE WHEN ic.IndicatorId = 6 THEN r.TotalTime END AS IdleTotal,
			CASE WHEN ic.IndicatorId = 6 THEN 1 END AS IdleUsed,
		
			CASE WHEN ic.IndicatorId = 7 THEN r.ServiceBrakeDistance END AS wServiceBrakeDistance,
			CASE WHEN ic.IndicatorId = 7 THEN r.ServiceBrakeDistance + r.EngineBrakeDistance END AS ServiceBrakeTotal,
			CASE WHEN ic.IndicatorId = 7 THEN 1 END AS ServiceBrakeUsed,
		
			CASE WHEN ic.IndicatorId = 8 THEN r.EngineBrakeOverRPMDistance END AS wEngineBrakeOverRPMDistance,
			CASE WHEN ic.IndicatorId = 8 THEN r.EngineBrakeDistance END AS EngineBrakeOverRPMTotal,
			CASE WHEN ic.IndicatorId = 8 THEN 1 END AS EngineBrakeOverRPMUsed,
		
			CASE WHEN ic.IndicatorId = 9 THEN r.ROPCount END AS wROPCount,
			CASE WHEN ic.IndicatorId = 9 THEN r.DrivingDistance + r.PTOMovingDistance END AS ROPTotal,
			CASE WHEN ic.IndicatorId = 9 THEN 1 END AS ROPUsed,

			CASE WHEN ic.IndicatorId = 41 THEN r.ROP2Count END AS wROP2Count,
			CASE WHEN ic.IndicatorId = 41 THEN r.DrivingDistance + r.PTOMovingDistance END AS ROP2Total,
			CASE WHEN ic.IndicatorId = 41 THEN 1 END AS ROP2Used,
					
			CASE WHEN ic.IndicatorId = 10 THEN ro.OverspeedDistance END AS wOverspeedDistance,
			CASE WHEN ic.IndicatorId = 10 THEN r.DrivingDistance + r.PTOMovingDistance END AS OverSpeedTotal,
			CASE WHEN ic.IndicatorId = 10 THEN 1 END AS OverSpeedUsed,

			CASE WHEN ic.IndicatorId = 32 THEN ro.OverSpeedHighDistance END AS wOverSpeedHighDistance,
			CASE WHEN ic.IndicatorId = 32 THEN r.DrivingDistance + r.PTOMovingDistance END AS OverSpeedHighTotal,
			CASE WHEN ic.IndicatorId = 32 THEN 1 END AS OverSpeedHighUsed,
		
			CASE WHEN ic.IndicatorId = 30 THEN r.OverSpeedDistance END AS wIVHOverSpeedDistance,
			CASE WHEN ic.IndicatorId = 30 THEN r.DrivingDistance + r.PTOMovingDistance END AS IVHOverSpeedTotal,
			CASE WHEN ic.IndicatorId = 30 THEN 1 END AS IVHOverSpeedUsed,
		
			CASE WHEN ic.IndicatorId = 11 THEN r.CoastOutOfGearDistance END AS wCoastOutOfGearDistance,
			CASE WHEN ic.IndicatorId = 11 THEN r.DrivingDistance + r.PTOMovingDistance END AS CoastOutOfGearTotal,
			CASE WHEN ic.IndicatorId = 11 THEN 1 END AS CoastOutOfGearUsed,
		
			CASE WHEN ic.IndicatorId = 12 THEN r.PanicStopCount END AS wPanicStopCount,
			CASE WHEN ic.IndicatorId = 12 THEN r.DrivingDistance + r.PTOMovingDistance END AS PanicStopTotal,
			CASE WHEN ic.IndicatorId = 12 THEN 1 END AS PanicStopUsed,
		
			CASE WHEN ic.IndicatorId = 22 THEN abc.Acceleration END AS wAcceleration,
			CASE WHEN ic.IndicatorId = 22 THEN r.DrivingDistance + r.PTOMovingDistance END AS AccelerationTotal,
			CASE WHEN ic.IndicatorId = 22 THEN 1 END AS AccelerationUsed,
		
			CASE WHEN ic.IndicatorId = 23 THEN abc.Braking END AS wBraking,
			CASE WHEN ic.IndicatorId = 23 THEN r.DrivingDistance + r.PTOMovingDistance END AS BrakingTotal,
			CASE WHEN ic.IndicatorId = 23 THEN 1 END AS BrakingUsed,
		
			CASE WHEN ic.IndicatorId = 24 THEN abc.Cornering END AS wCornering,
			CASE WHEN ic.IndicatorId = 24 THEN r.DrivingDistance + r.PTOMovingDistance END AS CorneringTotal,
			CASE WHEN ic.IndicatorId = 24 THEN 1 END AS CorneringUsed,
		
			CASE WHEN ic.IndicatorId = 33 THEN abc.AccelerationLow END AS wAccelerationLow,
			CASE WHEN ic.IndicatorId = 33 THEN r.DrivingDistance + r.PTOMovingDistance END AS AccelerationLowTotal,
			CASE WHEN ic.IndicatorId = 33 THEN 1 END AS AccelerationLowUsed,
		
			CASE WHEN ic.IndicatorId = 34 THEN abc.BrakingLow END AS wBrakingLow,
			CASE WHEN ic.IndicatorId = 34 THEN r.DrivingDistance + r.PTOMovingDistance END AS BrakingLowTotal,
			CASE WHEN ic.IndicatorId = 34 THEN 1 END AS BrakingLowUsed,
		
			CASE WHEN ic.IndicatorId = 35 THEN abc.CorneringLow END AS wCorneringLow,
			CASE WHEN ic.IndicatorId = 35 THEN r.DrivingDistance + r.PTOMovingDistance END AS CorneringLowTotal,
			CASE WHEN ic.IndicatorId = 35 THEN 1 END AS CorneringLowUsed, 		
		
			CASE WHEN ic.IndicatorId = 36 THEN abc.AccelerationHigh END AS wAccelerationHigh,
			CASE WHEN ic.IndicatorId = 36 THEN r.DrivingDistance + r.PTOMovingDistance END AS AccelerationHighTotal,
			CASE WHEN ic.IndicatorId = 36 THEN 1 END AS AccelerationHighUsed,
		
			CASE WHEN ic.IndicatorId = 37 THEN abc.BrakingHigh END AS wBrakingHigh,
			CASE WHEN ic.IndicatorId = 37 THEN r.DrivingDistance + r.PTOMovingDistance END AS BrakingHighTotal,
			CASE WHEN ic.IndicatorId = 37 THEN 1 END AS BrakingHighUsed,
		
			CASE WHEN ic.IndicatorId = 38 THEN abc.CorneringHigh END AS wCorneringHigh,
			CASE WHEN ic.IndicatorId = 38 THEN r.DrivingDistance + r.PTOMovingDistance END AS CorneringHighTotal,
			CASE WHEN ic.IndicatorId = 38 THEN 1 END AS CorneringHighUsed,	
	
			CASE WHEN ic.IndicatorId = 39 THEN abc.AccelerationLow + abc.BrakingLow + abc.CorneringLow END AS wManoeuvresLow,
			CASE WHEN ic.IndicatorId = 39 THEN r.DrivingDistance + r.PTOMovingDistance END AS ManoeuvresLowTotal,
			CASE WHEN ic.IndicatorId = 39 THEN 1 END AS ManoeuvresLowUsed,	

			CASE WHEN ic.IndicatorId = 40 THEN abc.Acceleration + abc.Braking + abc.Cornering END AS wManoeuvresMed,
			CASE WHEN ic.IndicatorId = 40 THEN r.DrivingDistance + r.PTOMovingDistance END AS ManoeuvresMedTotal,
			CASE WHEN ic.IndicatorId = 40 THEN 1 END AS ManoeuvresMedUsed,	
	
			CASE WHEN ic.IndicatorId = 25 THEN 1 END AS CruiseTopGearRatioUsed,
		
			CASE WHEN ic.IndicatorId = 28 THEN r.ORCount END AS wORCount,
			CASE WHEN ic.IndicatorId = 28 THEN r.DrivingDistance + r.PTOMovingDistance END AS ORCountTotal,
			CASE WHEN ic.IndicatorId = 28 THEN 1 END AS ORCountUsed,
			
			CASE WHEN ic.IndicatorId = 29 THEN r.PTOMovingTime + PTONonMovingTime END AS wPTOTime,
			CASE WHEN ic.IndicatorId = 29 THEN r.TotalTime END AS PTOTotal,
			CASE WHEN ic.IndicatorId = 29 THEN 1 END AS PTOUsed,

			CASE WHEN ic.IndicatorId = 16 THEN r.TotalFuel END AS wTotalFuel,
			CASE WHEN ic.IndicatorId = 16 THEN r.DrivingDistance + r.PTOMovingDistance END AS FuelEconTotal,

			CASE WHEN ic.IndicatorId = 42 THEN r.TopGearSpeedingDistance END AS wTopGearOverSpeed,
			CASE WHEN ic.IndicatorId = 42 THEN r.OverSpeedThresholdDistance END AS TopGearOverSpeedTotal,
			CASE WHEN ic.IndicatorId = 42 THEN 1 END AS TopGearOverSpeedUsed,

			CASE WHEN ic.IndicatorId = 43 THEN r.CruiseSpeedingDistance END AS wCruiseOverSpeed,
			CASE WHEN ic.IndicatorId = 43 THEN r.OverSpeedThresholdDistance END AS CruiseOverSpeedTotal,
			CASE WHEN ic.IndicatorId = 43 THEN 1 END AS CruiseOverSpeedUsed,

			CASE WHEN ic.IndicatorId = 44 THEN ISNULL(r.FuelWastage,0) END AS wFuelWastage

	FROM dbo.Reporting r		
		INNER JOIN dbo.Vehicle v ON r.VehicleIntId = v.VehicleIntId
		INNER JOIN @VehicleConfig vc ON v.VehicleId = vc.Vid
		INNER JOIN dbo.IndicatorConfig ic ON vc.ReportConfigId = ic.ReportConfigurationId

		--INNER JOIN dbo.Driver d ON r.DriverIntId = d.DriverIntId
		LEFT JOIN dbo.ReportingABC abc ON r.VehicleIntId = abc.VehicleIntId AND r.DriverIntId = abc.DriverIntId AND r.Date = abc.Date --AND r.RouteID = abc.RouteId
		LEFT JOIN dbo.ReportingOverspeed ro ON r.VehicleIntId = ro.VehicleIntId AND r.DriverIntId = ro.DriverIntId AND r.Date = ro.Date --AND r.RouteID = ro.RouteId
	WHERE r.Date BETWEEN @lsdate AND @ledate 
	  AND r.DrivingDistance > 0
	  AND ic.Archived = 0
	) raw
GROUP BY raw.VehicleIntId

SELECT
		-- Week identifiers
		NULL AS WeekNum,
		NULL AS WeekStartDate,
		NULL AS WeekEndDate,
		
		-- Vehicle and Driver Identification columns
		NULL AS	VehicleId,	
		NULL AS Registration,
		
		NULL AS DriverId,
 		NULL AS DisplayName,
 		NULL AS DriverName, -- included for backward compatibility
 		NULL AS FirstName,
 		NULL AS Surname,
 		NULL AS MiddleNames,
 		NULL AS Number,
 		NULL AS NumberAlternate,
 		NULL AS NumberAlternate2,

 		--[0], [1], [2], [3], [4], [97], [98], [99],

		[4] AS Coached,
		[3] + [97] AS NotRequired,
		[1] + [2] AS NotCoached,
 		
 		-- Data columns with corresponding colours below 
		SweetSpot, 
		OverRevWithFuel, 
		TopGear, 
		Cruise, 
		CruiseInTopGears,
		CoastInGear, 
		Idle, 
		EngineServiceBrake, 
		OverRevWithoutFuel, 
		Rop,
		Rop2, 
		OverSpeed,
		OverSpeedHigh,
		OverSpeedDistance, 
		IVHOverSpeed,
		CoastOutOfGear, 
		HarshBraking, 
		FuelEcon,
		Pto, 
		Co2, 
		CruiseTopGearRatio,
		Acceleration, 
		Braking, 
		Cornering,
		AccelerationLow, 
		BrakingLow, 
		CorneringLow,
		AccelerationHigh, 
		BrakingHigh, 
		CorneringHigh,
		ManoeuvresLow,
		ManoeuvresMed,
		CruiseOverspeed,
		TopGearOverspeed,
		FuelWastage * @fuelcost AS FuelWastageCost,

		-- Component Columns
		SweetSpotComponent,
		OverRevWithFuelComponent,
		TopGearComponent,
		CruiseComponent,
		CruiseInTopGearsComponent,
		CruiseTopGearRatioComponent,
		IdleComponent,
		EngineServiceBrakeComponent,
		OverRevWithoutFuelComponent,
		RopComponent,
		Rop2Component,
		OverSpeedComponent,
		OverSpeedHighComponent,
		OverSpeedDistanceComponent,
		IVHOverSpeedComponent,
		CoastOutOfGearComponent,
		CoastInGearComponent,
		HarshBrakingComponent,
		AccelerationComponent,
		BrakingComponent,
		CorneringComponent,
		AccelerationLowComponent,
		BrakingLowComponent,
		CorneringLowComponent,
		AccelerationHighComponent,
		BrakingHighComponent,
		CorneringHighComponent,
		ManoeuvresLowComponent,
		ManoeuvresMedComponent,
		CruiseOverspeedComponent,
		TopGearOverspeedComponent,
		
		-- Score columns
		Efficiency, 
		Safety,

		-- Additional columns with no corresponding colour	
		TotalTime,
		TotalDrivingDistance,
		ServiceBrakeUsage,	
		OverRevCount,
		
		-- Date and Unit columns 
		@lsdate AS sdate,
		@ledate AS edate,
		[dbo].TZ_GetTime(@lsdate,default,@luid) AS CreationDateTime,
		[dbo].TZ_GetTime(@ledate,default,@luid) AS ClosureDateTime,

		@diststr AS DistanceUnit,
		@fuelstr AS FuelUnit,
		@co2str AS Co2Unit,
		@fuelmult AS FuelMult,
		@currency AS Currency,

		-- Colour columns corresponding to data columns above (all set to NULL for Fleet Report)
		NULL AS SweetSpotColour, NULL AS SweetSpotMix,
		NULL AS OverRevWithFuelColour, NULL AS OverRevWithFuelMix,
		NULL AS TopGearColour, NULL AS TopGearMix,
		NULL AS CruiseColour, NULL AS CruiseMix,
		NULL AS CruiseInTopGearsColour, NULL AS CruiseInTopGearsMix,
		NULL AS CoastInGearColour, NULL AS CoastInGearMix,
		NULL AS IdleColour, NULL AS IdleMix,
		NULL AS EngineServiceBrakeColour, NULL AS EngineServiceBrakeMix,
		NULL AS OverRevWithoutFuelColour, NULL AS OverRevWithoutFuelMix,
		NULL AS RopColour, NULL AS RopMix,
		NULL AS Rop2Colour, NULL AS  Rop2Mix,
		NULL AS OverSpeedColour, NULL AS OverSpeedMix,
		NULL AS OverSpeedHighColour, NULL AS OverSpeedHighMix,
		NULL AS IVHOverSpeedColour, NULL AS IVHOverSpeedMix,
		NULL AS CoastOutOfGearColour, NULL AS CoastOutOfGearMix,
		NULL AS HarshBrakingColour, NULL AS HarshBrakingMix,
		NULL AS EfficiencyColour, NULL AS EfficiencyMix,
		NULL AS SafetyColour, NULL AS SafetyMix,
		NULL AS KPLColour, NULL AS KPLMix,
		NULL AS Co2Colour, NULL AS Co2Mix,
		NULL AS OverSpeedDistanceColour, NULL AS OverSpeedDistanceMix,
		NULL AS AccelerationColour, NULL AS AccelerationMix,
		NULL AS BrakingColour, NULL AS BrakingMix,
		NULL AS CorneringColour, NULL AS CorneringMix,
		NULL AS AccelerationLowColour, NULL AS AccelerationLowMix,
		NULL AS BrakingLowColour, NULL AS BrakingLowMix,
		NULL AS CorneringLowColour, NULL AS CorneringLowMix,
		NULL AS AccelerationHighColour, NULL AS AccelerationHighMix,
		NULL AS BrakingHighColour, NULL AS BrakingHighMix,
		NULL AS CorneringHighColour, NULL AS CorneringHighMix,
		NULL AS ManoeuvresLowColour, NULL AS ManoeuvresLowMix,
		NULL AS ManoeuvresMedColour, NULL AS ManoeuvresMedMix,
		NULL AS CruiseTopGearRatioColour, NULL AS CruiseTopGearRatioMix,
		NULL AS OverRevCountColour, NULL AS OverRevCountMix,
		NULL AS PtoColour, NULL AS PtoMix,
		NULL AS CruiseOverspeedColour, NULL AS CruiseOverspeedMix,
		NULL AS TopGearOverspeedColour, NULL AS TopGearOverspeedMix,
		NULL AS FuelWastageCostColour

FROM
	(SELECT *,
		
		Safety = dbo.ScoreByClassAndConfig('S', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, TopGearOverspeed, CruiseOverspeed, @lrprtcfgid),
		Efficiency = dbo.ScoreByClassAndConfig('E', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, TopGearOverspeed, CruiseOverspeed, @lrprtcfgid),

		SweetSpotComponent = dbo.ScoreComponentValueConfig(1, SweetSpot, @lrprtcfgid),
		OverRevWithFuelComponent = dbo.ScoreComponentValueConfig(2, OverRevWithFuel, @lrprtcfgid),
		TopGearComponent = dbo.ScoreComponentValueConfig(3, TopGear, @lrprtcfgid),
		CruiseComponent = dbo.ScoreComponentValueConfig(4, Cruise, @lrprtcfgid),
		CruiseInTopGearsComponent = dbo.ScoreComponentValueConfig(31, CruiseInTopGears, @lrprtcfgid),
		CruiseTopGearRatioComponent = dbo.ScoreComponentValueConfig(25, CruiseTopGearRatio, @lrprtcfgid),
		IdleComponent = dbo.ScoreComponentValueConfig(6, Idle, @lrprtcfgid),
		AccelerationComponent = dbo.ScoreComponentValueConfig(22, Acceleration, @lrprtcfgid),
		BrakingComponent = dbo.ScoreComponentValueConfig(23, Braking, @lrprtcfgid),
		CorneringComponent = dbo.ScoreComponentValueConfig(24, Cornering, @lrprtcfgid),
		AccelerationLowComponent = dbo.ScoreComponentValueConfig(33, AccelerationLow, @lrprtcfgid),
		BrakingLowComponent = dbo.ScoreComponentValueConfig(34, BrakingLow, @lrprtcfgid),
		CorneringLowComponent = dbo.ScoreComponentValueConfig(35, CorneringLow, @lrprtcfgid),
		AccelerationHighComponent = dbo.ScoreComponentValueConfig(36, AccelerationHigh, @lrprtcfgid),
		BrakingHighComponent = dbo.ScoreComponentValueConfig(37, BrakingHigh, @lrprtcfgid),
		CorneringHighComponent = dbo.ScoreComponentValueConfig(38, CorneringHigh, @lrprtcfgid),
		ManoeuvresLowComponent = dbo.ScoreComponentValueConfig(39, ManoeuvresLow, @lrprtcfgid),
		ManoeuvresMedComponent = dbo.ScoreComponentValueConfig(40, ManoeuvresMed, @lrprtcfgid),
		EngineServiceBrakeComponent = dbo.ScoreComponentValueConfig(7, EngineServiceBrake, @lrprtcfgid),
		OverRevWithoutFuelComponent = dbo.ScoreComponentValueConfig(8, OverRevWithoutFuel, @lrprtcfgid),
		RopComponent = dbo.ScoreComponentValueConfig(9, Rop, @lrprtcfgid),
		Rop2Component = dbo.ScoreComponentValueConfig(41, Rop2, @lrprtcfgid),
		OverSpeedComponent = dbo.ScoreComponentValueConfig(10, OverSpeed, @lrprtcfgid),
		OverSpeedHighComponent = dbo.ScoreComponentValueConfig(32, OverSpeedHigh, @lrprtcfgid),
		OverSpeedDistanceComponent = dbo.ScoreComponentValueConfig(21, OverSpeedDistance, @lrprtcfgid),
		IVHOverSpeedComponent = dbo.ScoreComponentValueConfig(30, IVHOverSpeed, @lrprtcfgid),
		CoastOutOfGearComponent = dbo.ScoreComponentValueConfig(11, CoastOutOfGear, @lrprtcfgid),
		CoastInGearComponent = dbo.ScoreComponentValueConfig(5, CoastInGear, @lrprtcfgid),
		HarshBrakingComponent = dbo.ScoreComponentValueConfig(12, HarshBraking, @lrprtcfgid),
		CruiseOverspeedComponent = dbo.ScoreComponentValueConfig(43, CruiseOverspeed, @lrprtcfgid),
		TopGearOverspeedComponent = dbo.ScoreComponentValueConfig(42, TopGearOverspeed, @lrprtcfgid)

	FROM
		(SELECT

			-- Add summation of coaching status columns here
			SUM([0]) AS [0],
			SUM([1]) AS [1],
			SUM([2]) AS [2],
			SUM([3]) AS [3],
			SUM([4]) AS [4],
			SUM([97]) AS [97],
			SUM([98]) AS [98],
			SUM([99]) AS [99],

			-- For each component use the weighted value rather than the Reporting value so that vehicle configs have been accounted for
			SUM(wInSweetSpotDistance) / dbo.ZeroYieldNull(SUM(InSweetSpotTotal)) AS SweetSpot,
			SUM(wFueledOverRPMDistance) / dbo.ZeroYieldNull(SUM(FueledOverRPMTotal)) AS OverRevWithFuel,
			SUM(wTopGearDistance) / dbo.ZeroYieldNull(SUM(TopGearTotal)) AS TopGear,
			SUM(wCruiseControlDistance) / dbo.ZeroYieldNull(SUM(CruiseTotal)) AS Cruise,
			--Proof of concept. CruiseInTopGearsDistance should be used in production as soon as firmware is released.
			dbo.CAP(SUM(wCruiseInTopGearsDistance) / dbo.ZeroYieldNull(SUM(CruiseInTopGearsTotal)), 1.0) AS CruiseInTopGears,
			--SUM(CruiseInTopGearsDistance) / dbo.ZeroYieldNull(SUM(TopGearDistance + ISNULL(GearDownDistance,0))) AS CruiseInTopGears,
			SUM(wCoastInGearDistance) / dbo.ZeroYieldNull(SUM(CoastInGearTotal)) AS CoastInGear,
			SUM(wCruiseControlDistance) / dbo.ZeroYieldNull(SUM(wTopGearDistance)) AS CruiseTopGearRatio,
			CAST(SUM(wIdleTime) AS float) / dbo.ZeroYieldNull(SUM(IdleTotal)) AS Idle,
			CAST(SUM(wPTOTime) AS float) / dbo.ZeroYieldNull(SUM(PTOTotal)) AS Pto,
			ISNULL((SUM(TotalFuel) * 2639.1 * @co2mult) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)),0) AS Co2, --@co2mult: 1 for g/km, 1.6 for g/miles
			SUM(wServiceBrakeDistance) / dbo.ZeroYieldNull(SUM(ServiceBrakeTotal)) AS ServiceBrakeUsage,
			ISNULL(SUM(EngineBrakeDistance) / dbo.ZeroYieldNull(SUM(ServiceBrakeDistance + EngineBrakeDistance)),0) AS EngineServiceBrake,
			SUM(wEngineBrakeOverRPMDistance) / dbo.ZeroYieldNull(SUM(EngineBrakeOverRPMTotal)) AS OverRevWithoutFuel,
			ISNULL((SUM(wROPCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(ROPTotal) * @distmult * 1000))))),0) AS Rop,
			ISNULL((SUM(wROP2Count) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(ROP2Total) * @distmult * 1000))))),0) AS Rop2,
			ISNULL(SUM(wOverSpeedDistance) / dbo.ZeroYieldNull(SUM(OverSpeedTotal)),0) AS OverSpeed,
			ISNULL(SUM(wOverSpeedHighDistance) / dbo.ZeroYieldNull(SUM(OverSpeedHighTotal)),0) AS OverSpeedHigh,
			ISNULL(SUM(wOverSpeedDistance) / dbo.ZeroYieldNull(SUM(OverSpeedTotal)),0) AS OverSpeedDistance, 
			ISNULL(SUM(wOverSpeedDistance) / dbo.ZeroYieldNull(SUM(IVHOverSpeedTotal)),0) AS IVHOverSpeed,
			ISNULL(SUM(wCoastOutOfGearDistance) / dbo.ZeroYieldNull(SUM(CoastOutOfGearTotal)),0) AS CoastOutOfGear,
			ISNULL((SUM(wPanicStopCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(PanicStopTotal) * @distmult * 1000))))),0) AS HarshBraking,
			ISNULL((SUM(wORCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(ORCountTotal) * @distmult * 1000))))),0) AS OverRevCount,
			ISNULL((SUM(wAcceleration) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(AccelerationTotal) * @distmult * 1000))))),0) AS Acceleration,
			ISNULL((SUM(wBraking) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(BrakingTotal) * @distmult * 1000))))),0) AS Braking,
			ISNULL((SUM(wCornering) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(CorneringTotal) * @distmult * 1000))))),0) AS Cornering,
			ISNULL((SUM(wAccelerationLow) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(AccelerationLowTotal) * @distmult * 1000))))),0) AS AccelerationLow,
			ISNULL((SUM(wBrakingLow) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(BrakingLowTotal) * @distmult * 1000))))),0) AS BrakingLow,
			ISNULL((SUM(wCorneringLow) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(CorneringLowTotal) * @distmult * 1000))))),0) AS CorneringLow,
			ISNULL((SUM(wAccelerationHigh) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(AccelerationHighTotal) * @distmult * 1000))))),0) AS AccelerationHigh,
			ISNULL((SUM(wBrakingHigh) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(BrakingHighTotal) * @distmult * 1000))))),0) AS BrakingHigh,
			ISNULL((SUM(wCorneringHigh) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(CorneringHighTotal) * @distmult * 1000))))),0) AS CorneringHigh,
			ISNULL((SUM(wManoeuvresLow) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(ManoeuvresLowTotal) * @distmult * 1000))))),0) AS ManoeuvresLow,
			ISNULL((SUM(wManoeuvresMed) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(ManoeuvresMedTotal) * @distmult * 1000))))),0) AS ManoeuvresMed,

			ISNULL(SUM(wCruiseOverSpeed) / dbo.ZeroYieldNull(SUM(CruiseOverSpeedTotal)), 0) AS CruiseOverspeed,
			ISNULL(SUM(wTopGearOverSpeed) / dbo.ZeroYieldNull(SUM(w.TopGearOverSpeedTotal)), 0) AS TopGearOverspeed,
			SUM(wFuelWastage) AS FuelWastage,

			(CASE WHEN @fuelmult = 0.1 THEN
				(CASE WHEN SUM(wTotalFuel)=0 THEN NULL ELSE SUM(wTotalFuel * ISNULL(FuelMultiplier,1.0))*100 END)/SUM(FuelEconTotal) 
			ELSE
				(SUM(FuelEconTotal) * 1000) / (CASE WHEN SUM(wTotalFuel)=0 THEN NULL ELSE SUM(wTotalFuel * ISNULL(FuelMultiplier,1.0)) END) * @fuelmult END) AS FuelEcon,
				
			SUM(DrivingDistance * 1000 * @distmult) AS TotalDrivingDistance,
			SUM(TotalTime) AS TotalTime				
		FROM dbo.Reporting r
--			CROSS JOIN @weightedData w --ON r.Date = w.Date AND r.VehicleIntId = w.VehicleIntId AND r.DriverIntId = w.DriverIntId
			INNER JOIN dbo.Vehicle v ON r.VehicleIntId = v.VehicleIntId
			INNER JOIN dbo.Driver d ON r.DriverIntId = d.DriverIntId
			INNER JOIN @weighteddata w ON r.VehicleIntId = w.VehicleIntId
			LEFT JOIN dbo.ReportingABC abc ON r.VehicleIntId = abc.VehicleIntId AND r.DriverIntId = abc.DriverIntId AND r.Date = abc.Date --AND r.RouteID = abc.RouteId
			LEFT JOIN dbo.ReportingOverspeed ro ON r.VehicleIntId = ro.VehicleIntId AND r.DriverIntId = ro.DriverIntId AND r.Date = ro.Date --AND r.RouteID = ro.RouteId
			LEFT JOIN (SELECT	VehicleIntId, DriverIntId, CAST(FLOOR(CAST(EventDateTime AS FLOAT)) AS DATETIME) AS Date, SUM([0]) AS [0], SUM([1]) AS [1], SUM([2]) AS [2], SUM([3]) AS [3], SUM([4]) AS [4], SUM([97]) AS [97], SUM([98]) AS [98], SUM([99]) AS [99]
						FROM dbo.CAM_Incident i
						PIVOT (COUNT(IncidentId) FOR CoachingStatusId IN ([0], [1], [2], [3], [4], [97], [98], [99])) AS StatusCount
						--WHERE DriverIntId IN (SELECT dbo.GetDriverIntFromId(value) FROM dbo.Split(@dids, ','))
						WHERE EventDateTime BETWEEN @sdate AND @edate
						  AND CreationCodeId IN (7, 36, 37, 38, 336, 337, 338, 436, 437, 438, 455, 456)
						  AND VehicleIntId IN (SELECT DISTINCT VehicleIntId FROM @weightedData)
						GROUP BY VehicleIntId, DriverIntId, FLOOR(CAST(EventDateTime AS FLOAT))) cs ON cs.VehicleIntId = v.VehicleIntId AND cs.DriverIntId = d.DriverIntId AND cs.Date = r.Date

		WHERE r.Date BETWEEN @lsdate AND @ledate 
		  --AND (v.VehicleId IN (SELECT Value FROM dbo.Split(dbo.GetFleetVids(@luid), ',')) OR dbo.GetFleetVids(@luid) IS NULL)
          AND r.DrivingDistance > 0
		HAVING SUM(DrivingDistance) > 10 ) o
	) p

GO
