SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_ReportByVehicleConfigId_VehicleGroups]
(
	@gids VARCHAR(MAX),
	@vids varchar(max),
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER
)
AS

--DECLARE	@gids VARCHAR(MAX),
--		@vids varchar(max),
--		@sdate datetime,
--		@edate datetime,
--		@uid uniqueidentifier,
--		@rprtcfgid UNIQUEIDENTIFIER

--SET @gids = N'EA6FF8F6-F6EA-4632-9607-7B0A8A8A8DDB'
--SET @vids = N'B83B0EB1-1A1A-40DF-B5F4-026DA43F2A94,ABAC69E6-CCCC-4E60-9F81-0B14A2CE8CFD,7A03DFD2-3982-46E8-8C4E-12F297DEE350,16DF929B-A773-46D2-900E-2CA8DCF23893,87A3B70E-9B8D-42CB-BB13-2E1C9427331C,93431E81-EE44-4EEE-A959-387B6E4F9CE3,9607D260-5E7F-4DFC-9D2E-3C005AB819B9,39512BD9-7CCF-48AD-9623-46CD000D2AC6,A2979529-C977-44AA-A321-6E9D9F6C6866,9B2B5A35-D0D9-4776-BB1F-87B27DBFD2CC,00F7CA23-363A-4C53-B482-8D3618E305F2,D92E730A-EAA8-4675-A625-9F9F7E6E7B16,DFB2454E-1286-473B-9215-A38D8717CE57,42C9DA5C-2BF6-4A23-865A-A5AB067F8DFA,B8C522B8-99C0-4630-A4DE-A7A523437829,3D0FA257-E0E9-4009-9508-BBFFA244F817,10EA066A-E397-46C5-A337-C6E1B58A88FE,87B51B30-B441-4A79-AD36-ED2BAD3E3204,2660BB7C-C530-4F5A-8988-EDB6DE4D21FE,9630D650-9B0E-4810-BCF0-F92CF9563405'
--SET @sdate = '2020-08-24 00:00'
--SET @edate = '2020-08-30 23:59'
--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
--SET @rprtcfgid = N'1C595889-0353-43F4-B840-64781558BBF5'

DECLARE @lgids VARCHAR(MAX),
		@lvids varchar(max),
		@lsdate datetime,
		@ledate datetime,
		@luid UNIQUEIDENTIFIER,
		@lrprtcfgid UNIQUEIDENTIFIER
		
SET @lgids = @gids
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
		@co2mult FLOAT


SELECT @diststr = [dbo].UserPref(@luid, 203)
SELECT @distmult = [dbo].UserPref(@luid, 202)
SELECT @fuelstr = [dbo].UserPref(@luid, 205)
SELECT @fuelmult = [dbo].UserPref(@luid, 204)
SELECT @co2str = [dbo].UserPref(@luid, 211)
SELECT @co2mult = [dbo].UserPref(@luid, 210)

SET @lsdate = [dbo].TZ_ToUTC(@lsdate,default,@luid)
SET @ledate = [dbo].TZ_ToUTC(@ledate,default,@luid)

DECLARE @RedColour VARCHAR(50)
DECLARE @YellowColour VARCHAR(50)
DECLARE @GreenColour VARCHAR(50)
DECLARE @GoldColour VARCHAR(50)
DECLARE @SilverColour VARCHAR(50)
DECLARE @BronzeColour VARCHAR(50)
DECLARE @CopperColour VARCHAR(50)

SET @RedColour = 'Red'
SET @YellowColour = 'Amber'
SET @GreenColour = 'Green'
SET @GoldColour = 'Gold'
SET @SilverColour = 'Silver'
SET @BronzeColour = 'Bronze'
SET @CopperColour = 'Copper'

-- Create temporary table for vehicle configs
DECLARE @VehicleConfig TABLE
(
	Vid UNIQUEIDENTIFIER,
	ReportConfigId UNIQUEIDENTIFIER
)

-- Get configs by vehicle
-- The table will be populated by a specific vehicle config if one exists, other wise the default config will be populated instead
INSERT INTO @VehicleConfig (Vid, ReportConfigId)
SELECT DISTINCT v.VehicleId, ISNULL(vrc.ReportConfigurationId, @lrprtcfgid)
FROM dbo.Vehicle v
INNER JOIN dbo.GroupDetail gd ON gd.EntityDataId = v.VehicleId
INNER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId
LEFT JOIN dbo.VehicleReportConfiguration vrc ON v.VehicleId = vrc.VehicleId
WHERE (v.VehicleId IN (SELECT Value FROM dbo.Split(@lvids, ',')) OR @lvids IS NULL)
  AND g.IsParameter = 0 
  AND g.Archived = 0 
  AND g.GroupId IN (SELECT Value FROM dbo.Split(@lgids, ','))

-- Pre-Process Data to get weighted distances
DECLARE @weightedData TABLE
(
	GroupId UNIQUEIDENTIFIER,
	VehicleId UNIQUEIDENTIFIER,
	RCount INT,
	wInSweetSpotDistance FLOAT, InSweetSpotTotal FLOAT, InSweetSpotUsed INT,
	wFueledOverRPMDistance FLOAT, FueledOverRPMTotal FLOAT, FueledOverRPMUsed INT,
	wTopGearDistance FLOAT, TopGearTotal FLOAT, TopGearUsed INT,
	wCruiseControlDistance FLOAT, CruiseTotal FLOAT, CruiseUsed INT,
	wCruiseInTopGearsDistance FLOAT, CruiseInTopGearsTotal FLOAT, CruiseInTopGearsUsed INT,
	wCoastInGearDistance FLOAT, CoastInGearTotal FLOAT, CoastInGearUsed INT,
	wIdleTime FLOAT, IdleTotal FLOAT, IdleUsed INT,
	wServiceBrakeDistance FLOAT, ServiceBrakeTotal FLOAT, ServiceBrakeUsed INT, 
	wEngineBrakeOverRPMDistance FLOAT, EngineBrakeOverRPMTotal FLOAT, EngineBrakeOverRPMUsed INT,
	wROPCount FLOAT, ROPTotal FLOAT, ROPUsed INT,
	wROP2Count FLOAT, ROP2Total FLOAT, ROP2Used INT,
	wOverspeedDistance FLOAT, OverSpeedTotal FLOAT, OverSpeedUsed INT,
	wOverSpeedHighDistance FLOAT, OverSpeedHighTotal FLOAT, OverSpeedHighUsed INT,
	wIVHOverSpeedDistance FLOAT, IVHOverSpeedTotal FLOAT, IVHOverSpeedUsed INT,
	wCoastOutOfGearDistance FLOAT, CoastOutOfGearTotal FLOAT, CoastOutOfGearUsed INT,
	wPanicStopCount FLOAT, PanicStopTotal FLOAT, PanicStopUsed INT,
	wAcceleration FLOAT, AccelerationTotal FLOAT, AccelerationUsed INT,
	wBraking FLOAT, BrakingTotal FLOAT, BrakingUsed INT,
	wCornering FLOAT, CorneringTotal FLOAT, CorneringUsed INT,
	wAccelerationLow FLOAT, AccelerationLowTotal FLOAT, AccelerationLowUsed INT,
	wBrakingLow FLOAT, BrakingLowTotal FLOAT, BrakingLowUsed INT,
	wCorneringLow FLOAT, CorneringLowTotal FLOAT, CorneringLowUsed INT,
	wAccelerationHigh FLOAT, AccelerationHighTotal FLOAT, AccelerationHighUsed INT,
	wBrakingHigh FLOAT, BrakingHighTotal FLOAT, BrakingHighUsed INT,
	wCorneringHigh FLOAT, CorneringHighTotal FLOAT, CorneringHighUsed INT,	
	wManoeuvresLow FLOAT, ManoeuvresLowTotal FLOAT, ManoeuvresLowUsed INT,		
	wManoeuvresMed FLOAT, ManoeuvresMedTotal FLOAT, ManoeuvresMedUsed INT,		
	CruiseTopGearRatioUsed INT,
	wORCount FLOAT, ORCountTotal FLOAT, ORCountUsed INT,
	wPTOTime FLOAT, PTOTotal FLOAT, PTOUsed INT,
	wTotalFuel FLOAT, FuelEconTotal FLOAT,
	wTopGearOverSpeed FLOAT, TopGearOverSpeedTotal FLOAT, TopGearOverSpeedUsed TINYINT,
	wCruiseOverSpeed FLOAT, CruiseOverSpeedTotal FLOAT, CruiseOverSpeedUsed TINYINT,

	wOverspeedCount FLOAT, OverspeedCountTotal FLOAT, OverspeedCountUsed TINYINT,
	wOverspeedHighCount FLOAT, OverspeedHighCountTotal FLOAT, OverspeedHighCountUsed TINYINT,
	wStabilityControl FLOAT, StabilityControlTotal FLOAT, StabilityControlUsed TINYINT,
	wCollisionWarningLow FLOAT, CollisionWarningLowTotal FLOAT, CollisionWarningLowUsed TINYINT,
	wCollisionWarningMed FLOAT, CollisionWarningMedTotal FLOAT, CollisionWarningMedUsed TINYINT,
	wCollisionWarningHigh FLOAT, CollisionWarningHighTotal FLOAT, CollisionWarningHighUsed TINYINT,
	wLaneDepartureDisable FLOAT, LaneDepartureDisableTotal FLOAT, LaneDepartureDisableUsed TINYINT,
	wLaneDepartureLeftRight FLOAT, LaneDepartureLeftRightTotal FLOAT, LaneDepartureLeftRightUsed TINYINT,
	wFatigue FLOAT, FatigueTotal FLOAT, FatigueUsed TINYINT,
	wDistraction FLOAT, DistractionTotal FLOAT, DistractionUsed TINYINT,
	wSweetSpotTime FLOAT, SweetSpotTimeTotal FLOAT, SweetSpotTimeUsed TINYINT,
	wOverRevTime FLOAT, OverRevTimeTotal FLOAT, OverRevTimeUsed TINYINT,
	wTopGearTime FLOAT, TopGearTimeTotal FLOAT, TopGearTimeUsed TINYINT
)

INSERT INTO @weightedData  (GroupId,
							VehicleId,
							RCount,
							wInSweetSpotDistance, InSweetSpotTotal, InSweetSpotUsed,
							wFueledOverRPMDistance, FueledOverRPMTotal, FueledOverRPMUsed,
							wTopGearDistance, TopGearTotal, TopGearUsed,
							wCruiseControlDistance, CruiseTotal, CruiseUsed,
							wCruiseInTopGearsDistance, CruiseInTopGearsTotal, CruiseInTopGearsUsed,
							wCoastInGearDistance, CoastInGearTotal, CoastInGearUsed,
							wIdleTime, IdleTotal, IdleUsed,
							wServiceBrakeDistance, ServiceBrakeTotal, ServiceBrakeUsed,
							wEngineBrakeOverRPMDistance, EngineBrakeOverRPMTotal, EngineBrakeOverRPMUsed,
							wROPCount, ROPTotal, ROPUsed,
							wROP2Count, ROP2Total, ROP2Used,
							wOverspeedDistance, OverSpeedTotal, OverSpeedUsed,
							wOverSpeedHighDistance, OverSpeedHighTotal, OverSpeedHighUsed,
							wIVHOverSpeedDistance, IVHOverSpeedTotal, IVHOverSpeedUsed,
							wCoastOutOfGearDistance, CoastOutOfGearTotal, CoastOutOfGearUsed,
							wPanicStopCount, PanicStopTotal, PanicStopUsed,
							wAcceleration, AccelerationTotal, AccelerationUsed,
							wBraking, BrakingTotal, BrakingUsed,
							wCornering, CorneringTotal, CorneringUsed,
							wAccelerationLow, AccelerationLowTotal, AccelerationLowUsed,
							wBrakingLow, BrakingLowTotal, BrakingLowUsed,
							wCorneringLow, CorneringLowTotal, CorneringLowUsed,
							wAccelerationHigh, AccelerationHighTotal, AccelerationHighUsed,
							wBrakingHigh, BrakingHighTotal, BrakingHighUsed,
							wCorneringHigh, CorneringHighTotal, CorneringHighUsed,	
							wManoeuvresLow, ManoeuvresLowTotal, ManoeuvresLowUsed,
							wManoeuvresMed, ManoeuvresMedTotal, ManoeuvresMedUsed,													
							CruiseTopGearRatioUsed,
							wORCount, ORCountTotal, ORCountUsed,
							wPTOTime, PTOTotal, PTOUsed,
							wTotalFuel, FuelEconTotal,
							wTopGearOverSpeed, TopGearOverSpeedTotal, TopGearOverSpeedUsed,
							wCruiseOverSpeed, CruiseOverSpeedTotal, CruiseOverSpeedUsed,
							
						wOverspeedCount, OverspeedCountTotal, OverspeedCountUsed,
						wOverspeedHighCount, OverspeedHighCountTotal, OverspeedHighCountUsed,
						wStabilityControl, StabilityControlTotal, StabilityControlUsed,
						wCollisionWarningLow, CollisionWarningLowTotal, CollisionWarningLowUsed,
						wCollisionWarningMed, CollisionWarningMedTotal, CollisionWarningMedUsed,
						wCollisionWarningHigh, CollisionWarningHighTotal, CollisionWarningHighUsed,
						wLaneDepartureDisable, LaneDepartureDisableTotal, LaneDepartureDisableUsed,
						wLaneDepartureLeftRight, LaneDepartureLeftRightTotal, LaneDepartureLeftRightUsed,
						wFatigue, FatigueTotal, FatigueUsed,
						wDistraction, DistractionTotal, DistractionUsed,
						wSweetSpotTime, SweetSpotTimeTotal, SweetSpotTimeUsed,
						wOverRevTime, OverRevTimeTotal, OverRevTimeUsed,
						wTopGearTime, TopGearTimeTotal, TopGearTimeUsed)

SELECT	GroupId, VehicleId, COUNT(DISTINCT ReportingId) AS RCount, 
		SUM(wInSweetSpotDistance), SUM(InSweetSpotTotal), SUM(InSweetSpotUsed),
		SUM(wFueledOverRPMDistance), SUM(FueledOverRPMTotal), SUM(FueledOverRPMUsed),
		SUM(wTopGearDistance), SUM(TopGearTotal), SUM(TopGearUsed), 
		SUM(wCruiseControlDistance), SUM(CruiseTotal), SUM(CruiseUsed), 
		SUM(wCruiseInTopGearsDistance), SUM(CruiseInTopGearsTotal), SUM(CruiseInTopGearsUsed),
		SUM(wCoastInGearDistance), SUM(CoastInGearTotal), SUM(CoastInGearUsed), 
		SUM(wIdleTime), SUM(IdleTotal), SUM(IdleUsed),
		SUM(wServiceBrakeDistance), SUM(ServiceBrakeTotal), SUM(ServiceBrakeUsed),
		SUM(wEngineBrakeOverRPMDistance), SUM(EngineBrakeOverRPMTotal), SUM(EngineBrakeOverRPMUsed),
		SUM(wROPCount), SUM(ROPTotal), SUM(ROPUsed),
		SUM(wROP2Count), SUM(ROP2Total), SUM(ROP2Used),
		SUM(wOverspeedDistance), SUM(OverSpeedTotal), SUM(OverSpeedUsed),
		SUM(wOverSpeedHighDistance), SUM(OverSpeedHighTotal), SUM(OverSpeedHighUsed),
		SUM(wIVHOverSpeedDistance), SUM(IVHOverSpeedTotal), SUM(IVHOverSpeedUsed),
		SUM(wCoastOutOfGearDistance), SUM(CoastOutOfGearTotal), SUM(CoastOutOfGearUsed),
		SUM(wPanicStopCount), SUM(PanicStopTotal), SUM(PanicStopUsed),
		SUM(wAcceleration), SUM(AccelerationTotal), SUM(AccelerationUsed),
		SUM(wBraking), SUM(BrakingTotal), SUM(BrakingUsed),
		SUM(wCornering), SUM(CorneringTotal), SUM(CorneringUsed),
		SUM(wAccelerationLow), SUM(AccelerationLowTotal), SUM(AccelerationLowUsed),
		SUM(wBrakingLow), SUM(BrakingLowTotal), SUM(BrakingLowUsed),
		SUM(wCorneringLow), SUM(CorneringLowTotal), SUM(CorneringLowUsed),
		SUM(wAccelerationHigh), SUM(AccelerationHighTotal), SUM(AccelerationHighUsed),
		SUM(wBrakingHigh), SUM(BrakingHighTotal), SUM(BrakingHighUsed),
		SUM(wCorneringHigh), SUM(CorneringHighTotal), SUM(CorneringHighUsed),
		SUM(wManoeuvresLow), SUM(ManoeuvresLowTotal), SUM(ManoeuvresLowUsed),
		SUM(wManoeuvresMed), SUM(ManoeuvresMedTotal), SUM(ManoeuvresMedUsed),
		SUM(CruiseTopGearRatioUsed),
		SUM(wORCount), SUM(ORCountUsed), SUM(ORCountUsed),
		SUM(wPTOTime), SUM(PTOTotal), SUM(PTOUsed),
		SUM(wTotalFuel), SUM(FuelEconTotal),
		SUM(wTopGearOverSpeed), SUM(TopGearOverSpeedTotal), ISNULL(MAX(TopGearOverSpeedUsed), 0),
		SUM(wCruiseOverSpeed), SUM(CruiseOverSpeedTotal), ISNULL(MAX(CruiseOverSpeedUsed), 0),

			SUM(wOverspeedCount), SUM(OverspeedCountTotal), ISNULL(MAX(OverspeedCountUsed), 0),
			SUM(wOverspeedHighCount), SUM(OverspeedHighCountTotal), ISNULL(MAX(OverspeedHighCountUsed), 0),
			SUM(wStabilityControl), SUM(StabilityControlTotal), ISNULL(MAX(StabilityControlUsed), 0),
			SUM(wCollisionWarningLow), SUM(CollisionWarningLowTotal), ISNULL(MAX(CollisionWarningLowUsed), 0),
			SUM(wCollisionWarningMed), SUM(CollisionWarningMedTotal), ISNULL(MAX(CollisionWarningMedUsed), 0),
			SUM(wCollisionWarningHigh), SUM(CollisionWarningHighTotal), ISNULL(MAX(CollisionWarningHighUsed), 0),
			SUM(wLaneDepartureDisable), SUM(LaneDepartureDisableTotal), ISNULL(MAX(LaneDepartureDisableUsed), 0),
			SUM(wLaneDepartureLeftRight), SUM(LaneDepartureLeftRightTotal), ISNULL(MAX(LaneDepartureLeftRightUsed), 0),
			SUM(wFatigue), SUM(FatigueTotal), ISNULL(MAX(FatigueUsed), 0),
			SUM(wDistraction), SUM(DistractionTotal), ISNULL(MAX(DistractionUsed), 0),
			SUM(wSweetSpotTime), SUM(SweetSpotTimeTotal), ISNULL(MAX(SweetSpotTimeUsed), 0),
			SUM(wOverRevTime), SUM(OverRevTimeTotal), ISNULL(MAX(OverRevTimeUsed), 0),
			SUM(wTopGearTime), SUM(TopGearTimeTotal), ISNULL(MAX(TopGearTimeUsed), 0)

FROM	
	(
	SELECT	g.GroupId, v.VehicleId, ReportingId,
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
		
			CASE WHEN ic.IndicatorId = 7 THEN r.ServiceBrakeDistance END AS wServiceBrakeDistance,
			CASE WHEN ic.IndicatorId = 7 THEN r.ServiceBrakeDistance + r.EngineBrakeDistance END AS ServiceBrakeTotal,
			CASE WHEN ic.IndicatorId = 7 THEN 1 END AS ServiceBrakeUsed,
		
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
			CASE WHEN ic.IndicatorId = 43 THEN 1 END AS CruiseOverSpeedUsed,

		CASE WHEN ic.IndicatorId = 46 THEN re.OverspeedCount END AS wOverspeedCount,
		CASE WHEN ic.IndicatorId = 46 THEN r.DrivingDistance + r.PTOMovingDistance END AS OverspeedCountTotal,
		CASE WHEN ic.IndicatorId = 46 THEN 1 END AS OverspeedCountUsed,

		CASE WHEN ic.IndicatorId = 47 THEN re.OverspeedHighCount END AS wOverspeedHighCount,
		CASE WHEN ic.IndicatorId = 47 THEN r.DrivingDistance + r.PTOMovingDistance END AS OverspeedHighCountTotal,
		CASE WHEN ic.IndicatorId = 47 THEN 1 END AS OverspeedHighCountUsed,

		CASE WHEN ic.IndicatorId = 48 THEN re.StabilityCount END AS wStabilityControl,
		CASE WHEN ic.IndicatorId = 48 THEN r.DrivingDistance + r.PTOMovingDistance END AS StabilityControlTotal,
		CASE WHEN ic.IndicatorId = 48 THEN 1 END AS StabilityControlUsed,

		CASE WHEN ic.IndicatorId = 49 THEN re.CollisionWarningLow END AS wCollisionWarningLow,
		CASE WHEN ic.IndicatorId = 49 THEN r.DrivingDistance + r.PTOMovingDistance END AS CollisionWarningLowTotal,
		CASE WHEN ic.IndicatorId = 49 THEN 1 END AS CollisionWarningLowUsed,

		CASE WHEN ic.IndicatorId = 50 THEN re.CollisionWarningMed END AS wCollisionWarningMed,
		CASE WHEN ic.IndicatorId = 50 THEN r.DrivingDistance + r.PTOMovingDistance END AS CollisionWarningMedTotal,
		CASE WHEN ic.IndicatorId = 50 THEN 1 END AS CollisionWarningMedUsed,

		CASE WHEN ic.IndicatorId = 51 THEN re.CollisionWarningHigh END AS wCollisionWarningHigh,
		CASE WHEN ic.IndicatorId = 51 THEN r.DrivingDistance + r.PTOMovingDistance END AS CollisionWarningHighTotal,
		CASE WHEN ic.IndicatorId = 51 THEN 1 END AS CollisionWarningHighUsed,

		CASE WHEN ic.IndicatorId = 52 THEN re.LaneDepartureDisableCount END AS wLaneDepartureDisable,
		CASE WHEN ic.IndicatorId = 52 THEN r.DrivingDistance + r.PTOMovingDistance END AS LaneDepartureDisableTotal,
		CASE WHEN ic.IndicatorId = 52 THEN 1 END AS LaneDepartureDisableUsed,

		CASE WHEN ic.IndicatorId = 53 THEN re.LaneDepartureLeftRightCount END AS wLaneDepartureLeftRight,
		CASE WHEN ic.IndicatorId = 53 THEN r.DrivingDistance + r.PTOMovingDistance END AS LaneDepartureLeftRightTotal,
		CASE WHEN ic.IndicatorId = 53 THEN 1 END AS LaneDepartureLeftRightUsed,

		CASE WHEN ic.IndicatorId = 57 THEN re.Fatigue END AS wFatigue,
		CASE WHEN ic.IndicatorId = 57 THEN r.DrivingDistance + r.PTOMovingDistance END AS FatigueTotal,
		CASE WHEN ic.IndicatorId = 57 THEN 1 END AS FatigueUsed,

		CASE WHEN ic.IndicatorId = 58 THEN re.Distraction END AS wDistraction,
		CASE WHEN ic.IndicatorId = 58 THEN r.DrivingDistance + r.PTOMovingDistance END AS DistractionTotal,
		CASE WHEN ic.IndicatorId = 58 THEN 1 END AS DistractionUsed,

		CASE WHEN ic.IndicatorId = 54 THEN re.SweetSpotTime END AS wSweetSpotTime,
		CASE WHEN ic.IndicatorId = 54 THEN r.DrivingDistance + r.PTOMovingDistance END AS SweetSpotTimeTotal,
		CASE WHEN ic.IndicatorId = 54 THEN 1 END AS SweetSpotTimeUsed,

		CASE WHEN ic.IndicatorId = 55 THEN re.OverRPMTime END AS wOverRevTime,
		CASE WHEN ic.IndicatorId = 55 THEN r.DrivingDistance + r.PTOMovingDistance END AS OverRevTimeTotal,
		CASE WHEN ic.IndicatorId = 55 THEN 1 END AS OverRevTimeUsed,

		CASE WHEN ic.IndicatorId = 56 THEN re.TopGearTime END AS wTopGearTime,
		CASE WHEN ic.IndicatorId = 56 THEN r.DrivingDistance + r.PTOMovingDistance END AS TopGearTimeTotal,
		CASE WHEN ic.IndicatorId = 56 THEN 1 END AS TopGearTimeUsed

	FROM dbo.Reporting r		
		INNER JOIN dbo.Vehicle v ON r.VehicleIntId = v.VehicleIntId
		INNER JOIN dbo.GroupDetail gd ON v.VehicleId = gd.EntityDataId
		INNER JOIN dbo.[Group] g ON gd.GroupId = g.GroupId
		INNER JOIN @VehicleConfig vc ON v.VehicleId = vc.Vid
		INNER JOIN dbo.IndicatorConfig ic ON vc.ReportConfigId = ic.ReportConfigurationId
		LEFT JOIN dbo.ReportingABC abc ON r.VehicleIntId = abc.VehicleIntId AND r.DriverIntId = abc.DriverIntId AND r.Date = abc.Date --AND r.RouteID = abc.RouteId
		LEFT JOIN dbo.ReportingOverspeed ro ON r.VehicleIntId = ro.VehicleIntId AND r.DriverIntId = ro.DriverIntId AND r.Date = ro.Date --AND r.RouteID = ro.RouteId
		LEFT JOIN dbo.ReportingExtra re ON r.VehicleIntId = re.VehicleIntId AND r.DriverIntId = re.DriverIntId AND r.Date = re.Date
	WHERE r.Date BETWEEN @lsdate AND @ledate 
	  AND g.GroupId IN (SELECT Value FROM dbo.Split(@lgids, ','))
	  AND r.DrivingDistance > 0
	  AND ic.Archived = 0
	) raw
GROUP BY raw.GroupId, VehicleId

-- Now determine if the vehicle / group combinations use multiple configurations for each Indicator
DECLARE @ConfigCount TABLE
(
	GroupId UNIQUEIDENTIFIER,
	SweetSpotMix TINYINT,
	FueledOverRPMMix TINYINT,
	TopGearMix TINYINT,
	CruiseMix TINYINT,
	CruiseInTopGearsMix TINYINT,
	CoastInGearMix TINYINT,
	IdleMix TINYINT,
	ServiceBrakeMix TINYINT,
	EngineBrakeMix TINYINT,
	RopMix TINYINT,
	Rop2Mix TINYINT,
	OverSpeedMix TINYINT,
	OverSpeedHighMix TINYINT,
	IVHOverSpeedMix TINYINT,
	CoastOutOfGearMix TINYINT,
	HarshBrakingMix TINYINT,
	AccelerationMix TINYINT,
	BrakingMix TINYINT,
	CorneringMix TINYINT,
	AccelerationLowMix TINYINT,
	BrakingLowMix TINYINT,
	CorneringLowMix TINYINT,
	AccelerationHighMix TINYINT,
	BrakingHighMix TINYINT,
	CorneringHighMix TINYINT,
	ManoeuvresLowMix TINYINT,
	ManoeuvresMedMix TINYINT,
	ORCountMix TINYINT,
	PtoMix TINYINT,
	CruiseTopGearRatioMix TINYINT,
	CruiseOverspeedMix TINYINT,
	TopGearOverspeedMix TINYINT,

		OverspeedCountMix TINYINT,
		OverspeedHighCountMix TINYINT,
		StabilityControlMix TINYINT,
		CollisionWarningLowMix TINYINT,
		CollisionWarningMedMix TINYINT,
		CollisionWarningHighMix TINYINT,
		LaneDepartureDisableMix TINYINT,
		LaneDepartureLeftRightMix TINYINT,
		FatigueMix TINYINT,
		DistractionMix TINYINT,
		SweetSpotTimeMix TINYINT,
		OverRevTimeMix TINYINT,
		TopGearTimeMix TINYINT
)

INSERT INTO @ConfigCount (GroupId, SweetSpotMix, FueledOverRPMMix, TopGearMix, CruiseMix, CruiseInTopGearsMix, CoastInGearMix,
						  IdleMix, ServiceBrakeMix, EngineBrakeMix, RopMix, Rop2Mix, OverSpeedMix, OverSpeedHighMix, IVHOverSpeedMix, CoastOutOfGearMix,
						  HarshBrakingMix, AccelerationMix, BrakingMix, CorneringMix, AccelerationLowMix, BrakingLowMix, CorneringLowMix, 
						  AccelerationHighMix, BrakingHighMix, CorneringHighMix, ManoeuvresLowMix, ManoeuvresMedMix, ORCountMix, PtoMix, CruiseTopGearRatioMix,
						  CruiseOverspeedMix, TopGearOverspeedMix, OverspeedCountMix, OverspeedHighCountMix, StabilityControlMix, CollisionWarningLowMix, CollisionWarningMedMix, 
						  CollisionWarningHighMix, LaneDepartureDisableMix, LaneDepartureLeftRightMix, FatigueMix, DistractionMix, SweetSpotTimeMix, OverRevTimeMix, TopGearTimeMix)
SELECT	GroupId, 
		CASE WHEN SUM(InSweetSpotUsed) > 0 AND SUM(InSweetSpotUsed) != SUM(RCount) THEN 1 ELSE 0 END,
		CASE WHEN SUM(FueledOverRPMUsed) > 0 AND SUM(FueledOverRPMUsed) != SUM(RCount) THEN 1 ELSE 0 END,
		CASE WHEN SUM(TopGearUsed) > 0 AND SUM(TopGearUsed) != SUM(RCount) THEN 1 ELSE 0 END,
		CASE WHEN SUM(CruiseUsed) > 0 AND SUM(CruiseUsed) != SUM(RCount) THEN 1 ELSE 0 END,
		CASE WHEN SUM(CruiseInTopGearsUsed) > 0 AND SUM(CruiseInTopGearsUsed) != SUM(RCount) THEN 1 ELSE 0 END,
		CASE WHEN SUM(CoastInGearUsed) > 0 AND SUM(CoastInGearUsed) != SUM(RCount) THEN 1 ELSE 0 END,
		CASE WHEN SUM(IdleUsed) > 0 AND SUM(IdleUsed) != SUM(RCount) THEN 1 ELSE 0 END,
		CASE WHEN SUM(ServiceBrakeUsed) > 0 AND SUM(ServiceBrakeUsed) != SUM(RCount) THEN 1 ELSE 0 END,
		CASE WHEN SUM(EngineBrakeOverRPMUsed) > 0 AND SUM(EngineBrakeOverRPMUsed) != SUM(RCount) THEN 1 ELSE 0 END,
		CASE WHEN SUM(ROPUsed) > 0 AND SUM(ROPUsed) != SUM(RCount) THEN 1 ELSE 0 END,
		CASE WHEN SUM(ROP2Used) > 0 AND SUM(ROP2Used) != SUM(RCount) THEN 1 ELSE 0 END,
		CASE WHEN SUM(OverSpeedUsed) > 0 AND SUM(OverSpeedUsed) != SUM(RCount) THEN 1 ELSE 0 END,
		CASE WHEN SUM(OverSpeedHighUsed) > 0 AND SUM(OverSpeedHighUsed) != SUM(RCount) THEN 1 ELSE 0 END,
		CASE WHEN SUM(IVHOverSpeedUsed) > 0 AND SUM(IVHOverSpeedUsed) != SUM(RCount) THEN 1 ELSE 0 END,
		CASE WHEN SUM(CoastOutOfGearUsed) > 0 AND SUM(CoastOutOfGearUsed) != SUM(RCount) THEN 1 ELSE 0 END,
		CASE WHEN SUM(PanicStopUsed) > 0 AND SUM(PanicStopUsed) != SUM(RCount) THEN 1 ELSE 0 END,
		CASE WHEN SUM(AccelerationUsed) > 0 AND SUM(AccelerationUsed) != SUM(RCount) THEN 1 ELSE 0 END,
		CASE WHEN SUM(BrakingUsed) > 0 AND SUM(BrakingUsed) != SUM(RCount) THEN 1 ELSE 0 END,
		CASE WHEN SUM(CorneringUsed) > 0 AND SUM(CorneringUsed) != SUM(RCount) THEN 1 ELSE 0 END,
		CASE WHEN SUM(AccelerationLowUsed) > 0 AND SUM(AccelerationLowUsed) != SUM(RCount) THEN 1 ELSE 0 END,
		CASE WHEN SUM(BrakingLowUsed) > 0 AND SUM(BrakinglowUsed) != SUM(RCount) THEN 1 ELSE 0 END,
		CASE WHEN SUM(CorneringLowUsed) > 0 AND SUM(CorneringLowUsed) != SUM(RCount) THEN 1 ELSE 0 END,
		CASE WHEN SUM(AccelerationHighUsed) > 0 AND SUM(AccelerationHighUsed) != SUM(RCount) THEN 1 ELSE 0 END,
		CASE WHEN SUM(BrakingHighUsed) > 0 AND SUM(BrakingHighUsed) != SUM(RCount) THEN 1 ELSE 0 END,
		CASE WHEN SUM(CorneringHighUsed) > 0 AND SUM(CorneringHighUsed) != SUM(RCount) THEN 1 ELSE 0 END,
		CASE WHEN SUM(ManoeuvresLowUsed) > 0 AND SUM(ManoeuvresLowUsed) != SUM(RCount) THEN 1 ELSE 0 END,
		CASE WHEN SUM(ManoeuvresMedUsed) > 0 AND SUM(ManoeuvresMedUsed) != SUM(RCount) THEN 1 ELSE 0 END,
		CASE WHEN SUM(ORCountUsed) > 0 AND SUM(ORCountUsed) != SUM(RCount) THEN 1 ELSE 0 END,
		CASE WHEN SUM(PTOUsed) > 0 AND SUM(PTOUsed) != SUM(RCount) THEN 1 ELSE 0 END,		                                                                 
		CASE WHEN SUM(CruiseTopGearRatioUsed) > 0 AND SUM(CruiseTopGearRatioUsed) != SUM(RCount) THEN 1 ELSE 0 END,
		CASE WHEN SUM(CruiseOverSpeedUsed) > 0 AND SUM(CruiseOverSpeedUsed) != SUM(RCount) THEN 1 ELSE 0 END, 
		CASE WHEN SUM(TopGearOverSpeedUsed) > 0 AND SUM(TopGearOverSpeedUsed) != SUM(RCount) THEN 1 ELSE 0 END,

	CASE WHEN SUM(OverspeedCountUsed) > 0 AND SUM(OverspeedCountUsed) != SUM(RCount) THEN 1 ELSE 0 END,
	CASE WHEN SUM(OverspeedHighCountUsed) > 0 AND SUM(OverspeedHighCountUsed) != SUM(RCount) THEN 1 ELSE 0 END,
	CASE WHEN SUM(StabilityControlUsed) > 0 AND SUM(StabilityControlUsed) != SUM(RCount) THEN 1 ELSE 0 END,
	CASE WHEN SUM(CollisionWarningLowUsed) > 0 AND SUM(CollisionWarningLowUsed) != SUM(RCount) THEN 1 ELSE 0 END,
	CASE WHEN SUM(CollisionWarningMedUsed) > 0 AND SUM(CollisionWarningMedUsed) != SUM(RCount) THEN 1 ELSE 0 END,
	CASE WHEN SUM(CollisionWarningHighUsed) > 0 AND SUM(CollisionWarningHighUsed) != SUM(RCount) THEN 1 ELSE 0 END,
	CASE WHEN SUM(LaneDepartureDisableUsed) > 0 AND SUM(LaneDepartureDisableUsed) != SUM(RCount) THEN 1 ELSE 0 END,
	CASE WHEN SUM(LaneDepartureLeftRightUsed) > 0 AND SUM(LaneDepartureLeftRightUsed) != SUM(RCount) THEN 1 ELSE 0 END,
	CASE WHEN SUM(FatigueUsed) > 0 AND SUM(FatigueUsed) != SUM(RCount) THEN 1 ELSE 0 END,
	CASE WHEN SUM(DistractionUsed) > 0 AND SUM(DistractionUsed) != SUM(RCount) THEN 1 ELSE 0 END,
	CASE WHEN SUM(SweetSpotTimeUsed) > 0 AND SUM(SweetSpotTimeUsed) != SUM(RCount) THEN 1 ELSE 0 END,
	CASE WHEN SUM(OverRevTimeUsed) > 0 AND SUM(OverRevTimeUsed) != SUM(RCount) THEN 1 ELSE 0 END,
	CASE WHEN SUM(TopGearTimeUsed) > 0 AND SUM(TopGearTimeUsed) != SUM(RCount) THEN 1 ELSE 0 END

FROM @weightedData wd
GROUP BY GroupId

DECLARE @data TABLE
	(	GroupId UNIQUEIDENTIFIER,
		GroupName NVARCHAR(200),
		GroupTypeID INT,

		VehicleId UNIQUEIDENTIFIER,	

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

	OverspeedCount FLOAT,
	OverspeedHighCount FLOAT,
	StabilityControl FLOAT,
	CollisionWarningLow FLOAT,
	CollisionWarningMed FLOAT,
	CollisionWarningHigh FLOAT,
	LaneDepartureDisable FLOAT,
	LaneDepartureLeftRight FLOAT,
	Fatigue FLOAT,
	Distraction FLOAT,
	SweetSpotTime FLOAT,
	OverRevTime FLOAT,
	TopGearTime FLOAT,

		SweetSpotComponent FLOAT,
		OverRevWithFuelComponent FLOAT,
		TopGearComponent FLOAT,
		CruiseComponent FLOAT,
		CruiseInTopGearsComponent FLOAT,
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

	OverspeedCountComponent FLOAT,
	OverspeedHighCountComponent FLOAT,
	StabilityControlComponent FLOAT,
	CollisionWarningLowComponent FLOAT,
	CollisionWarningMedComponent FLOAT,
	CollisionWarningHighComponent FLOAT,
	LaneDepartureDisableComponent FLOAT,
	LaneDepartureLeftRightComponent FLOAT,
	FatigueComponent FLOAT,
	DistractionComponent FLOAT,
	SweetSpotTimeComponent FLOAT,
	OverRevTimeComponent FLOAT,
	TopGearTimeComponent FLOAT,

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
		FuelMult FLOAT,
		SweetSpotColour VARCHAR(MAX),
		SweetSpotMix BIT,
		OverRevWithFuelColour VARCHAR(MAX),
		OverRevWithFuelMix BIT,
		TopGearColour VARCHAR(MAX),
		TopGearMix BIT,
		CruiseColour VARCHAR(MAX),
		CruiseMix BIT,
		CruiseInTopGearsColour NVARCHAR(MAX),
		CruiseInTopGearsMix BIT,
		CoastInGearColour VARCHAR(MAX),
		CoastInGearMix BIT,
		IdleColour VARCHAR(MAX),
		IdleMix BIT,
		EngineServiceBrakeColour VARCHAR(MAX),
		EngineServiceBrakeMix BIT,	
		OverRevWithoutFuelColour VARCHAR(MAX),
		OverRevWithoutFuelMix BIT,
		RopColour VARCHAR(MAX),
		RopMix BIT,
		Rop2Colour VARCHAR(MAX),
		Rop2Mix BIT,
		OverSpeedColour VARCHAR(MAX), 
		OverSpeedMix BIT,
		OverSpeedHighColour NVARCHAR(MAX),
		OverSpeedHighMix BIT,
		IVHOverSpeedColour VARCHAR(MAX),
		IVHOverSpeedMix BIT,
		CoastOutOfGearColour VARCHAR(MAX),
		CoastOutOfGearMix BIT,
		HarshBrakingColour VARCHAR(MAX),
		HarshBrakingMix BIT,
		EfficiencyColour VARCHAR(MAX),
		EfficiencyMix BIT,
		SafetyColour VARCHAR(MAX),
		SafetyMix BIT,
		KPLColour VARCHAR(MAX),
		KPLMix BIT,
		Co2Colour VARCHAR(MAX),
		Co2Mix BIT,
		OverSpeedDistanceColour VARCHAR(MAX),
		OverSpeedDistanceMix BIT,
		AccelerationColour VARCHAR(MAX),
		AccelerationMix BIT,
		BrakingColour VARCHAR(MAX),
		BrakingMix BIT,
		CorneringColour VARCHAR(MAX),
		CorneringMix BIT,
		AccelerationLowColour VARCHAR(MAX),
		AccelerationLowMix BIT,
		BrakingLowColour VARCHAR(MAX),
		BrakingLowMix BIT,
		CorneringLowColour VARCHAR(MAX),
		CorneringLowMix BIT,
		AccelerationHighColour VARCHAR(MAX),
		AccelerationHighMix BIT,
		BrakingHighColour VARCHAR(MAX),
		BrakingHighMix BIT,
		CorneringHighColour VARCHAR(MAX),
		CorneringHighMix BIT,
		ManoeuvresLowColour VARCHAR(MAX),
		ManoeuvresLowMix BIT,
		ManoeuvresMedColour VARCHAR(MAX),
		ManoeuvresMedMix BIT,
		CruiseTopGearRatioColour VARCHAR(MAX),
		CruiseTopGearRatioMix BIT,
		OverRevCountColour VARCHAR(MAX),
		OverRevCountMix BIT,
		PtoColour VARCHAR(MAX),
		PtoMix BIT,
		CruiseOverspeedColour VARCHAR(MAX),
		CruiseOverspeedMix BIT,
		TopGearOverspeedColour VARCHAR(MAX),
		TopGearOverspeedMix BIT,
		FuelWastageCostColour VARCHAR(MAX),

	OverspeedCountColour VARCHAR(MAX),
	OverspeedCountMix BIT,
	OverspeedHighCountColour VARCHAR(MAX),
	OverspeedHighCountMix BIT,
	StabilityControlColour VARCHAR(MAX),
	StabilityControlMix BIT,
	CollisionWarningLowColour VARCHAR(MAX),
	CollisionWarningLowMix BIT,
	CollisionWarningMedColour VARCHAR(MAX),
	CollisionWarningMedMix BIT,
	CollisionWarningHighColour VARCHAR(MAX),
	CollisionWarningHighMix BIT,
	LaneDepartureDisableColour VARCHAR(MAX),
	LaneDepartureDisableMix BIT,
	LaneDepartureLeftRightColour VARCHAR(MAX),
	LaneDepartureLeftRightMix BIT,
	FatigueColour VARCHAR(MAX),
	FatigueMix BIT,
	DistractionColour VARCHAR(MAX),
	DistractionMix BIT,
	SweetSpotTimeColour VARCHAR(MAX),
	SweetSpotTimeMix BIT,
	OverRevTimeColour VARCHAR(MAX),
	OverRevTimeMix BIT,
	TopGearTimeColour VARCHAR(MAX),
	TopGearTimeMix BIT
	)

-- Now perform main report processing
INSERT INTO @data
        (GroupId,
         GroupName,
         GroupTypeID,
         VehicleId,
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

	OverspeedCount,
	OverspeedHighCount,
	StabilityControl,
	CollisionWarningLow,
	CollisionWarningMed,
	CollisionWarningHigh,
	LaneDepartureDisable,
	LaneDepartureLeftRight,
	Fatigue,
	Distraction,
	SweetSpotTime,
	OverRevTime,
	TopGearTime,

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
         CruiseOverspeedComponent,
         TopGearOverspeedComponent,

	OverspeedCountComponent,
	OverspeedHighCountComponent,
	StabilityControlComponent,
	CollisionWarningLowComponent,
	CollisionWarningMedComponent,
	CollisionWarningHighComponent,
	LaneDepartureDisableComponent,
	LaneDepartureLeftRightComponent,
	FatigueComponent,
	DistractionComponent,
	SweetSpotTimeComponent,
	OverRevTimeComponent,
	TopGearTimeComponent,

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
         FuelMult,
         SweetSpotColour,
         SweetSpotMix,
         OverRevWithFuelColour,
         OverRevWithFuelMix,
         TopGearColour,
         TopGearMix,
         CruiseColour,
         CruiseMix,
         CruiseInTopGearsColour,
         CruiseInTopGearsMix,
         CoastInGearColour,
         CoastInGearMix,
         IdleColour,
         IdleMix,
         EngineServiceBrakeColour,
         EngineServiceBrakeMix,
         OverRevWithoutFuelColour,
         OverRevWithoutFuelMix,
         RopColour,
         RopMix,
         Rop2Colour,
         Rop2Mix,
         OverSpeedColour,
         OverSpeedMix,
         OverSpeedHighColour,
         OverSpeedHighMix,
         IVHOverSpeedColour,
         IVHOverSpeedMix,
         CoastOutOfGearColour,
         CoastOutOfGearMix,
         HarshBrakingColour,
         HarshBrakingMix,
         EfficiencyColour,
         EfficiencyMix,
         SafetyColour,
         SafetyMix,
         KPLColour,
         KPLMix,
         Co2Colour,
         Co2Mix,
         OverSpeedDistanceColour,
         OverSpeedDistanceMix,
         AccelerationColour,
         AccelerationMix,
         BrakingColour,
         BrakingMix,
         CorneringColour,
         CorneringMix,
         AccelerationLowColour,
         AccelerationLowMix,
         BrakingLowColour,
         BrakingLowMix,
         CorneringLowColour,
         CorneringLowMix,
         AccelerationHighColour,
         AccelerationHighMix,
         BrakingHighColour,
         BrakingHighMix,
         CorneringHighColour,
         CorneringHighMix,
         ManoeuvresLowColour,
         ManoeuvresLowMix,
         ManoeuvresMedColour,
         ManoeuvresMedMix,
         CruiseTopGearRatioColour,
         CruiseTopGearRatioMix,
         OverRevCountColour,
         OverRevCountMix,
         PtoColour,
         PtoMix,
         CruiseOverspeedColour,
         CruiseOverspeedMix,
         TopGearOverspeedColour,
         TopGearOverspeedMix,
         FuelWastageCostColour,
		 
	OverspeedCountColour,
	OverspeedCountMix,
	OverspeedHighCountColour,
	OverspeedHighCountMix,
	StabilityControlColour,
	StabilityControlMix,
	CollisionWarningLowColour,
	CollisionWarningLowMix,
	CollisionWarningMedColour,
	CollisionWarningMedMix,
	CollisionWarningHighColour,
	CollisionWarningHighMix,
	LaneDepartureDisableColour,
	LaneDepartureDisableMix,
	LaneDepartureLeftRightColour,
	LaneDepartureLeftRightMix,
	FatigueColour,
	FatigueMix,
	DistractionColour,
	DistractionMix,
	SweetSpotTimeColour,
	SweetSpotTimeMix,
	OverRevTimeColour,
	OverRevTimeMix,
	TopGearTimeColour,
	TopGearTimeMix
        )
SELECT
		--Group
		
		g.GroupId,
		g.GroupName,
		g.GroupTypeID,

		VehicleId,
		
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

	OverspeedCount,
	OverspeedHighCount,
	StabilityControl,
	CollisionWarningLow,
	CollisionWarningMed,
	CollisionWarningHigh,
	LaneDepartureDisable,
	LaneDepartureLeftRight,
	Fatigue,
	Distraction,
	SweetSpotTime,
	OverRevTime,
	TopGearTime,
		
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
		CruiseOverspeedComponent,
		TopGearOverspeedComponent,

	OverspeedCountComponent,
	OverspeedHighCountComponent,
	StabilityControlComponent,
	CollisionWarningLowComponent,
	CollisionWarningMedComponent,
	CollisionWarningHighComponent,
	LaneDepartureDisableComponent,
	LaneDepartureLeftRightComponent,
	FatigueComponent,
	DistractionComponent,
	SweetSpotTimeComponent,
	OverRevTimeComponent,
	TopGearTimeComponent,

		
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
		--dbo.GYRColourConfig(SweetSpot*100, 1, ISNULL(ReportConfigId, @rprtcfgid)) 
		NULL AS SweetSpotColour, SweetSpotMix,
		--dbo.GYRColourConfig(OverRevWithFuel*100, 2, ISNULL(ReportConfigId, @lrprtcfgid)) 
		NULL AS OverRevWithFuelColour, FueledOverRPMMix AS OverRevWithFuelMix,
		--dbo.GYRColourConfig(TopGear*100, 3, ISNULL(ReportConfigId, @lrprtcfgid)) 
		NULL AS TopGearColour, TopGearMix,
		--dbo.GYRColourConfig(Cruise*100, 4, ISNULL(ReportConfigId, @lrprtcfgid)) 
		NULL AS CruiseColour, CruiseMix,
		--dbo.GYRColourConfig(CruiseInTopGears*100, 31, ISNULL(ReportConfigId, @lrprtcfgid)) 
		NULL AS CruiseInTopGearsColour, CruiseInTopGearsMix,
		--dbo.GYRColourConfig(CoastInGear*100, 5, ISNULL(ReportConfigId, @lrprtcfgid)) 
		NULL AS CoastInGearColour, CoastInGearMix,
		--dbo.GYRColourConfig(Idle*100, 6, ISNULL(ReportConfigId, @lrprtcfgid)) 
		NULL AS IdleColour, IdleMix,
		--dbo.GYRColourConfig(EngineServiceBrake*100, 7, ISNULL(ReportConfigId, @lrprtcfgid)) 
		NULL AS EngineServiceBrakeColour, ServiceBrakeMix AS EngineServiceBrakeMix,
		--dbo.GYRColourConfig(OverRevWithoutFuel*100, 8, ISNULL(ReportConfigId, @lrprtcfgid)) 
		NULL AS OverRevWithoutFuelColour, EngineBrakeMix AS OverRevWithoutFuelMix,
		--dbo.GYRColourConfig(Rop, 9, ISNULL(ReportConfigId, @lrprtcfgid)) 
		NULL AS RopColour, RopMix,
		--dbo.GYRColourConfig(Rop2, 41, ISNULL(ReportConfigId, @lrprtcfgid)) 
		NULL AS Rop2Colour, Rop2Mix,
		--dbo.GYRColourConfig(OverSpeed*100, 10, ISNULL(ReportConfigId, @lrprtcfgid)) 
		NULL AS OverSpeedColour, OverSpeedMix,
		--dbo.GYRColourConfig(OverSpeedHigh*100, 32, ISNULL(ReportConfigId, @lrprtcfgid)) 
		NULL AS OverSpeedHighColour, OverSpeedHighMix,
		--dbo.GYRColourConfig(IVHOverSpeed*100, 30, ISNULL(ReportConfigId, @lrprtcfgid)) 
		NULL AS IVHOverSpeedColour, IVHOverSpeedMix,
		--dbo.GYRColourConfig(CoastOutOfGear*100, 11, ISNULL(ReportConfigId, @lrprtcfgid)) 
		NULL AS CoastOutOfGearColour, CoastOutOfGearMix,
		--dbo.GYRColourConfig(HarshBraking, 12, ISNULL(ReportConfigId, @lrprtcfgid)) 
		NULL AS HarshBrakingColour, HarshBrakingMix,
		--dbo.GYRColourConfig(Efficiency, 14, ISNULL(ReportConfigId, @lrprtcfgid)) 
		NULL AS EfficiencyColour, NULL AS EfficiencyMix,
		--dbo.GYRColourConfig(Safety, 15, ISNULL(ReportConfigId, @lrprtcfgid)) 
		NULL AS SafetyColour, NULL AS SafetyMix,
		--dbo.GYRColourConfig(FuelEcon, 16, ReportConfigId) 
		NULL AS KPLColour, NULL AS KPLMix,
		--dbo.GYRColourConfig(Co2, 20, ReportConfigId) 
		NULL AS Co2Colour, NULL AS Co2Mix,
		--dbo.GYRColourConfig(OverSpeedDistance * 100, 21, ISNULL(ReportConfigId, @lrprtcfgid)) 
		NULL AS OverSpeedDistanceColour, IVHOverSpeedMix AS OverSpeedDistanceMix,
		--dbo.GYRColourConfig(Acceleration, 22, ISNULL(ReportConfigId, @lrprtcfgid)) 
		NULL AS AccelerationColour, AccelerationMix,
		--dbo.GYRColourConfig(Braking, 23, ISNULL(ReportConfigId, @lrprtcfgid)) 
		NULL AS BrakingColour, BrakingMix,
		--dbo.GYRColourConfig(Cornering, 24, ISNULL(ReportConfigId, @lrprtcfgid)) 
		NULL AS CorneringColour, CorneringMix,
		--dbo.GYRColourConfig(AccelerationLow, 33, ISNULL(ReportConfigId, @lrprtcfgid)) 
		NULL AS AccelerationLowColour, AccelerationLowMix,
		--dbo.GYRColourConfig(BrakingLow, 34, ISNULL(ReportConfigId, @lrprtcfgid)) 
		NULL AS BrakingLowColour, BrakingLowMix,
		--dbo.GYRColourConfig(CorneringLow, 35, ISNULL(ReportConfigId, @lrprtcfgid)) 
		NULL AS CorneringLowColour, CorneringLowMix,
		--dbo.GYRColourConfig(AccelerationHigh, 36, ISNULL(ReportConfigId, @lrprtcfgid)) 
		NULL AS AccelerationHighColour, AccelerationHighMix,
		--dbo.GYRColourConfig(BrakingHigh, 37, ISNULL(ReportConfigId, @lrprtcfgid)) 
		NULL AS BrakingHighColour, BrakingHighMix,
		--dbo.GYRColourConfig(CorneringHigh, 38, ISNULL(ReportConfigId, @lrprtcfgid)) 
		NULL AS CorneringHighColour, CorneringHighMix,
		--dbo.GYRColourConfig(ManoeuvresLow, 39, ISNULL(ReportConfigId, @lrprtcfgid)) 
		NULL AS ManoeuvresLowColour, ManoeuvresLowMix,
		--dbo.GYRColourConfig(ManoeuvresMed, 40, ISNULL(ReportConfigId, @lrprtcfgid)) 
		NULL AS ManoeuvresMedColour, ManoeuvresMedMix,
		--dbo.GYRColourConfig(CruiseTopGearRatio*100, 25, ISNULL(ReportConfigId, @lrprtcfgid)) 
		NULL AS CruiseTopGearRatioColour, CruiseTopGearRatioMix,
		--dbo.GYRColourConfig(OverRevCount, 28, ISNULL(ReportConfigId, @lrprtcfgid)) 
		NULL AS OverRevCountColour, ORCountMix AS OverRevCountMix,
		--dbo.GYRColourConfig(Pto*100, 29, ISNULL(ReportConfigId, @lrprtcfgid)) 
		NULL AS PtoColour, PtoMix,
		--dbo.GYRColourConfig(CruiseOverspeed*100, 43, ISNULL(ReportConfigId, @lrprtcfgid)) 
		NULL AS CruiseOverspeedColour, CruiseOverspeedMix,
		--dbo.GYRColourConfig(TopGearOverspeed*100, 42, ISNULL(ReportConfigId, @lrprtcfgid)) 
		NULL AS TopGearOverspeedColour, TopGearOverspeedMix,
		NULL AS FuelWastageCostColour,
		
	NULL AS OverspeedCountColour, OverspeedCountMix,
	NULL AS OverspeedHighCountColour, OverspeedHighCountMix,
	NULL AS StabilityControlColour, StabilityControlMix,
	NULL AS CollisionWarningLowColour, CollisionWarningLowMix,
	NULL AS CollisionWarningMedColour, CollisionWarningMedMix,
	NULL AS CollisionWarningHighColour, CollisionWarningHighMix,
	NULL AS LaneDepartureDisableColour, LaneDepartureDisableMix,
	NULL AS LaneDepartureLeftRightColour, LaneDepartureLeftRightMix,
	NULL AS FatigueColour, FatigueMix,
	NULL AS DistractionColour, DistractionMix,
	NULL AS SweetSpotTimeColour, SweetSpotTimeMix,
	NULL AS OverRevTimeColour, OverRevTimeMix,
	NULL AS TopGearTimeColour, TopGearTimeMix
		
FROM
	(
		SELECT o.*, vc.ReportConfigId,
		
		0 AS Safety,-- = dbo.ScoreByClassAndConfig('S', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, CruiseOverspeed, TopGearOverspeed, ISNULL(vc.ReportConfigId, @lrprtcfgid)),
		0 AS Efficiency,-- = dbo.ScoreByClassAndConfig('E', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, CruiseOverspeed, TopGearOverspeed, ISNULL(vc.ReportConfigId, @lrprtcfgid)),
	
		CASE WHEN ric1.HighLow = 1 THEN 
			CAST(ric1.Weight * (CASE WHEN ric1.Type='P' THEN SweetSpot * 100 ELSE SweetSpot END - ric1.Min) / CASE WHEN (ric1.Max - ric1.Min) = 0 THEN 1 ELSE (ric1.Max - ric1.Min) END AS FLOAT)
		ELSE CASE WHEN ric1.HighLow = 0 THEN 
			CAST(ric1.Weight * (ric1.Min - CASE WHEN ric1.Type='P' THEN SweetSpot * 100 ELSE SweetSpot END) / CASE WHEN (ric1.Min - ric1.Max) = 0 THEN 1 ELSE (ric1.Min - ric1.Max) END  AS FLOAT)
		ELSE 0
		END END AS SweetSpotComponent,
		CASE WHEN ric2.HighLow = 1 THEN 
			CAST(ric2.Weight * (CASE WHEN ric2.Type='P' THEN OverRevWithFuel * 100 ELSE OverRevWithFuel END - ric2.Min) / CASE WHEN (ric2.Max - ric2.Min) = 0 THEN 1 ELSE (ric2.Max - ric2.Min) END AS FLOAT)
		ELSE CASE WHEN ric2.HighLow = 0 THEN 
			CAST(ric2.Weight * (ric2.Min - CASE WHEN ric2.Type='P' THEN OverRevWithFuel * 100 ELSE OverRevWithFuel END) / CASE WHEN (ric2.Min - ric2.Max) = 0 THEN 1 ELSE (ric2.Min - ric2.Max) END  AS FLOAT)
		ELSE 0
		END END AS OverRevWithFuelComponent,
		CASE WHEN ric3.HighLow = 1 THEN 
			CAST(ric3.Weight * (CASE WHEN ric3.Type='P' THEN TopGear * 100 ELSE TopGear END - ric3.Min) / CASE WHEN (ric3.Max - ric3.Min) = 0 THEN 1 ELSE (ric3.Max - ric3.Min) END AS FLOAT)
		ELSE CASE WHEN ric3.HighLow = 0 THEN 
			CAST(ric3.Weight * (ric3.Min - CASE WHEN ric3.Type='P' THEN TopGear * 100 ELSE TopGear END) / CASE WHEN (ric3.Min - ric3.Max) = 0 THEN 1 ELSE (ric3.Min - ric3.Max) END  AS FLOAT)
		ELSE 0
		END END AS TopGearComponent,
		CASE WHEN ric4.HighLow = 1 THEN 
			CAST(ric4.Weight * (CASE WHEN ric4.Type='P' THEN Cruise * 100 ELSE Cruise END - ric4.Min) / CASE WHEN (ric4.Max - ric4.Min) = 0 THEN 1 ELSE (ric4.Max - ric4.Min) END AS FLOAT)
		ELSE CASE WHEN ric4.HighLow = 0 THEN 
			CAST(ric4.Weight * (ric4.Min - CASE WHEN ric4.Type='P' THEN Cruise * 100 ELSE Cruise END) / CASE WHEN (ric4.Min - ric4.Max) = 0 THEN 1 ELSE (ric4.Min - ric4.Max) END  AS FLOAT)
		ELSE 0
		END END AS CruiseComponent,
		CASE WHEN ric31.HighLow = 1 THEN 
			CAST(ric31.Weight * (CASE WHEN ric31.Type='P' THEN CruiseInTopGears * 100 ELSE CruiseInTopGears END - ric31.Min) / CASE WHEN (ric31.Max - ric31.Min) = 0 THEN 1 ELSE (ric31.Max - ric31.Min) END AS FLOAT)
		ELSE CASE WHEN ric31.HighLow = 0 THEN 
			CAST(ric31.Weight * (ric31.Min - CASE WHEN ric31.Type='P' THEN CruiseInTopGears * 100 ELSE CruiseInTopGears END) / CASE WHEN (ric31.Min - ric31.Max) = 0 THEN 1 ELSE (ric31.Min - ric31.Max) END  AS FLOAT)
		ELSE 0
		END END AS CruiseInTopGearsComponent,
		CASE WHEN ric6.HighLow = 1 THEN 
			CAST(ric6.Weight * (CASE WHEN ric6.Type='P' THEN Idle * 100 ELSE Idle END - ric6.Min) / CASE WHEN (ric6.Max - ric6.Min) = 0 THEN 1 ELSE (ric6.Max - ric6.Min) END AS FLOAT)
		ELSE CASE WHEN ric6.HighLow = 0 THEN 
			CAST(ric6.Weight * (ric6.Min - CASE WHEN ric6.Type='P' THEN Idle * 100 ELSE Idle END) / CASE WHEN (ric6.Min - ric6.Max) = 0 THEN 1 ELSE (ric6.Min - ric6.Max) END  AS FLOAT)
		ELSE 0
		END END AS IdleComponent,
		CASE WHEN ric22.HighLow = 1 THEN 
			CAST(ric22.Weight * (CASE WHEN ric22.Type='P' THEN Acceleration * 100 ELSE Acceleration END - ric22.Min) / CASE WHEN (ric22.Max - ric22.Min) = 0 THEN 1 ELSE (ric22.Max - ric22.Min) END AS FLOAT)
		ELSE CASE WHEN ric22.HighLow = 0 THEN 
			CAST(ric22.Weight * (ric22.Min - CASE WHEN ric22.Type='P' THEN Acceleration * 100 ELSE Acceleration END) / CASE WHEN (ric22.Min - ric22.Max) = 0 THEN 1 ELSE (ric22.Min - ric22.Max) END  AS FLOAT)
		ELSE 0
		END END AS AccelerationComponent,
		CASE WHEN ric23.HighLow = 1 THEN 
			CAST(ric23.Weight * (CASE WHEN ric23.Type='P' THEN Braking * 100 ELSE Braking END - ric23.Min) / CASE WHEN (ric23.Max - ric23.Min) = 0 THEN 1 ELSE (ric23.Max - ric23.Min) END AS FLOAT)
		ELSE CASE WHEN ric23.HighLow = 0 THEN 
			CAST(ric23.Weight * (ric23.Min - CASE WHEN ric23.Type='P' THEN Braking * 100 ELSE Braking END) / CASE WHEN (ric23.Min - ric23.Max) = 0 THEN 1 ELSE (ric23.Min - ric23.Max) END  AS FLOAT)
		ELSE 0
		END END AS BrakingComponent,
		CASE WHEN ric24.HighLow = 1 THEN 
			CAST(ric24.Weight * (CASE WHEN ric24.Type='P' THEN Cornering * 100 ELSE Cornering END - ric24.Min) / CASE WHEN (ric24.Max - ric24.Min) = 0 THEN 1 ELSE (ric24.Max - ric24.Min) END AS FLOAT)
		ELSE CASE WHEN ric24.HighLow = 0 THEN 
			CAST(ric24.Weight * (ric24.Min - CASE WHEN ric24.Type='P' THEN Cornering * 100 ELSE Cornering END) / CASE WHEN (ric24.Min - ric24.Max) = 0 THEN 1 ELSE (ric24.Min - ric24.Max) END  AS FLOAT)
		ELSE 0
		END END AS CorneringComponent,
		CASE WHEN ric33.HighLow = 1 THEN 
			CAST(ric33.Weight * (CASE WHEN ric33.Type='P' THEN AccelerationLow * 100 ELSE AccelerationLow END - ric33.Min) / CASE WHEN (ric33.Max - ric33.Min) = 0 THEN 1 ELSE (ric33.Max - ric33.Min) END AS FLOAT)
		ELSE CASE WHEN ric33.HighLow = 0 THEN 
			CAST(ric33.Weight * (ric33.Min - CASE WHEN ric33.Type='P' THEN AccelerationLow * 100 ELSE AccelerationLow END) / CASE WHEN (ric33.Min - ric33.Max) = 0 THEN 1 ELSE (ric33.Min - ric33.Max) END  AS FLOAT)
		ELSE 0
		END END AS AccelerationLowComponent,
		CASE WHEN ric34.HighLow = 1 THEN 
			CAST(ric34.Weight * (CASE WHEN ric34.Type='P' THEN BrakingLow * 100 ELSE BrakingLow END - ric34.Min) / CASE WHEN (ric34.Max - ric34.Min) = 0 THEN 1 ELSE (ric34.Max - ric34.Min) END AS FLOAT)
		ELSE CASE WHEN ric34.HighLow = 0 THEN 
			CAST(ric34.Weight * (ric34.Min - CASE WHEN ric34.Type='P' THEN BrakingLow * 100 ELSE BrakingLow END) / CASE WHEN (ric34.Min - ric34.Max) = 0 THEN 1 ELSE (ric34.Min - ric34.Max) END  AS FLOAT)
		ELSE 0
		END END AS BrakingLowComponent,
		CASE WHEN ric35.HighLow = 1 THEN 
			CAST(ric35.Weight * (CASE WHEN ric35.Type='P' THEN CorneringLow * 100 ELSE CorneringLow END - ric35.Min) / CASE WHEN (ric35.Max - ric35.Min) = 0 THEN 1 ELSE (ric35.Max - ric35.Min) END AS FLOAT)
		ELSE CASE WHEN ric35.HighLow = 0 THEN 
			CAST(ric35.Weight * (ric35.Min - CASE WHEN ric35.Type='P' THEN CorneringLow * 100 ELSE CorneringLow END) / CASE WHEN (ric35.Min - ric35.Max) = 0 THEN 1 ELSE (ric35.Min - ric35.Max) END  AS FLOAT)
		ELSE 0
		END END AS CorneringLowComponent,
		CASE WHEN ric36.HighLow = 1 THEN 
			CAST(ric36.Weight * (CASE WHEN ric36.Type='P' THEN AccelerationHigh * 100 ELSE AccelerationHigh END - ric36.Min) / CASE WHEN (ric36.Max - ric36.Min) = 0 THEN 1 ELSE (ric36.Max - ric36.Min) END AS FLOAT)
		ELSE CASE WHEN ric36.HighLow = 0 THEN 
			CAST(ric36.Weight * (ric36.Min - CASE WHEN ric36.Type='P' THEN AccelerationHigh * 100 ELSE AccelerationHigh END) / CASE WHEN (ric36.Min - ric36.Max) = 0 THEN 1 ELSE (ric36.Min - ric36.Max) END  AS FLOAT)
		ELSE 0
		END END AS AccelerationHighComponent,
		CASE WHEN ric37.HighLow = 1 THEN 
			CAST(ric37.Weight * (CASE WHEN ric37.Type='P' THEN BrakingHigh * 100 ELSE BrakingHigh END - ric37.Min) / CASE WHEN (ric37.Max - ric37.Min) = 0 THEN 1 ELSE (ric37.Max - ric37.Min) END AS FLOAT)
		ELSE CASE WHEN ric37.HighLow = 0 THEN 
			CAST(ric37.Weight * (ric37.Min - CASE WHEN ric37.Type='P' THEN BrakingHigh * 100 ELSE BrakingHigh END) / CASE WHEN (ric37.Min - ric37.Max) = 0 THEN 1 ELSE (ric37.Min - ric37.Max) END  AS FLOAT)
		ELSE 0
		END END AS BrakingHighComponent,
		CASE WHEN ric38.HighLow = 1 THEN 
			CAST(ric38.Weight * (CASE WHEN ric38.Type='P' THEN CorneringHigh * 100 ELSE CorneringHigh END - ric38.Min) / CASE WHEN (ric38.Max - ric38.Min) = 0 THEN 1 ELSE (ric38.Max - ric38.Min) END AS FLOAT)
		ELSE CASE WHEN ric38.HighLow = 0 THEN 
			CAST(ric38.Weight * (ric38.Min - CASE WHEN ric38.Type='P' THEN CorneringHigh * 100 ELSE CorneringHigh END) / CASE WHEN (ric38.Min - ric38.Max) = 0 THEN 1 ELSE (ric38.Min - ric38.Max) END  AS FLOAT)
		ELSE 0
		END END AS CorneringHighComponent,
		CASE WHEN ric39.HighLow = 1 THEN 
			CAST(ric39.Weight * (CASE WHEN ric39.Type='P' THEN (AccelerationLow + BrakingLow + CorneringLow) * 100 ELSE (AccelerationLow + BrakingLow + CorneringLow) END - ric39.Min) / CASE WHEN (ric39.Max - ric39.Min) = 0 THEN 1 ELSE (ric39.Max - ric39.Min) END AS FLOAT)
		ELSE CASE WHEN ric39.HighLow = 0 THEN 
			CAST(ric39.Weight * (ric39.Min - CASE WHEN ric39.Type='P' THEN (AccelerationLow + BrakingLow + CorneringLow) * 100 ELSE (AccelerationLow + BrakingLow + CorneringLow) END) / CASE WHEN (ric39.Min - ric39.Max) = 0 THEN 1 ELSE (ric39.Min - ric39.Max) END  AS FLOAT)
		ELSE 0
		END END AS ManoeuvresLowComponent,
		CASE WHEN ric40.HighLow = 1 THEN 
			CAST(ric40.Weight * (CASE WHEN ric40.Type='P' THEN (Acceleration + Braking + Cornering) * 100 ELSE (Acceleration + Braking + Cornering) END - ric40.Min) / CASE WHEN (ric40.Max - ric40.Min) = 0 THEN 1 ELSE (ric40.Max - ric40.Min) END AS FLOAT)
		ELSE CASE WHEN ric40.HighLow = 0 THEN 
			CAST(ric40.Weight * (ric40.Min - CASE WHEN ric40.Type='P' THEN (Acceleration + Braking + Cornering) * 100 ELSE (Acceleration + Braking + Cornering) END) / CASE WHEN (ric40.Min - ric40.Max) = 0 THEN 1 ELSE (ric40.Min - ric40.Max) END  AS FLOAT)
		ELSE 0
		END END AS ManoeuvresMedComponent,				
		CASE WHEN ric7.HighLow = 1 THEN 
			CAST(ric7.Weight * (CASE WHEN ric7.Type='P' THEN EngineServiceBrake * 100 ELSE EngineServiceBrake END - ric7.Min) / CASE WHEN (ric7.Max - ric7.Min) = 0 THEN 1 ELSE (ric7.Max - ric7.Min) END AS FLOAT)
		ELSE CASE WHEN ric7.HighLow = 0 THEN 
			CAST(ric7.Weight * (ric7.Min - CASE WHEN ric7.Type='P' THEN EngineServiceBrake * 100 ELSE EngineServiceBrake END) / CASE WHEN (ric7.Min - ric7.Max) = 0 THEN 1 ELSE (ric7.Min - ric7.Max) END  AS FLOAT)
		ELSE 0
		END END AS EngineServiceBrakeComponent,
		CASE WHEN ric8.HighLow = 1 THEN 
			CAST(ric8.Weight * (CASE WHEN ric8.Type='P' THEN OverRevWithoutFuel * 100 ELSE OverRevWithoutFuel END - ric8.Min) / CASE WHEN (ric8.Max - ric8.Min) = 0 THEN 1 ELSE (ric8.Max - ric8.Min) END AS FLOAT)
		ELSE CASE WHEN ric8.HighLow = 0 THEN 
			CAST(ric8.Weight * (ric8.Min - CASE WHEN ric8.Type='P' THEN OverRevWithoutFuel * 100 ELSE OverRevWithoutFuel END) / CASE WHEN (ric8.Min - ric8.Max) = 0 THEN 1 ELSE (ric8.Min - ric8.Max) END  AS FLOAT)
		ELSE 0
		END END AS OverRevWithoutFuelComponent,
		CASE WHEN ric9.HighLow = 1 THEN 
			CAST(ric9.Weight * (CASE WHEN ric9.Type='P' THEN Rop * 100 ELSE Rop END - ric9.Min) / CASE WHEN (ric9.Max - ric9.Min) = 0 THEN 1 ELSE (ric9.Max - ric9.Min) END AS FLOAT)
		ELSE CASE WHEN ric9.HighLow = 0 THEN 
			CAST(ric9.Weight * (ric9.Min - CASE WHEN ric9.Type='P' THEN Rop * 100 ELSE Rop END) / CASE WHEN (ric9.Min - ric9.Max) = 0 THEN 1 ELSE (ric9.Min - ric9.Max) END  AS FLOAT)
		ELSE 0
		END END AS RopComponent,
		CASE WHEN ric41.HighLow = 1 THEN 
			CAST(ric41.Weight * (CASE WHEN ric41.Type='P' THEN Rop2 * 100 ELSE Rop2 END - ric41.Min) / CASE WHEN (ric41.Max - ric41.Min) = 0 THEN 1 ELSE (ric41.Max - ric41.Min) END AS FLOAT)
		ELSE CASE WHEN ric41.HighLow = 0 THEN 
			CAST(ric41.Weight * (ric41.Min - CASE WHEN ric41.Type='P' THEN Rop2 * 100 ELSE Rop2 END) / CASE WHEN (ric41.Min - ric41.Max) = 0 THEN 1 ELSE (ric41.Min - ric41.Max) END  AS FLOAT)
		ELSE 0
		END END AS Rop2Component,
		CASE WHEN ric10.HighLow = 1 THEN 
			CAST(ric10.Weight * (CASE WHEN ric10.Type='P' THEN OverSpeed * 100 ELSE OverSpeed END - ric10.Min) / CASE WHEN (ric10.Max - ric10.Min) = 0 THEN 1 ELSE (ric10.Max - ric10.Min) END AS FLOAT)
		ELSE CASE WHEN ric10.HighLow = 0 THEN 
			CAST(ric10.Weight * (ric10.Min - CASE WHEN ric10.Type='P' THEN OverSpeed * 100 ELSE OverSpeed END) / CASE WHEN (ric10.Min - ric10.Max) = 0 THEN 1 ELSE (ric10.Min - ric10.Max) END  AS FLOAT)
		ELSE 0
		END END AS OverSpeedComponent,
		CASE WHEN ric32.HighLow = 1 THEN 
			CAST(ric32.Weight * (CASE WHEN ric32.Type='P' THEN OverSpeedHigh * 100 ELSE OverSpeedHigh END - ric32.Min) / CASE WHEN (ric32.Max - ric32.Min) = 0 THEN 1 ELSE (ric32.Max - ric32.Min) END AS FLOAT)
		ELSE CASE WHEN ric32.HighLow = 0 THEN 
			CAST(ric32.Weight * (ric32.Min - CASE WHEN ric32.Type='P' THEN OverSpeedHigh * 100 ELSE OverSpeedHigh END) / CASE WHEN (ric32.Min - ric32.Max) = 0 THEN 1 ELSE (ric32.Min - ric32.Max) END  AS FLOAT)
		ELSE 0
		END END AS OverSpeedHighComponent,
		CASE WHEN ric21.HighLow = 1 THEN 
			CAST(ric21.Weight * (CASE WHEN ric21.Type='P' THEN OverSpeedDistance * 100 ELSE OverSpeedDistance END - ric21.Min) / CASE WHEN (ric21.Max - ric21.Min) = 0 THEN 1 ELSE (ric21.Max - ric21.Min) END AS FLOAT)
		ELSE CASE WHEN ric21.HighLow = 0 THEN 
			CAST(ric21.Weight * (ric21.Min - CASE WHEN ric21.Type='P' THEN OverSpeedDistance * 100 ELSE OverSpeedDistance END) / CASE WHEN (ric21.Min - ric21.Max) = 0 THEN 1 ELSE (ric21.Min - ric21.Max) END  AS FLOAT)
		ELSE 0
		END END AS OverSpeedDistanceComponent,
		CASE WHEN ric30.HighLow = 1 THEN 
			CAST(ric30.Weight * (CASE WHEN ric30.Type='P' THEN IVHOverSpeed * 100 ELSE IVHOverSpeed END - ric30.Min) / CASE WHEN (ric30.Max - ric30.Min) = 0 THEN 1 ELSE (ric30.Max - ric30.Min) END AS FLOAT)
		ELSE CASE WHEN ric30.HighLow = 0 THEN 
			CAST(ric30.Weight * (ric30.Min - CASE WHEN ric30.Type='P' THEN IVHOverSpeed * 100 ELSE IVHOverSpeed END) / CASE WHEN (ric30.Min - ric30.Max) = 0 THEN 1 ELSE (ric30.Min - ric30.Max) END  AS FLOAT)
		ELSE 0
		END END AS IVHOverSpeedComponent,
		CASE WHEN ric11.HighLow = 1 THEN 
			CAST(ric11.Weight * (CASE WHEN ric11.Type='P' THEN CoastOutOfGear * 100 ELSE CoastOutOfGear END - ric11.Min) / CASE WHEN (ric11.Max - ric11.Min) = 0 THEN 1 ELSE (ric11.Max - ric11.Min) END AS FLOAT)
		ELSE CASE WHEN ric11.HighLow = 0 THEN 
			CAST(ric11.Weight * (ric11.Min - CASE WHEN ric11.Type='P' THEN CoastOutOfGear * 100 ELSE CoastOutOfGear END) / CASE WHEN (ric11.Min - ric11.Max) = 0 THEN 1 ELSE (ric11.Min - ric11.Max) END  AS FLOAT)
		ELSE 0
		END END AS CoastOutOfGearComponent,
		CASE WHEN ric12.HighLow = 1 THEN 
			CAST(ric12.Weight * (CASE WHEN ric12.Type='P' THEN HarshBraking * 100 ELSE HarshBraking END - ric12.Min) / CASE WHEN (ric12.Max - ric12.Min) = 0 THEN 1 ELSE (ric12.Max - ric12.Min) END AS FLOAT)
		ELSE CASE WHEN ric12.HighLow = 0 THEN 
			CAST(ric12.Weight * (ric12.Min - CASE WHEN ric12.Type='P' THEN HarshBraking * 100 ELSE HarshBraking END) / CASE WHEN (ric12.Min - ric12.Max) = 0 THEN 1 ELSE (ric12.Min - ric12.Max) END  AS FLOAT)
		ELSE 0
		END END AS HarshBrakingComponent,
		CASE WHEN ric43.HighLow = 1 THEN 
			CAST(ric43.Weight * (CASE WHEN ric43.Type='P' THEN CruiseOverspeed * 100 ELSE CruiseOverspeed END - ric43.Min) / CASE WHEN (ric43.Max - ric43.Min) = 0 THEN 1 ELSE (ric43.Max - ric43.Min) END AS FLOAT)
		ELSE CASE WHEN ric43.HighLow = 0 THEN 
			CAST(ric43.Weight * (ric43.Min - CASE WHEN ric43.Type='P' THEN CruiseOverspeed * 100 ELSE CruiseOverspeed END) / CASE WHEN (ric43.Min - ric43.Max) = 0 THEN 1 ELSE (ric43.Min - ric43.Max) END  AS FLOAT)
		ELSE 0
		END END AS CruiseOverspeedComponent,
		CASE WHEN ric42.HighLow = 1 THEN 
			CAST(ric42.Weight * (CASE WHEN ric42.Type='P' THEN TopGearOverspeed * 100 ELSE TopGearOverspeed END - ric42.Min) / CASE WHEN (ric42.Max - ric42.Min) = 0 THEN 1 ELSE (ric42.Max - ric42.Min) END AS FLOAT)
		ELSE CASE WHEN ric42.HighLow = 0 THEN 
			CAST(ric42.Weight * (ric42.Min - CASE WHEN ric42.Type='P' THEN TopGearOverspeed * 100 ELSE TopGearOverspeed END) / CASE WHEN (ric42.Min - ric42.Max) = 0 THEN 1 ELSE (ric42.Min - ric42.Max) END  AS FLOAT)
		ELSE 0
		END END AS TopGearOverspeedComponent,

		CASE WHEN ric46.HighLow = 1 THEN 
			CAST(ric46.Weight * (CASE WHEN ric46.Type='P' THEN OverspeedCount * 100 ELSE OverspeedCount END - ric46.Min) / CASE WHEN (ric46.Max - ric46.Min) = 0 THEN 1 ELSE (ric46.Max - ric46.Min) END AS FLOAT)
		ELSE CASE WHEN ric46.HighLow = 0 THEN 
			CAST(ric46.Weight * (ric46.Min - CASE WHEN ric46.Type='P' THEN OverspeedCount * 100 ELSE OverspeedCount END) / CASE WHEN (ric46.Min - ric46.Max) = 0 THEN 1 ELSE (ric46.Min - ric46.Max) END  AS FLOAT)
		ELSE 0
		END END AS OverspeedCountComponent,
		CASE WHEN ric47.HighLow = 1 THEN 
			CAST(ric47.Weight * (CASE WHEN ric47.Type='P' THEN OverspeedHighCount * 100 ELSE OverspeedHighCount END - ric47.Min) / CASE WHEN (ric47.Max - ric47.Min) = 0 THEN 1 ELSE (ric47.Max - ric47.Min) END AS FLOAT)
		ELSE CASE WHEN ric47.HighLow = 0 THEN 
			CAST(ric47.Weight * (ric47.Min - CASE WHEN ric47.Type='P' THEN OverspeedHighCount * 100 ELSE OverspeedHighCount END) / CASE WHEN (ric47.Min - ric47.Max) = 0 THEN 1 ELSE (ric47.Min - ric47.Max) END  AS FLOAT)
		ELSE 0
		END END AS OverspeedHighCountComponent,
		CASE WHEN ric48.HighLow = 1 THEN 
			CAST(ric48.Weight * (CASE WHEN ric48.Type='P' THEN StabilityControl * 100 ELSE StabilityControl END - ric48.Min) / CASE WHEN (ric48.Max - ric48.Min) = 0 THEN 1 ELSE (ric48.Max - ric48.Min) END AS FLOAT)
		ELSE CASE WHEN ric48.HighLow = 0 THEN 
			CAST(ric48.Weight * (ric48.Min - CASE WHEN ric48.Type='P' THEN StabilityControl * 100 ELSE StabilityControl END) / CASE WHEN (ric48.Min - ric48.Max) = 0 THEN 1 ELSE (ric48.Min - ric48.Max) END  AS FLOAT)
		ELSE 0
		END END AS StabilityControlComponent,
		CASE WHEN ric49.HighLow = 1 THEN 
			CAST(ric49.Weight * (CASE WHEN ric49.Type='P' THEN CollisionWarningLow * 100 ELSE CollisionWarningLow END - ric49.Min) / CASE WHEN (ric49.Max - ric49.Min) = 0 THEN 1 ELSE (ric49.Max - ric49.Min) END AS FLOAT)
		ELSE CASE WHEN ric49.HighLow = 0 THEN 
			CAST(ric49.Weight * (ric49.Min - CASE WHEN ric49.Type='P' THEN CollisionWarningLow * 100 ELSE CollisionWarningLow END) / CASE WHEN (ric49.Min - ric49.Max) = 0 THEN 1 ELSE (ric49.Min - ric49.Max) END  AS FLOAT)
		ELSE 0
		END END AS CollisionWarningLowComponent,
		CASE WHEN ric50.HighLow = 1 THEN 
			CAST(ric50.Weight * (CASE WHEN ric50.Type='P' THEN CollisionWarningMed * 100 ELSE CollisionWarningMed END - ric50.Min) / CASE WHEN (ric50.Max - ric50.Min) = 0 THEN 1 ELSE (ric50.Max - ric50.Min) END AS FLOAT)
		ELSE CASE WHEN ric50.HighLow = 0 THEN 
			CAST(ric50.Weight * (ric50.Min - CASE WHEN ric50.Type='P' THEN CollisionWarningMed * 100 ELSE CollisionWarningMed END) / CASE WHEN (ric50.Min - ric50.Max) = 0 THEN 1 ELSE (ric50.Min - ric50.Max) END  AS FLOAT)
		ELSE 0
		END END AS CollisionWarningMedComponent,
		CASE WHEN ric51.HighLow = 1 THEN 
			CAST(ric51.Weight * (CASE WHEN ric51.Type='P' THEN CollisionWarningHigh * 100 ELSE CollisionWarningHigh END - ric51.Min) / CASE WHEN (ric51.Max - ric51.Min) = 0 THEN 1 ELSE (ric51.Max - ric51.Min) END AS FLOAT)
		ELSE CASE WHEN ric51.HighLow = 0 THEN 
			CAST(ric51.Weight * (ric51.Min - CASE WHEN ric51.Type='P' THEN CollisionWarningHigh * 100 ELSE CollisionWarningHigh END) / CASE WHEN (ric51.Min - ric51.Max) = 0 THEN 1 ELSE (ric51.Min - ric51.Max) END  AS FLOAT)
		ELSE 0
		END END AS CollisionWarningHighComponent,
		CASE WHEN ric52.HighLow = 1 THEN 
			CAST(ric52.Weight * (CASE WHEN ric52.Type='P' THEN LaneDepartureDisable * 100 ELSE LaneDepartureDisable END - ric52.Min) / CASE WHEN (ric52.Max - ric52.Min) = 0 THEN 1 ELSE (ric52.Max - ric52.Min) END AS FLOAT)
		ELSE CASE WHEN ric52.HighLow = 0 THEN 
			CAST(ric52.Weight * (ric52.Min - CASE WHEN ric52.Type='P' THEN LaneDepartureDisable * 100 ELSE LaneDepartureDisable END) / CASE WHEN (ric52.Min - ric52.Max) = 0 THEN 1 ELSE (ric52.Min - ric52.Max) END  AS FLOAT)
		ELSE 0
		END END AS LaneDepartureDisableComponent,
		CASE WHEN ric53.HighLow = 1 THEN 
			CAST(ric53.Weight * (CASE WHEN ric53.Type='P' THEN LaneDepartureLeftRight * 100 ELSE LaneDepartureLeftRight END - ric53.Min) / CASE WHEN (ric53.Max - ric53.Min) = 0 THEN 1 ELSE (ric53.Max - ric53.Min) END AS FLOAT)
		ELSE CASE WHEN ric53.HighLow = 0 THEN 
			CAST(ric53.Weight * (ric53.Min - CASE WHEN ric53.Type='P' THEN LaneDepartureLeftRight * 100 ELSE LaneDepartureLeftRight END) / CASE WHEN (ric53.Min - ric53.Max) = 0 THEN 1 ELSE (ric53.Min - ric53.Max) END  AS FLOAT)
		ELSE 0
		END END AS LaneDepartureLeftRightComponent,
		CASE WHEN ric57.HighLow = 1 THEN 
			CAST(ric57.Weight * (CASE WHEN ric57.Type='P' THEN Fatigue * 100 ELSE Fatigue END - ric57.Min) / CASE WHEN (ric57.Max - ric57.Min) = 0 THEN 1 ELSE (ric57.Max - ric57.Min) END AS FLOAT)
		ELSE CASE WHEN ric57.HighLow = 0 THEN 
			CAST(ric57.Weight * (ric57.Min - CASE WHEN ric57.Type='P' THEN Fatigue * 100 ELSE Fatigue END) / CASE WHEN (ric57.Min - ric57.Max) = 0 THEN 1 ELSE (ric57.Min - ric57.Max) END  AS FLOAT)
		ELSE 0
		END END AS FatigueComponent,
		CASE WHEN ric58.HighLow = 1 THEN 
			CAST(ric58.Weight * (CASE WHEN ric58.Type='P' THEN Distraction * 100 ELSE Distraction END - ric58.Min) / CASE WHEN (ric58.Max - ric58.Min) = 0 THEN 1 ELSE (ric58.Max - ric58.Min) END AS FLOAT)
		ELSE CASE WHEN ric58.HighLow = 0 THEN 
			CAST(ric58.Weight * (ric58.Min - CASE WHEN ric58.Type='P' THEN Distraction * 100 ELSE Distraction END) / CASE WHEN (ric58.Min - ric58.Max) = 0 THEN 1 ELSE (ric58.Min - ric58.Max) END  AS FLOAT)
		ELSE 0
		END END AS DistractionComponent,
		CASE WHEN ric54.HighLow = 1 THEN 
			CAST(ric54.Weight * (CASE WHEN ric54.Type='P' THEN SweetSpotTime * 100 ELSE SweetSpotTime END - ric54.Min) / CASE WHEN (ric54.Max - ric54.Min) = 0 THEN 1 ELSE (ric54.Max - ric54.Min) END AS FLOAT)
		ELSE CASE WHEN ric54.HighLow = 0 THEN 
			CAST(ric54.Weight * (ric54.Min - CASE WHEN ric54.Type='P' THEN SweetSpotTime * 100 ELSE SweetSpotTime END) / CASE WHEN (ric54.Min - ric54.Max) = 0 THEN 1 ELSE (ric54.Min - ric54.Max) END  AS FLOAT)
		ELSE 0
		END END AS SweetSpotTimeComponent,
		CASE WHEN ric55.HighLow = 1 THEN 
			CAST(ric55.Weight * (CASE WHEN ric55.Type='P' THEN OverRevTime * 100 ELSE OverRevTime END - ric55.Min) / CASE WHEN (ric55.Max - ric55.Min) = 0 THEN 1 ELSE (ric55.Max - ric55.Min) END AS FLOAT)
		ELSE CASE WHEN ric55.HighLow = 0 THEN 
			CAST(ric55.Weight * (ric42.Min - CASE WHEN ric42.Type='P' THEN OverRevTime * 100 ELSE OverRevTime END) / CASE WHEN (ric42.Min - ric42.Max) = 0 THEN 1 ELSE (ric42.Min - ric42.Max) END  AS FLOAT)
		ELSE 0
		END END AS OverRevTimeComponent,
		CASE WHEN ric56.HighLow = 1 THEN 
			CAST(ric56.Weight * (CASE WHEN ric56.Type='P' THEN TopGearTime * 100 ELSE TopGearTime END - ric56.Min) / CASE WHEN (ric56.Max - ric56.Min) = 0 THEN 1 ELSE (ric56.Max - ric56.Min) END AS FLOAT)
		ELSE CASE WHEN ric56.HighLow = 0 THEN 
			CAST(ric56.Weight * (ric56.Min - CASE WHEN ric56.Type='P' THEN TopGearTime * 100 ELSE TopGearTime END) / CASE WHEN (ric56.Min - ric56.Max) = 0 THEN 1 ELSE (ric56.Min - ric56.Max) END  AS FLOAT)
		ELSE 0
		END END AS TopGearTimeComponent

	FROM
		(SELECT
			CASE WHEN (GROUPING(vg.GroupId) = 1) THEN NULL
				ELSE ISNULL(vg.GroupId, NULL)
			END AS GroupId,

			CASE WHEN (GROUPING(v.VehicleId) = 1) THEN NULL
				ELSE ISNULL(v.VehicleId, NULL)
			END AS VehicleId,

			-- For each component use the weighted value rather than the Reporting value so that vehicle configs have been accounted for
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
			ISNULL((SUM(wTotalFuel) * 2639.1 * @co2mult) / dbo.ZeroYieldNull(SUM(FuelEconTotal)),0) AS Co2, --@co2mult: 1 for g/km, 1.6 for g/miles
			SUM(wServiceBrakeDistance) / dbo.ZeroYieldNull(SUM(ServiceBrakeTotal)) AS ServiceBrakeUsage,
			ISNULL(SUM(EngineBrakeDistance) / dbo.ZeroYieldNull(SUM(ServiceBrakeDistance + EngineBrakeDistance)),0) AS EngineServiceBrake,
			ISNULL(SUM(wEngineBrakeOverRPMDistance) / dbo.ZeroYieldNull(SUM(EngineBrakeOverRPMTotal)), 0) AS OverRevWithoutFuel,
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

				ISNULL((SUM(wOverspeedCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(OverspeedCountTotal) * @distmult * 1000))))),0) AS OverspeedCount,
				ISNULL((SUM(wOverspeedHighCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(OverspeedHighCountTotal) * @distmult * 1000))))),0) AS OverspeedHighCount,
				ISNULL((SUM(wStabilityControl) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(StabilityControlTotal) * @distmult * 1000))))),0) AS StabilityControl,
				ISNULL((SUM(wCollisionWarningLow) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(CollisionWarningLowTotal) * @distmult * 1000))))),0) AS CollisionWarningLow,
				ISNULL((SUM(wCollisionWarningMed) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(CollisionWarningMedTotal) * @distmult * 1000))))),0) AS CollisionWarningMed,
				ISNULL((SUM(wCollisionWarningHigh) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(CollisionWarningHighTotal) * @distmult * 1000))))),0) AS CollisionWarningHigh,
				ISNULL((SUM(wLaneDepartureDisable) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(LaneDepartureDisableTotal) * @distmult * 1000))))),0) AS LaneDepartureDisable,
				ISNULL((SUM(wLaneDepartureLeftRight) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(LaneDepartureLeftRightTotal) * @distmult * 1000))))),0) AS LaneDepartureLeftRight,
				ISNULL((SUM(wFatigue) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(FatigueTotal) * @distmult * 1000))))),0) AS Fatigue,
				ISNULL((SUM(wDistraction) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DistractionTotal) * @distmult * 1000))))),0) AS Distraction,
				CAST(SUM(wSweetSpotTime) AS float) / dbo.ZeroYieldNull(SUM(SweetSpotTimeTotal)) AS SweetSpotTime,
				CAST(SUM(wOverRevTime) AS float) / dbo.ZeroYieldNull(SUM(OverRevTimeTotal)) AS OverRevTime,
				CAST(SUM(wTopGearTime) AS float) / dbo.ZeroYieldNull(SUM(TopGearTimeTotal)) AS TopGearTime,

			(CASE WHEN @fuelmult = 0.1 THEN
				(CASE WHEN SUM(wTotalFuel)=0 THEN NULL ELSE SUM(wTotalFuel * ISNULL(FuelMultiplier,1.0))*100 END)/SUM(FuelEconTotal) 
			ELSE
				(SUM(FuelEconTotal) * 1000) / (CASE WHEN SUM(wTotalFuel)=0 THEN NULL ELSE SUM(wTotalFuel * ISNULL(FuelMultiplier,1.0)) END) * @fuelmult END) AS FuelEcon,
			
			SUM(DrivingDistance * 1000 * @distmult) AS TotalDrivingDistance,
			SUM(TotalTime) AS TotalTime				
		FROM dbo.Reporting r
			INNER JOIN dbo.Vehicle v ON r.VehicleIntId = v.VehicleIntId
			INNER JOIN dbo.GroupDetail vgd ON v.VehicleId = vgd.EntityDataId
			INNER JOIN dbo.[Group] vg ON vgd.GroupId = vg.GroupId
			INNER JOIN @weightedData w ON vg.GroupId = w.GroupId AND w.VehicleId = v.VehicleId
			LEFT JOIN @VehicleConfig vc ON vc.Vid = v.VehicleId
			LEFT JOIN dbo.ReportingABC abc ON r.VehicleIntId = abc.VehicleIntId AND r.DriverIntId = abc.DriverIntId AND r.Date = abc.Date --AND r.RouteID = abc.RouteId
			LEFT JOIN dbo.ReportingOverspeed ro ON r.VehicleIntId = ro.VehicleIntId AND r.DriverIntId = ro.DriverIntId AND r.Date = ro.Date --AND r.RouteID = ro.RouteId
			-- LEFT JOIN to TAN_EntityCheckOut to excluded data for days where a vehicle is checked out during that day
			LEFT JOIN dbo.TAN_EntityCheckOut tec ON v.VehicleId = tec.EntityId 
												  AND FLOOR(CAST(r.Date AS FLOAT)) BETWEEN FLOOR(CAST(tec.CheckOutDateTime AS FLOAT)) AND FLOOR(CAST(tec.CheckInDateTime AS FLOAT))
												  AND tec.CheckOutReason NOT IN ('Defrosting','Abtauen','Dégelé','Sbrinare')

		WHERE r.Date BETWEEN @lsdate AND @ledate 
			AND (v.VehicleId IN (SELECT Value FROM dbo.Split(@lvids, ',')) OR @lvids IS NULL)
			AND r.DrivingDistance > 0
			AND vg.IsParameter = 0 
			AND vg.Archived = 0 
			AND vg.GroupId IN (SELECT Value FROM dbo.Split(@lgids, ','))
		    AND tec.EntityCheckOutId IS NULL -- exclude data for checked out periods	
		GROUP BY vg.GroupId, v.VehicleId WITH CUBE
		HAVING SUM(DrivingDistance) > 10 ) o

	LEFT JOIN @VehicleConfig vc ON o.VehicleId = vc.Vid

	LEFT JOIN dbo.ReportIndicatorConfig ric1 ON ric1.ReportConfigurationId = vc.ReportConfigId AND ric1.IndicatorId = 1
	LEFT JOIN dbo.ReportIndicatorConfig ric2 ON ric2.ReportConfigurationId = vc.ReportConfigId AND ric2.IndicatorId = 2
	LEFT JOIN dbo.ReportIndicatorConfig ric3 ON ric3.ReportConfigurationId = vc.ReportConfigId AND ric3.IndicatorId = 3
	LEFT JOIN dbo.ReportIndicatorConfig ric4 ON ric4.ReportConfigurationId = vc.ReportConfigId AND ric4.IndicatorId = 4
	LEFT JOIN dbo.ReportIndicatorConfig ric5 ON ric5.ReportConfigurationId = vc.ReportConfigId AND ric5.IndicatorId = 5
	LEFT JOIN dbo.ReportIndicatorConfig ric6 ON ric6.ReportConfigurationId = vc.ReportConfigId AND ric6.IndicatorId = 6
	LEFT JOIN dbo.ReportIndicatorConfig ric7 ON ric7.ReportConfigurationId = vc.ReportConfigId AND ric7.IndicatorId = 7
	LEFT JOIN dbo.ReportIndicatorConfig ric8 ON ric8.ReportConfigurationId = vc.ReportConfigId AND ric8.IndicatorId = 8
	LEFT JOIN dbo.ReportIndicatorConfig ric9 ON ric9.ReportConfigurationId = vc.ReportConfigId AND ric9.IndicatorId = 9
	LEFT JOIN dbo.ReportIndicatorConfig ric10 ON ric10.ReportConfigurationId = vc.ReportConfigId AND ric10.IndicatorId = 10
	LEFT JOIN dbo.ReportIndicatorConfig ric11 ON ric11.ReportConfigurationId = vc.ReportConfigId AND ric11.IndicatorId = 11
	LEFT JOIN dbo.ReportIndicatorConfig ric12 ON ric12.ReportConfigurationId = vc.ReportConfigId AND ric12.IndicatorId = 12
	LEFT JOIN dbo.ReportIndicatorConfig ric14 ON ric14.ReportConfigurationId = vc.ReportConfigId AND ric14.IndicatorId = 14
	LEFT JOIN dbo.ReportIndicatorConfig ric15 ON ric15.ReportConfigurationId = vc.ReportConfigId AND ric15.IndicatorId = 15
	LEFT JOIN dbo.ReportIndicatorConfig ric16 ON ric16.ReportConfigurationId = vc.ReportConfigId AND ric16.IndicatorId = 16
	LEFT JOIN dbo.ReportIndicatorConfig ric20 ON ric20.ReportConfigurationId = vc.ReportConfigId AND ric20.IndicatorId = 20
	LEFT JOIN dbo.ReportIndicatorConfig ric21 ON ric21.ReportConfigurationId = vc.ReportConfigId AND ric21.IndicatorId = 21
	LEFT JOIN dbo.ReportIndicatorConfig ric22 ON ric22.ReportConfigurationId = vc.ReportConfigId AND ric22.IndicatorId = 22
	LEFT JOIN dbo.ReportIndicatorConfig ric23 ON ric23.ReportConfigurationId = vc.ReportConfigId AND ric23.IndicatorId = 23
	LEFT JOIN dbo.ReportIndicatorConfig ric24 ON ric24.ReportConfigurationId = vc.ReportConfigId AND ric24.IndicatorId = 24
	LEFT JOIN dbo.ReportIndicatorConfig ric25 ON ric25.ReportConfigurationId = vc.ReportConfigId AND ric25.IndicatorId = 25
	LEFT JOIN dbo.ReportIndicatorConfig ric28 ON ric28.ReportConfigurationId = vc.ReportConfigId AND ric28.IndicatorId = 28
	LEFT JOIN dbo.ReportIndicatorConfig ric29 ON ric29.ReportConfigurationId = vc.ReportConfigId AND ric29.IndicatorId = 29
	LEFT JOIN dbo.ReportIndicatorConfig ric30 ON ric30.ReportConfigurationId = vc.ReportConfigId AND ric30.IndicatorId = 30
	LEFT JOIN dbo.ReportIndicatorConfig ric31 ON ric31.ReportConfigurationId = vc.ReportConfigId AND ric31.IndicatorId = 31
	LEFT JOIN dbo.ReportIndicatorConfig ric32 ON ric32.ReportConfigurationId = vc.ReportConfigId AND ric32.IndicatorId = 32
	LEFT JOIN dbo.ReportIndicatorConfig ric33 ON ric33.ReportConfigurationId = vc.ReportConfigId AND ric33.IndicatorId = 33
	LEFT JOIN dbo.ReportIndicatorConfig ric34 ON ric34.ReportConfigurationId = vc.ReportConfigId AND ric34.IndicatorId = 34
	LEFT JOIN dbo.ReportIndicatorConfig ric35 ON ric35.ReportConfigurationId = vc.ReportConfigId AND ric35.IndicatorId = 35
	LEFT JOIN dbo.ReportIndicatorConfig ric36 ON ric36.ReportConfigurationId = vc.ReportConfigId AND ric36.IndicatorId = 36
	LEFT JOIN dbo.ReportIndicatorConfig ric37 ON ric37.ReportConfigurationId = vc.ReportConfigId AND ric37.IndicatorId = 37
	LEFT JOIN dbo.ReportIndicatorConfig ric38 ON ric38.ReportConfigurationId = vc.ReportConfigId AND ric38.IndicatorId = 38
	LEFT JOIN dbo.ReportIndicatorConfig ric39 ON ric39.ReportConfigurationId = vc.ReportConfigId AND ric39.IndicatorId = 39
	LEFT JOIN dbo.ReportIndicatorConfig ric40 ON ric40.ReportConfigurationId = vc.ReportConfigId AND ric40.IndicatorId = 40
	LEFT JOIN dbo.ReportIndicatorConfig ric41 ON ric41.ReportConfigurationId = vc.ReportConfigId AND ric41.IndicatorId = 41
	LEFT JOIN dbo.ReportIndicatorConfig ric42 ON ric42.ReportConfigurationId = vc.ReportConfigId AND ric42.IndicatorId = 42
	LEFT JOIN dbo.ReportIndicatorConfig ric43 ON ric43.ReportConfigurationId = vc.ReportConfigId AND ric43.IndicatorId = 43

	LEFT JOIN dbo.ReportIndicatorConfig ric46 ON ric46.ReportConfigurationId = vc.ReportConfigId AND ric46.IndicatorId = 46
	LEFT JOIN dbo.ReportIndicatorConfig ric47 ON ric47.ReportConfigurationId = vc.ReportConfigId AND ric47.IndicatorId = 47
	LEFT JOIN dbo.ReportIndicatorConfig ric48 ON ric48.ReportConfigurationId = vc.ReportConfigId AND ric48.IndicatorId = 48
	LEFT JOIN dbo.ReportIndicatorConfig ric49 ON ric49.ReportConfigurationId = vc.ReportConfigId AND ric49.IndicatorId = 49
	LEFT JOIN dbo.ReportIndicatorConfig ric50 ON ric50.ReportConfigurationId = vc.ReportConfigId AND ric50.IndicatorId = 50
	LEFT JOIN dbo.ReportIndicatorConfig ric51 ON ric51.ReportConfigurationId = vc.ReportConfigId AND ric51.IndicatorId = 51
	LEFT JOIN dbo.ReportIndicatorConfig ric52 ON ric52.ReportConfigurationId = vc.ReportConfigId AND ric52.IndicatorId = 52
	LEFT JOIN dbo.ReportIndicatorConfig ric53 ON ric53.ReportConfigurationId = vc.ReportConfigId AND ric53.IndicatorId = 53
	LEFT JOIN dbo.ReportIndicatorConfig ric54 ON ric54.ReportConfigurationId = vc.ReportConfigId AND ric54.IndicatorId = 54
	LEFT JOIN dbo.ReportIndicatorConfig ric55 ON ric55.ReportConfigurationId = vc.ReportConfigId AND ric55.IndicatorId = 55
	LEFT JOIN dbo.ReportIndicatorConfig ric56 ON ric56.ReportConfigurationId = vc.ReportConfigId AND ric56.IndicatorId = 56
	LEFT JOIN dbo.ReportIndicatorConfig ric57 ON ric57.ReportConfigurationId = vc.ReportConfigId AND ric57.IndicatorId = 57
	LEFT JOIN dbo.ReportIndicatorConfig ric58 ON ric58.ReportConfigurationId = vc.ReportConfigId AND ric58.IndicatorId = 58
	) p
LEFT JOIN dbo.[Group] g ON p.GroupId = g.GroupId AND g.IsParameter = 0 AND g.Archived = 0
LEFT JOIN @configCount c ON g.groupId = c.GroupId
--WHERE vehicleid	IS null
ORDER BY g.GroupName

-- Calculate Scores
UPDATE @data 
SET Efficiency = SweetSpotComponent + OverRevWithFuelComponent + TopGearComponent + CruiseComponent + IdleComponent + CruiseInTopGearsComponent + TopGearOverspeedComponent + CruiseOverspeedComponent +
                 SweetSpotTimeComponent + OverRevTimeComponent + TopGearTimeComponent,
	Safety =	 EngineServiceBrakeComponent + OverRevWithoutFuelComponent + RopComponent  + OverSpeedComponent + CoastOutOfGearComponent + HarshBrakingComponent + AccelerationComponent + BrakingComponent + CorneringComponent +
				 IVHOverSpeedComponent + OverSpeedHighComponent + AccelerationLowComponent + BrakingLowComponent + CorneringLowComponent + AccelerationHighComponent + BrakingHighComponent + CorneringHighComponent +
				 ManoeuvresLowComponent + ManoeuvresMedComponent + Rop2Component +
				 OverspeedCountComponent + OverspeedHighCountComponent + StabilityControlComponent + CollisionWarningLowComponent + CollisionWarningMedComponent + 
				 CollisionWarningHighComponent + LaneDepartureDisableComponent + LaneDepartureLeftRightComponent + FatigueComponent + DistractionComponent

-- Re-Calculate Weighted Scores for Group Totals
UPDATE @data
SET Efficiency = w.WeightedEfficiency / d.TotalDrivingDistance, 
	Safety = w.WeightedSafety / d.TotalDrivingDistance
FROM @data d
INNER JOIN 
	(SELECT GroupId, SUM(d.Efficiency * d.TotalDrivingDistance) AS WeightedEfficiency, SUM(d.Safety * d.TotalDrivingDistance) AS WeightedSafety
	FROM @data d
	WHERE d.VehicleId IS NOT NULL AND d.GroupId IS NOT NULL
	GROUP BY GroupId) w ON d.GroupId = w.GroupId

-- Re-Calculate Weighted Scores for Report Total
UPDATE @data
SET Efficiency = w.WeightedEfficiency / d.TotalDrivingDistance, 
	Safety = w.WeightedSafety / d.TotalDrivingDistance
FROM @data d
CROSS JOIN 
	(SELECT SUM(d.Efficiency * d.TotalDrivingDistance) AS WeightedEfficiency, SUM(d.Safety * d.TotalDrivingDistance) AS WeightedSafety
	FROM @data d
	WHERE d.VehicleId IS NULL AND d.GroupId IS NOT NULL)  w
WHERE d.GroupId IS NULL	AND d.VehicleId IS NULL	

-- Calculate Colours for Group Totals
UPDATE @data
SET	SweetSpotColour =
		CASE ric1.HighLow	WHEN 1 THEN
								CASE
									WHEN ric1.GYRAmberMax = 0 AND ric1.GYRGreenMax = 0 AND ISNULL(ric1.GYRRedMax,0) = 0 THEN NULL
									WHEN ric1.GYRRedMax IS NULL AND ROUND(SweetSpot*100, ric1.Rounding) >= ric1.GYRGreenMax THEN @GreenColour
									WHEN ric1.GYRRedMax IS NULL AND ROUND(SweetSpot*100, ric1.Rounding) >= ric1.GYRAmberMax AND ROUND(SweetSpot*100, ric1.Rounding) < ric1.GYRGreenMax THEN @YellowColour
									WHEN ric1.GYRRedMax IS NULL AND ROUND(SweetSpot*100, ric1.Rounding) < ric1.GYRAmberMax THEN @RedColour
									WHEN ric1.GYRRedMax IS NOT NULL AND ROUND(SweetSpot*100, ric1.Rounding) >= ric1.GYRRedMax THEN @GoldColour
									WHEN ric1.GYRRedMax IS NOT NULL AND ROUND(SweetSpot*100, ric1.Rounding) >= ric1.GYRAmberMax AND ROUND(SweetSpot*100, ric1.Rounding) < ric1.GYRRedMax THEN @SilverColour
									WHEN ric1.GYRRedMax is NOT NULL AND ROUND(SweetSpot*100, ric1.Rounding) >= ric1.GYRGreenMax AND ROUND(SweetSpot*100, ric1.Rounding) < ric1.GYRAmberMax THEN @BronzeColour
									WHEN ric1.GYRRedMax IS NOT NULL AND ROUND(SweetSpot*100, ric1.Rounding) < ric1.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric1.GYRAmberMax = 0 AND ric1.GYRGreenMax = 0 AND ISNULL(ric1.GYRRedMax,0) = 0 THEN NULL
									WHEN ric1.GYRRedMAX IS NULL AND ROUND(SweetSpot*100, ric1.Rounding) <= ric1.GYRAmberMax THEN @GreenColour
									WHEN ric1.GYRRedMax IS NULL AND ROUND(SweetSpot*100, ric1.Rounding) <= ric1.GYRGreenMax AND ROUND(SweetSpot*100, ric1.Rounding) > ric1.GYRAmberMax THEN @YellowColour
									WHEN ric1.GYRRedMax IS NULL AND ROUND(SweetSpot*100, ric1.Rounding) > ric1.GYRGreenMax THEN @RedColour
									WHEN ric1.GYRRedMax IS NOT NULL AND ROUND(SweetSpot*100, ric1.Rounding) <= ric1.GYRRedMax THEN @GoldColour
									WHEN ric1.GYRRedMax IS NOT NULL AND ROUND(SweetSpot*100, ric1.Rounding) <= ric1.GYRAmberMax AND ROUND(SweetSpot*100, ric1.Rounding) > ric1.GYRRedMax THEN @SilverColour
									WHEN ric1.GYRRedMAx IS NOT NULL AND ROUND(SweetSpot*100, ric1.Rounding) <= ric1.GYRGreenMax AND ROUND(SweetSpot*100, ric1.Rounding) > ric1.GYRAmberMax THEN @BronzeColour
									WHEN ric1.GYRRedMax IS NOT NULL AND ROUND(SweetSpot*100, ric1.Rounding) > ric1.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	OverRevWithFuelColour =
		CASE ric2.HighLow	WHEN 1 THEN
								CASE
									WHEN ric2.GYRAmberMax = 0 AND ric2.GYRGreenMax = 0 AND ISNULL(ric2.GYRRedMax,0) = 0 THEN NULL
									WHEN ric2.GYRRedMax IS NULL AND ROUND(OverRevWithFuel*100, ric2.Rounding) >= ric2.GYRGreenMax THEN @GreenColour
									WHEN ric2.GYRRedMax IS NULL AND ROUND(OverRevWithFuel*100, ric2.Rounding) >= ric2.GYRAmberMax AND ROUND(OverRevWithFuel*100, ric2.Rounding) < ric2.GYRGreenMax THEN @YellowColour
									WHEN ric2.GYRRedMax IS NULL AND ROUND(OverRevWithFuel*100, ric2.Rounding) < ric2.GYRAmberMax THEN @RedColour
									WHEN ric2.GYRRedMax IS NOT NULL AND ROUND(OverRevWithFuel*100, ric2.Rounding) >= ric2.GYRRedMax THEN @GoldColour
									WHEN ric2.GYRRedMax IS NOT NULL AND ROUND(OverRevWithFuel*100, ric2.Rounding) >= ric2.GYRAmberMax AND ROUND(OverRevWithFuel*100, ric2.Rounding) < ric2.GYRRedMax THEN @SilverColour
									WHEN ric2.GYRRedMax is NOT NULL AND ROUND(OverRevWithFuel*100, ric2.Rounding) >= ric2.GYRGreenMax AND ROUND(OverRevWithFuel*100, ric2.Rounding) < ric2.GYRAmberMax THEN @BronzeColour
									WHEN ric2.GYRRedMax IS NOT NULL AND ROUND(OverRevWithFuel*100, ric2.Rounding) < ric2.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric2.GYRAmberMax = 0 AND ric2.GYRGreenMax = 0 AND ISNULL(ric2.GYRRedMax,0) = 0 THEN NULL
									WHEN ric2.GYRRedMAX IS NULL AND ROUND(OverRevWithFuel*100, ric2.Rounding) <= ric2.GYRAmberMax THEN @GreenColour
									WHEN ric2.GYRRedMax IS NULL AND ROUND(OverRevWithFuel*100, ric2.Rounding) <= ric2.GYRGreenMax AND ROUND(OverRevWithFuel*100, ric2.Rounding) > ric2.GYRAmberMax THEN @YellowColour
									WHEN ric2.GYRRedMax IS NULL AND ROUND(OverRevWithFuel*100, ric2.Rounding) > ric2.GYRGreenMax THEN @RedColour
									WHEN ric2.GYRRedMax IS NOT NULL AND ROUND(OverRevWithFuel*100, ric2.Rounding) <= ric2.GYRRedMax THEN @GoldColour
									WHEN ric2.GYRRedMax IS NOT NULL AND ROUND(OverRevWithFuel*100, ric2.Rounding) <= ric2.GYRAmberMax AND ROUND(OverRevWithFuel*100, ric2.Rounding) > ric2.GYRRedMax THEN @SilverColour
									WHEN ric2.GYRRedMAx IS NOT NULL AND ROUND(OverRevWithFuel*100, ric2.Rounding) <= ric2.GYRGreenMax AND ROUND(OverRevWithFuel*100, ric2.Rounding) > ric2.GYRAmberMax THEN @BronzeColour
									WHEN ric2.GYRRedMax IS NOT NULL AND ROUND(OverRevWithFuel*100, ric2.Rounding) > ric2.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	TopGearColour =
		CASE ric3.HighLow	WHEN 1 THEN
								CASE
									WHEN ric3.GYRAmberMax = 0 AND ric3.GYRGreenMax = 0 AND ISNULL(ric3.GYRRedMax,0) = 0 THEN NULL
									WHEN ric3.GYRRedMax IS NULL AND ROUND(TopGear*100, ric3.Rounding) >= ric3.GYRGreenMax THEN @GreenColour
									WHEN ric3.GYRRedMax IS NULL AND ROUND(TopGear*100, ric3.Rounding) >= ric3.GYRAmberMax AND ROUND(TopGear*100, ric3.Rounding) < ric3.GYRGreenMax THEN @YellowColour
									WHEN ric3.GYRRedMax IS NULL AND ROUND(TopGear*100, ric3.Rounding) < ric3.GYRAmberMax THEN @RedColour
									WHEN ric3.GYRRedMax IS NOT NULL AND ROUND(TopGear*100, ric3.Rounding) >= ric3.GYRRedMax THEN @GoldColour
									WHEN ric3.GYRRedMax IS NOT NULL AND ROUND(TopGear*100, ric3.Rounding) >= ric3.GYRAmberMax AND ROUND(TopGear*100, ric3.Rounding) < ric3.GYRRedMax THEN @SilverColour
									WHEN ric3.GYRRedMax is NOT NULL AND ROUND(TopGear*100, ric3.Rounding) >= ric3.GYRGreenMax AND ROUND(TopGear*100, ric3.Rounding) < ric3.GYRAmberMax THEN @BronzeColour
									WHEN ric3.GYRRedMax IS NOT NULL AND ROUND(TopGear*100, ric3.Rounding) < ric3.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric3.GYRAmberMax = 0 AND ric3.GYRGreenMax = 0 AND ISNULL(ric3.GYRRedMax,0) = 0 THEN NULL
									WHEN ric3.GYRRedMAX IS NULL AND ROUND(TopGear*100, ric3.Rounding) <= ric3.GYRAmberMax THEN @GreenColour
									WHEN ric3.GYRRedMax IS NULL AND ROUND(TopGear*100, ric3.Rounding) <= ric3.GYRGreenMax AND ROUND(TopGear*100, ric3.Rounding) > ric3.GYRAmberMax THEN @YellowColour
									WHEN ric3.GYRRedMax IS NULL AND ROUND(TopGear*100, ric3.Rounding) > ric3.GYRGreenMax THEN @RedColour
									WHEN ric3.GYRRedMax IS NOT NULL AND ROUND(TopGear*100, ric3.Rounding) <= ric3.GYRRedMax THEN @GoldColour
									WHEN ric3.GYRRedMax IS NOT NULL AND ROUND(TopGear*100, ric3.Rounding) <= ric3.GYRAmberMax AND ROUND(TopGear*100, ric3.Rounding) > ric3.GYRRedMax THEN @SilverColour
									WHEN ric3.GYRRedMAx IS NOT NULL AND ROUND(TopGear*100, ric3.Rounding) <= ric3.GYRGreenMax AND ROUND(TopGear*100, ric3.Rounding) > ric3.GYRAmberMax THEN @BronzeColour
									WHEN ric3.GYRRedMax IS NOT NULL AND ROUND(TopGear*100, ric3.Rounding) > ric3.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	CruiseColour =
		CASE ric4.HighLow	WHEN 1 THEN
								CASE
									WHEN ric4.GYRAmberMax = 0 AND ric4.GYRGreenMax = 0 AND ISNULL(ric4.GYRRedMax,0) = 0 THEN NULL
									WHEN ric4.GYRRedMax IS NULL AND ROUND(Cruise*100, ric4.Rounding) >= ric4.GYRGreenMax THEN @GreenColour
									WHEN ric4.GYRRedMax IS NULL AND ROUND(Cruise*100, ric4.Rounding) >= ric4.GYRAmberMax AND ROUND(Cruise*100, ric4.Rounding) < ric4.GYRGreenMax THEN @YellowColour
									WHEN ric4.GYRRedMax IS NULL AND ROUND(Cruise*100, ric4.Rounding) < ric4.GYRAmberMax THEN @RedColour
									WHEN ric4.GYRRedMax IS NOT NULL AND ROUND(Cruise*100, ric4.Rounding) >= ric4.GYRRedMax THEN @GoldColour
									WHEN ric4.GYRRedMax IS NOT NULL AND ROUND(Cruise*100, ric4.Rounding) >= ric4.GYRAmberMax AND ROUND(Cruise*100, ric4.Rounding) < ric4.GYRRedMax THEN @SilverColour
									WHEN ric4.GYRRedMax is NOT NULL AND ROUND(Cruise*100, ric4.Rounding) >= ric4.GYRGreenMax AND ROUND(Cruise*100, ric4.Rounding) < ric4.GYRAmberMax THEN @BronzeColour
									WHEN ric4.GYRRedMax IS NOT NULL AND ROUND(Cruise*100, ric4.Rounding) < ric4.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric4.GYRAmberMax = 0 AND ric4.GYRGreenMax = 0 AND ISNULL(ric4.GYRRedMax,0) = 0 THEN NULL
									WHEN ric4.GYRRedMAX IS NULL AND ROUND(Cruise*100, ric4.Rounding) <= ric4.GYRAmberMax THEN @GreenColour
									WHEN ric4.GYRRedMax IS NULL AND ROUND(Cruise*100, ric4.Rounding) <= ric4.GYRGreenMax AND ROUND(Cruise*100, ric4.Rounding) > ric4.GYRAmberMax THEN @YellowColour
									WHEN ric4.GYRRedMax IS NULL AND ROUND(Cruise*100, ric4.Rounding) > ric4.GYRGreenMax THEN @RedColour
									WHEN ric4.GYRRedMax IS NOT NULL AND ROUND(Cruise*100, ric4.Rounding) <= ric4.GYRRedMax THEN @GoldColour
									WHEN ric4.GYRRedMax IS NOT NULL AND ROUND(Cruise*100, ric4.Rounding) <= ric4.GYRAmberMax AND ROUND(Cruise*100, ric4.Rounding) > ric4.GYRRedMax THEN @SilverColour
									WHEN ric4.GYRRedMAx IS NOT NULL AND ROUND(Cruise*100, ric4.Rounding) <= ric4.GYRGreenMax AND ROUND(Cruise*100, ric4.Rounding) > ric4.GYRAmberMax THEN @BronzeColour
									WHEN ric4.GYRRedMax IS NOT NULL AND ROUND(Cruise*100, ric4.Rounding) > ric4.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	CruiseInTopGearsColour =
		CASE ric31.HighLow	WHEN 1 THEN
								CASE
									WHEN ric31.GYRAmberMax = 0 AND ric31.GYRGreenMax = 0 AND ISNULL(ric31.GYRRedMax,0) = 0 THEN NULL
									WHEN ric31.GYRRedMax IS NULL AND ROUND(CruiseInTopGears*100, ric31.Rounding) >= ric31.GYRGreenMax THEN @GreenColour
									WHEN ric31.GYRRedMax IS NULL AND ROUND(CruiseInTopGears*100, ric31.Rounding) >= ric31.GYRAmberMax AND ROUND(CruiseInTopGears*100, ric31.Rounding) < ric31.GYRGreenMax THEN @YellowColour
									WHEN ric31.GYRRedMax IS NULL AND ROUND(CruiseInTopGears*100, ric31.Rounding) < ric31.GYRAmberMax THEN @RedColour
									WHEN ric31.GYRRedMax IS NOT NULL AND ROUND(CruiseInTopGears*100, ric31.Rounding) >= ric31.GYRRedMax THEN @GoldColour
									WHEN ric31.GYRRedMax IS NOT NULL AND ROUND(CruiseInTopGears*100, ric31.Rounding) >= ric31.GYRAmberMax AND ROUND(CruiseInTopGears*100, ric31.Rounding) < ric31.GYRRedMax THEN @SilverColour
									WHEN ric31.GYRRedMax is NOT NULL AND ROUND(CruiseInTopGears*100, ric31.Rounding) >= ric31.GYRGreenMax AND ROUND(CruiseInTopGears*100, ric31.Rounding) < ric31.GYRAmberMax THEN @BronzeColour
									WHEN ric31.GYRRedMax IS NOT NULL AND ROUND(CruiseInTopGears*100, ric31.Rounding) < ric31.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric31.GYRAmberMax = 0 AND ric31.GYRGreenMax = 0 AND ISNULL(ric31.GYRRedMax,0) = 0 THEN NULL
									WHEN ric31.GYRRedMAX IS NULL AND ROUND(CruiseInTopGears*100, ric31.Rounding) <= ric31.GYRAmberMax THEN @GreenColour
									WHEN ric31.GYRRedMax IS NULL AND ROUND(CruiseInTopGears*100, ric31.Rounding) <= ric31.GYRGreenMax AND ROUND(CruiseInTopGears*100, ric31.Rounding) > ric31.GYRAmberMax THEN @YellowColour
									WHEN ric31.GYRRedMax IS NULL AND ROUND(CruiseInTopGears*100, ric31.Rounding) > ric31.GYRGreenMax THEN @RedColour
									WHEN ric31.GYRRedMax IS NOT NULL AND ROUND(CruiseInTopGears*100, ric31.Rounding) <= ric31.GYRRedMax THEN @GoldColour
									WHEN ric31.GYRRedMax IS NOT NULL AND ROUND(CruiseInTopGears*100, ric31.Rounding) <= ric31.GYRAmberMax AND ROUND(CruiseInTopGears*100, ric31.Rounding) > ric31.GYRRedMax THEN @SilverColour
									WHEN ric31.GYRRedMAx IS NOT NULL AND ROUND(CruiseInTopGears*100, ric31.Rounding) <= ric31.GYRGreenMax AND ROUND(CruiseInTopGears*100, ric31.Rounding) > ric31.GYRAmberMax THEN @BronzeColour
									WHEN ric31.GYRRedMax IS NOT NULL AND ROUND(CruiseInTopGears*100, ric31.Rounding) > ric31.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	CoastInGearColour =
		CASE ric5.HighLow	WHEN 1 THEN
								CASE
									WHEN ric5.GYRAmberMax = 0 AND ric5.GYRGreenMax = 0 AND ISNULL(ric5.GYRRedMax,0) = 0 THEN NULL
									WHEN ric5.GYRRedMax IS NULL AND ROUND(CoastInGear*100, ric5.Rounding) >= ric5.GYRGreenMax THEN @GreenColour
									WHEN ric5.GYRRedMax IS NULL AND ROUND(CoastInGear*100, ric5.Rounding) >= ric5.GYRAmberMax AND ROUND(CoastInGear*100, ric5.Rounding) < ric5.GYRGreenMax THEN @YellowColour
									WHEN ric5.GYRRedMax IS NULL AND ROUND(CoastInGear*100, ric5.Rounding) < ric5.GYRAmberMax THEN @RedColour
									WHEN ric5.GYRRedMax IS NOT NULL AND ROUND(CoastInGear*100, ric5.Rounding) >= ric5.GYRRedMax THEN @GoldColour
									WHEN ric5.GYRRedMax IS NOT NULL AND ROUND(CoastInGear*100, ric5.Rounding) >= ric5.GYRAmberMax AND ROUND(CoastInGear*100, ric5.Rounding) < ric5.GYRRedMax THEN @SilverColour
									WHEN ric5.GYRRedMax is NOT NULL AND ROUND(CoastInGear*100, ric5.Rounding) >= ric5.GYRGreenMax AND ROUND(CoastInGear*100, ric5.Rounding) < ric5.GYRAmberMax THEN @BronzeColour
									WHEN ric5.GYRRedMax IS NOT NULL AND ROUND(CoastInGear*100, ric5.Rounding) < ric5.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric5.GYRAmberMax = 0 AND ric5.GYRGreenMax = 0 AND ISNULL(ric5.GYRRedMax,0) = 0 THEN NULL
									WHEN ric5.GYRRedMAX IS NULL AND ROUND(CoastInGear*100, ric5.Rounding) <= ric5.GYRAmberMax THEN @GreenColour
									WHEN ric5.GYRRedMax IS NULL AND ROUND(CoastInGear*100, ric5.Rounding) <= ric5.GYRGreenMax AND ROUND(CoastInGear*100, ric5.Rounding) > ric5.GYRAmberMax THEN @YellowColour
									WHEN ric5.GYRRedMax IS NULL AND ROUND(CoastInGear*100, ric5.Rounding) > ric5.GYRGreenMax THEN @RedColour
									WHEN ric5.GYRRedMax IS NOT NULL AND ROUND(CoastInGear*100, ric5.Rounding) <= ric5.GYRRedMax THEN @GoldColour
									WHEN ric5.GYRRedMax IS NOT NULL AND ROUND(CoastInGear*100, ric5.Rounding) <= ric5.GYRAmberMax AND ROUND(CoastInGear*100, ric5.Rounding) > ric5.GYRRedMax THEN @SilverColour
									WHEN ric5.GYRRedMAx IS NOT NULL AND ROUND(CoastInGear*100, ric5.Rounding) <= ric5.GYRGreenMax AND ROUND(CoastInGear*100, ric5.Rounding) > ric5.GYRAmberMax THEN @BronzeColour
									WHEN ric5.GYRRedMax IS NOT NULL AND ROUND(CoastInGear*100, ric5.Rounding) > ric5.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	IdleColour =
		CASE ric6.HighLow	WHEN 1 THEN
								CASE
									WHEN ric6.GYRAmberMax = 0 AND ric6.GYRGreenMax = 0 AND ISNULL(ric6.GYRRedMax,0) = 0 THEN NULL
									WHEN ric6.GYRRedMax IS NULL AND ROUND(Idle*100, ric6.Rounding) >= ric6.GYRGreenMax THEN @GreenColour
									WHEN ric6.GYRRedMax IS NULL AND ROUND(Idle*100, ric6.Rounding) >= ric6.GYRAmberMax AND ROUND(Idle*100, ric6.Rounding) < ric6.GYRGreenMax THEN @YellowColour
									WHEN ric6.GYRRedMax IS NULL AND ROUND(Idle*100, ric6.Rounding) < ric6.GYRAmberMax THEN @RedColour
									WHEN ric6.GYRRedMax IS NOT NULL AND ROUND(Idle*100, ric6.Rounding) >= ric6.GYRRedMax THEN @GoldColour
									WHEN ric6.GYRRedMax IS NOT NULL AND ROUND(Idle*100, ric6.Rounding) >= ric6.GYRAmberMax AND ROUND(Idle*100, ric6.Rounding) < ric6.GYRRedMax THEN @SilverColour
									WHEN ric6.GYRRedMax is NOT NULL AND ROUND(Idle*100, ric6.Rounding) >= ric6.GYRGreenMax AND ROUND(Idle*100, ric6.Rounding) < ric6.GYRAmberMax THEN @BronzeColour
									WHEN ric6.GYRRedMax IS NOT NULL AND ROUND(Idle*100, ric6.Rounding) < ric6.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric6.GYRAmberMax = 0 AND ric6.GYRGreenMax = 0 AND ISNULL(ric6.GYRRedMax,0) = 0 THEN NULL
									WHEN ric6.GYRRedMAX IS NULL AND ROUND(Idle*100, ric6.Rounding) <= ric6.GYRAmberMax THEN @GreenColour
									WHEN ric6.GYRRedMax IS NULL AND ROUND(Idle*100, ric6.Rounding) <= ric6.GYRGreenMax AND ROUND(Idle*100, ric6.Rounding) > ric6.GYRAmberMax THEN @YellowColour
									WHEN ric6.GYRRedMax IS NULL AND ROUND(Idle*100, ric6.Rounding) > ric6.GYRGreenMax THEN @RedColour
									WHEN ric6.GYRRedMax IS NOT NULL AND ROUND(Idle*100, ric6.Rounding) <= ric6.GYRRedMax THEN @GoldColour
									WHEN ric6.GYRRedMax IS NOT NULL AND ROUND(Idle*100, ric6.Rounding) <= ric6.GYRAmberMax AND ROUND(Idle*100, ric6.Rounding) > ric6.GYRRedMax THEN @SilverColour
									WHEN ric6.GYRRedMAx IS NOT NULL AND ROUND(Idle*100, ric6.Rounding) <= ric6.GYRGreenMax AND ROUND(Idle*100, ric6.Rounding) > ric6.GYRAmberMax THEN @BronzeColour
									WHEN ric6.GYRRedMax IS NOT NULL AND ROUND(Idle*100, ric6.Rounding) > ric6.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	EngineServiceBrakeColour =
		CASE ric7.HighLow	WHEN 1 THEN
								CASE
									WHEN ric7.GYRAmberMax = 0 AND ric7.GYRGreenMax = 0 AND ISNULL(ric7.GYRRedMax,0) = 0 THEN NULL
									WHEN ric7.GYRRedMax IS NULL AND ROUND(EngineServiceBrake*100, ric7.Rounding) >= ric7.GYRGreenMax THEN @GreenColour
									WHEN ric7.GYRRedMax IS NULL AND ROUND(EngineServiceBrake*100, ric7.Rounding) >= ric7.GYRAmberMax AND ROUND(EngineServiceBrake*100, ric7.Rounding) < ric7.GYRGreenMax THEN @YellowColour
									WHEN ric7.GYRRedMax IS NULL AND ROUND(EngineServiceBrake*100, ric7.Rounding) < ric7.GYRAmberMax THEN @RedColour
									WHEN ric7.GYRRedMax IS NOT NULL AND ROUND(EngineServiceBrake*100, ric7.Rounding) >= ric7.GYRRedMax THEN @GoldColour
									WHEN ric7.GYRRedMax IS NOT NULL AND ROUND(EngineServiceBrake*100, ric7.Rounding) >= ric7.GYRAmberMax AND ROUND(EngineServiceBrake*100, ric7.Rounding) < ric7.GYRRedMax THEN @SilverColour
									WHEN ric7.GYRRedMax is NOT NULL AND ROUND(EngineServiceBrake*100, ric7.Rounding) >= ric7.GYRGreenMax AND ROUND(EngineServiceBrake*100, ric7.Rounding) < ric7.GYRAmberMax THEN @BronzeColour
									WHEN ric7.GYRRedMax IS NOT NULL AND ROUND(EngineServiceBrake*100, ric7.Rounding) < ric7.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric7.GYRAmberMax = 0 AND ric7.GYRGreenMax = 0 AND ISNULL(ric7.GYRRedMax,0) = 0 THEN NULL
									WHEN ric7.GYRRedMAX IS NULL AND ROUND(EngineServiceBrake*100, ric7.Rounding) <= ric7.GYRAmberMax THEN @GreenColour
									WHEN ric7.GYRRedMax IS NULL AND ROUND(EngineServiceBrake*100, ric7.Rounding) <= ric7.GYRGreenMax AND ROUND(EngineServiceBrake*100, ric7.Rounding) > ric7.GYRAmberMax THEN @YellowColour
									WHEN ric7.GYRRedMax IS NULL AND ROUND(EngineServiceBrake*100, ric7.Rounding) > ric7.GYRGreenMax THEN @RedColour
									WHEN ric7.GYRRedMax IS NOT NULL AND ROUND(EngineServiceBrake*100, ric7.Rounding) <= ric7.GYRRedMax THEN @GoldColour
									WHEN ric7.GYRRedMax IS NOT NULL AND ROUND(EngineServiceBrake*100, ric7.Rounding) <= ric7.GYRAmberMax AND ROUND(EngineServiceBrake*100, ric7.Rounding) > ric7.GYRRedMax THEN @SilverColour
									WHEN ric7.GYRRedMAx IS NOT NULL AND ROUND(EngineServiceBrake*100, ric7.Rounding) <= ric7.GYRGreenMax AND ROUND(EngineServiceBrake*100, ric7.Rounding) > ric7.GYRAmberMax THEN @BronzeColour
									WHEN ric7.GYRRedMax IS NOT NULL AND ROUND(EngineServiceBrake*100, ric7.Rounding) > ric7.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	OverRevWithoutFuelColour =
		CASE ric8.HighLow	WHEN 1 THEN
								CASE
									WHEN ric8.GYRAmberMax = 0 AND ric8.GYRGreenMax = 0 AND ISNULL(ric8.GYRRedMax,0) = 0 THEN NULL
									WHEN ric8.GYRRedMax IS NULL AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) >= ric8.GYRGreenMax THEN @GreenColour
									WHEN ric8.GYRRedMax IS NULL AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) >= ric8.GYRAmberMax AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) < ric8.GYRGreenMax THEN @YellowColour
									WHEN ric8.GYRRedMax IS NULL AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) < ric8.GYRAmberMax THEN @RedColour
									WHEN ric8.GYRRedMax IS NOT NULL AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) >= ric8.GYRRedMax THEN @GoldColour
									WHEN ric8.GYRRedMax IS NOT NULL AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) >= ric8.GYRAmberMax AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) < ric8.GYRRedMax THEN @SilverColour
									WHEN ric8.GYRRedMax is NOT NULL AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) >= ric8.GYRGreenMax AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) < ric8.GYRAmberMax THEN @BronzeColour
									WHEN ric8.GYRRedMax IS NOT NULL AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) < ric8.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric8.GYRAmberMax = 0 AND ric8.GYRGreenMax = 0 AND ISNULL(ric8.GYRRedMax,0) = 0 THEN NULL
									WHEN ric8.GYRRedMAX IS NULL AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) <= ric8.GYRAmberMax THEN @GreenColour
									WHEN ric8.GYRRedMax IS NULL AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) <= ric8.GYRGreenMax AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) > ric8.GYRAmberMax THEN @YellowColour
									WHEN ric8.GYRRedMax IS NULL AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) > ric8.GYRGreenMax THEN @RedColour
									WHEN ric8.GYRRedMax IS NOT NULL AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) <= ric8.GYRRedMax THEN @GoldColour
									WHEN ric8.GYRRedMax IS NOT NULL AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) <= ric8.GYRAmberMax AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) > ric8.GYRRedMax THEN @SilverColour
									WHEN ric8.GYRRedMAx IS NOT NULL AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) <= ric8.GYRGreenMax AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) > ric8.GYRAmberMax THEN @BronzeColour
									WHEN ric8.GYRRedMax IS NOT NULL AND ROUND(OverRevWithoutFuel*100, ric8.Rounding) > ric8.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	RopColour =
		CASE ric9.HighLow	WHEN 1 THEN
								CASE
									WHEN ric9.GYRAmberMax = 0 AND ric9.GYRGreenMax = 0 AND ISNULL(ric9.GYRRedMax,0) = 0 THEN NULL
									WHEN ric9.GYRRedMax IS NULL AND ROUND(Rop, ric9.Rounding) >= ric9.GYRGreenMax THEN @GreenColour
									WHEN ric9.GYRRedMax IS NULL AND ROUND(Rop, ric9.Rounding) >= ric9.GYRAmberMax AND ROUND(Rop, ric9.Rounding) < ric9.GYRGreenMax THEN @YellowColour
									WHEN ric9.GYRRedMax IS NULL AND ROUND(Rop, ric9.Rounding) < ric9.GYRAmberMax THEN @RedColour
									WHEN ric9.GYRRedMax IS NOT NULL AND ROUND(Rop, ric9.Rounding) >= ric9.GYRRedMax THEN @GoldColour
									WHEN ric9.GYRRedMax IS NOT NULL AND ROUND(Rop, ric9.Rounding) >= ric9.GYRAmberMax AND ROUND(Rop, ric9.Rounding) < ric9.GYRRedMax THEN @SilverColour
									WHEN ric9.GYRRedMax is NOT NULL AND ROUND(Rop, ric9.Rounding) >= ric9.GYRGreenMax AND ROUND(Rop, ric9.Rounding) < ric9.GYRAmberMax THEN @BronzeColour
									WHEN ric9.GYRRedMax IS NOT NULL AND ROUND(Rop, ric9.Rounding) < ric9.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric9.GYRAmberMax = 0 AND ric9.GYRGreenMax = 0 AND ISNULL(ric9.GYRRedMax,0) = 0 THEN NULL
									WHEN ric9.GYRRedMAX IS NULL AND ROUND(Rop, ric9.Rounding) <= ric9.GYRAmberMax THEN @GreenColour
									WHEN ric9.GYRRedMax IS NULL AND ROUND(Rop, ric9.Rounding) <= ric9.GYRGreenMax AND ROUND(Rop, ric9.Rounding) > ric9.GYRAmberMax THEN @YellowColour
									WHEN ric9.GYRRedMax IS NULL AND ROUND(Rop, ric9.Rounding) > ric9.GYRGreenMax THEN @RedColour
									WHEN ric9.GYRRedMax IS NOT NULL AND ROUND(Rop, ric9.Rounding) <= ric9.GYRRedMax THEN @GoldColour
									WHEN ric9.GYRRedMax IS NOT NULL AND ROUND(Rop, ric9.Rounding) <= ric9.GYRAmberMax AND ROUND(Rop, ric9.Rounding) > ric9.GYRRedMax THEN @SilverColour
									WHEN ric9.GYRRedMAx IS NOT NULL AND ROUND(Rop, ric9.Rounding) <= ric9.GYRGreenMax AND ROUND(Rop, ric9.Rounding) > ric9.GYRAmberMax THEN @BronzeColour
									WHEN ric9.GYRRedMax IS NOT NULL AND ROUND(Rop, ric9.Rounding) > ric9.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
Rop2Colour =
		CASE ric41.HighLow	WHEN 1 THEN
								CASE
									WHEN ric41.GYRAmberMax = 0 AND ric41.GYRGreenMax = 0 AND ISNULL(ric41.GYRRedMax,0) = 0 THEN NULL
									WHEN ric41.GYRRedMax IS NULL AND ROUND(Rop2, ric41.Rounding) >= ric41.GYRGreenMax THEN @GreenColour
									WHEN ric41.GYRRedMax IS NULL AND ROUND(Rop2, ric41.Rounding) >= ric41.GYRAmberMax AND ROUND(Rop2, ric41.Rounding) < ric41.GYRGreenMax THEN @YellowColour
									WHEN ric41.GYRRedMax IS NULL AND ROUND(Rop2, ric41.Rounding) < ric41.GYRAmberMax THEN @RedColour
									WHEN ric41.GYRRedMax IS NOT NULL AND ROUND(Rop2, ric41.Rounding) >= ric41.GYRRedMax THEN @GoldColour
									WHEN ric41.GYRRedMax IS NOT NULL AND ROUND(Rop2, ric41.Rounding) >= ric41.GYRAmberMax AND ROUND(Rop2, ric41.Rounding) < ric41.GYRRedMax THEN @SilverColour
									WHEN ric41.GYRRedMax is NOT NULL AND ROUND(Rop2, ric41.Rounding) >= ric41.GYRGreenMax AND ROUND(Rop2, ric41.Rounding) < ric41.GYRAmberMax THEN @BronzeColour
									WHEN ric41.GYRRedMax IS NOT NULL AND ROUND(Rop2, ric41.Rounding) < ric41.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric41.GYRAmberMax = 0 AND ric41.GYRGreenMax = 0 AND ISNULL(ric41.GYRRedMax,0) = 0 THEN NULL
									WHEN ric41.GYRRedMAX IS NULL AND ROUND(Rop2, ric41.Rounding) <= ric41.GYRAmberMax THEN @GreenColour
									WHEN ric41.GYRRedMax IS NULL AND ROUND(Rop2, ric41.Rounding) <= ric41.GYRGreenMax AND ROUND(Rop2, ric41.Rounding) > ric41.GYRAmberMax THEN @YellowColour
									WHEN ric41.GYRRedMax IS NULL AND ROUND(Rop2, ric41.Rounding) > ric41.GYRGreenMax THEN @RedColour
									WHEN ric41.GYRRedMax IS NOT NULL AND ROUND(Rop2, ric41.Rounding) <= ric41.GYRRedMax THEN @GoldColour
									WHEN ric41.GYRRedMax IS NOT NULL AND ROUND(Rop2, ric41.Rounding) <= ric41.GYRAmberMax AND ROUND(Rop2, ric41.Rounding) > ric41.GYRRedMax THEN @SilverColour
									WHEN ric41.GYRRedMAx IS NOT NULL AND ROUND(Rop2, ric41.Rounding) <= ric41.GYRGreenMax AND ROUND(Rop2, ric41.Rounding) > ric41.GYRAmberMax THEN @BronzeColour
									WHEN ric41.GYRRedMax IS NOT NULL AND ROUND(Rop2, ric41.Rounding) > ric41.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	OverSpeedColour =
		CASE ric10.HighLow	WHEN 1 THEN
								CASE
									WHEN ric10.GYRAmberMax = 0 AND ric10.GYRGreenMax = 0 AND ISNULL(ric10.GYRRedMax,0) = 0 THEN NULL
									WHEN ric10.GYRRedMax IS NULL AND ROUND(OverSpeed*100, ric10.Rounding) >= ric10.GYRGreenMax THEN @GreenColour
									WHEN ric10.GYRRedMax IS NULL AND ROUND(OverSpeed*100, ric10.Rounding) >= ric10.GYRAmberMax AND ROUND(OverSpeed*100, ric10.Rounding) < ric10.GYRGreenMax THEN @YellowColour
									WHEN ric10.GYRRedMax IS NULL AND ROUND(OverSpeed*100, ric10.Rounding) < ric10.GYRAmberMax THEN @RedColour
									WHEN ric10.GYRRedMax IS NOT NULL AND ROUND(OverSpeed*100, ric10.Rounding) >= ric10.GYRRedMax THEN @GoldColour
									WHEN ric10.GYRRedMax IS NOT NULL AND ROUND(OverSpeed*100, ric10.Rounding) >= ric10.GYRAmberMax AND ROUND(OverSpeed*100, ric10.Rounding) < ric10.GYRRedMax THEN @SilverColour
									WHEN ric10.GYRRedMax is NOT NULL AND ROUND(OverSpeed*100, ric10.Rounding) >= ric10.GYRGreenMax AND ROUND(OverSpeed*100, ric10.Rounding) < ric10.GYRAmberMax THEN @BronzeColour
									WHEN ric10.GYRRedMax IS NOT NULL AND ROUND(OverSpeed*100, ric10.Rounding) < ric10.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric10.GYRAmberMax = 0 AND ric10.GYRGreenMax = 0 AND ISNULL(ric10.GYRRedMax,0) = 0 THEN NULL
									WHEN ric10.GYRRedMAX IS NULL AND ROUND(OverSpeed*100, ric10.Rounding) <= ric10.GYRAmberMax THEN @GreenColour
									WHEN ric10.GYRRedMax IS NULL AND ROUND(OverSpeed*100, ric10.Rounding) <= ric10.GYRGreenMax AND ROUND(OverSpeed*100, ric10.Rounding) > ric10.GYRAmberMax THEN @YellowColour
									WHEN ric10.GYRRedMax IS NULL AND ROUND(OverSpeed*100, ric10.Rounding) > ric10.GYRGreenMax THEN @RedColour
									WHEN ric10.GYRRedMax IS NOT NULL AND ROUND(OverSpeed*100, ric10.Rounding) <= ric10.GYRRedMax THEN @GoldColour
									WHEN ric10.GYRRedMax IS NOT NULL AND ROUND(OverSpeed*100, ric10.Rounding) <= ric10.GYRAmberMax AND ROUND(OverSpeed*100, ric10.Rounding) > ric10.GYRRedMax THEN @SilverColour
									WHEN ric10.GYRRedMAx IS NOT NULL AND ROUND(OverSpeed*100, ric10.Rounding) <= ric10.GYRGreenMax AND ROUND(OverSpeed*100, ric10.Rounding) > ric10.GYRAmberMax THEN @BronzeColour
									WHEN ric10.GYRRedMax IS NOT NULL AND ROUND(OverSpeed*100, ric10.Rounding) > ric10.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	OverSpeedHighColour = 
		CASE ric32.HighLow	WHEN 1 THEN
								CASE
									WHEN ric32.GYRAmberMax = 0 AND ric32.GYRGreenMax = 0 AND ISNULL(ric32.GYRRedMax,0) = 0 THEN NULL
									WHEN ric32.GYRRedMax IS NULL AND ROUND(OverSpeedHigh*100, ric32.Rounding) >= ric32.GYRGreenMax THEN @GreenColour
									WHEN ric32.GYRRedMax IS NULL AND ROUND(OverSpeedHigh*100, ric32.Rounding) >= ric32.GYRAmberMax AND ROUND(OverSpeedHigh*100, ric32.Rounding) < ric32.GYRGreenMax THEN @YellowColour
									WHEN ric32.GYRRedMax IS NULL AND ROUND(OverSpeedHigh*100, ric32.Rounding) < ric32.GYRAmberMax THEN @RedColour
									WHEN ric32.GYRRedMax IS NOT NULL AND ROUND(OverSpeedHigh*100, ric32.Rounding) >= ric32.GYRRedMax THEN @GoldColour
									WHEN ric32.GYRRedMax IS NOT NULL AND ROUND(OverSpeedHigh*100, ric32.Rounding) >= ric32.GYRAmberMax AND ROUND(OverSpeedHigh*100, ric32.Rounding) < ric32.GYRRedMax THEN @SilverColour
									WHEN ric32.GYRRedMax is NOT NULL AND ROUND(OverSpeedHigh*100, ric32.Rounding) >= ric32.GYRGreenMax AND ROUND(OverSpeedHigh*100, ric32.Rounding) < ric32.GYRAmberMax THEN @BronzeColour
									WHEN ric32.GYRRedMax IS NOT NULL AND ROUND(OverSpeedHigh*100, ric32.Rounding) < ric32.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric32.GYRAmberMax = 0 AND ric32.GYRGreenMax = 0 AND ISNULL(ric32.GYRRedMax,0) = 0 THEN NULL
									WHEN ric32.GYRRedMAX IS NULL AND ROUND(OverSpeedHigh*100, ric32.Rounding) <= ric32.GYRAmberMax THEN @GreenColour
									WHEN ric32.GYRRedMax IS NULL AND ROUND(OverSpeedHigh*100, ric32.Rounding) <= ric32.GYRGreenMax AND ROUND(OverSpeedHigh*100, ric32.Rounding) > ric32.GYRAmberMax THEN @YellowColour
									WHEN ric32.GYRRedMax IS NULL AND ROUND(OverSpeedHigh*100, ric32.Rounding) > ric32.GYRGreenMax THEN @RedColour
									WHEN ric32.GYRRedMax IS NOT NULL AND ROUND(OverSpeedHigh*100, ric32.Rounding) <= ric32.GYRRedMax THEN @GoldColour
									WHEN ric32.GYRRedMax IS NOT NULL AND ROUND(OverSpeedHigh*100, ric32.Rounding) <= ric32.GYRAmberMax AND ROUND(OverSpeedHigh*100, ric32.Rounding) > ric32.GYRRedMax THEN @SilverColour
									WHEN ric32.GYRRedMAx IS NOT NULL AND ROUND(OverSpeedHigh*100, ric32.Rounding) <= ric32.GYRGreenMax AND ROUND(OverSpeedHigh*100, ric32.Rounding) > ric32.GYRAmberMax THEN @BronzeColour
									WHEN ric32.GYRRedMax IS NOT NULL AND ROUND(OverSpeedHigh*100, ric32.Rounding) > ric32.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	IVHOverSpeedColour =
		CASE ric30.HighLow	WHEN 1 THEN
								CASE
									WHEN ric30.GYRAmberMax = 0 AND ric30.GYRGreenMax = 0 AND ISNULL(ric30.GYRRedMax,0) = 0 THEN NULL
									WHEN ric30.GYRRedMax IS NULL AND ROUND(IVHOverSpeed*100, ric30.Rounding) >= ric30.GYRGreenMax THEN @GreenColour
									WHEN ric30.GYRRedMax IS NULL AND ROUND(IVHOverSpeed*100, ric30.Rounding) >= ric30.GYRAmberMax AND ROUND(IVHOverSpeed*100, ric30.Rounding) < ric30.GYRGreenMax THEN @YellowColour
									WHEN ric30.GYRRedMax IS NULL AND ROUND(IVHOverSpeed*100, ric30.Rounding) < ric30.GYRAmberMax THEN @RedColour
									WHEN ric30.GYRRedMax IS NOT NULL AND ROUND(IVHOverSpeed*100, ric30.Rounding) >= ric30.GYRRedMax THEN @GoldColour
									WHEN ric30.GYRRedMax IS NOT NULL AND ROUND(IVHOverSpeed*100, ric30.Rounding) >= ric30.GYRAmberMax AND ROUND(IVHOverSpeed*100, ric30.Rounding) < ric30.GYRRedMax THEN @SilverColour
									WHEN ric30.GYRRedMax is NOT NULL AND ROUND(IVHOverSpeed*100, ric30.Rounding) >= ric30.GYRGreenMax AND ROUND(IVHOverSpeed*100, ric30.Rounding) < ric30.GYRAmberMax THEN @BronzeColour
									WHEN ric30.GYRRedMax IS NOT NULL AND ROUND(IVHOverSpeed*100, ric30.Rounding) < ric30.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric30.GYRAmberMax = 0 AND ric30.GYRGreenMax = 0 AND ISNULL(ric30.GYRRedMax,0) = 0 THEN NULL
									WHEN ric30.GYRRedMAX IS NULL AND ROUND(IVHOverSpeed*100, ric30.Rounding) <= ric30.GYRAmberMax THEN @GreenColour
									WHEN ric30.GYRRedMax IS NULL AND ROUND(IVHOverSpeed*100, ric30.Rounding) <= ric30.GYRGreenMax AND ROUND(IVHOverSpeed*100, ric30.Rounding) > ric30.GYRAmberMax THEN @YellowColour
									WHEN ric30.GYRRedMax IS NULL AND ROUND(IVHOverSpeed*100, ric30.Rounding) > ric30.GYRGreenMax THEN @RedColour
									WHEN ric30.GYRRedMax IS NOT NULL AND ROUND(IVHOverSpeed*100, ric30.Rounding) <= ric30.GYRRedMax THEN @GoldColour
									WHEN ric30.GYRRedMax IS NOT NULL AND ROUND(IVHOverSpeed*100, ric30.Rounding) <= ric30.GYRAmberMax AND ROUND(IVHOverSpeed*100, ric30.Rounding) > ric30.GYRRedMax THEN @SilverColour
									WHEN ric30.GYRRedMAx IS NOT NULL AND ROUND(IVHOverSpeed*100, ric30.Rounding) <= ric30.GYRGreenMax AND ROUND(IVHOverSpeed*100, ric30.Rounding) > ric30.GYRAmberMax THEN @BronzeColour
									WHEN ric30.GYRRedMax IS NOT NULL AND ROUND(IVHOverSpeed*100, ric30.Rounding) > ric30.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	CoastOutOfGearColour =
		CASE ric11.HighLow	WHEN 1 THEN
								CASE
									WHEN ric11.GYRAmberMax = 0 AND ric11.GYRGreenMax = 0 AND ISNULL(ric11.GYRRedMax,0) = 0 THEN NULL
									WHEN ric11.GYRRedMax IS NULL AND ROUND(CoastOutOfGear*100, ric11.Rounding) >= ric11.GYRGreenMax THEN @GreenColour
									WHEN ric11.GYRRedMax IS NULL AND ROUND(CoastOutOfGear*100, ric11.Rounding) >= ric11.GYRAmberMax AND ROUND(CoastOutOfGear*100, ric11.Rounding) < ric11.GYRGreenMax THEN @YellowColour
									WHEN ric11.GYRRedMax IS NULL AND ROUND(CoastOutOfGear*100, ric11.Rounding) < ric11.GYRAmberMax THEN @RedColour
									WHEN ric11.GYRRedMax IS NOT NULL AND ROUND(CoastOutOfGear*100, ric11.Rounding) >= ric11.GYRRedMax THEN @GoldColour
									WHEN ric11.GYRRedMax IS NOT NULL AND ROUND(CoastOutOfGear*100, ric11.Rounding) >= ric11.GYRAmberMax AND ROUND(CoastOutOfGear*100, ric11.Rounding) < ric11.GYRRedMax THEN @SilverColour
									WHEN ric11.GYRRedMax is NOT NULL AND ROUND(CoastOutOfGear*100, ric11.Rounding) >= ric11.GYRGreenMax AND ROUND(CoastOutOfGear*100, ric11.Rounding) < ric11.GYRAmberMax THEN @BronzeColour
									WHEN ric11.GYRRedMax IS NOT NULL AND ROUND(CoastOutOfGear*100, ric11.Rounding) < ric11.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric11.GYRAmberMax = 0 AND ric11.GYRGreenMax = 0 AND ISNULL(ric11.GYRRedMax,0) = 0 THEN NULL
									WHEN ric11.GYRRedMAX IS NULL AND ROUND(CoastOutOfGear*100, ric11.Rounding) <= ric11.GYRAmberMax THEN @GreenColour
									WHEN ric11.GYRRedMax IS NULL AND ROUND(CoastOutOfGear*100, ric11.Rounding) <= ric11.GYRGreenMax AND ROUND(CoastOutOfGear*100, ric11.Rounding) > ric11.GYRAmberMax THEN @YellowColour
									WHEN ric11.GYRRedMax IS NULL AND ROUND(CoastOutOfGear*100, ric11.Rounding) > ric11.GYRGreenMax THEN @RedColour
									WHEN ric11.GYRRedMax IS NOT NULL AND ROUND(CoastOutOfGear*100, ric11.Rounding) <= ric11.GYRRedMax THEN @GoldColour
									WHEN ric11.GYRRedMax IS NOT NULL AND ROUND(CoastOutOfGear*100, ric11.Rounding) <= ric11.GYRAmberMax AND ROUND(CoastOutOfGear*100, ric11.Rounding) > ric11.GYRRedMax THEN @SilverColour
									WHEN ric11.GYRRedMAx IS NOT NULL AND ROUND(CoastOutOfGear*100, ric11.Rounding) <= ric11.GYRGreenMax AND ROUND(CoastOutOfGear*100, ric11.Rounding) > ric11.GYRAmberMax THEN @BronzeColour
									WHEN ric11.GYRRedMax IS NOT NULL AND ROUND(CoastOutOfGear*100, ric11.Rounding) > ric11.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	HarshBrakingColour =
		CASE ric12.HighLow	WHEN 1 THEN
								CASE
									WHEN ric12.GYRAmberMax = 0 AND ric12.GYRGreenMax = 0 AND ISNULL(ric12.GYRRedMax,0) = 0 THEN NULL
									WHEN ric12.GYRRedMax IS NULL AND ROUND(HarshBraking, ric12.Rounding) >= ric12.GYRGreenMax THEN @GreenColour
									WHEN ric12.GYRRedMax IS NULL AND ROUND(HarshBraking, ric12.Rounding) >= ric12.GYRAmberMax AND ROUND(HarshBraking, ric12.Rounding) < ric12.GYRGreenMax THEN @YellowColour
									WHEN ric12.GYRRedMax IS NULL AND ROUND(HarshBraking, ric12.Rounding) < ric12.GYRAmberMax THEN @RedColour
									WHEN ric12.GYRRedMax IS NOT NULL AND ROUND(HarshBraking, ric12.Rounding) >= ric12.GYRRedMax THEN @GoldColour
									WHEN ric12.GYRRedMax IS NOT NULL AND ROUND(HarshBraking, ric12.Rounding) >= ric12.GYRAmberMax AND ROUND(HarshBraking, ric12.Rounding) < ric12.GYRRedMax THEN @SilverColour
									WHEN ric12.GYRRedMax is NOT NULL AND ROUND(HarshBraking, ric12.Rounding) >= ric12.GYRGreenMax AND ROUND(HarshBraking, ric12.Rounding) < ric12.GYRAmberMax THEN @BronzeColour
									WHEN ric12.GYRRedMax IS NOT NULL AND ROUND(HarshBraking, ric12.Rounding) < ric12.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric12.GYRAmberMax = 0 AND ric12.GYRGreenMax = 0 AND ISNULL(ric12.GYRRedMax,0) = 0 THEN NULL
									WHEN ric12.GYRRedMAX IS NULL AND ROUND(HarshBraking, ric12.Rounding) <= ric12.GYRAmberMax THEN @GreenColour
									WHEN ric12.GYRRedMax IS NULL AND ROUND(HarshBraking, ric12.Rounding) <= ric12.GYRGreenMax AND ROUND(HarshBraking, ric12.Rounding) > ric12.GYRAmberMax THEN @YellowColour
									WHEN ric12.GYRRedMax IS NULL AND ROUND(HarshBraking, ric12.Rounding) > ric12.GYRGreenMax THEN @RedColour
									WHEN ric12.GYRRedMax IS NOT NULL AND ROUND(HarshBraking, ric12.Rounding) <= ric12.GYRRedMax THEN @GoldColour
									WHEN ric12.GYRRedMax IS NOT NULL AND ROUND(HarshBraking, ric12.Rounding) <= ric12.GYRAmberMax AND ROUND(HarshBraking, ric12.Rounding) > ric12.GYRRedMax THEN @SilverColour
									WHEN ric12.GYRRedMAx IS NOT NULL AND ROUND(HarshBraking, ric12.Rounding) <= ric12.GYRGreenMax AND ROUND(HarshBraking, ric12.Rounding) > ric12.GYRAmberMax THEN @BronzeColour
									WHEN ric12.GYRRedMax IS NOT NULL AND ROUND(HarshBraking, ric12.Rounding) > ric12.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	EfficiencyColour =
		CASE ric14.HighLow	WHEN 1 THEN
								CASE
									WHEN ric14.GYRAmberMax = 0 AND ric14.GYRGreenMax = 0 AND ISNULL(ric14.GYRRedMax,0) = 0 THEN NULL
									WHEN ric14.GYRRedMax IS NULL AND ROUND(Efficiency, ric14.Rounding) >= ric14.GYRGreenMax THEN @GreenColour
									WHEN ric14.GYRRedMax IS NULL AND ROUND(Efficiency, ric14.Rounding) >= ric14.GYRAmberMax AND ROUND(Efficiency, ric14.Rounding) < ric14.GYRGreenMax THEN @YellowColour
									WHEN ric14.GYRRedMax IS NULL AND ROUND(Efficiency, ric14.Rounding) < ric14.GYRAmberMax THEN @RedColour
									WHEN ric14.GYRRedMax IS NOT NULL AND ROUND(Efficiency, ric14.Rounding) >= ric14.GYRRedMax THEN @GoldColour
									WHEN ric14.GYRRedMax IS NOT NULL AND ROUND(Efficiency, ric14.Rounding) >= ric14.GYRAmberMax AND ROUND(Efficiency, ric14.Rounding) < ric14.GYRRedMax THEN @SilverColour
									WHEN ric14.GYRRedMax is NOT NULL AND ROUND(Efficiency, ric14.Rounding) >= ric14.GYRGreenMax AND ROUND(Efficiency, ric14.Rounding) < ric14.GYRAmberMax THEN @BronzeColour
									WHEN ric14.GYRRedMax IS NOT NULL AND ROUND(Efficiency, ric14.Rounding) < ric14.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric14.GYRAmberMax = 0 AND ric14.GYRGreenMax = 0 AND ISNULL(ric14.GYRRedMax,0) = 0 THEN NULL
									WHEN ric14.GYRRedMAX IS NULL AND ROUND(Efficiency, ric14.Rounding) <= ric14.GYRAmberMax THEN @GreenColour
									WHEN ric14.GYRRedMax IS NULL AND ROUND(Efficiency, ric14.Rounding) <= ric14.GYRGreenMax AND ROUND(Efficiency, ric14.Rounding) > ric14.GYRAmberMax THEN @YellowColour
									WHEN ric14.GYRRedMax IS NULL AND ROUND(Efficiency, ric14.Rounding) > ric14.GYRGreenMax THEN @RedColour
									WHEN ric14.GYRRedMax IS NOT NULL AND ROUND(Efficiency, ric14.Rounding) <= ric14.GYRRedMax THEN @GoldColour
									WHEN ric14.GYRRedMax IS NOT NULL AND ROUND(Efficiency, ric14.Rounding) <= ric14.GYRAmberMax AND ROUND(Efficiency, ric14.Rounding) > ric14.GYRRedMax THEN @SilverColour
									WHEN ric14.GYRRedMAx IS NOT NULL AND ROUND(Efficiency, ric14.Rounding) <= ric14.GYRGreenMax AND ROUND(Efficiency, ric14.Rounding) > ric14.GYRAmberMax THEN @BronzeColour
									WHEN ric14.GYRRedMax IS NOT NULL AND ROUND(Efficiency, ric14.Rounding) > ric14.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	SafetyColour =
		CASE ric15.HighLow	WHEN 1 THEN
								CASE
									WHEN ric15.GYRAmberMax = 0 AND ric15.GYRGreenMax = 0 AND ISNULL(ric15.GYRRedMax,0) = 0 THEN NULL
									WHEN ric15.GYRRedMax IS NULL AND ROUND(Safety, ric15.Rounding) >= ric15.GYRGreenMax THEN @GreenColour
									WHEN ric15.GYRRedMax IS NULL AND ROUND(Safety, ric15.Rounding) >= ric15.GYRAmberMax AND ROUND(Safety, ric15.Rounding) < ric15.GYRGreenMax THEN @YellowColour
									WHEN ric15.GYRRedMax IS NULL AND ROUND(Safety, ric15.Rounding) < ric15.GYRAmberMax THEN @RedColour
									WHEN ric15.GYRRedMax IS NOT NULL AND ROUND(Safety, ric15.Rounding) >= ric15.GYRRedMax THEN @GoldColour
									WHEN ric15.GYRRedMax IS NOT NULL AND ROUND(Safety, ric15.Rounding) >= ric15.GYRAmberMax AND ROUND(Safety, ric15.Rounding) < ric15.GYRRedMax THEN @SilverColour
									WHEN ric15.GYRRedMax is NOT NULL AND ROUND(Safety, ric15.Rounding) >= ric15.GYRGreenMax AND ROUND(Safety, ric15.Rounding) < ric15.GYRAmberMax THEN @BronzeColour
									WHEN ric15.GYRRedMax IS NOT NULL AND ROUND(Safety, ric15.Rounding) < ric15.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric15.GYRAmberMax = 0 AND ric15.GYRGreenMax = 0 AND ISNULL(ric15.GYRRedMax,0) = 0 THEN NULL
									WHEN ric15.GYRRedMAX IS NULL AND ROUND(Safety, ric15.Rounding) <= ric15.GYRAmberMax THEN @GreenColour
									WHEN ric15.GYRRedMax IS NULL AND ROUND(Safety, ric15.Rounding) <= ric15.GYRGreenMax AND ROUND(Safety, ric15.Rounding) > ric15.GYRAmberMax THEN @YellowColour
									WHEN ric15.GYRRedMax IS NULL AND ROUND(Safety, ric15.Rounding) > ric15.GYRGreenMax THEN @RedColour
									WHEN ric15.GYRRedMax IS NOT NULL AND ROUND(Safety, ric15.Rounding) <= ric15.GYRRedMax THEN @GoldColour
									WHEN ric15.GYRRedMax IS NOT NULL AND ROUND(Safety, ric15.Rounding) <= ric15.GYRAmberMax AND ROUND(Safety, ric15.Rounding) > ric15.GYRRedMax THEN @SilverColour
									WHEN ric15.GYRRedMAx IS NOT NULL AND ROUND(Safety, ric15.Rounding) <= ric15.GYRGreenMax AND ROUND(Safety, ric15.Rounding) > ric15.GYRAmberMax THEN @BronzeColour
									WHEN ric15.GYRRedMax IS NOT NULL AND ROUND(Safety, ric15.Rounding) > ric15.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	KPLColour = 
		CASE ric16.HighLow	WHEN 1 THEN
								CASE
									WHEN ric16.GYRAmberMax = 0 AND ric16.GYRGreenMax = 0 AND ISNULL(ric16.GYRRedMax,0) = 0 THEN NULL
									WHEN ric16.GYRRedMax IS NULL AND ROUND(FuelEcon, ric16.Rounding) >= ric16.GYRGreenMax THEN @GreenColour
									WHEN ric16.GYRRedMax IS NULL AND ROUND(FuelEcon, ric16.Rounding) >= ric16.GYRAmberMax AND ROUND(FuelEcon, ric16.Rounding) < ric16.GYRGreenMax THEN @YellowColour
									WHEN ric16.GYRRedMax IS NULL AND ROUND(FuelEcon, ric16.Rounding) < ric16.GYRAmberMax THEN @RedColour
									WHEN ric16.GYRRedMax IS NOT NULL AND ROUND(FuelEcon, ric16.Rounding) >= ric16.GYRRedMax THEN @GoldColour
									WHEN ric16.GYRRedMax IS NOT NULL AND ROUND(FuelEcon, ric16.Rounding) >= ric16.GYRAmberMax AND ROUND(FuelEcon, ric16.Rounding) < ric16.GYRRedMax THEN @SilverColour
									WHEN ric16.GYRRedMax is NOT NULL AND ROUND(FuelEcon, ric16.Rounding) >= ric16.GYRGreenMax AND ROUND(FuelEcon, ric16.Rounding) < ric16.GYRAmberMax THEN @BronzeColour
									WHEN ric16.GYRRedMax IS NOT NULL AND ROUND(FuelEcon, ric16.Rounding) < ric16.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric16.GYRAmberMax = 0 AND ric16.GYRGreenMax = 0 AND ISNULL(ric16.GYRRedMax,0) = 0 THEN NULL
									WHEN ric16.GYRRedMAX IS NULL AND ROUND(FuelEcon, ric16.Rounding) <= ric16.GYRAmberMax THEN @GreenColour
									WHEN ric16.GYRRedMax IS NULL AND ROUND(FuelEcon, ric16.Rounding) <= ric16.GYRGreenMax AND ROUND(FuelEcon, ric16.Rounding) > ric16.GYRAmberMax THEN @YellowColour
									WHEN ric16.GYRRedMax IS NULL AND ROUND(FuelEcon, ric16.Rounding) > ric16.GYRGreenMax THEN @RedColour
									WHEN ric16.GYRRedMax IS NOT NULL AND ROUND(FuelEcon, ric16.Rounding) <= ric16.GYRRedMax THEN @GoldColour
									WHEN ric16.GYRRedMax IS NOT NULL AND ROUND(FuelEcon, ric16.Rounding) <= ric16.GYRAmberMax AND ROUND(FuelEcon, ric16.Rounding) > ric16.GYRRedMax THEN @SilverColour
									WHEN ric16.GYRRedMAx IS NOT NULL AND ROUND(FuelEcon, ric16.Rounding) <= ric16.GYRGreenMax AND ROUND(FuelEcon, ric16.Rounding) > ric16.GYRAmberMax THEN @BronzeColour
									WHEN ric16.GYRRedMax IS NOT NULL AND ROUND(FuelEcon, ric16.Rounding) > ric16.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	Co2Colour =
		CASE ric20.HighLow	WHEN 1 THEN
								CASE
									WHEN ric20.GYRAmberMax = 0 AND ric20.GYRGreenMax = 0 AND ISNULL(ric20.GYRRedMax,0) = 0 THEN NULL
									WHEN ric20.GYRRedMax IS NULL AND ROUND(Co2, ric20.Rounding) >= ric20.GYRGreenMax THEN @GreenColour
									WHEN ric20.GYRRedMax IS NULL AND ROUND(Co2, ric20.Rounding) >= ric20.GYRAmberMax AND ROUND(Co2, ric20.Rounding) < ric20.GYRGreenMax THEN @YellowColour
									WHEN ric20.GYRRedMax IS NULL AND ROUND(Co2, ric20.Rounding) < ric20.GYRAmberMax THEN @RedColour
									WHEN ric20.GYRRedMax IS NOT NULL AND ROUND(Co2, ric20.Rounding) >= ric20.GYRRedMax THEN @GoldColour
									WHEN ric20.GYRRedMax IS NOT NULL AND ROUND(Co2, ric20.Rounding) >= ric20.GYRAmberMax AND ROUND(Co2, ric20.Rounding) < ric20.GYRRedMax THEN @SilverColour
									WHEN ric20.GYRRedMax is NOT NULL AND ROUND(Co2, ric20.Rounding) >= ric20.GYRGreenMax AND ROUND(Co2, ric20.Rounding) < ric20.GYRAmberMax THEN @BronzeColour
									WHEN ric20.GYRRedMax IS NOT NULL AND ROUND(Co2, ric20.Rounding) < ric20.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric20.GYRAmberMax = 0 AND ric20.GYRGreenMax = 0 AND ISNULL(ric20.GYRRedMax,0) = 0 THEN NULL
									WHEN ric20.GYRRedMAX IS NULL AND ROUND(Co2, ric20.Rounding) <= ric20.GYRAmberMax THEN @GreenColour
									WHEN ric20.GYRRedMax IS NULL AND ROUND(Co2, ric20.Rounding) <= ric20.GYRGreenMax AND ROUND(Co2, ric20.Rounding) > ric20.GYRAmberMax THEN @YellowColour
									WHEN ric20.GYRRedMax IS NULL AND ROUND(Co2, ric20.Rounding) > ric20.GYRGreenMax THEN @RedColour
									WHEN ric20.GYRRedMax IS NOT NULL AND ROUND(Co2, ric20.Rounding) <= ric20.GYRRedMax THEN @GoldColour
									WHEN ric20.GYRRedMax IS NOT NULL AND ROUND(Co2, ric20.Rounding) <= ric20.GYRAmberMax AND ROUND(Co2, ric20.Rounding) > ric20.GYRRedMax THEN @SilverColour
									WHEN ric20.GYRRedMAx IS NOT NULL AND ROUND(Co2, ric20.Rounding) <= ric20.GYRGreenMax AND ROUND(Co2, ric20.Rounding) > ric20.GYRAmberMax THEN @BronzeColour
									WHEN ric20.GYRRedMax IS NOT NULL AND ROUND(Co2, ric20.Rounding) > ric20.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	OverSpeedDistanceColour =
		CASE ric21.HighLow	WHEN 1 THEN
								CASE
									WHEN ric21.GYRAmberMax = 0 AND ric21.GYRGreenMax = 0 AND ISNULL(ric21.GYRRedMax,0) = 0 THEN NULL
									WHEN ric21.GYRRedMax IS NULL AND ROUND(OverSpeedDistance*100, ric21.Rounding) >= ric21.GYRGreenMax THEN @GreenColour
									WHEN ric21.GYRRedMax IS NULL AND ROUND(OverSpeedDistance*100, ric21.Rounding) >= ric21.GYRAmberMax AND ROUND(OverSpeedDistance*100, ric21.Rounding) < ric21.GYRGreenMax THEN @YellowColour
									WHEN ric21.GYRRedMax IS NULL AND ROUND(OverSpeedDistance*100, ric21.Rounding) < ric21.GYRAmberMax THEN @RedColour
									WHEN ric21.GYRRedMax IS NOT NULL AND ROUND(OverSpeedDistance*100, ric21.Rounding) >= ric21.GYRRedMax THEN @GoldColour
									WHEN ric21.GYRRedMax IS NOT NULL AND ROUND(OverSpeedDistance*100, ric21.Rounding) >= ric21.GYRAmberMax AND ROUND(OverSpeedDistance*100, ric21.Rounding) < ric21.GYRRedMax THEN @SilverColour
									WHEN ric21.GYRRedMax is NOT NULL AND ROUND(OverSpeedDistance*100, ric21.Rounding) >= ric21.GYRGreenMax AND ROUND(OverSpeedDistance*100, ric21.Rounding) < ric21.GYRAmberMax THEN @BronzeColour
									WHEN ric21.GYRRedMax IS NOT NULL AND ROUND(OverSpeedDistance*100, ric21.Rounding) < ric21.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric21.GYRAmberMax = 0 AND ric21.GYRGreenMax = 0 AND ISNULL(ric21.GYRRedMax,0) = 0 THEN NULL
									WHEN ric21.GYRRedMAX IS NULL AND ROUND(OverSpeedDistance*100, ric21.Rounding) <= ric21.GYRAmberMax THEN @GreenColour
									WHEN ric21.GYRRedMax IS NULL AND ROUND(OverSpeedDistance*100, ric21.Rounding) <= ric21.GYRGreenMax AND ROUND(OverSpeedDistance*100, ric21.Rounding) > ric21.GYRAmberMax THEN @YellowColour
									WHEN ric21.GYRRedMax IS NULL AND ROUND(OverSpeedDistance*100, ric21.Rounding) > ric21.GYRGreenMax THEN @RedColour
									WHEN ric21.GYRRedMax IS NOT NULL AND ROUND(OverSpeedDistance*100, ric21.Rounding) <= ric21.GYRRedMax THEN @GoldColour
									WHEN ric21.GYRRedMax IS NOT NULL AND ROUND(OverSpeedDistance*100, ric21.Rounding) <= ric21.GYRAmberMax AND ROUND(OverSpeedDistance*100, ric21.Rounding) > ric21.GYRRedMax THEN @SilverColour
									WHEN ric21.GYRRedMAx IS NOT NULL AND ROUND(OverSpeedDistance*100, ric21.Rounding) <= ric21.GYRGreenMax AND ROUND(OverSpeedDistance*100, ric21.Rounding) > ric21.GYRAmberMax THEN @BronzeColour
									WHEN ric21.GYRRedMax IS NOT NULL AND ROUND(OverSpeedDistance*100, ric21.Rounding) > ric21.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	AccelerationColour =
		CASE ric22.HighLow	WHEN 1 THEN
								CASE
									WHEN ric22.GYRAmberMax = 0 AND ric22.GYRGreenMax = 0 AND ISNULL(ric22.GYRRedMax,0) = 0 THEN NULL
									WHEN ric22.GYRRedMax IS NULL AND ROUND(Acceleration, ric22.Rounding) >= ric22.GYRGreenMax THEN @GreenColour
									WHEN ric22.GYRRedMax IS NULL AND ROUND(Acceleration, ric22.Rounding) >= ric22.GYRAmberMax AND ROUND(Acceleration, ric22.Rounding) < ric22.GYRGreenMax THEN @YellowColour
									WHEN ric22.GYRRedMax IS NULL AND ROUND(Acceleration, ric22.Rounding) < ric22.GYRAmberMax THEN @RedColour
									WHEN ric22.GYRRedMax IS NOT NULL AND ROUND(Acceleration, ric22.Rounding) >= ric22.GYRRedMax THEN @GoldColour
									WHEN ric22.GYRRedMax IS NOT NULL AND ROUND(Acceleration, ric22.Rounding) >= ric22.GYRAmberMax AND ROUND(Acceleration, ric22.Rounding) < ric22.GYRRedMax THEN @SilverColour
									WHEN ric22.GYRRedMax is NOT NULL AND ROUND(Acceleration, ric22.Rounding) >= ric22.GYRGreenMax AND ROUND(Acceleration, ric22.Rounding) < ric22.GYRAmberMax THEN @BronzeColour
									WHEN ric22.GYRRedMax IS NOT NULL AND ROUND(Acceleration, ric22.Rounding) < ric22.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric22.GYRAmberMax = 0 AND ric22.GYRGreenMax = 0 AND ISNULL(ric22.GYRRedMax,0) = 0 THEN NULL
									WHEN ric22.GYRRedMAX IS NULL AND ROUND(Acceleration, ric22.Rounding) <= ric22.GYRAmberMax THEN @GreenColour
									WHEN ric22.GYRRedMax IS NULL AND ROUND(Acceleration, ric22.Rounding) <= ric22.GYRGreenMax AND ROUND(Acceleration, ric22.Rounding) > ric22.GYRAmberMax THEN @YellowColour
									WHEN ric22.GYRRedMax IS NULL AND ROUND(Acceleration, ric22.Rounding) > ric22.GYRGreenMax THEN @RedColour
									WHEN ric22.GYRRedMax IS NOT NULL AND ROUND(Acceleration, ric22.Rounding) <= ric22.GYRRedMax THEN @GoldColour
									WHEN ric22.GYRRedMax IS NOT NULL AND ROUND(Acceleration, ric22.Rounding) <= ric22.GYRAmberMax AND ROUND(Acceleration, ric22.Rounding) > ric22.GYRRedMax THEN @SilverColour
									WHEN ric22.GYRRedMAx IS NOT NULL AND ROUND(Acceleration, ric22.Rounding) <= ric22.GYRGreenMax AND ROUND(Acceleration, ric22.Rounding) > ric22.GYRAmberMax THEN @BronzeColour
									WHEN ric22.GYRRedMax IS NOT NULL AND ROUND(Acceleration, ric22.Rounding) > ric22.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	BrakingColour =
		CASE ric23.HighLow	WHEN 1 THEN
								CASE
									WHEN ric23.GYRAmberMax = 0 AND ric23.GYRGreenMax = 0 AND ISNULL(ric23.GYRRedMax,0) = 0 THEN NULL
									WHEN ric23.GYRRedMax IS NULL AND ROUND(Braking, ric23.Rounding) >= ric23.GYRGreenMax THEN @GreenColour
									WHEN ric23.GYRRedMax IS NULL AND ROUND(Braking, ric23.Rounding) >= ric23.GYRAmberMax AND ROUND(Braking, ric23.Rounding) < ric23.GYRGreenMax THEN @YellowColour
									WHEN ric23.GYRRedMax IS NULL AND ROUND(Braking, ric23.Rounding) < ric23.GYRAmberMax THEN @RedColour
									WHEN ric23.GYRRedMax IS NOT NULL AND ROUND(Braking, ric23.Rounding) >= ric23.GYRRedMax THEN @GoldColour
									WHEN ric23.GYRRedMax IS NOT NULL AND ROUND(Braking, ric23.Rounding) >= ric23.GYRAmberMax AND ROUND(Braking, ric23.Rounding) < ric23.GYRRedMax THEN @SilverColour
									WHEN ric23.GYRRedMax is NOT NULL AND ROUND(Braking, ric23.Rounding) >= ric23.GYRGreenMax AND ROUND(Braking, ric23.Rounding) < ric23.GYRAmberMax THEN @BronzeColour
									WHEN ric23.GYRRedMax IS NOT NULL AND ROUND(Braking, ric23.Rounding) < ric23.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric23.GYRAmberMax = 0 AND ric23.GYRGreenMax = 0 AND ISNULL(ric23.GYRRedMax,0) = 0 THEN NULL
									WHEN ric23.GYRRedMAX IS NULL AND ROUND(Braking, ric23.Rounding) <= ric23.GYRAmberMax THEN @GreenColour
									WHEN ric23.GYRRedMax IS NULL AND ROUND(Braking, ric23.Rounding) <= ric23.GYRGreenMax AND ROUND(Braking, ric23.Rounding) > ric23.GYRAmberMax THEN @YellowColour
									WHEN ric23.GYRRedMax IS NULL AND ROUND(Braking, ric23.Rounding) > ric23.GYRGreenMax THEN @RedColour
									WHEN ric23.GYRRedMax IS NOT NULL AND ROUND(Braking, ric23.Rounding) <= ric23.GYRRedMax THEN @GoldColour
									WHEN ric23.GYRRedMax IS NOT NULL AND ROUND(Braking, ric23.Rounding) <= ric23.GYRAmberMax AND ROUND(Braking, ric23.Rounding) > ric23.GYRRedMax THEN @SilverColour
									WHEN ric23.GYRRedMAx IS NOT NULL AND ROUND(Braking, ric23.Rounding) <= ric23.GYRGreenMax AND ROUND(Braking, ric23.Rounding) > ric23.GYRAmberMax THEN @BronzeColour
									WHEN ric23.GYRRedMax IS NOT NULL AND ROUND(Braking, ric23.Rounding) > ric23.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	CorneringColour =
		CASE ric24.HighLow	WHEN 1 THEN
								CASE
									WHEN ric24.GYRAmberMax = 0 AND ric24.GYRGreenMax = 0 AND ISNULL(ric24.GYRRedMax,0) = 0 THEN NULL
									WHEN ric24.GYRRedMax IS NULL AND ROUND(Cornering, ric24.Rounding) >= ric24.GYRGreenMax THEN @GreenColour
									WHEN ric24.GYRRedMax IS NULL AND ROUND(Cornering, ric24.Rounding) >= ric24.GYRAmberMax AND ROUND(Cornering, ric24.Rounding) < ric24.GYRGreenMax THEN @YellowColour
									WHEN ric24.GYRRedMax IS NULL AND ROUND(Cornering, ric24.Rounding) < ric24.GYRAmberMax THEN @RedColour
									WHEN ric24.GYRRedMax IS NOT NULL AND ROUND(Cornering, ric24.Rounding) >= ric24.GYRRedMax THEN @GoldColour
									WHEN ric24.GYRRedMax IS NOT NULL AND ROUND(Cornering, ric24.Rounding) >= ric24.GYRAmberMax AND ROUND(Cornering, ric24.Rounding) < ric24.GYRRedMax THEN @SilverColour
									WHEN ric24.GYRRedMax is NOT NULL AND ROUND(Cornering, ric24.Rounding) >= ric24.GYRGreenMax AND ROUND(Cornering, ric24.Rounding) < ric24.GYRAmberMax THEN @BronzeColour
									WHEN ric24.GYRRedMax IS NOT NULL AND ROUND(Cornering, ric24.Rounding) < ric24.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric24.GYRAmberMax = 0 AND ric24.GYRGreenMax = 0 AND ISNULL(ric24.GYRRedMax,0) = 0 THEN NULL
									WHEN ric24.GYRRedMAX IS NULL AND ROUND(Cornering, ric24.Rounding) <= ric24.GYRAmberMax THEN @GreenColour
									WHEN ric24.GYRRedMax IS NULL AND ROUND(Cornering, ric24.Rounding) <= ric24.GYRGreenMax AND ROUND(Cornering, ric24.Rounding) > ric24.GYRAmberMax THEN @YellowColour
									WHEN ric24.GYRRedMax IS NULL AND ROUND(Cornering, ric24.Rounding) > ric24.GYRGreenMax THEN @RedColour
									WHEN ric24.GYRRedMax IS NOT NULL AND ROUND(Cornering, ric24.Rounding) <= ric24.GYRRedMax THEN @GoldColour
									WHEN ric24.GYRRedMax IS NOT NULL AND ROUND(Cornering, ric24.Rounding) <= ric24.GYRAmberMax AND ROUND(Cornering, ric24.Rounding) > ric24.GYRRedMax THEN @SilverColour
									WHEN ric24.GYRRedMAx IS NOT NULL AND ROUND(Cornering, ric24.Rounding) <= ric24.GYRGreenMax AND ROUND(Cornering, ric24.Rounding) > ric24.GYRAmberMax THEN @BronzeColour
									WHEN ric24.GYRRedMax IS NOT NULL AND ROUND(Cornering, ric24.Rounding) > ric24.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	AccelerationLowColour =
		CASE ric33.HighLow	WHEN 1 THEN
								CASE
									WHEN ric33.GYRAmberMax = 0 AND ric33.GYRGreenMax = 0 AND ISNULL(ric33.GYRRedMax,0) = 0 THEN NULL
									WHEN ric33.GYRRedMax IS NULL AND ROUND(AccelerationLow, ric33.Rounding) >= ric33.GYRGreenMax THEN @GreenColour
									WHEN ric33.GYRRedMax IS NULL AND ROUND(AccelerationLow, ric33.Rounding) >= ric33.GYRAmberMax AND ROUND(AccelerationLow, ric33.Rounding) < ric33.GYRGreenMax THEN @YellowColour
									WHEN ric33.GYRRedMax IS NULL AND ROUND(AccelerationLow, ric33.Rounding) < ric33.GYRAmberMax THEN @RedColour
									WHEN ric33.GYRRedMax IS NOT NULL AND ROUND(AccelerationLow, ric33.Rounding) >= ric33.GYRRedMax THEN @GoldColour
									WHEN ric33.GYRRedMax IS NOT NULL AND ROUND(AccelerationLow, ric33.Rounding) >= ric33.GYRAmberMax AND ROUND(AccelerationLow, ric33.Rounding) < ric33.GYRRedMax THEN @SilverColour
									WHEN ric33.GYRRedMax is NOT NULL AND ROUND(AccelerationLow, ric33.Rounding) >= ric33.GYRGreenMax AND ROUND(AccelerationLow, ric33.Rounding) < ric33.GYRAmberMax THEN @BronzeColour
									WHEN ric33.GYRRedMax IS NOT NULL AND ROUND(AccelerationLow, ric33.Rounding) < ric33.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric33.GYRAmberMax = 0 AND ric33.GYRGreenMax = 0 AND ISNULL(ric33.GYRRedMax,0) = 0 THEN NULL
									WHEN ric33.GYRRedMAX IS NULL AND ROUND(AccelerationLow, ric33.Rounding) <= ric33.GYRAmberMax THEN @GreenColour
									WHEN ric33.GYRRedMax IS NULL AND ROUND(AccelerationLow, ric33.Rounding) <= ric33.GYRGreenMax AND ROUND(AccelerationLow, ric33.Rounding) > ric33.GYRAmberMax THEN @YellowColour
									WHEN ric33.GYRRedMax IS NULL AND ROUND(AccelerationLow, ric33.Rounding) > ric33.GYRGreenMax THEN @RedColour
									WHEN ric33.GYRRedMax IS NOT NULL AND ROUND(AccelerationLow, ric33.Rounding) <= ric33.GYRRedMax THEN @GoldColour
									WHEN ric33.GYRRedMax IS NOT NULL AND ROUND(AccelerationLow, ric33.Rounding) <= ric33.GYRAmberMax AND ROUND(AccelerationLow, ric33.Rounding) > ric33.GYRRedMax THEN @SilverColour
									WHEN ric33.GYRRedMAx IS NOT NULL AND ROUND(AccelerationLow, ric33.Rounding) <= ric33.GYRGreenMax AND ROUND(AccelerationLow, ric33.Rounding) > ric33.GYRAmberMax THEN @BronzeColour
									WHEN ric33.GYRRedMax IS NOT NULL AND ROUND(AccelerationLow, ric33.Rounding) > ric33.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	BrakingLowColour = 
		CASE ric34.HighLow	WHEN 1 THEN
								CASE
									WHEN ric34.GYRAmberMax = 0 AND ric34.GYRGreenMax = 0 AND ISNULL(ric34.GYRRedMax,0) = 0 THEN NULL
									WHEN ric34.GYRRedMax IS NULL AND ROUND(BrakingLow, ric34.Rounding) >= ric34.GYRGreenMax THEN @GreenColour
									WHEN ric34.GYRRedMax IS NULL AND ROUND(BrakingLow, ric34.Rounding) >= ric34.GYRAmberMax AND ROUND(BrakingLow, ric34.Rounding) < ric34.GYRGreenMax THEN @YellowColour
									WHEN ric34.GYRRedMax IS NULL AND ROUND(BrakingLow, ric34.Rounding) < ric34.GYRAmberMax THEN @RedColour
									WHEN ric34.GYRRedMax IS NOT NULL AND ROUND(BrakingLow, ric34.Rounding) >= ric34.GYRRedMax THEN @GoldColour
									WHEN ric34.GYRRedMax IS NOT NULL AND ROUND(BrakingLow, ric34.Rounding) >= ric34.GYRAmberMax AND ROUND(BrakingLow, ric34.Rounding) < ric34.GYRRedMax THEN @SilverColour
									WHEN ric34.GYRRedMax is NOT NULL AND ROUND(BrakingLow, ric34.Rounding) >= ric34.GYRGreenMax AND ROUND(BrakingLow, ric34.Rounding) < ric34.GYRAmberMax THEN @BronzeColour
									WHEN ric34.GYRRedMax IS NOT NULL AND ROUND(BrakingLow, ric34.Rounding) < ric34.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric34.GYRAmberMax = 0 AND ric34.GYRGreenMax = 0 AND ISNULL(ric34.GYRRedMax,0) = 0 THEN NULL
									WHEN ric34.GYRRedMAX IS NULL AND ROUND(BrakingLow, ric34.Rounding) <= ric34.GYRAmberMax THEN @GreenColour
									WHEN ric34.GYRRedMax IS NULL AND ROUND(BrakingLow, ric34.Rounding) <= ric34.GYRGreenMax AND ROUND(BrakingLow, ric34.Rounding) > ric34.GYRAmberMax THEN @YellowColour
									WHEN ric34.GYRRedMax IS NULL AND ROUND(BrakingLow, ric34.Rounding) > ric34.GYRGreenMax THEN @RedColour
									WHEN ric34.GYRRedMax IS NOT NULL AND ROUND(BrakingLow, ric34.Rounding) <= ric34.GYRRedMax THEN @GoldColour
									WHEN ric34.GYRRedMax IS NOT NULL AND ROUND(BrakingLow, ric34.Rounding) <= ric34.GYRAmberMax AND ROUND(BrakingLow, ric34.Rounding) > ric34.GYRRedMax THEN @SilverColour
									WHEN ric34.GYRRedMAx IS NOT NULL AND ROUND(BrakingLow, ric34.Rounding) <= ric34.GYRGreenMax AND ROUND(BrakingLow, ric34.Rounding) > ric34.GYRAmberMax THEN @BronzeColour
									WHEN ric34.GYRRedMax IS NOT NULL AND ROUND(BrakingLow, ric34.Rounding) > ric34.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	CorneringLowColour =
		CASE ric35.HighLow	WHEN 1 THEN
								CASE
									WHEN ric35.GYRAmberMax = 0 AND ric35.GYRGreenMax = 0 AND ISNULL(ric35.GYRRedMax,0) = 0 THEN NULL
									WHEN ric35.GYRRedMax IS NULL AND ROUND(CorneringLow, ric35.Rounding) >= ric35.GYRGreenMax THEN @GreenColour
									WHEN ric35.GYRRedMax IS NULL AND ROUND(CorneringLow, ric35.Rounding) >= ric35.GYRAmberMax AND ROUND(CorneringLow, ric35.Rounding) < ric35.GYRGreenMax THEN @YellowColour
									WHEN ric35.GYRRedMax IS NULL AND ROUND(CorneringLow, ric35.Rounding) < ric35.GYRAmberMax THEN @RedColour
									WHEN ric35.GYRRedMax IS NOT NULL AND ROUND(CorneringLow, ric35.Rounding) >= ric35.GYRRedMax THEN @GoldColour
									WHEN ric35.GYRRedMax IS NOT NULL AND ROUND(CorneringLow, ric35.Rounding) >= ric35.GYRAmberMax AND ROUND(CorneringLow, ric35.Rounding) < ric35.GYRRedMax THEN @SilverColour
									WHEN ric35.GYRRedMax is NOT NULL AND ROUND(CorneringLow, ric35.Rounding) >= ric35.GYRGreenMax AND ROUND(CorneringLow, ric35.Rounding) < ric35.GYRAmberMax THEN @BronzeColour
									WHEN ric35.GYRRedMax IS NOT NULL AND ROUND(CorneringLow, ric35.Rounding) < ric35.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric35.GYRAmberMax = 0 AND ric35.GYRGreenMax = 0 AND ISNULL(ric35.GYRRedMax,0) = 0 THEN NULL
									WHEN ric35.GYRRedMAX IS NULL AND ROUND(CorneringLow, ric35.Rounding) <= ric35.GYRAmberMax THEN @GreenColour
									WHEN ric35.GYRRedMax IS NULL AND ROUND(CorneringLow, ric35.Rounding) <= ric35.GYRGreenMax AND ROUND(CorneringLow, ric35.Rounding) > ric35.GYRAmberMax THEN @YellowColour
									WHEN ric35.GYRRedMax IS NULL AND ROUND(CorneringLow, ric35.Rounding) > ric35.GYRGreenMax THEN @RedColour
									WHEN ric35.GYRRedMax IS NOT NULL AND ROUND(CorneringLow, ric35.Rounding) <= ric35.GYRRedMax THEN @GoldColour
									WHEN ric35.GYRRedMax IS NOT NULL AND ROUND(CorneringLow, ric35.Rounding) <= ric35.GYRAmberMax AND ROUND(CorneringLow, ric35.Rounding) > ric35.GYRRedMax THEN @SilverColour
									WHEN ric35.GYRRedMAx IS NOT NULL AND ROUND(CorneringLow, ric35.Rounding) <= ric35.GYRGreenMax AND ROUND(CorneringLow, ric35.Rounding) > ric35.GYRAmberMax THEN @BronzeColour
									WHEN ric35.GYRRedMax IS NOT NULL AND ROUND(CorneringLow, ric35.Rounding) > ric35.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	AccelerationHighColour =
		CASE ric36.HighLow	WHEN 1 THEN
								CASE
									WHEN ric36.GYRAmberMax = 0 AND ric36.GYRGreenMax = 0 AND ISNULL(ric36.GYRRedMax,0) = 0 THEN NULL
									WHEN ric36.GYRRedMax IS NULL AND ROUND(AccelerationHigh, ric36.Rounding) >= ric36.GYRGreenMax THEN @GreenColour
									WHEN ric36.GYRRedMax IS NULL AND ROUND(AccelerationHigh, ric36.Rounding) >= ric36.GYRAmberMax AND ROUND(AccelerationHigh, ric36.Rounding) < ric36.GYRGreenMax THEN @YellowColour
									WHEN ric36.GYRRedMax IS NULL AND ROUND(AccelerationHigh, ric36.Rounding) < ric36.GYRAmberMax THEN @RedColour
									WHEN ric36.GYRRedMax IS NOT NULL AND ROUND(AccelerationHigh, ric36.Rounding) >= ric36.GYRRedMax THEN @GoldColour
									WHEN ric36.GYRRedMax IS NOT NULL AND ROUND(AccelerationHigh, ric36.Rounding) >= ric36.GYRAmberMax AND ROUND(AccelerationHigh, ric36.Rounding) < ric36.GYRRedMax THEN @SilverColour
									WHEN ric36.GYRRedMax is NOT NULL AND ROUND(AccelerationHigh, ric36.Rounding) >= ric36.GYRGreenMax AND ROUND(AccelerationHigh, ric36.Rounding) < ric36.GYRAmberMax THEN @BronzeColour
									WHEN ric36.GYRRedMax IS NOT NULL AND ROUND(AccelerationHigh, ric36.Rounding) < ric36.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric36.GYRAmberMax = 0 AND ric36.GYRGreenMax = 0 AND ISNULL(ric36.GYRRedMax,0) = 0 THEN NULL
									WHEN ric36.GYRRedMAX IS NULL AND ROUND(AccelerationHigh, ric36.Rounding) <= ric36.GYRAmberMax THEN @GreenColour
									WHEN ric36.GYRRedMax IS NULL AND ROUND(AccelerationHigh, ric36.Rounding) <= ric36.GYRGreenMax AND ROUND(AccelerationHigh, ric36.Rounding) > ric36.GYRAmberMax THEN @YellowColour
									WHEN ric36.GYRRedMax IS NULL AND ROUND(AccelerationHigh, ric36.Rounding) > ric36.GYRGreenMax THEN @RedColour
									WHEN ric36.GYRRedMax IS NOT NULL AND ROUND(AccelerationHigh, ric36.Rounding) <= ric36.GYRRedMax THEN @GoldColour
									WHEN ric36.GYRRedMax IS NOT NULL AND ROUND(AccelerationHigh, ric36.Rounding) <= ric36.GYRAmberMax AND ROUND(AccelerationHigh, ric36.Rounding) > ric36.GYRRedMax THEN @SilverColour
									WHEN ric36.GYRRedMAx IS NOT NULL AND ROUND(AccelerationHigh, ric36.Rounding) <= ric36.GYRGreenMax AND ROUND(AccelerationHigh, ric36.Rounding) > ric36.GYRAmberMax THEN @BronzeColour
									WHEN ric36.GYRRedMax IS NOT NULL AND ROUND(AccelerationHigh, ric36.Rounding) > ric36.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	BrakingHighColour =
		CASE ric37.HighLow	WHEN 1 THEN
								CASE
									WHEN ric37.GYRAmberMax = 0 AND ric37.GYRGreenMax = 0 AND ISNULL(ric37.GYRRedMax,0) = 0 THEN NULL
									WHEN ric37.GYRRedMax IS NULL AND ROUND(BrakingHigh, ric37.Rounding) >= ric37.GYRGreenMax THEN @GreenColour
									WHEN ric37.GYRRedMax IS NULL AND ROUND(BrakingHigh, ric37.Rounding) >= ric37.GYRAmberMax AND ROUND(BrakingHigh, ric37.Rounding) < ric37.GYRGreenMax THEN @YellowColour
									WHEN ric37.GYRRedMax IS NULL AND ROUND(BrakingHigh, ric37.Rounding) < ric37.GYRAmberMax THEN @RedColour
									WHEN ric37.GYRRedMax IS NOT NULL AND ROUND(BrakingHigh, ric37.Rounding) >= ric37.GYRRedMax THEN @GoldColour
									WHEN ric37.GYRRedMax IS NOT NULL AND ROUND(BrakingHigh, ric37.Rounding) >= ric37.GYRAmberMax AND ROUND(BrakingHigh, ric37.Rounding) < ric37.GYRRedMax THEN @SilverColour
									WHEN ric37.GYRRedMax is NOT NULL AND ROUND(BrakingHigh, ric37.Rounding) >= ric37.GYRGreenMax AND ROUND(BrakingHigh, ric37.Rounding) < ric37.GYRAmberMax THEN @BronzeColour
									WHEN ric37.GYRRedMax IS NOT NULL AND ROUND(BrakingHigh, ric37.Rounding) < ric37.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric37.GYRAmberMax = 0 AND ric37.GYRGreenMax = 0 AND ISNULL(ric37.GYRRedMax,0) = 0 THEN NULL
									WHEN ric37.GYRRedMAX IS NULL AND ROUND(BrakingHigh, ric37.Rounding) <= ric37.GYRAmberMax THEN @GreenColour
									WHEN ric37.GYRRedMax IS NULL AND ROUND(BrakingHigh, ric37.Rounding) <= ric37.GYRGreenMax AND ROUND(BrakingHigh, ric37.Rounding) > ric37.GYRAmberMax THEN @YellowColour
									WHEN ric37.GYRRedMax IS NULL AND ROUND(BrakingHigh, ric37.Rounding) > ric37.GYRGreenMax THEN @RedColour
									WHEN ric37.GYRRedMax IS NOT NULL AND ROUND(BrakingHigh, ric37.Rounding) <= ric37.GYRRedMax THEN @GoldColour
									WHEN ric37.GYRRedMax IS NOT NULL AND ROUND(BrakingHigh, ric37.Rounding) <= ric37.GYRAmberMax AND ROUND(BrakingHigh, ric37.Rounding) > ric37.GYRRedMax THEN @SilverColour
									WHEN ric37.GYRRedMAx IS NOT NULL AND ROUND(BrakingHigh, ric37.Rounding) <= ric37.GYRGreenMax AND ROUND(BrakingHigh, ric37.Rounding) > ric37.GYRAmberMax THEN @BronzeColour
									WHEN ric37.GYRRedMax IS NOT NULL AND ROUND(BrakingHigh, ric37.Rounding) > ric37.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	CorneringHighColour =
		CASE ric38.HighLow	WHEN 1 THEN
								CASE
									WHEN ric38.GYRAmberMax = 0 AND ric38.GYRGreenMax = 0 AND ISNULL(ric38.GYRRedMax,0) = 0 THEN NULL
									WHEN ric38.GYRRedMax IS NULL AND ROUND(CorneringHigh, ric38.Rounding) >= ric38.GYRGreenMax THEN @GreenColour
									WHEN ric38.GYRRedMax IS NULL AND ROUND(CorneringHigh, ric38.Rounding) >= ric38.GYRAmberMax AND ROUND(CorneringHigh, ric38.Rounding) < ric38.GYRGreenMax THEN @YellowColour
									WHEN ric38.GYRRedMax IS NULL AND ROUND(CorneringHigh, ric38.Rounding) < ric38.GYRAmberMax THEN @RedColour
									WHEN ric38.GYRRedMax IS NOT NULL AND ROUND(CorneringHigh, ric38.Rounding) >= ric38.GYRRedMax THEN @GoldColour
									WHEN ric38.GYRRedMax IS NOT NULL AND ROUND(CorneringHigh, ric38.Rounding) >= ric38.GYRAmberMax AND ROUND(CorneringHigh, ric38.Rounding) < ric38.GYRRedMax THEN @SilverColour
									WHEN ric38.GYRRedMax is NOT NULL AND ROUND(CorneringHigh, ric38.Rounding) >= ric38.GYRGreenMax AND ROUND(CorneringHigh, ric38.Rounding) < ric38.GYRAmberMax THEN @BronzeColour
									WHEN ric38.GYRRedMax IS NOT NULL AND ROUND(CorneringHigh, ric38.Rounding) < ric38.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric38.GYRAmberMax = 0 AND ric38.GYRGreenMax = 0 AND ISNULL(ric38.GYRRedMax,0) = 0 THEN NULL
									WHEN ric38.GYRRedMAX IS NULL AND ROUND(CorneringHigh, ric38.Rounding) <= ric38.GYRAmberMax THEN @GreenColour
									WHEN ric38.GYRRedMax IS NULL AND ROUND(CorneringHigh, ric38.Rounding) <= ric38.GYRGreenMax AND ROUND(CorneringHigh, ric38.Rounding) > ric38.GYRAmberMax THEN @YellowColour
									WHEN ric38.GYRRedMax IS NULL AND ROUND(CorneringHigh, ric38.Rounding) > ric38.GYRGreenMax THEN @RedColour
									WHEN ric38.GYRRedMax IS NOT NULL AND ROUND(CorneringHigh, ric38.Rounding) <= ric38.GYRRedMax THEN @GoldColour
									WHEN ric38.GYRRedMax IS NOT NULL AND ROUND(CorneringHigh, ric38.Rounding) <= ric38.GYRAmberMax AND ROUND(CorneringHigh, ric38.Rounding) > ric38.GYRRedMax THEN @SilverColour
									WHEN ric38.GYRRedMAx IS NOT NULL AND ROUND(CorneringHigh, ric38.Rounding) <= ric38.GYRGreenMax AND ROUND(CorneringHigh, ric38.Rounding) > ric38.GYRAmberMax THEN @BronzeColour
									WHEN ric38.GYRRedMax IS NOT NULL AND ROUND(CorneringHigh, ric38.Rounding) > ric38.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	ManoeuvresLowColour =
		CASE ric39.HighLow	WHEN 1 THEN
								CASE
									WHEN ric39.GYRAmberMax = 0 AND ric39.GYRGreenMax = 0 AND ISNULL(ric39.GYRRedMax,0) = 0 THEN NULL
									WHEN ric39.GYRRedMax IS NULL AND ROUND(ManoeuvresLow, ric39.Rounding) >= ric39.GYRGreenMax THEN @GreenColour
									WHEN ric39.GYRRedMax IS NULL AND ROUND(ManoeuvresLow, ric39.Rounding) >= ric39.GYRAmberMax AND ROUND(ManoeuvresLow, ric39.Rounding) < ric39.GYRGreenMax THEN @YellowColour
									WHEN ric39.GYRRedMax IS NULL AND ROUND(ManoeuvresLow, ric39.Rounding) < ric39.GYRAmberMax THEN @RedColour
									WHEN ric39.GYRRedMax IS NOT NULL AND ROUND(ManoeuvresLow, ric39.Rounding) >= ric39.GYRRedMax THEN @GoldColour
									WHEN ric39.GYRRedMax IS NOT NULL AND ROUND(ManoeuvresLow, ric39.Rounding) >= ric39.GYRAmberMax AND ROUND(ManoeuvresLow, ric39.Rounding) < ric39.GYRRedMax THEN @SilverColour
									WHEN ric39.GYRRedMax is NOT NULL AND ROUND(ManoeuvresLow, ric39.Rounding) >= ric39.GYRGreenMax AND ROUND(ManoeuvresLow, ric39.Rounding) < ric39.GYRAmberMax THEN @BronzeColour
									WHEN ric39.GYRRedMax IS NOT NULL AND ROUND(ManoeuvresLow, ric39.Rounding) < ric39.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric39.GYRAmberMax = 0 AND ric39.GYRGreenMax = 0 AND ISNULL(ric39.GYRRedMax,0) = 0 THEN NULL
									WHEN ric39.GYRRedMAX IS NULL AND ROUND(ManoeuvresLow, ric39.Rounding) <= ric39.GYRAmberMax THEN @GreenColour
									WHEN ric39.GYRRedMax IS NULL AND ROUND(ManoeuvresLow, ric39.Rounding) <= ric39.GYRGreenMax AND ROUND(ManoeuvresLow, ric39.Rounding) > ric39.GYRAmberMax THEN @YellowColour
									WHEN ric39.GYRRedMax IS NULL AND ROUND(ManoeuvresLow, ric39.Rounding) > ric39.GYRGreenMax THEN @RedColour
									WHEN ric39.GYRRedMax IS NOT NULL AND ROUND(ManoeuvresLow, ric39.Rounding) <= ric39.GYRRedMax THEN @GoldColour
									WHEN ric39.GYRRedMax IS NOT NULL AND ROUND(ManoeuvresLow, ric39.Rounding) <= ric39.GYRAmberMax AND ROUND(ManoeuvresLow, ric39.Rounding) > ric39.GYRRedMax THEN @SilverColour
									WHEN ric39.GYRRedMAx IS NOT NULL AND ROUND(ManoeuvresLow, ric39.Rounding) <= ric39.GYRGreenMax AND ROUND(ManoeuvresLow, ric39.Rounding) > ric39.GYRAmberMax THEN @BronzeColour
									WHEN ric39.GYRRedMax IS NOT NULL AND ROUND(ManoeuvresLow, ric39.Rounding) > ric39.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	ManoeuvresMedColour =
		CASE ric40.HighLow	WHEN 1 THEN
								CASE
									WHEN ric40.GYRAmberMax = 0 AND ric40.GYRGreenMax = 0 AND ISNULL(ric40.GYRRedMax,0) = 0 THEN NULL
									WHEN ric40.GYRRedMax IS NULL AND ROUND(ManoeuvresMed, ric40.Rounding) >= ric40.GYRGreenMax THEN @GreenColour
									WHEN ric40.GYRRedMax IS NULL AND ROUND(ManoeuvresMed, ric40.Rounding) >= ric40.GYRAmberMax AND ROUND(ManoeuvresMed, ric40.Rounding) < ric40.GYRGreenMax THEN @YellowColour
									WHEN ric40.GYRRedMax IS NULL AND ROUND(ManoeuvresMed, ric40.Rounding) < ric40.GYRAmberMax THEN @RedColour
									WHEN ric40.GYRRedMax IS NOT NULL AND ROUND(ManoeuvresMed, ric40.Rounding) >= ric40.GYRRedMax THEN @GoldColour
									WHEN ric40.GYRRedMax IS NOT NULL AND ROUND(ManoeuvresMed, ric40.Rounding) >= ric40.GYRAmberMax AND ROUND(ManoeuvresMed, ric40.Rounding) < ric40.GYRRedMax THEN @SilverColour
									WHEN ric40.GYRRedMax is NOT NULL AND ROUND(ManoeuvresMed, ric40.Rounding) >= ric40.GYRGreenMax AND ROUND(ManoeuvresMed, ric40.Rounding) < ric40.GYRAmberMax THEN @BronzeColour
									WHEN ric40.GYRRedMax IS NOT NULL AND ROUND(ManoeuvresMed, ric40.Rounding) < ric40.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric40.GYRAmberMax = 0 AND ric40.GYRGreenMax = 0 AND ISNULL(ric40.GYRRedMax,0) = 0 THEN NULL
									WHEN ric40.GYRRedMAX IS NULL AND ROUND(ManoeuvresMed, ric40.Rounding) <= ric40.GYRAmberMax THEN @GreenColour
									WHEN ric40.GYRRedMax IS NULL AND ROUND(ManoeuvresMed, ric40.Rounding) <= ric40.GYRGreenMax AND ROUND(ManoeuvresMed, ric40.Rounding) > ric40.GYRAmberMax THEN @YellowColour
									WHEN ric40.GYRRedMax IS NULL AND ROUND(ManoeuvresMed, ric40.Rounding) > ric40.GYRGreenMax THEN @RedColour
									WHEN ric40.GYRRedMax IS NOT NULL AND ROUND(ManoeuvresMed, ric40.Rounding) <= ric40.GYRRedMax THEN @GoldColour
									WHEN ric40.GYRRedMax IS NOT NULL AND ROUND(ManoeuvresMed, ric40.Rounding) <= ric40.GYRAmberMax AND ROUND(ManoeuvresMed, ric40.Rounding) > ric40.GYRRedMax THEN @SilverColour
									WHEN ric40.GYRRedMAx IS NOT NULL AND ROUND(ManoeuvresMed, ric40.Rounding) <= ric40.GYRGreenMax AND ROUND(ManoeuvresMed, ric40.Rounding) > ric40.GYRAmberMax THEN @BronzeColour
									WHEN ric40.GYRRedMax IS NOT NULL AND ROUND(ManoeuvresMed, ric40.Rounding) > ric40.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,

	CruiseTopGearRatioColour =
		CASE ric25.HighLow	WHEN 1 THEN
								CASE
									WHEN ric25.GYRAmberMax = 0 AND ric25.GYRGreenMax = 0 AND ISNULL(ric25.GYRRedMax,0) = 0 THEN NULL
									WHEN ric25.GYRRedMax IS NULL AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) >= ric25.GYRGreenMax THEN @GreenColour
									WHEN ric25.GYRRedMax IS NULL AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) >= ric25.GYRAmberMax AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) < ric25.GYRGreenMax THEN @YellowColour
									WHEN ric25.GYRRedMax IS NULL AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) < ric25.GYRAmberMax THEN @RedColour
									WHEN ric25.GYRRedMax IS NOT NULL AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) >= ric25.GYRRedMax THEN @GoldColour
									WHEN ric25.GYRRedMax IS NOT NULL AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) >= ric25.GYRAmberMax AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) < ric25.GYRRedMax THEN @SilverColour
									WHEN ric25.GYRRedMax is NOT NULL AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) >= ric25.GYRGreenMax AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) < ric25.GYRAmberMax THEN @BronzeColour
									WHEN ric25.GYRRedMax IS NOT NULL AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) < ric25.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric25.GYRAmberMax = 0 AND ric25.GYRGreenMax = 0 AND ISNULL(ric25.GYRRedMax,0) = 0 THEN NULL
									WHEN ric25.GYRRedMAX IS NULL AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) <= ric25.GYRAmberMax THEN @GreenColour
									WHEN ric25.GYRRedMax IS NULL AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) <= ric25.GYRGreenMax AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) > ric25.GYRAmberMax THEN @YellowColour
									WHEN ric25.GYRRedMax IS NULL AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) > ric25.GYRGreenMax THEN @RedColour
									WHEN ric25.GYRRedMax IS NOT NULL AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) <= ric25.GYRRedMax THEN @GoldColour
									WHEN ric25.GYRRedMax IS NOT NULL AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) <= ric25.GYRAmberMax AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) > ric25.GYRRedMax THEN @SilverColour
									WHEN ric25.GYRRedMAx IS NOT NULL AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) <= ric25.GYRGreenMax AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) > ric25.GYRAmberMax THEN @BronzeColour
									WHEN ric25.GYRRedMax IS NOT NULL AND ROUND(CruiseTopGearRatio*100, ric25.Rounding) > ric25.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	OverRevCountColour =
		CASE ric28.HighLow	WHEN 1 THEN
								CASE
									WHEN ric28.GYRAmberMax = 0 AND ric28.GYRGreenMax = 0 AND ISNULL(ric28.GYRRedMax,0) = 0 THEN NULL
									WHEN ric28.GYRRedMax IS NULL AND ROUND(OverRevCount, ric28.Rounding) >= ric28.GYRGreenMax THEN @GreenColour
									WHEN ric28.GYRRedMax IS NULL AND ROUND(OverRevCount, ric28.Rounding) >= ric28.GYRAmberMax AND ROUND(OverRevCount, ric28.Rounding) < ric28.GYRGreenMax THEN @YellowColour
									WHEN ric28.GYRRedMax IS NULL AND ROUND(OverRevCount, ric28.Rounding) < ric28.GYRAmberMax THEN @RedColour
									WHEN ric28.GYRRedMax IS NOT NULL AND ROUND(OverRevCount, ric28.Rounding) >= ric28.GYRRedMax THEN @GoldColour
									WHEN ric28.GYRRedMax IS NOT NULL AND ROUND(OverRevCount, ric28.Rounding) >= ric28.GYRAmberMax AND ROUND(OverRevCount, ric28.Rounding) < ric28.GYRRedMax THEN @SilverColour
									WHEN ric28.GYRRedMax is NOT NULL AND ROUND(OverRevCount, ric28.Rounding) >= ric28.GYRGreenMax AND ROUND(OverRevCount, ric28.Rounding) < ric28.GYRAmberMax THEN @BronzeColour
									WHEN ric28.GYRRedMax IS NOT NULL AND ROUND(OverRevCount, ric28.Rounding) < ric28.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric28.GYRAmberMax = 0 AND ric28.GYRGreenMax = 0 AND ISNULL(ric28.GYRRedMax,0) = 0 THEN NULL
									WHEN ric28.GYRRedMAX IS NULL AND ROUND(OverRevCount, ric28.Rounding) <= ric28.GYRAmberMax THEN @GreenColour
									WHEN ric28.GYRRedMax IS NULL AND ROUND(OverRevCount, ric28.Rounding) <= ric28.GYRGreenMax AND ROUND(OverRevCount, ric28.Rounding) > ric28.GYRAmberMax THEN @YellowColour
									WHEN ric28.GYRRedMax IS NULL AND ROUND(OverRevCount, ric28.Rounding) > ric28.GYRGreenMax THEN @RedColour
									WHEN ric28.GYRRedMax IS NOT NULL AND ROUND(OverRevCount, ric28.Rounding) <= ric28.GYRRedMax THEN @GoldColour
									WHEN ric28.GYRRedMax IS NOT NULL AND ROUND(OverRevCount, ric28.Rounding) <= ric28.GYRAmberMax AND ROUND(OverRevCount, ric28.Rounding) > ric28.GYRRedMax THEN @SilverColour
									WHEN ric28.GYRRedMAx IS NOT NULL AND ROUND(OverRevCount, ric28.Rounding) <= ric28.GYRGreenMax AND ROUND(OverRevCount, ric28.Rounding) > ric28.GYRAmberMax THEN @BronzeColour
									WHEN ric28.GYRRedMax IS NOT NULL AND ROUND(OverRevCount, ric28.Rounding) > ric28.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,

	PtoColour =
		CASE ric29.HighLow	WHEN 1 THEN
								CASE
									WHEN ric29.GYRAmberMax = 0 AND ric29.GYRGreenMax = 0 AND ISNULL(ric29.GYRRedMax,0) = 0 THEN NULL
									WHEN ric29.GYRRedMax IS NULL AND ROUND(Pto*100, ric29.Rounding) >= ric29.GYRGreenMax THEN @GreenColour
									WHEN ric29.GYRRedMax IS NULL AND ROUND(Pto*100, ric29.Rounding) >= ric29.GYRAmberMax AND ROUND(Pto*100, ric29.Rounding) < ric29.GYRGreenMax THEN @YellowColour
									WHEN ric29.GYRRedMax IS NULL AND ROUND(Pto*100, ric29.Rounding) < ric29.GYRAmberMax THEN @RedColour
									WHEN ric29.GYRRedMax IS NOT NULL AND ROUND(Pto*100, ric29.Rounding) >= ric29.GYRRedMax THEN @GoldColour
									WHEN ric29.GYRRedMax IS NOT NULL AND ROUND(Pto*100, ric29.Rounding) >= ric29.GYRAmberMax AND ROUND(Pto*100, ric29.Rounding) < ric29.GYRRedMax THEN @SilverColour
									WHEN ric29.GYRRedMax is NOT NULL AND ROUND(Pto*100, ric29.Rounding) >= ric29.GYRGreenMax AND ROUND(Pto*100, ric29.Rounding) < ric29.GYRAmberMax THEN @BronzeColour
									WHEN ric29.GYRRedMax IS NOT NULL AND ROUND(Pto*100, ric29.Rounding) < ric29.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric29.GYRAmberMax = 0 AND ric29.GYRGreenMax = 0 AND ISNULL(ric29.GYRRedMax,0) = 0 THEN NULL
									WHEN ric29.GYRRedMAX IS NULL AND ROUND(Pto*100, ric29.Rounding) <= ric29.GYRAmberMax THEN @GreenColour
									WHEN ric29.GYRRedMax IS NULL AND ROUND(Pto*100, ric29.Rounding) <= ric29.GYRGreenMax AND ROUND(Pto*100, ric29.Rounding) > ric29.GYRAmberMax THEN @YellowColour
									WHEN ric29.GYRRedMax IS NULL AND ROUND(Pto*100, ric29.Rounding) > ric29.GYRGreenMax THEN @RedColour
									WHEN ric29.GYRRedMax IS NOT NULL AND ROUND(Pto*100, ric29.Rounding) <= ric29.GYRRedMax THEN @GoldColour
									WHEN ric29.GYRRedMax IS NOT NULL AND ROUND(Pto*100, ric29.Rounding) <= ric29.GYRAmberMax AND ROUND(Pto*100, ric29.Rounding) > ric29.GYRRedMax THEN @SilverColour
									WHEN ric29.GYRRedMAx IS NOT NULL AND ROUND(Pto*100, ric29.Rounding) <= ric29.GYRGreenMax AND ROUND(Pto*100, ric29.Rounding) > ric29.GYRAmberMax THEN @BronzeColour
									WHEN ric29.GYRRedMax IS NOT NULL AND ROUND(Pto*100, ric29.Rounding) > ric29.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	CruiseOverspeedColour =
		CASE ric43.HighLow	WHEN 1 THEN
								CASE
									WHEN ric43.GYRAmberMax = 0 AND ric43.GYRGreenMax = 0 AND ISNULL(ric43.GYRRedMax,0) = 0 THEN NULL
									WHEN ric43.GYRRedMax IS NULL AND ROUND(CruiseOverspeed*100, ric43.Rounding) >= ric43.GYRGreenMax THEN @GreenColour
									WHEN ric43.GYRRedMax IS NULL AND ROUND(CruiseOverspeed*100, ric43.Rounding) >= ric43.GYRAmberMax AND ROUND(CruiseOverspeed*100, ric43.Rounding) < ric43.GYRGreenMax THEN @YellowColour
									WHEN ric43.GYRRedMax IS NULL AND ROUND(CruiseOverspeed*100, ric43.Rounding) < ric43.GYRAmberMax THEN @RedColour
									WHEN ric43.GYRRedMax IS NOT NULL AND ROUND(CruiseOverspeed*100, ric43.Rounding) >= ric43.GYRRedMax THEN @GoldColour
									WHEN ric43.GYRRedMax IS NOT NULL AND ROUND(CruiseOverspeed*100, ric43.Rounding) >= ric43.GYRAmberMax AND ROUND(CruiseOverspeed*100, ric43.Rounding) < ric43.GYRRedMax THEN @SilverColour
									WHEN ric43.GYRRedMax is NOT NULL AND ROUND(CruiseOverspeed*100, ric43.Rounding) >= ric43.GYRGreenMax AND ROUND(CruiseOverspeed*100, ric43.Rounding) < ric43.GYRAmberMax THEN @BronzeColour
									WHEN ric43.GYRRedMax IS NOT NULL AND ROUND(CruiseOverspeed*100, ric43.Rounding) < ric43.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric43.GYRAmberMax = 0 AND ric43.GYRGreenMax = 0 AND ISNULL(ric43.GYRRedMax,0) = 0 THEN NULL
									WHEN ric43.GYRRedMAX IS NULL AND ROUND(CruiseOverspeed*100, ric43.Rounding) <= ric43.GYRAmberMax THEN @GreenColour
									WHEN ric43.GYRRedMax IS NULL AND ROUND(CruiseOverspeed*100, ric43.Rounding) <= ric43.GYRGreenMax AND ROUND(CruiseOverspeed*100, ric43.Rounding) > ric43.GYRAmberMax THEN @YellowColour
									WHEN ric43.GYRRedMax IS NULL AND ROUND(CruiseOverspeed*100, ric43.Rounding) > ric43.GYRGreenMax THEN @RedColour
									WHEN ric43.GYRRedMax IS NOT NULL AND ROUND(CruiseOverspeed*100, ric43.Rounding) <= ric43.GYRRedMax THEN @GoldColour
									WHEN ric43.GYRRedMax IS NOT NULL AND ROUND(CruiseOverspeed*100, ric43.Rounding) <= ric43.GYRAmberMax AND ROUND(CruiseOverspeed*100, ric43.Rounding) > ric43.GYRRedMax THEN @SilverColour
									WHEN ric43.GYRRedMAx IS NOT NULL AND ROUND(CruiseOverspeed*100, ric43.Rounding) <= ric43.GYRGreenMax AND ROUND(CruiseOverspeed*100, ric43.Rounding) > ric43.GYRAmberMax THEN @BronzeColour
									WHEN ric43.GYRRedMax IS NOT NULL AND ROUND(CruiseOverspeed*100, ric43.Rounding) > ric43.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	TopGearOverspeedColour =
		CASE ric42.HighLow	WHEN 1 THEN
								CASE
									WHEN ric42.GYRAmberMax = 0 AND ric42.GYRGreenMax = 0 AND ISNULL(ric42.GYRRedMax,0) = 0 THEN NULL
									WHEN ric42.GYRRedMax IS NULL AND ROUND(TopGearOverspeed*100, ric42.Rounding) >= ric42.GYRGreenMax THEN @GreenColour
									WHEN ric42.GYRRedMax IS NULL AND ROUND(TopGearOverspeed*100, ric42.Rounding) >= ric42.GYRAmberMax AND ROUND(TopGearOverspeed*100, ric42.Rounding) < ric42.GYRGreenMax THEN @YellowColour
									WHEN ric42.GYRRedMax IS NULL AND ROUND(TopGearOverspeed*100, ric42.Rounding) < ric42.GYRAmberMax THEN @RedColour
									WHEN ric42.GYRRedMax IS NOT NULL AND ROUND(TopGearOverspeed*100, ric42.Rounding) >= ric42.GYRRedMax THEN @GoldColour
									WHEN ric42.GYRRedMax IS NOT NULL AND ROUND(TopGearOverspeed*100, ric42.Rounding) >= ric42.GYRAmberMax AND ROUND(TopGearOverspeed*100, ric42.Rounding) < ric42.GYRRedMax THEN @SilverColour
									WHEN ric42.GYRRedMax is NOT NULL AND ROUND(TopGearOverspeed*100, ric42.Rounding) >= ric42.GYRGreenMax AND ROUND(TopGearOverspeed*100, ric42.Rounding) < ric42.GYRAmberMax THEN @BronzeColour
									WHEN ric42.GYRRedMax IS NOT NULL AND ROUND(TopGearOverspeed*100, ric42.Rounding) < ric42.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric42.GYRAmberMax = 0 AND ric42.GYRGreenMax = 0 AND ISNULL(ric42.GYRRedMax,0) = 0 THEN NULL
									WHEN ric42.GYRRedMAX IS NULL AND ROUND(TopGearOverspeed*100, ric42.Rounding) <= ric42.GYRAmberMax THEN @GreenColour
									WHEN ric42.GYRRedMax IS NULL AND ROUND(TopGearOverspeed*100, ric42.Rounding) <= ric42.GYRGreenMax AND ROUND(TopGearOverspeed*100, ric42.Rounding) > ric42.GYRAmberMax THEN @YellowColour
									WHEN ric42.GYRRedMax IS NULL AND ROUND(TopGearOverspeed*100, ric42.Rounding) > ric42.GYRGreenMax THEN @RedColour
									WHEN ric42.GYRRedMax IS NOT NULL AND ROUND(TopGearOverspeed*100, ric42.Rounding) <= ric42.GYRRedMax THEN @GoldColour
									WHEN ric42.GYRRedMax IS NOT NULL AND ROUND(TopGearOverspeed*100, ric42.Rounding) <= ric42.GYRAmberMax AND ROUND(TopGearOverspeed*100, ric42.Rounding) > ric42.GYRRedMax THEN @SilverColour
									WHEN ric42.GYRRedMAx IS NOT NULL AND ROUND(TopGearOverspeed*100, ric42.Rounding) <= ric42.GYRGreenMax AND ROUND(TopGearOverspeed*100, ric42.Rounding) > ric42.GYRAmberMax THEN @BronzeColour
									WHEN ric42.GYRRedMax IS NOT NULL AND ROUND(TopGearOverspeed*100, ric42.Rounding) > ric42.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
		--NULL AS FuelWastageCostColour

	OverspeedCountColour =
		CASE ric46.HighLow	WHEN 1 THEN
								CASE
									WHEN ric46.GYRAmberMax = 0 AND ric46.GYRGreenMax = 0 AND ISNULL(ric46.GYRRedMax,0) = 0 THEN NULL
									WHEN ric46.GYRRedMax IS NULL AND ROUND(OverspeedCount*100, ric46.Rounding) >= ric46.GYRGreenMax THEN @GreenColour
									WHEN ric46.GYRRedMax IS NULL AND ROUND(OverspeedCount*100, ric46.Rounding) >= ric46.GYRAmberMax AND ROUND(OverspeedCount*100, ric46.Rounding) < ric46.GYRGreenMax THEN @YellowColour
									WHEN ric46.GYRRedMax IS NULL AND ROUND(OverspeedCount*100, ric46.Rounding) < ric46.GYRAmberMax THEN @RedColour
									WHEN ric46.GYRRedMax IS NOT NULL AND ROUND(OverspeedCount*100, ric46.Rounding) >= ric46.GYRRedMax THEN @GoldColour
									WHEN ric46.GYRRedMax IS NOT NULL AND ROUND(OverspeedCount*100, ric46.Rounding) >= ric46.GYRAmberMax AND ROUND(OverspeedCount*100, ric46.Rounding) < ric46.GYRRedMax THEN @SilverColour
									WHEN ric46.GYRRedMax is NOT NULL AND ROUND(OverspeedCount*100, ric46.Rounding) >= ric46.GYRGreenMax AND ROUND(OverspeedCount*100, ric46.Rounding) < ric46.GYRAmberMax THEN @BronzeColour
									WHEN ric46.GYRRedMax IS NOT NULL AND ROUND(OverspeedCount*100, ric46.Rounding) < ric46.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric46.GYRAmberMax = 0 AND ric46.GYRGreenMax = 0 AND ISNULL(ric46.GYRRedMax,0) = 0 THEN NULL
									WHEN ric46.GYRRedMAX IS NULL AND ROUND(OverspeedCount*100, ric46.Rounding) <= ric46.GYRAmberMax THEN @GreenColour
									WHEN ric46.GYRRedMax IS NULL AND ROUND(OverspeedCount*100, ric46.Rounding) <= ric46.GYRGreenMax AND ROUND(OverspeedCount*100, ric46.Rounding) > ric46.GYRAmberMax THEN @YellowColour
									WHEN ric46.GYRRedMax IS NULL AND ROUND(OverspeedCount*100, ric46.Rounding) > ric46.GYRGreenMax THEN @RedColour
									WHEN ric46.GYRRedMax IS NOT NULL AND ROUND(OverspeedCount*100, ric46.Rounding) <= ric46.GYRRedMax THEN @GoldColour
									WHEN ric46.GYRRedMax IS NOT NULL AND ROUND(OverspeedCount*100, ric46.Rounding) <= ric46.GYRAmberMax AND ROUND(OverspeedCount*100, ric46.Rounding) > ric46.GYRRedMax THEN @SilverColour
									WHEN ric46.GYRRedMAx IS NOT NULL AND ROUND(OverspeedCount*100, ric46.Rounding) <= ric46.GYRGreenMax AND ROUND(OverspeedCount*100, ric46.Rounding) > ric46.GYRAmberMax THEN @BronzeColour
									WHEN ric46.GYRRedMax IS NOT NULL AND ROUND(OverspeedCount*100, ric46.Rounding) > ric46.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
							
	OverspeedHighCountColour =
		CASE ric47.HighLow	WHEN 1 THEN
								CASE
									WHEN ric47.GYRAmberMax = 0 AND ric47.GYRGreenMax = 0 AND ISNULL(ric47.GYRRedMax,0) = 0 THEN NULL
									WHEN ric47.GYRRedMax IS NULL AND ROUND(OverspeedHighCount*100, ric47.Rounding) >= ric47.GYRGreenMax THEN @GreenColour
									WHEN ric47.GYRRedMax IS NULL AND ROUND(OverspeedHighCount*100, ric47.Rounding) >= ric47.GYRAmberMax AND ROUND(OverspeedHighCount*100, ric47.Rounding) < ric47.GYRGreenMax THEN @YellowColour
									WHEN ric47.GYRRedMax IS NULL AND ROUND(OverspeedHighCount*100, ric47.Rounding) < ric47.GYRAmberMax THEN @RedColour
									WHEN ric47.GYRRedMax IS NOT NULL AND ROUND(OverspeedHighCount*100, ric47.Rounding) >= ric47.GYRRedMax THEN @GoldColour
									WHEN ric47.GYRRedMax IS NOT NULL AND ROUND(OverspeedHighCount*100, ric47.Rounding) >= ric47.GYRAmberMax AND ROUND(OverspeedHighCount*100, ric47.Rounding) < ric47.GYRRedMax THEN @SilverColour
									WHEN ric47.GYRRedMax is NOT NULL AND ROUND(OverspeedHighCount*100, ric47.Rounding) >= ric47.GYRGreenMax AND ROUND(OverspeedHighCount*100, ric47.Rounding) < ric47.GYRAmberMax THEN @BronzeColour
									WHEN ric47.GYRRedMax IS NOT NULL AND ROUND(OverspeedHighCount*100, ric47.Rounding) < ric47.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric47.GYRAmberMax = 0 AND ric47.GYRGreenMax = 0 AND ISNULL(ric47.GYRRedMax,0) = 0 THEN NULL
									WHEN ric47.GYRRedMAX IS NULL AND ROUND(OverspeedHighCount*100, ric47.Rounding) <= ric47.GYRAmberMax THEN @GreenColour
									WHEN ric47.GYRRedMax IS NULL AND ROUND(OverspeedHighCount*100, ric47.Rounding) <= ric47.GYRGreenMax AND ROUND(OverspeedHighCount*100, ric47.Rounding) > ric47.GYRAmberMax THEN @YellowColour
									WHEN ric47.GYRRedMax IS NULL AND ROUND(OverspeedHighCount*100, ric47.Rounding) > ric47.GYRGreenMax THEN @RedColour
									WHEN ric47.GYRRedMax IS NOT NULL AND ROUND(OverspeedHighCount*100, ric47.Rounding) <= ric47.GYRRedMax THEN @GoldColour
									WHEN ric47.GYRRedMax IS NOT NULL AND ROUND(OverspeedHighCount*100, ric47.Rounding) <= ric47.GYRAmberMax AND ROUND(OverspeedHighCount*100, ric47.Rounding) > ric47.GYRRedMax THEN @SilverColour
									WHEN ric47.GYRRedMAx IS NOT NULL AND ROUND(OverspeedHighCount*100, ric47.Rounding) <= ric47.GYRGreenMax AND ROUND(OverspeedHighCount*100, ric47.Rounding) > ric47.GYRAmberMax THEN @BronzeColour
									WHEN ric47.GYRRedMax IS NOT NULL AND ROUND(OverspeedHighCount*100, ric47.Rounding) > ric47.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	StabilityControlColour =
		CASE ric48.HighLow	WHEN 1 THEN
								CASE
									WHEN ric48.GYRAmberMax = 0 AND ric48.GYRGreenMax = 0 AND ISNULL(ric48.GYRRedMax,0) = 0 THEN NULL
									WHEN ric48.GYRRedMax IS NULL AND ROUND(StabilityControl*100, ric48.Rounding) >= ric48.GYRGreenMax THEN @GreenColour
									WHEN ric48.GYRRedMax IS NULL AND ROUND(StabilityControl*100, ric48.Rounding) >= ric48.GYRAmberMax AND ROUND(StabilityControl*100, ric48.Rounding) < ric48.GYRGreenMax THEN @YellowColour
									WHEN ric48.GYRRedMax IS NULL AND ROUND(StabilityControl*100, ric48.Rounding) < ric48.GYRAmberMax THEN @RedColour
									WHEN ric48.GYRRedMax IS NOT NULL AND ROUND(StabilityControl*100, ric48.Rounding) >= ric48.GYRRedMax THEN @GoldColour
									WHEN ric48.GYRRedMax IS NOT NULL AND ROUND(StabilityControl*100, ric48.Rounding) >= ric48.GYRAmberMax AND ROUND(StabilityControl*100, ric48.Rounding) < ric48.GYRRedMax THEN @SilverColour
									WHEN ric48.GYRRedMax is NOT NULL AND ROUND(StabilityControl*100, ric48.Rounding) >= ric48.GYRGreenMax AND ROUND(StabilityControl*100, ric48.Rounding) < ric48.GYRAmberMax THEN @BronzeColour
									WHEN ric48.GYRRedMax IS NOT NULL AND ROUND(StabilityControl*100, ric48.Rounding) < ric48.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric48.GYRAmberMax = 0 AND ric48.GYRGreenMax = 0 AND ISNULL(ric48.GYRRedMax,0) = 0 THEN NULL
									WHEN ric48.GYRRedMAX IS NULL AND ROUND(StabilityControl*100, ric48.Rounding) <= ric48.GYRAmberMax THEN @GreenColour
									WHEN ric48.GYRRedMax IS NULL AND ROUND(StabilityControl*100, ric48.Rounding) <= ric48.GYRGreenMax AND ROUND(StabilityControl*100, ric48.Rounding) > ric48.GYRAmberMax THEN @YellowColour
									WHEN ric48.GYRRedMax IS NULL AND ROUND(StabilityControl*100, ric48.Rounding) > ric48.GYRGreenMax THEN @RedColour
									WHEN ric48.GYRRedMax IS NOT NULL AND ROUND(StabilityControl*100, ric48.Rounding) <= ric48.GYRRedMax THEN @GoldColour
									WHEN ric48.GYRRedMax IS NOT NULL AND ROUND(StabilityControl*100, ric48.Rounding) <= ric48.GYRAmberMax AND ROUND(StabilityControl*100, ric48.Rounding) > ric48.GYRRedMax THEN @SilverColour
									WHEN ric48.GYRRedMAx IS NOT NULL AND ROUND(StabilityControl*100, ric48.Rounding) <= ric48.GYRGreenMax AND ROUND(StabilityControl*100, ric48.Rounding) > ric48.GYRAmberMax THEN @BronzeColour
									WHEN ric48.GYRRedMax IS NOT NULL AND ROUND(StabilityControl*100, ric48.Rounding) > ric48.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	CollisionWarningLowColour =
		CASE ric49.HighLow	WHEN 1 THEN
								CASE
									WHEN ric49.GYRAmberMax = 0 AND ric49.GYRGreenMax = 0 AND ISNULL(ric49.GYRRedMax,0) = 0 THEN NULL
									WHEN ric49.GYRRedMax IS NULL AND ROUND(CollisionWarningLow*100, ric49.Rounding) >= ric49.GYRGreenMax THEN @GreenColour
									WHEN ric49.GYRRedMax IS NULL AND ROUND(CollisionWarningLow*100, ric49.Rounding) >= ric49.GYRAmberMax AND ROUND(CollisionWarningLow*100, ric49.Rounding) < ric49.GYRGreenMax THEN @YellowColour
									WHEN ric49.GYRRedMax IS NULL AND ROUND(CollisionWarningLow*100, ric49.Rounding) < ric49.GYRAmberMax THEN @RedColour
									WHEN ric49.GYRRedMax IS NOT NULL AND ROUND(CollisionWarningLow*100, ric49.Rounding) >= ric49.GYRRedMax THEN @GoldColour
									WHEN ric49.GYRRedMax IS NOT NULL AND ROUND(CollisionWarningLow*100, ric49.Rounding) >= ric49.GYRAmberMax AND ROUND(CollisionWarningLow*100, ric49.Rounding) < ric49.GYRRedMax THEN @SilverColour
									WHEN ric49.GYRRedMax is NOT NULL AND ROUND(CollisionWarningLow*100, ric49.Rounding) >= ric49.GYRGreenMax AND ROUND(CollisionWarningLow*100, ric49.Rounding) < ric49.GYRAmberMax THEN @BronzeColour
									WHEN ric49.GYRRedMax IS NOT NULL AND ROUND(CollisionWarningLow*100, ric49.Rounding) < ric49.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric49.GYRAmberMax = 0 AND ric49.GYRGreenMax = 0 AND ISNULL(ric49.GYRRedMax,0) = 0 THEN NULL
									WHEN ric49.GYRRedMAX IS NULL AND ROUND(CollisionWarningLow*100, ric49.Rounding) <= ric49.GYRAmberMax THEN @GreenColour
									WHEN ric49.GYRRedMax IS NULL AND ROUND(CollisionWarningLow*100, ric49.Rounding) <= ric49.GYRGreenMax AND ROUND(CollisionWarningLow*100, ric49.Rounding) > ric49.GYRAmberMax THEN @YellowColour
									WHEN ric49.GYRRedMax IS NULL AND ROUND(CollisionWarningLow*100, ric49.Rounding) > ric49.GYRGreenMax THEN @RedColour
									WHEN ric49.GYRRedMax IS NOT NULL AND ROUND(CollisionWarningLow*100, ric49.Rounding) <= ric49.GYRRedMax THEN @GoldColour
									WHEN ric49.GYRRedMax IS NOT NULL AND ROUND(CollisionWarningLow*100, ric49.Rounding) <= ric49.GYRAmberMax AND ROUND(CollisionWarningLow*100, ric49.Rounding) > ric49.GYRRedMax THEN @SilverColour
									WHEN ric49.GYRRedMAx IS NOT NULL AND ROUND(CollisionWarningLow*100, ric49.Rounding) <= ric49.GYRGreenMax AND ROUND(CollisionWarningLow*100, ric49.Rounding) > ric49.GYRAmberMax THEN @BronzeColour
									WHEN ric49.GYRRedMax IS NOT NULL AND ROUND(CollisionWarningLow*100, ric49.Rounding) > ric49.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	CollisionWarningMedColour =
		CASE ric50.HighLow	WHEN 1 THEN
								CASE
									WHEN ric50.GYRAmberMax = 0 AND ric50.GYRGreenMax = 0 AND ISNULL(ric50.GYRRedMax,0) = 0 THEN NULL
									WHEN ric50.GYRRedMax IS NULL AND ROUND(CollisionWarningMed*100, ric50.Rounding) >= ric50.GYRGreenMax THEN @GreenColour
									WHEN ric50.GYRRedMax IS NULL AND ROUND(CollisionWarningMed*100, ric50.Rounding) >= ric50.GYRAmberMax AND ROUND(CollisionWarningMed*100, ric50.Rounding) < ric50.GYRGreenMax THEN @YellowColour
									WHEN ric50.GYRRedMax IS NULL AND ROUND(CollisionWarningMed*100, ric50.Rounding) < ric50.GYRAmberMax THEN @RedColour
									WHEN ric50.GYRRedMax IS NOT NULL AND ROUND(CollisionWarningMed*100, ric50.Rounding) >= ric50.GYRRedMax THEN @GoldColour
									WHEN ric50.GYRRedMax IS NOT NULL AND ROUND(CollisionWarningMed*100, ric50.Rounding) >= ric50.GYRAmberMax AND ROUND(CollisionWarningMed*100, ric50.Rounding) < ric50.GYRRedMax THEN @SilverColour
									WHEN ric50.GYRRedMax is NOT NULL AND ROUND(CollisionWarningMed*100, ric50.Rounding) >= ric50.GYRGreenMax AND ROUND(CollisionWarningMed*100, ric50.Rounding) < ric50.GYRAmberMax THEN @BronzeColour
									WHEN ric50.GYRRedMax IS NOT NULL AND ROUND(CollisionWarningMed*100, ric50.Rounding) < ric50.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric50.GYRAmberMax = 0 AND ric50.GYRGreenMax = 0 AND ISNULL(ric50.GYRRedMax,0) = 0 THEN NULL
									WHEN ric50.GYRRedMAX IS NULL AND ROUND(CollisionWarningMed*100, ric50.Rounding) <= ric50.GYRAmberMax THEN @GreenColour
									WHEN ric50.GYRRedMax IS NULL AND ROUND(CollisionWarningMed*100, ric50.Rounding) <= ric50.GYRGreenMax AND ROUND(CollisionWarningMed*100, ric50.Rounding) > ric50.GYRAmberMax THEN @YellowColour
									WHEN ric50.GYRRedMax IS NULL AND ROUND(CollisionWarningMed*100, ric50.Rounding) > ric50.GYRGreenMax THEN @RedColour
									WHEN ric50.GYRRedMax IS NOT NULL AND ROUND(CollisionWarningMed*100, ric50.Rounding) <= ric50.GYRRedMax THEN @GoldColour
									WHEN ric50.GYRRedMax IS NOT NULL AND ROUND(CollisionWarningMed*100, ric50.Rounding) <= ric50.GYRAmberMax AND ROUND(CollisionWarningMed*100, ric50.Rounding) > ric50.GYRRedMax THEN @SilverColour
									WHEN ric50.GYRRedMAx IS NOT NULL AND ROUND(CollisionWarningMed*100, ric50.Rounding) <= ric50.GYRGreenMax AND ROUND(CollisionWarningMed*100, ric50.Rounding) > ric50.GYRAmberMax THEN @BronzeColour
									WHEN ric50.GYRRedMax IS NOT NULL AND ROUND(CollisionWarningMed*100, ric50.Rounding) > ric50.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	CollisionWarningHighColour =
		CASE ric51.HighLow	WHEN 1 THEN
								CASE
									WHEN ric51.GYRAmberMax = 0 AND ric51.GYRGreenMax = 0 AND ISNULL(ric51.GYRRedMax,0) = 0 THEN NULL
									WHEN ric51.GYRRedMax IS NULL AND ROUND(CollisionWarningHighColour*100, ric51.Rounding) >= ric51.GYRGreenMax THEN @GreenColour
									WHEN ric51.GYRRedMax IS NULL AND ROUND(CollisionWarningHighColour*100, ric51.Rounding) >= ric51.GYRAmberMax AND ROUND(CollisionWarningHighColour*100, ric51.Rounding) < ric51.GYRGreenMax THEN @YellowColour
									WHEN ric51.GYRRedMax IS NULL AND ROUND(CollisionWarningHighColour*100, ric51.Rounding) < ric51.GYRAmberMax THEN @RedColour
									WHEN ric51.GYRRedMax IS NOT NULL AND ROUND(CollisionWarningHighColour*100, ric51.Rounding) >= ric51.GYRRedMax THEN @GoldColour
									WHEN ric51.GYRRedMax IS NOT NULL AND ROUND(CollisionWarningHighColour*100, ric51.Rounding) >= ric51.GYRAmberMax AND ROUND(CollisionWarningHighColour*100, ric51.Rounding) < ric51.GYRRedMax THEN @SilverColour
									WHEN ric51.GYRRedMax is NOT NULL AND ROUND(CollisionWarningHighColour*100, ric51.Rounding) >= ric51.GYRGreenMax AND ROUND(CollisionWarningHighColour*100, ric51.Rounding) < ric51.GYRAmberMax THEN @BronzeColour
									WHEN ric51.GYRRedMax IS NOT NULL AND ROUND(CollisionWarningHighColour*100, ric51.Rounding) < ric51.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric51.GYRAmberMax = 0 AND ric51.GYRGreenMax = 0 AND ISNULL(ric51.GYRRedMax,0) = 0 THEN NULL
									WHEN ric51.GYRRedMAX IS NULL AND ROUND(CollisionWarningHighColour*100, ric51.Rounding) <= ric51.GYRAmberMax THEN @GreenColour
									WHEN ric51.GYRRedMax IS NULL AND ROUND(CollisionWarningHighColour*100, ric51.Rounding) <= ric51.GYRGreenMax AND ROUND(CollisionWarningHighColour*100, ric51.Rounding) > ric51.GYRAmberMax THEN @YellowColour
									WHEN ric51.GYRRedMax IS NULL AND ROUND(CollisionWarningHighColour*100, ric51.Rounding) > ric51.GYRGreenMax THEN @RedColour
									WHEN ric51.GYRRedMax IS NOT NULL AND ROUND(CollisionWarningHighColour*100, ric51.Rounding) <= ric51.GYRRedMax THEN @GoldColour
									WHEN ric51.GYRRedMax IS NOT NULL AND ROUND(CollisionWarningHighColour*100, ric51.Rounding) <= ric51.GYRAmberMax AND ROUND(CollisionWarningHighColour*100, ric51.Rounding) > ric51.GYRRedMax THEN @SilverColour
									WHEN ric51.GYRRedMAx IS NOT NULL AND ROUND(CollisionWarningHighColour*100, ric51.Rounding) <= ric51.GYRGreenMax AND ROUND(CollisionWarningHighColour*100, ric51.Rounding) > ric51.GYRAmberMax THEN @BronzeColour
									WHEN ric51.GYRRedMax IS NOT NULL AND ROUND(CollisionWarningHighColour*100, ric51.Rounding) > ric51.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	LaneDepartureDisableColour =
		CASE ric52.HighLow	WHEN 1 THEN
								CASE
									WHEN ric52.GYRAmberMax = 0 AND ric52.GYRGreenMax = 0 AND ISNULL(ric52.GYRRedMax,0) = 0 THEN NULL
									WHEN ric52.GYRRedMax IS NULL AND ROUND(LaneDepartureDisableColour*100, ric52.Rounding) >= ric52.GYRGreenMax THEN @GreenColour
									WHEN ric52.GYRRedMax IS NULL AND ROUND(LaneDepartureDisableColour*100, ric52.Rounding) >= ric52.GYRAmberMax AND ROUND(LaneDepartureDisableColour*100, ric52.Rounding) < ric52.GYRGreenMax THEN @YellowColour
									WHEN ric52.GYRRedMax IS NULL AND ROUND(LaneDepartureDisableColour*100, ric52.Rounding) < ric52.GYRAmberMax THEN @RedColour
									WHEN ric52.GYRRedMax IS NOT NULL AND ROUND(LaneDepartureDisableColour*100, ric52.Rounding) >= ric52.GYRRedMax THEN @GoldColour
									WHEN ric52.GYRRedMax IS NOT NULL AND ROUND(LaneDepartureDisableColour*100, ric52.Rounding) >= ric52.GYRAmberMax AND ROUND(LaneDepartureDisableColour*100, ric52.Rounding) < ric52.GYRRedMax THEN @SilverColour
									WHEN ric52.GYRRedMax is NOT NULL AND ROUND(LaneDepartureDisableColour*100, ric52.Rounding) >= ric52.GYRGreenMax AND ROUND(LaneDepartureDisableColour*100, ric52.Rounding) < ric52.GYRAmberMax THEN @BronzeColour
									WHEN ric52.GYRRedMax IS NOT NULL AND ROUND(LaneDepartureDisableColour*100, ric52.Rounding) < ric52.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric52.GYRAmberMax = 0 AND ric52.GYRGreenMax = 0 AND ISNULL(ric52.GYRRedMax,0) = 0 THEN NULL
									WHEN ric52.GYRRedMAX IS NULL AND ROUND(LaneDepartureDisableColour*100, ric52.Rounding) <= ric52.GYRAmberMax THEN @GreenColour
									WHEN ric52.GYRRedMax IS NULL AND ROUND(LaneDepartureDisableColour*100, ric52.Rounding) <= ric52.GYRGreenMax AND ROUND(LaneDepartureDisableColour*100, ric52.Rounding) > ric52.GYRAmberMax THEN @YellowColour
									WHEN ric52.GYRRedMax IS NULL AND ROUND(LaneDepartureDisableColour*100, ric52.Rounding) > ric52.GYRGreenMax THEN @RedColour
									WHEN ric52.GYRRedMax IS NOT NULL AND ROUND(LaneDepartureDisableColour*100, ric52.Rounding) <= ric52.GYRRedMax THEN @GoldColour
									WHEN ric52.GYRRedMax IS NOT NULL AND ROUND(LaneDepartureDisableColour*100, ric52.Rounding) <= ric52.GYRAmberMax AND ROUND(LaneDepartureDisableColour*100, ric52.Rounding) > ric52.GYRRedMax THEN @SilverColour
									WHEN ric52.GYRRedMAx IS NOT NULL AND ROUND(LaneDepartureDisableColour*100, ric52.Rounding) <= ric52.GYRGreenMax AND ROUND(LaneDepartureDisableColour*100, ric52.Rounding) > ric52.GYRAmberMax THEN @BronzeColour
									WHEN ric52.GYRRedMax IS NOT NULL AND ROUND(LaneDepartureDisableColour*100, ric52.Rounding) > ric52.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	LaneDepartureLeftRightColour =
		CASE ric53.HighLow	WHEN 1 THEN
								CASE
									WHEN ric53.GYRAmberMax = 0 AND ric53.GYRGreenMax = 0 AND ISNULL(ric53.GYRRedMax,0) = 0 THEN NULL
									WHEN ric53.GYRRedMax IS NULL AND ROUND(LaneDepartureLeftRightColour*100, ric53.Rounding) >= ric53.GYRGreenMax THEN @GreenColour
									WHEN ric53.GYRRedMax IS NULL AND ROUND(LaneDepartureLeftRightColour*100, ric53.Rounding) >= ric53.GYRAmberMax AND ROUND(LaneDepartureLeftRightColour*100, ric53.Rounding) < ric53.GYRGreenMax THEN @YellowColour
									WHEN ric53.GYRRedMax IS NULL AND ROUND(LaneDepartureLeftRightColour*100, ric53.Rounding) < ric53.GYRAmberMax THEN @RedColour
									WHEN ric53.GYRRedMax IS NOT NULL AND ROUND(LaneDepartureLeftRightColour*100, ric53.Rounding) >= ric53.GYRRedMax THEN @GoldColour
									WHEN ric53.GYRRedMax IS NOT NULL AND ROUND(LaneDepartureLeftRightColour*100, ric53.Rounding) >= ric53.GYRAmberMax AND ROUND(LaneDepartureLeftRightColour*100, ric53.Rounding) < ric53.GYRRedMax THEN @SilverColour
									WHEN ric53.GYRRedMax is NOT NULL AND ROUND(LaneDepartureLeftRightColour*100, ric53.Rounding) >= ric53.GYRGreenMax AND ROUND(LaneDepartureLeftRightColour*100, ric53.Rounding) < ric53.GYRAmberMax THEN @BronzeColour
									WHEN ric53.GYRRedMax IS NOT NULL AND ROUND(LaneDepartureLeftRightColour*100, ric53.Rounding) < ric53.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric53.GYRAmberMax = 0 AND ric53.GYRGreenMax = 0 AND ISNULL(ric53.GYRRedMax,0) = 0 THEN NULL
									WHEN ric53.GYRRedMAX IS NULL AND ROUND(LaneDepartureLeftRightColour*100, ric53.Rounding) <= ric53.GYRAmberMax THEN @GreenColour
									WHEN ric53.GYRRedMax IS NULL AND ROUND(LaneDepartureLeftRightColour*100, ric53.Rounding) <= ric53.GYRGreenMax AND ROUND(LaneDepartureLeftRightColour*100, ric53.Rounding) > ric53.GYRAmberMax THEN @YellowColour
									WHEN ric53.GYRRedMax IS NULL AND ROUND(LaneDepartureLeftRightColour*100, ric53.Rounding) > ric53.GYRGreenMax THEN @RedColour
									WHEN ric53.GYRRedMax IS NOT NULL AND ROUND(LaneDepartureLeftRightColour*100, ric53.Rounding) <= ric53.GYRRedMax THEN @GoldColour
									WHEN ric53.GYRRedMax IS NOT NULL AND ROUND(LaneDepartureLeftRightColour*100, ric53.Rounding) <= ric53.GYRAmberMax AND ROUND(LaneDepartureLeftRightColour*100, ric53.Rounding) > ric53.GYRRedMax THEN @SilverColour
									WHEN ric53.GYRRedMAx IS NOT NULL AND ROUND(LaneDepartureLeftRightColour*100, ric53.Rounding) <= ric53.GYRGreenMax AND ROUND(LaneDepartureLeftRightColour*100, ric53.Rounding) > ric53.GYRAmberMax THEN @BronzeColour
									WHEN ric53.GYRRedMax IS NOT NULL AND ROUND(LaneDepartureLeftRightColour*100, ric53.Rounding) > ric53.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	FatigueColour =
		CASE ric57.HighLow	WHEN 1 THEN
								CASE
									WHEN ric57.GYRAmberMax = 0 AND ric57.GYRGreenMax = 0 AND ISNULL(ric57.GYRRedMax,0) = 0 THEN NULL
									WHEN ric57.GYRRedMax IS NULL AND ROUND(FatigueColour*100, ric57.Rounding) >= ric57.GYRGreenMax THEN @GreenColour
									WHEN ric57.GYRRedMax IS NULL AND ROUND(FatigueColour*100, ric57.Rounding) >= ric57.GYRAmberMax AND ROUND(FatigueColour*100, ric57.Rounding) < ric57.GYRGreenMax THEN @YellowColour
									WHEN ric57.GYRRedMax IS NULL AND ROUND(FatigueColour*100, ric57.Rounding) < ric57.GYRAmberMax THEN @RedColour
									WHEN ric57.GYRRedMax IS NOT NULL AND ROUND(FatigueColour*100, ric57.Rounding) >= ric57.GYRRedMax THEN @GoldColour
									WHEN ric57.GYRRedMax IS NOT NULL AND ROUND(FatigueColour*100, ric57.Rounding) >= ric57.GYRAmberMax AND ROUND(FatigueColour*100, ric57.Rounding) < ric57.GYRRedMax THEN @SilverColour
									WHEN ric57.GYRRedMax is NOT NULL AND ROUND(FatigueColour*100, ric57.Rounding) >= ric57.GYRGreenMax AND ROUND(FatigueColour*100, ric57.Rounding) < ric57.GYRAmberMax THEN @BronzeColour
									WHEN ric57.GYRRedMax IS NOT NULL AND ROUND(FatigueColour*100, ric57.Rounding) < ric57.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric57.GYRAmberMax = 0 AND ric57.GYRGreenMax = 0 AND ISNULL(ric57.GYRRedMax,0) = 0 THEN NULL
									WHEN ric57.GYRRedMAX IS NULL AND ROUND(FatigueColour*100, ric57.Rounding) <= ric57.GYRAmberMax THEN @GreenColour
									WHEN ric57.GYRRedMax IS NULL AND ROUND(FatigueColour*100, ric57.Rounding) <= ric57.GYRGreenMax AND ROUND(FatigueColour*100, ric57.Rounding) > ric57.GYRAmberMax THEN @YellowColour
									WHEN ric57.GYRRedMax IS NULL AND ROUND(FatigueColour*100, ric57.Rounding) > ric57.GYRGreenMax THEN @RedColour
									WHEN ric57.GYRRedMax IS NOT NULL AND ROUND(FatigueColour*100, ric57.Rounding) <= ric57.GYRRedMax THEN @GoldColour
									WHEN ric57.GYRRedMax IS NOT NULL AND ROUND(FatigueColour*100, ric57.Rounding) <= ric57.GYRAmberMax AND ROUND(FatigueColour*100, ric57.Rounding) > ric57.GYRRedMax THEN @SilverColour
									WHEN ric57.GYRRedMAx IS NOT NULL AND ROUND(FatigueColour*100, ric57.Rounding) <= ric57.GYRGreenMax AND ROUND(FatigueColour*100, ric57.Rounding) > ric57.GYRAmberMax THEN @BronzeColour
									WHEN ric57.GYRRedMax IS NOT NULL AND ROUND(FatigueColour*100, ric57.Rounding) > ric57.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	DistractionColour =
		CASE ric58.HighLow	WHEN 1 THEN
								CASE
									WHEN ric58.GYRAmberMax = 0 AND ric58.GYRGreenMax = 0 AND ISNULL(ric58.GYRRedMax,0) = 0 THEN NULL
									WHEN ric58.GYRRedMax IS NULL AND ROUND(Distraction*100, ric58.Rounding) >= ric58.GYRGreenMax THEN @GreenColour
									WHEN ric58.GYRRedMax IS NULL AND ROUND(Distraction*100, ric58.Rounding) >= ric58.GYRAmberMax AND ROUND(Distraction*100, ric58.Rounding) < ric58.GYRGreenMax THEN @YellowColour
									WHEN ric58.GYRRedMax IS NULL AND ROUND(Distraction*100, ric58.Rounding) < ric58.GYRAmberMax THEN @RedColour
									WHEN ric58.GYRRedMax IS NOT NULL AND ROUND(Distraction*100, ric58.Rounding) >= ric58.GYRRedMax THEN @GoldColour
									WHEN ric58.GYRRedMax IS NOT NULL AND ROUND(Distraction*100, ric58.Rounding) >= ric58.GYRAmberMax AND ROUND(Distraction*100, ric58.Rounding) < ric58.GYRRedMax THEN @SilverColour
									WHEN ric58.GYRRedMax is NOT NULL AND ROUND(Distraction*100, ric58.Rounding) >= ric58.GYRGreenMax AND ROUND(Distraction*100, ric58.Rounding) < ric58.GYRAmberMax THEN @BronzeColour
									WHEN ric58.GYRRedMax IS NOT NULL AND ROUND(Distraction*100, ric58.Rounding) < ric58.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric58.GYRAmberMax = 0 AND ric58.GYRGreenMax = 0 AND ISNULL(ric58.GYRRedMax,0) = 0 THEN NULL
									WHEN ric58.GYRRedMAX IS NULL AND ROUND(Distraction*100, ric58.Rounding) <= ric58.GYRAmberMax THEN @GreenColour
									WHEN ric58.GYRRedMax IS NULL AND ROUND(Distraction*100, ric58.Rounding) <= ric58.GYRGreenMax AND ROUND(Distraction*100, ric58.Rounding) > ric58.GYRAmberMax THEN @YellowColour
									WHEN ric58.GYRRedMax IS NULL AND ROUND(Distraction*100, ric58.Rounding) > ric58.GYRGreenMax THEN @RedColour
									WHEN ric58.GYRRedMax IS NOT NULL AND ROUND(Distraction*100, ric58.Rounding) <= ric58.GYRRedMax THEN @GoldColour
									WHEN ric58.GYRRedMax IS NOT NULL AND ROUND(Distraction*100, ric58.Rounding) <= ric58.GYRAmberMax AND ROUND(Distraction*100, ric58.Rounding) > ric58.GYRRedMax THEN @SilverColour
									WHEN ric58.GYRRedMAx IS NOT NULL AND ROUND(Distraction*100, ric58.Rounding) <= ric58.GYRGreenMax AND ROUND(Distraction*100, ric58.Rounding) > ric58.GYRAmberMax THEN @BronzeColour
									WHEN ric58.GYRRedMax IS NOT NULL AND ROUND(Distraction*100, ric58.Rounding) > ric58.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	SweetSpotTimeColour =
		CASE ric54.HighLow	WHEN 1 THEN
								CASE
									WHEN ric54.GYRAmberMax = 0 AND ric54.GYRGreenMax = 0 AND ISNULL(ric54.GYRRedMax,0) = 0 THEN NULL
									WHEN ric54.GYRRedMax IS NULL AND ROUND(SweetSpotTimeColour*100, ric54.Rounding) >= ric54.GYRGreenMax THEN @GreenColour
									WHEN ric54.GYRRedMax IS NULL AND ROUND(SweetSpotTimeColour*100, ric54.Rounding) >= ric54.GYRAmberMax AND ROUND(SweetSpotTimeColour*100, ric54.Rounding) < ric54.GYRGreenMax THEN @YellowColour
									WHEN ric54.GYRRedMax IS NULL AND ROUND(SweetSpotTimeColour*100, ric54.Rounding) < ric54.GYRAmberMax THEN @RedColour
									WHEN ric54.GYRRedMax IS NOT NULL AND ROUND(SweetSpotTimeColour*100, ric54.Rounding) >= ric54.GYRRedMax THEN @GoldColour
									WHEN ric54.GYRRedMax IS NOT NULL AND ROUND(SweetSpotTimeColour*100, ric54.Rounding) >= ric54.GYRAmberMax AND ROUND(SweetSpotTimeColour*100, ric54.Rounding) < ric54.GYRRedMax THEN @SilverColour
									WHEN ric54.GYRRedMax is NOT NULL AND ROUND(SweetSpotTimeColour*100, ric54.Rounding) >= ric54.GYRGreenMax AND ROUND(SweetSpotTimeColour*100, ric54.Rounding) < ric54.GYRAmberMax THEN @BronzeColour
									WHEN ric54.GYRRedMax IS NOT NULL AND ROUND(SweetSpotTimeColour*100, ric54.Rounding) < ric54.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric54.GYRAmberMax = 0 AND ric54.GYRGreenMax = 0 AND ISNULL(ric54.GYRRedMax,0) = 0 THEN NULL
									WHEN ric54.GYRRedMAX IS NULL AND ROUND(SweetSpotTimeColour*100, ric54.Rounding) <= ric54.GYRAmberMax THEN @GreenColour
									WHEN ric54.GYRRedMax IS NULL AND ROUND(SweetSpotTimeColour*100, ric54.Rounding) <= ric54.GYRGreenMax AND ROUND(SweetSpotTimeColour*100, ric54.Rounding) > ric54.GYRAmberMax THEN @YellowColour
									WHEN ric54.GYRRedMax IS NULL AND ROUND(SweetSpotTimeColour*100, ric54.Rounding) > ric54.GYRGreenMax THEN @RedColour
									WHEN ric54.GYRRedMax IS NOT NULL AND ROUND(SweetSpotTimeColour*100, ric54.Rounding) <= ric54.GYRRedMax THEN @GoldColour
									WHEN ric54.GYRRedMax IS NOT NULL AND ROUND(SweetSpotTimeColour*100, ric54.Rounding) <= ric54.GYRAmberMax AND ROUND(SweetSpotTimeColour*100, ric54.Rounding) > ric54.GYRRedMax THEN @SilverColour
									WHEN ric54.GYRRedMAx IS NOT NULL AND ROUND(SweetSpotTimeColour*100, ric54.Rounding) <= ric54.GYRGreenMax AND ROUND(SweetSpotTimeColour*100, ric54.Rounding) > ric54.GYRAmberMax THEN @BronzeColour
									WHEN ric54.GYRRedMax IS NOT NULL AND ROUND(SweetSpotTimeColour*100, ric54.Rounding) > ric54.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	OverRevTimeColour =
		CASE ric55.HighLow	WHEN 1 THEN
								CASE
									WHEN ric55.GYRAmberMax = 0 AND ric55.GYRGreenMax = 0 AND ISNULL(ric55.GYRRedMax,0) = 0 THEN NULL
									WHEN ric55.GYRRedMax IS NULL AND ROUND(OverRevTimeColour*100, ric55.Rounding) >= ric55.GYRGreenMax THEN @GreenColour
									WHEN ric55.GYRRedMax IS NULL AND ROUND(OverRevTimeColour*100, ric55.Rounding) >= ric55.GYRAmberMax AND ROUND(OverRevTimeColour*100, ric55.Rounding) < ric55.GYRGreenMax THEN @YellowColour
									WHEN ric55.GYRRedMax IS NULL AND ROUND(OverRevTimeColour*100, ric55.Rounding) < ric55.GYRAmberMax THEN @RedColour
									WHEN ric55.GYRRedMax IS NOT NULL AND ROUND(OverRevTimeColour*100, ric55.Rounding) >= ric55.GYRRedMax THEN @GoldColour
									WHEN ric55.GYRRedMax IS NOT NULL AND ROUND(OverRevTimeColour*100, ric55.Rounding) >= ric55.GYRAmberMax AND ROUND(OverRevTimeColour*100, ric55.Rounding) < ric55.GYRRedMax THEN @SilverColour
									WHEN ric55.GYRRedMax is NOT NULL AND ROUND(OverRevTimeColour*100, ric55.Rounding) >= ric55.GYRGreenMax AND ROUND(OverRevTimeColour*100, ric55.Rounding) < ric55.GYRAmberMax THEN @BronzeColour
									WHEN ric55.GYRRedMax IS NOT NULL AND ROUND(OverRevTimeColour*100, ric55.Rounding) < ric55.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric55.GYRAmberMax = 0 AND ric55.GYRGreenMax = 0 AND ISNULL(ric55.GYRRedMax,0) = 0 THEN NULL
									WHEN ric55.GYRRedMAX IS NULL AND ROUND(OverRevTimeColour*100, ric55.Rounding) <= ric55.GYRAmberMax THEN @GreenColour
									WHEN ric55.GYRRedMax IS NULL AND ROUND(OverRevTimeColour*100, ric55.Rounding) <= ric55.GYRGreenMax AND ROUND(OverRevTimeColour*100, ric55.Rounding) > ric55.GYRAmberMax THEN @YellowColour
									WHEN ric55.GYRRedMax IS NULL AND ROUND(OverRevTimeColour*100, ric55.Rounding) > ric55.GYRGreenMax THEN @RedColour
									WHEN ric55.GYRRedMax IS NOT NULL AND ROUND(OverRevTimeColour*100, ric55.Rounding) <= ric55.GYRRedMax THEN @GoldColour
									WHEN ric55.GYRRedMax IS NOT NULL AND ROUND(OverRevTimeColour*100, ric55.Rounding) <= ric55.GYRAmberMax AND ROUND(OverRevTimeColour*100, ric55.Rounding) > ric55.GYRRedMax THEN @SilverColour
									WHEN ric55.GYRRedMAx IS NOT NULL AND ROUND(OverRevTimeColour*100, ric55.Rounding) <= ric55.GYRGreenMax AND ROUND(OverRevTimeColour*100, ric55.Rounding) > ric55.GYRAmberMax THEN @BronzeColour
									WHEN ric55.GYRRedMax IS NOT NULL AND ROUND(OverRevTimeColour*100, ric55.Rounding) > ric55.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END,
	TopGearTimeColour =
		CASE ric56.HighLow	WHEN 1 THEN
								CASE
									WHEN ric56.GYRAmberMax = 0 AND ric56.GYRGreenMax = 0 AND ISNULL(ric56.GYRRedMax,0) = 0 THEN NULL
									WHEN ric56.GYRRedMax IS NULL AND ROUND(TopGearTimeColour*100, ric56.Rounding) >= ric56.GYRGreenMax THEN @GreenColour
									WHEN ric56.GYRRedMax IS NULL AND ROUND(TopGearTimeColour*100, ric56.Rounding) >= ric56.GYRAmberMax AND ROUND(TopGearTimeColour*100, ric56.Rounding) < ric56.GYRGreenMax THEN @YellowColour
									WHEN ric56.GYRRedMax IS NULL AND ROUND(TopGearTimeColour*100, ric56.Rounding) < ric56.GYRAmberMax THEN @RedColour
									WHEN ric56.GYRRedMax IS NOT NULL AND ROUND(TopGearTimeColour*100, ric56.Rounding) >= ric56.GYRRedMax THEN @GoldColour
									WHEN ric56.GYRRedMax IS NOT NULL AND ROUND(TopGearTimeColour*100, ric56.Rounding) >= ric56.GYRAmberMax AND ROUND(TopGearTimeColour*100, ric56.Rounding) < ric56.GYRRedMax THEN @SilverColour
									WHEN ric56.GYRRedMax is NOT NULL AND ROUND(TopGearTimeColour*100, ric56.Rounding) >= ric56.GYRGreenMax AND ROUND(TopGearTimeColour*100, ric56.Rounding) < ric56.GYRAmberMax THEN @BronzeColour
									WHEN ric56.GYRRedMax IS NOT NULL AND ROUND(TopGearTimeColour*100, ric56.Rounding) < ric56.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							ELSE
								CASE
									WHEN ric56.GYRAmberMax = 0 AND ric56.GYRGreenMax = 0 AND ISNULL(ric56.GYRRedMax,0) = 0 THEN NULL
									WHEN ric56.GYRRedMAX IS NULL AND ROUND(TopGearTimeColour*100, ric56.Rounding) <= ric56.GYRAmberMax THEN @GreenColour
									WHEN ric56.GYRRedMax IS NULL AND ROUND(TopGearTimeColour*100, ric56.Rounding) <= ric56.GYRGreenMax AND ROUND(TopGearTimeColour*100, ric56.Rounding) > ric56.GYRAmberMax THEN @YellowColour
									WHEN ric56.GYRRedMax IS NULL AND ROUND(TopGearTimeColour*100, ric56.Rounding) > ric56.GYRGreenMax THEN @RedColour
									WHEN ric56.GYRRedMax IS NOT NULL AND ROUND(TopGearTimeColour*100, ric56.Rounding) <= ric56.GYRRedMax THEN @GoldColour
									WHEN ric56.GYRRedMax IS NOT NULL AND ROUND(TopGearTimeColour*100, ric56.Rounding) <= ric56.GYRAmberMax AND ROUND(TopGearTimeColour*100, ric56.Rounding) > ric56.GYRRedMax THEN @SilverColour
									WHEN ric56.GYRRedMAx IS NOT NULL AND ROUND(TopGearTimeColour*100, ric56.Rounding) <= ric56.GYRGreenMax AND ROUND(TopGearTimeColour*100, ric56.Rounding) > ric56.GYRAmberMax THEN @BronzeColour
									WHEN ric56.GYRRedMax IS NOT NULL AND ROUND(TopGearTimeColour*100, ric56.Rounding) > ric56.GYRGreenMax THEN @CopperColour
									ELSE 'Blue'
								END
							END

FROM @data d 
LEFT JOIN dbo.ReportIndicatorConfig ric1 ON ric1.ReportConfigurationId = d.ReportConfigId AND ric1.IndicatorId = 1
LEFT JOIN dbo.ReportIndicatorConfig ric2 ON ric2.ReportConfigurationId = d.ReportConfigId AND ric2.IndicatorId = 2
LEFT JOIN dbo.ReportIndicatorConfig ric3 ON ric3.ReportConfigurationId = d.ReportConfigId AND ric3.IndicatorId = 3
LEFT JOIN dbo.ReportIndicatorConfig ric4 ON ric4.ReportConfigurationId = d.ReportConfigId AND ric4.IndicatorId = 4
LEFT JOIN dbo.ReportIndicatorConfig ric5 ON ric5.ReportConfigurationId = d.ReportConfigId AND ric5.IndicatorId = 5
LEFT JOIN dbo.ReportIndicatorConfig ric6 ON ric6.ReportConfigurationId = d.ReportConfigId AND ric6.IndicatorId = 6
LEFT JOIN dbo.ReportIndicatorConfig ric7 ON ric7.ReportConfigurationId = d.ReportConfigId AND ric7.IndicatorId = 7
LEFT JOIN dbo.ReportIndicatorConfig ric8 ON ric8.ReportConfigurationId = d.ReportConfigId AND ric8.IndicatorId = 8
LEFT JOIN dbo.ReportIndicatorConfig ric9 ON ric9.ReportConfigurationId = d.ReportConfigId AND ric9.IndicatorId = 9
LEFT JOIN dbo.ReportIndicatorConfig ric10 ON ric10.ReportConfigurationId = d.ReportConfigId AND ric10.IndicatorId = 10
LEFT JOIN dbo.ReportIndicatorConfig ric11 ON ric11.ReportConfigurationId = d.ReportConfigId AND ric11.IndicatorId = 11
LEFT JOIN dbo.ReportIndicatorConfig ric12 ON ric12.ReportConfigurationId = d.ReportConfigId AND ric12.IndicatorId = 12
LEFT JOIN dbo.ReportIndicatorConfig ric14 ON ric14.ReportConfigurationId = d.ReportConfigId AND ric14.IndicatorId = 14
LEFT JOIN dbo.ReportIndicatorConfig ric15 ON ric15.ReportConfigurationId = d.ReportConfigId AND ric15.IndicatorId = 15
LEFT JOIN dbo.ReportIndicatorConfig ric16 ON ric16.ReportConfigurationId = d.ReportConfigId AND ric16.IndicatorId = 16
LEFT JOIN dbo.ReportIndicatorConfig ric20 ON ric20.ReportConfigurationId = d.ReportConfigId AND ric20.IndicatorId = 20
LEFT JOIN dbo.ReportIndicatorConfig ric21 ON ric21.ReportConfigurationId = d.ReportConfigId AND ric21.IndicatorId = 21
LEFT JOIN dbo.ReportIndicatorConfig ric22 ON ric22.ReportConfigurationId = d.ReportConfigId AND ric22.IndicatorId = 22
LEFT JOIN dbo.ReportIndicatorConfig ric23 ON ric23.ReportConfigurationId = d.ReportConfigId AND ric23.IndicatorId = 23
LEFT JOIN dbo.ReportIndicatorConfig ric24 ON ric24.ReportConfigurationId = d.ReportConfigId AND ric24.IndicatorId = 24
LEFT JOIN dbo.ReportIndicatorConfig ric25 ON ric25.ReportConfigurationId = d.ReportConfigId AND ric25.IndicatorId = 25
LEFT JOIN dbo.ReportIndicatorConfig ric28 ON ric28.ReportConfigurationId = d.ReportConfigId AND ric28.IndicatorId = 28
LEFT JOIN dbo.ReportIndicatorConfig ric29 ON ric29.ReportConfigurationId = d.ReportConfigId AND ric29.IndicatorId = 29
LEFT JOIN dbo.ReportIndicatorConfig ric30 ON ric30.ReportConfigurationId = d.ReportConfigId AND ric30.IndicatorId = 30
LEFT JOIN dbo.ReportIndicatorConfig ric31 ON ric31.ReportConfigurationId = d.ReportConfigId AND ric31.IndicatorId = 31
LEFT JOIN dbo.ReportIndicatorConfig ric32 ON ric32.ReportConfigurationId = d.ReportConfigId AND ric32.IndicatorId = 32
LEFT JOIN dbo.ReportIndicatorConfig ric33 ON ric33.ReportConfigurationId = d.ReportConfigId AND ric33.IndicatorId = 33
LEFT JOIN dbo.ReportIndicatorConfig ric34 ON ric34.ReportConfigurationId = d.ReportConfigId AND ric34.IndicatorId = 34
LEFT JOIN dbo.ReportIndicatorConfig ric35 ON ric35.ReportConfigurationId = d.ReportConfigId AND ric35.IndicatorId = 35
LEFT JOIN dbo.ReportIndicatorConfig ric36 ON ric36.ReportConfigurationId = d.ReportConfigId AND ric36.IndicatorId = 36
LEFT JOIN dbo.ReportIndicatorConfig ric37 ON ric37.ReportConfigurationId = d.ReportConfigId AND ric37.IndicatorId = 37
LEFT JOIN dbo.ReportIndicatorConfig ric38 ON ric38.ReportConfigurationId = d.ReportConfigId AND ric38.IndicatorId = 38
LEFT JOIN dbo.ReportIndicatorConfig ric39 ON ric39.ReportConfigurationId = d.ReportConfigId AND ric39.IndicatorId = 39
LEFT JOIN dbo.ReportIndicatorConfig ric40 ON ric40.ReportConfigurationId = d.ReportConfigId AND ric40.IndicatorId = 40
LEFT JOIN dbo.ReportIndicatorConfig ric41 ON ric41.ReportConfigurationId = d.ReportConfigId AND ric41.IndicatorId = 41
LEFT JOIN dbo.ReportIndicatorConfig ric42 ON ric42.ReportConfigurationId = d.ReportConfigId AND ric42.IndicatorId = 42
LEFT JOIN dbo.ReportIndicatorConfig ric43 ON ric43.ReportConfigurationId = d.ReportConfigId AND ric43.IndicatorId = 43

LEFT JOIN dbo.ReportIndicatorConfig ric46 ON ric46.ReportConfigurationId = d.ReportConfigId AND ric46.IndicatorId = 46
LEFT JOIN dbo.ReportIndicatorConfig ric47 ON ric47.ReportConfigurationId = d.ReportConfigId AND ric47.IndicatorId = 47
LEFT JOIN dbo.ReportIndicatorConfig ric48 ON ric48.ReportConfigurationId = d.ReportConfigId AND ric48.IndicatorId = 48
LEFT JOIN dbo.ReportIndicatorConfig ric49 ON ric49.ReportConfigurationId = d.ReportConfigId AND ric49.IndicatorId = 49
LEFT JOIN dbo.ReportIndicatorConfig ric50 ON ric50.ReportConfigurationId = d.ReportConfigId AND ric50.IndicatorId = 50
LEFT JOIN dbo.ReportIndicatorConfig ric51 ON ric51.ReportConfigurationId = d.ReportConfigId AND ric51.IndicatorId = 51
LEFT JOIN dbo.ReportIndicatorConfig ric52 ON ric52.ReportConfigurationId = d.ReportConfigId AND ric52.IndicatorId = 52
LEFT JOIN dbo.ReportIndicatorConfig ric53 ON ric53.ReportConfigurationId = d.ReportConfigId AND ric53.IndicatorId = 53
LEFT JOIN dbo.ReportIndicatorConfig ric54 ON ric54.ReportConfigurationId = d.ReportConfigId AND ric54.IndicatorId = 54
LEFT JOIN dbo.ReportIndicatorConfig ric55 ON ric55.ReportConfigurationId = d.ReportConfigId AND ric55.IndicatorId = 55
LEFT JOIN dbo.ReportIndicatorConfig ric56 ON ric56.ReportConfigurationId = d.ReportConfigId AND ric56.IndicatorId = 56
LEFT JOIN dbo.ReportIndicatorConfig ric57 ON ric57.ReportConfigurationId = d.ReportConfigId AND ric57.IndicatorId = 57
LEFT JOIN dbo.ReportIndicatorConfig ric58 ON ric58.ReportConfigurationId = d.ReportConfigId AND ric58.IndicatorId = 58

WHERE d.VehicleId IS NULL

SELECT GroupId,
       GroupName,
       GroupTypeID,
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

	OverspeedCount,
	OverspeedHighCount,
	StabilityControl,
	CollisionWarningLow,
	CollisionWarningMed,
	CollisionWarningHigh,
	LaneDepartureDisable,
	LaneDepartureLeftRight,
	Fatigue,
	Distraction,
	SweetSpotTime,
	OverRevTime,
	TopGearTime,

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
       CruiseOverspeedComponent,
       TopGearOverspeedComponent,

	OverspeedCountComponent,
	OverspeedHighCountComponent,
	StabilityControlComponent,
	CollisionWarningLowComponent,
	CollisionWarningMedComponent,
	CollisionWarningHighComponent,
	LaneDepartureDisableComponent,
	LaneDepartureLeftRightComponent,
	FatigueComponent,
	DistractionComponent,
	SweetSpotTimeComponent,
	OverRevTimeComponent,
	TopGearTimeComponent,

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
       FuelMult,
       SweetSpotColour,
       SweetSpotMix,
       OverRevWithFuelColour,
       OverRevWithFuelMix,
       TopGearColour,
       TopGearMix,
       CruiseColour,
       CruiseMix,
       CruiseInTopGearsColour,
       CruiseInTopGearsMix,
       CoastInGearColour,
       CoastInGearMix,
       IdleColour,
       IdleMix,
       EngineServiceBrakeColour,
       EngineServiceBrakeMix,
       OverRevWithoutFuelColour,
       OverRevWithoutFuelMix,
       RopColour,
       RopMix,
       Rop2Colour,
       Rop2Mix,
       OverSpeedColour,
       OverSpeedMix,
       OverSpeedHighColour,
       OverSpeedHighMix,
       IVHOverSpeedColour,
       IVHOverSpeedMix,
       CoastOutOfGearColour,
       CoastOutOfGearMix,
       HarshBrakingColour,
       HarshBrakingMix,
       EfficiencyColour,
       EfficiencyMix,
       SafetyColour,
       SafetyMix,
       KPLColour,
       KPLMix,
       Co2Colour,
       Co2Mix,
       OverSpeedDistanceColour,
       OverSpeedDistanceMix,
       AccelerationColour,
       AccelerationMix,
       BrakingColour,
       BrakingMix,
       CorneringColour,
       CorneringMix,
       AccelerationLowColour,
       AccelerationLowMix,
       BrakingLowColour,
       BrakingLowMix,
       CorneringLowColour,
       CorneringLowMix,
       AccelerationHighColour,
       AccelerationHighMix,
       BrakingHighColour,
       BrakingHighMix,
       CorneringHighColour,
       CorneringHighMix,
       ManoeuvresLowColour,
       ManoeuvresLowMix,
       ManoeuvresMedColour,
       ManoeuvresMedMix,
       CruiseTopGearRatioColour,
       CruiseTopGearRatioMix,
       OverRevCountColour,
       OverRevCountMix,
       PtoColour,
       PtoMix,
       CruiseOverspeedColour,
       CruiseOverspeedMix,
       TopGearOverspeedColour,
       TopGearOverspeedMix,
       FuelWastageCostColour,
	   
	OverspeedCountColour,
	OverspeedCountMix,
	OverspeedHighCountColour,
	OverspeedHighCountMix,
	StabilityControlColour,
	StabilityControlMix,
	CollisionWarningLowColour,
	CollisionWarningLowMix,
	CollisionWarningMedColour,
	CollisionWarningMedMix,
	CollisionWarningHighColour,
	CollisionWarningHighMix,
	LaneDepartureDisableColour,
	LaneDepartureDisableMix,
	LaneDepartureLeftRightColour,
	LaneDepartureLeftRightMix,
	FatigueColour,
	FatigueMix,
	DistractionColour,
	DistractionMix,
	SweetSpotTimeColour,
	SweetSpotTimeMix,
	OverRevTimeColour,
	OverRevTimeMix,
	TopGearTimeColour,
	TopGearTimeMix

FROM @data
WHERE VehicleId IS NULL	

GO
