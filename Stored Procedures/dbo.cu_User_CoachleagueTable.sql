SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cu_User_CoachleagueTable] -- New
(
	@uid UNIQUEIDENTIFIER,
	@sdate DATETIME = NULL,
	@edate DATETIME = NULL
)
AS

	--DECLARE @uid UNIQUEIDENTIFIER,
	--		@sdate DATETIME,
	--		@edate DATETIME

	--SET @uid = N'C13C0754-8B33-49BA-8C93-C5CE1A5F6475'
	----SET @sdate = '2017-07-01 00:00'
	----SET @edate = '2017-07-27 23:59'

	IF @sdate IS NULL AND @edate IS NULL
	BEGIN
		--Start/end of this month
		SET @edate = DATEADD(s, -1, DATEADD(mm, DATEDIFF(m,0,GETDATE())+1,0))
		SET @sdate = DATEADD(s, 1, DATEADD(MONTH, -2, @edate))
	END ELSE
    BEGIN
		SET @sdate = DATEADD(MONTH, -1, @sdate)
	END	

	DECLARE @luid UNIQUEIDENTIFIER,
			@lsdate DATETIME,
			@ledate DATETIME

	SET @luid = @uid
	SET @lsdate = @sdate
	SET @ledate = @edate

	DECLARE @distmult FLOAT,
			@fuelmult FLOAT,
			@co2mult FLOAT,
			@rprtcfgid UNIQUEIDENTIFIER

	SET @rprtcfgid = N'DDA2FB34-1AB1-4ED7-A53E-BB974EDD2941'
	SET @distmult = Cast([dbo].[UserPref](@luid, 202) as float)
	SET @fuelmult = [dbo].UserPref(@luid, 204)
	SET @co2mult = [dbo].UserPref(@luid, 210)

	DECLARE @period_dates TABLE (
			PeriodNum TINYINT IDENTITY (1,1),
			StartDate DATETIME,
			EndDate DATETIME,
			PeriodType VARCHAR(MAX))
      
	INSERT  INTO @period_dates ( StartDate, EndDate, PeriodType )
	SELECT  StartDate,
			EndDate,
			PeriodType
	FROM    dbo.CreateDependentDateRange(@lsdate, @ledate, @luid, 1, 1, 3) -- split by calendar month

	DECLARE @coaches TABLE
	(
		GroupId UNIQUEIDENTIFIER, 
		GroupName NVARCHAR(MAX),
		Coaches NVARCHAR(MAX)
	)
	INSERT INTO @coaches( GroupId, GroupName, Coaches )
	SELECT DISTINCT 
		g.GroupId, g.GroupName, dbo.fn_AirProducts_GetCoaches(t.TriggerId, c.CustomerId)
	FROM dbo.TAN_Trigger t
		INNER JOIN dbo.TAN_TriggerEntity te ON te.TriggerId = t.TriggerId
		INNER JOIN dbo.Vehicle v ON te.TriggerEntityId = v.VehicleId
		INNER JOIN dbo.GroupDetail gd ON gd.EntityDataId = v.VehicleId
		INNER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId AND g.IsParameter = 0 AND g.Archived = 0 AND g.GroupTypeId = 1
			AND g.GroupName NOT LIKE '%*%' 
			AND g.GroupName NOT LIKE '%Manage%' 
			AND g.GroupName NOT LIKE '%Phil%'
			AND g.GroupName NOT LIKE '%Temporary%'
			AND g.GroupName NOT LIKE '%$%'
		INNER JOIN dbo.TAN_TriggerType tt ON tt.TriggerTypeId = t.TriggerTypeId
		INNER JOIN dbo.Customer c ON c.CustomerId = t.CustomerId
		INNER JOIN dbo.[User] u ON u.CustomerID = c.CustomerId
	WHERE u.UserID = @uid
		AND t.TriggerTypeId = 48
		AND t.Archived = 0
		AND t.Disabled = 0
		AND t.Name LIKE '-%'
		AND RIGHT(LEFT(t.Name, 6), 4) = LEFT(g.GroupName, 4)

	DELETE FROM @coaches WHERE Coaches IS NULL
	
	DECLARE @coachGroups TABLE
	(
		Coaches NVARCHAR(MAX),
		Groups NVARCHAR(MAX),
		GroupIds NVARCHAR(MAX)
	)
	DECLARE @tmp_groupnames NVARCHAR(MAX), @tmp_groupIds NVARCHAR(MAX), @tmp_coaches NVARCHAR(MAX) 

					
	DECLARE c_cur CURSOR FAST_FORWARD FOR
	SELECT DISTINCT Coaches FROM @coaches

	OPEN c_cur
	FETCH NEXT FROM c_cur INTO @tmp_coaches
	WHILE @@fetch_status = 0
	BEGIN
		SET @tmp_groupIds = NULL
		SET @tmp_groupnames = NULL

		SELECT @tmp_groupIds = COALESCE(@tmp_groupIds + ',', '') + CAST(GroupId AS NVARCHAR(MAX))	
		FROM @coaches
		WHERE Coaches = @tmp_coaches

		SELECT @tmp_groupnames = COALESCE(@tmp_groupnames + ', ', '') + GroupName	
		FROM @coaches
		WHERE Coaches = @tmp_coaches

		INSERT INTO @coachGroups
				( Coaches, GroupIds, Groups )
		VALUES  ( @tmp_coaches, @tmp_groupIds, @tmp_groupnames)

		FETCH NEXT FROM c_cur INTO @tmp_coaches
	END
	CLOSE c_cur
	DEALLOCATE c_cur

	DECLARE @IncidentData TABLE
    (
		Date DATETIME,
		VehicleIntId INT,
		DriverIntId INT,		
		Total INT,
		New INT,
		ForReview INT,
		Coachable INT,
		NotRequired INT,
		Coached INT,
		PositiveRecognition INT,
		Archived INT,
		Unused INT
	)					
	INSERT INTO @IncidentData (Date, VehicleIntId, DriverIntId, Total, New, ForReview, Coachable, NotRequired, Coached, PositiveRecognition, Archived, Unused)
	SELECT	CAST(FLOOR(CAST(i.EventDateTime AS FLOAT)) AS DATETIME),
			i.VehicleIntId,
			i.DriverIntId,
			COUNT(*),
			SUM(CASE WHEN i.CoachingStatusId = 0 THEN 1 ELSE 0 END),
			SUM(CASE WHEN i.CoachingStatusId = 1 THEN 1 ELSE 0 END),
			SUM(CASE WHEN i.CoachingStatusId = 2 THEN 1 ELSE 0 END),
			SUM(CASE WHEN i.CoachingStatusId = 3 THEN 1 ELSE 0 END),
			SUM(CASE WHEN i.CoachingStatusId = 4 THEN 1 ELSE 0 END),
			SUM(CASE WHEN i.CoachingStatusId = 97 THEN 1 ELSE 0 END),
			SUM(CASE WHEN i.CoachingStatusId = 98 AND u.Name NOT IN ('AAAdam','AAAdamCoach','AAAdamL','AirAdmin','AirAnalyst','APRTLAdmin','AirNick','AirSam','APRTLAdminCoach','AA') THEN 1 ELSE 0 END),
			SUM(CASE WHEN i.CoachingStatusId = 99 THEN 1 ELSE 0 END)		
	FROM dbo.CAM_Incident i
			LEFT JOIN dbo.VideoCoachingHistory hist ON hist.IncidentId = i.IncidentId AND hist.CoachingStatusId = 98 
			LEFT JOIN dbo.[User] u ON hist.StatusUserId = u.UserID
			INNER JOIN dbo.Vehicle v ON v.VehicleIntId = i.VehicleIntId
			INNER JOIN dbo.Driver d ON d.DriverIntId = i.DriverIntId
			INNER JOIN dbo.GroupDetail gd ON gd.EntityDataId = v.VehicleId
			INNER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId AND g.GroupTypeId = 1 
			INNER JOIN @period_dates p ON p.PeriodNum = 2
	WHERE i.EventDateTime BETWEEN p.StartDate AND p.EndDate
		AND g.GroupId IN (SELECT GroupId FROM @coaches)
		AND i.CreationCodeId IN (436, 437, 438, 455, 456)
	GROUP BY FLOOR(CAST(i.EventDateTime AS FLOAT)), i.VehicleIntId, i.DriverIntId

	DECLARE @data TABLE
	(
		PeriodNum INT,
		Coaches NVARCHAR(MAX),
		Groups NVARCHAR(MAX),
		Drivers INT,
		DistanceTravelled FLOAT,
		Efficiency FLOAT,
		SweetSpot FLOAT, OverRev FLOAT, Idle FLOAT, FuelEcon FLOAT,
		Safety FLOAT,
		OverSpeed FLOAT, Rop FLOAT, Rop2 FLOAT, Low FLOAT, Med FLOAT, Acceleration FLOAT, Braking FLOAT, Cornering FLOAT,
		Total INT,
		New INT,
		ForReview INT,
		Archived INT,
		CoachingNotRequired INT,
		PositiveRecognition INT,
		Coached INT,
		EfficiencyColour NVARCHAR(MAX),
		SweetSpotColour NVARCHAR(MAX),
		OverRevWithFuelColour NVARCHAR(MAX),
		IdleColour NVARCHAR(MAX),
		SafetyColour NVARCHAR(MAX),
		OverSpeedColour NVARCHAR(MAX), 
		OverSpeedDistanceColour NVARCHAR(MAX),
		RopColour NVARCHAR(MAX),
		Rop2Colour NVARCHAR(MAX),
		ManoeuvresLowColour NVARCHAR(MAX),
		ManoeuvresMedColour NVARCHAR(MAX),
		AccelerationHighColour NVARCHAR(MAX),
		BrakingHighColour NVARCHAR(MAX),
		CorneringHighColour NVARCHAR(MAX),
		SafetyCoachingSessions INT NULL,
		EfficiencyCoachingSessions INT NULL
	)

	INSERT INTO @data
	        (PeriodNum,
			 Coaches,
			 Groups,
	         Drivers,
	         DistanceTravelled,
	         Efficiency,
	         SweetSpot,
	         OverRev,
	         Idle,
	         FuelEcon,
	         Safety,
	         OverSpeed,
	         Rop,
	         Rop2,
	         Low,
	         Med,
	         Acceleration,
	         Braking,
	         Cornering,
	         Total,
	         New,
	         ForReview,
	         Archived,
	         CoachingNotRequired,
	         PositiveRecognition,
	         Coached,
	         EfficiencyColour,
	         SweetSpotColour,
	         OverRevWithFuelColour,
	         IdleColour,
	         SafetyColour,
	         OverSpeedColour,
	         OverSpeedDistanceColour,
	         RopColour,
	         Rop2Colour,
	         ManoeuvresLowColour,
	         ManoeuvresMedColour,
	         AccelerationHighColour,
	         BrakingHighColour,
	         CorneringHighColour,
	         SafetyCoachingSessions,
	         EfficiencyCoachingSessions
	        )
	SELECT
			p.PeriodNum,
			--Group		
			p.Coaches,
			cg.Groups,
			Drivers,
 		
			TotalDrivingDistance,

 			-- Data columns with corresponding colours below 
			ROUND(Efficiency, 4) AS Efficiency, 
			ROUND(SweetSpot, 4) AS SweetSpot, 
			ROUND(OverRevWithFuel, 4) AS OverRev,  
			ROUND(Idle, 4) AS Idle, 
			ROUND(FuelEcon, 2) AS FuelEcon,
		
			ROUND(Safety, 4) AS Safety,
			ROUND(OverSpeedDistance, 4) AS OverSpeed,
			ROUND(Rop, 2) AS Rop, 
			ROUND(Rop2, 2) AS Rop2,
			ROUND(ManoeuvresLow, 2) AS Low,
			ROUND(ManoeuvresMed, 2) AS Med,
			ROUND(AccelerationHigh, 2) AS Acceleration, 
			ROUND(BrakingHigh, 2) AS Braking, 
			ROUND(CorneringHigh, 2) AS Cornering,
		
			 Total,
			 New,
			 ForReview,
			 p.Archived,
			 CoachingNotRequired,
			 PositiveRecognition,
			 Coached,

			---- Colour columns corresponding to data columns above
			dbo.GYRColourConfig(Efficiency, 14, @rprtcfgid) AS EfficiencyColour,
			dbo.GYRColourConfig(SweetSpot*100, 1, @rprtcfgid) AS SweetSpotColour,
			dbo.GYRColourConfig(OverRevWithFuel*100, 2, @rprtcfgid) AS OverRevWithFuelColour,
			dbo.GYRColourConfig(Idle*100, 6, @rprtcfgid) AS IdleColour,
		
			dbo.GYRColourConfig(Safety, 15, @rprtcfgid) AS SafetyColour,
			dbo.GYRColourConfig(OverSpeed*100, 10, @rprtcfgid) AS OverSpeedColour, 
			dbo.GYRColourConfig(OverSpeedDistance * 100, 21, @rprtcfgid) AS OverSpeedDistanceColour,
			dbo.GYRColourConfig(Rop, 9, @rprtcfgid) AS RopColour,
			dbo.GYRColourConfig(Rop2, 41, @rprtcfgid) AS Rop2Colour,
			dbo.GYRColourConfig(AccelerationLow + BrakingLow + CorneringLow, 39, @rprtcfgid) AS ManoeuvresLowColour,
			dbo.GYRColourConfig(Acceleration + Braking + Cornering, 40, @rprtcfgid) AS ManoeuvresMedColour,
			dbo.GYRColourConfig(AccelerationHigh, 36, @rprtcfgid) AS AccelerationHighColour,
			dbo.GYRColourConfig(BrakingHigh, 37, @rprtcfgid) AS BrakingHighColour,
			dbo.GYRColourConfig(CorneringHigh, 38, @rprtcfgid) AS CorneringHighColour,

			NULL AS SafetyCoachingSessions,
			NULL AS EfficiencyCoachingSessions
	FROM
		(
			SELECT *,
		
			Safety = dbo.ScoreByClassConfig('S', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, @rprtcfgid),
			Efficiency = dbo.ScoreByClassConfig('E', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, @rprtcfgid)
		
		FROM
			(SELECT
				CASE WHEN (GROUPING(p.PeriodNum) = 1) THEN NULL
					ELSE ISNULL(p.PeriodNum, NULL)
				END AS PeriodNum,

				CASE WHEN (GROUPING(c.Coaches) = 1) THEN NULL
					ELSE ISNULL(c.Coaches, NULL)
				END AS Coaches,

				COUNT(DISTINCT r.DriverIntId) AS Drivers,

				SUM(InSweetSpotDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0))) AS SweetSpot,
				SUM(FueledOverRPMDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0))) AS OverRevWithFuel,
				SUM(TopGearDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0))) AS TopGear,
				SUM(CruiseControlDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0))) AS Cruise,
				--Proof of concept. CruiseInTopGearsDistance should be used in production as soon as firmware is released.
				dbo.CAP(SUM(CruiseControlDistance) / dbo.ZeroYieldNull(SUM(TopGearDistance + ISNULL(GearDownDistance,0))), 1.0) AS CruiseInTopGears,
				--SUM(CruiseInTopGearsDistance) / dbo.ZeroYieldNull(SUM(TopGearDistance + ISNULL(GearDownDistance,0))) AS CruiseInTopGears,
				SUM(CoastInGearDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0))) AS CoastInGear,
				SUM(CruiseControlDistance) / dbo.ZeroYieldNull(SUM(TopGearDistance)) AS CruiseTopGearRatio,
				CAST(SUM(IdleTime) AS float) / dbo.ZeroYieldNull(SUM(TotalTime)) AS Idle,
				CAST(SUM(PTOMovingTime) + SUM(PTONonMovingTime) AS float) / dbo.ZeroYieldNull(SUM(TotalTime)) AS Pto,
				ISNULL((SUM(TotalFuel) * 2639.1 * @co2mult) / dbo.ZeroYieldNull(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0))),0) AS Co2, --@co2mult: 1 for g/km, 1.6 for g/miles
				SUM(TotalTime) AS TotalTime,
				SUM(ServiceBrakeDistance) / CASE WHEN SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) = 0 THEN NULL ELSE SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) END AS ServiceBrakeUsage,
				ISNULL(SUM(EngineBrakeDistance) / dbo.ZeroYieldNull(SUM(ServiceBrakeDistance + EngineBrakeDistance)),0) AS EngineServiceBrake,
				ISNULL(SUM(EngineBrakeOverRPMDistance) / dbo.ZeroYieldNull(SUM(EngineBrakeDistance)),0) AS OverRevWithoutFuel,
				ISNULL((SUM(ROPCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS Rop,
				ISNULL((SUM(ROP2Count) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS Rop2,
				ISNULL(SUM(ro.OverSpeedDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0))),0) AS OverSpeed,
				ISNULL(SUM(ro.OverSpeedHighDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0))),0) AS OverSpeedHigh,
				ISNULL(SUM(ro.OverSpeedDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0))),0) AS OverSpeedDistance, 
				ISNULL(SUM(r.OverSpeedDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0))),0) AS IVHOverSpeed,
				ISNULL(SUM(CoastOutOfGearDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0))),0) AS CoastOutOfGear,
				ISNULL((SUM(PanicStopCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS HarshBraking,
				SUM(DrivingDistance * 1000 * @distmult) AS TotalDrivingDistance,
				ISNULL((SUM(ORCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS OverRevCount,
			
				ISNULL((SUM(abc.Acceleration) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS Acceleration,
				ISNULL((SUM(abc.Braking) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS Braking,
				ISNULL((SUM(abc.Cornering) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS Cornering,

				ISNULL((SUM(abc.AccelerationLow) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS AccelerationLow,
				ISNULL((SUM(abc.BrakingLow) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS BrakingLow,
				ISNULL((SUM(abc.CorneringLow) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS CorneringLow,
		
				ISNULL((SUM(abc.AccelerationHigh) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS AccelerationHigh,
				ISNULL((SUM(abc.BrakingHigh) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS BrakingHigh,
				ISNULL((SUM(abc.CorneringHigh) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS CorneringHigh,

				ISNULL((SUM(abc.AccelerationLow + abc.BrakingLow + abc.CorneringLow) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS ManoeuvresLow,
				ISNULL((SUM(abc.Acceleration + abc.Braking + abc.Cornering) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * @distmult * 1000))))),0) AS ManoeuvresMed,

				(CASE WHEN @fuelmult = 0.1 THEN
					(CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel * ISNULL(NULL,1.0))*100 END)/SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) 
				ELSE
					(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * 1000) / (CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel * ISNULL(NULL,1.0)) END) * @fuelmult END) AS FuelEcon,

				ISNULL(SUM(id.Total),0) AS Total,
				ISNULL(SUM(id.New),0) AS New,
				ISNULL(SUM(id.ForReview),0) AS ForReview,
				ISNULL(SUM(id.Archived),0) AS Archived,
				ISNULL(SUM(id.NotRequired),0) AS CoachingNotRequired,
				ISNULL(SUM(id.PositiveRecognition),0) AS PositiveRecognition,
				ISNULL(SUM(id.Coached),0) AS Coached
			
			FROM dbo.Reporting r
				LEFT JOIN @IncidentData id ON id.Date = r.Date AND id.VehicleIntId = r.VehicleIntId AND id.DriverIntId = r.DriverIntId
				INNER JOIN dbo.Vehicle v ON v.VehicleIntId = r.VehicleIntId
				INNER JOIN @period_dates p ON r.Date BETWEEN p.StartDate AND p.EndDate
				INNER JOIN dbo.GroupDetail vgd ON v.VehicleId = vgd.EntityDataId
				INNER JOIN @coaches c ON c.GroupId = vgd.GroupId
				LEFT JOIN dbo.ReportingABC abc ON r.VehicleIntId = abc.VehicleIntId AND r.DriverIntId = abc.DriverIntId AND r.Date = abc.Date
				LEFT JOIN dbo.ReportingOverspeed ro ON r.VehicleIntId = ro.VehicleIntId AND r.DriverIntId = ro.DriverIntId AND r.Date = ro.Date

			WHERE r.Date BETWEEN @lsdate AND @ledate 
				AND r.DrivingDistance > 0
			GROUP BY p.PeriodNum, c.Coaches WITH CUBE
			HAVING SUM(DrivingDistance) > 10 
			) o
		) p
	INNER JOIN @coachgroups cg ON p.Coaches = cg.Coaches

	SELECT 
		dbo.TZ_GetTime(p.StartDate, DEFAULT, @luid) AS StartDate,
		dbo.TZ_GetTime(p.EndDate, DEFAULT, @luid) AS EndDate,
		d.Coaches,
		d.Groups,
		
		d.Safety ,
		d.Efficiency ,
		d.Coached,

		d.Total AS GrandTotal,
		(d.ForReview + d.Archived + d.CoachingNotRequired + d.PositiveRecognition + d.Coached) AS TotalPassedForCoaching,
		(d.ForReview + d.Archived + d.CoachingNotRequired + d.PositiveRecognition) AS NotCoached,

		IsSafetyBetter = CAST(CASE WHEN d.Safety > dprev.Safety THEN 1 
								WHEN d.Safety < dprev.Safety THEN 0
								ELSE NULL END AS BIT),
		IsEfficiencyBetter = CAST(CASE WHEN d.Efficiency > dprev.Efficiency THEN 1 
								WHEN d.Efficiency < dprev.Efficiency THEN 0
								ELSE NULL END AS BIT)
	FROM @data d
	INNER JOIN @data dprev ON dprev.Coaches = d.Coaches AND dprev.PeriodNum = 1
	INNER JOIN @period_dates p ON p.PeriodNum = d.PeriodNum
	WHERE d.DistanceTravelled > 10
	  AND d.PeriodNum = 2
	ORDER BY d.Safety DESC




GO
