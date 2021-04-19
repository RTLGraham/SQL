SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_Report_Trend_VehicleFleet]
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
		
--SET @vids = NULL --N'53B878DA-091D-4722-B467-1463EE502C19,AD7AE29D-1328-4228-B4C2-194D6C90A266,2F29E214-4249-4412-9927-1BBFF111DF1B'
----SET @gids = N'B04062C4-67FA-41A9-9BFC-4776782653B4,7BF24193-706A-4AC2-93A2-65177209B0E8,EA6FF8F6-F6EA-4632-9607-7B0A8A8A8DDB'
--SET @gids = NULL --N'B04062C4-67FA-41A9-9BFC-4776782653B4'
--SET @vehicletypeid = NULL
--SET @routeid = NULL
--SET	@sdate = '2018-01-01 00:00'
--SET	@edate = '2018-12-31 23:59'
--SET	@uid = N'1476B50A-6850-411B-90DD-514D4AB9FC85'
--SET	@rprtcfgid = N'7C2F54E9-B075-49E1-8EAE-C967BF72DD4A'
--SET @drilldown = 1
--SET @calendar = 1
--SET @groupBy = 0


/*
SET	@uid = N'C13C0754-8B33-49BA-8C93-C5CE1A5F6475'
SET	@rprtcfgid = N'D97F56DF-49F7-4634-BFA5-636E013DC428'

SET	@uid = N'1476B50A-6850-411B-90DD-514D4AB9FC85'
SET	@rprtcfgid = N'7C2F54E9-B075-49E1-8EAE-C967BF72DD4A'
*/

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

		--ReportConfigId UNIQUEIDENTIFIER,

		SweetSpot FLOAT, 
		OverRevWithFuel FLOAT, 
		TopGear FLOAT, 
		Cruise FLOAT,
		CruiseInTopGears FLOAT, 
		CoastInGear FLOAT, 
		CruiseTopGearRatio FLOAT,
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
		TotalFuel FLOAT,
		Pto FLOAT, 
		Co2 FLOAT, 
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
		  --ReportConfigId ,
		  SweetSpot , 
		  OverRevWithFuel ,
		  TopGear ,
		  Cruise ,
		  CruiseInTopGears ,
		  CoastInGear,
		  CruiseTopGearRatio ,
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
		  TotalFuel,
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

		--ISNULL(ReportConfigId, @lrprtcfgid) AS ReportConfigId,
 		 		
 		-- Data columns with corresponding colours below 
		SweetSpot, OverRevWithFuel, TopGear, Cruise, 
		CruiseInTopGears,
		CoastInGear,CruiseTopGearRatio,
		Idle, EngineServiceBrake, OverRevWithoutFuel, 
		Rop, Rop2, OverSpeed, 
		OverSpeedHigh, OverSpeedDistance,
		IVHOverSpeed,SpeedGauge, CoastOutOfGear, HarshBraking, FuelEcon,NULL,
		Pto, Co2, 
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

		-- For each component use the weighted value rather than the Reporting value so that vehicle configs have been accounted for
		ISNULL(SUM(CAST(InSweetSpotDistance AS FLOAT)) / dbo.ZeroYieldNull(SUM(CAST(r.DrivingDistance AS FLOAT))),0) AS SweetSpot,
		ISNULL(SUM(CAST(FueledOverRPMDistance AS FLOAT)) / dbo.ZeroYieldNull(SUM(CAST(r.DrivingDistance AS FLOAT))),0) AS OverRevWithFuel,
		ISNULL(SUM(CAST(TopGearDistance AS FLOAT)) / dbo.ZeroYieldNull(SUM(CAST(r.DrivingDistance AS FLOAT))),0) AS TopGear,
		ISNULL(SUM(CAST(CruiseControlDistance AS FLOAT)) / dbo.ZeroYieldNull(SUM(CAST(r.DrivingDistance AS FLOAT))),0) AS Cruise,
		--Proof of concept. CruiseInTopGearsDistance should be used in production as soon as firmware is released.
		dbo.CAP(ISNULL(SUM(CAST(CruiseInTopGearsDistance AS FLOAT)) / dbo.ZeroYieldNull(SUM(CAST(r.DrivingDistance AS FLOAT))),0), 1.0) AS CruiseInTopGears,
		--SUM(CruiseInTopGearsDistance) / dbo.ZeroYieldNull(SUM(TopGearDistance + ISNULL(GearDownDistance,0))) AS CruiseInTopGears,
		ISNULL(SUM(CAST(CoastInGearDistance AS FLOAT)) / dbo.ZeroYieldNull(SUM(CAST(r.DrivingDistance AS FLOAT))),0) AS CoastInGear,
		ISNULL(SUM(CAST(CruiseControlDistance AS FLOAT)) / dbo.ZeroYieldNull(SUM(CAST(r.DrivingDistance AS FLOAT))),0) AS CruiseTopGearRatio,
		ISNULL(CAST(SUM(CAST(IdleTime AS FLOAT)) AS float) / dbo.ZeroYieldNull(SUM(CAST(TotalTime AS FLOAT))),0) AS Idle,
		ISNULL(CAST(SUM(CAST(r.PTOMovingTime + PTONonMovingTime AS FLOAT)) AS float) / dbo.ZeroYieldNull(SUM(CAST(r.PTOMovingTime + PTONonMovingTime AS FLOAT))),0) AS Pto,
		ISNULL((SUM(CAST(TotalFuel AS FLOAT)) * 2639.1 * @co2mult) / dbo.ZeroYieldNull(SUM(CAST(DrivingDistance + PTOMovingDistance AS FLOAT))),0) AS Co2, --@co2mult: 1 for g/km, 1.6 for g/miles
		ISNULL(SUM(CAST(ServiceBrakeDistance AS FLOAT)) / dbo.ZeroYieldNull(SUM(CAST(r.ServiceBrakeDistance + r.EngineBrakeDistance AS FLOAT))),0) AS ServiceBrakeUsage,
		ISNULL(SUM(CAST(EngineBrakeDistance AS FLOAT)) / dbo.ZeroYieldNull(SUM(CAST(ServiceBrakeDistance + EngineBrakeDistance AS FLOAT))),0) AS EngineServiceBrake,
		ISNULL(SUM(CAST(EngineBrakeOverRPMDistance AS FLOAT)) / dbo.ZeroYieldNull(SUM(CAST(r.EngineBrakeDistance AS FLOAT))),0) AS OverRevWithoutFuel,
		ISNULL((SUM(CAST(ROPCount AS FLOAT)) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(CAST(r.DrivingDistance AS FLOAT)) * @distmult * 1000))))),0) AS Rop,
		ISNULL((SUM(CAST(ROP2Count AS FLOAT)) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(CAST(r.DrivingDistance AS FLOAT)) * @distmult * 1000))))),0) AS Rop2,
		ISNULL(SUM(CAST(ro.OverSpeedDistance AS FLOAT)) / dbo.ZeroYieldNull(SUM(CAST(r.DrivingDistance AS FLOAT))),0) AS OverSpeed,
		ISNULL(SUM(CAST(OverSpeedHighDistance AS FLOAT)) / dbo.ZeroYieldNull(SUM(CAST(r.DrivingDistance AS FLOAT))),0) AS OverSpeedHigh,
		ISNULL(SUM(CAST(ro.OverSpeedDistance AS FLOAT)) / dbo.ZeroYieldNull(SUM(CAST(r.DrivingDistance AS FLOAT))),0) AS OverSpeedDistance, 
		ISNULL(SUM(CAST(r.OverSpeedDistance AS FLOAT)) / dbo.ZeroYieldNull(SUM(CAST(r.DrivingDistance AS FLOAT))),0) AS IVHOverSpeed,

		ISNULL(SUM(ro.Incidents) / CAST(SUM(ro.Observations) AS FLOAT), 0) AS SpeedGauge,

		ISNULL(SUM(CAST(CoastOutOfGearDistance AS FLOAT)) / dbo.ZeroYieldNull(SUM(CAST(r.DrivingDistance AS FLOAT))),0) AS CoastOutOfGear,
		ISNULL((SUM(CAST(PanicStopCount AS FLOAT)) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(CAST(r.DrivingDistance AS FLOAT)) * @distmult * 1000))))),0) AS HarshBraking,
		ISNULL((SUM(CAST(ORCount AS FLOAT)) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(CAST(r.DrivingDistance AS FLOAT)) * @distmult * 1000))))),0) AS OverRevCount,
		ISNULL((SUM(CAST(Acceleration AS FLOAT)) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(CAST(r.DrivingDistance AS FLOAT)) * @distmult * 1000))))),0) AS Acceleration,
		ISNULL((SUM(CAST(Braking AS FLOAT)) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(CAST(r.DrivingDistance AS FLOAT)) * @distmult * 1000))))),0) AS Braking,
		ISNULL((SUM(CAST(Cornering AS FLOAT)) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(CAST(r.DrivingDistance AS FLOAT)) * @distmult * 1000))))),0) AS Cornering,
		ISNULL((SUM(CAST(AccelerationLow AS FLOAT)) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(CAST(r.DrivingDistance AS FLOAT)) * @distmult * 1000))))),0) AS AccelerationLow,
		ISNULL((SUM(CAST(BrakingLow AS FLOAT)) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(CAST(r.DrivingDistance AS FLOAT)) * @distmult * 1000))))),0) AS BrakingLow,
		ISNULL((SUM(CAST(CorneringLow AS FLOAT)) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(CAST(r.DrivingDistance AS FLOAT)) * @distmult * 1000))))),0) AS CorneringLow,
		ISNULL((SUM(CAST(AccelerationHigh AS FLOAT)) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(CAST(r.DrivingDistance AS FLOAT)) * @distmult * 1000))))),0) AS AccelerationHigh,
		ISNULL((SUM(CAST(BrakingHigh AS FLOAT)) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(CAST(r.DrivingDistance AS FLOAT)) * @distmult * 1000))))),0) AS BrakingHigh,
		ISNULL((SUM(CAST(CorneringHigh AS FLOAT)) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(CAST(r.DrivingDistance AS FLOAT)) * @distmult * 1000))))),0) AS CorneringHigh,
		ISNULL((SUM(CAST(abc.AccelerationLow + abc.BrakingLow + abc.CorneringLow AS FLOAT)) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(CAST(r.DrivingDistance AS FLOAT)) * @distmult * 1000))))),0) AS ManoeuvresLow,
		ISNULL((SUM(CAST(abc.Acceleration + abc.Braking + abc.Cornering AS FLOAT)) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(CAST(r.DrivingDistance AS FLOAT)) * @distmult * 1000))))),0) AS ManoeuvresMed,

		ISNULL(SUM(CAST(r.CruiseSpeedingDistance AS FLOAT)) / dbo.ZeroYieldNull(SUM(CAST(r.OverSpeedThresholdDistance AS FLOAT))), 0) AS CruiseOverspeed,
		ISNULL(SUM(CAST(r.TopGearSpeedingDistance AS FLOAT)) / dbo.ZeroYieldNull(SUM(CAST(r.OverSpeedThresholdDistance AS FLOAT))), 0) AS TopGearOverspeed,
		SUM(CAST(r.FuelWastage AS FLOAT)) AS FuelWastage,

		ISNULL((SUM(CAST(OverspeedCount AS FLOAT)) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(CAST(r.DrivingDistance AS FLOAT)) * @distmult * 1000))))),0) AS OverspeedCount,
		ISNULL((SUM(CAST(OverspeedHighCount AS FLOAT)) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(CAST(r.DrivingDistance AS FLOAT)) * @distmult * 1000))))),0) AS OverspeedHighCount,
		ISNULL((SUM(CAST(StabilityCount AS FLOAT)) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(CAST(r.DrivingDistance AS FLOAT)) * @distmult * 1000))))),0) AS StabilityControl,
		ISNULL((SUM(CAST(CollisionWarningLow AS FLOAT)) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(CAST(r.DrivingDistance AS FLOAT)) * @distmult * 1000))))),0) AS CollisionWarningLow,
		ISNULL((SUM(CAST(CollisionWarningMed AS FLOAT)) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(CAST(r.DrivingDistance AS FLOAT)) * @distmult * 1000))))),0) AS CollisionWarningMed,
		ISNULL((SUM(CAST(CollisionWarningHigh AS FLOAT)) * (dbo.ZeroYieldNull(1000 /dbo.ZeroYieldNull((SUM(CAST(r.DrivingDistance AS FLOAT)) * @distmult * 1000))))),0) AS CollisionWarningHigh,
		ISNULL((SUM(CAST(LaneDepartureDisableCount AS FLOAT)) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(CAST(r.DrivingDistance AS FLOAT)) * @distmult * 1000))))),0) AS LaneDepartureDisable,
		ISNULL((SUM(CAST(LaneDepartureLeftRightCount AS FLOAT)) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(CAST(r.DrivingDistance AS FLOAT)) * @distmult * 1000))))),0) AS LaneDepartureLeftRight,
		ISNULL(CAST(SUM(CAST(SweetSpotTime AS FLOAT)) AS float) / dbo.ZeroYieldNull(SUM(CAST(re.DrivingTime  AS FLOAT))),0) AS SweetSpotTime,
		ISNULL(CAST(SUM(CAST(OverRPMTime AS FLOAT)) AS float) / dbo.ZeroYieldNull(SUM(CAST(re.DrivingTime  AS FLOAT))),0) AS OverRevTime,
		ISNULL(CAST(SUM(CAST(TopGearTime AS FLOAT)) AS float) / dbo.ZeroYieldNull(SUM(CAST(re.DrivingTime  AS FLOAT))),0) AS TopGearTime,
		ISNULL((SUM(CAST(Fatigue AS FLOAT)) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(CAST(r.DrivingDistance AS FLOAT)) * @distmult * 1000))))),0) AS Fatigue,
		ISNULL((SUM(CAST(Distraction AS FLOAT)) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(CAST(r.DrivingDistance AS FLOAT)) * @distmult * 1000))))),0) AS Distraction,

		(CASE WHEN @fuelmult = 0.1 THEN
			(CASE WHEN SUM(CAST(TotalFuel AS FLOAT))=0 THEN NULL ELSE SUM(CAST(TotalFuel * ISNULL(FuelMultiplier,1.0)*100 AS FLOAT)) END)/SUM(CAST(DrivingDistance + PTOMovingDistance AS FLOAT)) 
		ELSE
			(SUM(CAST(DrivingDistance + PTOMovingDistance AS FLOAT)) * 1000) / (CASE WHEN SUM(CAST(TotalFuel AS FLOAT))=0 THEN NULL ELSE SUM(CAST(TotalFuel * ISNULL(FuelMultiplier,1.0)  AS FLOAT)) END) * @fuelmult END) AS FuelEcon,
			
		SUM(CAST(DrivingDistance * 1000 * @distmult AS FLOAT)) AS TotalDrivingDistance,
		SUM(CAST(TotalTime AS FLOAT)) AS TotalTime				
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
		AND CAST(r.DrivingDistance AS FLOAT) > 0
		AND tec.EntityCheckOutId IS NULL -- exclude data for checked out periods	

	GROUP BY p.PeriodNum, v.VehicleId WITH CUBE
	HAVING SUM(DrivingDistance) > 10

) Result
    
LEFT JOIN @VehicleConfig vc ON Result.VehicleId = vc.Vid
LEFT JOIN @period_dates p ON Result.PeriodNum = p.PeriodNum
LEFT JOIN dbo.Vehicle v ON Result.VehicleId = v.VehicleId

IF (SELECT COUNT(DISTINCT ReportConfigId) FROM @VehicleConfig) = 1
BEGIN -- Original score calculations	

	 -- Calculate Scores for total rows
	UPDATE @data
	SET 	Safety = dbo.ScoreByClassAndConfigPlus('S', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, TopGearOverspeed, CruiseOverspeed, OverspeedCount, OverspeedHighCount, StabilityControl, CollisionWarningLow, CollisionWarningMed, CollisionWarningHigh, LaneDepartureDisable, LaneDepartureLeftRight, SweetSpotTime, OverRevTime, TopGearTime, Fatigue, Distraction,SpeedGauge, @lrprtcfgid),
		Efficiency = dbo.ScoreByClassAndConfigPlus('E', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, TopGearOverspeed, CruiseOverspeed, OverspeedCount, OverspeedHighCount, StabilityControl, CollisionWarningLow, CollisionWarningMed, CollisionWarningHigh, LaneDepartureDisable, LaneDepartureLeftRight, SweetSpotTime, OverRevTime, TopGearTime, Fatigue, Distraction,SpeedGauge, @lrprtcfgid)
	WHERE VehicleId IS NULL AND PeriodNum IS NOT NULL	

END	
ELSE	

BEGIN -- Fair calculations required

	 --Calculate Scores
	UPDATE @data
	SET 	Safety = dbo.ScoreByClassAndConfigPlus('S', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, TopGearOverspeed, CruiseOverspeed, OverspeedCount, OverspeedHighCount, StabilityControl, CollisionWarningLow, CollisionWarningMed, CollisionWarningHigh, LaneDepartureDisable, LaneDepartureLeftRight, SweetSpotTime, OverRevTime, TopGearTime, Fatigue, Distraction,SpeedGauge, @lrprtcfgid),
		Efficiency = dbo.ScoreByClassAndConfigPlus('E', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, TopGearOverspeed, CruiseOverspeed, OverspeedCount, OverspeedHighCount, StabilityControl, CollisionWarningLow, CollisionWarningMed, CollisionWarningHigh, LaneDepartureDisable, LaneDepartureLeftRight, SweetSpotTime, OverRevTime, TopGearTime, Fatigue, Distraction,SpeedGauge, @lrprtcfgid)
	WHERE VehicleId IS NOT NULL AND PeriodNum IS NOT NULL	

	 --Calculate Group Scores based on weighted average of scores from vehicles driven in group
	UPDATE @data
	SET Efficiency = w.WeightedEfficiency / d.TotalDrivingDistance, 
		Safety = w.WeightedSafety / d.TotalDrivingDistance
	FROM @data d
	INNER JOIN 
		(SELECT d.PeriodNum, SUM(d.Efficiency * d.TotalDrivingDistance) AS WeightedEfficiency, SUM(d.Safety * d.TotalDrivingDistance) AS WeightedSafety
		FROM @data d
		WHERE d.VehicleId IS NOT NULL AND d.PeriodNum IS NOT NULL	
		GROUP BY d.PeriodNum) w ON w.PeriodNum = d.PeriodNum 
	WHERE d.PeriodNum IS NOT NULL AND d.VehicleId IS NULL 

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
 	   NULL AS GroupId,
 	   NULL AS GroupName,
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
	   OverSpeedDistance,
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
WHERE d.PeriodNum IS NOT NULL	
  AND d.VehicleId IS NULL
ORDER BY PeriodNum


GO
