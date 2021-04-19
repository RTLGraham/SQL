SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_AirProductsSafety_GroupsDriver]
(
	@gids NVARCHAR(MAX),
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER
)
AS

	--DECLARE	@gids NVARCHAR(MAX),
	--		@sdate datetime,
	--		@edate datetime,
	--		@uid uniqueidentifier,
	--		@rprtcfgid UNIQUEIDENTIFIER,
	--		@vIdsToExclude NVARCHAR(MAX)

	--SET @sdate = '2016-04-01 00:00'
	--SET @edate = '2016-04-30 23:59'
	--SET @uid = N'988d25de-65e9-4fc5-8981-3d2b4ea0feab'
	--SET	@rprtcfgid = N'dda2fb34-1ab1-4ed7-a53e-bb974edd2941'
	--SET @gids = N'2CF07E80-0FAB-429A-AAF3-06C1032ACC27,12E872AD-ED42-4E4D-9C2A-09095963D3B2,5BCBF691-2994-436F-9D59-317F3354ADCF,1A399E9E-E88B-451A-BA15-90ECF774844A,AD79F78C-DAFD-4AC8-86DA-990B35B33C31,E125A4ED-21AB-48A9-A4A0-D8766537085C'
	--SET @vIdsToExclude = N'C518E682-B62F-447B-B223-DC204ED0B2C3,9D784848-44B7-420C-B200-1D10411A69F4,A12B02B7-E03C-47A3-8988-094140140FB1,CC2D082E-AC60-454A-A32C-99867A2442B7,CADC2E25-3D66-47CA-8FC1-5A6D09000BDD,68A1DE48-E0B7-49DE-8068-4311A2A3DE02,233FB4D0-D8BE-4F20-8A5A-CBAB5339C51C,9E21389B-8FDF-4EA6-91F8-83B637005793,9E9A5800-5C0A-4FA0-AE0C-CB7DA4EE242D,35CB3B69-245B-427D-A466-8336E43888A2,49939D7B-5138-4F07-A447-5242724C3124,A3196E35-7E77-4F6F-B685-09AA5B8AD6B0,C598BABC-E893-4204-BB97-A28B4E269597,5DB34E58-8735-434D-BE06-C89C4C752503'
	


	DECLARE @lsdate datetime,
			@ledate datetime,
			@luid UNIQUEIDENTIFIER,
			@lrprtcfgid UNIQUEIDENTIFIER
		
	SET @lsdate = @sdate
	SET @ledate = @edate
	SET @luid = @uid
	SET @lrprtcfgid = @rprtcfgid

	DECLARE @diststr varchar(20),
			@distmult float,
			@fuelstr varchar(20),
			@fuelmult float,
			@co2str varchar(20),
			@co2mult FLOAT


	SELECT @diststr = dbo.UserPref(@luid, 203)
	SELECT @distmult = dbo.UserPref(@luid, 202)
	SELECT @fuelstr = dbo.UserPref(@luid, 205)
	SELECT @fuelmult = dbo.UserPref(@luid, 204)
	SELECT @co2str = dbo.UserPref(@luid, 211)
	SELECT @co2mult = dbo.UserPref(@luid, 210)

	--SET @lsdate = dbo.TZ_ToUTC(@lsdate,default,@luid)
	--SET @ledate = dbo.TZ_ToUTC(@ledate,default,@luid)

	SELECT
			--Group
		
			@gids AS GroupIds,
 		
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
			ROUND(CorneringHigh, 2) AS Cornering

			,@lsdate AS sdate,
			@ledate AS edate
	FROM
		(
			SELECT *,
		
			Safety = dbo.ScoreByClassConfig('S', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, @lrprtcfgid),
			Efficiency = dbo.ScoreByClassConfig('E', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, @lrprtcfgid)
		

		FROM
			(SELECT
				CASE WHEN (GROUPING(vg.GroupId) = 1) THEN NULL
					ELSE ISNULL(vg.GroupId, NULL)
				END AS GroupId,
			
				--CASE WHEN (GROUPING(v.VehicleId) = 1) THEN NULL
				--	ELSE ISNULL(v.VehicleId, NULL)
				--END AS VehicleId,

				--CASE WHEN (GROUPING(d.DriverId) = 1) THEN NULL
				--	ELSE ISNULL(d.DriverId, NULL)
				--END AS DriverId,

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
					(CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel * ISNULL(FuelMultiplier,1.0))*100 END)/SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) 
				ELSE
					(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * 1000) / (CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel * ISNULL(FuelMultiplier,1.0)) END) * @fuelmult END) AS FuelEcon
				
			FROM [dbo].Reporting r
				INNER JOIN dbo.Vehicle v ON r.VehicleIntId = v.VehicleIntId
				INNER JOIN dbo.GroupDetail vgd ON v.VehicleId = vgd.EntityDataId
				INNER JOIN dbo.[Group] vg ON vgd.GroupId = vg.GroupId 
				LEFT JOIN dbo.ReportingABC abc ON r.VehicleIntId = abc.VehicleIntId AND r.DriverIntId = abc.DriverIntId AND r.Date = abc.Date --AND r.RouteID = abc.RouteId
				LEFT JOIN dbo.ReportingOverspeed ro ON r.VehicleIntId = ro.VehicleIntId AND r.DriverIntId = ro.DriverIntId AND r.Date = ro.Date --AND r.RouteID = ro.RouteId

			WHERE r.Date BETWEEN @lsdate AND @ledate 
				AND r.DrivingDistance > 0
				AND vg.IsParameter = 0 
				AND vg.Archived = 0 
				AND vg.GroupId IN (SELECT Value FROM dbo.Split(@gids, ','))
			GROUP BY vg.GroupId WITH CUBE
			HAVING SUM(DrivingDistance) > 10 ) o
		) p
	LEFT JOIN dbo.[Group] g ON p.GroupId = g.GroupId AND g.IsParameter = 0 AND g.Archived = 0
	WHERE p.GroupId IS NULL

GO
