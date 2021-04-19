SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_Report_DrillDown_Vehicle]
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
	@calendar TINYINT
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
--		@calendar TINYINT
--		
--SET @vids = NULL --N'53B878DA-091D-4722-B467-1463EE502C19,AD7AE29D-1328-4228-B4C2-194D6C90A266,2F29E214-4249-4412-9927-1BBFF111DF1B'
--SET @gids = N'B04062C4-67FA-41A9-9BFC-4776782653B4,7BF24193-706A-4AC2-93A2-65177209B0E8,EA6FF8F6-F6EA-4632-9607-7B0A8A8A8DDB'
--SET @vehicletypeid = NULL
--SET @routeid = NULL
--SET	@sdate = '2012-02-02 10:00'
--SET	@edate = '2012-03-10 17:00'
--SET	@uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
--SET	@rprtcfgid = N'6FAD9660-775F-4E1D-94B2-613CD4F94D65'
--SET @drilldown = 1
--SET @calendar = 0

DECLARE @diststr varchar(20),
		@distmult float,
		@fuelstr varchar(20),
		@fuelmult float,
		@co2str varchar(20),
		@co2mult FLOAT,
		@liquidstr VARCHAR(20),
		@liquidmult float

SELECT @diststr = [dbo].UserPref(@uid, 203)
SELECT @distmult = [dbo].UserPref(@uid, 202)
SELECT @fuelstr = [dbo].UserPref(@uid, 205)
SELECT @fuelmult = [dbo].UserPref(@uid, 204)
SELECT @co2str = [dbo].UserPref(@uid, 211)
SELECT @co2mult = [dbo].UserPref(@uid, 210)
SELECT @liquidstr = [dbo].UserPref(@uid, 201)
SELECT @liquidmult = [dbo].UserPref(@uid, 200)

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
        FROM    dbo.CreateDependentDateRange(@sdate, @edate, @uid, @drilldown, @calendar, NULL)

-- Convert dates to UTC
SET @sdate = [dbo].TZ_ToUTC(@sdate,default,@uid)
SET @edate = [dbo].TZ_ToUTC(@edate,default,@uid)

SELECT
		-- Vehicle, Driver and Group Identification columns
		p.PeriodNum,
		[dbo].TZ_GetTime(p.StartDate,default,@uid) AS WeekStartDate,
		[dbo].TZ_GetTime(p.EndDate,default,@uid) AS WeekEndDate,
		p.PeriodType,
		v.VehicleId,	
		v.Registration,
		
		NULL AS DriverId,
 		NULL AS DisplayName,
 		NULL AS FirstName,
 		NULL AS Surname,
 		NULL AS MiddleNames,
 		NULL AS Number,
 		NULL AS NumberAlternate,
 		NULL AS NumberAlternate2,
 		
-- 		g.GroupId,
-- 		g.GroupName,
 		
 		-- Data columns with corresponding colours below 
		SweetSpot, OverRevWithFuel, 
--		TopGear, Cruise, CoastInGear, CruiseTopGearRatio,
		Idle, 
--		EngineServiceBrake, 
		OverRevWithoutFuel, 
--		Rop, OverSpeed, IVHOverSpeed, CoastOutOfGear, HarshBraking, 
		FuelEcon, TotalFuel,
--		Pto, 
		Co2, Acceleration, Braking, Cornering,
		
		-- Score columns
		Efficiency, 
		Safety,
		
		-- Additional columns with no corresponding colour	
--		TotalTime,
		TotalDrivingDistance,
--		ServiceBrakeUsage,
--		EngineBrakeUsage,	
--		OverRevCount,

		-- Date and Unit columns 
		@sdate AS sdate,
		@edate AS edate,
		[dbo].TZ_GetTime(@sdate,default,@uid) AS CreationDateTime,
		[dbo].TZ_GetTime(@edate,default,@uid) AS ClosureDateTime,

		@diststr AS DistanceUnit,
		@fuelstr AS FuelUnit,
		@co2str AS Co2Unit,
		@fuelmult AS FuelMult,
		@liquidstr AS LiquidUnit,
		
		-- Colour columns corresponding to data columns above
--		dbo.GYRColourConfig(SweetSpot*100, 1, @rprtcfgid) AS SweetSpotColour,
--		dbo.GYRColourConfig(OverRevWithFuel*100, 2, @rprtcfgid) AS OverRevWithFuelColour,
--		dbo.GYRColourConfig(TopGear*100, 3, @rprtcfgid) AS TopGearColour,
--		dbo.GYRColourConfig(Cruise*100, 4, @rprtcfgid) AS CruiseColour,
--		dbo.GYRColourConfig(CoastInGear*100, 5, @rprtcfgid) AS CoastInGearColour,
--		dbo.GYRColourConfig(CruiseTopGearRatio*100, 25, @rprtcfgid) AS CruiseTopGearRatioColour,
--		dbo.GYRColourConfig(Idle*100, 6, @rprtcfgid) AS IdleColour,
--		dbo.GYRColourConfig(EngineServiceBrake*100, 7, @rprtcfgid) AS EngineServiceBrakeColour,
--		dbo.GYRColourConfig(OverRevWithoutFuel*100, 8, @rprtcfgid) AS OverRevWithoutFuelColour,
--		dbo.GYRColourConfig(Rop, 9, @rprtcfgid) AS RopColour,
--		dbo.GYRColourConfig(OverSpeed*100, 10, @rprtcfgid) AS OverSpeedColour,
--		dbo.GYRColourConfig(IVHOverSpeed*100, 10, @rprtcfgid) AS IVHOverSpeedColour,
--		dbo.GYRColourConfig(CoastOutOfGear*100, 11, @rprtcfgid) AS CoastOutOfGearColour,
--		dbo.GYRColourConfig(HarshBraking, 12, @rprtcfgid) AS HarshBrakingColour,
--		dbo.GYRColourConfig(FuelEcon, 16, @rprtcfgid) AS FuelEconColour,
--		dbo.GYRColourConfig(Acceleration, 22, @rprtcfgid) AS AccelerationColour,
--		dbo.GYRColourConfig(Braking, 23, @rprtcfgid) AS BrakingColour,
--		dbo.GYRColourConfig(Cornering, 24, @rprtcfgid) AS CorneringColour,
		dbo.GYRColourConfig(Efficiency, 14, @rprtcfgid) AS EfficiencyColour,
		dbo.GYRColourConfig(Safety, 15, @rprtcfgid) AS SafetyColour
--		NULL AS OverRevCountColour
		
FROM
	(SELECT *,
		
		Efficiency = dbo.ScoreEfficiencyConfig(SweetSpot, OverRevWithFuel, TopGear, Cruise, Idle, CruiseTopGearRatio, @rprtcfgid),
		Safety = dbo.ScoreSafetyConfig(CoastInGear, EngineServiceBrake, OverRevWithoutFuel, Rop, NULL, /*OverSpeed*/ CoastOutOfGear, HarshBraking, Acceleration, Braking, Cornering, @rprtcfgid)

	FROM
		(SELECT
			CASE WHEN (GROUPING(p.PeriodNum) = 1) THEN NULL
				ELSE ISNULL(p.PeriodNum, NULL)
			END AS PeriodNum,
		
			CASE WHEN (GROUPING(v.VehicleId) = 1) THEN NULL
				ELSE ISNULL(v.VehicleId, NULL)
			END AS VehicleId,
			
--			CASE WHEN (GROUPING(gd.GroupId) = 1) THEN NULL
--				ELSE ISNULL(gd.GroupId, NULL)
--			END AS GroupId,

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
			SUM(EngineBrakeDistance) / CASE WHEN SUM(DrivingDistance + PTOMovingDistance) = 0 THEN NULL ELSE SUM(DrivingDistance + PTOMovingDistance) END AS EngineBrakeUsage,			
			ISNULL(SUM(EngineBrakeDistance) / dbo.ZeroYieldNull(SUM(ServiceBrakeDistance + EngineBrakeDistance)),0) AS EngineServiceBrake,
			ISNULL(SUM(EngineBrakeOverRPMDistance) / dbo.ZeroYieldNull(SUM(EngineBrakeDistance)),0) AS OverRevWithoutFuel,
			ISNULL((SUM(ROPCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000))))),0) AS Rop,
--			ISNULL(SUM(ro.OverSpeedDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)),0) AS OverSpeed,
			ISNULL(SUM(r.OverSpeedDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)),0) AS IVHOverSpeed,
			ISNULL(SUM(CoastOutOfGearDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)),0) AS CoastOutOfGear,
			ISNULL((SUM(PanicStopCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000))))),0) AS HarshBraking,
			SUM(DrivingDistance * 1000 * @distmult) AS TotalDrivingDistance,
			ISNULL((SUM(ORCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000))))),0) AS OverRevCount,
			ISNULL((SUM(abc.Acceleration) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000))))),0) AS Acceleration,
			ISNULL((SUM(abc.Braking) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000))))),0) AS Braking,
			ISNULL((SUM(abc.Cornering) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + PTOMovingDistance) * @distmult * 1000))))),0) AS Cornering,
			SUM(TotalFuel * @liquidmult) AS TotalFuel,
			(CASE WHEN @fuelmult = 0.1 THEN
				(CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel * ISNULL(FuelMultiplier,1.0))*100 END)/SUM(DrivingDistance + PTOMovingDistance) 
			ELSE
				(SUM(DrivingDistance + PTOMovingDistance) * 1000) / (CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel * ISNULL(FuelMultiplier,1.0)) END) * @fuelmult END) AS FuelEcon
				
		FROM dbo.Reporting r
			INNER JOIN dbo.Vehicle v ON r.VehicleIntId = v.VehicleIntId
			INNER JOIN dbo.GroupDetail gd ON v.VehicleId = gd.EntityDataId AND gd.GroupTypeId = 1
			INNER JOIN @period_dates p ON r.Date BETWEEN p.StartDate AND p.EndDate
			INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
			INNER JOIN dbo.[User] u ON cv.CustomerId = u.CustomerID
			LEFT JOIN dbo.ReportingABC abc ON r.VehicleIntId = abc.VehicleIntId AND r.DriverIntId = abc.DriverIntId AND r.Date = abc.Date AND r.RouteID = abc.RouteId
--			LEFT JOIN dbo.ReportingOverspeed ro ON r.VehicleIntId = ro.VehicleIntId AND r.DriverIntId = ro.DriverIntId AND r.Date = ro.Date AND r.RouteId = ro.RouteId

		WHERE r.Date BETWEEN @sdate AND @edate
		  AND (v.VehicleId IN (SELECT Value FROM dbo.Split(@vids, ',')) OR @vids IS NULL)
		  AND (gd.GroupId IN (SELECT Value FROM dbo.Split(@gids, ',')) OR @gids IS NULL)
		  AND v.Archived = 0
		  AND cv.Archived = 0	
		  AND u.UserID = @uid
		  AND (v.VehicleTypeID = @vehicletypeid OR @vehicletypeid IS NULL)
		  AND (r.RouteID = @routeid OR @routeid IS NULL)

		GROUP BY p.PeriodNum, v.VehicleId /*, gd.GroupId*/ WITH CUBE
		HAVING SUM(DrivingDistance) > 10 ) o
	) Result

LEFT JOIN dbo.Vehicle v ON Result.VehicleId = v.VehicleId
--LEFT JOIN dbo.[Group] g ON Result.GroupId = g.GroupId
LEFT JOIN @period_dates p ON Result.PeriodNum = p.PeriodNum




GO
