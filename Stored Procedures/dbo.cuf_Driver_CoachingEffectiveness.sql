SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Driver_CoachingEffectiveness]
(
	@uid UNIQUEIDENTIFIER,
	@gids VARCHAR(MAX),
	@sdate DATETIME,
	@edate datetime ,
	@drilldown TINYINT,
	@calendar TINYINT,
	@groupBy INT
)
AS
BEGIN

	--DECLARE @uid UNIQUEIDENTIFIER,
	--		@sdate DATETIME,
	--		@edate DATETIME,
	--		@gids NVARCHAR(MAX),
	--		@drilldown TINYINT,
	--		@calendar TINYINT,
	--		@groupBy INT

	--SELECT	@sdate = '2018-06-04 00:00',
	--		@edate = '2018-06-10 23:59',
	--		@uid = N'988d25de-65e9-4fc5-8981-3d2b4ea0feab',
	--		@gids = N'9F79C2F5-D8DE-40A4-812E-054A19412400,2091E18A-AF79-4489-9CBD-08460224B2BC,B521E92B-2244-40F2-B181-0CA88682DE0F,22251DD4-95E4-47B3-A0E7-1521A98B02A1,B5F21005-3428-4B35-9E5F-1A67C0D58367,0F0E441B-C760-49D5-ABC1-1AC0CF91FDE3,9D874687-26C5-4411-9024-206C4B4E3D48,A05EBCC1-3847-4E61-800C-2172CC363780,F0E7D8F1-4212-4C5C-B28E-27942890BD2E,EA33EEA1-309C-4C05-886D-2B70BBEE55AC,0DC4209A-E128-4258-AB66-3148056635CE,8EF32C73-FEC2-4000-B068-375AD0D169AB,08DC854C-52B7-4CD4-8903-3E74FCE4A017,A886DBB6-5F7B-4655-8CAD-4640B01DC036,E265FBF8-0396-4658-A41F-4AD61C95F1AB,188E9E76-CB7D-46F5-B3AA-4DF4E73179AE,EB84D30D-BB15-4D64-9385-4ED9C678ACA1,2DF9FF24-D1D4-470C-895F-5708F0D02927,7C1AF9C4-8319-44E4-82D1-5CE1C3756C4F,2DABE842-DD85-43F4-9C70-5E2C63621B55,1D7970F7-299F-47AB-A378-6F002DEBF73D,5B160160-CDEC-4CD2-B549-765B43CE99BA,14E57789-57C6-47BE-A7A2-7D1149A3964B,5532E83D-A49C-4683-B93B-8464EF17A32D,C81A6E9A-10CD-48C6-819E-882D60FD2FC0,6657E042-2FDB-44AB-A0B4-88D75F443BAA,837DE1D0-6A08-44C4-9CF0-89A1A0C5D576,C4F0C0B5-DD9A-4E94-A5F3-9303B8DEFD43,904E3803-1E00-4361-911C-9ADC91CB3D01,5706C20B-D848-4125-955C-9C5FB9AB1B57,F49D2FC0-B389-4324-8992-A0E45BE43900,66661596-E2E8-4817-8F52-A3D917156366,226E6C25-591E-44CE-B0D3-AA4719C2F62C,3194AFB9-6610-4EFD-8FCC-AABBFCF5CDBA,47E37F11-E799-4B4E-A5BC-AC202D654DC7,573D95FD-3417-4410-8A21-B6BA62B63283,77AB2F13-85E8-4D5B-92E8-BA934A9D8067,F2FFB2A4-0321-4224-A730-C13FA39409B0,972A4600-78F5-4CD8-A9A3-C38891EA9DDF,B012D898-30D0-458F-BD7D-CAC45D94F47F,91357D5E-F82B-48BE-A67C-D63E702B73AA,E39275E9-D056-4FA3-A518-D986FB62BB9C,38487B7E-59B4-4CED-80BA-ECB6BF8B1EBE,08DE223D-A291-4837-8017-EE4DBE2B4A00,F45FEAA0-E308-4233-A5F5-F2544EDE44AE,034C9B0E-380B-4297-BBE2-F56FA3673483,038BAA85-CA53-4D72-88F4-F5E351D209EB,3EC61BD4-CDDF-444C-8896-F61E451491B2',
	--		--@lgids = N'47E37F11-E799-4B4E-A5BC-AC202D654DC7'
	--		@drilldown = 1,
	--		@calendar = 0,
	--		@groupBy = 1

	DECLARE @luid UNIQUEIDENTIFIER,
			@lsdate DATETIME,
			@ledate DATETIME,
			@lgids NVARCHAR(MAX),
			@ldrilldown TINYINT,
			@lcalendar TINYINT,
			@lgroupBy INT

	SET @luid = @uid
	SET @lsdate = @sdate
	SET @ledate = @edate
	SET @lgids = @gids
	SET @ldrilldown = @drilldown
	SET @lcalendar = @calendar
	SET @lgroupby = @groupBy

	DECLARE @distmult FLOAT,
			@fuelmult FLOAT,
			@co2mult FLOAT,
			@rprtcfgid UNIQUEIDENTIFIER

	SET @rprtcfgid = N'DDA2FB34-1AB1-4ED7-A53E-BB974EDD2941'
	SET @distmult = Cast(dbo.[UserPref](@luid, 202) as float)
	SET @fuelmult = dbo.UserPref(@luid, 204)
	SET @co2mult = dbo.UserPref(@luid, 210)

	DECLARE @analysts NVARCHAR(MAX),
			@cid UNIQUEIDENTIFIER

	SELECT @cid = u.CustomerId
	FROM dbo.[User] u
	WHERE u.UserID = @luid

	SELECT @analysts = dbo.GetCustomerAnalystUserIds(@cid)

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
			FROM    dbo.CreateDependentDateRange(@lsdate, @ledate, @luid, @ldrilldown, @lcalendar, @lgroupBy)

	DECLARE @groups TABLE
    (
		GroupId UNIQUEIDENTIFIER,
		GroupName NVARCHAR(MAX)--,
		--Drivers INT
	)

	INSERT INTO @groups( GroupId, GroupName)
	SELECT	g.GroupId, 
			g.GroupName
	FROM dbo.[Group] g
		INNER JOIN dbo.GroupDetail gd ON gd.GroupId = g.GroupId
		INNER JOIN dbo.Driver d ON gd.EntityDataId = d.DriverId
	WHERE g.GroupId IN (SELECT Value FROM dbo.Split(@lgids, ','))
		AND g.IsParameter = 0 AND g.Archived = 0 AND g.GroupTypeId = 2 AND d.Archived = 0
	GROUP BY g.GroupId, g.GroupName
					
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
			SUM(CASE WHEN i.CoachingStatusId = 98 AND
				@analysts NOT LIKE '%' + CAST(u.UserID as NVARCHAR(MAX)) + '%'
				--u.Name NOT IN ('AAAdam','AAAdamCoach','AAAdamL','AirAdmin','AirAnalyst','APRTLAdmin','AirNick','AirSam','APRTLAdminCoach','AA') 
				THEN 1 ELSE 0 END),
			SUM(CASE WHEN i.CoachingStatusId = 99 THEN 1 ELSE 0 END)		
	FROM dbo.CAM_Incident i
			LEFT JOIN dbo.VideoCoachingHistory hist ON hist.IncidentId = i.IncidentId AND hist.CoachingStatusId = 98 
			LEFT JOIN dbo.[User] u ON hist.StatusUserId = u.UserID
			INNER JOIN dbo.Vehicle v ON v.VehicleIntId = i.VehicleIntId
			INNER JOIN dbo.Driver d ON d.DriverIntId = i.DriverIntId
			INNER JOIN dbo.GroupDetail gd ON gd.EntityDataId = d.DriverId
			INNER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId AND g.GroupTypeId = 2 
	WHERE i.EventDateTime BETWEEN @lsdate AND @ledate
		AND g.GroupId IN (SELECT GroupId FROM @groups)
		AND i.CreationCodeId IN (436, 437, 438, 455, 456)
	GROUP BY FLOOR(CAST(i.EventDateTime AS FLOAT)), i.VehicleIntId, i.DriverIntId

	DECLARE @data TABLE
	(
		PeriodNum TINYINT,
		PeriodStartDate DATETIME,
		PeriodEndDate DATETIME,
		PeriodType VARCHAR(MAX),
		Drivers INT,
		DistanceTravelled FLOAT,
		Efficiency FLOAT,
		SweetSpot FLOAT, OverRev FLOAT, Idle FLOAT, FuelEcon FLOAT,
		Safety FLOAT,
		OverSpeed FLOAT, Rop FLOAT, Rop2 FLOAT, Low FLOAT, Med FLOAT, Acceleration FLOAT, Braking FLOAT, Cornering FLOAT,
		Total INT,
		New INT,
		ForRevew INT,
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
		CorneringHighColour NVARCHAR(MAX)
	)

	INSERT INTO @data
			(PeriodNum ,
			 PeriodStartDate ,
			 PeriodEndDate ,
			 PeriodType ,
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
			 ForRevew,
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
			 CorneringHighColour
			)

	SELECT
			--Group		
			p.PeriodNum,
			p.StartDate,
			p.EndDate,
			p.PeriodType,
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
			 data.Archived,
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
			dbo.GYRColourConfig(CorneringHigh, 38, @rprtcfgid) AS CorneringHighColour
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
				INNER JOIN dbo.Driver d ON d.DriverIntId = r.DriverIntId
				INNER JOIN @period_dates p ON r.Date BETWEEN p.StartDate AND p.EndDate
				INNER JOIN dbo.GroupDetail dgd ON d.DriverId = dgd.EntityDataId
				INNER JOIN dbo.[Group] dg ON dgd.GroupId = dg.GroupId 
				LEFT JOIN dbo.ReportingABC abc ON r.VehicleIntId = abc.VehicleIntId AND r.DriverIntId = abc.DriverIntId AND r.Date = abc.Date
				LEFT JOIN dbo.ReportingOverspeed ro ON r.VehicleIntId = ro.VehicleIntId AND r.DriverIntId = ro.DriverIntId AND r.Date = ro.Date

			WHERE r.Date BETWEEN @lsdate AND @ledate 
				--AND r.DrivingDistance > 0
				AND dg.IsParameter = 0 
				AND dg.Archived = 0 
				AND dg.GroupId IN (SELECT GroupId FROM @groups)
			GROUP BY p.PeriodNum WITH CUBE
			--HAVING SUM(DrivingDistance) > 10 
			) o
		) data
	LEFT JOIN @period_dates p ON data.PeriodNum = p.PeriodNum 

	SELECT 
		--ISNULL(g.GroupName, ' Fleet') AS GroupName,
		d.PeriodNum,
		d.PeriodType,
		d.PeriodStartDate,
		d.PeriodEndDate,
		d.Drivers ,
		d.Efficiency ,
		d.Safety ,
		d.DistanceTravelled AS DistanceTravelledKM,
		ISNULL(d.DistanceTravelled * 1000.0 * @distmult, 0.0) AS DistanceTravelled,
		d.ForRevew,
		d.Archived,
		d.CoachingNotRequired,
		d.PositiveRecognition,
		d.Coached,
		(d.ForRevew + d.Archived + d.CoachingNotRequired + d.PositiveRecognition + d.Coached) AS Total,
		ISNULL(ROUND(d.ForRevew / dbo.ZeroYieldNull(d.DistanceTravelled * 1000.0 * @distmult) * 1000, 2), 0) AS ForRevewPer1000,
		ISNULL(ROUND(d.Archived / dbo.ZeroYieldNull(d.DistanceTravelled * 1000.0 * @distmult) * 1000, 2), 0) AS ArchivedPer1000,
		ISNULL(ROUND(d.CoachingNotRequired / dbo.ZeroYieldNull(d.DistanceTravelled * 1000.0 * @distmult) * 1000, 2), 0) AS CoachingNotRequiredPer1000,
		ISNULL(ROUND(d.PositiveRecognition / dbo.ZeroYieldNull(d.DistanceTravelled * 1000.0 * @distmult) * 1000, 2), 0) AS PositiveRecognitionPer1000,
		ISNULL(ROUND(d.Coached / dbo.ZeroYieldNull(d.DistanceTravelled * 1000.0 * @distmult) * 1000, 2), 0) AS CoachedPer1000,
		(
			ISNULL(ROUND(d.ForRevew / dbo.ZeroYieldNull(d.DistanceTravelled * 1000.0 * @distmult) * 1000, 2), 0) +
			ISNULL(ROUND(d.Archived / dbo.ZeroYieldNull(d.DistanceTravelled * 1000.0 * @distmult) * 1000, 2), 0) +
			ISNULL(ROUND(d.CoachingNotRequired / dbo.ZeroYieldNull(d.DistanceTravelled * 1000.0 * @distmult) * 1000, 2), 0) +
			ISNULL(ROUND(d.PositiveRecognition / dbo.ZeroYieldNull(d.DistanceTravelled * 1000.0 * @distmult) * 1000, 2), 0) +
			ISNULL(ROUND(d.Coached / dbo.ZeroYieldNull(d.DistanceTravelled * 1000.0 * @distmult) * 1000, 2), 0)
		) AS TotalPer1000
	FROM @data d
		--INNER JOIN @groups g ON g.GroupId = d.GroupId
	WHERE d.DistanceTravelled > 10 AND PeriodNum Is NOT NULL
	ORDER BY d.PeriodNum
	--ORDER BY (d.ForRevew + d.Archived + d.CoachingNotRequired + d.PositiveRecognition + d.Coached) DESC 
END
GO
