SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportPerformance_Group_Vehicle]
(
	@gids varchar(max), 
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER
) 
AS

--DECLARE	@gids varchar(max),
--		@sdate datetime,
--		@edate datetime,
--		@uid uniqueidentifier,
--		@rprtcfgid uniqueidentifier
--
----SET @gids = N'08BACCA2-74F4-4932-8244-038318FA54B6,169E0045-012A-44A5-ADB5-05BEFAB135A9'
--SET @gids = N'08BACCA2-74F4-4932-8244-038318FA54B6'
--
--SET @sdate = '2011-04-04 00:00:00'
--SET @edate = '2011-04-24 23:59:59'
--SET @uid = N'4c0a0d44-0685-4292-9087-f32e03f10134'
--SET @rprtcfgid = N'3FED49AA-15C3-4875-A980-D252A6DAEF80'

DECLARE @diststr varchar(20),
		@distmult float,
		@fuelstr varchar(20),
		@fuelmult float,
		@co2str varchar(20),
		@co2mult float

SELECT @diststr = [dbo].UserPref(@uid, 203)
SELECT @distmult = [dbo].UserPref(@uid, 202)
SELECT @fuelstr = [dbo].UserPref(@uid, 205)
SELECT @fuelmult = [dbo].UserPref(@uid, 204)
SELECT @co2str = [dbo].UserPref(@uid, 211)
SELECT @co2mult = [dbo].UserPref(@uid, 210)

SET @sdate = [dbo].TZ_ToUTC(@sdate,default,@uid)
SET @edate = [dbo].TZ_ToUTC(@edate,default,@uid)

DECLARE @DepotList TABLE (CustomerIntId int)

INSERT INTO @DepotList 
SELECT DISTINCT c.CustomerIntId
FROM dbo.CustomerVehicle cv
	INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
	INNER JOIN dbo.GroupDetail gd ON gd.EntityDataId = cv.VehicleId
WHERE gd.GroupId IN (SELECT Value FROM dbo.Split(@gids, ','))
  AND c.CustomerIntId != 0
  AND cv.enddate IS NULL
  
SELECT *
FROM 
	(SELECT
			v.VehicleId,	
			v.Registration,
			d.DriverId,
     		d.Surname + ' ' + d.Firstname as DriverName, 
     		g.GroupId,
     		GroupName,
     		
     		SweetSpot, 
			OverRevWithFuel,
			TopGear, 
			Cruise, 
			CoastInGear, 
			Idle, 
			TotalTime, 
			ServiceBrakeUsage, 
			EngineServiceBrake, 
			OverRevWithoutFuel, 
			CEILING(Rop) AS Rop, 
			OverSpeed, 
			CoastOutOfGear, 
			CEILING(HarshBraking) AS HarshBraking, 
			
			TotalDrivingDistance, 
			FuelEcon,
			Pto,
			Co2, 			
			CruiseTopGearRatio,
     		/*
			dbo.ScorePerfComponentValueConfig(1, SweetSpot*100, @rprtcfgid) AS SweetSpot, 
			dbo.ScorePerfComponentValueConfig(2, OverRevWithFuel*100, @rprtcfgid) AS OverRevWithFuel,
			dbo.ScorePerfComponentValueConfig(3, TopGear*100, @rprtcfgid) AS TopGear, 
			dbo.ScorePerfComponentValueConfig(4, Cruise*100, @rprtcfgid) AS Cruise, 
			dbo.ScorePerfComponentValueConfig(5, CoastInGear*100, @rprtcfgid) AS CoastInGear, 
			dbo.ScorePerfComponentValueConfig(6, Idle*100, @rprtcfgid) AS Idle, 
			TotalTime, 
			ServiceBrakeUsage, 
			dbo.ScorePerfComponentValueConfig(7, EngineServiceBrake*100, @rprtcfgid) AS EngineServiceBrake, 
			dbo.ScorePerfComponentValueConfig(8, OverRevWithoutFuel*100, @rprtcfgid) AS OverRevWithoutFuel, 
			dbo.ScorePerfComponentValueConfig(9, Rop, @rprtcfgid) AS Rop, 
			dbo.ScorePerfComponentValueConfig(10, OverSpeed*100, @rprtcfgid) AS OverSpeed, 
			dbo.ScorePerfComponentValueConfig(11, CoastOutOfGear*100, @rprtcfgid) AS CoastOutOfGear, 
			dbo.ScorePerfComponentValueConfig(12, HarshBraking, @rprtcfgid) AS HarshBraking, 
			TotalDrivingDistance, 
			dbo.ScorePerfComponentValueConfig(16, FuelEcon, @rprtcfgid) AS FuelEcon,
			Pto,
			Co2, 			
			dbo.ScorePerfComponentValueConfig(25, CruiseTopGearRatio*100, @rprtcfgid) AS CruiseTopGearRatio,
			*/
			Efficiency, 
			Safety,
			
			@sdate AS sdate,
			@edate AS edate,
			[dbo].TZ_GetTime(@sdate,default,@uid) AS CreationDateTime,
			[dbo].TZ_GetTime(@edate,default,@uid) AS ClosureDateTime,

			@diststr AS DistanceUnit,
			@fuelstr AS FuelUnit,
			@co2str AS Co2Unit,

			dbo.GYRColourConfig(Idle*100, 6, @rprtcfgid) AS IdleColour,
			dbo.GYRColourConfig(SweetSpot*100, 1, @rprtcfgid) AS SweetSpotColour,
			dbo.GYRColourConfig(OverRevWithFuel*100, 2, @rprtcfgid) AS OverRevWithFuelColour,
			dbo.GYRColourConfig(TopGear*100, 3, @rprtcfgid) AS TopgearColour,
			dbo.GYRColourConfig(Cruise*100, 4, @rprtcfgid) AS CruiseColour,
			dbo.GYRColourConfig(CoastInGear*100, 5, @rprtcfgid) AS CoastInGearColour,			
			dbo.GYRColourConfig(FuelEcon, 16, @rprtcfgid) AS KPLColour,
			dbo.GYRColourConfig(Efficiency, 18, @rprtcfgid) AS EfficiencyColour, -- Combined Colour
			dbo.GYRColourConfig(Safety, 15, @rprtcfgid) AS SafetyColour,
			dbo.GYRColourConfig(EngineServiceBrake*100, 7, @rprtcfgid) AS EngineServiceBrakeColour,
			dbo.GYRColourConfig(OverRevWithoutFuel*100, 8, @rprtcfgid) AS OverRevWithoutFuelColour,
			dbo.GYRColourConfig(Rop, 9, @rprtcfgid) AS RopColour,
			dbo.GYRColourConfig(OverSpeed*100, 10, @rprtcfgid) AS TimeOverSpeedColour,
			dbo.GYRColourConfig(CoastOutOfGear*100, 11, @rprtcfgid) AS TimeOutOfGearCoastingColour,
			dbo.GYRColourConfig(HarshBraking, 12, @rprtcfgid) AS HarshBrakingColour,
			dbo.GYRColourConfig(CruiseTopGearRatio*100, 25, @rprtcfgid) AS CruiseTopGearRatioColour

	FROM
		(SELECT *,
			
			Efficiency = dbo.ScorePerformanceConfig(SweetSpot, OverRevWithFuel, TopGear, Cruise, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, CoastOutOfGear, HarshBraking, CruiseTopGearRatio, @rprtcfgid), -- Combined Score
			Safety = dbo.ScoreSafetyConfig(CoastInGear, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, CoastOutOfGear, HarshBraking, NULL, NULL, NULL, @rprtcfgid)
		FROM
			(SELECT
				CASE WHEN (GROUPING(v.VehicleId) = 1) THEN NULL
					ELSE ISNULL(v.VehicleId, NULL)
				END AS VehicleId,

				CASE WHEN (GROUPING(d.DriverId) = 1) THEN NULL
					ELSE ISNULL(d.DriverId, NULL)
				END AS DriverId,
				
				CASE WHEN (GROUPING(gd.GroupId) = 1) THEN NULL
					ELSE ISNULL(gd.GroupId, NULL)
				END AS GroupId,

				SUM(InSweetSpotDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS SweetSpot,
				SUM(FueledOverRPMDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS OverRevWithFuel,
				SUM(TopGearDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS TopGear,
				SUM(CruiseControlDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS Cruise,
				SUM(CoastInGearDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS CoastInGear,
				SUM(CruiseControlDistance) / dbo.ZeroYieldNull(SUM(TopGearDistance)) AS CruiseTopGearRatio,
				CAST(SUM(IdleTime) AS float) / dbo.ZeroYieldNull(SUM(TotalTime)) AS Idle,
				CAST(SUM(PTOMovingTime) + SUM(PTONonMovingTime) AS float) / dbo.ZeroYieldNull(SUM(TotalTime)) AS Pto,
				ISNULL((SUM(TotalFuel) * 2639.1 * @co2mult) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)),0) AS Co2, --@co2mult: 1 for g/km, 1.6 for g/miles
				SUM(TotalTime) AS TotalTime,
				SUM(ServiceBrakeDistance) / CASE WHEN SUM(DrivingDistance + PTOMovingDistance) = 0 THEN NULL ELSE SUM(DrivingDistance + PTOMovingDistance) END AS ServiceBrakeUsage,
				ISNULL(SUM(EngineBrakeDistance) / dbo.ZeroYieldNull(SUM(ServiceBrakeDistance + EngineBrakeDistance)),0) AS EngineServiceBrake,
				ISNULL(SUM(EngineBrakeOverRPMDistance) / dbo.ZeroYieldNull(SUM(EngineBrakeDistance)),0) AS OverRevWithoutFuel,
				ISNULL((SUM(ROPCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000))))),0) AS Rop,
				ISNULL(SUM(OverSpeedDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)),0) AS OverSpeed,
				ISNULL(SUM(CoastOutOfGearDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)),0) AS CoastOutOfGear,
				ISNULL((SUM(PanicStopCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000))))),0) AS HarshBraking,
				SUM(DrivingDistance * 1000 * @distmult) AS TotalDrivingDistance,

				(CASE WHEN @fuelmult = 0.1 THEN
					(CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel  * ISNULL(FuelMultiplier,1.0))*100 END)/SUM(DrivingDistance + PTOMovingDistance) 
				ELSE
					(SUM(DrivingDistance + PTOMovingDistance) * 1000) / (CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel * ISNULL(FuelMultiplier,1.0)) END) * @fuelmult END) AS FuelEcon
					
			FROM 	dbo.Reporting r
						INNER JOIN dbo.Driver d ON r.DriverIntId = d.DriverIntId
						INNER JOIN dbo.Vehicle v ON r.VehicleIntId = v.VehicleIntId
						INNER JOIN GroupDetail gd ON gd.EntityDataId = v.VehicleId
							AND GroupId IN (SELECT VALUE FROM dbo.Split(@gids, ','))
				
			WHERE Date BETWEEN @sdate AND @edate 

			GROUP BY d.DriverId, v.VehicleId, gd.GroupId WITH CUBE
			HAVING SUM(DrivingDistance) > 10 ) o
		) p

	LEFT JOIN dbo.Vehicle v ON p.VehicleId = v.VehicleId
	LEFT JOIN [Group] g ON p.GroupId = g.GroupId
	LEFT JOIN dbo.Driver d ON p.DriverId = d.DriverId) CubeResult

WHERE CubeResult.GroupId IS NOT null
  AND DriverId is NULL	
  
UNION	/* have to calculate the overall totals separately as drivers and vehicles */
		/* may be in more than one group which affects the rollup of the cube      */

SELECT
			NULL,	
			NULL AS Registration,
			NULL,
     		NULL AS DriverName, 
     		NULL,
     		NULL AS GroupName,
     		
     		SweetSpot, 
			OverRevWithFuel,
			TopGear, 
			Cruise, 
			CoastInGear, 
			Idle, 
			TotalTime, 
			ServiceBrakeUsage, 
			EngineServiceBrake, 
			OverRevWithoutFuel, 
			CEILING(Rop) AS Rop, 
			OverSpeed, 
			CoastOutOfGear, 
			CEILING(HarshBraking) AS HarshBraking, 
			
			TotalDrivingDistance, 
			FuelEcon,
			Pto,
			Co2, 			
			CruiseTopGearRatio,
     		
     		/*
			dbo.ScorePerfComponentValueConfig(1, SweetSpot*100, @rprtcfgid) AS SweetSpot, 
			dbo.ScorePerfComponentValueConfig(2, OverRevWithFuel*100, @rprtcfgid) AS OverRevWithFuel,
			dbo.ScorePerfComponentValueConfig(3, TopGear*100, @rprtcfgid) AS TopGear, 
			dbo.ScorePerfComponentValueConfig(4, Cruise*100, @rprtcfgid) AS Cruise, 
			dbo.ScorePerfComponentValueConfig(5, CoastInGear*100, @rprtcfgid) AS CoastInGear, 
			dbo.ScorePerfComponentValueConfig(6, Idle*100, @rprtcfgid) AS Idle, 
			TotalTime, 
			ServiceBrakeUsage, 
			dbo.ScorePerfComponentValueConfig(7, EngineServiceBrake*100, @rprtcfgid) AS EngineServiceBrake, 
			dbo.ScorePerfComponentValueConfig(8, OverRevWithoutFuel*100, @rprtcfgid) AS OverRevWithoutFuel, 
			dbo.ScorePerfComponentValueConfig(9, Rop, @rprtcfgid) AS Rop, 
			dbo.ScorePerfComponentValueConfig(10, OverSpeed*100, @rprtcfgid) AS OverSpeed, 
			dbo.ScorePerfComponentValueConfig(11, CoastOutOfGear*100, @rprtcfgid) AS CoastOutOfGear, 
			dbo.ScorePerfComponentValueConfig(12, HarshBraking, @rprtcfgid) AS HarshBraking, 
			TotalDrivingDistance, 
			dbo.ScorePerfComponentValueConfig(16, FuelEcon, @rprtcfgid) AS FuelEcon,
			Pto,
			Co2, 			
			dbo.ScorePerfComponentValueConfig(25, CruiseTopGearRatio*100, @rprtcfgid) AS CruiseTopGearRatio,
			*/
			Efficiency, 
			Safety,
			
			@sdate AS sdate,
			@edate AS edate,
			[dbo].TZ_GetTime(@sdate,default,@uid) AS CreationDateTime,
			[dbo].TZ_GetTime(@edate,default,@uid) AS ClosureDateTime,

			@diststr AS DistanceUnit,
			@fuelstr AS FuelUnit,
			@co2str AS Co2Unit,

			dbo.GYRColourConfig(Idle*100, 6, @rprtcfgid) AS IdleColour,
			dbo.GYRColourConfig(SweetSpot*100, 1, @rprtcfgid) AS SweetSpotColour,
			dbo.GYRColourConfig(OverRevWithFuel*100, 2, @rprtcfgid) AS OverRevWithFuelColour,
			dbo.GYRColourConfig(TopGear*100, 3, @rprtcfgid) AS TopgearColour,
			dbo.GYRColourConfig(Cruise*100, 4, @rprtcfgid) AS CruiseColour,
			dbo.GYRColourConfig(CoastInGear*100, 5, @rprtcfgid) AS CoastInGearColour,			
			dbo.GYRColourConfig(FuelEcon, 16, @rprtcfgid) AS KPLColour,
			dbo.GYRColourConfig(Efficiency, 18, @rprtcfgid) AS EfficiencyColour, -- Combined Colour
			dbo.GYRColourConfig(Safety, 15, @rprtcfgid) AS SafetyColour,
			dbo.GYRColourConfig(EngineServiceBrake*100, 7, @rprtcfgid) AS EngineServiceBrakeColour,
			dbo.GYRColourConfig(OverRevWithoutFuel*100, 8, @rprtcfgid) AS OverRevWithoutFuelColour,
			dbo.GYRColourConfig(Rop, 9, @rprtcfgid) AS RopColour,
			dbo.GYRColourConfig(OverSpeed*100, 10, @rprtcfgid) AS TimeOverSpeedColour,
			dbo.GYRColourConfig(CoastOutOfGear*100, 11, @rprtcfgid) AS TimeOutOfGearCoastingColour,
			dbo.GYRColourConfig(HarshBraking, 12, @rprtcfgid) AS HarshBrakingColour,
			dbo.GYRColourConfig(CruiseTopGearRatio*100, 25, @rprtcfgid) AS CruiseTopGearRatioColour

	FROM
		(SELECT *,
			
			Efficiency = dbo.ScorePerformanceConfig(SweetSpot, OverRevWithFuel, TopGear, Cruise, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, CoastOutOfGear, HarshBraking, CruiseTopGearRatio, @rprtcfgid), -- Combined Score
			Safety = dbo.ScoreSafetyConfig(CoastInGear, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, CoastOutOfGear, HarshBraking, NULL, NULL, NULL, @rprtcfgid)
		FROM
			(SELECT
				SUM(InSweetSpotDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS SweetSpot,
				SUM(FueledOverRPMDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS OverRevWithFuel,
				SUM(TopGearDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS TopGear,
				SUM(CruiseControlDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS Cruise,
				SUM(CoastInGearDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS CoastInGear,
				SUM(CruiseControlDistance) / dbo.ZeroYieldNull(SUM(TopGearDistance)) AS CruiseTopGearRatio,
				CAST(SUM(IdleTime) AS float) / dbo.ZeroYieldNull(SUM(TotalTime)) AS Idle,
				CAST(SUM(PTOMovingTime) + SUM(PTONonMovingTime) AS float) / dbo.ZeroYieldNull(SUM(TotalTime)) AS Pto,
				ISNULL((SUM(TotalFuel) * 2639.1 * @co2mult) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)),0) AS Co2, --@co2mult: 1 for g/km, 1.6 for g/miles
				SUM(TotalTime) AS TotalTime,
				SUM(ServiceBrakeDistance) / CASE WHEN SUM(DrivingDistance + PTOMovingDistance) = 0 THEN NULL ELSE SUM(DrivingDistance + PTOMovingDistance) END AS ServiceBrakeUsage,
				ISNULL(SUM(EngineBrakeDistance) / dbo.ZeroYieldNull(SUM(ServiceBrakeDistance + EngineBrakeDistance)),0) AS EngineServiceBrake,
				ISNULL(SUM(EngineBrakeOverRPMDistance) / dbo.ZeroYieldNull(SUM(EngineBrakeDistance)),0) AS OverRevWithoutFuel,
				ISNULL((SUM(ROPCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000))))),0) AS Rop,
				ISNULL(SUM(OverSpeedDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)),0) AS OverSpeed,
				ISNULL(SUM(CoastOutOfGearDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)),0) AS CoastOutOfGear,
				ISNULL((SUM(PanicStopCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000))))),0) AS HarshBraking,
				SUM(DrivingDistance * 1000 * @distmult) AS TotalDrivingDistance,

				(CASE WHEN @fuelmult = 0.1 THEN
					(CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel  * ISNULL(FuelMultiplier,1.0))*100 END)/SUM(DrivingDistance + PTOMovingDistance) 
				ELSE
					(SUM(DrivingDistance + PTOMovingDistance) * 1000) / (CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel * ISNULL(FuelMultiplier,1.0)) END) * @fuelmult END) AS FuelEcon
					
			FROM 	dbo.Reporting r
						INNER JOIN dbo.Vehicle v ON r.VehicleIntId = v.VehicleIntId
						INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
						INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
						INNER JOIN dbo.Driver d ON r.DriverIntId = d.DriverIntId

				
			WHERE Date BETWEEN @sdate AND @edate 
			  AND c.CustomerIntId IN (SELECT CustomerIntId FROM @DepotList)  
			  AND c.CustomerIntId != 0
		
			HAVING SUM(DrivingDistance) > 10 ) o
		) p

ORDER BY Registration, DriverName, GroupName

GO
