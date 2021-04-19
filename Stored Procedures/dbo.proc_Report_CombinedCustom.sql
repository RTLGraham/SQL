SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_Report_CombinedCustom]
(
	@dids varchar(max),
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER
)
AS

--DECLARE	@dids varchar(max),
--		@sdate datetime,
--		@edate datetime,
--		@uid uniqueidentifier,
--		@rprtcfgid UNIQUEIDENTIFIER
--
--SET @dids = N'CADD2E69-47A6-4AE9-941D-9673F8F91563'
--SET @sdate = '2011-08-13 00:00'
--SET @edate = GETDATE()
--SET @uid = N'8DA18520-50CA-402F-AE8E-6015B443B92C' 
--SET @rprtcfgid = N'77C80BDB-5827-4C5E-BBF4-06F36ACB47D6' 

DECLARE @diststr varchar(20),
		@distmult float,
		@fuelstr varchar(20),
		@fuelmult float,
		@co2str varchar(20),
		@co2mult FLOAT,
		@speedMult FLOAT

SELECT @diststr = [dbo].UserPref(@uid, 203)
SELECT @distmult = [dbo].UserPref(@uid, 202)
SELECT @fuelstr = [dbo].UserPref(@uid, 205)
SELECT @fuelmult = [dbo].UserPref(@uid, 204)
SELECT @co2str = [dbo].UserPref(@uid, 211)
SELECT @co2mult = [dbo].UserPref(@uid, 210)
SELECT @speedMult = [dbo].UserPref(@uid, 208)

SET @sdate = [dbo].TZ_ToUTC(@sdate,default,@uid)
SET @edate = [dbo].TZ_ToUTC(@edate,default,@uid)


SELECT *
FROM 
	(SELECT
			v.VehicleId,	
			Registration,
			d.DriverId,
     		dbo.FormatDriverNameByUser(d.DriverId, @uid) as DriverName,
			SweetSpot, OverRevWithFuel, TopGear, Cruise, CoastInGear, Idle, TotalTime, 
			ServiceBrakeUsage, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, 
			CoastOutOfGear, HarshBraking, TotalDrivingDistance, FuelEcon,
			Pto,
			Co2, 			
			CruiseTopGearRatio,
			AverageSpeed,
			
			Efficiency, Safety,
			
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
			dbo.GYRColourConfig(FuelEcon, 16, @rprtcfgid) AS KPLColour,
			dbo.GYRColourConfig(Efficiency, 14, @rprtcfgid) AS EfficiencyColour,
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
			
			Efficiency = dbo.ScoreEfficiencyConfig(SweetSpot, OverRevWithFuel, TopGear, Cruise, Idle, CruiseTopGearRatio, @rprtcfgid),
			Safety = dbo.ScoreSafetyConfig(CoastInGear, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, CoastOutOfGear, HarshBraking, NULL, NULL, NULL, @rprtcfgid)
		FROM
			(SELECT
				CASE WHEN (GROUPING(v.VehicleId) = 1) THEN NULL
					ELSE ISNULL(v.VehicleId, NULL)
				END AS VehicleId,

				CASE WHEN (GROUPING(d.DriverId) = 1) THEN NULL
					ELSE ISNULL(d.DriverId, NULL)
				END AS DriverId,

				ISNULL(SUM(DrivingDistance + PTOMovingDistance) / dbo.ZeroYieldNull(SUM(TotalTime/CAST(3600 AS FLOAT))) * @speedMult, 0) AS AverageSpeed,
				
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
				ISNULL(SUM(ServiceBrakeDistance + EngineBrakeDistance),0) AS EngineServiceBrake,
				ISNULL(SUM(EngineBrakeOverRPMDistance) / dbo.ZeroYieldNull(SUM(EngineBrakeDistance)),0) AS OverRevWithoutFuel,
				ISNULL((SUM(ROPCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000))))),0) AS Rop,
				ISNULL(SUM(OverSpeedDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)),0) AS OverSpeed,
				ISNULL(SUM(CoastOutOfGearDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)),0) AS CoastOutOfGear,
				ISNULL((SUM(PanicStopCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000))))),0) AS HarshBraking,
				SUM(DrivingDistance * 1000 * @distmult) AS TotalDrivingDistance,

				(CASE WHEN @fuelmult = 0.1 THEN
					(CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel * ISNULL(FuelMultiplier,1.0))*100 END)/SUM(DrivingDistance + PTOMovingDistance) 
				ELSE
					(SUM(DrivingDistance + PTOMovingDistance) * 1000) / (CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel * ISNULL(FuelMultiplier,1.0)) END) * @fuelmult END) AS FuelEcon
					
			FROM 	dbo.Reporting r
						INNER JOIN dbo.Vehicle v ON r.VehicleIntId = v.VehicleIntId
						INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
						INNER JOIN dbo.Driver d ON r.DriverIntId = d.DriverIntId
						INNER JOIN dbo.CustomerDriver cd ON d.DriverId = cd.DriverId
						INNER JOIN dbo.Customer c ON cd.CustomerId = c.CustomerId AND cv.CustomerId = c.CustomerId

			WHERE Date BETWEEN @sdate AND @edate 
			GROUP BY d.DriverId, v.VehicleId /*, DepotId */ WITH CUBE
			HAVING SUM(DrivingDistance) > 10 /* AND DepotId != 999 */) o
		) p

	LEFT JOIN dbo.Vehicle v ON p.VehicleId = v.VehicleId
	LEFT JOIN dbo.Driver d ON p.DriverId = d.DriverId) CubeResult

WHERE (CubeResult.VehicleId IS NULL AND CubeResult.DriverId IS NULL)
  OR CubeResult.DriverId IN (SELECT Value FROM dbo.Split(@dids, ','))
  OR (CubeResult.VehicleId IN (SELECT DISTINCT v.VehicleId
								FROM dbo.Reporting r
									INNER JOIN dbo.Vehicle v ON r.VehicleIntId = v.VehicleIntId
									INNER JOIN dbo.Driver d ON r.DriverIntId = d.DriverIntId
								WHERE d.DriverId IN (SELECT Value FROM dbo.Split(@dids, ','))
								  AND r.Date BETWEEN @sdate AND @edate) AND DriverId IS NULL)

ORDER BY Registration, DriverName



GO
