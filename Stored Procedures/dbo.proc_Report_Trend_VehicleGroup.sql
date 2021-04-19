SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_Report_Trend_VehicleGroup]
(
	@vids varchar(max), 
	@gids varchar(max), 
	@sdate datetime,
	@edate datetime,
	@routeid INT,
	@vehicletypeid INT,	
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER,
	@drilldown TINYINT,
	@calendar TINYINT,
	@groupBy INT
)
AS

--DECLARE @vids varchar(max),
--		@gids VARCHAR(max),
--		@routeid INT,
--		@vehicletypeid INT,	
--		@sdate datetime,
--		@edate datetime,
--		@uid UNIQUEIDENTIFIER,
--		@rprtcfgid UNIQUEIDENTIFIER,
--		@drilldown TINYINT,
--		@calendar TINYINT,
--		@groupBy int	
		
--SET @vids = N'A8DC179E-04AB-4483-9141-A95F46B0968B'
--SET @gids = N'906E3BAD-7739-44B1-8966-28F8D4F10A09'
----SET @gids = N'B04062C4-67FA-41A9-9BFC-4776782653B4'
--SET @vehicletypeid = NULL
--SET @routeid = NULL
--SET	@sdate = '2016-03-21 00:00'
--SET	@edate = '2016-06-19 23:59'
--SET	@uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
--SET	@rprtcfgid = N'77C80BDB-5827-4C5E-BBF4-06F36ACB47D6'
--SET @drilldown = 1
--SET @calendar = 0
--SET @groupBy = 0

DECLARE @lvids varchar(max), 
		@lgids varchar(max), 
		@lsdate datetime,
		@ledate datetime,
		@lrouteid INT,
		@lvehicletypeid INT,	
		@luid UNIQUEIDENTIFIER,
		@lrprtcfgid UNIQUEIDENTIFIER,
		@ldrilldown TINYINT,
		@lcalendar TINYINT,
		@lgroupBy INT

SET @lvids = @vids
SET @lgids = @gids
SET @lsdate = @sdate
SET @ledate = @edate
SET @lrouteid = @routeid
SET @lvehicletypeid = @vehicletypeid
SET @luid = @uid
SET @lrprtcfgid = @rprtcfgid
SET @ldrilldown = @drilldown
SET @lcalendar = @calendar
SET @lgroupBy = @groupBy

DECLARE @diststr varchar(20),
		@distmult float,
		@fuelstr varchar(20),
		@fuelmult float,
		@fuelcost FLOAT,
		@currency NVARCHAR(10),
		@co2str varchar(20),
		@co2mult FLOAT,
		@liquidstr VARCHAR(20),
		@liquidmult float

SELECT @diststr = [dbo].UserPref(@luid, 203)
SELECT @distmult = [dbo].UserPref(@luid, 202)
SELECT @fuelstr = [dbo].UserPref(@luid, 205)
SELECT @fuelmult = [dbo].UserPref(@luid, 204)
SELECT @co2str = [dbo].UserPref(@luid, 211)
SELECT @co2mult = [dbo].UserPref(@luid, 210)
SELECT @liquidstr = [dbo].UserPref(@luid, 201)
SELECT @liquidmult = [dbo].UserPref(@luid, 200)
SELECT @currency = [dbo].UserPref(@luid, 381)

SELECT @fuelcost = CAST(cp.Value AS FLOAT)
FROM dbo.[User] u
INNER JOIN dbo.CustomerPreference cp ON cp.CustomerID = u.CustomerID
WHERE u.UserID = @luid
  AND cp.NameID = 3007

-- Determine period sizes based upon provided start date and end date total duration -- use dates in user time zone

DECLARE @period_dates TABLE (
		PeriodNum TINYINT IDENTITY (1,1),
		StartDate DATETIME,
		EndDate DATETIME,
		PeriodType VARCHAR(MAX))
      
INSERT  INTO @period_dates ( StartDate, EndDate, PeriodType )
        SELECT  StartDate,
                EndDate,
                PeriodType
        FROM    dbo.CreateDependentDateRange_Local(@lsdate, @ledate, @luid, @ldrilldown, @lcalendar, @lgroupBy)

-- Convert dates to UTC
--SET @lsdate = [dbo].TZ_ToUTC(@lsdate,default,@luid)
--SET @ledate = [dbo].TZ_ToUTC(@ledate,default,@luid)

-- Create temporary table for vehicle configs
DECLARE @VehicleConfig TABLE
(
	Vid UNIQUEIDENTIFIER,
	ReportConfigId UNIQUEIDENTIFIER
)

-- Get configs by vehicle
-- The table will be populated by a specific vehicle config if one exists, other wise the default config will be populated instead
INSERT INTO @VehicleConfig (Vid, ReportConfigId)
SELECT DISTINCT v.VehicleId, ISNULL(vrc.ReportConfigurationId, @lrprtcfgid)
FROM dbo.Vehicle v
INNER JOIN dbo.GroupDetail gd ON gd.EntityDataId = v.VehicleId
INNER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId
LEFT JOIN dbo.VehicleReportConfiguration vrc ON v.VehicleId = vrc.VehicleId
WHERE (v.VehicleId IN (SELECT Value FROM dbo.Split(@lvids, ',')) OR @lvids IS NULL)
  AND g.IsParameter = 0 
  AND g.Archived = 0 
  AND g.GroupId IN (SELECT Value FROM dbo.Split(@lgids, ','))

DECLARE @data TABLE 
(
		PeriodNum TINYINT,

		VehicleId UNIQUEIDENTIFIER,	
		Registration VARCHAR(MAX),

		ReportConfigId UNIQUEIDENTIFIER,
 		
 		GroupId UNIQUEIDENTIFIER,
 		GroupName NVARCHAR(MAX),
 		
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
		
		Efficiency FLOAT, 
		Safety FLOAT,
		
		TotalTime FLOAT,
		TotalDrivingDistance FLOAT,
		ServiceBrakeUsage FLOAT,	
		EngineBrakeUsage FLOAT,
		OverRevCount FLOAT
)

INSERT INTO @data
        ( PeriodNum ,
          VehicleId ,
          Registration ,
		  ReportConfigId ,
          GroupId ,
          GroupName ,
		  SweetSpot , 
		  OverRevWithFuel ,
		  TopGear ,
		  Cruise ,
		  CruiseInTopGears ,
		  CoastInGear ,
		  Idle ,
		  EngineServiceBrake ,
		  OverRevWithoutFuel ,
		  Rop ,
		  Rop2 ,
		  OverSpeed ,
		  OverSpeedHigh ,
		  OverSpeedDistance ,
		  IVHOverSpeed ,

		  SpeedGauge,

		  CoastOutOfGear ,
		  HarshBraking ,
		  FuelEcon ,
		  Pto ,
		  Co2 ,
		  CruiseTopGearRatio ,
		  Acceleration ,
	      Braking ,
		  Cornering ,
		  AccelerationLow ,
		  BrakingLow ,
		  CorneringLow ,
		  AccelerationHigh ,
		  BrakingHigh ,
		  CorneringHigh ,
		  ManoeuvresLow ,
		  ManoeuvresMed ,
		  CruiseOverspeed,
		  TopGearOverspeed,
		  FuelWastageCost,
		  OverspeedCount,
		  OverspeedHighCount,
		  StabilityControl,
		  CollisionWarningLow,
		  CollisionWarningMed,
		  CollisionWarningHigh,
		  LaneDepartureDisable,
		  LaneDepartureLeftRight,
		  SweetSpotTime,
		  OverRevTime,
		  TopGearTime,
		  Fatigue,
		  Distraction,
          Efficiency ,
          Safety ,
          TotalTime ,
          TotalDrivingDistance ,
          ServiceBrakeUsage ,
          EngineBrakeUsage ,
          OverRevCount 
        )

SELECT
		-- Vehicle, Driver and Group Identification columns
		p.PeriodNum,

		v.VehicleId AS VehicleId,	
		v.Registration AS Registration,
		
		ISNULL(ReportConfigId, @lrprtcfgid) AS ReportConfigId,
 		
 		g.GroupId AS GroupId,
 		g.GroupName AS GroupName,
 		
 		-- Data columns with corresponding colours below 
		SweetSpot, OverRevWithFuel, TopGear, Cruise, 
		CruiseInTopGears,
		CoastInGear,
		Idle, EngineServiceBrake, OverRevWithoutFuel, 
		Rop, Rop2, OverSpeed, 
		OverSpeedHigh, OverSpeedDistance,
		IVHOverSpeed,SpeedGauge, CoastOutOfGear, HarshBraking, FuelEcon,
		Pto, Co2, CruiseTopGearRatio,
		Acceleration, Braking, Cornering,
		AccelerationLow, BrakingLow, CorneringLow,
		AccelerationHigh, BrakingHigh, CorneringHigh,
		ManoeuvresLow,
		ManoeuvresMed,
		CruiseOverspeed,
		TopGearOverspeed,
		FuelWastage * @fuelcost AS FuelWastageCost,
		OverspeedCount,
		OverspeedHighCount,
		StabilityControl,
		CollisionWarningLow,
		CollisionWarningMed,
		CollisionWarningHigh,
		LaneDepartureDisable,
		LaneDepartureLeftRight,
		SweetSpotTime,
		OverRevTime,
		TopGearTime,
		Fatigue,
		Distraction,

		-- Score columns
		0 AS Efficiency, 
		0 AS Safety,
		
		-- Additional columns with no corresponding colour	
		TotalTime,
		TotalDrivingDistance,
		ServiceBrakeUsage,
		0 AS EngineBrakeUsage,	
		OverRevCount
		
FROM
	(SELECT
		CASE WHEN (GROUPING(p.PeriodNum) = 1) THEN NULL
			ELSE ISNULL(p.PeriodNum, NULL)
		END AS PeriodNum,

		CASE WHEN (GROUPING(v.VehicleId) = 1) THEN NULL
			ELSE ISNULL(v.VehicleId, NULL)
		END AS VehicleId,
							
		CASE WHEN (GROUPING(gd.GroupId) = 1) THEN NULL
			ELSE ISNULL(gd.GroupId, NULL)
		END AS GroupId,

		-- For each component use the weighted value rather than the Reporting value so that vehicle configs have been accounted for
		ISNULL(SUM(InSweetSpotDistance) / dbo.ZeroYieldNull(SUM(r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0))),0) AS SweetSpot,
		ISNULL(SUM(FueledOverRPMDistance) / dbo.ZeroYieldNull(SUM(r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0))),0) AS OverRevWithFuel,
		ISNULL(SUM(TopGearDistance) / dbo.ZeroYieldNull(SUM(r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0))),0) AS TopGear,
		ISNULL(SUM(CruiseControlDistance) / dbo.ZeroYieldNull(SUM(r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0))),0) AS Cruise,
		--Proof of concept. CruiseInTopGearsDistance should be used in production as soon as firmware is released.
		dbo.CAP(ISNULL(SUM(CruiseInTopGearsDistance) / dbo.ZeroYieldNull(SUM(r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0))),0), 1.0) AS CruiseInTopGears,
		--SUM(CruiseInTopGearsDistance) / dbo.ZeroYieldNull(SUM(TopGearDistance + ISNULL(GearDownDistance,0))) AS CruiseInTopGears,
		ISNULL(SUM(CoastInGearDistance) / dbo.ZeroYieldNull(SUM(r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0))),0) AS CoastInGear,
		ISNULL(SUM(CruiseControlDistance) / dbo.ZeroYieldNull(SUM(r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0))),0) AS CruiseTopGearRatio,
		ISNULL(CAST(SUM(IdleTime) AS float) / dbo.ZeroYieldNull(SUM(r.TotalTime)),0) AS Idle,
		ISNULL(CAST(SUM(r.PTOMovingTime + PTONonMovingTime) AS float) / dbo.ZeroYieldNull(SUM(r.PTOMovingTime + PTONonMovingTime)),0) AS Pto,
		ISNULL((SUM(TotalFuel) * 2639.1 * @co2mult) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)),0) AS Co2, --@co2mult: 1 for g/km, 1.6 for g/miles
		ISNULL(SUM(ServiceBrakeDistance) / dbo.ZeroYieldNull(SUM(r.ServiceBrakeDistance + r.EngineBrakeDistance)),0) AS ServiceBrakeUsage,
		ISNULL(SUM(EngineBrakeDistance) / dbo.ZeroYieldNull(SUM(ServiceBrakeDistance + EngineBrakeDistance)),0) AS EngineServiceBrake,
		ISNULL(SUM(EngineBrakeOverRPMDistance) / dbo.ZeroYieldNull(SUM(r.EngineBrakeDistance)),0) AS OverRevWithoutFuel,
		ISNULL((SUM(ROPCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0)) * @distmult * 1000))))),0) AS Rop,
		ISNULL((SUM(ROP2Count) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0)) * @distmult * 1000))))),0) AS Rop2,
		ISNULL(SUM(ro.OverSpeedDistance) / dbo.ZeroYieldNull(SUM(r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0))),0) AS OverSpeed,
		ISNULL(SUM(OverSpeedHighDistance) / dbo.ZeroYieldNull(SUM(r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0))),0) AS OverSpeedHigh,
		ISNULL(SUM(ro.OverSpeedDistance) / dbo.ZeroYieldNull(SUM(r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0))),0) AS OverSpeedDistance, 
		ISNULL(SUM(r.OverSpeedDistance) / dbo.ZeroYieldNull(SUM(r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0))),0) AS IVHOverSpeed,

		ISNULL(SUM(ro.Incidents) / CAST(SUM(ro.Observations) AS FLOAT), 0) AS SpeedGauge,

		ISNULL(SUM(CoastOutOfGearDistance) / dbo.ZeroYieldNull(SUM(r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0))),0) AS CoastOutOfGear,
		ISNULL((SUM(PanicStopCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0)) * @distmult * 1000))))),0) AS HarshBraking,
		ISNULL((SUM(ORCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0)) * @distmult * 1000))))),0) AS OverRevCount,
		ISNULL((SUM(Acceleration) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0)) * @distmult * 1000))))),0) AS Acceleration,
		ISNULL((SUM(Braking) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0)) * @distmult * 1000))))),0) AS Braking,
		ISNULL((SUM(Cornering) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0)) * @distmult * 1000))))),0) AS Cornering,
		ISNULL((SUM(AccelerationLow) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0)) * @distmult * 1000))))),0) AS AccelerationLow,
		ISNULL((SUM(BrakingLow) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0)) * @distmult * 1000))))),0) AS BrakingLow,
		ISNULL((SUM(CorneringLow) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0)) * @distmult * 1000))))),0) AS CorneringLow,
		ISNULL((SUM(AccelerationHigh) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0)) * @distmult * 1000))))),0) AS AccelerationHigh,
		ISNULL((SUM(BrakingHigh) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0)) * @distmult * 1000))))),0) AS BrakingHigh,
		ISNULL((SUM(CorneringHigh) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0)) * @distmult * 1000))))),0) AS CorneringHigh,
		ISNULL((SUM(abc.AccelerationLow + abc.BrakingLow + abc.CorneringLow) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0)) * @distmult * 1000))))),0) AS ManoeuvresLow,
		ISNULL((SUM(abc.Acceleration + abc.Braking + abc.Cornering) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0)) * @distmult * 1000))))),0) AS ManoeuvresMed,

		ISNULL(SUM(r.CruiseSpeedingDistance) / dbo.ZeroYieldNull(SUM(r.OverSpeedThresholdDistance)), 0) AS CruiseOverspeed,
		ISNULL(SUM(r.TopGearSpeedingDistance) / dbo.ZeroYieldNull(SUM(r.OverSpeedThresholdDistance)), 0) AS TopGearOverspeed,
		SUM(r.FuelWastage) AS FuelWastage,

		ISNULL((SUM(OverspeedCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0)) * @distmult * 1000))))),0) AS OverspeedCount,
		ISNULL((SUM(OverspeedHighCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0)) * @distmult * 1000))))),0) AS OverspeedHighCount,
		ISNULL((SUM(StabilityCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0)) * @distmult * 1000))))),0) AS StabilityControl,
		ISNULL((SUM(CollisionWarningLow) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0)) * @distmult * 1000))))),0) AS CollisionWarningLow,
		ISNULL((SUM(CollisionWarningMed) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0)) * @distmult * 1000))))),0) AS CollisionWarningMed,
		ISNULL((SUM(CollisionWarningHigh) * (dbo.ZeroYieldNull(1000 /dbo.ZeroYieldNull((SUM(r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0)) * @distmult * 1000))))),0) AS CollisionWarningHigh,
		ISNULL((SUM(LaneDepartureDisableCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0)) * @distmult * 1000))))),0) AS LaneDepartureDisable,
		ISNULL((SUM(LaneDepartureLeftRightCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0)) * @distmult * 1000))))),0) AS LaneDepartureLeftRight,
		ISNULL(CAST(SUM(SweetSpotTime) AS float) / dbo.ZeroYieldNull(SUM(re.DrivingTime)),0) AS SweetSpotTime,
		ISNULL(CAST(SUM(OverRPMTime) AS float) / dbo.ZeroYieldNull(SUM(re.DrivingTime)),0) AS OverRevTime,
		ISNULL(CAST(SUM(TopGearTime) AS float) / dbo.ZeroYieldNull(SUM(re.DrivingTime)),0) AS TopGearTime,
		ISNULL((SUM(Fatigue) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0)) * @distmult * 1000))))),0) AS Fatigue,
		ISNULL((SUM(Distraction) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0)) * @distmult * 1000))))),0) AS Distraction,

		(CASE WHEN @fuelmult = 0.1 THEN
			(CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel * ISNULL(FuelMultiplier,1.0))*100 END)/SUM(DrivingDistance + PTOMovingDistance) 
		ELSE
			(SUM(DrivingDistance + PTOMovingDistance) * 1000) / (CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel * ISNULL(FuelMultiplier,1.0)) END) * @fuelmult END) AS FuelEcon,
			
		SUM(DrivingDistance * 1000 * @distmult) AS TotalDrivingDistance,
		SUM(TotalTime) AS TotalTime				
	FROM dbo.Reporting r
		INNER JOIN dbo.Vehicle v ON r.VehicleIntId = v.VehicleIntId
		INNER JOIN dbo.GroupDetail gd ON v.VehicleId = gd.EntityDataId AND gd.GroupTypeId = 1
		INNER JOIN @period_dates p ON r.Date BETWEEN p.StartDate AND p.EndDate
		LEFT JOIN dbo.ReportingABC abc ON r.VehicleIntId = abc.VehicleIntId AND r.DriverIntId = abc.DriverIntId AND r.Date = abc.Date --AND r.RouteID = abc.RouteId
		LEFT JOIN dbo.ReportingOverspeed ro ON r.VehicleIntId = ro.VehicleIntId AND r.DriverIntId = ro.DriverIntId AND r.Date = ro.Date --AND r.RouteID = ro.RouteId
		LEFT JOIN dbo.ReportingExtra re ON r.VehicleIntId = re.VehicleIntId AND r.DriverIntId = re.DriverIntId AND r.Date = re.Date
		-- LEFT JOIN to TAN_EntityCheckOut to excluded data for days where a vehicle is checked out during that day
		LEFT JOIN dbo.TAN_EntityCheckOut tec ON v.VehicleId = tec.EntityId 
											  AND FLOOR(CAST(r.Date AS FLOAT)) BETWEEN FLOOR(CAST(tec.CheckOutDateTime AS FLOAT)) AND FLOOR(CAST(tec.CheckInDateTime AS FLOAT))

	WHERE r.Date BETWEEN @lsdate AND @ledate
		AND (v.VehicleId IN (SELECT Value FROM dbo.Split(@lvids, ',')) OR @lvids IS NULL)
		AND (gd.GroupId IN (SELECT Value FROM dbo.Split(@lgids, ',')) OR @lgids IS NULL)
		AND v.Archived = 0
		AND (v.VehicleTypeID = @lvehicletypeid OR @lvehicletypeid IS NULL)
		AND (r.RouteID = @lrouteid OR @lrouteid IS NULL)
		AND r.DrivingDistance > 0
		AND tec.EntityCheckOutId IS NULL -- exclude data for checked out periods

	GROUP BY p.PeriodNum, v.VehicleId, gd.GroupId WITH CUBE
	HAVING SUM(DrivingDistance) > 10 
) Result

LEFT JOIN @VehicleConfig vc ON Result.VehicleId = vc.Vid
LEFT JOIN dbo.Vehicle v ON Result.VehicleId = v.VehicleId
LEFT JOIN dbo.[Group] g ON Result.GroupId = g.GroupId
LEFT JOIN @period_dates p ON Result.PeriodNum = p.PeriodNum

IF (SELECT COUNT(DISTINCT ReportConfigId) FROM @VehicleConfig) = 1
BEGIN -- Original score calculations	

	 -- Calculate Scores for total rows
	UPDATE @data
	SET 	Safety = dbo.ScoreByClassAndConfigPlus('S', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, TopGearOverspeed, CruiseOverspeed, OverspeedCount, OverspeedHighCount, StabilityControl, CollisionWarningLow, CollisionWarningMed, CollisionWarningHigh, LaneDepartureDisable, LaneDepartureLeftRight, SweetSpotTime, OverRevTime, TopGearTime, Fatigue, Distraction,SpeedGauge, @lrprtcfgid),
		Efficiency = dbo.ScoreByClassAndConfigPlus('E', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, TopGearOverspeed, CruiseOverspeed, OverspeedCount, OverspeedHighCount, StabilityControl, CollisionWarningLow, CollisionWarningMed, CollisionWarningHigh, LaneDepartureDisable, LaneDepartureLeftRight, SweetSpotTime, OverRevTime, TopGearTime, Fatigue, Distraction,SpeedGauge, @lrprtcfgid)
	WHERE GroupId IS NOT NULL AND VehicleId IS NULL AND PeriodNum IS NOT NULL	

END	
ELSE	

BEGIN -- Fair calculations required

	 --Calculate Scores
	UPDATE @data
	SET 	Safety = dbo.ScoreByClassAndConfigPlus('S', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, TopGearOverspeed, CruiseOverspeed, OverspeedCount, OverspeedHighCount, StabilityControl, CollisionWarningLow, CollisionWarningMed, CollisionWarningHigh, LaneDepartureDisable, LaneDepartureLeftRight, SweetSpotTime, OverRevTime, TopGearTime, Fatigue, Distraction,SpeedGauge, @lrprtcfgid),
		Efficiency = dbo.ScoreByClassAndConfigPlus('E', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, TopGearOverspeed, CruiseOverspeed, OverspeedCount, OverspeedHighCount, StabilityControl, CollisionWarningLow, CollisionWarningMed, CollisionWarningHigh, LaneDepartureDisable, LaneDepartureLeftRight, SweetSpotTime, OverRevTime, TopGearTime, Fatigue, Distraction,SpeedGauge, @lrprtcfgid)
	WHERE VehicleId IS NOT NULL AND PeriodNum IS NOT NULL AND GroupId IS NOT NULL	

	 --Calculate Group Scores based on weighted average of scores from vehicles driven in group
	UPDATE @data
	SET Efficiency = w.WeightedEfficiency / d.TotalDrivingDistance, 
		Safety = w.WeightedSafety / d.TotalDrivingDistance
	FROM @data d
	INNER JOIN 
		(SELECT d.GroupId, d.PeriodNum, SUM(d.Efficiency * d.TotalDrivingDistance) AS WeightedEfficiency, SUM(d.Safety * d.TotalDrivingDistance) AS WeightedSafety
		FROM @data d
		WHERE d.VehicleId IS NOT NULL AND d.PeriodNum IS NOT NULL AND d.GroupId IS NOT NULL		
		GROUP BY d.GroupId, d.PeriodNum) w ON w.GroupId = d.GroupId AND w.PeriodNum = d.PeriodNum 
	WHERE  d.VehicleId IS NULL AND d.GroupId IS NOT NULL AND d.PeriodNum IS NOT NULL	 

END	-- Fair/Non Fair score calculations	


SELECT d.PeriodNum ,
	   p.StartDate AS WeekStartDate,
	   p.EndDate AS WeekEndDate,
		--[dbo].TZ_GetTime(p.StartDate,default,@luid) AS WeekStartDate,
		--[dbo].TZ_GetTime(p.EndDate,default,@luid) AS WeekEndDate,
	   p.PeriodType,
       VehicleId ,
       Registration ,
		NULL AS DriverId,
 		NULL AS DisplayName,
 		NULL AS FirstName,
 		NULL AS Surname,
 		NULL AS MiddleNames,
 		NULL AS Number,
 		NULL AS NumberAlternate,
 		NULL AS NumberAlternate2,
       --ReportConfigId ,
       GroupId ,
       GroupName ,
       SweetSpot ,
       OverRevWithFuel ,
       TopGear ,
       Cruise ,
       CruiseInTopGears ,
       CoastInGear ,
       CruiseTopGearRatio ,
       Idle ,
       EngineServiceBrake ,
       OverRevWithoutFuel ,
       Rop ,
       Rop2 ,
       OverSpeed ,
       OverSpeedHigh ,
	   OverspeedDistance,
       IVHOverSpeed ,

	   SpeedGauge,

       CoastOutOfGear ,
       HarshBraking ,
       FuelEcon ,
	   NULL AS TotalFuel ,
       Pto ,
       Co2 ,
       Acceleration ,
       Braking ,
       Cornering ,
       AccelerationLow ,
       BrakingLow ,
       CorneringLow ,
       AccelerationHigh ,
       BrakingHigh ,
       CorneringHigh ,
       ManoeuvresLow ,
       ManoeuvresMed ,
	   CruiseOverspeed ,
	   TopGearOverspeed ,
	   FuelWastageCost ,
	   OverspeedCount,
	   OverspeedHighCount,
	   StabilityControl,
	   CollisionWarningLow,
	   CollisionWarningMed,
	   CollisionWarningHigh,
	   LaneDepartureDisable,
	   LaneDepartureLeftRight,
	   SweetSpotTime,
	   OverRevTime,
	   TopGearTime,
	   Fatigue,
	   Distraction,
       Efficiency ,
       Safety ,
       TotalTime ,
       TotalDrivingDistance ,
       ServiceBrakeUsage ,
       EngineBrakeUsage ,
       OverRevCount ,
	   @lsdate AS sdate,
	   @ledate AS edate,
	   @lsdate AS CreationDateTime,
	   @ledate AS ClosureDateTime,
	   --[dbo].TZ_GetTime(@lsdate,default,@luid) AS CreationDateTime,
	   --[dbo].TZ_GetTime(@ledate,default,@luid) AS ClosureDateTime,
	   @diststr AS DistanceUnit,
	   @fuelstr AS FuelUnit,
	   @co2str AS Co2Unit,
	   @fuelmult AS FuelMult,
	   @liquidstr AS FuelUnit,
	   @currency AS Currency
FROM @data d
INNER JOIN @period_dates p ON p.PeriodNum = d.PeriodNum
WHERE d.VehicleId IS NULL
  AND d.GroupId IS NOT NULL	
  AND d.PeriodNum IS NOT NULL
ORDER BY d.GroupId, d.PeriodNum

GO
