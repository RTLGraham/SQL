SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportTowCoupling_ByDriver]
( 
	@dids varchar(max),
	@sdate datetime,
	@edate datetime,
	@uid uniqueidentifier,
	@rprtcfgid uniqueidentifier
)
AS

	--DECLARE
	--	@dids varchar(max),
	--	@sdate datetime,
	--	@edate datetime,
	--	@uid uniqueidentifier,
	--	@rprtcfgid UNIQUEIDENTIFIER
        
	--SET @dids = N'6E4718E1-F32B-43C0-9B20-FEC0BF631FF4,6CE79774-8713-4A05-88E2-F35A379352F3,813B1518-110E-4AE4-80DE-C7587B89D85F,9551FF09-C65C-4187-96C5-D12438A244B1,F0C5E97C-9740-4909-A2C0-19400A0350F4,8347BF48-6472-485B-BB32-F375C73049FB,1C1EF054-7304-4442-BBE3-1F5727C34322,7B77132E-83C5-45CF-A706-28A36F6D95D9,D9597F0E-DB3F-49A8-ABB7-E5C98DA60C74,577AA473-22D3-4576-BF5A-FAD2ABFA990B,5A8E4616-1BF0-4F7C-952F-32662F9AC50A,1C3CDC7C-8D82-4F24-9D2E-F6873B7B9C9C,D1844154-5A99-4798-81ED-C6B825664A26,E284786C-AE6D-4111-897D-29808E8DF92E,4421B62C-BA04-4B18-891E-4F5E778D4089,FD55E2F0-BB29-4FDE-92DF-B51B1AB06703,C8B1BD19-2AFA-4D9D-BD42-BBA4093CF975,AF62743F-C5F5-4BE9-AB14-859192B97FCE,057F7A23-44F5-4A4D-BE97-C1C13623B329,139D5EDC-1F24-4232-8E34-4E4A49B80445,FCB12EC8-784D-48EE-BE91-FE276902B8C7,02913AE8-6415-4854-B9B6-6FB7DAAF1E5D,D8A160F9-0434-45C2-B9EB-D350FCA2B57D,2ED261BC-F123-4FA7-8896-8194C4E5CD06,106ABC13-7274-4F74-A4E1-3BE0F45B4480,7729F6F8-E3B3-4378-89E2-698B2A51E250,54D8EC42-582F-4379-A416-6DB925E808A4,8672B33F-B3A6-497A-A050-C8D447FEB1B7,82718DC9-0B78-451F-BA97-14366A3CCEA8,CDFF9A4E-B00B-4CFA-A384-459A0D8B68FD,FC30AA83-209F-4BC4-8568-C689C6CA4F90,4463C6B0-338A-4138-AD2E-116E1419FA9A,E45EEC1B-A8C5-4B99-91A7-8F982E9ED13A,AD17A41F-CFB4-4BD1-88E2-A2CBAE0164E8,577DB62D-EFA0-4825-9489-C932AC17975A,3119D3C5-2186-461B-996A-15E88530E882,8AD0861D-0C18-4798-9732-F830E3601AC3,E88B3868-B7EC-4DAC-B616-150702502F78,9A713D39-F93C-46C0-9AD8-E32A79B107BF,B0410427-0866-4C33-80BD-EF1578BF5517,C9E32A84-C346-4C59-9BD0-C9329357650A,6B7CAF91-352B-4235-B6D0-173558537693,25DDB100-692F-4F73-A1E9-FA3D1E2DF12E,A415627C-9888-48BD-B704-5139E575A399,91644AC1-F94B-4260-92D7-9F256EB86C93,D512F51D-4EB2-4E53-B973-4A43210D9AD1,46EFC06F-DA42-442F-BDFC-8C33CFE0C4F5,78594791-BB59-42EB-87AC-AB9CE56D265D,E9CE1CE4-B75C-4049-AD4B-4A24B266641F,C2A393DE-9BA4-4D97-90AD-A943D5469187,2F45F1EB-DA7A-4335-AAAD-88572355A9F8,F869F2C0-8318-4CC9-B138-22394D475392,46A61038-1F93-4EAB-A520-75C3873591E1,4A53C771-72D2-454E-981A-C62C7E7CAE51,B7FC587D-E1E7-4D35-AE60-C1AFCC8E0EC0,CFADCEE7-EDEB-4596-B6B8-CF05E0160E59,B848799B-036E-4DAE-AC01-1EB05AADA5A1,45CFD753-37C9-439E-8C35-13BF0A237588,EBAABBC5-E0F1-4351-909A-3DFB0EBAC852,132B23A2-87AD-401A-B57D-3D182E2B357C,BEF4BD94-E970-492C-A440-A199E467050D,7774B1BD-445E-4652-B17D-68ED8D939EA3,66D84087-CAAA-42E2-9FB6-12632256C654,4D120863-87CB-4475-B5F2-A8137576D75A,7DCDEC1A-BC3F-41D0-B8D6-33D1A2186F05,A65B33C6-30FE-42D8-BA77-2476BAB8F6F2,3A921725-A639-4E9F-A92B-39BD8BDDD9F4,D0FD2F93-4DF2-49DD-9710-1D2BDA4BDE0C,6266FE2D-B273-444C-B876-263FFB332E5C,A5889B03-72E5-4588-BD38-FDCACB86DE0E,84F26D10-E500-46AD-89B9-02C229E1B3E1,D00171ED-A4F1-49BE-9C3C-0F167108DB94,842D510F-7B68-414E-A4E1-5E1861D9E2C0,094C7465-9D77-462B-A9FE-772BCB88D22A,FE9EB2A1-8A8E-49D4-AD64-E473F66F3B59,8969A544-06EF-4155-B642-6CC05C7403A6,E1FE1EB0-5642-4C43-AA04-DF562FDE8C26,F24E95C3-A803-40A0-8C45-F28AF9BD4B68,BD3C744E-6107-4E62-844C-C9F0B86AB6AF,DA954C77-73D9-45B0-8DE5-FC83284B577B,E8C18D46-76F3-49CF-81FC-C1454DDCADBA,FBA0E9B8-27D6-4444-80A3-51EB7F8475CC,A9551E48-6064-4515-BDDF-A1A797D79967,000E331B-70EE-4044-9CC3-F26988A6A283'
	--SET @sdate = '2018-11-01 00:00'
	--SET @edate = '2018-11-30 23:59'
	--SET @uid = N'DFA7CC7F-92FC-4BA6-9A32-F37BB3FDDE2F'
	--SET	@rprtcfgid = N'9030713E-A0A5-440D-8D9B-464782D076C3'
		
	DECLARE	@ldids varchar(max),
			@lsdate datetime,
			@ledate datetime,
			@luid uniqueidentifier,
			@lrprtcfgid UNIQUEIDENTIFIER
		
	SET @ldids = @dids
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
				AND Driver.DriverId IN (SELECT Value FROM dbo.Split(@ldids, ','))
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
			  AND (d.DriverId IN (SELECT Value FROM dbo.Split(@ldids, ',')) OR @ldids IS NULL)
			  AND r.DrivingDistance > 0
			GROUP BY d.DriverId, v.VehicleId, r.TowCoupling WITH CUBE
			HAVING SUM(DrivingDistance) > 10 ) o
		) p

	LEFT JOIN dbo.Vehicle v ON p.VehicleId = v.VehicleId
	LEFT JOIN dbo.Driver d ON p.DriverId = d.DriverId

	WHERE TowCoupling IS NOT NULL	
		AND 
		(
			(d.DriverId IS NULL AND v.VehicleId IS NULL)
			OR
			(d.DriverId IS NOT NULL AND v.VehicleId IS NULL)
			OR
			(d.DriverId IS NOT NULL AND v.VehicleId IS NOT NULL)
		)


	ORDER BY Surname, Registration, TowCoupling DESC 

GO
