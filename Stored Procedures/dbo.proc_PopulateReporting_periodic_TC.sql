SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_PopulateReporting_periodic_TC]
AS	
BEGIN

	DECLARE	@vids varchar(max),
			@dids VARCHAR(MAX),
			@sdate datetime,
			@edate datetime,
			@uid uniqueidentifier,
			@rprtcfgid uniqueidentifier

	SET @vids = N'5DC6B74D-4787-42A6-B193-00C0FBB80C7F,908DA9E8-55B8-4D98-82C8-00C7B84A6ABA,A8B2AD32-6182-4221-B57F-00F841553240,0BED4DC9-D4B4-4E6E-B241-0193690FFB6C,D1F21E8D-E371-4EA5-860C-0458E88909FC,AF15ED87-A0F3-4B0F-827A-0508A8EBB7C5,037ACA79-8997-4975-817B-0929306A1733,FE4007D1-AA86-4AF7-8213-0EEF3C210257,B00193AC-2997-45E4-BF50-0F041A45CA9E,2501E6CB-A07E-4494-8B1D-1123630A9010,766151C6-7D7D-46A5-BD2B-115E0B565983,2C6E2650-4FD1-4AF4-9446-1403748CC6D0,FB36A449-BB5E-424F-A500-159B27BF9087,BC1F639F-7F59-41F9-B2E4-195D2C13CAD8,4D94C75D-5BB2-43EF-BF23-1A6F2F66AD66,DA83892B-AAB8-4B0B-984E-1B12ADE65A94,3C26C709-D620-4285-8A6D-1BF3333F607F,2DCF09F4-AD6F-4E93-89D3-1CAF06B2A8CF,F39E3878-8160-4F3D-98EE-1DEA64F9CB05,117AE4D7-40B2-4813-9DF0-1E71A1B186BE,23A93616-53F5-4DDE-BE22-1F8FA232B218,47D132AF-B000-49B9-B99F-21648FF3AECD,EE4C082D-EAE8-42CB-A238-2308F5647762,87509C21-E559-453F-95FB-243B0DA7EE34,84B6C152-5BBD-438A-AA86-24BF73BA57BE,44D67403-13B8-4C32-98BF-24D59DBC6783,69690527-3EEC-409F-BC31-2749997062F7,FD57D03E-5381-45E0-9C8C-2A0981702859,838243A1-9F82-4967-B886-2ACF93831F4D,A66AE7F8-0564-444B-A73B-2CB2C678FF77,0D5665DC-1F6A-42F1-9FA0-2E1166C442AC,AE2ACB3F-1ECE-4951-86D2-2F02ACDD19A3,FBE86284-76F4-495C-B347-320BCE566AF3,B2ACE54E-25FA-438B-8B2E-33BE453E3DB8,139ACBC1-B800-4088-A0C8-361AD80B449D,96DDBAD7-CC43-4B52-8005-36B3BB94B276,2A5C3AB6-0344-49CE-9FDA-36F87DC3E8DE,F301844C-8414-429E-92C7-380B356BEF2C,073D9AF0-479C-4651-AB60-3868E23611FF,3306DEB8-71DB-429F-AF63-3AE47D33C35B,B55CC32D-1349-4588-8101-3C1557123C6B,A91ACEED-9DF1-4C6C-BB77-41BDFB787AB7,63736765-22A9-49B3-A0AF-44907D713FA3,20DAC224-13A4-48C1-A075-45E101EE8FAC,2D86BBE5-D49F-44F5-8815-465185BB09AE,BD15C7D8-9922-41A7-A776-4911814B15A8,70DC3856-3840-4AAD-98BD-49217FC0E0A8,FD891FB8-2560-4FBA-8DE1-4B724ABCEC2D,8CBBADE0-0FC7-4B99-81FE-4BBC5616EC3D,2378A8AD-3F0C-4BD7-9FC1-4C26041FD04C,F87C9CCB-C46C-4E71-89D3-5289C4D99B17,011EFA14-570E-4B3F-84BA-53AF7F1494A5,7A006DFD-CC8D-4561-9641-540D07B27663,2157764E-DD2D-4924-B22C-560635A49F7E,2FE8C118-50E3-4064-9E55-5A21FE5EDF2B,C38F3F9D-7301-4828-9BC3-5A56F29A41E9,F2955B2B-A8D4-4A0E-B6D5-5AF4467E4413,6A35A367-B28A-49FB-852B-5F79E8045E61,FDB881B3-ABF3-43F3-B94C-6055D9FFFB2A,2B7F1950-3D76-4561-A510-62FAFD4ADE6A,789C4E1C-532C-48C5-996A-6319A10324AF,82330A88-73D8-40ED-9676-632FA064AA30,BF4B8D0D-B5E0-4471-A199-64BFFF83426F,5579A974-B469-409A-8336-658EF7AE16CF,A9A9E5B8-ED0B-47A5-AADC-69FACFE98348,B1F780FC-5C6E-4A7B-BA40-6C08BA0C0B0E,C7BEB533-8001-448F-BDD0-706D63415854,C408048A-8D52-439B-9C20-7132EDF51D0A,86EE5710-80CE-47C1-9805-72DBCCA0838F,AD555052-53E9-4263-B9E9-75C0A2E171BE,B0F78261-851D-4DE2-B214-75FD9F1600FF,B8AFC8BF-0146-498B-BDB3-76DF82BCC59C,F5A25F81-3E96-421D-9129-77ADD22B0F59,76C83ED3-07DF-403B-85B7-77F57CF71AB4,E95AF964-6D24-4225-8BF2-7976B8D605A0,1B976AFA-F2EE-48AA-936D-7C2BF8DACD8C,494D2E17-6928-4197-AB64-810EE0739053,51FBEF08-0FCB-4108-862D-812A487FAA3A,6C3EA9D9-9CE8-42ED-9D23-82BCF8C959B7,BEA7F0FD-AC0A-4A38-80C1-86F48A8524D2,A703021F-01AE-4A79-BE4D-872855AF90C9,F7DAC3A9-7F21-4575-80B7-88925E08A3D4,E1FB7734-855A-40CE-AF27-89A026FCA1A5,D56A06DC-10A4-4B26-B04E-8B11C9EB0809,98BB59FA-D272-4BB4-BB4C-8E1951D707A0,3FA2CEDD-DFCB-40EC-92D3-8FB51E448516,B9917699-30CF-4F91-9E20-8FE2819D991C,3B511B2C-8B02-4C44-8207-915126AC3ED0,26385F5D-2DBD-40B8-B2A2-91A629575D8A,54BCE489-1B40-4BC4-95D4-928229496B10,DD037D7D-B257-4A20-AA74-92B53E54413C,7CB4A152-8A9A-402B-8B9D-9450B29107C8,A4BCB1AA-8F81-4D5D-A44F-94A209947517,D04361BC-CE97-4DB6-A202-959C9403597A,2ACF5C22-D6D0-48A2-80F3-961001F4392D,522DA766-41BB-4303-B737-9626D0F17384,31FA1816-CB05-4050-AC5A-96AC8BE7F44D,729001B2-DC4B-4C21-8C5E-970E814E4093,FDFC946E-3912-4CD2-B969-973615B59BAE,275AB2FC-802B-454C-B12F-9863CF51DBE6,14263FA4-753D-4BE7-B3F3-9BE3F2C819A1,BC89A0D7-0FCA-4669-BDE0-9EF1DCA282CE,7F261D3E-7151-4449-99C3-A2D9054DA711,4A2BD981-BD02-40C3-B66D-A6EBF551E822,9BBAAAF0-DEEC-4BD3-B794-A9EE27DD963B,ABC1ABFA-0956-4BF5-9FED-ABEC14D62C53,94AA4654-2044-42EC-AB4E-AD4EF6B0AA96,01D3EC70-7D62-4467-8EDC-AF7F96B31D66,96A8B3DC-4E07-4964-B463-AF9FAE825A01,FF8108A5-7B24-41A5-81D2-B0C490CFECE9,225122D9-C24B-4749-900E-B0C6767AF2CE,697F376C-50C1-4D51-B0BC-B0DD42F98691,DD9D706D-1BEB-4111-9685-B1164034867D,E1570A53-A1E0-4E58-A9E8-B193977DA88D,F15A9A5C-B7B4-42FD-BDDE-B24744A30931,C8E52409-8EDD-4E1E-A6D5-B29410DD450B,DAD7CA03-AA4E-46EB-B956-B3402F58A9DD,40E90FD0-A92E-4F25-B6D3-B608E9BD11B6,11A30BD0-7A60-4465-A324-B6CE764046BB,9BCD6539-3503-4327-992A-B72A7E261C06,5F6DE841-4749-4D2C-8B83-B850AC083CA7,7BBAA5A3-4FF6-4696-BF4F-BB7D2F962F57,5BF7E585-D2D8-48F5-903A-BC3AA97A5905,D063771E-C94B-4466-8053-BCEB5DB48DCE,652C8BA6-A548-46E6-BAAF-BDC08F74B603,32076FD8-AC0E-419B-901E-BF1E5D094F24,247A9899-F581-4E2B-8F1A-BFA7779A942D,16987744-42C7-4B77-88C3-C07C56B9AFB1,B152817D-0D15-4642-99B3-C19CA75190FB,40E9D273-BFCF-4CFF-8FA8-C1E01ADE58B3,3B36A764-0FFA-45EB-8AF1-C354D41810FB,DFA643DA-A397-43E5-822B-C3F518CE8D0D,05CFF8E6-8E8A-49DB-BAD6-C43924365076,BB930D8C-3E99-4C81-89B8-C60ABA63F78B,EB006EDC-4C25-42D9-A296-C8C76AE1634E,DE4A410C-6EC5-4B86-835B-CBFC90F81E41,AA1FB2A9-8E49-46D3-BEA7-CFA7C103B83A,4C0A5E13-9249-4A35-AA9A-D16603076DCE,7442ED61-BAF9-4AA8-82D3-D1FDD15DD3CB,61FFD7D9-B694-440D-99F1-D3AA094FD711,819474A8-D576-48BE-B0FD-D44128E48F20,96FFA8A4-C196-423D-9488-D67B2897FD76,E1F29644-F373-4572-9E31-D74A45356BA8,D40234E5-CB66-4D7E-B5CC-D9CD6636FC3E,580188F4-7D17-40F8-B98B-DD58F2EF2F70,768AA025-6443-40F7-93D0-DF7679D92535,8DF64B27-B621-4E7B-8477-E0165D640651,5AE5A3A8-CDD7-4B11-AFE1-E11A6DDCEAD8,CA7C7A1A-550A-42A3-A9C9-E1AF5E7501BF,8F88D6C6-AD0C-49A0-9A4C-E38569CBFCA3,B6C086E5-FCDE-4508-915E-E4CF456B2E6A,6168C2B6-0490-4786-9ACC-E5CFB78BE48D,3D13F357-9D0E-43B9-9A4E-E63833314E5F,2C2AE025-DFF6-4AA1-AC2A-E6874965FEE2,C9BF4FDF-A887-4F4A-BFCB-E71B0B4EEA68,AFFF5DAB-CA73-4651-BCEB-EBE30DA501AE,F127352D-6CC5-4A02-9AA3-EE808A0F5031,06B11087-55DB-4BF4-B111-F4C6D76049EF,A078398D-89BD-44C0-B53E-F553491A8AA2,F63E6B67-C9A6-44AE-A47F-F5F12CA4AD67,6026012F-5C10-4124-B316-F637790515F7,B5E77BA9-FB02-4A9B-ADF0-F93E2B1498F6,5E746821-CC92-4C5E-B0CB-FAE8EAD14D4C,51791C86-9C10-40BF-BB8E-FECEC2D7C3B4'
	SET @dids = NULL
	SET @sdate = '2016-09-01 00:00'
	SET @edate = '2016-09-14 23:59'
	SET @uid = N'DFA7CC7F-92FC-4BA6-9A32-F37BB3FDDE2F'
	SET	@rprtcfgid = N'9030713E-A0A5-440D-8D9B-464782D076C3'

	DECLARE	@lvids varchar(max),
			@ldids VARCHAR(MAX),
			@lsdate datetime,
			@ledate datetime,
			@luid uniqueidentifier,
			@lrprtcfgid UNIQUEIDENTIFIER
		
	SET @lvids = @vids
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
		SUM(ISNULL(DrivingTime,0) + ISNULL(IdleTime,0) + ISNULL(ShortIdleTime,0)) AS TotalTime,
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
				AND c.Name LIKE 'Nestle Germany%'
		GROUP BY aa.CustomerIntId, aa.VehicleIntId, aa.DriverIntId, aa.RouteID, FLOOR(CAST(aa.CreationDateTime AS FLOAT)), dbo.TestBits(aa.StatusFlags, 4)		



	SELECT
			-- Vehicle and Driver Identification columns
			TowCoupling,
			--v.VehicleId,	
			v.Registration,
			--v.FleetNumber,
			--v.VehicleTypeID,
			--d.DriverId,
 			--dbo.FormatDriverNameByUser(d.DriverId, @luid) as DisplayName,
 			dbo.FormatDriverNameByUser(d.DriverId, @luid) as DriverName, -- included for backward compatibility
 			--d.FirstName,
 			--d.Surname,
 			--d.MiddleNames,
 			--d.Number,
 			--d.NumberAlternate,
 			--d.NumberAlternate2,

 			-- Data columns with corresponding colours below 
			SweetSpot, 
			OverRevWithFuel, 
			TopGear, 
			Cruise, 
			CruiseInTopGears,
			CoastInGear, 
			Idle, 
			EngineServiceBrake, 
			OverRevWithoutFuel, 
			Rop,
			Rop2, 
			OverSpeed,
			OverSpeedHigh,
			OverSpeedDistance, 
			IVHOverSpeed,
			CoastOutOfGear, 
			HarshBraking, 
			FuelEcon,
			Pto, 
			Co2, 
			CruiseTopGearRatio,
			Acceleration, 
			Braking, 
			Cornering,
			AccelerationLow, 
			BrakingLow, 
			CorneringLow,
			AccelerationHigh, 
			BrakingHigh, 
			CorneringHigh,
			ManoeuvresLow,
			ManoeuvresMed,
			NULL AS CruiseOverspeed,
			NULL AS TopGearOverspeed,
			NULL AS FuelWastageCost,

			-- Component Columns
			SweetSpotComponent,
			OverRevWithFuelComponent,
			TopGearComponent,
			CruiseComponent,
			CruiseInTopGearsComponent,
			IdleComponent,
			EngineServiceBrakeComponent,
			OverRevWithoutFuelComponent,
			RopComponent,
			Rop2Component,
			OverSpeedComponent,
			OverSpeedHighComponent,
			OverSpeedDistanceComponent,
			IVHOverSpeedComponent,
			CoastOutOfGearComponent,
			HarshBrakingComponent,
			AccelerationComponent,
			BrakingComponent,
			CorneringComponent,
			AccelerationLowComponent,
			BrakingLowComponent,
			CorneringLowComponent,
			AccelerationHighComponent,
			BrakingHighComponent,
			CorneringHighComponent,
			ManoeuvresLowComponent,
			ManoeuvresMedComponent,
			NULL AS CruiseOverspeedComponent,
			NULL AS TopGearOverspeedComponent,

			-- Score columns
			Efficiency, 
			Safety,

			-- Additional columns with no corresponding colour	
			TotalTime,
			TotalDrivingDistance,
			ServiceBrakeUsage,	
			OverRevCount,

			-- Date and Unit columns 
			@lsdate AS sdate,
			@ledate AS edate,
			[dbo].TZ_GetTime(@lsdate,default,@luid) AS CreationDateTime,
			[dbo].TZ_GetTime(@ledate,default,@luid) AS ClosureDateTime,

			@diststr AS DistanceUnit,
			@fuelstr AS FuelUnit,
			@co2str AS Co2Unit,
			@fuelmult AS FuelMult,

			-- Colour columns corresponding to data columns above
			dbo.GYRColourConfig(SweetSpot*100, 1, @lrprtcfgid) AS SweetSpotColour,
			dbo.GYRColourConfig(OverRevWithFuel*100, 2, @lrprtcfgid) AS OverRevWithFuelColour,
			dbo.GYRColourConfig(TopGear*100, 3, @lrprtcfgid) AS TopGearColour,
			dbo.GYRColourConfig(Cruise*100, 4, @lrprtcfgid) AS CruiseColour,
			dbo.GYRColourConfig(CruiseInTopGears*100, 31, @lrprtcfgid) AS CruiseInTopGearsColour,
			dbo.GYRColourConfig(CoastInGear*100, 5, @lrprtcfgid) AS CoastInGearColour,
			dbo.GYRColourConfig(Idle*100, 6, @lrprtcfgid) AS IdleColour,
			dbo.GYRColourConfig(EngineServiceBrake*100, 7, @lrprtcfgid) AS EngineServiceBrakeColour,
			dbo.GYRColourConfig(OverRevWithoutFuel*100, 8, @lrprtcfgid) AS OverRevWithoutFuelColour,
			dbo.GYRColourConfig(Rop, 9, @lrprtcfgid) AS RopColour,
			dbo.GYRColourConfig(Rop2, 41, @lrprtcfgid) AS Rop2Colour,
			dbo.GYRColourConfig(OverSpeed*100, 10, @lrprtcfgid) AS OverSpeedColour, 
			dbo.GYRColourConfig(OverSpeedHigh*100, 32, @lrprtcfgid) AS OverSpeedHighColour,
			dbo.GYRColourConfig(IVHOverSpeed*100, 30, @lrprtcfgid) AS IVHOverSpeedColour,
			dbo.GYRColourConfig(CoastOutOfGear*100, 11, @lrprtcfgid) AS CoastOutOfGearColour,
			dbo.GYRColourConfig(HarshBraking, 12, @lrprtcfgid) AS HarshBrakingColour,
			dbo.GYRColourConfig(Efficiency, 14, @lrprtcfgid) AS EfficiencyColour,
			dbo.GYRColourConfig(Safety, 15, @lrprtcfgid) AS SafetyColour,
			dbo.GYRColourConfig(FuelEcon, 16, @lrprtcfgid) AS KPLColour,
			dbo.GYRColourConfig(Co2, 20, @lrprtcfgid) AS Co2Colour,
			dbo.GYRColourConfig(OverSpeedDistance * 100, 21, @lrprtcfgid) AS OverSpeedDistanceColour,
			dbo.GYRColourConfig(Acceleration, 22, @lrprtcfgid) AS AccelerationColour,
			dbo.GYRColourConfig(Braking, 23, @lrprtcfgid) AS BrakingColour,
			dbo.GYRColourConfig(Cornering, 24, @lrprtcfgid) AS CorneringColour,
			dbo.GYRColourConfig(AccelerationLow, 33, @lrprtcfgid) AS AccelerationLowColour,
			dbo.GYRColourConfig(BrakingLow, 34, @lrprtcfgid) AS BrakingLowColour,
			dbo.GYRColourConfig(CorneringLow, 35, @lrprtcfgid) AS CorneringLowColour,
			dbo.GYRColourConfig(AccelerationHigh, 36, @lrprtcfgid) AS AccelerationHighColour,
			dbo.GYRColourConfig(BrakingHigh, 37, @lrprtcfgid) AS BrakingHighColour,
			dbo.GYRColourConfig(CorneringHigh, 38, @lrprtcfgid) AS CorneringHighColour,
			dbo.GYRColourConfig(AccelerationLow + BrakingLow + CorneringLow, 39, @lrprtcfgid) AS ManoeuvresLowColour,
			dbo.GYRColourConfig(Acceleration + Braking + Cornering, 40, @lrprtcfgid) AS ManoeuvresMedColour,
			dbo.GYRColourConfig(CruiseTopGearRatio*100, 25, @lrprtcfgid) AS CruiseTopGearRatioColour,
			dbo.GYRColourConfig(OverRevCount, 28, @lrprtcfgid) AS OverRevCountColour,
			dbo.GYRColourConfig(Pto*100, 29, @lrprtcfgid) AS PtoColour,
			NULL AS CruiseOverspeedColour,
			NULL AS TopGearOverspeedColour,
			NULL AS FuelWastageCostColour
	FROM
		(SELECT *,

			Safety = dbo.ScoreByClassConfig('S', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, @lrprtcfgid),
			Efficiency = dbo.ScoreByClassConfig('E', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, @lrprtcfgid),

			SweetSpotComponent = dbo.ScoreComponentValueConfig(1, SweetSpot, @lrprtcfgid),
			OverRevWithFuelComponent = dbo.ScoreComponentValueConfig(2, OverRevWithFuel, @lrprtcfgid),
			TopGearComponent = dbo.ScoreComponentValueConfig(3, TopGear, @lrprtcfgid),
			CruiseComponent = dbo.ScoreComponentValueConfig(4, Cruise, @lrprtcfgid),
			CruiseInTopGearsComponent = dbo.ScoreComponentValueConfig(31, CruiseInTopGears, @lrprtcfgid),
			IdleComponent = dbo.ScoreComponentValueConfig(6, Idle, @lrprtcfgid),
		
			AccelerationComponent = dbo.ScoreComponentValueConfig(22, Acceleration, @lrprtcfgid),
			BrakingComponent = dbo.ScoreComponentValueConfig(23, Braking, @lrprtcfgid),
			CorneringComponent = dbo.ScoreComponentValueConfig(24, Cornering, @lrprtcfgid),
		
			AccelerationLowComponent = dbo.ScoreComponentValueConfig(33, AccelerationLow, @lrprtcfgid),
			BrakingLowComponent = dbo.ScoreComponentValueConfig(34, BrakingLow, @lrprtcfgid),
			CorneringLowComponent = dbo.ScoreComponentValueConfig(35, CorneringLow, @lrprtcfgid),
		
			AccelerationHighComponent = dbo.ScoreComponentValueConfig(36, AccelerationHigh, @lrprtcfgid),
			BrakingHighComponent = dbo.ScoreComponentValueConfig(37, BrakingHigh, @lrprtcfgid),
			CorneringHighComponent = dbo.ScoreComponentValueConfig(38, CorneringHigh, @lrprtcfgid),

			ManoeuvresLowComponent = dbo.ScoreComponentValueConfig(39, AccelerationLow + BrakingLow + CorneringLow, @lrprtcfgid),
			ManoeuvresMedComponent = dbo.ScoreComponentValueConfig(40, Acceleration + Braking + Cornering, @lrprtcfgid),

			EngineServiceBrakeComponent = dbo.ScoreComponentValueConfig(7, EngineServiceBrake, @lrprtcfgid),
			OverRevWithoutFuelComponent = dbo.ScoreComponentValueConfig(8, OverRevWithoutFuel, @lrprtcfgid),
			RopComponent = dbo.ScoreComponentValueConfig(9, Rop, @lrprtcfgid),
			Rop2Component = dbo.ScoreComponentValueConfig(41, Rop2, @lrprtcfgid),
			OverSpeedComponent = dbo.ScoreComponentValueConfig(10, OverSpeed, @lrprtcfgid),
			OverSpeedHighComponent = dbo.ScoreComponentValueConfig(32, OverSpeedHigh, @lrprtcfgid),
			OverSpeedDistanceComponent = dbo.ScoreComponentValueConfig(21, OverSpeedDistance, @lrprtcfgid),
			IVHOverSpeedComponent = dbo.ScoreComponentValueConfig(30, IVHOverSpeed, @lrprtcfgid),
			CoastOutOfGearComponent = dbo.ScoreComponentValueConfig(11, CoastOutOfGear, @lrprtcfgid),
			HarshBrakingComponent = dbo.ScoreComponentValueConfig(12, HarshBraking, @lrprtcfgid)

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
			  AND (d.DriverId IN (SELECT Value FROM dbo.Split(@ldids, ',')) OR @ldids IS NULL)
			  AND r.DrivingDistance > 0
			GROUP BY d.DriverId, v.VehicleId, r.TowCoupling WITH CUBE
			HAVING SUM(DrivingDistance) > 10 ) o
		) p

	LEFT JOIN dbo.Vehicle v ON p.VehicleId = v.VehicleId
	LEFT JOIN dbo.Driver d ON p.DriverId = d.DriverId

	WHERE TowCoupling IS NOT NULL	

	ORDER BY Registration, Surname


END


GO
