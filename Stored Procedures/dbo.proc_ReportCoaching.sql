SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportCoaching]
(
	@dids varchar(max),
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER,
	@drilldown TINYINT,
	@calendar TINYINT,
	@groupBy INT
)
AS

--DECLARE	@dids VARCHAR(MAX),
--		@sdate datetime,
--		@edate datetime,
--		@uid uniqueidentifier,
--		@rprtcfgid UNIQUEIDENTIFIER,
--		@drilldown TINYINT,
--		@calendar TINYINT,
--		@groupBy INT

--SET @dids = N'64844794-79A0-454B-999B-D2B30C33992A'
----SET @dids = N'FE9BB5DB-3D6C-4375-8DB4-01043E2F5337' -- Geoff Hind
----SET @dids = N'EE3EB36D-5A27-4BB9-B163-543FB9F84085' -- Goodson. Graham

--	SET @sdate = '2020-03-23 00:00'
--	SET @edate = '2020-03-23 23:59'
--SET @uid = N'6E39B5F2-1CD4-4069-A562-0311E2584DDF'
--SET @rprtcfgid = N'1453f8c7-e0b5-4195-a10f-14e034f421b9'
--SET @drilldown = 1
--SET @calendar = 1
--SET @groupBy = 3

DECLARE	@ldids VARCHAR(MAX),
		@lsdate datetime,
		@ledate datetime,
		@luid uniqueidentifier,
		@lrprtcfgid UNIQUEIDENTIFIER,
		@ldrilldown TINYINT,
		@lcalendar TINYINT,
		@lgroupBy INT
		
SET @ldids = @dids
SET @lsdate = @sdate
SET @ledate = @edate
SET @luid = @uid
SET @lrprtcfgid = @rprtcfgid
SET @ldrilldown = @drilldown
SET @lcalendar = @calendar
SET @lgroupby = @groupBy

DECLARE @diststr varchar(20),
		@distmult float,
		@fuelstr varchar(20),
		@fuelmult float,
		@fuelcost FLOAT,
		@currency NVARCHAR(10),
		@co2str varchar(20),
		@co2mult FLOAT,
		@now DATETIME

SELECT @diststr = [dbo].UserPref(@luid, 203)
SELECT @distmult = [dbo].UserPref(@luid, 202)
SELECT @fuelstr = [dbo].UserPref(@luid, 205)
SELECT @fuelmult = [dbo].UserPref(@luid, 204)
SELECT @co2str = [dbo].UserPref(@luid, 211)
SELECT @co2mult = [dbo].UserPref(@luid, 210)
SELECT @currency = [dbo].UserPref(@luid, 381)

SELECT @fuelcost = CAST(cp.Value AS FLOAT)
FROM dbo.[User] u
INNER JOIN dbo.CustomerPreference cp ON cp.CustomerID = u.CustomerID
WHERE u.UserID = @luid
  AND cp.NameID = 3007

SET @lsdate = [dbo].TZ_ToUTC(@lsdate,default,@luid)
SET @ledate = [dbo].TZ_ToUTC(@ledate,default,@luid)
SET @now = GETDATE()

DECLARE	 @period_dates TABLE (
		PeriodNum TINYINT IDENTITY (1,1),
		StartDate DATETIME,
		EndDate DATETIME,
		PeriodType VARCHAR(MAX))
     
INSERT  INTO @period_dates ( StartDate, EndDate, PeriodType )
        SELECT  StartDate,
                EndDate,
                PeriodType
        FROM    dbo.CreateDependentDateRange(@lsdate, @ledate, @luid, @ldrilldown, @lcalendar, @lgroupBy)

-- Create temporary table for vehicle configs
DECLARE @VehicleConfig TABLE
(
	Vid UNIQUEIDENTIFIER,
	ReportConfigId UNIQUEIDENTIFIER
)

-- Get configs by vehicle
INSERT INTO @VehicleConfig (Vid, ReportConfigId)
SELECT DISTINCT v.VehicleId, ISNULL(vrc.ReportConfigurationId, @lrprtcfgid)
FROM dbo.Reporting r
INNER JOIN dbo.Vehicle v ON r.VehicleIntId = v.VehicleIntId
INNER JOIN dbo.Driver d ON r.DriverIntId = d.DriverIntId
LEFT JOIN dbo.VehicleReportConfiguration vrc ON v.VehicleId = vrc.VehicleId
WHERE d.DriverId IN (SELECT VALUE FROM dbo.Split(@ldids, ','))
	AND r.Date BETWEEN @lsdate AND @ledate

-- Pre-Process Data to get weighted distances
DECLARE @weightedData TABLE
(
	Date DATETIME,
	VehicleIntId INT,
	DriverIntId INT,
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

	wSpeedGauge FLOAT,SpeedGaugeTotal FLOAT,SpeedGaugeUsed INT,

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
	wManoeuvresLow FLOAT, ManoeuvresLowTotal FLOAT, ManoeuvresLowUsed TINYINT,		
	wManoeuvresMed FLOAT, ManoeuvresMedTotal FLOAT, ManoeuvresMedUsed TINYINT,		
	CruiseTopGearRatioUsed INT,
	wORCount FLOAT, ORCountTotal FLOAT, ORCountUsed INT,
	wPTOTime FLOAT, PTOTotal FLOAT, PTOUsed INT,
	wTotalFuel FLOAT, FuelEconTotal FLOAT,
	wTopGearOverSpeed FLOAT, TopGearOverSpeedTotal FLOAT, TopGearOverSpeedUsed TINYINT,
	wCruiseOverSpeed FLOAT, CruiseOverSpeedTotal FLOAT, CruiseOverSpeedUsed TINYINT,
	wFuelWastage FLOAT,
	wOverspeedCount FLOAT, OverspeedCountTotal FLOAT, OverspeedCountUsed INT,
	wOverspeedHighCount FLOAT, OverspeedHighCountTotal FLOAT, OverspeedHighCountUsed TINYINT,
	wStabilityControl FLOAT, StabilityControlTotal FLOAT, StabilityControlUsed TINYINT,
	wCollisionWarningLow FLOAT, CollisionWarningLowTotal FLOAT, CollisionWarningLowUsed TINYINT,
	wCollisionWarningMed FLOAT, CollisionWarningMedTotal FLOAT, CollisionWarningMedUsed TINYINT,
	wCollisionWarningHigh FLOAT, CollisionWarningHighTotal FLOAT, CollisionWarningHighUsed TINYINT,
	wLaneDepartureDisable FLOAT, LaneDepartureDisableTotal FLOAT, LaneDepartureDisableUsed TINYINT,
	wLaneDepartureLeftRight FLOAT, LaneDepartureLeftRightTotal FLOAT, LaneDepartureLeftRightUsed TINYINT,
	wSweetSpotTime FLOAT, SweetSpotTimeTotal FLOAT, SweetSpotTimeUsed TINYINT,
	wOverRevTime FLOAT, OverRevTimeTotal FLOAT, OverRevTimeUsed TINYINT,
	wTopGearTime FLOAT, TopGearTimeTotal FLOAT, TopGearTimeUsed TINYINT,
	wFatigue FLOAT, FatigueTotal FLOAT, FatigueUsed TINYINT,
	wDistraction FLOAT, DistractionTotal FLOAT, DistractionUsed TINYINT
)

INSERT INTO @weightedData  (Date, VehicleIntId, DriverIntId, 
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

							wSpeedGauge,--SpeedGaugeTotal,SpeedGaugeUsed,

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
							wFuelWastage,
							wOverspeedCount, OverspeedCountTotal, OverspeedCountUsed,
							wOverspeedHighCount, OverspeedHighCountTotal, OverspeedHighCountUsed,
							wStabilityControl, StabilityControlTotal, StabilityControlUsed,
							wCollisionWarningLow, CollisionWarningLowTotal, CollisionWarningLowUsed,
							wCollisionWarningMed, CollisionWarningMedTotal, CollisionWarningMedUsed,
							wCollisionWarningHigh, CollisionWarningHighTotal, CollisionWarningHighUsed,
							wLaneDepartureDisable, LaneDepartureDisableTotal, LaneDepartureDisableUsed,
							wLaneDepartureLeftRight, LaneDepartureLeftRightTotal, LaneDepartureLeftRightUsed,
							wSweetSpotTime, SweetSpotTimeTotal, SweetSpotTimeUsed,
							wOverRevTime, OverRevTimeTotal, OverRevTimeUsed,
							wTopGearTime, TopGearTimeTotal, TopGearTimeUsed,
							wFatigue, FatigueTotal, FatigueUsed,
							wDistraction, DistractionTotal, DistractionUsed)
SELECT	Date, VehicleIntId, DriverIntId, 
		SUM(wInSweetSpotDistance), SUM(InSweetSpotTotal), ISNULL(MAX(InSweetSpotUsed), 0),
		SUM(wFueledOverRPMDistance), SUM(FueledOverRPMTotal), ISNULL(MAX(FueledOverRPMUsed), 0),
		SUM(wTopGearDistance), SUM(TopGearTotal), ISNULL(MAX(TopGearUsed), 0),
		SUM(wCruiseControlDistance), SUM(CruiseTotal), ISNULL(MAX(CruiseUsed), 0),
		SUM(wCruiseInTopGearsDistance), SUM(CruiseInTopGearsTotal), ISNULL(MAX(CruiseInTopGearsUsed), 0),
		SUM(wCoastInGearDistance), SUM(CoastInGearTotal), ISNULL(MAX(CoastInGearUsed), 0),
		SUM(wIdleTime), SUM(IdleTotal), ISNULL(MAX(IdleUsed), 0),
		SUM(wServiceBrakeDistance), SUM(ServiceBrakeTotal), ISNULL(MAX(ServiceBrakeUsed), 0),
		SUM(wEngineBrakeOverRPMDistance), SUM(EngineBrakeOverRPMTotal), ISNULL(MAX(EngineBrakeOverRPMUsed), 0),
		SUM(wROPCount), SUM(ROPTotal), ISNULL(MAX(ROPUsed), 0),
		SUM(wROP2Count), SUM(ROP2Total), ISNULL(MAX(ROP2Used), 0),
		SUM(wOverspeedDistance), SUM(OverSpeedTotal), ISNULL(MAX(OverSpeedUsed), 0),
		SUM(wOverSpeedHighDistance), SUM(OverSpeedHighTotal), ISNULL(MAX(OverSpeedHighUsed), 0),
		SUM(wIVHOverSpeedDistance), SUM(IVHOverSpeedTotal), ISNULL(MAX(IVHOverSpeedUsed), 0),

		SUM(wSpeedGauge),-- SUM(SpeedGaugeTotal),ISNULL(MAX(SpeedGaugeUsed), 0),

		SUM(wCoastOutOfGearDistance), SUM(CoastOutOfGearTotal), ISNULL(MAX(CoastOutOfGearUsed), 0),
		SUM(wPanicStopCount), SUM(PanicStopTotal), ISNULL(MAX(PanicStopUsed), 0),
		SUM(wAcceleration), SUM(AccelerationTotal), ISNULL(MAX(AccelerationUsed), 0),
		SUM(wBraking), SUM(BrakingTotal), ISNULL(MAX(BrakingUsed), 0),
		SUM(wCornering), SUM(CorneringTotal), ISNULL(MAX(CorneringUsed), 0),
		SUM(wAccelerationLow), SUM(AccelerationLowTotal), ISNULL(MAX(AccelerationLowUsed), 0),
		SUM(wBrakingLow), SUM(BrakingLowTotal), ISNULL(MAX(BrakingLowUsed), 0),
		SUM(wCorneringLow), SUM(CorneringLowTotal), ISNULL(MAX(CorneringLowUsed), 0),
		SUM(wAccelerationHigh), SUM(AccelerationHighTotal), ISNULL(MAX(AccelerationHighUsed), 0),
		SUM(wBrakingHigh), SUM(BrakingHighTotal), ISNULL(MAX(BrakingHighUsed), 0),
		SUM(wCorneringHigh), SUM(CorneringHighTotal), ISNULL(MAX(CorneringHighUsed), 0),
		SUM(wManoeuvresLow), SUM(ManoeuvresLowTotal), ISNULL(MAX(ManoeuvresLowUsed), 0),
		SUM(wManoeuvresMed), SUM(ManoeuvresMedTotal), ISNULL(MAX(ManoeuvresMedUsed), 0),
		ISNULL(MAX(CruiseTopGearRatioUsed), 0),
		SUM(wORCount), SUM(ORCountUsed), ISNULL(MAX(ORCountUsed), 0),
		SUM(wPTOTime), SUM(PTOTotal), ISNULL(MAX(PTOUsed), 0),
		SUM(wTotalFuel), SUM(FuelEconTotal),
		SUM(wTopGearOverSpeed), SUM(TopGearOverSpeedTotal), ISNULL(MAX(TopGearOverSpeedUsed), 0),
		SUM(wCruiseOverSpeed), SUM(CruiseOverSpeedTotal), ISNULL(MAX(CruiseOverSpeedUsed), 0),
		SUM(wFuelWastage),
		SUM(wOverspeedCount), SUM(OverspeedCountTotal), ISNULL(MAX(OverspeedCountUsed), 0),
		SUM(wOverspeedHighCount), SUM(OverspeedHighCountTotal), ISNULL(MAX(OverspeedHighCountUsed), 0),
		SUM(wStabilityControl), SUM(StabilityControlTotal), ISNULL(MAX(StabilityControlUsed), 0),
		SUM(wCollisionWarningLow), SUM(CollisionWarningLowTotal), ISNULL(MAX(CollisionWarningLowUsed), 0),
		SUM(wCollisionWarningMed), SUM(CollisionWarningMedTotal), ISNULL(MAX(CollisionWarningMedUsed), 0),
		SUM(wCollisionWarningHigh), SUM(CollisionWarningHighTotal), ISNULL(MAX(CollisionWarningHighUsed), 0),
		SUM(wLaneDepartureDisable), SUM(LaneDepartureDisableTotal), ISNULL(MAX(LaneDepartureDisableUsed), 0),
		SUM(wLaneDepartureLeftRight), SUM(LaneDepartureLeftRightTotal), ISNULL(MAX(LaneDepartureLeftRightUsed), 0),
		SUM(wSweetSpotTime), SUM(SweetSpotTimeTotal), ISNULL(MAX(SweetSpotTimeUsed), 0),
		SUM(wOverRevTime), SUM(OverRevTimeTotal), ISNULL(MAX(OverRevTimeUsed), 0),
		SUM(wTopGearTime), SUM(TopGearTimeTotal), ISNULL(MAX(TopGearTimeUsed), 0),
		SUM(wFatigue), SUM(FatigueTotal), ISNULL(MAX(FatigueUsed), 0),
		SUM(wDistraction), SUM(DistractionTotal), ISNULL(MAX(DistractionUsed), 0)
FROM	
	(
	SELECT	r.Date, r.VehicleIntId, r.DriverIntId,
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

			CASE WHEN ic.IndicatorId = 44 THEN ISNULL(r.FuelWastage,0) END AS wFuelWastage,

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

			CASE WHEN ic.IndicatorId = 54 THEN re.SweetSpotTime END AS wSweetSpotTime,
			CASE WHEN ic.IndicatorId = 54 THEN r.TotalTime END AS SweetSpotTimeTotal,
			CASE WHEN ic.IndicatorId = 54 THEN 1 END AS SweetSpotTimeUsed,

			CASE WHEN ic.IndicatorId = 55 THEN re.OverRPMTime END AS wOverRevTime,
			CASE WHEN ic.IndicatorId = 55 THEN r.TotalTime END AS OverRevTimeTotal,
			CASE WHEN ic.IndicatorId = 55 THEN 1 END AS OverRevTimeUsed,

			CASE WHEN ic.IndicatorId = 56 THEN re.TopGearTime END AS wTopGearTime,
			CASE WHEN ic.IndicatorId = 56 THEN r.TotalTime END AS TopGearTimeTotal,
			CASE WHEN ic.IndicatorId = 56 THEN 1 END AS TopGearTimeUsed,

			CASE WHEN ic.IndicatorId = 57 THEN re.Fatigue END AS wFatigue,
			CASE WHEN ic.IndicatorId = 57 THEN r.DrivingDistance + r.PTOMovingDistance END AS FatigueTotal,
			CASE WHEN ic.IndicatorId = 57 THEN 1 END AS FatigueUsed,

			CASE WHEN ic.IndicatorId = 58 THEN re.Distraction END AS wDistraction,
			CASE WHEN ic.IndicatorId = 58 THEN r.DrivingDistance + r.PTOMovingDistance END AS DistractionTotal,
			CASE WHEN ic.IndicatorId = 58 THEN 1 END AS DistractionUsed,

			CASE WHEN ic.IndicatorId = 59 THEN ISNULL(ro.Incidents / CAST(CASE WHEN ro.Observations = 0 THEN NULL ELSE ro.Observations end AS FLOAT), 0)END   AS wSpeedGauge


	FROM dbo.Reporting r		
		INNER JOIN dbo.Vehicle v ON r.VehicleIntId = v.VehicleIntId
		INNER JOIN @VehicleConfig vc ON v.VehicleId = vc.Vid
		INNER JOIN dbo.IndicatorConfig ic ON vc.ReportConfigId = ic.ReportConfigurationId

		INNER JOIN dbo.Driver d ON r.DriverIntId = d.DriverIntId
		LEFT JOIN dbo.ReportingABC abc ON r.VehicleIntId = abc.VehicleIntId AND r.DriverIntId = abc.DriverIntId AND r.Date = abc.Date --AND r.RouteID = abc.RouteId
		LEFT JOIN dbo.ReportingOverspeed ro ON r.VehicleIntId = ro.VehicleIntId AND r.DriverIntId = ro.DriverIntId AND r.Date = ro.Date --AND r.RouteID = ro.RouteId
		LEFT JOIN dbo.ReportingExtra re ON r.VehicleIntId = re.VehicleIntId AND r.DriverIntId = re.DriverIntId AND r.Date = re.Date
	WHERE r.Date BETWEEN @lsdate AND @ledate 
	  AND r.DrivingDistance > 0
	  AND ic.Archived = 0
	) raw
GROUP BY raw.Date, raw.VehicleIntId, raw.DriverIntId

-- Now determine if the driver / vehicle / total combinations use multiple configurations for each Indicator
DECLARE @ConfigCount TABLE
(
	VehicleIntId INT,
	DriverIntId INT,
	SweetSpotMix SMALLINT,
	FueledOverRPMMix SMALLINT,
	TopGearMix SMALLINT,
	CruiseMix SMALLINT,
	CruiseInTopGearsMix SMALLINT,
	CoastInGearMix SMALLINT,
	IdleMix SMALLINT,
	ServiceBrakeMix SMALLINT,
	EngineBrakeMix SMALLINT,
	RopMix SMALLINT,
	Rop2Mix SMALLINT,
	OverSpeedMix SMALLINT,
	OverSpeedHighMix SMALLINT,
	IVHOverSpeedMix SMALLINT,

	SpeedGaugeMix SMALLINT,

	CoastOutOfGearMix SMALLINT,
	HarshBrakingMix SMALLINT,
	AccelerationMix SMALLINT,
	BrakingMix SMALLINT,
	CorneringMix SMALLINT,
	AccelerationLowMix SMALLINT,
	BrakingLowMix SMALLINT,
	CorneringLowMix SMALLINT,
	AccelerationHighMix SMALLINT,
	BrakingHighMix SMALLINT,
	CorneringHighMix SMALLINT,
	ManoeuvresLowMix SMALLINT,
	ManoeuvresMedMix SMALLINT,
	ORCountMix SMALLINT,
	PtoMix SMALLINT,
	CruiseTopGearRatioMix SMALLINT,
	CruiseOverspeedMix SMALLINT,
	TopGearOverspeedMix SMALLINT,
	OverspeedCountMix SMALLINT,
	OverspeedHighCountMix SMALLINT,
	StabilityControlMix SMALLINT,
	CollisionWarningLowMix SMALLINT,
	CollisionWarningMedMix SMALLINT,
	CollisionWarningHighMix SMALLINT,
	LaneDepartureDisableMix SMALLINT,
	LaneDepartureLeftRightMix SMALLINT,
	SweetSpotTimeMix SMALLINT,
	OverRevTimeMix SMALLINT,
	TopGearTimeMix SMALLINT,
	FatigueMix SMALLINT,
	DistractionMix SMALLINT
)

INSERT INTO @ConfigCount (VehicleIntId, DriverIntId, SweetSpotMix, FueledOverRPMMix, TopGearMix, CruiseMix, CruiseInTopGearsMix, CoastInGearMix,
						  IdleMix, ServiceBrakeMix, EngineBrakeMix, RopMix, Rop2Mix, OverSpeedMix, OverSpeedHighMix, IVHOverSpeedMix,SpeedGaugeMix, CoastOutOfGearMix,
						  HarshBrakingMix, AccelerationMix, BrakingMix, CorneringMix, AccelerationLowMix, BrakingLowMix, CorneringLowMix, 
						  AccelerationHighMix, BrakingHighMix, CorneringHighMix, ManoeuvresLowMix, ManoeuvresMedMix, ORCountMix, PtoMix, CruiseTopGearRatioMix,
						  CruiseOverspeedMix, TopGearOverspeedMix, OverspeedCountMix, OverspeedHighCountMix, StabilityControlMix, CollisionWarningLowMix, CollisionWarningMedMix,
						  CollisionWarningHighMix, LaneDepartureDisableMix, LaneDepartureLeftRightMix, SweetSpotTimeMix, OverRevTimeMix, TopGearTimeMix, FatigueMix, DistractionMix)
SELECT	VehicleIntId, 
		DriverintId, 
		COUNT(DISTINCT InSweetSpotUsed) - 1,
		COUNT(DISTINCT FueledOverRPMUsed) - 1,
		COUNT(DISTINCT TopGearUsed) - 1,
		COUNT(DISTINCT CruiseUsed) - 1,
		COUNT(DISTINCT CruiseInTopGearsUsed) - 1,
		COUNT(DISTINCT CoastInGearUsed) - 1,
		COUNT(DISTINCT IdleUsed) - 1,
		COUNT(DISTINCT ServiceBrakeUsed) - 1,
		COUNT(DISTINCT EngineBrakeOverRPMUsed) - 1,
		COUNT(DISTINCT ROPUsed) - 1,
		COUNT(DISTINCT ROP2Used) - 1,
		COUNT(DISTINCT OverSpeedUsed) - 1,
		COUNT(DISTINCT OverSpeedHighUsed) - 1,
		COUNT(DISTINCT IVHOverSpeedUsed) - 1,

		COUNT(DISTINCT SpeedGaugeUsed) - 1,

		COUNT(DISTINCT CoastOutOfGearUsed) - 1,
		COUNT(DISTINCT PanicStopUsed) - 1,
		COUNT(DISTINCT AccelerationUsed) - 1,
		COUNT(DISTINCT BrakingUsed) - 1,
		COUNT(DISTINCT CorneringUsed) - 1,
		COUNT(DISTINCT AccelerationLowUsed) - 1,
		COUNT(DISTINCT BrakingLowUsed) - 1,
		COUNT(DISTINCT CorneringLowUsed) - 1,
		COUNT(DISTINCT AccelerationHighUsed) - 1,
		COUNT(DISTINCT BrakingHighUsed) - 1,
		COUNT(DISTINCT CorneringHighUsed) - 1,
		COUNT(DISTINCT ManoeuvresLowUsed) - 1,
		COUNT(DISTINCT ManoeuvresMedUsed) - 1,
		COUNT(DISTINCT ORCountUsed) - 1,
		COUNT(DISTINCT PTOUsed) - 1,
		COUNT(DISTINCT CruiseTopGearRatioUsed) - 1,
		COUNT(DISTINCT CruiseOverSpeedUsed) - 1,
		COUNT(DISTINCT TopGearOverSpeedUsed) - 1,
		COUNT(DISTINCT OverspeedCountUsed) -1,
		COUNT(DISTINCT OverspeedHighCountUsed) -1,
		COUNT(DISTINCT StabilityControlUsed) -1,
		COUNT(DISTINCT CollisionWarningLowUsed) -1,
		COUNT(DISTINCT CollisionWarningMedUsed) -1,
		COUNT(DISTINCT CollisionWarningHighUsed) -1,
		COUNT(DISTINCT LaneDepartureDisableUsed) -1,
		COUNT(DISTINCT LaneDepartureLeftRightUsed) -1,
		COUNT(DISTINCT SweetSpotTimeUsed) -1,
		COUNT(DISTINCT OverRevTimeUsed) -1,
		COUNT(DISTINCT TopGearTimeUsed) -1,
		COUNT(DISTINCT FatigueUsed) -1,
		COUNT(DISTINCT DistractionUsed) -1
FROM @weightedData wd
GROUP BY VehicleIntId, DriverIntId

INSERT INTO @ConfigCount (VehicleIntId, DriverIntId, SweetSpotMix, FueledOverRPMMix, TopGearMix, CruiseMix, CruiseInTopGearsMix, CoastInGearMix,
						  IdleMix, ServiceBrakeMix, EngineBrakeMix, RopMix, Rop2Mix, OverSpeedMix, OverSpeedHighMix, IVHOverSpeedMix,SpeedGaugeMix, CoastOutOfGearMix,
						  HarshBrakingMix, AccelerationMix, BrakingMix, CorneringMix, AccelerationLowMix, BrakingLowMix, CorneringLowMix, 
						  AccelerationHighMix, BrakingHighMix, CorneringHighMix, ManoeuvresLowMix, ManoeuvresMedMix, ORCountMix, PtoMix, CruiseTopGearRatioMix,
						  CruiseOverspeedMix, TopGearOverspeedMix, OverspeedCountMix, OverspeedHighCountMix, StabilityControlMix, CollisionWarningLowMix, CollisionWarningMedMix,
						  CollisionWarningHighMix, LaneDepartureDisableMix, LaneDepartureLeftRightMix, SweetSpotTimeMix, OverRevTimeMix, TopGearTimeMix, FatigueMix, DistractionMix)
SELECT	VehicleIntId, 
		0, 
		COUNT(DISTINCT InSweetSpotUsed) - 1, 
		COUNT(DISTINCT FueledOverRPMUsed) - 1,
		COUNT(DISTINCT TopGearUsed) - 1,
		COUNT(DISTINCT CruiseUsed) - 1,
		COUNT(DISTINCT CruiseInTopGearsUsed) - 1,
		COUNT(DISTINCT CoastInGearUsed) - 1,
		COUNT(DISTINCT IdleUsed) - 1,
		COUNT(DISTINCT ServiceBrakeUsed) - 1,
		COUNT(DISTINCT EngineBrakeOverRPMUsed) - 1,
		COUNT(DISTINCT ROPUsed) - 1,
		COUNT(DISTINCT ROP2Used) - 1,
		COUNT(DISTINCT OverSpeedUsed) - 1,
		COUNT(DISTINCT OverSpeedHighUsed) - 1,
		COUNT(DISTINCT IVHOverSpeedUsed) - 1,

		COUNT(DISTINCT SpeedGaugeUsed) - 1,

		COUNT(DISTINCT CoastOutOfGearUsed) - 1,
		COUNT(DISTINCT PanicStopUsed) - 1,
		COUNT(DISTINCT AccelerationUsed) - 1,
		COUNT(DISTINCT BrakingUsed) - 1,
		COUNT(DISTINCT CorneringUsed) - 1,
		COUNT(DISTINCT AccelerationLowUsed) - 1,
		COUNT(DISTINCT BrakingLowUsed) - 1,
		COUNT(DISTINCT CorneringLowUsed) - 1,
		COUNT(DISTINCT AccelerationHighUsed) - 1,
		COUNT(DISTINCT BrakingHighUsed) - 1,
		COUNT(DISTINCT CorneringHighUsed) - 1,
		COUNT(DISTINCT ManoeuvresLowUsed) - 1,
		COUNT(DISTINCT ManoeuvresMedUsed) - 1,
		COUNT(DISTINCT ORCountUsed) - 1,
		COUNT(DISTINCT PTOUsed) - 1,
		COUNT(DISTINCT CruiseTopGearRatioUsed) - 1,
		COUNT(DISTINCT CruiseOverSpeedUsed) - 1,
		COUNT(DISTINCT TopGearOverSpeedUsed) - 1,
		COUNT(DISTINCT OverspeedCountUsed) -1,
		COUNT(DISTINCT OverspeedHighCountUsed) -1,
		COUNT(DISTINCT StabilityControlUsed) -1,
		COUNT(DISTINCT CollisionWarningLowUsed) -1,
		COUNT(DISTINCT CollisionWarningMedUsed) -1,
		COUNT(DISTINCT CollisionWarningHighUsed) -1,
		COUNT(DISTINCT LaneDepartureDisableUsed) -1,
		COUNT(DISTINCT LaneDepartureLeftRightUsed) -1,
		COUNT(DISTINCT SweetSpotTimeUsed) -1,
		COUNT(DISTINCT OverRevTimeUsed) -1,
		COUNT(DISTINCT TopGearTimeUsed) -1,
		COUNT(DISTINCT FatigueUsed) -1,
		COUNT(DISTINCT DistractionUsed) -1
FROM @weightedData wd
GROUP BY VehicleIntId

INSERT INTO @ConfigCount (VehicleIntId, DriverIntId, SweetSpotMix, FueledOverRPMMix, TopGearMix, CruiseMix, CruiseInTopGearsMix, CoastInGearMix,
						  IdleMix, ServiceBrakeMix, EngineBrakeMix, RopMix, Rop2Mix, OverSpeedMix, OverSpeedHighMix, IVHOverSpeedMix,SpeedGaugeMix, CoastOutOfGearMix,
						  HarshBrakingMix, AccelerationMix, BrakingMix, CorneringMix, AccelerationLowMix, BrakingLowMix, CorneringLowMix, 
						  AccelerationHighMix, BrakingHighMix, CorneringHighMix, ManoeuvresLowMix, ManoeuvresMedMix, ORCountMix, PtoMix, CruiseTopGearRatioMix,
						  CruiseOverspeedMix, TopGearOverspeedMix, OverspeedCountMix, OverspeedHighCountMix, StabilityControlMix, CollisionWarningLowMix, CollisionWarningMedMix,
						  CollisionWarningHighMix, LaneDepartureDisableMix, LaneDepartureLeftRightMix, SweetSpotTimeMix, OverRevTimeMix, TopGearTimeMix, FatigueMix, DistractionMix)
SELECT	0, 
		DriverIntId, 
		COUNT(DISTINCT InSweetSpotUsed) - 1, 
		COUNT(DISTINCT FueledOverRPMUsed) - 1 ,
		COUNT(DISTINCT TopGearUsed) - 1,
		COUNT(DISTINCT CruiseUsed) - 1,
		COUNT(DISTINCT CruiseInTopGearsUsed) - 1,
		COUNT(DISTINCT CoastInGearUsed) - 1,
		COUNT(DISTINCT IdleUsed) - 1,
		COUNT(DISTINCT ServiceBrakeUsed) - 1,
		COUNT(DISTINCT EngineBrakeOverRPMUsed) - 1,
		COUNT(DISTINCT ROPUsed) - 1,
		COUNT(DISTINCT ROP2Used) - 1,
		COUNT(DISTINCT OverSpeedUsed) - 1,
		COUNT(DISTINCT OverSpeedHighUsed) - 1,
		COUNT(DISTINCT IVHOverSpeedUsed) - 1,

		COUNT(DISTINCT SpeedGaugeUsed) - 1,

		COUNT(DISTINCT CoastOutOfGearUsed) - 1,
		COUNT(DISTINCT PanicStopUsed) - 1,
		COUNT(DISTINCT AccelerationUsed) - 1,
		COUNT(DISTINCT BrakingUsed) - 1,
		COUNT(DISTINCT CorneringUsed) - 1,
		COUNT(DISTINCT AccelerationLowUsed) - 1,
		COUNT(DISTINCT BrakingLowUsed) - 1,
		COUNT(DISTINCT CorneringLowUsed) - 1,
		COUNT(DISTINCT AccelerationHighUsed) - 1,
		COUNT(DISTINCT BrakingHighUsed) - 1,
		COUNT(DISTINCT CorneringHighUsed) - 1,
		COUNT(DISTINCT ManoeuvresLowUsed) - 1,
		COUNT(DISTINCT ManoeuvresMedUsed) - 1,
		COUNT(DISTINCT ORCountUsed) - 1,
		COUNT(DISTINCT PTOUsed) - 1,
		COUNT(DISTINCT CruiseTopGearRatioUsed) - 1,
		COUNT(DISTINCT CruiseOverSpeedUsed) - 1,
		COUNT(DISTINCT TopGearOverSpeedUsed) - 1,
		COUNT(DISTINCT OverspeedCountUsed) -1,
		COUNT(DISTINCT OverspeedHighCountUsed) -1,
		COUNT(DISTINCT StabilityControlUsed) -1,
		COUNT(DISTINCT CollisionWarningLowUsed) -1,
		COUNT(DISTINCT CollisionWarningMedUsed) -1,
		COUNT(DISTINCT CollisionWarningHighUsed) -1,
		COUNT(DISTINCT LaneDepartureDisableUsed) -1,
		COUNT(DISTINCT LaneDepartureLeftRightUsed) -1,
		COUNT(DISTINCT SweetSpotTimeUsed) -1,
		COUNT(DISTINCT OverRevTimeUsed) -1,
		COUNT(DISTINCT TopGearTimeUsed) -1,
		COUNT(DISTINCT FatigueUsed) -1,
		COUNT(DISTINCT DistractionUsed) -1
FROM @weightedData wd
GROUP BY DriverIntId

INSERT INTO @ConfigCount (VehicleIntId, DriverIntId, SweetSpotMix, FueledOverRPMMix, TopGearMix, CruiseMix, CruiseInTopGearsMix, CoastInGearMix,
						  IdleMix, ServiceBrakeMix, EngineBrakeMix, RopMix, Rop2Mix, OverSpeedMix, OverSpeedHighMix, IVHOverSpeedMix,SpeedGaugeMix, CoastOutOfGearMix,
						  HarshBrakingMix, AccelerationMix, BrakingMix, CorneringMix, AccelerationLowMix, BrakingLowMix, CorneringLowMix, 
						  AccelerationHighMix, BrakingHighMix, CorneringHighMix, ManoeuvresLowMix, ManoeuvresMedMix, ORCountMix, PtoMix, CruiseTopGearRatioMix,
						  CruiseOverspeedMix, TopGearOverspeedMix, OverspeedCountMix, OverspeedHighCountMix, StabilityControlMix, CollisionWarningLowMix, CollisionWarningMedMix,
						  CollisionWarningHighMix, LaneDepartureDisableMix, LaneDepartureLeftRightMix, SweetSpotTimeMix, OverRevTimeMix, TopGearTimeMix, FatigueMix, DistractionMix)
SELECT	0, 
		0, 
		COUNT(DISTINCT InSweetSpotUsed) - 1, 
		COUNT(DISTINCT FueledOverRPMUsed) - 1,
		COUNT(DISTINCT TopGearUsed) - 1,
		COUNT(DISTINCT CruiseUsed) - 1,
		COUNT(DISTINCT CruiseInTopGearsUsed) - 1,
		COUNT(DISTINCT CoastInGearUsed) - 1,
		COUNT(DISTINCT IdleUsed) - 1,
		COUNT(DISTINCT ServiceBrakeUsed) - 1,
		COUNT(DISTINCT EngineBrakeOverRPMUsed) - 1,
		COUNT(DISTINCT ROPUsed) - 1,
		COUNT(DISTINCT ROP2Used) - 1,
		COUNT(DISTINCT OverSpeedUsed) - 1,
		COUNT(DISTINCT OverSpeedHighUsed) - 1,
		COUNT(DISTINCT IVHOverSpeedUsed) - 1,

		COUNT(DISTINCT SpeedGaugeUsed) - 1,

		COUNT(DISTINCT CoastOutOfGearUsed) - 1,
		COUNT(DISTINCT PanicStopUsed) - 1,
		COUNT(DISTINCT AccelerationUsed) - 1,
		COUNT(DISTINCT BrakingUsed) - 1,
		COUNT(DISTINCT CorneringUsed) - 1,
		COUNT(DISTINCT AccelerationLowUsed) - 1,
		COUNT(DISTINCT BrakingLowUsed) - 1,
		COUNT(DISTINCT CorneringLowUsed) - 1,
		COUNT(DISTINCT AccelerationHighUsed) - 1,
		COUNT(DISTINCT BrakingHighUsed) - 1,
		COUNT(DISTINCT CorneringHighUsed) - 1,
		COUNT(DISTINCT ManoeuvresLowUsed) - 1,
		COUNT(DISTINCT ManoeuvresMedUsed) - 1,
		COUNT(DISTINCT ORCountUsed) - 1,
		COUNT(DISTINCT PTOUsed) - 1,
		COUNT(DISTINCT CruiseTopGearRatioUsed) - 1,
		COUNT(DISTINCT CruiseOverSpeedUsed) - 1,
		COUNT(DISTINCT TopGearOverSpeedUsed) - 1,
		COUNT(DISTINCT OverspeedCountUsed) -1,
		COUNT(DISTINCT OverspeedHighCountUsed) -1,
		COUNT(DISTINCT StabilityControlUsed) -1,
		COUNT(DISTINCT CollisionWarningLowUsed) -1,
		COUNT(DISTINCT CollisionWarningMedUsed) -1,
		COUNT(DISTINCT CollisionWarningHighUsed) -1,
		COUNT(DISTINCT LaneDepartureDisableUsed) -1,
		COUNT(DISTINCT LaneDepartureLeftRightUsed) -1,
		COUNT(DISTINCT SweetSpotTimeUsed) -1,
		COUNT(DISTINCT OverRevTimeUsed) -1,
		COUNT(DISTINCT TopGearTimeUsed) -1,
		COUNT(DISTINCT FatigueUsed) -1,
		COUNT(DISTINCT DistractionUsed) -1
FROM @weightedData wd

-- Now perform main report processing
SELECT
		-- Period identification columns
 		p.PeriodNum,
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

 		--[0], [1], [2], [3], [4], [97], [98], [99],

		[4] AS Coached,
		[3] + [97] AS NotRequired,
		[1] + [2] AS NotCoached,

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

		SpeedGauge,

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
		FuelWastage * @fuelcost AS FuelWastageCost,
		OverspeedCount / 100.0 AS OverspeedCount,
		OverspeedHighCount / 100.0 AS OverspeedHighCount,
		StabilityControl / 100.0 AS StabilityControl,
		CollisionWarningLow / 100.0 AS CollisionWarningLow,
		CollisionWarningMed / 100.0 AS CollisionWarningMed,
		CollisionWarningHigh / 100.0 AS CollisionWarningHigh,
		LaneDepartureDisable / 100.0 AS LaneDepartureDisable,
		LaneDepartureLeftRight / 100.0 AS LaneDepartureLeftRight,
		SweetSpotTime,
		OverRevTime,
		TopGearTime,
		Fatigue / 100.0 AS Fatigue,
		Distraction / 100.0 AS Distraction,

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

		SpeedGaugeComponent,

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
		OverspeedCountComponent,
		OverspeedHighCountComponent,
		StabilityControlComponent,
		CollisionWarningLowComponent,
		CollisionWarningMedComponent,
		CollisionWarningHighComponent,
		LaneDepartureDisableComponent,
		LaneDepartureLeftRightComponent,
		SweetSpotTimeComponent,
		OverRevTimeComponent,
		TopGearTimeComponent,
		FatigueComponent,
		DistractionComponent,
		
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
		@currency AS Currency,

		-- Colour columns corresponding to data columns above
		dbo.GYRColourConfig(SweetSpot*100, 1, ISNULL(ReportConfigId, @rprtcfgid)) AS SweetSpotColour, SweetSpotMix,
		dbo.GYRColourConfig(OverRevWithFuel*100, 2, ISNULL(ReportConfigId, @lrprtcfgid)) AS OverRevWithFuelColour, FueledOverRPMMix AS OverRevWithFuelMix,
		dbo.GYRColourConfig(TopGear*100, 3, ISNULL(ReportConfigId, @lrprtcfgid)) AS TopGearColour, TopGearMix,
		dbo.GYRColourConfig(Cruise*100, 4, ISNULL(ReportConfigId, @lrprtcfgid)) AS CruiseColour, CruiseMix,
		dbo.GYRColourConfig(CruiseInTopGears*100, 31, ISNULL(ReportConfigId, @lrprtcfgid)) AS CruiseInTopGearsColour, CruiseInTopGearsMix,
		dbo.GYRColourConfig(CoastInGear*100, 5, ISNULL(ReportConfigId, @lrprtcfgid)) AS CoastInGearColour, CoastInGearMix,
		dbo.GYRColourConfig(Idle*100, 6, ISNULL(ReportConfigId, @lrprtcfgid)) AS IdleColour, IdleMix,
		dbo.GYRColourConfig(EngineServiceBrake*100, 7, ISNULL(ReportConfigId, @lrprtcfgid)) AS EngineServiceBrakeColour, ServiceBrakeMix AS EngineServiceBrakeMix,
		dbo.GYRColourConfig(OverRevWithoutFuel*100, 8, ISNULL(ReportConfigId, @lrprtcfgid)) AS OverRevWithoutFuelColour, EngineBrakeMix AS OverRevWithoutFuelMix,
		dbo.GYRColourConfig(Rop, 9, ISNULL(ReportConfigId, @lrprtcfgid)) AS RopColour, RopMix,
		dbo.GYRColourConfig(Rop2, 41, ISNULL(ReportConfigId, @lrprtcfgid)) AS Rop2Colour, Rop2Mix,
		dbo.GYRColourConfig(OverSpeed*100, 10, ISNULL(ReportConfigId, @lrprtcfgid)) AS OverSpeedColour, OverSpeedMix,
		dbo.GYRColourConfig(OverSpeedHigh*100, 32, ISNULL(ReportConfigId, @lrprtcfgid)) AS OverSpeedHighColour, OverSpeedHighMix,
		dbo.GYRColourConfig(IVHOverSpeed*100, 30, ISNULL(ReportConfigId, @lrprtcfgid)) AS IVHOverSpeedColour, IVHOverSpeedMix,

		dbo.GYRColourConfig(SpeedGauge*100, 59, ISNULL(ReportConfigId, @lrprtcfgid)) AS SpeedGaugeColour, SpeedGaugeMix,

		dbo.GYRColourConfig(CoastOutOfGear*100, 11, ISNULL(ReportConfigId, @lrprtcfgid)) AS CoastOutOfGearColour, CoastOutOfGearMix,
		dbo.GYRColourConfig(HarshBraking, 12, ISNULL(ReportConfigId, @lrprtcfgid)) AS HarshBrakingColour, HarshBrakingMix,
		dbo.GYRColourConfig(Efficiency, 14, ISNULL(ReportConfigId, @lrprtcfgid)) AS EfficiencyColour, NULL AS EfficiencyMix,
		dbo.GYRColourConfig(Safety, 15, ISNULL(ReportConfigId, @lrprtcfgid)) AS SafetyColour, NULL AS SafetyMix,
		dbo.GYRColourConfig(FuelEcon, 16, ReportConfigId) AS KPLColour, NULL AS KPLMix,
		dbo.GYRColourConfig(Co2, 20, ReportConfigId) AS Co2Colour, NULL AS Co2Mix,
		dbo.GYRColourConfig(OverSpeedDistance * 100, 21, ISNULL(ReportConfigId, @lrprtcfgid)) AS OverSpeedDistanceColour, IVHOverSpeedMix AS OverSpeedDistanceMix,
		dbo.GYRColourConfig(Acceleration, 22, ISNULL(ReportConfigId, @lrprtcfgid)) AS AccelerationColour, AccelerationMix,
		dbo.GYRColourConfig(Braking, 23, ISNULL(ReportConfigId, @lrprtcfgid)) AS BrakingColour, BrakingMix,
		dbo.GYRColourConfig(Cornering, 24, ISNULL(ReportConfigId, @lrprtcfgid)) AS CorneringColour, CorneringMix,
		dbo.GYRColourConfig(AccelerationLow, 33, ISNULL(ReportConfigId, @lrprtcfgid)) AS AccelerationLowColour, AccelerationLowMix,
		dbo.GYRColourConfig(BrakingLow, 34, ISNULL(ReportConfigId, @lrprtcfgid)) AS BrakingLowColour, BrakingLowMix,
		dbo.GYRColourConfig(CorneringLow, 35, ISNULL(ReportConfigId, @lrprtcfgid)) AS CorneringLowColour, CorneringLowMix,
		dbo.GYRColourConfig(AccelerationHigh, 36, ISNULL(ReportConfigId, @lrprtcfgid)) AS AccelerationHighColour, AccelerationHighMix,
		dbo.GYRColourConfig(BrakingHigh, 37, ISNULL(ReportConfigId, @lrprtcfgid)) AS BrakingHighColour, BrakingHighMix,
		dbo.GYRColourConfig(CorneringHigh, 38, ISNULL(ReportConfigId, @lrprtcfgid)) AS CorneringHighColour, CorneringHighMix,
		dbo.GYRColourConfig(ManoeuvresLow, 39, ISNULL(ReportConfigId, @lrprtcfgid)) AS ManoeuvresLowColour, ManoeuvresLowMix,
		dbo.GYRColourConfig(ManoeuvresMed, 40, ISNULL(ReportConfigId, @lrprtcfgid)) AS ManoeuvresMedColour, ManoeuvresMedMix,
		dbo.GYRColourConfig(CruiseTopGearRatio*100, 25, ISNULL(ReportConfigId, @lrprtcfgid)) AS CruiseTopGearRatioColour, CruiseTopGearRatioMix,
		dbo.GYRColourConfig(OverRevCount, 28, ISNULL(ReportConfigId, @lrprtcfgid)) AS OverRevCountColour, ORCountMix AS OverRevCountMix,
		dbo.GYRColourConfig(Pto*100, 29, ISNULL(ReportConfigId, @lrprtcfgid)) AS PtoColour, PtoMix,
		dbo.GYRColourConfig(CruiseOverspeed*100, 43, ISNULL(ReportConfigId, @lrprtcfgid)) AS CruiseOverspeedColour, CruiseOverspeedMix,
		dbo.GYRColourConfig(TopGearOverspeed*100, 42, ISNULL(ReportConfigId, @lrprtcfgid)) AS TopGearOverspeedColour, TopGearOverspeedMix,
		NULL AS FuelWastageCostColour,
		dbo.GYRColourConfig(OverSpeedCount, 46, ISNULL(ReportConfigId, @lrprtcfgid)) AS OverspeedCountColour, OverspeedCountMix,
		dbo.GYRColourConfig(OverSpeedHighCount, 47, ISNULL(ReportConfigId, @lrprtcfgid)) AS OverspeedHighCountColour, OverspeedHighCountMix,
		dbo.GYRColourConfig(StabilityControl, 48, ISNULL(ReportConfigId, @lrprtcfgid)) AS StabilityControlColour, StabilityControlMix,
		dbo.GYRColourConfig(CollisionWarningLow, 49, ISNULL(ReportConfigId, @lrprtcfgid)) AS CollisionWarningLowColour, CollisionWarningLowMix,
		dbo.GYRColourConfig(CollisionWarningMed, 50, ISNULL(ReportConfigId, @lrprtcfgid)) AS CollisionWarningMedColour, CollisionWarningMedMix,
		dbo.GYRColourConfig(CollisionWarningHigh, 51, ISNULL(ReportConfigId, @lrprtcfgid)) AS CollisionWarningHighColour, CollisionWarningHighMix,
		dbo.GYRColourConfig(LaneDepartureDisable, 52, ISNULL(ReportConfigId, @lrprtcfgid)) AS LaneDepartureDisableColour, LaneDepartureDisableMix,
		dbo.GYRColourConfig(LaneDepartureLeftRight, 53, ISNULL(ReportConfigId, @lrprtcfgid)) AS LaneDepartureLeftRightColour, LaneDepartureLeftRightMix,
		dbo.GYRColourConfig(SweetSpotTime*100, 54, ISNULL(ReportConfigId, @lrprtcfgid)) AS SweetSpotTimeColour, SweetSpotTimeMix,
		dbo.GYRColourConfig(OverRevTime*100, 55, ISNULL(ReportConfigId, @lrprtcfgid)) AS OverRevTimeColour, OverRevTimeMix,
		dbo.GYRColourConfig(TopGearTime*100, 56, ISNULL(ReportConfigId, @lrprtcfgid)) AS TopGearTimeColour, TopGearTimeMix,
		dbo.GYRColourConfig(Fatigue, 57, ISNULL(ReportConfigId, @lrprtcfgid)) AS FatigueColour, FatigueMix,
		dbo.GYRColourConfig(Distraction, 58, ISNULL(ReportConfigId, @lrprtcfgid)) AS DistractionColour, DistractionMix

FROM
	(SELECT *,
		
		Safety = dbo.ScoreByClassAndConfigPlus('S', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, TopGearOverspeed, CruiseOverspeed, OverspeedCount, OverspeedHighCount, StabilityControl, CollisionWarningLow, CollisionWarningMed, CollisionWarningHigh, LaneDepartureDisable, LaneDepartureLeftRight, SweetSpotTime, OverRevTime, TopGearTime, Fatigue, Distraction,SpeedGauge, ISNULL(ReportConfigId, @lrprtcfgid)),
		Efficiency = dbo.ScoreByClassAndConfigPlus('E', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, TopGearOverspeed, CruiseOverspeed, OverspeedCount, OverspeedHighCount, StabilityControl, CollisionWarningLow, CollisionWarningMed, CollisionWarningHigh, LaneDepartureDisable, LaneDepartureLeftRight, SweetSpotTime, OverRevTime, TopGearTime, Fatigue, Distraction,SpeedGauge, ISNULL(ReportConfigId, @lrprtcfgid)),

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

		SpeedGaugeComponent = dbo.ScoreComponentValueConfig(59, SpeedGauge, ISNULL(ReportConfigId, @lrprtcfgid)),

		CoastOutOfGearComponent = dbo.ScoreComponentValueConfig(11, CoastOutOfGear, ISNULL(ReportConfigId, @lrprtcfgid)),
		CoastInGearComponent = dbo.ScoreComponentValueConfig(5, CoastInGear, ISNULL(ReportConfigId, @lrprtcfgid)),
		HarshBrakingComponent = dbo.ScoreComponentValueConfig(12, HarshBraking, ISNULL(ReportConfigId, @lrprtcfgid)),
		CruiseOverspeedComponent = dbo.ScoreComponentValueConfig(43, CruiseOverspeed, ISNULL(ReportConfigId, @lrprtcfgid)),
		TopGearOverspeedComponent = dbo.ScoreComponentValueConfig(42, TopGearOverspeed, ISNULL(ReportConfigId, @lrprtcfgid)),
		OverspeedCountComponent = dbo.ScoreComponentValueConfig(46, OverspeedCount, ISNULL(ReportConfigId, @lrprtcfgid)),
		OverspeedHighCountComponent = dbo.ScoreComponentValueConfig(47, OverspeedHighCount, ISNULL(ReportConfigId, @lrprtcfgid)),
		StabilityControlComponent = dbo.ScoreComponentValueConfig(48, StabilityControl, ISNULL(ReportConfigId, @lrprtcfgid)),
		CollisionWarningLowComponent = dbo.ScoreComponentValueConfig(49, CollisionWarningLow, ISNULL(ReportConfigId, @lrprtcfgid)),
		CollisionWarningMedComponent = dbo.ScoreComponentValueConfig(50, CollisionWarningMed, ISNULL(ReportConfigId, @lrprtcfgid)),
		CollisionWarningHighComponent = dbo.ScoreComponentValueConfig(51, CollisionWarningHigh, ISNULL(ReportConfigId, @lrprtcfgid)),
		LaneDepartureDisableComponent = dbo.ScoreComponentValueConfig(52, LaneDepartureDisable, ISNULL(ReportConfigId, @lrprtcfgid)),
		LaneDepartureLeftRightComponent = dbo.ScoreComponentValueConfig(53, LaneDepartureLeftRight, ISNULL(ReportConfigId, @lrprtcfgid)),
		SweetSpotTimeComponent = dbo.ScoreComponentValueConfig(54, SweetSpotTime, ISNULL(ReportConfigId, @lrprtcfgid)),
		OverRevTimeComponent = dbo.ScoreComponentValueConfig(55, OverRevTime, ISNULL(ReportConfigId, @lrprtcfgid)),
		TopGearTimeComponent = dbo.ScoreComponentValueConfig(56, TopGearTime, ISNULL(ReportConfigId, @lrprtcfgid)),
		FatigueComponent = dbo.ScoreComponentValueConfig(57, Fatigue, ISNULL(ReportConfigId, @lrprtcfgid)),
		DistractionComponent = dbo.ScoreComponentValueConfig(58, Distraction, ISNULL(ReportConfigId, @lrprtcfgid))

	FROM
		(SELECT
			CASE WHEN (GROUPING(p.PeriodNum) = 1) THEN NULL
				ELSE ISNULL(p.PeriodNum, NULL)
			END AS PeriodNum,
			
			CASE WHEN (GROUPING(v.VehicleId) = 1) THEN NULL
				ELSE ISNULL(v.VehicleId, NULL)
			END AS VehicleId,

			CASE WHEN (GROUPING(d.DriverId) = 1) THEN NULL
				ELSE ISNULL(d.DriverId, NULL)
			END AS DriverId,

			-- Add summation of coaching status columns here
			SUM([0]) AS [0],
			SUM([1]) AS [1],
			SUM([2]) AS [2],
			SUM([3]) AS [3],
			SUM([4]) AS [4],
			SUM([97]) AS [97],
			SUM([98]) AS [98],
			SUM([99]) AS [99],

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
			ISNULL((SUM(TotalFuel) * 2639.1 * @co2mult) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)),0) AS Co2, --@co2mult: 1 for g/km, 1.6 for g/miles
			SUM(wServiceBrakeDistance) / dbo.ZeroYieldNull(SUM(ServiceBrakeTotal)) AS ServiceBrakeUsage,
			ISNULL(SUM(EngineBrakeDistance) / dbo.ZeroYieldNull(SUM(ServiceBrakeDistance + EngineBrakeDistance)),0) AS EngineServiceBrake,
			SUM(wEngineBrakeOverRPMDistance) / dbo.ZeroYieldNull(SUM(EngineBrakeOverRPMTotal)) AS OverRevWithoutFuel,
			ISNULL((SUM(wROPCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(ROPTotal) * @distmult * 1000))))),0) AS Rop,
			ISNULL((SUM(wROP2Count) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(ROP2Total) * @distmult * 1000))))),0) AS Rop2,
			ISNULL(SUM(wOverSpeedDistance) / dbo.ZeroYieldNull(SUM(OverSpeedTotal)),0) AS OverSpeed,
			ISNULL(SUM(wOverSpeedHighDistance) / dbo.ZeroYieldNull(SUM(OverSpeedHighTotal)),0) AS OverSpeedHigh,
			ISNULL(SUM(wOverSpeedDistance) / dbo.ZeroYieldNull(SUM(OverSpeedTotal)),0) AS OverSpeedDistance, 
			ISNULL(SUM(wOverSpeedDistance) / dbo.ZeroYieldNull(SUM(IVHOverSpeedTotal)),0) AS IVHOverSpeed,

		    ISNULL(SUM(wSpeedGauge),0) AS SpeedGauge,

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
			ISNULL(SUM(wCruiseOverSpeed) / dbo.ZeroYieldNull(SUM(CruiseOverSpeedTotal)), 0) AS CruiseOverspeed,
			ISNULL(SUM(wTopGearOverSpeed) / dbo.ZeroYieldNull(SUM(w.TopGearOverSpeedTotal)), 0) AS TopGearOverspeed,
			SUM(wFuelWastage) AS FuelWastage,

			ISNULL((SUM(wOverspeedCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(w.OverspeedCountTotal) * @distmult * 1000))))),0) AS OverspeedCount,
			ISNULL((SUM(wOverspeedHighCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(w.OverspeedHighCountTotal) * @distmult * 1000))))),0) AS OverspeedHighCount,
			ISNULL((SUM(wStabilityControl) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(w.StabilityControlTotal) * @distmult * 1000))))),0) AS StabilityControl,
			ISNULL((SUM(wCollisionWarningLow) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(w.CollisionWarningLowTotal) * @distmult * 1000))))),0) AS CollisionWarningLow,
			ISNULL((SUM(wCollisionWarningMed) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(w.CollisionWarningMedTotal) * @distmult * 1000))))),0) AS CollisionWarningMed,
			ISNULL((SUM(wCollisionWarningHigh) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(w.CollisionWarningHighTotal) * @distmult * 1000))))),0) AS CollisionWarningHigh,
			ISNULL((SUM(wLaneDepartureDisable) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(w.LaneDepartureDisableTotal) * @distmult * 1000))))),0) AS LaneDepartureDisable,
			ISNULL((SUM(wLaneDepartureLeftRight) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(w.LaneDepartureLeftRightTotal) * @distmult * 1000))))),0) AS LaneDepartureLeftRight,
			CAST(SUM(wSweetSpotTime) AS float) / dbo.ZeroYieldNull(SUM(w.SweetSpotTimeTotal)) AS SweetSpotTime,
			CAST(SUM(wOverRevTime) AS float) / dbo.ZeroYieldNull(SUM(w.OverRevTimeTotal)) AS OverRevTime,
			CAST(SUM(wTopGearTime) AS float) / dbo.ZeroYieldNull(SUM(w.TopGearTimeTotal)) AS TopGearTime,
			ISNULL((SUM(w.wFatigue) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(w.FatigueTotal) * @distmult * 1000))))),0) AS Fatigue,
			ISNULL((SUM(w.wDistraction) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(w.DistractionTotal) * @distmult * 1000))))),0) AS Distraction,

			(CASE WHEN @fuelmult = 0.1 THEN
				(CASE WHEN SUM(wTotalFuel)=0 THEN NULL ELSE SUM(wTotalFuel * ISNULL(FuelMultiplier,1.0))*100 END)/SUM(FuelEconTotal) 
			ELSE
				(SUM(FuelEconTotal) * 1000) / (CASE WHEN SUM(wTotalFuel)=0 THEN NULL ELSE SUM(wTotalFuel * ISNULL(FuelMultiplier,1.0)) END) * @fuelmult END) AS FuelEcon
				
		FROM dbo.Reporting r
			INNER JOIN @weightedData w ON r.Date = w.Date AND r.VehicleIntId = w.VehicleIntId AND r.DriverIntId = w.DriverIntId
			INNER JOIN dbo.Vehicle v ON r.VehicleIntId = v.VehicleIntId
			INNER JOIN dbo.Driver d ON r.DriverIntId = d.DriverIntId
			INNER JOIN @period_dates p ON r.Date BETWEEN p.StartDate AND p.EndDate
			--LEFT JOIN dbo.ReportingABC abc ON r.VehicleIntId = abc.VehicleIntId AND r.DriverIntId = abc.DriverIntId AND r.Date = abc.Date --AND r.RouteID = abc.RouteId
			--LEFT JOIN dbo.ReportingOverspeed ro ON r.VehicleIntId = ro.VehicleIntId AND r.DriverIntId = ro.DriverIntId AND r.Date = ro.Date --AND r.RouteID = ro.RouteId
			--LEFT JOIN dbo.CAM_Incident ci ON r.VehicleIntId = ci.VehicleIntId AND r.DriverIntId = ci.DriverIntId AND FLOOR(CAST(ci.EventDateTime AS FLOAT)) = FLOOR(CAST(r.Date AS FLOAT))
			LEFT JOIN (SELECT	VehicleIntId, DriverIntId, CAST(FLOOR(CAST(EventDateTime AS FLOAT)) AS DATETIME) AS Date, SUM([0]) AS [0], SUM([1]) AS [1], SUM([2]) AS [2], SUM([3]) AS [3], SUM([4]) AS [4], SUM([97]) AS [97], SUM([98]) AS [98], SUM([99]) AS [99]
						FROM dbo.CAM_Incident
						PIVOT (COUNT(IncidentId) FOR CoachingStatusId IN ([0], [1], [2], [3], [4], [97], [98], [99])) AS StatusCount
						WHERE DriverIntId IN (SELECT dbo.GetDriverIntFromId(value) FROM dbo.Split(@dids, ','))
						  AND EventDateTime BETWEEN @sdate AND @edate
						  AND CreationCodeId IN (7, 36, 37, 38, 336, 337, 338, 436, 437, 438, 455, 456)
						GROUP BY VehicleIntId, DriverIntId, FLOOR(CAST(EventDateTime AS FLOAT))) cs ON cs.VehicleIntId = v.VehicleIntId AND cs.DriverIntId = d.DriverIntId AND cs.Date = r.Date

		WHERE r.Date BETWEEN @lsdate AND @ledate 
		  AND (d.DriverId IN (SELECT Value FROM dbo.Split(@ldids, ',')) OR @ldids IS NULL)
          AND r.DrivingDistance > 0
		GROUP BY p.PeriodNum, d.DriverId, v.VehicleId WITH CUBE
		HAVING SUM(DrivingDistance) > 10 ) o

	LEFT JOIN @VehicleConfig vc ON o.VehicleId = vc.Vid
	) Result

LEFT JOIN dbo.Vehicle v ON Result.VehicleId = v.VehicleId
LEFT JOIN dbo.Driver d ON Result.DriverId = d.DriverId
LEFT JOIN @period_dates p ON Result.PeriodNum = p.PeriodNum
INNER JOIN @configCount c ON ISNULL(v.VehicleIntId,0) = c.VehicleIntid AND ISNULL(d.DriverIntId,0) = c.DriverIntId

ORDER BY Registration, Surname, PeriodNum	


GO
