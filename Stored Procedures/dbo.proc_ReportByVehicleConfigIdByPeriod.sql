SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportByVehicleConfigIdByPeriod]
(
	@vids varchar(max),
	@dids varchar(max),
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER,
	@periodType INT
)
AS

--DECLARE	@vids varchar(max),
--		@dids VARCHAR(MAX),
--		@sdate datetime,
--		@edate datetime,
--		@uid uniqueidentifier,
--		@rprtcfgid UNIQUEIDENTIFIER,
--		@periodType INT

--SET @vids = NULL--N'D075F7EF-C02E-46E4-91C3-8191F2167F59,8016F50D-A2D1-49A9-BC1E-13AE27953390,486A43F1-70D9-46CC-A745-542B6A4D77CE,5DE385BF-BFCB-4179-90CB-5AEE460B14AD,67B44E7F-6A0E-42E0-9DCF-5DDCA2AF502E,2C1A82DE-6DCB-4D03-BC21-5F65198B9A84,DB3AC174-1CFE-404C-914B-6BE9DB1B7038,D075F7EF-C02E-46E4-91C3-8191F2167F59,6CD1331B-F7FC-4866-A333-8FEE45667F33,91D26E73-DBD4-45DA-935C-997766C44AA2,3708F23A-F7CA-44F0-BB96-A94E80C40DFF,A8DC179E-04AB-4483-9141-A95F46B0968B,5AAB0E74-D39E-483B-AAFF-200FB5A56850,1860348D-20B5-42CF-BA66-203864BA0461,BD5F9889-8007-4943-9001-46CB3ED2D36F,4DA5FA6D-8496-4D75-AA6A-4C32B377BDF9,C5868274-5850-4762-8EA8-5B5B7C1C2B5B,BD15D85F-F591-4AB5-881A-65E296715D18,33A67A70-9935-4214-B7B0-69B7AC228F5C,26C1ACD4-C763-40E0-AA10-6DEB1F960A9A,46F9F76A-1324-474B-B0BD-6E160C3E8ACD,EB5F8AE0-FC95-4D38-87FE-801C22911CA6,2D68CB77-FE15-4030-839A-824B6D0806BA,9A615ECD-2389-4D20-B0BE-8667626A38BA,CF6E7729-C9E7-4373-BEAB-895D9A2F1379,8288801A-186F-4BE4-A044-8A4007BD2372,0BBEF81F-92A9-4183-A354-8B15F4B354DD,AE9AD52F-7659-4339-BB56-A39AC3923A54,DF0D3E78-19EB-4779-BAE8-A974FE4F1B33,F5F18987-540E-44A0-A9EB-BC42699EFA30,2E7A5E82-702A-4003-BB17-C072A93ED941,18750389-36C6-4D3E-BE79-C54B859CE83B,2C63EBDD-07D4-4F26-A3A4-C5E18DBCB5CF,0A293ED6-5DE5-4B92-BDF0-C8357DF9003D,D103A123-A2A2-4EF1-97DF-D184E971FE7B,C98B01D1-B2E7-4378-A1A4-D5245CDDDF0D,3AAEA81D-20C4-4F24-B022-DECA9C7C51B1,5081472D-203E-4F21-9CF8-E1F98619361A,53B878DA-091D-4722-B467-1463EE502C19,04D11745-A145-4215-A432-2A5061B9DC17,2C38D238-E1A6-4E08-B419-345ACB40930F,FA6E62CA-3470-4F73-A32D-3C79BF6206A9,339C8146-9790-4CFE-B974-5819ECC299C0,C83D509F-26C0-4ED6-9D12-5C5D9716789D,8780C077-1BCB-4EF9-AC7A-6D763D0B5721,FB0C91E1-401B-427B-B3EE-7AC8A4294BF3,7DE5AA38-2BA3-4C8F-A488-911911DA6F80,0FADC446-F107-4EF5-B23A-93CF7EA917E7,5C77C772-4FCA-4040-BDF7-942B2E153FFF,B88446F6-CDEE-456D-9896-9743AEDD4D9A,8C2E8B0E-E258-4F27-8BE6-9EE90EF08614,DB306411-629E-445B-8FE9-9FE65C285296,4723BA01-21CE-4FFB-85E7-A754BF858BC7,760F49E6-5E83-49E2-9E56-CDE7CFDEFF08,97E3C42B-0940-404F-B0FE-E4AD4981E728,76EE70C2-598A-4C1F-85C0-E5A102CD70F2,B7EEE367-B07C-4441-86EF-EB7E5613F7EF,7B27F3D7-3BAC-40AC-9B30-ED9211329331'
--SET @dids = N'8C9A2496-033A-4907-A054-392F85E7ACC0'
--SET @sdate = '2018-10-20 00:00'
--SET @edate = '2018-11-19 23:59'
----SET @rprtcfgid = N'6FAD9660-775F-4E1D-94B2-613CD4F94D65'
----SET @dids = NULL--N'A0842CD2-4540-4C18-96F9-5E0D2219D8CB,0D572BAC-D832-4D53-A192-7F7C56E1D37B,56E27377-A4C4-4318-8F21-CB7F7CE1F5C7'
--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
--SET	@rprtcfgid = N'1C595889-0353-43F4-B840-64781558BBF5'
--SET @periodType = 0

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
		@co2mult FLOAT,
		@now DATETIME

SELECT @diststr = [dbo].UserPref(@luid, 203)
SELECT @distmult = [dbo].UserPref(@luid, 202)
SELECT @fuelstr = [dbo].UserPref(@luid, 205)
SELECT @fuelmult = [dbo].UserPref(@luid, 204)
SELECT @co2str = [dbo].UserPref(@luid, 211)
SELECT @co2mult = [dbo].UserPref(@luid, 210)

SET @lsdate = [dbo].TZ_ToUTC(@lsdate,default,@luid)
SET @ledate = [dbo].TZ_ToUTC(@ledate,default,@luid)
SET @now = GETDATE()

DECLARE @period_dates TABLE (
		PeriodNum TINYINT IDENTITY (1,1),
		PeriodId INT,
		StartDate DATETIME,
		EndDate DATETIME)

IF ISNULL(@periodType, 0) = 0	-- Default setting of last 5 weeks used for Combined report
BEGIN      
INSERT  INTO @period_dates ( StartDate, EndDate )
        SELECT  StartDate,
                EndDate
        FROM    dbo.CreateDateRangeSec(@lsdate, @ledate, 168)
UPDATE @period_dates
SET PeriodId = PeriodNum -- set the periodId = PeriodNum for default processing
END	
	

-- Create temporary table for vehicle configs
DECLARE @VehicleConfig TABLE
(
	Vid UNIQUEIDENTIFIER,
	ReportConfigId UNIQUEIDENTIFIER,
	TotalsIndicatorId INT
)

IF @lvids IS NOT NULL -- Get configs by vehicle
-- The table will be populated by a specific vehicle config if one exists, other wise the default config will be populated instead
BEGIN
	INSERT INTO @VehicleConfig (Vid, ReportConfigId)
	SELECT v.Value, ISNULL(vrc.ReportConfigurationId, @lrprtcfgid)
	FROM dbo.Split(@lvids, ',') v
	LEFT JOIN dbo.VehicleReportConfiguration vrc ON v.Value = vrc.VehicleId
END ELSE -- identify vehicles by driver and get configs by vehicle
BEGIN
	INSERT INTO @VehicleConfig (Vid, ReportConfigId)
	SELECT DISTINCT v.VehicleId, ISNULL(vrc.ReportConfigurationId, @lrprtcfgid)
	FROM dbo.Reporting r
	INNER JOIN dbo.Vehicle v ON r.VehicleIntId = v.VehicleIntId
	INNER JOIN dbo.Driver d ON r.DriverIntId = d.DriverIntId
	LEFT JOIN dbo.VehicleReportConfiguration vrc ON v.VehicleId = vrc.VehicleId
	WHERE d.DriverId IN (SELECT VALUE FROM dbo.Split(@ldids, ','))
	  AND r.Date BETWEEN @lsdate AND @ledate
END

UPDATE @VehicleConfig
SET TotalsIndicatorId = ti.IndicatorId
FROM @VehicleConfig vc
INNER JOIN (SELECT ic.ReportConfigurationId, MIN(ic.IndicatorId) AS IndicatorId
			FROM dbo.IndicatorConfig ic
			WHERE ic.IndicatorId IN (14,15) 
			GROUP BY ic.ReportConfigurationId) ti ON vc.ReportConfigId = ti.ReportConfigurationId 

-- Pre-Process Data to get weighted distances
DECLARE @weightedData TABLE
(
	Date DATETIME,
	VehicleIntId INT,
	DriverIntId INT,
	DrivingDistance FLOAT,
	TotalTime BIGINT,
	wInSweetSpotDistance FLOAT, InSweetSpotTotal FLOAT, --InSweetSpotUsed INT,
	wFueledOverRPMDistance FLOAT, FueledOverRPMTotal FLOAT, --FueledOverRPMUsed INT,
	wTopGearDistance FLOAT, TopGearTotal FLOAT, --TopGearUsed INT,
	wCruiseControlDistance FLOAT, CruiseTotal FLOAT, --CruiseUsed INT,
	wCruiseInTopGearsDistance FLOAT, CruiseInTopGearsTotal FLOAT, --CruiseInTopGearsUsed INT,
	wCoastInGearDistance FLOAT, CoastInGearTotal FLOAT, --CoastInGearUsed INT,
	wIdleTime FLOAT, IdleTotal FLOAT, --IdleUsed INT,
	wEngineBrakeDistance FLOAT, EngineServiceTotal FLOAT, --EngineServiceUsed INT, 
	wEngineBrakeOverRPMDistance FLOAT, EngineBrakeOverRPMTotal FLOAT, --EngineBrakeOverRPMUsed INT,
	wROPCount FLOAT, ROPTotal FLOAT, --ROPUsed INT,
	wROP2Count FLOAT, ROP2Total FLOAT, --ROP2Used INT,
	wOverspeedDistance FLOAT, OverSpeedTotal FLOAT, --OverSpeedUsed INT,
	wOverSpeedHighDistance FLOAT, OverSpeedHighTotal FLOAT, --OverSpeedHighUsed INT,
	wIVHOverSpeedDistance FLOAT, IVHOverSpeedTotal FLOAT, --IVHOverSpeedUsed INT,
	wCoastOutOfGearDistance FLOAT, CoastOutOfGearTotal FLOAT, --CoastOutOfGearUsed INT,
	wPanicStopCount FLOAT, PanicStopTotal FLOAT, --PanicStopUsed INT,
	wAcceleration FLOAT, AccelerationTotal FLOAT, --AccelerationUsed INT,
	wBraking FLOAT, BrakingTotal FLOAT, --BrakingUsed INT,
	wCornering FLOAT, CorneringTotal FLOAT, --CorneringUsed INT,
	wAccelerationLow FLOAT, AccelerationLowTotal FLOAT, --AccelerationLowUsed INT,
	wBrakingLow FLOAT, BrakingLowTotal FLOAT, --BrakingLowUsed INT,
	wCorneringLow FLOAT, CorneringLowTotal FLOAT, --CorneringLowUsed INT,
	wAccelerationHigh FLOAT, AccelerationHighTotal FLOAT, --AccelerationHighUsed INT,
	wBrakingHigh FLOAT, BrakingHighTotal FLOAT, --BrakingHighUsed INT,
	wCorneringHigh FLOAT, CorneringHighTotal FLOAT, --CorneringHighUsed INT,
	wManoeuvresLow FLOAT, ManoeuvresLowTotal FLOAT, --ManoeuvresLowUsed TINYINT,		
	wManoeuvresMed FLOAT, ManoeuvresMedTotal FLOAT, --ManoeuvresMedUsed TINYINT,		
	--CruiseTopGearRatioUsed INT,
	wORCount FLOAT, ORCountTotal FLOAT, --ORCountUsed INT,
	wPTOTime FLOAT, PTOTotal FLOAT, --PTOUsed INT
	wTotalFuel FLOAT, FuelEconTotal FLOAT,
	wTopGearOverSpeed FLOAT, TopGearOverSpeedTotal FLOAT, TopGearOverSpeedUsed TINYINT,
	wCruiseOverSpeed FLOAT, CruiseOverSpeedTotal FLOAT, CruiseOverSpeedUsed TINYINT

)

INSERT INTO @weightedData  (Date, VehicleIntId, DriverIntId, 
							DrivingDistance, TotalTime,
							wInSweetSpotDistance, InSweetSpotTotal, --InSweetSpotUsed,
							wFueledOverRPMDistance, FueledOverRPMTotal, --FueledOverRPMUsed,
							wTopGearDistance, TopGearTotal, --TopGearUsed,
							wCruiseControlDistance, CruiseTotal, --CruiseUsed,
							wCruiseInTopGearsDistance, CruiseInTopGearsTotal, --CruiseInTopGearsUsed,
							wCoastInGearDistance, CoastInGearTotal, --CoastInGearUsed,
							wIdleTime, IdleTotal, --IdleUsed,
							wEngineBrakeDistance, EngineServiceTotal, --EngineServiceUsed,
							wEngineBrakeOverRPMDistance, EngineBrakeOverRPMTotal, --EngineBrakeOverRPMUsed,
							wROPCount, ROPTotal, --ROPUsed,
							wROP2Count, ROP2Total, --ROP2Used,
							wOverspeedDistance, OverSpeedTotal, --OverSpeedUsed,
							wOverSpeedHighDistance, OverSpeedHighTotal, --OverSpeedHighUsed,
							wIVHOverSpeedDistance, IVHOverSpeedTotal, --IVHOverSpeedUsed,
							wCoastOutOfGearDistance, CoastOutOfGearTotal, --CoastOutOfGearUsed,
							wPanicStopCount, PanicStopTotal, --PanicStopUsed,
							wAcceleration, AccelerationTotal, --AccelerationUsed,
							wBraking, BrakingTotal, --BrakingUsed,
							wCornering, CorneringTotal, --CorneringUsed,
							wAccelerationLow, AccelerationLowTotal, --AccelerationLowUsed,
							wBrakingLow, BrakingLowTotal, --BrakingLowUsed,
							wCorneringLow, CorneringLowTotal, --CorneringLowUsed,
							wAccelerationHigh, AccelerationHighTotal, --AccelerationHighUsed,
							wBrakingHigh, BrakingHighTotal, --BrakingHighUsed,
							wCorneringHigh, CorneringHighTotal, --CorneringHighUsed,
							wManoeuvresLow, ManoeuvresLowTotal, --ManoeuvresLowUsed,
							wManoeuvresMed, ManoeuvresMedTotal, --ManoeuvresMedUsed,													
							--CruiseTopGearRatioUsed,
							wORCount, ORCountTotal, --ORCountUsed,
							wPTOTime, PTOTotal,--, PTOUsed)
							wTotalFuel, FuelEconTotal,
							wTopGearOverSpeed, TopGearOverSpeedTotal, TopGearOverSpeedUsed,
							wCruiseOverSpeed, CruiseOverSpeedTotal, CruiseOverSpeedUsed)

SELECT	Date, VehicleIntId, DriverIntId, 
		SUM(DrivingDistance), SUM(TotalTime),
		SUM(wInSweetSpotDistance), SUM(InSweetSpotTotal), 
		SUM(wFueledOverRPMDistance), SUM(FueledOverRPMTotal), 
		SUM(wTopGearDistance), SUM(TopGearTotal), 
		SUM(wCruiseControlDistance), SUM(CruiseTotal), 
		SUM(wCruiseInTopGearsDistance), SUM(CruiseInTopGearsTotal), 
		SUM(wCoastInGearDistance), SUM(CoastInGearTotal),
		SUM(wIdleTime), SUM(IdleTotal), 
		SUM(wEngineBrakeDistance), SUM(EngineServiceTotal), 
		SUM(wEngineBrakeOverRPMDistance), SUM(EngineBrakeOverRPMTotal), 
		SUM(wROPCount), SUM(ROPTotal),
		SUM(wROP2Count), SUM(ROP2Total), 
		SUM(wOverspeedDistance), SUM(OverSpeedTotal), 
		SUM(wOverSpeedHighDistance), SUM(OverSpeedHighTotal), 
		SUM(wIVHOverSpeedDistance), SUM(IVHOverSpeedTotal), 
		SUM(wCoastOutOfGearDistance), SUM(CoastOutOfGearTotal),
		SUM(wPanicStopCount), SUM(PanicStopTotal), 
		SUM(wAcceleration), SUM(AccelerationTotal), 
		SUM(wBraking), SUM(BrakingTotal), 
		SUM(wCornering), SUM(CorneringTotal),
		SUM(wAccelerationLow), SUM(AccelerationLowTotal),
		SUM(wBrakingLow), SUM(BrakingLowTotal), 
		SUM(wCorneringLow), SUM(CorneringLowTotal), 
		SUM(wAccelerationHigh), SUM(AccelerationHighTotal),
		SUM(wBrakingHigh), SUM(BrakingHighTotal), 
		SUM(wCorneringHigh), SUM(CorneringHighTotal), 
		SUM(wManoeuvresLow), SUM(ManoeuvresLowTotal), 
		SUM(wManoeuvresMed), SUM(ManoeuvresMedTotal), 
		SUM(wORCount), SUM(ORCountUsed),
		SUM(wPTOTime), SUM(PTOTotal),
		SUM(wTotalFuel), SUM(FuelEconTotal),
		SUM(wTopGearOverSpeed), SUM(TopGearOverSpeedTotal), ISNULL(MAX(TopGearOverSpeedUsed), 0),
		SUM(wCruiseOverSpeed), SUM(CruiseOverSpeedTotal), ISNULL(MAX(CruiseOverSpeedUsed), 0)

FROM	
	(
	SELECT	r.Date, r.VehicleIntId, r.DriverIntId,
			CASE WHEN ic.IndicatorId = vc.TotalsIndicatorId THEN r.DrivingDistance + r.PTOMovingDistance END AS DrivingDistance,
			CASE WHEN ic.IndicatorId = vc.TotalsIndicatorId THEN r.TotalTime END AS TotalTime,

			-- For each component calculate the weighted value and the weighted total (i.e. where the indicator is being used (IS NOT NULL))	
			CASE WHEN ic.IndicatorId = 1 THEN r.InSweetSpotDistance END AS wInSweetSpotDistance,
			CASE WHEN ic.IndicatorId = 1 THEN r.DrivingDistance + r.PTOMovingDistance END AS InSweetSpotTotal,
			CASE WHEN ic.IndicatorId = 1 THEN 1 END AS InSweetSpotUsed,
		
			CASE WHEN ic.IndicatorId = 2 THEN r.FueledOverRPMDistance END AS wFueledOverRPMDistance,
			CASE WHEN ic.IndicatorId = 2 THEN r.DrivingDistance + r.PTOMovingDistance END AS FueledOverRPMTotal,
			CASE WHEN ic.IndicatorId = 2 THEN 1 END AS FueledOverRPMUsed,
		
			CASE WHEN ic.IndicatorId = 3 THEN r.TopGearDistance END AS wTopGearDistance,
			CASE WHEN ic.IndicatorId = 3 THEN r.DrivingDistance + r.PTOMovingDistance END AS TopGearTotal,
			CASE WHEN ic.IndicatorId = 3 THEN 1 END AS TopGearUsed,
		
			CASE WHEN ic.IndicatorId = 4 THEN r.CruiseControlDistance END AS wCruiseControlDistance,
			CASE WHEN ic.IndicatorId = 4 THEN r.DrivingDistance + r.PTOMovingDistance END AS CruiseTotal,
			CASE WHEN ic.IndicatorId = 4 THEN 1 END AS CruiseUsed,
		
			CASE WHEN ic.IndicatorId = 31 THEN r.CruiseControlDistance END AS wCruiseInTopGearsDistance,
			CASE WHEN ic.IndicatorId = 31 THEN r.TopGearDistance + r.GearDownDistance END AS CruiseInTopGearsTotal,
			CASE WHEN ic.IndicatorId = 31 THEN 1 END AS CruiseInTopGearsUsed,
		
			CASE WHEN ic.IndicatorId = 5 THEN r.CoastInGearDistance END AS wCoastInGearDistance,
			CASE WHEN ic.IndicatorId = 5 THEN r.DrivingDistance + r.PTOMovingDistance END AS CoastInGearTotal,
			CASE WHEN ic.IndicatorId = 5 THEN 1 END AS CoastInGearUsed,
		
			CASE WHEN ic.IndicatorId = 6 THEN r.IdleTime END AS wIdleTime,
			CASE WHEN ic.IndicatorId = 6 THEN r.TotalTime END AS IdleTotal,
			CASE WHEN ic.IndicatorId = 6 THEN 1 END AS IdleUsed,
		
			CASE WHEN ic.IndicatorId = 7 THEN r.EngineBrakeDistance END AS wEngineBrakeDistance,
			CASE WHEN ic.IndicatorId = 7 THEN r.ServiceBrakeDistance + r.EngineBrakeDistance END AS EngineServiceTotal,
			CASE WHEN ic.IndicatorId = 7 THEN 1 END AS EngineServiceUsed,
		
			CASE WHEN ic.IndicatorId = 8 THEN r.EngineBrakeOverRPMDistance END AS wEngineBrakeOverRPMDistance,
			CASE WHEN ic.IndicatorId = 8 THEN r.EngineBrakeDistance END AS EngineBrakeOverRPMTotal,
			CASE WHEN ic.IndicatorId = 8 THEN 1 END AS EngineBrakeOverRPMUsed,
		
			CASE WHEN ic.IndicatorId = 9 THEN r.ROPCount END AS wROPCount,
			CASE WHEN ic.IndicatorId = 9 THEN r.DrivingDistance + r.PTOMovingDistance END AS ROPTotal,
			CASE WHEN ic.IndicatorId = 9 THEN 1 END AS ROPUsed,

			CASE WHEN ic.IndicatorId = 41 THEN r.ROP2Count END AS wROP2Count,
			CASE WHEN ic.IndicatorId = 41 THEN r.DrivingDistance + r.PTOMovingDistance END AS ROP2Total,
			CASE WHEN ic.IndicatorId = 41 THEN 1 END AS ROP2Used,
					
			CASE WHEN ic.IndicatorId = 10 THEN ro.OverspeedDistance END AS wOverspeedDistance,
			CASE WHEN ic.IndicatorId = 10 THEN r.DrivingDistance + r.PTOMovingDistance END AS OverSpeedTotal,
			CASE WHEN ic.IndicatorId = 10 THEN 1 END AS OverSpeedUsed,

			CASE WHEN ic.IndicatorId = 32 THEN ro.OverSpeedHighDistance END AS wOverSpeedHighDistance,
			CASE WHEN ic.IndicatorId = 32 THEN r.DrivingDistance + r.PTOMovingDistance END AS OverSpeedHighTotal,
			CASE WHEN ic.IndicatorId = 32 THEN 1 END AS OverSpeedHighUsed,
		
			CASE WHEN ic.IndicatorId = 30 THEN r.OverSpeedDistance END AS wIVHOverSpeedDistance,
			CASE WHEN ic.IndicatorId = 30 THEN r.DrivingDistance + r.PTOMovingDistance END AS IVHOverSpeedTotal,
			CASE WHEN ic.IndicatorId = 30 THEN 1 END AS IVHOverSpeedUsed,
		
			CASE WHEN ic.IndicatorId = 11 THEN r.CoastOutOfGearDistance END AS wCoastOutOfGearDistance,
			CASE WHEN ic.IndicatorId = 11 THEN r.DrivingDistance + r.PTOMovingDistance END AS CoastOutOfGearTotal,
			CASE WHEN ic.IndicatorId = 11 THEN 1 END AS CoastOutOfGearUsed,
		
			CASE WHEN ic.IndicatorId = 12 THEN r.PanicStopCount END AS wPanicStopCount,
			CASE WHEN ic.IndicatorId = 12 THEN r.DrivingDistance + r.PTOMovingDistance END AS PanicStopTotal,
			CASE WHEN ic.IndicatorId = 12 THEN 1 END AS PanicStopUsed,
		
			CASE WHEN ic.IndicatorId = 22 THEN abc.Acceleration END AS wAcceleration,
			CASE WHEN ic.IndicatorId = 22 THEN r.DrivingDistance + r.PTOMovingDistance END AS AccelerationTotal,
			CASE WHEN ic.IndicatorId = 22 THEN 1 END AS AccelerationUsed,
		
			CASE WHEN ic.IndicatorId = 23 THEN abc.Braking END AS wBraking,
			CASE WHEN ic.IndicatorId = 23 THEN r.DrivingDistance + r.PTOMovingDistance END AS BrakingTotal,
			CASE WHEN ic.IndicatorId = 23 THEN 1 END AS BrakingUsed,
		
			CASE WHEN ic.IndicatorId = 24 THEN abc.Cornering END AS wCornering,
			CASE WHEN ic.IndicatorId = 24 THEN r.DrivingDistance + r.PTOMovingDistance END AS CorneringTotal,
			CASE WHEN ic.IndicatorId = 24 THEN 1 END AS CorneringUsed,
		
			CASE WHEN ic.IndicatorId = 33 THEN abc.AccelerationLow END AS wAccelerationLow,
			CASE WHEN ic.IndicatorId = 33 THEN r.DrivingDistance + r.PTOMovingDistance END AS AccelerationLowTotal,
			CASE WHEN ic.IndicatorId = 33 THEN 1 END AS AccelerationLowUsed,
		
			CASE WHEN ic.IndicatorId = 34 THEN abc.BrakingLow END AS wBrakingLow,
			CASE WHEN ic.IndicatorId = 34 THEN r.DrivingDistance + r.PTOMovingDistance END AS BrakingLowTotal,
			CASE WHEN ic.IndicatorId = 34 THEN 1 END AS BrakingLowUsed,
		
			CASE WHEN ic.IndicatorId = 35 THEN abc.CorneringLow END AS wCorneringLow,
			CASE WHEN ic.IndicatorId = 35 THEN r.DrivingDistance + r.PTOMovingDistance END AS CorneringLowTotal,
			CASE WHEN ic.IndicatorId = 35 THEN 1 END AS CorneringLowUsed, 		
		
			CASE WHEN ic.IndicatorId = 36 THEN abc.AccelerationHigh END AS wAccelerationHigh,
			CASE WHEN ic.IndicatorId = 36 THEN r.DrivingDistance + r.PTOMovingDistance END AS AccelerationHighTotal,
			CASE WHEN ic.IndicatorId = 36 THEN 1 END AS AccelerationHighUsed,
		
			CASE WHEN ic.IndicatorId = 37 THEN abc.BrakingHigh END AS wBrakingHigh,
			CASE WHEN ic.IndicatorId = 37 THEN r.DrivingDistance + r.PTOMovingDistance END AS BrakingHighTotal,
			CASE WHEN ic.IndicatorId = 37 THEN 1 END AS BrakingHighUsed,
		
			CASE WHEN ic.IndicatorId = 38 THEN abc.CorneringHigh END AS wCorneringHigh,
			CASE WHEN ic.IndicatorId = 38 THEN r.DrivingDistance + r.PTOMovingDistance END AS CorneringHighTotal,
			CASE WHEN ic.IndicatorId = 38 THEN 1 END AS CorneringHighUsed,	
	
			CASE WHEN ic.IndicatorId = 39 THEN abc.AccelerationLow + abc.BrakingLow + abc.CorneringLow END AS wManoeuvresLow,
			CASE WHEN ic.IndicatorId = 39 THEN r.DrivingDistance + r.PTOMovingDistance END AS ManoeuvresLowTotal,
			CASE WHEN ic.IndicatorId = 39 THEN 1 END AS ManoeuvresLowUsed,	

			CASE WHEN ic.IndicatorId = 40 THEN abc.Acceleration + abc.Braking + abc.Cornering END AS wManoeuvresMed,
			CASE WHEN ic.IndicatorId = 40 THEN r.DrivingDistance + r.PTOMovingDistance END AS ManoeuvresMedTotal,
			CASE WHEN ic.IndicatorId = 40 THEN 1 END AS ManoeuvresMedUsed,	
	
			CASE WHEN ic.IndicatorId = 25 THEN 1 END AS CruiseTopGearRatioUsed,
		
			CASE WHEN ic.IndicatorId = 28 THEN r.ORCount END AS wORCount,
			CASE WHEN ic.IndicatorId = 28 THEN r.DrivingDistance + r.PTOMovingDistance END AS ORCountTotal,
			CASE WHEN ic.IndicatorId = 28 THEN 1 END AS ORCountUsed,
			
			CASE WHEN ic.IndicatorId = 29 THEN r.PTOMovingTime + PTONonMovingTime END AS wPTOTime,
			CASE WHEN ic.IndicatorId = 29 THEN r.TotalTime END AS PTOTotal,
			CASE WHEN ic.IndicatorId = 29 THEN 1 END AS PTOUsed,

			CASE WHEN ic.IndicatorId = 16 THEN r.TotalFuel END AS wTotalFuel,
			CASE WHEN ic.IndicatorId = 16 THEN r.DrivingDistance + r.PTOMovingDistance END AS FuelEconTotal,

			CASE WHEN ic.IndicatorId = 42 THEN r.TopGearSpeedingDistance END AS wTopGearOverSpeed,
			CASE WHEN ic.IndicatorId = 42 THEN r.OverSpeedThresholdDistance END AS TopGearOverSpeedTotal,
			CASE WHEN ic.IndicatorId = 42 THEN 1 END AS TopGearOverSpeedUsed,

			CASE WHEN ic.IndicatorId = 43 THEN r.CruiseSpeedingDistance END AS wCruiseOverSpeed,
			CASE WHEN ic.IndicatorId = 43 THEN r.OverSpeedThresholdDistance END AS CruiseOverSpeedTotal,
			CASE WHEN ic.IndicatorId = 43 THEN 1 END AS CruiseOverSpeedUsed

	FROM dbo.Reporting r		
		INNER JOIN dbo.Vehicle v ON r.VehicleIntId = v.VehicleIntId
		INNER JOIN @VehicleConfig vc ON v.VehicleId = vc.Vid
		INNER JOIN dbo.IndicatorConfig ic ON vc.ReportConfigId = ic.ReportConfigurationId

		INNER JOIN dbo.Driver d ON r.DriverIntId = d.DriverIntId
		LEFT JOIN dbo.ReportingABC abc ON r.VehicleIntId = abc.VehicleIntId AND r.DriverIntId = abc.DriverIntId AND r.Date = abc.Date --AND r.RouteID = abc.RouteId
		LEFT JOIN dbo.ReportingOverspeed ro ON r.VehicleIntId = ro.VehicleIntId AND r.DriverIntId = ro.DriverIntId AND r.Date = ro.Date --AND r.RouteID = ro.RouteId
		-- LEFT JOIN to TAN_EntityCheckOut to excluded data for days where a vehicle is checked out during that day
		LEFT JOIN dbo.TAN_EntityCheckOut tec ON v.VehicleId = tec.EntityId 
												AND FLOOR(CAST(r.Date AS FLOAT)) BETWEEN FLOOR(CAST(tec.CheckOutDateTime AS FLOAT)) AND FLOOR(CAST(tec.CheckInDateTime AS FLOAT))
												AND tec.CheckOutReason NOT IN ('Defrosting', 'Abtauen', 'Dégelé', 'Sbrinare')

	WHERE r.Date BETWEEN @lsdate AND @ledate 
	  AND r.DrivingDistance > 0
	  AND ic.Archived = 0
	  AND tec.EntityCheckOutId IS NULL -- exclude data for checked out periods
	) raw
GROUP BY raw.Date, raw.VehicleIntId, raw.DriverIntId

-- Now perform main report processing
DECLARE @data TABLE
	(
		PeriodNum SMALLINT,
		PeriodStartDate DATETIME,
		PeriodEndDate DATETIME,
		VehicleId UNIQUEIDENTIFIER,	
		Registration VARCHAR(MAX),
		DriverId UNIQUEIDENTIFIER,
 		DisplayName VARCHAR(MAX),
 		DriverName VARCHAR(MAX), 
 		FirstName VARCHAR(MAX),
 		Surname VARCHAR(MAX),
 		MiddleNames VARCHAR(MAX),
 		Number VARCHAR(MAX),
 		NumberAlternate VARCHAR(MAX),
 		NumberAlternate2 VARCHAR(MAX),
		ReportConfigId UNIQUEIDENTIFIER,
		SweetSpot FLOAT, 
		OverRevWithFuel FLOAT, 
		TopGear FLOAT, 
		Cruise FLOAT,
		CruiseInTopGears FLOAT, 
		CoastInGear FLOAT, 
		Idle FLOAT, 
		EngineServiceBrake FLOAT, 
		OverRevWithoutFuel FLOAT, 
		Rop FLOAT, 
		Rop2 FLOAT,
		OverSpeed FLOAT,
		OverSpeedHigh FLOAT,
		OverSpeedDistance FLOAT, 
		IVHOverSpeed FLOAT,
		CoastOutOfGear FLOAT, 
		HarshBraking FLOAT, 
		FuelEcon FLOAT,
		Pto FLOAT, 
		Co2 FLOAT, 
		CruiseTopGearRatio FLOAT,
		Acceleration FLOAT, 
		Braking FLOAT, 
		Cornering FLOAT,
		AccelerationLow FLOAT, 
		BrakingLow FLOAT, 
		CorneringLow FLOAT,
		AccelerationHigh FLOAT, 
		BrakingHigh FLOAT, 
		CorneringHigh FLOAT,
		ManoeuvresLow FLOAT,
		ManoeuvresMed FLOAT,
		CruiseOverspeed FLOAT,
		TopGearOverspeed FLOAT,
		FuelWastageCost FLOAT,
		SweetSpotComponent FLOAT,
		OverRevWithFuelComponent FLOAT,
		TopGearComponent FLOAT,
		CruiseComponent FLOAT,
		CruiseInTopGearsComponent FLOAT,
		CruiseTopGearRatioComponent FLOAT,
		IdleComponent FLOAT,
		EngineServiceBrakeComponent FLOAT,
		OverRevWithoutFuelComponent FLOAT,
		RopComponent FLOAT,
		Rop2Component FLOAT,
		OverSpeedComponent FLOAT,
		OverSpeedHighComponent FLOAT,
		OverSpeedDistanceComponent FLOAT,
		IVHOverSpeedComponent FLOAT,
		CoastOutOfGearComponent FLOAT,
		CoastInGearComponent FLOAT,
		HarshBrakingComponent FLOAT,
		AccelerationComponent FLOAT,
		BrakingComponent FLOAT,
		CorneringComponent FLOAT,
		AccelerationLowComponent FLOAT,
		BrakingLowComponent FLOAT,
		CorneringLowComponent FLOAT,
		AccelerationHighComponent FLOAT,
		BrakingHighComponent FLOAT,
		CorneringHighComponent FLOAT,
		ManoeuvresLowComponent FLOAT,
		ManoeuvresMedComponent FLOAT,
		CruiseOverspeedComponent FLOAT,
		TopGearOverspeedComponent FLOAT,

		Efficiency FLOAT, 
		Safety FLOAT,

		TotalTime FLOAT,
		TotalDrivingDistance FLOAT,
		ServiceBrakeUsage FLOAT,	
		OverRevCount FLOAT,
		sdate DATETIME,
		edate DATETIME,
		CreationDateTime DATETIME,
		ClosureDateTime DATETIME,
		DistanceUnit VARCHAR(MAX),
		FuelUnit VARCHAR(MAX),
		Co2Unit VARCHAR(MAX),
		FuelMult FLOAT
	)





-- Now perform main report processing
INSERT INTO @data
        (PeriodNum,
         PeriodStartDate,
         PeriodEndDate,
         VehicleId,
         Registration,
         DriverId,
         DisplayName,
         DriverName,
         FirstName,
         Surname,
         MiddleNames,
         Number,
         NumberAlternate,
         NumberAlternate2,
		 ReportConfigId,
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
         CruiseOverspeed,
         TopGearOverspeed,
         FuelWastageCost,
         SweetSpotComponent,
         OverRevWithFuelComponent,
         TopGearComponent,
         CruiseComponent,
         CruiseInTopGearsComponent,
         CruiseTopGearRatioComponent,
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
         CoastInGearComponent,
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
         CruiseOverspeedComponent,
         TopGearOverspeedComponent,
         Efficiency,
         Safety,
         TotalTime,
         TotalDrivingDistance,
         ServiceBrakeUsage,
         OverRevCount,
         sdate,
         edate,
         CreationDateTime,
         ClosureDateTime,
         DistanceUnit,
         FuelUnit,
         Co2Unit,
         FuelMult
        )

SELECT
		-- Period identification columns
 		p.PeriodId AS PeriodNum,
		[dbo].TZ_GetTime(p.StartDate,default,@luid) AS PeriodStartDate,
		[dbo].TZ_GetTime(p.EndDate,default,@luid) AS PeriodEndDate,		
		
		-- Vehicle and Driver Identification columns
		v.VehicleId,	
		v.Registration,
		
		d.DriverId,

 		dbo.FormatDriverNameByUser(d.DriverId, @luid) as DisplayName,
 		dbo.FormatDriverNameByUser(d.DriverId, @luid) as DriverName, -- included for backward compatibility
 		d.FirstName,
 		d.Surname,
 		d.MiddleNames,
 		d.Number,
 		d.NumberAlternate,
 		d.NumberAlternate2,
 		
 		ISNULL(ReportConfigId, @lrprtcfgid) AS ReportConfigId,
 		
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
		CruiseOverspeed,
		TopGearOverspeed,
		NULL AS FuelWastageCost,
		
		-- Component Columns
		SweetSpotComponent,
		OverRevWithFuelComponent,
		TopGearComponent,
		CruiseComponent,
		CruiseInTopGearsComponent,
		CruiseTopGearRatioComponent,
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
		CoastInGearComponent,
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
		CruiseOverspeedComponent,
		TopGearOverspeedComponent,
		
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
		@fuelmult AS FuelMult

FROM
	(SELECT *,
		
		0 AS Safety,-- = dbo.ScoreByClassConfig('S', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, ISNULL(ReportConfigId, @lrprtcfgid)),
		0 AS Efficiency,-- = dbo.ScoreByClassConfig('E', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, ISNULL(ReportConfigId, @lrprtcfgid)),
		
		SweetSpotComponent = dbo.ScoreComponentValueConfig(1, SweetSpot, ISNULL(ReportConfigId, @lrprtcfgid)),
		OverRevWithFuelComponent = dbo.ScoreComponentValueConfig(2, OverRevWithFuel, ISNULL(ReportConfigId, @lrprtcfgid)),
		TopGearComponent = dbo.ScoreComponentValueConfig(3, TopGear, ISNULL(ReportConfigId, @lrprtcfgid)),
		CruiseComponent = dbo.ScoreComponentValueConfig(4, Cruise, ISNULL(ReportConfigId, @lrprtcfgid)),
		CruiseInTopGearsComponent = dbo.ScoreComponentValueConfig(31, CruiseInTopGears, ISNULL(ReportConfigId, @lrprtcfgid)),
		CruiseTopGearRatioComponent = dbo.ScoreComponentValueConfig(25, CruiseTopGearRatio, ISNULL(ReportConfigId, @lrprtcfgid)),
		IdleComponent = dbo.ScoreComponentValueConfig(6, Idle, ISNULL(ReportConfigId, @lrprtcfgid)),
		AccelerationComponent = dbo.ScoreComponentValueConfig(22, Acceleration, ISNULL(ReportConfigId, @lrprtcfgid)),
		BrakingComponent = dbo.ScoreComponentValueConfig(23, Braking, ISNULL(ReportConfigId, @lrprtcfgid)),
		CorneringComponent = dbo.ScoreComponentValueConfig(24, Cornering, ISNULL(ReportConfigId, @lrprtcfgid)),
		AccelerationLowComponent = dbo.ScoreComponentValueConfig(33, AccelerationLow, ISNULL(ReportConfigId, @lrprtcfgid)),
		BrakingLowComponent = dbo.ScoreComponentValueConfig(34, BrakingLow, ISNULL(ReportConfigId, @lrprtcfgid)),
		CorneringLowComponent = dbo.ScoreComponentValueConfig(35, CorneringLow, ISNULL(ReportConfigId, @lrprtcfgid)),
		AccelerationHighComponent = dbo.ScoreComponentValueConfig(36, AccelerationHigh, ISNULL(ReportConfigId, @lrprtcfgid)),
		BrakingHighComponent = dbo.ScoreComponentValueConfig(37, BrakingHigh, ISNULL(ReportConfigId, @lrprtcfgid)),
		CorneringHighComponent = dbo.ScoreComponentValueConfig(38, CorneringHigh, ISNULL(ReportConfigId, @lrprtcfgid)),
		ManoeuvresLowComponent = dbo.ScoreComponentValueConfig(39, ManoeuvresLow, ISNULL(ReportConfigId, @lrprtcfgid)),
		ManoeuvresMedComponent = dbo.ScoreComponentValueConfig(40, ManoeuvresMed, ISNULL(ReportConfigId, @lrprtcfgid)),
		EngineServiceBrakeComponent = dbo.ScoreComponentValueConfig(7, EngineServiceBrake, ISNULL(ReportConfigId, @lrprtcfgid)),
		OverRevWithoutFuelComponent = dbo.ScoreComponentValueConfig(8, OverRevWithoutFuel, ISNULL(ReportConfigId, @lrprtcfgid)),
		RopComponent = dbo.ScoreComponentValueConfig(9, Rop, ISNULL(ReportConfigId, @lrprtcfgid)),
		Rop2Component = dbo.ScoreComponentValueConfig(41, Rop2, ISNULL(ReportConfigId, @lrprtcfgid)),
		OverSpeedComponent = dbo.ScoreComponentValueConfig(10, OverSpeed, ISNULL(ReportConfigId, @lrprtcfgid)),
		OverSpeedHighComponent = dbo.ScoreComponentValueConfig(32, OverSpeedHigh, ISNULL(ReportConfigId, @lrprtcfgid)),
		OverSpeedDistanceComponent = dbo.ScoreComponentValueConfig(21, OverSpeedDistance, ISNULL(ReportConfigId, @lrprtcfgid)),
		IVHOverSpeedComponent = dbo.ScoreComponentValueConfig(30, IVHOverSpeed, ISNULL(ReportConfigId, @lrprtcfgid)),
		CoastOutOfGearComponent = dbo.ScoreComponentValueConfig(11, CoastOutOfGear, ISNULL(ReportConfigId, @lrprtcfgid)),
		CoastInGearComponent = dbo.ScoreComponentValueConfig(5, CoastInGear, ISNULL(ReportConfigId, @lrprtcfgid)),
		HarshBrakingComponent = dbo.ScoreComponentValueConfig(12, HarshBraking, ISNULL(ReportConfigId, @lrprtcfgid)),
		CruiseOverspeedComponent = dbo.ScoreComponentValueConfig(43, CruiseOverspeed, ISNULL(ReportConfigId, @lrprtcfgid)),
		TopGearOverspeedComponent = dbo.ScoreComponentValueConfig(42, TopGearOverspeed, ISNULL(ReportConfigId, @lrprtcfgid))

	FROM
		(SELECT
			CASE WHEN (GROUPING(p.PeriodId) = 1) THEN NULL
				ELSE ISNULL(p.PeriodId, NULL)
			END AS PeriodId,
			
			CASE WHEN (GROUPING(v.VehicleId) = 1) THEN NULL
				ELSE ISNULL(v.VehicleId, NULL)
			END AS VehicleId,

			CASE WHEN (GROUPING(d.DriverId) = 1) THEN NULL
				ELSE ISNULL(d.DriverId, NULL)
			END AS DriverId,

			SUM(TotalTime) AS TotalTime,
			SUM(DrivingDistance * 1000 * @distmult) AS TotalDrivingDistance,
			SUM(wInSweetSpotDistance) / dbo.ZeroYieldNull(SUM(InSweetSpotTotal)) AS SweetSpot,
			SUM(wFueledOverRPMDistance) / dbo.ZeroYieldNull(SUM(FueledOverRPMTotal)) AS OverRevWithFuel,
			SUM(wTopGearDistance) / dbo.ZeroYieldNull(SUM(TopGearTotal)) AS TopGear,
			SUM(wCruiseControlDistance) / dbo.ZeroYieldNull(SUM(CruiseTotal)) AS Cruise,
			--Proof of concept. CruiseInTopGearsDistance should be used in production as soon as firmware is released.
			dbo.CAP(SUM(wCruiseInTopGearsDistance) / dbo.ZeroYieldNull(SUM(CruiseInTopGearsTotal)), 1.0) AS CruiseInTopGears,
			--SUM(CruiseInTopGearsDistance) / dbo.ZeroYieldNull(SUM(TopGearDistance + ISNULL(GearDownDistance,0))) AS CruiseInTopGears,
			SUM(wCoastInGearDistance) / dbo.ZeroYieldNull(SUM(CoastInGearTotal)) AS CoastInGear,
			SUM(wCruiseControlDistance) / dbo.ZeroYieldNull(SUM(wTopGearDistance)) AS CruiseTopGearRatio,
			CAST(SUM(wIdleTime) AS float) / dbo.ZeroYieldNull(SUM(IdleTotal)) AS Idle,
			CAST(SUM(wPTOTime) AS float) / dbo.ZeroYieldNull(SUM(PTOTotal)) AS Pto,
			ISNULL((SUM(wTotalFuel) * 2639.1 * @co2mult) / dbo.ZeroYieldNull(SUM(DrivingDistance)),0) AS Co2, --@co2mult: 1 for g/km, 1.6 for g/miles
			SUM(wEngineBrakeDistance) / dbo.ZeroYieldNull(SUM(EngineServiceTotal)) AS ServiceBrakeUsage,
			ISNULL(SUM(wEngineBrakeDistance) / dbo.ZeroYieldNull(SUM(EngineServiceTotal)),0) AS EngineServiceBrake,
			SUM(wEngineBrakeOverRPMDistance) / dbo.ZeroYieldNull(SUM(EngineBrakeOverRPMTotal)) AS OverRevWithoutFuel,
			ISNULL((SUM(wROPCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(ROPTotal) * @distmult * 1000))))),0) AS Rop,
			ISNULL((SUM(wROP2Count) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(ROP2Total) * @distmult * 1000))))),0) AS Rop2,
			ISNULL(SUM(wOverSpeedDistance) / dbo.ZeroYieldNull(SUM(OverSpeedTotal)),0) AS OverSpeed,
			ISNULL(SUM(wOverSpeedHighDistance) / dbo.ZeroYieldNull(SUM(OverSpeedHighTotal)),0) AS OverSpeedHigh,
			ISNULL(SUM(wOverSpeedDistance) / dbo.ZeroYieldNull(SUM(OverSpeedTotal)),0) AS OverSpeedDistance, 
			ISNULL(SUM(wOverSpeedDistance) / dbo.ZeroYieldNull(SUM(IVHOverSpeedTotal)),0) AS IVHOverSpeed,
			ISNULL(SUM(wCoastOutOfGearDistance) / dbo.ZeroYieldNull(SUM(CoastOutOfGearTotal)),0) AS CoastOutOfGear,
			ISNULL((SUM(wPanicStopCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(PanicStopTotal) * @distmult * 1000))))),0) AS HarshBraking,
			ISNULL((SUM(wORCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(ORCountTotal) * @distmult * 1000))))),0) AS OverRevCount,
			ISNULL((SUM(wAcceleration) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(AccelerationTotal) * @distmult * 1000))))),0) AS Acceleration,
			ISNULL((SUM(wBraking) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(BrakingTotal) * @distmult * 1000))))),0) AS Braking,
			ISNULL((SUM(wCornering) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(CorneringTotal) * @distmult * 1000))))),0) AS Cornering,
			ISNULL((SUM(wAccelerationLow) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(AccelerationLowTotal) * @distmult * 1000))))),0) AS AccelerationLow,
			ISNULL((SUM(wBrakingLow) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(BrakingLowTotal) * @distmult * 1000))))),0) AS BrakingLow,
			ISNULL((SUM(wCorneringLow) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(CorneringLowTotal) * @distmult * 1000))))),0) AS CorneringLow,
			ISNULL((SUM(wAccelerationHigh) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(AccelerationHighTotal) * @distmult * 1000))))),0) AS AccelerationHigh,
			ISNULL((SUM(wBrakingHigh) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(BrakingHighTotal) * @distmult * 1000))))),0) AS BrakingHigh,
			ISNULL((SUM(wCorneringHigh) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(CorneringHighTotal) * @distmult * 1000))))),0) AS CorneringHigh,
			ISNULL((SUM(wManoeuvresLow) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(ManoeuvresLowTotal) * @distmult * 1000))))),0) AS ManoeuvresLow,
			ISNULL((SUM(wManoeuvresMed) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(ManoeuvresMedTotal) * @distmult * 1000))))),0) AS ManoeuvresMed,

			ISNULL(SUM(wCruiseOverSpeed) / dbo.ZeroYieldNull(SUM(CruiseOverSpeedTotal)),0) AS CruiseOverspeed,
			ISNULL(SUM(wTopGearOverSpeed) / dbo.ZeroYieldNull(SUM(TopGearOverSpeedTotal)),0) AS TopGearOverspeed,

			(CASE WHEN @fuelmult = 0.1 THEN
				(CASE WHEN SUM(wTotalFuel)=0 THEN NULL ELSE SUM(wTotalFuel * ISNULL(FuelMultiplier,1.0))*100 END)/SUM(FuelEconTotal) 
			ELSE
				(SUM(FuelEconTotal) * 1000) / (CASE WHEN SUM(wTotalFuel)=0 THEN NULL ELSE SUM(wTotalFuel * ISNULL(FuelMultiplier,1.0)) END) * @fuelmult END) AS FuelEcon
				
		FROM @weightedData w
			INNER JOIN dbo.Vehicle v ON w.VehicleIntId = v.VehicleIntId
			INNER JOIN dbo.Driver d ON w.DriverIntId = d.DriverIntId
			INNER JOIN @period_dates p ON w.Date BETWEEN p.StartDate AND p.EndDate
			--LEFT JOIN dbo.ReportingABC abc ON r.VehicleIntId = abc.VehicleIntId AND r.DriverIntId = abc.DriverIntId AND r.Date = abc.Date --AND r.RouteID = abc.RouteId
			--LEFT JOIN dbo.ReportingOverspeed ro ON r.VehicleIntId = ro.VehicleIntId AND r.DriverIntId = ro.DriverIntId AND r.Date = ro.Date --AND r.RouteID = ro.RouteId
			-- LEFT JOIN to TAN_EntityCheckOut to excluded data for days where a vehicle is checked out during that day
			--LEFT JOIN dbo.TAN_EntityCheckOut tec ON v.VehicleId = tec.EntityId 
			--									  AND FLOOR(CAST(r.Date AS FLOAT)) BETWEEN FLOOR(CAST(tec.CheckOutDateTime AS FLOAT)) AND FLOOR(CAST(tec.CheckInDateTime AS FLOAT))
			--									  AND tec.CheckOutReason NOT IN ('Defrosting', 'Abtauen', 'Dégelé', 'Sbrinare')

		WHERE (v.VehicleId IN (SELECT Value FROM dbo.Split(@lvids, ',')) OR @lvids IS NULL)
		  AND (d.DriverId IN (SELECT Value FROM dbo.Split(@ldids, ',')) OR @ldids IS NULL)
          AND DrivingDistance > 0
		GROUP BY p.PeriodId, d.DriverId, v.VehicleId WITH CUBE
		HAVING SUM(DrivingDistance) > 10 ) o

	LEFT JOIN @VehicleConfig vc ON o.VehicleId = vc.Vid
	) Result

LEFT JOIN dbo.Vehicle v ON Result.VehicleId = v.VehicleId
LEFT JOIN dbo.Driver d ON Result.DriverId = d.DriverId
LEFT JOIN @period_dates p ON Result.PeriodId = p.PeriodId

ORDER BY Registration, Surname, PeriodNum	

-- Calculate Scores
UPDATE @data
SET Safety = dbo.ScoreByClassAndConfig('S', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, CruiseOverspeed, TopGearOverspeed, ISNULL(ReportConfigId, @lrprtcfgid)),
	Efficiency = dbo.ScoreByClassAndConfig('E', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, CruiseOverspeed, TopGearOverspeed, ISNULL(ReportConfigId, @lrprtcfgid))

---- Calculate Average Fuel Wastage Cost for vehicle rows
--DECLARE @avgFuelWastageCost FLOAT
--SELECT @avgFuelWastageCost = AVG(FuelWastageCost)
--FROM @data
--WHERE VehicleId IS NOT NULL
--  AND DriverId IS NOT NULL	

---- Post process the data for drivers only to re-calculate the score based on distance where multiple vehicle configs have been used by a driver
--IF @dids IS NOT NULL	
--BEGIN
		
	-- Calculate Driver Scores based on weighted average of scores from vehicles driven by driver
	UPDATE @data
	SET Efficiency = w.WeightedEfficiency / d.TotalDrivingDistance, 
		Safety = w.WeightedSafety / d.TotalDrivingDistance
	FROM @data d
	INNER JOIN 
	(SELECT d.DriverId, d.PeriodNum, SUM(d.Efficiency * d.TotalDrivingDistance) AS WeightedEfficiency, SUM(d.Safety * d.TotalDrivingDistance) AS WeightedSafety
	FROM @data d
	WHERE d.DriverId IS NOT NULL AND d.VehicleId IS NOT NULL AND d.PeriodNum IS NOT NULL	
	GROUP BY d.DriverId, d.PeriodNum) w ON w.DriverId = d.DriverId AND w.PeriodNum = d.PeriodNum
	WHERE d.DriverId IS NOT NULL AND d.PeriodNum IS NOT NULL AND d.VehicleId IS NULL

	-- Calculate Score and Colours for Report Total
	UPDATE @data
	SET Efficiency = w.WeightedEfficiency / d.TotalDrivingDistance, 
		Safety = w.WeightedSafety / d.TotalDrivingDistance
	FROM @data d
	CROSS JOIN 
		(SELECT SUM(d.Efficiency * d.TotalDrivingDistance) AS WeightedEfficiency, SUM(d.Safety * d.TotalDrivingDistance) AS WeightedSafety
		FROM @data d
		WHERE d.DriverId IS NOT NULL AND d.VehicleId IS NULL AND d.PeriodNum IS NULL) w 
	WHERE d.DriverId IS NULL AND d.VehicleId IS NULL AND d.PeriodNum IS NULL	

--END	

SELECT *
FROM @data

GO
