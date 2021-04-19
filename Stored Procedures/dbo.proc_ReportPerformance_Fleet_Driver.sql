SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
--
CREATE PROCEDURE [dbo].[proc_ReportPerformance_Fleet_Driver]
(
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER
) 
AS

--DECLARE	@uid uniqueidentifier,
--		@rprtcfgid uniqueidentifier
--
--SET @uid = N'38AAFFD4-1AE7-479B-889A-4D7F52C0DB58'
--SET @rprtcfgid = N'3FED49AA-15C3-4875-A980-D252A6DAEF80'

DECLARE @diststr varchar(20),
		@distmult float,
		@fuelstr varchar(20),
		@fuelmult float,
		@co2str varchar(20),
		@co2mult FLOAT,
		@sdate DATETIME,
		@edate DATETIME,
		@sdate0 DATETIME,
		@edate0 DATETIME

SELECT @diststr = [dbo].UserPref(@uid, 203)
SELECT @distmult = [dbo].UserPref(@uid, 202)
SELECT @fuelstr = [dbo].UserPref(@uid, 205)
SELECT @fuelmult = [dbo].UserPref(@uid, 204)
SELECT @co2str = [dbo].UserPref(@uid, 211)
SELECT @co2mult = [dbo].UserPref(@uid, 210)

SET @edate = GETUTCDATE()
SET @sdate = CAST(CAST(YEAR(dateadd(month,-3,@edate)) AS VARCHAR(4)) + '/' + 
                CAST(MONTH(dateadd(month,-3,@edate)) AS VARCHAR(2)) + '/01' AS DATETIME)
                
-- set dates for prior period (period 0) to calculate IsScoreBetter for period 1
SET @sdate0 = DATEADD(MONTH,-1,@sdate)
SET @edate0 = DATEADD(dd,-1,@sdate)

--SET @sdate = [dbo].TZ_ToUTC(@sdate,default,@uid)
--SET @edate = [dbo].TZ_ToUTC(@edate,default,@uid)

DECLARE @ResultSet TABLE (
	Period INT,
	GroupId UNIQUEIDENTIFIER,
	GroupName VARCHAR(255),
	Distance FLOAT,
	Score FLOAT )

INSERT INTO @ResultSet
        ( Period, GroupId, GroupName, Distance, Score )

SELECT
		Period,
 		[Group].GroupId,
 		GroupName,		
 		TotalDrivingDistance AS Distance,
		Score
FROM
	(SELECT *,
		
		Score = dbo.ScorePerformanceConfig(SweetSpot, OverRevWithFuel, TopGear, Cruise, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, CoastOutOfGear, HarshBraking, CruiseTopGearRatio, @rprtcfgid)
	FROM
		(SELECT		
			CASE WHEN (GROUPING(DATEPART(mm,r.Date)) = 1) THEN NULL
				ELSE ISNULL(datepart(mm,r.Date), NULL)
			END AS Period,
				
			CASE WHEN (GROUPING(gd.GroupId) = 1) THEN NULL
				ELSE ISNULL(gd.GroupId, NULL)
			END AS GroupId,
			
			CONVERT(CHAR(6), MAX(r.Date), 112) AS ScorePeriod,
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
				(CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel  * ISNULL(@fuelmult,1.0))*100 END)/SUM(DrivingDistance + PTOMovingDistance) 
			ELSE
				(SUM(DrivingDistance + PTOMovingDistance) * 1000) / (CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel * ISNULL(@fuelmult,1.0)) END) * @fuelmult END) AS FuelEcon
				
		FROM 	dbo.Reporting r
						INNER JOIN dbo.Driver d ON r.DriverIntId = d.DriverIntId
						INNER JOIN GroupDetail gd ON gd.EntityDataId = d.DriverId
						INNER JOIN dbo.UserGroup ug ON ug.GroupId = gd.GroupId AND ug.UserId = @uid
		WHERE Date BETWEEN @sdate AND @edate 
			AND ug.Archived = 0
		GROUP BY DATEPART(mm,r.Date), gd.GroupId WITH CUBE
		HAVING SUM(DrivingDistance) > 10 ) o
	) CubeResult

LEFT JOIN [Group] ON CubeResult.GroupId = [Group].GroupId
WHERE Period is NOT NULL

UNION

SELECT
		Period,
 		[Group].GroupId,
 		GroupName,		
 		TotalDrivingDistance AS Distance,
		Score
FROM
	(SELECT *,
		
		Score = dbo.ScorePerformanceConfig(SweetSpot, OverRevWithFuel, TopGear, Cruise, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, CoastOutOfGear, HarshBraking, CruiseTopGearRatio, @rprtcfgid)
	FROM
		(SELECT		
			CASE WHEN (GROUPING(DATEPART(mm,r.Date)) = 1) THEN NULL
				ELSE ISNULL(datepart(mm,r.Date), NULL)
			END AS Period,
						
			CASE WHEN (GROUPING(gd.GroupId) = 1) THEN NULL
				ELSE ISNULL(gd.GroupId, NULL)
			END AS GroupId,
			
			CONVERT(CHAR(6), MAX(r.Date), 112) AS ScorePeriod,
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
				(CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel  * ISNULL(@fuelmult,1.0))*100 END)/SUM(DrivingDistance + PTOMovingDistance) 
			ELSE
				(SUM(DrivingDistance + PTOMovingDistance) * 1000) / (CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel * ISNULL(@fuelmult,1.0)) END) * @fuelmult END) AS FuelEcon
				
		FROM 	dbo.Reporting r
			INNER JOIN dbo.Driver d ON r.DriverIntId = d.DriverIntId
			INNER JOIN GroupDetail gd ON gd.EntityDataId = d.DriverId
			INNER JOIN dbo.UserGroup ug ON ug.GroupId = gd.GroupId AND ug.UserId = @uid
		WHERE Date BETWEEN @sdate0 AND @edate0 
			AND ug.Archived = 0
		GROUP BY DATEPART(mm,r.Date), gd.GroupId WITH CUBE
		HAVING SUM(DrivingDistance) > 10 ) o
	) CubeResult

LEFT JOIN [Group] ON CubeResult.GroupId = [Group].GroupId
WHERE Period is NOT NULL

DECLARE @Groups TABLE (GroupId UNIQUEIDENTIFIER, GroupName VARCHAR(255))
INSERT INTO @Groups
SELECT DISTINCT GroupId, GroupName
FROM @ResultSet

SELECT	g.GroupId, 
		g.GroupName, 
		r4.Distance,
		r1.Score AS ScorePeriod1,
		IsScoreBetterPeriod1 = CASE 
			WHEN r0.Score-r1.Score > 0 THEN 0
			WHEN r0.Score-r1.Score < 0 THEN 1
			ELSE NULL
		END, 
		CONVERT(CHAR(6), DATEADD(mm, -3,GETUTCDATE()), 112) AS ScorePeriodDate1,
		r2.Score AS ScorePeriod2,
		IsScoreBetterPeriod2 = CASE 
			WHEN r1.Score-r2.Score < 0 THEN 0
			WHEN r1.Score-r2.Score > 0 THEN 1
			ELSE NULL
		END,
		CONVERT(CHAR(6), DATEADD(mm, -2,GETUTCDATE()), 112) AS ScorePeriodDate2,
		r3.Score AS ScorePeriod3, 
		IsScoreBetterPeriod3 = CASE 
			WHEN r2.Score-r3.Score < 0 THEN 0
			WHEN r2.Score-r3.Score > 0 THEN 1
			ELSE NULL
		END,
		CONVERT(CHAR(6), DATEADD(mm, -1,GETUTCDATE()), 112) AS ScorePeriodDate3,
		r4.Score AS ScorePeriod4,
		IsScoreBetterPeriod4 = CASE 
			WHEN r3.Score-r4.Score < 0 THEN 0
			WHEN r3.Score-r4.Score > 0 THEN 1
			ELSE NULL
		END,
		CONVERT(CHAR(6), GETUTCDATE(), 112) AS ScorePeriodDate4,
		dbo.GYRColourConfig(r1.Score, 18, @rprtcfgid) AS ScorePeriodColour1,
		dbo.GYRColourConfig(r2.Score, 18, @rprtcfgid) AS ScorePeriodColour2,
		dbo.GYRColourConfig(r3.Score, 18, @rprtcfgid) AS ScorePeriodColour3,
		dbo.GYRColourConfig(r4.Score, 18, @rprtcfgid) AS ScorePeriodColour4,
		@sdate AS sdate,
		@edate AS edate,
		[dbo].TZ_GetTime(@sdate,default,@uid) AS CreationDateTime,
		[dbo].TZ_GetTime(@edate,default,@uid) AS ClosureDateTime
FROM @Groups g
LEFT JOIN @ResultSet r0 ON (g.GroupId = r0.GroupId OR g.GroupId IS NULL AND r0.GroupId IS NULL) AND r0.Period = DATEPART(mm,GETUTCDATE())-4
LEFT JOIN @ResultSet r1 ON (g.GroupId = r1.GroupId OR g.GroupId IS NULL AND r1.GroupId IS NULL) AND r1.Period = DATEPART(mm,GETUTCDATE())-3
LEFT JOIN @ResultSet r2 ON (g.GroupId = r2.GroupId OR g.GroupId IS NULL AND r2.GroupId IS NULL) AND r2.Period = DATEPART(mm,GETUTCDATE())-2
LEFT JOIN @ResultSet r3 ON (g.GroupId = r3.GroupId OR g.GroupId IS NULL AND r3.GroupId IS NULL) AND r3.Period = DATEPART(mm,GETUTCDATE())-1
LEFT JOIN @ResultSet r4 ON (g.GroupId = r4.GroupId OR g.GroupId IS NULL AND r4.GroupId IS NULL) AND r4.Period = DATEPART(mm,GETUTCDATE())






GO
