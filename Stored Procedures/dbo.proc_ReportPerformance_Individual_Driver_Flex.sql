SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportPerformance_Individual_Driver_Flex]
(
	@did UNIQUEIDENTIFIER, 
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER
) 
AS

--DECLARE	@did uniqueidentifier,
--		@sdate datetime,
--		@edate datetime,
--		@uid uniqueidentifier,
--		@rprtcfgid uniqueidentifier
--SET @did = N'44707203-94C6-4802-ABDD-153FA186F439' -- Andy Punter
----SET @did = N'F8172542-2700-4F76-8995-DA6C9EB902F2' -- Gary Benson
----SET @did = N'FE9BB5DB-3D6C-4375-8DB4-01043E2F5337' -- Geoff Hind
----SET @did = N'EE3EB36D-5A27-4BB9-B163-543FB9F84085' -- Goodson. Graham

--SET @sdate = '2011-11-30 00:00:00'
--SET @edate = '2011-12-06 23:59:59'
--SET @uid = N'38AAFFD4-1AE7-479B-889A-4D7F52C0DB58' 
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

DECLARE @ResultSet TABLE (
			VehicleId UNIQUEIDENTIFIER,	
			Registration VARCHAR(20),
			DriverId UNIQUEIDENTIFIER,
     		DriverName VARCHAR(100), 
     		WeekNumber INT,
     		WStartDate DATETIME,
     		WEndDate DATETIME,
			Score FLOAT, 
			IsScoreBetter BIT,
			TotalDrivingDistance FLOAT, 
			SweetSpot FLOAT,
			Idle FLOAT, 
			OverRevWithFuel FLOAT,
			Cruise FLOAT, 

			SpeedGauge FLOAT,

			EngineServiceBrake FLOAT,
			HarshBraking FLOAT,  
			CoastInGear FLOAT, 
			OverSpeed FLOAT,  
			Rop FLOAT, 
			OverRevWithoutFuel FLOAT, 
			Pto FLOAT,
			FuelEcon FLOAT,
			sdate DATETIME,
			edate DATETIME,
			DistanceUnit VARCHAR(20),
			FuelUnit VARCHAR(20),
			ScoreColour VARCHAR(10),
			SweetSpotColour VARCHAR(10),
			IdleColour VARCHAR(10),
			OverRevWithFuelColour VARCHAR(10),
			CruiseColour VARCHAR(10),
			EngineServiceBrakeColour VARCHAR(10),
			HarshBrakingColour VARCHAR(10),
			CoastInGearColour VARCHAR(10),
			SpeedGaugeColour VARCHAR(10)
			)
			
INSERT INTO @ResultSet
        ( VehicleId ,
          Registration ,
          DriverId ,
          DriverName ,
          WeekNumber ,
          WStartDate ,
          WEndDate ,
          Score ,
          IsScoreBetter ,
          TotalDrivingDistance ,
          SweetSpot ,
          Idle ,
          OverRevWithFuel ,
          Cruise ,

		  SpeedGauge,

          EngineServiceBrake ,
          HarshBraking ,
          CoastInGear ,
          OverSpeed ,
          Rop ,
          OverRevWithoutFuel ,
          Pto ,
          FuelEcon ,
          sdate ,
          edate ,
          DistanceUnit ,
          FuelUnit ,
          ScoreColour ,
          SweetSpotColour ,
          IdleColour ,
          OverRevWithFuelColour ,
          CruiseColour ,
          EngineServiceBrakeColour ,
          HarshBrakingColour ,
          CoastInGearColour,
		  SpeedGaugeColour
        )

SELECT *
FROM 
	(SELECT
			v.VehicleId,	
			Registration,
			d.DriverId,
     		d.Surname + ' ' + d.Firstname as DriverName, 
     		NULL AS WeekNumber,
     		NULL AS WStartDate,
     		NULL AS WEndDate,
			Score, 
			IsScoreBetter,
			TotalDrivingDistance, 
			SweetSpot,
			Idle, 
			OverRevWithFuel,
			Cruise, 
			SpeedGauge,
			EngineServiceBrake,
			HarshBraking,  
			CoastInGear, 
			OverSpeed,  
			Rop, 
			OverRevWithoutFuel, 
			Pto,
			FuelEcon,
			@sdate AS sdate,
			@edate AS edate,

			@diststr AS DistanceUnit,
			@fuelstr AS FuelUnit,

			dbo.GYRColourConfig(Score, 18, @rprtcfgid) AS ScoreColour,
			dbo.GYRColourConfig(SweetSpot*100, 1, @rprtcfgid) AS SweetSpotColour,
			dbo.GYRColourConfig(Idle*100, 6, @rprtcfgid) AS IdleColour,
			dbo.GYRColourConfig(OverRevWithFuel*100, 2, @rprtcfgid) AS OverRevWithFuelColour,
			dbo.GYRColourConfig(Cruise*100, 4, @rprtcfgid) AS CruiseColour,
			dbo.GYRColourConfig(EngineServiceBrake*100, 7, @rprtcfgid) AS EngineServiceBrakeColour,
			dbo.GYRColourConfig(HarshBraking, 12, @rprtcfgid) AS HarshBrakingColour,
			dbo.GYRColourConfig(CoastInGear*100, 5, @rprtcfgid) AS CoastInGearColour,			
			dbo.GYRColourConfig(SpeedGauge*100, 59, @rprtcfgid) AS SpeedGaugeColour	
	FROM
		(SELECT *,
			
			Score = dbo.ScorePerformanceConfig(SweetSpot, OverRevWithFuel, NULL, Cruise, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, NULL, HarshBraking, NULL, @rprtcfgid),
			NULL AS IsScoreBetter
		FROM
			(SELECT
				CASE WHEN (GROUPING(v.VehicleId) = 1) THEN NULL
					ELSE ISNULL(v.VehicleId, NULL)
				END AS VehicleId,

				CASE WHEN (GROUPING(d.DriverId) = 1) THEN NULL
					ELSE ISNULL(d.DriverId, NULL)
				END AS DriverId,
				
				SUM(InSweetSpotDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS SweetSpot,
				SUM(FueledOverRPMDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS OverRevWithFuel,
				SUM(CruiseControlDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS Cruise,

				ISNULL(SUM(ro.Incidents) / CAST(SUM(ro.Observations) AS FLOAT), 0) AS SpeedGauge,

				SUM(CoastInGearDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS CoastInGear,
				CAST(SUM(IdleTime) AS float) / dbo.ZeroYieldNull(SUM(TotalTime)) AS Idle,
				CAST(SUM(PTOMovingTime) + SUM(PTONonMovingTime) AS float) / dbo.ZeroYieldNull(SUM(TotalTime)) AS Pto,
				ISNULL(SUM(EngineBrakeDistance) / dbo.ZeroYieldNull(SUM(ServiceBrakeDistance + EngineBrakeDistance)),0) AS EngineServiceBrake,
				ISNULL(SUM(EngineBrakeOverRPMDistance) / dbo.ZeroYieldNull(SUM(EngineBrakeDistance)),0) AS OverRevWithoutFuel,
				ISNULL((SUM(ROPCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000))))),0) AS Rop,
				ISNULL(SUM(reporting.OverSpeedDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)),0) AS OverSpeed,
				ISNULL((SUM(PanicStopCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000))))),0) AS HarshBraking,
				SUM(DrivingDistance * 1000 * @distmult) AS TotalDrivingDistance,

				(CASE WHEN @fuelmult = 0.1 THEN
					(CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel  * ISNULL(FuelMultiplier,1.0))*100 END)/SUM(DrivingDistance + PTOMovingDistance) 
				ELSE
					(SUM(DrivingDistance + PTOMovingDistance) * 1000) / (CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel * ISNULL(FuelMultiplier,1.0)) END) * @fuelmult END) AS FuelEcon
					
			FROM 	dbo.Reporting
				INNER JOIN dbo.Vehicle v ON Reporting.VehicleIntId = v.VehicleIntId
						INNER JOIN dbo.Driver d ON Reporting.DriverIntId = d.DriverIntId
				LEFT JOIN dbo.ReportingOverspeed ro ON reporting.VehicleIntId = ro.VehicleIntId AND reporting.DriverIntId = ro.DriverIntId AND reporting.Date = ro.Date 
			WHERE reporting.Date BETWEEN @sdate AND @edate 
			  AND d.DriverId = @did

			GROUP BY d.DriverId, v.VehicleId WITH CUBE
			HAVING SUM(DrivingDistance) > 10 ) o
		) p

	LEFT JOIN dbo.Vehicle v ON p.VehicleId = v.VehicleId
	LEFT JOIN dbo.Driver d ON p.DriverId = d.DriverId) CubeResult

WHERE CubeResult.DriverId = @did 

UNION -- get prior period to calculate IsScoreBetter

SELECT *
FROM 
	(SELECT
			v.VehicleId,	
			Registration,
			d.DriverId,
			d.Surname + ' ' + d.Firstname as DriverName,
     		99 AS WeekNumber,
     		NULL AS WStartDate,
     		NULL AS WEndDate,
			Score, 
			IsScoreBetter,
			TotalDrivingDistance, 
			SweetSpot,
			Idle, 
			OverRevWithFuel,
			Cruise, 

			SpeedGauge,


			EngineServiceBrake,
			HarshBraking,  
			CoastInGear, 
			OverSpeed,  
			Rop, 
			OverRevWithoutFuel, 
			Pto,
			FuelEcon,
			@sdate AS sdate,
			@edate AS edate,

			@diststr AS DistanceUnit,
			@fuelstr AS FuelUnit,

			dbo.GYRColourConfig(Score, 18, @rprtcfgid) AS ScoreColour,
			dbo.GYRColourConfig(SweetSpot*100, 1, @rprtcfgid) AS SweetSpotColour,
			dbo.GYRColourConfig(Idle*100, 6, @rprtcfgid) AS IdleColour,
			dbo.GYRColourConfig(OverRevWithFuel*100, 2, @rprtcfgid) AS OverRevWithFuelColour,
			dbo.GYRColourConfig(Cruise*100, 4, @rprtcfgid) AS CruiseColour,
			dbo.GYRColourConfig(EngineServiceBrake*100, 7, @rprtcfgid) AS EngineServiceBrakeColour,
			dbo.GYRColourConfig(HarshBraking, 12, @rprtcfgid) AS HarshBrakingColour,
			dbo.GYRColourConfig(CoastInGear*100, 5, @rprtcfgid) AS CoastInGearColour,
			dbo.GYRColourConfig(SpeedGauge*100, 59, @rprtcfgid) AS SpeedGaugeColour			

	FROM
		(SELECT *,
			
			Score = dbo.ScorePerformanceConfig(SweetSpot, OverRevWithFuel, NULL, Cruise, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, NULL, HarshBraking, NULL, @rprtcfgid),
			NULL AS IsScoreBetter
		FROM
			(SELECT
				CASE WHEN (GROUPING(v.VehicleId) = 1) THEN NULL
					ELSE ISNULL(v.VehicleId, NULL)
				END AS VehicleId,

				CASE WHEN (GROUPING(d.DriverId) = 1) THEN NULL
					ELSE ISNULL(d.DriverId, NULL)
				END AS DriverId,

				SUM(InSweetSpotDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS SweetSpot,
				SUM(FueledOverRPMDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS OverRevWithFuel,
				SUM(CruiseControlDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS Cruise,

				ISNULL(SUM(ro.Incidents) / CAST(SUM(ro.Observations) AS FLOAT), 0) AS SpeedGauge,

				SUM(CoastInGearDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS CoastInGear,
				CAST(SUM(IdleTime) AS float) / dbo.ZeroYieldNull(SUM(TotalTime)) AS Idle,
				CAST(SUM(PTOMovingTime) + SUM(PTONonMovingTime) AS float) / dbo.ZeroYieldNull(SUM(TotalTime)) AS Pto,
				ISNULL(SUM(EngineBrakeDistance) / dbo.ZeroYieldNull(SUM(ServiceBrakeDistance + EngineBrakeDistance)),0) AS EngineServiceBrake,
				ISNULL(SUM(EngineBrakeOverRPMDistance) / dbo.ZeroYieldNull(SUM(EngineBrakeDistance)),0) AS OverRevWithoutFuel,
				ISNULL((SUM(ROPCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000))))),0) AS Rop,
				ISNULL(SUM(reporting.OverSpeedDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)),0) AS OverSpeed,
				ISNULL((SUM(PanicStopCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000))))),0) AS HarshBraking,
				SUM(DrivingDistance * 1000 * @distmult) AS TotalDrivingDistance,

				(CASE WHEN @fuelmult = 0.1 THEN
					(CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel  * ISNULL(FuelMultiplier,1.0))*100 END)/SUM(DrivingDistance + PTOMovingDistance) 
				ELSE
					(SUM(DrivingDistance + PTOMovingDistance) * 1000) / (CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel * ISNULL(FuelMultiplier,1.0)) END) * @fuelmult END) AS FuelEcon
					
			FROM 	dbo.Reporting
						INNER JOIN dbo.Vehicle v ON Reporting.VehicleIntId = v.VehicleIntId
						INNER JOIN dbo.Driver d ON Reporting.DriverIntId = d.DriverIntId
						LEFT JOIN dbo.ReportingOverspeed ro ON reporting.VehicleIntId = ro.VehicleIntId AND reporting.DriverIntId = ro.DriverIntId AND reporting.Date = ro.Date 
			WHERE reporting.Date BETWEEN DATEADD(dd, DATEDIFF(dd,@edate,@sdate)-1 ,@sdate) AND DATEADD(dd,-1,@sdate)
			  AND d.DriverId = @did

			GROUP BY d.DriverId, v.VehicleId WITH CUBE
			HAVING SUM(DrivingDistance) > 10 ) o
		) p

	LEFT JOIN dbo.Vehicle v ON p.VehicleId = v.VehicleId
	LEFT JOIN dbo.Driver d ON p.DriverId = d.DriverId) CubeResult

WHERE CubeResult.DriverId = @did 
  AND VehicleId IS NULL

SELECT 
		  r1.VehicleId ,
		  r1.Registration ,
		  r1.DriverId ,
		  r1.DriverName ,
		  r1.WeekNumber ,
		  [dbo].TZ_GetTime(r1.WStartDate,default,@uid) AS WStartDate,
		  [dbo].TZ_GetTime(r1.WEndDate,default,@uid) AS WEndDate ,
		  r1.Score ,
		  IsScoreBetter = CASE 
			WHEN r1.Score-r2.Score > 0 THEN 0
			WHEN r1.Score-r2.Score < 0 THEN 1
			ELSE NULL
		  END,
		  r1.TotalDrivingDistance ,
		  r1.SweetSpot ,
		  r1.Idle ,
		  r1.OverRevWithFuel ,
		  r1.Cruise ,
		  r1.SpeedGauge,
		  r1.EngineServiceBrake ,
		  CEILING(r1.HarshBraking) AS HarshBraking ,
		  r1.CoastInGear ,
		  r1.OverSpeed ,
		  CEILING(r1.Rop) AS Rop ,
		  r1.OverRevWithoutFuel ,
		  r1.Pto ,
		  r1.FuelEcon ,
		  r1.sdate ,
		  r1.edate ,
		  r1.DistanceUnit ,
		  r1.FuelUnit ,
		  r1.ScoreColour ,
		  r1.SweetSpotColour ,
		  r1.IdleColour ,
		  r1.OverRevWithFuelColour ,
		  r1.CruiseColour ,
		  r1.EngineServiceBrakeColour ,
		  r1.HarshBrakingColour ,
		  r1.CoastInGearColour,
		  r1.SpeedGaugeColour
FROM @ResultSet r1
LEFT JOIN @ResultSet r2 ON (r1.VehicleId = r2.VehicleId OR (r1.VehicleId IS NULL AND r2.VehicleId IS NULL))
		AND r1.driverid = r2.driverid 
		AND r1.WeekNumber IS NULL AND r2.WeekNumber = 99
WHERE r1.weeknumber IS NULL 
ORDER BY r1.WeekNumber, r1.Registration


GO
