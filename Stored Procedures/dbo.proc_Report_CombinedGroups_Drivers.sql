SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_Report_CombinedGroups_Drivers]
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
--		@rprtcfgid UNIQUEIDENTIFIER,
--		@groupType INT
		
--SET @groupType = 2
--SET @gids = N'2DE3180F-2328-4AC2-827F-6A9A2D05B042'
--SET @sdate = '2012-03-01 00:00'
--SET @edate = GETDATE()
--SET @uid = N'8DA18520-50CA-402F-AE8E-6015B443B92C' 
--SET @rprtcfgid = N'77C80BDB-5827-4C5E-BBF4-06F36ACB47D6' 

DECLARE @diststr varchar(20),
		@distmult float,
		@fuelstr varchar(20),
		@fuelmult float,
		@co2str varchar(20),
		@co2mult FLOAT,
		@speedstr varchar(20),
		@speedMult FLOAT,
		@liquidstr varchar(20),
		@liquidmult float

SELECT @diststr = [dbo].UserPref(@uid, 203)
SELECT @distmult = [dbo].UserPref(@uid, 202)
SELECT @fuelstr = [dbo].UserPref(@uid, 205)
SELECT @fuelmult = [dbo].UserPref(@uid, 204)
SELECT @co2str = [dbo].UserPref(@uid, 211)
SELECT @co2mult = [dbo].UserPref(@uid, 210)
SELECT @speedMult = [dbo].UserPref(@uid, 208)
SELECT @speedstr = [dbo].UserPref(@uid, 209)
SELECT @liquidstr = [dbo].UserPref(@uid, 201)
SELECT @liquidmult = [dbo].UserPref(@uid, 200)

SET @sdate = [dbo].TZ_ToUTC(@sdate,default,@uid)
SET @edate = [dbo].TZ_ToUTC(@edate,default,@uid)

SELECT *
FROM 
	(SELECT
			g.GroupId,
			g.GroupName,
			--Vehicles.VehicleId,	
			--Registration,
			--Drivers.DriverId,
     		--DriverName, 
			SweetSpot, OverRevWithFuel, TopGear, Cruise, CoastInGear, Idle, TotalTime, 
			ServiceBrakeUsage, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, 
			CoastOutOfGear, HarshBraking, TotalDrivingDistance, FuelEcon, TotalFuel,
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
			@fuelstr AS SpeedUnit,
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
			Safety = dbo.ScoreSafetyConfig(CoastInGear, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, CoastOutOfGear, HarshBraking, Acceleration, Braking, Cornering, @rprtcfgid)
		FROM
			(SELECT
				CASE WHEN (GROUPING(g.GroupId) = 1) THEN NULL
					ELSE ISNULL(g.GroupId, NULL)
				END AS GroupId,

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
				SUM(ServiceBrakeDistance + EngineBrakeDistance) / CASE WHEN SUM(DrivingDistance + PTOMovingDistance) = 0 THEN NULL ELSE SUM(DrivingDistance + PTOMovingDistance) END AS ServiceBrakeUsage,
				ISNULL(SUM(ServiceBrakeDistance + EngineBrakeDistance),0) AS EngineServiceBrake,
				ISNULL(SUM(EngineBrakeOverRPMDistance) / dbo.ZeroYieldNull(SUM(EngineBrakeDistance)),0) AS OverRevWithoutFuel,
				ISNULL((SUM(ROPCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000))))),0) AS Rop,
				ISNULL(SUM(OverSpeedDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)),0) AS OverSpeed,
				ISNULL(SUM(CoastOutOfGearDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)),0) AS CoastOutOfGear,
				ISNULL((SUM(PanicStopCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000))))),0) AS HarshBraking,
				SUM(DrivingDistance * 1000 * @distmult) AS TotalDrivingDistance,
				SUM(RABC.Acceleration) AS Acceleration,
				SUM(RABC.Braking) AS Braking,
				SUM(RABC.Cornering) AS Cornering,

				(CASE WHEN @fuelmult = 0.1 THEN
					(CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel)*100 END)/SUM(DrivingDistance + PTOMovingDistance) 
				ELSE
					(SUM(DrivingDistance + PTOMovingDistance) * 1000) / (CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel) END) * @fuelmult END) AS FuelEcon,
				SUM(TotalFuel * @liquidmult) AS TotalFuel
					
			FROM 	dbo.Reporting R
				INNER JOIN dbo.ReportingABC RABC
					ON R.Date = RABC.Date
					AND R.DriverIntId = RABC.DriverIntId
					AND R.VehicleIntId = RABC.VehicleIntId
					AND R.RouteID = RABC.RouteId
				INNER JOIN dbo.Driver ON R.DriverIntId = Driver.DriverIntId
				INNER JOIN dbo.GroupDetail gd ON gd.EntityDataId = Driver.DriverId
				INNER JOIN dbo.[Group] g ON gd.GroupId = g.GroupId
			
			WHERE R.Date BETWEEN @sdate AND @edate 
				AND g.GroupTypeId = 2 AND g.Archived = 0 AND g.IsParameter = 0
				AND g.GroupId IN (SELECT Value FROM dbo.Split(@gids, ','))
			GROUP BY g.GroupId WITH CUBE
			HAVING SUM(DrivingDistance) > 10 ) o
		) p
	LEFT JOIN dbo.[Group] g ON p.GroupId = g.GroupId ) CubeResult

WHERE (CubeResult.GroupId IN (SELECT Value FROM dbo.Split(@gids, ',')))
	OR CubeResult.GroupId IS NULL

ORDER BY GroupName


GO
