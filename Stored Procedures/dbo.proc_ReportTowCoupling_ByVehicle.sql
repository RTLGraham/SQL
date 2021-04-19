SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportTowCoupling_ByVehicle]
( 
	@vids varchar(max),
	@sdate datetime,
	@edate datetime,
	@uid uniqueidentifier,
	@rprtcfgid uniqueidentifier
)
AS

	--DECLARE
	--	@vids varchar(max),
	--	@sdate datetime,
	--	@edate datetime,
	--	@uid uniqueidentifier,
	--	@rprtcfgid UNIQUEIDENTIFIER
        
	--SET @vids = N'D40234E5-CB66-4D7E-B5CC-D9CD6636FC3E,AD555052-53E9-4263-B9E9-75C0A2E171BE,652C8BA6-A548-46E6-BAAF-BDC08F74B603,AE2ACB3F-1ECE-4951-86D2-2F02ACDD19A3,A703021F-01AE-4A79-BE4D-872855AF90C9,4D94C75D-5BB2-43EF-BF23-1A6F2F66AD66,40E9D273-BFCF-4CFF-8FA8-C1E01ADE58B3,BF4B8D0D-B5E0-4471-A199-64BFFF83426F,23A93616-53F5-4DDE-BE22-1F8FA232B218,63736765-22A9-49B3-A0AF-44907D713FA3,CBBADEA1-ABC2-44DC-84F6-6A4D792B3B2F,6C3EA9D9-9CE8-42ED-9D23-82BCF8C959B7,8DF64B27-B621-4E7B-8477-E0165D640651,86DD7F25-530B-4B95-8026-41558B0873EF,EB006EDC-4C25-42D9-A296-C8C76AE1634E,B2ACE54E-25FA-438B-8B2E-33BE453E3DB8,ABC1ABFA-0956-4BF5-9FED-ABEC14D62C53,11A30BD0-7A60-4465-A324-B6CE764046BB,A9A9E5B8-ED0B-47A5-AADC-69FACFE98348,F15A9A5C-B7B4-42FD-BDDE-B24744A30931,54BCE489-1B40-4BC4-95D4-928229496B10,F87C9CCB-C46C-4E71-89D3-5289C4D99B17,14E8C378-938C-4C13-A041-1C4D7D0B83A2,DA83892B-AAB8-4B0B-984E-1B12ADE65A94,32076FD8-AC0E-419B-901E-BF1E5D094F24,838243A1-9F82-4967-B886-2ACF93831F4D,DD037D7D-B257-4A20-AA74-92B53E54413C,0D5665DC-1F6A-42F1-9FA0-2E1166C442AC,2C6E2650-4FD1-4AF4-9446-1403748CC6D0,6026012F-5C10-4124-B316-F637790515F7,F5A25F81-3E96-421D-9129-77ADD22B0F59,C9EBFAA4-D0E2-41AA-8C6A-0E294561143D,BC3A2C77-7E20-42C3-AFD7-EF6262D66148,1F867234-A5F7-4B21-A75F-7527BF30E2A0,97AC6BD1-75CB-4309-BD07-07A5A44C1834,C6FCBD41-1C25-4D11-8228-E8F8248AB8B7,C08BF57B-EAE8-4D7F-AF4E-BC2EEF2F07BC,92117A05-2E14-4982-8B95-377F80C07762,A375920B-C7A1-4DD9-99E9-6B15BD045C01,D514200B-54F1-418B-A9DF-75DCB59B8705,05EF49FE-0716-4BD7-B3CA-696EA2A180BD,8B03D8A5-0EC7-4266-B484-914F3740C578,88CD97A3-D074-4354-AF24-DA8D142C5E19,B9E39B4F-D607-40E5-A7DE-C47AB7D99F00,9451FEB1-616D-4468-B980-E36347A573DD,7EAA64B9-4A07-4414-A806-41A1BA94749D,181ACA7E-ED00-484F-8FAD-990A2AFF034C,8896DA9E-6D59-432C-95F4-523AEDFBA46E,BEB987D9-FDAB-4ABF-9A92-23E8CC10F59C,58CC1504-5B9B-4045-8ED2-9E06CE9FCAC6,6D61844F-C122-4A2D-B097-B5EEDC03354A,4D7F98AB-B0CF-4F4A-A4B3-BD90A078F5FC,9F93EACB-010E-456D-9D4F-ACA62F1382D0,E71FF558-9204-43CC-92E9-C3730F78E001,D93DE673-CF5E-44EC-B320-D23D978365C8,55574E13-DCE1-4A51-8EA1-114F70113020,D3C2D391-9A0F-4D47-9D68-701C19465D71,CDB16E40-5001-4AE5-8CCA-100C89CDFF85,1FF289C2-8FDD-4A24-9049-3250E89DE4B6,2089036E-C6D1-4251-9862-A10A486D3DA8,9BBAAAF0-DEEC-4BD3-B794-A9EE27DD963B,35CF9064-21F0-47EB-B14E-27ACA538DE06,4A2BD981-BD02-40C3-B66D-A6EBF551E822,AF4C9EB2-93EB-4C39-84AE-7F230B5F4511,C7BEB533-8001-448F-BDD0-706D63415854,4C0A5E13-9249-4A35-AA9A-D16603076DCE,6E538F0D-5D1C-423D-A5AA-AA572D317A6E,3B511B2C-8B02-4C44-8207-915126AC3ED0,FD57D03E-5381-45E0-9C8C-2A0981702859,117AE4D7-40B2-4813-9DF0-1E71A1B186BE,20DAC224-13A4-48C1-A075-45E101EE8FAC,96DDBAD7-CC43-4B52-8005-36B3BB94B276,073D9AF0-479C-4651-AB60-3868E23611FF,FD891FB8-2560-4FBA-8DE1-4B724ABCEC2D,06B11087-55DB-4BF4-B111-F4C6D76049EF,B8AFC8BF-0146-498B-BDB3-76DF82BCC59C,766151C6-7D7D-46A5-BD2B-115E0B565983,AFFF5DAB-CA73-4651-BCEB-EBE30DA501AE,96FFA8A4-C196-423D-9488-D67B2897FD76,BC1F639F-7F59-41F9-B2E4-195D2C13CAD8,44D67403-13B8-4C32-98BF-24D59DBC6783,580188F4-7D17-40F8-B98B-DD58F2EF2F70,F127352D-6CC5-4A02-9AA3-EE808A0F5031,D063771E-C94B-4466-8053-BCEB5DB48DCE,3C26C709-D620-4285-8A6D-1BF3333F607F,51FBEF08-0FCB-4108-862D-812A487FAA3A,B0F78261-851D-4DE2-B214-75FD9F1600FF,D1F21E8D-E371-4EA5-860C-0458E88909FC,98BB59FA-D272-4BB4-BB4C-8E1951D707A0,768AA025-6443-40F7-93D0-DF7679D92535,BC89A0D7-0FCA-4669-BDE0-9EF1DCA282CE,FB36A449-BB5E-424F-A500-159B27BF9087,05CFF8E6-8E8A-49DB-BAD6-C43924365076,D56A06DC-10A4-4B26-B04E-8B11C9EB0809,7BBAA5A3-4FF6-4696-BF4F-BB7D2F962F57,76C83ED3-07DF-403B-85B7-77F57CF71AB4,96A8B3DC-4E07-4964-B463-AF9FAE825A01,C408048A-8D52-439B-9C20-7132EDF51D0A'
	--SET @sdate = '2018-11-01 00:00'
	--SET @edate = '2018-11-30 23:59'
	--SET @uid = N'DFA7CC7F-92FC-4BA6-9A32-F37BB3FDDE2F'
	--SET	@rprtcfgid = N'9030713E-A0A5-440D-8D9B-464782D076C3'
	
	DECLARE	@lvids varchar(max),
			@lsdate datetime,
			@ledate datetime,
			@luid uniqueidentifier,
			@lrprtcfgid UNIQUEIDENTIFIER
		
	SET @lvids = @vids
	SET @lsdate = @sdate
	SET @ledate = @edate
	SET @luid = @uid
	SET @lrprtcfgid = @rprtcfgid

	DECLARE @diststr varchar(20),
			@distmult float,
			@fuelstr varchar(20),
			@fuelmult float,
			@co2str varchar(20),
			@co2mult float

	SELECT @diststr = [dbo].UserPref(@luid, 203)
	SELECT @distmult = [dbo].UserPref(@luid, 202)
	SELECT @fuelstr = [dbo].UserPref(@luid, 205)
	SELECT @fuelmult = [dbo].UserPref(@luid, 204)
	SELECT @co2str = [dbo].UserPref(@luid, 211)
	SELECT @co2mult = [dbo].UserPref(@luid, 210)

	SET @lsdate = [dbo].TZ_ToUTC(@lsdate,default,@luid)
	SET @ledate = [dbo].TZ_ToUTC(@ledate,default,@luid)

	DECLARE @tempReporting table(
		[VehicleIntId] [int] NULL,
		[DriverIntId] [int] NULL,
		[TowCoupling] CHAR(1) NULL,
		[InSweetSpotDistance] [float] NULL,
		[FueledOverRPMDistance] [float] NULL,
		[TopGearDistance] [float] NULL,
		[GearDownDistance] [float] NULL,
		[CruiseControlDistance] [float] NULL,
		[CruiseInTopGearsDistance] [float] NULL,
		[CoastInGearDistance] [float] NULL,
		[IdleTime] [int] NULL,
		[TotalTime] [int] NULL,
		[EngineBrakeDistance] [float] NULL,
		[ServiceBrakeDistance] [float] NULL,
		[EngineBrakeOverRPMDistance] [float] NULL,
		[ROPCount] [int] NULL,
		[ROP2Count] [INT] NULL,
		[OverSpeedDistance] [float] NULL,
		[CoastOutOfGearDistance] [float] NULL,
		[PanicStopCount] [int] NULL,
		[TotalFuel] [float] NULL,
		[TimeNoID] [float] NULL,
		[TimeID] [float] NULL,
		[DrivingDistance] [float] NULL,
		[PTOMovingDistance] [float] NULL,
		[Date] [smalldatetime] NOT NULL,
		[Rows] [int] NULL,
		[DrivingFuel] [float] NULL,
		[PTOMovingTime] [int] NULL,
		[PTOMovingFuel] [float] NULL,
		[PTONonMovingTime] [int] NULL,
		[PTONonMovingFuel] [float] NULL,
		[DigitalInput2Count] [int] NULL,
		[RouteID] [int] NULL,
		[ORCount] [int] NULL,
		[CruiseSpeedingDistance] [FLOAT] NULL,
		[OverSpeedThresholdDistance] [FLOAT] NULL,
		[TopGearSpeedingDistance] FLOAT NULL,
		[FuelWastage] FLOAT NULL	
	);



	INSERT INTO @tempReporting 
	(
		VehicleIntId, DriverIntId, TowCoupling, InSweetSpotDistance, FueledOverRPMDistance,
		TopGearDistance, GearDownDistance, CruiseControlDistance, CruiseInTopGearsDistance, CoastInGearDistance, IdleTime, TotalTime,
		EngineBrakeDistance, ServiceBrakeDistance, EngineBrakeOverRPMDistance, ROPCount, ROP2Count, OverSpeedDistance,
		CoastOutOfGearDistance, PanicStopCount, TotalFuel, TimeNoID, TimeID,
		DrivingDistance, PTOMovingDistance, Date, Rows, DrivingFuel,
		PTOMovingTime, PTOMovingFuel, PTONonMovingTime, PTONonMovingFuel,DigitalInput2Count,RouteID,ORCount,
		CruiseSpeedingDistance, OverSpeedThresholdDistance, TopGearSpeedingDistance, FuelWastage
	)

	SELECT aa.VehicleIntId, aa.DriverIntId,
		CASE WHEN dbo.TestBits(aa.StatusFlags, 4) = 1 THEN 'Y' ELSE 'N' END AS TowCoupling,
		SUM(ISNULL(InSweetSpotDistance, 0)) AS InSweetSpotDistance,
		SUM(ISNULL(FueledOverRPMDistance, 0)) AS FueledOverRPMDistance,
		SUM(ISNULL(TopGearDistance,0)) AS TopGearDistance,
		SUM(ISNULL(GearDownDistance,0)) AS GearDownDistance,
		SUM(ISNULL(CruiseControlDistance,0)) AS CruiseControlDistance,
		SUM(ISNULL(CruiseTopGearDistance,0) + ISNULL(CruiseGearDownDistance,0)) AS CruiseInTopGearsDistance,
		SUM(ISNULL(CoastInGearDistance,0)) AS CoastInGearDistance,
		SUM(ISNULL(IdleTime,0)) AS IdleTime,
		SUM(ISNULL(DrivingTime,0) + ISNULL(IdleTime,0) + ISNULL(ShortIdleTime,0) + ISNULL(aa.PTOMovingTime,0) + ISNULL(aa.PTONonMovingTime,0)) AS TotalTime,
		SUM(ISNULL(EngineBrakeDistance,0)) AS EngineBrakeDistance,
		SUM(ISNULL(ServiceBrakeDistance,0)) AS ServiceBrakeDistance,
		SUM(ISNULL(EngineBrakeOverRPMDistance,0)) AS EngineBrakeOverRPMDistance,
		SUM(ISNULL(DataLinkDownTime,0)) AS ROPCount,
		SUM(ISNULL(RSGTime,0)) AS ROP2Count,
		SUM(ISNULL(OverSpeedDistance,0)) AS OverSpeedDistance,
		SUM(ISNULL(CoastOutOfGearDistance,0)) AS CoastOutOfGearDistance,
		SUM(ISNULL(PanicStopCount,0)) AS PanicStopCount,
		SUM(ISNULL(DrivingFuel,0) + ISNULL(PTONonMovingFuel,0) + ISNULL(PTOMovingFuel,0) + ISNULL(IdleFuel,0) + ISNULL(ShortIdleFuel,0)) AS TotalFuel,
		SUM(	CASE WHEN Driver.Number = 'No ID' OR Driver.Surname = 'UNKNOWN' THEN 0
				ELSE CAST(ISNULL(DrivingTime,0) + ISNULL(PTOMovingTime,0) + ISNULL(PTONonMovingTime,0) + ISNULL(IdleTime,0) + ISNULL(ShortIdleTime,0) AS float) END) AS TimeNoID,
		SUM(CAST(ISNULL(DrivingTime,0) + ISNULL(PTOMovingTime,0) + ISNULL(PTONonMovingTime,0) + ISNULL(IdleTime,0) + ISNULL(ShortIdleTime,0) AS float)) AS TimeID,
		SUM(ISNULL(DrivingDistance,0)) AS DrivingDistance,
		SUM(ISNULL(PTOMovingDistance,0)) AS PTOMovingDistance,
		--CAST(YEAR(CreationDateTime) AS varchar(4)) + '-' + CAST(dbo.LeadingZero(MONTH(CreationDateTime),2) AS varchar(2)) + '-' + CAST(dbo.LeadingZero(DAY(CreationDateTime),2) AS varchar(2)) + ' 00:00:00.000' AS Date,
		CAST(FLOOR(CAST(aa.CreationDateTime AS FLOAT)) AS DATETIME) AS Date,
		COUNT(*) AS Rows,
		SUM(ISNULL(DrivingFuel,0)) AS DrivingFuel,
		SUM(ISNULL(PTOMovingTime,0)) AS PTOMovingTime,
		SUM(ISNULL(PTOMovingFuel,0)) AS PTOMovingFuel,
		SUM(ISNULL(PTONonMovingTime,0)) AS PTONonMovingTime,
		SUM(ISNULL(PTONonMovingFuel,0)) AS PTONonMovingFuel,
		SUM(ISNULL(DigitalInput2Count,0)) As DigitalInput2Count,
		RouteID,
		SUM(ISNULL(ORCount,0)) AS ORCount,
		SUM(ISNULL(CruiseSpeedingDistance,0)) AS CruiseSpeedingDistance,
		SUM(ISNULL(OverSpeedThresholdDistance,0)) AS OverSpeedThresholdDistance,
		SUM(ISNULL(TopGearSpeedingDistance,0)) AS TopGearSpeedingDistance,
		SUM(ISNULL(FueledOverRPMFuel,0) + ISNULL(IdleFuel,0) + ISNULL(ShortIdleFuel,0)) AS FuelWastage
		FROM dbo.Accum aa
			INNER JOIN dbo.Customer c ON c.CustomerIntId = aa.CustomerIntId
			INNER JOIN dbo.Vehicle v ON aa.VehicleIntId = v.VehicleIntId
			INNER JOIN dbo.IVH i ON v.IVHId = i.IVHId
			INNER JOIN dbo.Driver ON aa.DriverIntId = Driver.DriverIntId
		WHERE (v.IsCAN = 1 OR v.IsCAN IS NULL OR i.IVHTypeId = 6)
				AND ABS(DATEDIFF(HOUR, aa.CreationDateTime, aa.ClosureDateTime)) < 30
				AND aa.CreationDateTime BETWEEN @sdate AND @edate
				AND v.VehicleId IN (SELECT Value FROM dbo.Split(@lvids, ','))
		GROUP BY aa.CustomerIntId, aa.VehicleIntId, aa.DriverIntId, aa.RouteID, FLOOR(CAST(aa.CreationDateTime AS FLOAT)), dbo.TestBits(aa.StatusFlags, 4)		



	SELECT
			v.VehicleId,	
			d.DriverId,
			ISNULL(v.Registration,'') AS Registration,
 			ISNULL(dbo.FormatDriverNameByUser(d.DriverId, @luid),'') AS DriverName, -- included for backward compatibility
			TowCoupling,
			Efficiency, 
			TotalDrivingDistance,
			TotalTime,

			SweetSpot, 
			OverRevWithFuel, 
			TopGear, 
			CoastInGear, 
			Idle, 
			ISNULL(FuelEcon,'') AS FuelEcon,
			ISNULL(Co2,'') AS Co2, 
			dbo.GYRColourConfig(Efficiency, 14, @lrprtcfgid) AS EfficiencyColour
	FROM
		(SELECT *,

			Safety = dbo.ScoreByClassConfig('S', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, @lrprtcfgid),
			Efficiency = dbo.ScoreByClassConfig('E', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, @lrprtcfgid)
			

		FROM
			(SELECT
				CASE WHEN (GROUPING(v.VehicleId) = 1) THEN NULL
					ELSE ISNULL(v.VehicleId, NULL)
				END AS VehicleId,

				CASE WHEN (GROUPING(d.DriverId) = 1) THEN NULL
					ELSE ISNULL(d.DriverId, NULL)
				END AS DriverId,

				CASE WHEN (GROUPING(r.TowCoupling) = 1) THEN NULL
					ELSE ISNULL(r.TowCoupling, NULL)
				END AS TowCoupling,

				SUM(InSweetSpotDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0))) AS SweetSpot,
				SUM(FueledOverRPMDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0))) AS OverRevWithFuel,
				SUM(TopGearDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0))) AS TopGear,
				SUM(CruiseControlDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0))) AS Cruise,
				--Proof of concept. CruiseInTopGearsDistance should be used in production as soon as firmware is released.
				ISNULL(dbo.CAP(SUM(CruiseControlDistance) / dbo.ZeroYieldNull(SUM(TopGearDistance + ISNULL(GearDownDistance,0))), 1.0),0) AS CruiseInTopGears,
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

			FROM @tempReporting r
				INNER JOIN dbo.Vehicle v ON r.VehicleIntId = v.VehicleIntId
				INNER JOIN dbo.Driver d ON r.DriverIntId = d.DriverIntId
				LEFT JOIN dbo.ReportingABC abc ON r.VehicleIntId = abc.VehicleIntId AND r.DriverIntId = abc.DriverIntId AND r.Date = abc.Date --AND r.RouteID = abc.RouteId
				LEFT JOIN dbo.ReportingOverspeed ro ON r.VehicleIntId = ro.VehicleIntId AND r.DriverIntId = ro.DriverIntId AND r.Date = ro.Date --AND r.RouteID = ro.RouteId

			WHERE r.Date BETWEEN @lsdate AND @ledate 
			  AND (v.VehicleId IN (SELECT Value FROM dbo.Split(@lvids, ',')) OR @lvids IS NULL)
			  AND r.DrivingDistance > 0
			GROUP BY d.DriverId, v.VehicleId, r.TowCoupling WITH CUBE
			HAVING SUM(DrivingDistance) > 10 ) o
		) p

	LEFT JOIN dbo.Vehicle v ON p.VehicleId = v.VehicleId
	LEFT JOIN dbo.Driver d ON p.DriverId = d.DriverId

	WHERE TowCoupling IS NOT NULL	
		AND 
		(
			(v.VehicleId IS NULL AND d.DriverId IS NULL)
			OR
			(v.VehicleId IS NOT NULL AND d.DriverId IS NULL)
			OR
			(v.VehicleId IS NOT NULL AND d.DriverId IS NOT NULL)
		)


	ORDER BY Registration, Surname, TowCoupling DESC 


GO
