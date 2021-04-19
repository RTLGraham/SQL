SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_MonthlyCombinedAirProducts]
(
	@uid UNIQUEIDENTIFIER,
	@gids NVARCHAR(MAX),
	@sdate DATETIME,
	@edate DATETIME
)
AS

	
	--DECLARE @sdate DATETIME,
	--		@edate DATETIME,
	--		@uid UNIQUEIDENTIFIER,
	--		@gids NVARCHAR(MAX)

	--/*France*/
	--SELECT	@sdate = '2018-10-01 00:00',
	--		@edate = '2018-10-31 23:59',
	--		@uid = N'B4BFA82D-A74E-4B47-8D38-0026E02DFA33',
	--		@gids = N'19786F65-7E87-4157-969D-6C128B4E51E6'

	--/*UK*/
	--SELECT	@sdate = '2019-12-10 00:00',
	--		@edate = '2019-12-16 23:59',
	--		@uid = N'F5C3B62D-6D98-4ED6-87C8-DAC5DF947E5E',
	--		@gids = N'04742F8D-C10B-4E97-9D26-2D8A865D0B91'

	--/*Spain*/	
	--SELECT	@sdate = '2020-01-01 00:00',
	--		@edate = '2020-01-31 23:59',
	----SELECT	@sdate = '2020-01-16 00:00',
	----		@edate = '2020-01-16 23:59',
	--		@uid = N'1476B50A-6850-411B-90DD-514D4AB9FC85',
	--		@gids = N'E3362B8F-249E-449D-B455-2C229776D57E,405D5473-64D7-4F8D-AE26-2F2D980E3E70,FC4E63FD-6408-44CE-88FC-3723D17DB8AF,F9D4A87E-33E0-4C40-A702-39D460A528D1,AD39D580-2159-4018-8DBA-3F718DF6B0B6,5E3D5CF1-A38E-4D4F-A328-56732CD4E26B,605B14C6-D91E-4E45-8B8C-5B86C7316925,37340522-BB57-4EBB-9688-6CED09AF1332,2F2A5480-E031-49CB-BFE3-6D12C684373B,349E4F76-B736-4641-8394-822DA2C4FEFE,C83BAF15-AA3C-41DE-BD23-919A358D805C,F07BBCF4-6058-44FA-BC43-995693AC5BC6,7E694CFF-A13A-457E-9D13-BFF562A497D7,9FDFBA13-2072-45C6-AE7D-FA6CC555F875'

	DECLARE @rptConfig UNIQUEIDENTIFIER

	SELECT TOP 1 @rptConfig = Value
	FROM dbo.UserPreference 
	WHERE NameID = 801 AND UserID = @uid AND Archived = 0
	ORDER BY Value

	DECLARE @lsdate datetime,
			@ledate datetime,
			@luid UNIQUEIDENTIFIER,
			@lrprtcfgid UNIQUEIDENTIFIER,
			@lgids NVARCHAR(MAX)
		
	SET @lsdate = @sdate
	SET @ledate = @edate
	SET @luid = @uid
	SET @lrprtcfgid = @rptConfig
	SET @lgids = @gids

	DECLARE @diststr varchar(20),
			@distmult float,
			@fuelstr varchar(20),
			@fuelmult float,
			@co2str varchar(20),
			@co2mult FLOAT,
			@cName NVARCHAR(MAX),
			@timezone NVARCHAR(30)

	
	SET @timezone = dbo.[UserPref](@luid, 600)

	SELECT TOP 1 @cName = c.Name
	FROM dbo.[User] u
		INNER JOIN dbo.Customer c ON c.CustomerId = u.CustomerID
	WHERE u.UserID = @luid AND c.Archived = 0 
	ORDER BY c.LastOperation DESC


	SELECT @diststr = dbo.UserPref(@luid, 203)
	SELECT @distmult = dbo.UserPref(@luid, 202)
	SELECT @fuelstr = dbo.UserPref(@luid, 205)
	SELECT @fuelmult = dbo.UserPref(@luid, 204)
	SELECT @co2str = dbo.UserPref(@luid, 211)
	SELECT @co2mult = dbo.UserPref(@luid, 210)
	
	DECLARE @analysts NVARCHAR(MAX);
	
	SELECT @analysts = COALESCE(@analysts + ',', '') + u.Name
	FROM dbo.[User] u
		INNER JOIN dbo.Customer c ON c.CustomerId = u.CustomerID
		INNER JOIN dbo.UserPreference up ON up.UserID = u.UserID
		--INNER JOIN dbo.DictionaryName dn ON dn.NameID = up.NameID
	WHERE c.Name = @cName AND up.NameID = 1095 AND up.Value = 1

		DECLARE @groups TABLE
		(
			RowType NVARCHAR(MAX),
			ParentId UNIQUEIDENTIFIER,
			Region NVARCHAR(MAX),
			GroupId UNIQUEIDENTIFIER,
			GroupName NVARCHAR(max)
		)

		INSERT INTO @groups ( RowType, ParentId, Region, GroupId, GroupName )
		VALUES ('Fleet', NULL, NULL, '00000000-0000-0000-0000-000000000000', 'Fleet')
		INSERT INTO @groups ( RowType, ParentId, Region, GroupId, GroupName )
		VALUES ('Cost Centre', '00000000-0000-0000-0000-000000000000', 'Fleet', '00000000-0000-0000-0000-000000000001', 'North')
		INSERT INTO @groups ( RowType, ParentId, Region, GroupId, GroupName )
		VALUES ('Cost Centre', '00000000-0000-0000-0000-000000000000', 'Fleet', '00000000-0000-0000-0000-000000000002', 'Centre')
		INSERT INTO @groups ( RowType, ParentId, Region, GroupId, GroupName )
		VALUES ('Cost Centre', '00000000-0000-0000-0000-000000000000', 'Fleet', '00000000-0000-0000-0000-000000000003', 'South')
		INSERT INTO @groups ( RowType, ParentId, Region, GroupId, GroupName )
		VALUES ('Cost Centre', '00000000-0000-0000-0000-000000000000', 'Fleet', '00000000-0000-0000-0000-000000000004', 'Sales Centre')
		INSERT INTO @groups ( RowType, ParentId, Region, GroupId, GroupName )
		VALUES ('Cost Centre', '00000000-0000-0000-0000-000000000000', 'Fleet', '00000000-0000-0000-0000-000000000005', 'Cost Centre')
		
		--North
		INSERT INTO @groups ( RowType, ParentId, Region, GroupId, GroupName )
		SELECT DISTINCT 'Group', '00000000-0000-0000-0000-000000000001', 'North', g.GroupId, g.GroupName
		FROM dbo.[Group] g
			INNER JOIN dbo.GroupDetail gd ON gd.GroupId = g.GroupId
			INNER JOIN dbo.Vehicle v ON gd.EntityDataId = v.VehicleId
			INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
			INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
		WHERE g.IsParameter = 0 AND g.Archived = 0 AND g.GroupTypeId = 1
			AND c.Name = @cName
			AND g.GroupId IN (SELECT Value FROM dbo.Split(@lgids, ','))
			AND g.GroupName LIKE 'N %'
		GROUP BY g.GroupId, g.GroupName
		ORDER BY g.GroupName

		--South
		INSERT INTO @groups ( RowType, ParentId, Region, GroupId, GroupName )
		SELECT DISTINCT 'Group', '00000000-0000-0000-0000-000000000003', 'South', g.GroupId, g.GroupName
		FROM dbo.[Group] g
			INNER JOIN dbo.GroupDetail gd ON gd.GroupId = g.GroupId
			INNER JOIN dbo.Vehicle v ON gd.EntityDataId = v.VehicleId
			INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
			INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
		WHERE g.IsParameter = 0 AND g.Archived = 0 AND g.GroupTypeId = 1
			AND c.Name = @cName
			AND g.GroupId IN (SELECT Value FROM dbo.Split(@lgids, ','))
			AND g.GroupName LIKE 'S %'
		GROUP BY g.GroupId, g.GroupName
		ORDER BY g.GroupName


		
		--Sales Centre
		INSERT INTO @groups ( RowType, ParentId, Region, GroupId, GroupName )
		SELECT DISTINCT 'Group', '00000000-0000-0000-0000-000000000004', 'Sales Centre', g.GroupId, g.GroupName
		FROM dbo.[Group] g
			INNER JOIN dbo.GroupDetail gd ON gd.GroupId = g.GroupId
			INNER JOIN dbo.Vehicle v ON gd.EntityDataId = v.VehicleId
			INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
			INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
		WHERE g.IsParameter = 0 AND g.Archived = 0 AND g.GroupTypeId = 1
			AND c.Name = @cName
			AND g.GroupId IN (SELECT Value FROM dbo.Split(@lgids, ','))
			AND g.GroupName LIKE 'SC %'
		GROUP BY g.GroupId, g.GroupName
		ORDER BY g.GroupName

		--Centre
		INSERT INTO @groups ( RowType, ParentId, Region, GroupId, GroupName )
		SELECT DISTINCT 'Group', '00000000-0000-0000-0000-000000000002', 'Centre', g.GroupId, g.GroupName
		FROM dbo.[Group] g
			INNER JOIN dbo.GroupDetail gd ON gd.GroupId = g.GroupId
			INNER JOIN dbo.Vehicle v ON gd.EntityDataId = v.VehicleId
			INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
			INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
		WHERE g.IsParameter = 0 AND g.Archived = 0 AND g.GroupTypeId = 1
			AND c.Name = @cName
			AND g.GroupId IN (SELECT Value FROM dbo.Split(@lgids, ','))
			AND g.GroupName LIKE 'C %'
		GROUP BY g.GroupId, g.GroupName
		ORDER BY g.GroupName
		
		-- Cost Centre
		INSERT INTO @groups ( RowType, ParentId, Region, GroupId, GroupName )
		SELECT DISTINCT 'Group', '00000000-0000-0000-0000-000000000005', 'Cost Centre', g.GroupId, g.GroupName
		FROM dbo.[Group] g
			INNER JOIN dbo.GroupDetail gd ON gd.GroupId = g.GroupId
			INNER JOIN dbo.Vehicle v ON gd.EntityDataId = v.VehicleId
			INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
			INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
		WHERE g.IsParameter = 0 AND g.Archived = 0 AND g.GroupTypeId = 1
			AND c.Name = @cName
			AND g.GroupId IN (SELECT Value FROM dbo.Split(@lgids, ','))
			AND g.GroupId NOT IN (SELECT GroupId FROM @groups)
		GROUP BY g.GroupId, g.GroupName
		ORDER BY g.GroupName

		DECLARE @IncidentData TABLE
		(
			Date DATETIME,
			VehicleIntId INT,
			DriverIntId INT,
			UnfilteredTotal INT,
			Total INT,
			Archived INT,
			CoachingRequired INT,
			CoachingNotRequired INT,
			PositiveRecognition INT,
			Coached INT,
			New INT,
			ForReview INT,
			IsVideoPlayable INT
		)

		INSERT INTO @IncidentData (Date, VehicleIntId, DriverIntId, UnfilteredTotal, Total, Archived, CoachingRequired, CoachingNotRequired, PositiveRecognition, Coached, New, ForReview, IsVideoPlayable)
		SELECT o.Date,
               o.VehicleIntId,
               o.DriverIntId,
               COUNT(DISTINCT o.IncidentId),
               COUNT(DISTINCT o.IncidentId),
               SUM(o.Archived),
               SUM(o.CoachingRequired),
               SUM(o.CoachingNotRequired),
               SUM(o.PositiveRecognition),
               SUM(o.Coached),
               SUM(o.New),
               SUM(o.ForReview),
               1
		FROM 
		(
			SELECT DISTINCT	CAST(FLOOR(CAST(i.EventDateTime AS FLOAT)) AS DATETIME) AS Date, 
					i.VehicleIntId,
					i.DriverIntId,
					i.IncidentId,
					(CASE WHEN i.CoachingStatusId = 98 
							THEN CASE WHEN dbo.GetPreviousCoachingStatus(i.IncidentId, i.CoachingStatusId) IS NULL THEN 0 ELSE 1  END	
							ELSE 0 
						END) AS Archived,
					(CASE WHEN i.CoachingStatusId = 2 THEN 1 ELSE 0 END) AS CoachingRequired,
					(CASE WHEN i.CoachingStatusId = 3 THEN 1 ELSE 0 END) AS CoachingNotRequired,
					(CASE WHEN i.CoachingStatusId = 97 THEN 1 ELSE 0 END) AS PositiveRecognition,
					(CASE WHEN i.CoachingStatusId = 4 THEN 1 ELSE 0 END) AS Coached,
					(CASE WHEN i.CoachingStatusId = 0 THEN 1 ELSE 0 END) AS New,
					(CASE WHEN i.CoachingStatusId = 1 THEN 1 ELSE 0 END) AS ForReview,
					--below condition is needed to match the Video Tool
					(SELECT COUNT(DISTINCT v1.IncidentId) FROM dbo.CAM_Video v1 WHERE v1.IncidentId = i.IncidentId AND v1.CameraNumber = 1 AND v1.VideoStatus = 1) AS IsVideoPlayable
			FROM dbo.CAM_Incident i
				INNER JOIN dbo.Vehicle v ON v.VehicleIntId = i.VehicleIntId
				INNER JOIN dbo.GroupDetail gd ON gd.EntityDataId = v.VehicleId
				INNER JOIN @groups g ON g.GroupId = gd.GroupId AND g.RowType = 'Group'
				--below joins are required to ensure 1to1 match with the Video Tool
				INNER JOIN dbo.Driver d ON i.DriverIntId = d.DriverIntId
				INNER JOIN dbo.Customer cust ON i.CustomerIntId = cust.CustomerIntId
				INNER JOIN dbo.VehicleCamera vc ON v.VehicleId = vc.VehicleId
				INNER JOIN dbo.Camera c ON vc.CameraId = c.CameraId
				INNER JOIN dbo.Project p ON c.ProjectId = p.ProjectId
			WHERE i.EventDateTime BETWEEN @lsdate AND @ledate
				AND i.CreationCodeId IN (0, 55, 436, 437, 438, 456)
				--below conditions are required to ensure 1to1 match with Video Tool
				AND i.Archived = 0
				AND c.Archived = 0
				AND vc.Archived = 0
			GROUP BY FLOOR(CAST(i.EventDateTime AS FLOAT)), i.VehicleIntId, i.DriverIntId, i.IncidentId, i.CoachingStatusId
		) o
		WHERE o.IsVideoPlayable = 1
		GROUP BY o.Date, o.VehicleIntId, o.DriverIntId
		
		DECLARE @data TABLE
		(
			ParentId UNIQUEIDENTIFIER,
			GroupId UNIQUEIDENTIFIER,
			GroupName NVARCHAR(MAX),
			Vehicles INT,
			Drivers INT,
			DistanceTravelled FLOAT,
			Efficiency FLOAT,
			SweetSpot FLOAT, OverRev FLOAT, Idle FLOAT, FuelEcon FLOAT,
			Safety FLOAT,
			OverSpeed FLOAT, Rop FLOAT, Rop2 FLOAT, Low FLOAT, Med FLOAT, Acceleration FLOAT, Braking FLOAT, Cornering FLOAT,
			UnfilteredTotal INT,
			Total INT,
			New INT,
			ForReview INT,
			Archived INT,
			CoachingRequired INT,
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
			(ParentId,
			 GroupId,
			 GroupName,
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
			 UnfilteredTotal,
			 Total,
			 New,
			 ForReview,
			 Archived,
			 CoachingRequired,
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
			ParentId,
		
			g.GroupId,
			g.GroupName,
 		
			TotalDrivingDistance,

			Efficiency, 
			SweetSpot, 
			OverRevWithFuel,
			Idle, 
			FuelEcon,
		
			Safety,
			OverSpeed * 100.0 AS OverSpeedDistance,
			--OverSpeed AS OverSpeedDistance,
			Rop, 
			Rop2,
			ManoeuvresLow,
			ManoeuvresMed,
			AccelerationHigh, 
			BrakingHigh, 
			CorneringHigh,


			 UnfilteredTotal,
			 Total,
			 New,
			 ForReview,
			 p.Archived,
			 CoachingRequired,
			 CoachingNotRequired,
			 PositiveRecognition,
			 Coached,
		
			---- Colour columns corresponding to data columns above
			dbo.GYRColourConfig(Efficiency, 14, @lrprtcfgid) AS EfficiencyColour,
			dbo.GYRColourConfig(SweetSpot*100, 1, @lrprtcfgid) AS SweetSpotColour,
			dbo.GYRColourConfig(OverRevWithFuel*100, 2, @lrprtcfgid) AS OverRevWithFuelColour,
			dbo.GYRColourConfig(Idle*100, 6, @lrprtcfgid) AS IdleColour,
		
			dbo.GYRColourConfig(Safety, 15, @lrprtcfgid) AS SafetyColour,
			dbo.GYRColourConfig(OverSpeed*100, 10, @lrprtcfgid) AS OverSpeedColour, 
			dbo.GYRColourConfig(OverSpeedDistance * 100, 21, @lrprtcfgid) AS OverSpeedDistanceColour,
			dbo.GYRColourConfig(Rop, 9, @lrprtcfgid) AS RopColour,
			dbo.GYRColourConfig(Rop2, 41, @lrprtcfgid) AS Rop2Colour,
			dbo.GYRColourConfig(AccelerationLow + BrakingLow + CorneringLow, 39, @lrprtcfgid) AS ManoeuvresLowColour,
			dbo.GYRColourConfig(Acceleration + Braking + Cornering, 40, @lrprtcfgid) AS ManoeuvresMedColour,
			dbo.GYRColourConfig(AccelerationHigh, 36, @lrprtcfgid) AS AccelerationHighColour,
			dbo.GYRColourConfig(BrakingHigh, 37, @lrprtcfgid) AS BrakingHighColour,
			dbo.GYRColourConfig(CorneringHigh, 38, @lrprtcfgid) AS CorneringHighColour
	FROM
		(
			SELECT *,
		
			Safety = dbo.ScoreByClassConfig('S', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, @lrprtcfgid),
			Efficiency = dbo.ScoreByClassConfig('E', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, @lrprtcfgid)
		
		FROM
			(SELECT
				CASE WHEN (GROUPING(g.ParentId) = 1) THEN NULL
					ELSE ISNULL(g.ParentId, NULL)
				END AS ParentId,

				CASE WHEN (GROUPING(vg.GroupId) = 1) THEN NULL
					ELSE ISNULL(vg.GroupId, NULL)
				END AS GroupId,

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
					(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * 1000) / (CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel * ISNULL(FuelMultiplier,1.0)) END) * @fuelmult END) AS FuelEcon,

				ISNULL(SUM(i.UnfilteredTotal),0) AS UnfilteredTotal,
				ISNULL(SUM(i.Total),0) AS Total,
				ISNULL(SUM(i.Archived),0) AS Archived,
				ISNULL(SUM(i.CoachingRequired),0) AS CoachingRequired,
				ISNULL(SUM(i.CoachingNotRequired),0) AS CoachingNotRequired,
				ISNULL(SUM(i.PositiveRecognition),0) AS PositiveRecognition,
				ISNULL(SUM(i.Coached),0) AS Coached,
				ISNULL(SUM(i.New),0) AS New,
				ISNULL(SUM(i.ForReview),0) AS ForReview
			FROM [dbo].Reporting r
				LEFT JOIN @IncidentData i ON i.Date = r.Date AND i.VehicleIntId = r.VehicleIntId AND i.DriverIntId = r.DriverIntId
				INNER JOIN dbo.Vehicle v ON r.VehicleIntId = v.VehicleIntId
				INNER JOIN dbo.GroupDetail vgd ON v.VehicleId = vgd.EntityDataId
				INNER JOIN dbo.[Group] vg ON vgd.GroupId = vg.GroupId AND vg.GroupId IN (SELECT value FROM dbo.Split(@gids, ','))
				INNER JOIN dbo.Driver d ON d.DriverIntId = r.DriverIntId -- AND ISNULL(d.Number,'') != 'No ID'
				INNER JOIN @groups g ON g.GroupId = vg.GroupId
				LEFT JOIN dbo.ReportingABC abc ON r.VehicleIntId = abc.VehicleIntId AND r.DriverIntId = abc.DriverIntId AND r.Date = abc.Date 
				LEFT JOIN dbo.ReportingOverspeed ro ON r.VehicleIntId = ro.VehicleIntId AND r.DriverIntId = ro.DriverIntId AND r.Date = ro.Date 

			WHERE r.Date BETWEEN @lsdate AND @ledate 
				AND r.DrivingDistance > 0
				AND vg.IsParameter = 0 
				AND vg.Archived = 0 
			GROUP BY ParentId, vg.GroupId WITH CUBE
			HAVING SUM(DrivingDistance) > 10 ) o
		) p
	LEFT JOIN dbo.[Group] g ON p.GroupId = g.GroupId AND g.IsParameter = 0 AND g.Archived = 0
	WHERE (p.GroupId IS NOT NULL AND ParentId IS NOT NULL)
	   OR (ParentId IS NOT NULL AND p.GroupId IS NULL)
	   OR (ParentId IS NULL AND p.GroupId IS NULL)

	-- Set the Vehicle and Driver Counts (can't be done in the main select due to the HAVING clause working outside the CUBE
	UPDATE @data
	SET Drivers = DriverCount, Vehicles = VehicleCount
	FROM @data d 
	INNER JOIN	(
	SELECT DISTINCT ParentId, GroupId, COUNT(DISTINCT DriverId) AS DriverCount, COUNT(DISTINCT VehicleId) AS VehicleCount
	FROM	
	(
		SELECT 

			CASE WHEN (GROUPING(g.ParentId) = 1) THEN NULL
				ELSE ISNULL(g.ParentId, NULL)
			END AS ParentId,

			CASE WHEN (GROUPING(vg.GroupId) = 1) THEN NULL
				ELSE ISNULL(vg.GroupId, NULL)
			END AS GroupId,

			CASE WHEN (GROUPING(d.DriverId) = 1) THEN NULL
				ELSE ISNULL(d.DriverId, NULL)
			END AS DriverId,

			CASE WHEN (GROUPING(v.VehicleId) = 1) THEN NULL
				ELSE ISNULL(v.VehicleId, NULL)
			END AS VehicleId,

			SUM(r.DrivingDistance) AS Distance
				
		FROM [dbo].Reporting r
			INNER JOIN dbo.Vehicle v ON r.VehicleIntId = v.VehicleIntId
			INNER JOIN dbo.GroupDetail vgd ON v.VehicleId = vgd.EntityDataId
			INNER JOIN dbo.[Group] vg ON vgd.GroupId = vg.GroupId 
			INNER JOIN dbo.Driver d ON d.DriverIntId = r.DriverIntId -- AND ISNULL(d.Number,'') != 'No ID'
			INNER JOIN @groups g ON g.GroupId = vg.GroupId

		WHERE r.Date BETWEEN @lsdate AND @ledate 
			AND r.DrivingDistance > 0
			AND vg.IsParameter = 0 
			AND vg.Archived = 0 
			AND vg.GroupId IN (SELECT value FROM dbo.Split(@gids, ','))
		GROUP BY ParentId, vg.GroupId, d.DriverId, v.VehicleId WITH CUBE
		HAVING SUM(DrivingDistance) > 10 
	) x
	GROUP BY ParentId, GroupId) dc ON ISNULL(d.ParentId, N'00000000-0000-0000-0000-000000000000') = ISNULL(dc.ParentId, N'00000000-0000-0000-0000-000000000000') AND ISNULL(d.GroupId, N'00000000-0000-0000-0000-000000000000') = ISNULL(dc.GroupId, N'00000000-0000-0000-0000-000000000000')

	SELECT res.StartDate,
           res.EndDate,
           res.GroupId,
           res.ParentId,
           res.RowLevel,
           res.RowName,
           res.Vehicles,
           res.Drivers,
           res.DistanceTravelled,
           res.Efficiency,
           res.EfficiencyColour,
           res.SweetSpot,
           res.OverRev,
           res.Idle,
           res.FuelEcon,
           res.Safety,
           res.SafetyColour,
           res.OverSpeed,
           res.Rop,
           res.Rop2,
           res.Low,
           res.Med,
           res.Acceleration,
           res.Braking,
           res.Cornering,
           res.RopCount,
           res.Rop2Count,
           res.LowCount,
           res.MedCount,
           res.AccelerationCount,
           res.BrakingCount,
           res.CorneringCount,
           res.GrandTotal,
           res.ForRevew,
           res.Archived,
           res.CoachingRequired,
           res.CoachingNotRequired,
           res.PositiveRecognition,
           res.Coached,
           res.Total
		   ,
           res.ForRevewPer1000,
           res.ArchivedPer1000,
           res.CoachingRequiredPer1000,
           res.CoachingNotRequiredPer1000,
           res.PositiveRecognitionPer1000,
           res.CoachedPer1000,
           res.TotalPer1000,
           res.PerDriver	
	FROM 
	(
		SELECT 
			dbo.TZ_GetTime(@lsdate, @timezone, @luid) AS StartDate,
			dbo.TZ_GetTime(@ledate, @timezone, @luid) AS EndDate,
			d.GroupId AS GroupId,
			g.GroupId AS ParentId,
			CASE WHEN d.ParentId IS NULL AND d.GroupId IS NULL THEN 1
				 WHEN d.ParentId IS NOT NULL AND d.GroupId IS NULL THEN 2
				 WHEN d.ParentId IS NOT NULL AND d.GroupId IS NOT NULL THEN 3
			END AS RowLevel,
			ISNULL(CASE WHEN d.GroupName IS NULL THEN g.GroupName ELSE d.GroupName END, 'Fleet') AS RowName,
			d.Vehicles ,
			d.Drivers ,
			d.DistanceTravelled,

			ROUND(Efficiency, 4) AS Efficiency,
			EfficiencyColour,
			ROUND(SweetSpot, 4) AS SweetSpot,
			ROUND(OverRev, 4) AS OverRev,
			ROUND(Idle, 4) AS Idle,
			ROUND(d.FuelEcon, 2) AS FuelEcon,
			ROUND(d.Safety, 4) AS Safety,
			SafetyColour,
			ROUND(OverSpeed, 4) AS OverSpeed,
			ROUND(Rop, 2) AS Rop,
			ROUND(Rop2, 2) AS Rop2,
			ROUND(Low, 2) AS Low,
			ROUND(Med, 2) AS Med,
			ROUND(Acceleration, 2) AS Acceleration,
			ROUND(Braking, 2) AS Braking,
			ROUND(Cornering, 2) AS Cornering,

			ROUND(Rop * DistanceTravelled / 1000.0, 0) AS RopCount,
			ROUND(Rop2 * DistanceTravelled / 1000.0, 0) AS Rop2Count,
			ROUND(Low * DistanceTravelled / 1000.0, 0) AS LowCount,
			ROUND(Med * DistanceTravelled / 1000.0, 0) AS MedCount,
			ROUND(Acceleration * DistanceTravelled / 1000.0, 0) AS AccelerationCount,
			ROUND(Braking * DistanceTravelled / 1000.0, 0) AS BrakingCount,
			ROUND(Cornering * DistanceTravelled / 1000.0, 0) AS CorneringCount,

			d.Total AS GrandTotal,
			d.ForReview AS ForRevew,
			d.Archived,
			d.CoachingRequired,
			d.CoachingNotRequired,
			d.PositiveRecognition,
			d.Coached,
			(d.ForReview + d.Archived + d.CoachingRequired + d.CoachingNotRequired + d.PositiveRecognition + d.Coached) AS Total,
			ISNULL(ROUND(d.ForReview / dbo.ZeroYieldNull(d.DistanceTravelled) * 1000, 2), 0) AS ForRevewPer1000,
			ISNULL(ROUND(d.Archived / dbo.ZeroYieldNull(d.DistanceTravelled) * 1000, 2), 0) AS ArchivedPer1000,
			ISNULL(ROUND(d.CoachingRequired / dbo.ZeroYieldNull(d.DistanceTravelled) * 1000, 2), 0) AS CoachingRequiredPer1000,
			ISNULL(ROUND(d.CoachingNotRequired / dbo.ZeroYieldNull(d.DistanceTravelled) * 1000, 2), 0) AS CoachingNotRequiredPer1000,
			ISNULL(ROUND(d.PositiveRecognition / dbo.ZeroYieldNull(d.DistanceTravelled) * 1000, 2), 0) AS PositiveRecognitionPer1000,
			ISNULL(ROUND(d.Coached / dbo.ZeroYieldNull(d.DistanceTravelled) * 1000, 2), 0) AS CoachedPer1000,
			(
				ISNULL(ROUND(d.ForReview / dbo.ZeroYieldNull(d.DistanceTravelled) * 1000, 2), 0) +
				ISNULL(ROUND(d.Archived / dbo.ZeroYieldNull(d.DistanceTravelled) * 1000, 2), 0) +
				ISNULL(ROUND(d.CoachingNotRequired / dbo.ZeroYieldNull(d.DistanceTravelled) * 1000, 2), 0) +
				ISNULL(ROUND(d.PositiveRecognition / dbo.ZeroYieldNull(d.DistanceTravelled) * 1000, 2), 0) +
				ISNULL(ROUND(d.Coached / dbo.ZeroYieldNull(d.DistanceTravelled) * 1000, 2), 0)
			) AS TotalPer1000,
			(d.ForReview + d.Archived + d.CoachingRequired + d.CoachingNotRequired + d.PositiveRecognition + d.Coached) / dbo.ZeroYieldNull(d.Drivers) AS PerDriver
		FROM @data d
		LEFT JOIN @groups g ON g.GroupId = d.ParentId
		WHERE d.DistanceTravelled > 10
	) res
	WHERE res.RowLevel IN (1,2) OR res.GroupId IN (SELECT Value FROM dbo.Split(@lgids, ','))
	ORDER BY res.ParentId, res.RowLevel, res.RowName

GO
