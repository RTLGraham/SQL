SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_Report_Trend_DriverPlus]
(
	@dids varchar(max), 
	@gids varchar(max), 
	@sdate datetime,
	@edate datetime,
	@routeid INT,
	@vehicletypeid INT,	
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER,
	@drilldown TINYINT,
	@calendar TINYINT,
	@groupBy INT
)
AS

--DECLARE @dids varchar(max),
--		@gids VARCHAR(max),
--		@routeid INT,
--		@vehicletypeid INT,	
--		@sdate datetime,
--		@edate datetime,
--		@uid UNIQUEIDENTIFIER,
--		@rprtcfgid UNIQUEIDENTIFIER,
--		@drilldown TINYINT,
--		@calendar TINYINT,
--		@groupBy INT
		

--SET @dids = N'64844794-79A0-454B-999B-D2B30C33992A'
--SET @gids = NULL 
--SET @vehicletypeid = NULL
--SET @routeid = NULL
--	SET @sdate = '2020-03-23 00:00'
--	SET @edate = '2020-03-23 23:59'
--SET @uid = N'6E39B5F2-1CD4-4069-A562-0311E2584DDF'
--SET @rprtcfgid = N'1453f8c7-e0b5-4195-a10f-14e034f421b9'
--SET @drilldown = 1
--SET @calendar = 1
--SET @groupBy = 3



DECLARE @ldids varchar(max),
		@lgids VARCHAR(max),
		@lrouteid INT,
		@lvehicletypeid INT,	
		@lsdate datetime,
		@ledate datetime,
		@luid UNIQUEIDENTIFIER,
		@lrprtcfgid UNIQUEIDENTIFIER,
		@ldrilldown TINYINT,
		@lcalendar TINYINT,
		@lgroupBy INT
		
SET @ldids = @dids
SET @lgids = @gids
SET @lrouteid = @routeid
SET @lvehicletypeid = @vehicletypeid
SET @lsdate = @sdate
SET @ledate = @edate
SET @luid = @uid
SET @lrprtcfgid = @rprtcfgid
SET @ldrilldown = @drilldown
SET @lcalendar = @calendar
SET @lgroupBy = @groupBy

DECLARE @diststr varchar(20),
		@distmult float,
		@fuelstr varchar(20),
		@fuelmult float,
		@fuelcost FLOAT,
		@currency NVARCHAR(10),
		@co2str varchar(20),
		@co2mult FLOAT,
		@liquidstr VARCHAR(20),
		@liquidmult FLOAT

SELECT @diststr = [dbo].UserPref(@luid, 203)
SELECT @distmult = [dbo].UserPref(@luid, 202)
SELECT @fuelstr = [dbo].UserPref(@luid, 205)
SELECT @fuelmult = [dbo].UserPref(@luid, 204)
SELECT @co2str = [dbo].UserPref(@luid, 211)
SELECT @co2mult = [dbo].UserPref(@luid, 210)
SELECT @liquidstr = [dbo].UserPref(@luid, 201)
SELECT @liquidmult = [dbo].UserPref(@luid, 200)
SELECT @currency = [dbo].UserPref(@luid, 381)

SELECT @fuelcost = CAST(cp.Value AS FLOAT)
FROM dbo.[User] u
INNER JOIN dbo.CustomerPreference cp ON cp.CustomerID = u.CustomerID
WHERE u.UserID = @luid
  AND cp.NameID = 3007

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

-- Convert dates to UTC
--SET @lsdate = [dbo].TZ_ToUTC(@lsdate,default,@luid)
--SET @ledate = [dbo].TZ_ToUTC(@ledate,default,@luid)

-- Create temporary table for vehicle configs
DECLARE @VehicleConfig TABLE
(
	Vid UNIQUEIDENTIFIER,
	ReportConfigId UNIQUEIDENTIFIER
)

-- The table will be populated by a specific vehicle config if one exists, other wise the default config will be populated instead
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
	wInSweetSpotDistance FLOAT, InSweetSpotTotal FLOAT, --InSweetSpotUsed INT,
	wFueledOverRPMDistance FLOAT, FueledOverRPMTotal FLOAT, --FueledOverRPMUsed INT,
	wTopGearDistance FLOAT, TopGearTotal FLOAT, --TopGearUsed INT,
	wCruiseControlDistance FLOAT, CruiseTotal FLOAT, --CruiseUsed INT,
	wCruiseInTopGearsDistance FLOAT, CruiseInTopGearsTotal FLOAT, --CruiseInTopGearsUsed INT,
	wCoastInGearDistance FLOAT, CoastInGearTotal FLOAT, --CoastInGearUsed INT,
	wIdleTime FLOAT, IdleTotal FLOAT, --IdleUsed INT,
	wServiceBrakeDistance FLOAT, ServiceBrakeTotal FLOAT, --ServiceBrakeUsed INT, 
	wEngineBrakeOverRPMDistance FLOAT, EngineBrakeOverRPMTotal FLOAT, --EngineBrakeOverRPMUsed INT,
	wROPCount FLOAT, ROPTotal FLOAT, --ROPUsed INT,
	wROP2Count FLOAT, ROP2Total FLOAT, --ROP2Used INT,
	wOverspeedDistance FLOAT, OverSpeedTotal FLOAT, --OverSpeedUsed INT,
	wOverSpeedHighDistance FLOAT, OverSpeedHighTotal FLOAT, --OverSpeedHighUsed INT,
	wIVHOverSpeedDistance FLOAT, IVHOverSpeedTotal FLOAT, --IVHOverSpeedUsed INT,

		wSpeedGauge FLOAT,

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
	wTopGearOverSpeed FLOAT, TopGearOverSpeedTotal FLOAT, --TopGearOverSpeedUsed TINYINT,
	wCruiseOverSpeed FLOAT, CruiseOverSpeedTotal FLOAT, --CruiseOverSpeedUsed TINYINT,
	wFuelWastage FLOAT,
	wOverspeedCount FLOAT, OverspeedCountTotal FLOAT, --OverspeedCountUsed INT,
	wOverspeedHighCount FLOAT, OverspeedHighCountTotal FLOAT, --OverspeedHighCountUsed TINYINT,
	wStabilityControl FLOAT, StabilityControlTotal FLOAT, --StabilityControlUsed TINYINT,
	wCollisionWarningLow FLOAT, CollisionWarningLowTotal FLOAT, --CollisionWarningLowUsed TINYINT,
	wCollisionWarningMed FLOAT, CollisionWarningMedTotal FLOAT, --CollisionWarningMedUsed TINYINT,
	wCollisionWarningHigh FLOAT, CollisionWarningHighTotal FLOAT, --CollisionWarningHighUsed TINYINT,
	wLaneDepartureDisable FLOAT, LaneDepartureDisableTotal FLOAT, --LaneDepartureDisableUsed TINYINT,
	wLaneDepartureLeftRight FLOAT, LaneDepartureLeftRightTotal FLOAT, --LaneDepartureLeftRightUsed TINYINT,
	wSweetSpotTime FLOAT, SweetSpotTimeTotal FLOAT, --SweetSpotTimeUsed TINYINT,
	wOverRevTime FLOAT, OverRevTimeTotal FLOAT, --OverRevTimeUsed TINYINT,
	wTopGearTime FLOAT, TopGearTimeTotal FLOAT, --TopGearTimeUsed TINYINT,
	wFatigue FLOAT, FatigueTotal FLOAT, --FatigueUsed TINYINT,
	wDistraction FLOAT, DistractionTotal FLOAT --DistractionUsed TINYINT
)

INSERT INTO @weightedData  (Date, VehicleIntId, DriverIntId, 
							wInSweetSpotDistance, InSweetSpotTotal, --InSweetSpotUsed,
							wFueledOverRPMDistance, FueledOverRPMTotal, --FueledOverRPMUsed,
							wTopGearDistance, TopGearTotal, --TopGearUsed,
							wCruiseControlDistance, CruiseTotal, --CruiseUsed,
							wCruiseInTopGearsDistance, CruiseInTopGearsTotal, --CruiseInTopGearsUsed,
							wCoastInGearDistance, CoastInGearTotal, --CoastInGearUsed,
							wIdleTime, IdleTotal, --IdleUsed,
							wServiceBrakeDistance, ServiceBrakeTotal, --ServiceBrakeUsed,
							wEngineBrakeOverRPMDistance, EngineBrakeOverRPMTotal, --EngineBrakeOverRPMUsed,
							wROPCount, ROPTotal, --ROPUsed,
							wROP2Count, ROP2Total, --ROP2Used,
							wOverspeedDistance, OverSpeedTotal, --OverSpeedUsed,
							wOverSpeedHighDistance, OverSpeedHighTotal, --OverSpeedHighUsed,
							wIVHOverSpeedDistance, IVHOverSpeedTotal, --IVHOverSpeedUsed,

							wSpeedGauge ,

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
							wTopGearOverSpeed, TopGearOverSpeedTotal, --TopGearOverSpeedUsed,
							wCruiseOverSpeed, CruiseOverSpeedTotal, --CruiseOverSpeedUsed,
							wFuelWastage,
							wOverspeedCount, OverspeedCountTotal, 
							wOverspeedHighCount, OverspeedHighCountTotal,
							wStabilityControl, StabilityControlTotal, 
							wCollisionWarningLow, CollisionWarningLowTotal, 
							wCollisionWarningMed, CollisionWarningMedTotal, 
							wCollisionWarningHigh, CollisionWarningHighTotal,
							wLaneDepartureDisable, LaneDepartureDisableTotal, 
							wLaneDepartureLeftRight, LaneDepartureLeftRightTotal,
							wSweetSpotTime, SweetSpotTimeTotal, 
							wOverRevTime, OverRevTimeTotal,
							wTopGearTime, TopGearTimeTotal,
							wFatigue, FatigueTotal,
							wDistraction, DistractionTotal)
SELECT	Date, VehicleIntId, DriverIntId, 
		SUM(wInSweetSpotDistance), SUM(InSweetSpotTotal), 
		SUM(wFueledOverRPMDistance), SUM(FueledOverRPMTotal), 
		SUM(wTopGearDistance), SUM(TopGearTotal), 
		SUM(wCruiseControlDistance), SUM(CruiseTotal), 
		SUM(wCruiseInTopGearsDistance), SUM(CruiseInTopGearsTotal), 
		SUM(wCoastInGearDistance), SUM(CoastInGearTotal),
		SUM(wIdleTime), SUM(IdleTotal), 
		SUM(wServiceBrakeDistance), SUM(ServiceBrakeTotal), 
		SUM(wEngineBrakeOverRPMDistance), SUM(EngineBrakeOverRPMTotal), 
		SUM(wROPCount), SUM(ROPTotal), 
		SUM(wROP2Count), SUM(ROP2Total), 
		SUM(wOverspeedDistance), SUM(OverSpeedTotal), 
		SUM(wOverSpeedHighDistance), SUM(OverSpeedHighTotal), 
		SUM(wIVHOverSpeedDistance), SUM(IVHOverSpeedTotal), 

		SUM(wSpeedGauge) ,
		

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
		SUM(wTopGearOverSpeed), SUM(TopGearOverSpeedTotal), 
		SUM(wCruiseOverSpeed), SUM(CruiseOverSpeedTotal), 
		SUM(wFuelWastage),
		SUM(wOverspeedCount), SUM(OverspeedCountTotal),
		SUM(wOverspeedHighCount), SUM(OverspeedHighCountTotal),
		SUM(wStabilityControl), SUM(StabilityControlTotal), 
		SUM(wCollisionWarningLow), SUM(CollisionWarningLowTotal),
		SUM(wCollisionWarningMed), SUM(CollisionWarningMedTotal),
		SUM(wCollisionWarningHigh), SUM(CollisionWarningHighTotal),
		SUM(wLaneDepartureDisable), SUM(LaneDepartureDisableTotal),
		SUM(wLaneDepartureLeftRight), SUM(LaneDepartureLeftRightTotal),
		SUM(wSweetSpotTime), SUM(SweetSpotTimeTotal),
		SUM(wOverRevTime), SUM(OverRevTimeTotal),
		SUM(wTopGearTime), SUM(TopGearTimeTotal),
		SUM(wFatigue), SUM(FatigueTotal),
		SUM(wDistraction), SUM(DistractionTotal)
FROM	
	(
	SELECT	r.Date, r.VehicleIntId, r.DriverIntId,
			-- For each component calculate the weighted value and the weighted total (i.e. where the indicator is being used (IS NOT NULL))	
			CASE WHEN ic.IndicatorId = 1 THEN r.InSweetSpotDistance END AS wInSweetSpotDistance,
			CASE WHEN ic.IndicatorId = 1 THEN r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0) END AS InSweetSpotTotal,
			CASE WHEN ic.IndicatorId = 1 THEN 1 END AS InSweetSpotUsed,
		
			CASE WHEN ic.IndicatorId = 2 THEN r.FueledOverRPMDistance END AS wFueledOverRPMDistance,
			CASE WHEN ic.IndicatorId = 2 THEN r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0) END AS FueledOverRPMTotal,
			CASE WHEN ic.IndicatorId = 2 THEN 1 END AS FueledOverRPMUsed,
		
			CASE WHEN ic.IndicatorId = 3 THEN r.TopGearDistance END AS wTopGearDistance,
			CASE WHEN ic.IndicatorId = 3 THEN r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0) END AS TopGearTotal,
			CASE WHEN ic.IndicatorId = 3 THEN 1 END AS TopGearUsed,
		
			CASE WHEN ic.IndicatorId = 4 THEN r.CruiseControlDistance END AS wCruiseControlDistance,
			CASE WHEN ic.IndicatorId = 4 THEN r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0) END AS CruiseTotal,
			CASE WHEN ic.IndicatorId = 4 THEN 1 END AS CruiseUsed,
		
			CASE WHEN ic.IndicatorId = 31 THEN r.CruiseControlDistance END AS wCruiseInTopGearsDistance,
			CASE WHEN ic.IndicatorId = 31 THEN r.TopGearDistance + r.GearDownDistance END AS CruiseInTopGearsTotal,
			CASE WHEN ic.IndicatorId = 31 THEN 1 END AS CruiseInTopGearsUsed,
		
			CASE WHEN ic.IndicatorId = 5 THEN r.CoastInGearDistance END AS wCoastInGearDistance,
			CASE WHEN ic.IndicatorId = 5 THEN r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0) END AS CoastInGearTotal,
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
			CASE WHEN ic.IndicatorId = 9 THEN r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0) END AS ROPTotal,
			CASE WHEN ic.IndicatorId = 9 THEN 1 END AS ROPUsed,

			CASE WHEN ic.IndicatorId = 41 THEN r.ROP2Count END AS wROP2Count,
			CASE WHEN ic.IndicatorId = 41 THEN r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0) END AS ROP2Total,
			CASE WHEN ic.IndicatorId = 41 THEN 1 END AS ROP2Used,
					
			CASE WHEN ic.IndicatorId = 10 THEN ro.OverspeedDistance END AS wOverspeedDistance,
			CASE WHEN ic.IndicatorId = 10 THEN r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0) END AS OverSpeedTotal,
			CASE WHEN ic.IndicatorId = 10 THEN 1 END AS OverSpeedUsed,

			CASE WHEN ic.IndicatorId = 32 THEN ro.OverSpeedHighDistance END AS wOverSpeedHighDistance,
			CASE WHEN ic.IndicatorId = 32 THEN r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0) END AS OverSpeedHighTotal,
			CASE WHEN ic.IndicatorId = 32 THEN 1 END AS OverSpeedHighUsed,
		
			CASE WHEN ic.IndicatorId = 30 THEN r.OverSpeedDistance END AS wIVHOverSpeedDistance,
			CASE WHEN ic.IndicatorId = 30 THEN r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0) END AS IVHOverSpeedTotal,
			CASE WHEN ic.IndicatorId = 30 THEN 1 END AS IVHOverSpeedUsed,
		
			CASE WHEN ic.IndicatorId = 11 THEN r.CoastOutOfGearDistance END AS wCoastOutOfGearDistance,
			CASE WHEN ic.IndicatorId = 11 THEN r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0) END AS CoastOutOfGearTotal,
			CASE WHEN ic.IndicatorId = 11 THEN 1 END AS CoastOutOfGearUsed,
		
			CASE WHEN ic.IndicatorId = 12 THEN r.PanicStopCount END AS wPanicStopCount,
			CASE WHEN ic.IndicatorId = 12 THEN r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0) END AS PanicStopTotal,
			CASE WHEN ic.IndicatorId = 12 THEN 1 END AS PanicStopUsed,
		
			CASE WHEN ic.IndicatorId = 22 THEN abc.Acceleration END AS wAcceleration,
			CASE WHEN ic.IndicatorId = 22 THEN r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0) END AS AccelerationTotal,
			CASE WHEN ic.IndicatorId = 22 THEN 1 END AS AccelerationUsed,
		
			CASE WHEN ic.IndicatorId = 23 THEN abc.Braking END AS wBraking,
			CASE WHEN ic.IndicatorId = 23 THEN r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0) END AS BrakingTotal,
			CASE WHEN ic.IndicatorId = 23 THEN 1 END AS BrakingUsed,
		
			CASE WHEN ic.IndicatorId = 24 THEN abc.Cornering END AS wCornering,
			CASE WHEN ic.IndicatorId = 24 THEN r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0) END AS CorneringTotal,
			CASE WHEN ic.IndicatorId = 24 THEN 1 END AS CorneringUsed,
		
			CASE WHEN ic.IndicatorId = 33 THEN abc.AccelerationLow END AS wAccelerationLow,
			CASE WHEN ic.IndicatorId = 33 THEN r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0) END AS AccelerationLowTotal,
			CASE WHEN ic.IndicatorId = 33 THEN 1 END AS AccelerationLowUsed,
		
			CASE WHEN ic.IndicatorId = 34 THEN abc.BrakingLow END AS wBrakingLow,
			CASE WHEN ic.IndicatorId = 34 THEN r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0) END AS BrakingLowTotal,
			CASE WHEN ic.IndicatorId = 34 THEN 1 END AS BrakingLowUsed,
		
			CASE WHEN ic.IndicatorId = 35 THEN abc.CorneringLow END AS wCorneringLow,
			CASE WHEN ic.IndicatorId = 35 THEN r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0) END AS CorneringLowTotal,
			CASE WHEN ic.IndicatorId = 35 THEN 1 END AS CorneringLowUsed, 		
		
			CASE WHEN ic.IndicatorId = 36 THEN abc.AccelerationHigh END AS wAccelerationHigh,
			CASE WHEN ic.IndicatorId = 36 THEN r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0) END AS AccelerationHighTotal,
			CASE WHEN ic.IndicatorId = 36 THEN 1 END AS AccelerationHighUsed,
		
			CASE WHEN ic.IndicatorId = 37 THEN abc.BrakingHigh END AS wBrakingHigh,
			CASE WHEN ic.IndicatorId = 37 THEN r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0) END AS BrakingHighTotal,
			CASE WHEN ic.IndicatorId = 37 THEN 1 END AS BrakingHighUsed,
		
			CASE WHEN ic.IndicatorId = 38 THEN abc.CorneringHigh END AS wCorneringHigh,
			CASE WHEN ic.IndicatorId = 38 THEN r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0) END AS CorneringHighTotal,
			CASE WHEN ic.IndicatorId = 38 THEN 1 END AS CorneringHighUsed,	
	
			CASE WHEN ic.IndicatorId = 39 THEN abc.AccelerationLow + abc.BrakingLow + abc.CorneringLow END AS wManoeuvresLow,
			CASE WHEN ic.IndicatorId = 39 THEN r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0) END AS ManoeuvresLowTotal,
			CASE WHEN ic.IndicatorId = 39 THEN 1 END AS ManoeuvresLowUsed,	

			CASE WHEN ic.IndicatorId = 40 THEN abc.Acceleration + abc.Braking + abc.Cornering END AS wManoeuvresMed,
			CASE WHEN ic.IndicatorId = 40 THEN r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0) END AS ManoeuvresMedTotal,
			CASE WHEN ic.IndicatorId = 40 THEN 1 END AS ManoeuvresMedUsed,	
	
			CASE WHEN ic.IndicatorId = 25 THEN 1 END AS CruiseTopGearRatioUsed,
		
			CASE WHEN ic.IndicatorId = 28 THEN r.ORCount END AS wORCount,
			CASE WHEN ic.IndicatorId = 28 THEN r.DrivingDistance + ISNULL(r.PTOMovingDistance, 0) END AS ORCountTotal,
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


			--CASE WHEN ic.IndicatorId = 59 THEN ISNULL(ro.Observations/CASE WHEN ro.Incidents = 0 THEN NULL ELSE ro.Incidents END ,0) END AS wSpeedGauge,
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



DECLARE @data TABLE 
(
		PeriodNum TINYINT,
		WeekStartDate DATETIME,
		WeekEndDate DATETIME,
		PeriodType VARCHAR(MAX),
		VehicleId UNIQUEIDENTIFIER,	
		Registration VARCHAR(MAX),
		
		DriverId UNIQUEIDENTIFIER,
 		DisplayName NVARCHAR(MAX),
 		FirstName NVARCHAR(MAX),
 		Surname NVARCHAR(MAX),
 		MiddleNames NVARCHAR(MAX),
 		Number NVARCHAR(MAX),
 		NumberAlternate NVARCHAR(MAX),
 		NumberAlternate2 NVARCHAR(MAX),

		ReportConfigId UNIQUEIDENTIFIER,
 		
 		GroupId UNIQUEIDENTIFIER,
 		GroupName NVARCHAR(MAX),
 		
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

		SpeedGauge FLOAT,

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
		SweetSpotTime FLOAT,
		OverRevTime FLOAT,
		TopGearTime FLOAT,
		Fatigue FLOAT,
		Distraction FLOAT,
		
		Efficiency FLOAT, 
		Safety FLOAT,
		
		TotalTime FLOAT,
		TotalDrivingDistance FLOAT,
		ServiceBrakeUsage FLOAT,	
		EngineBrakeUsage FLOAT,
		OverRevCount FLOAT,

		-- Date and Unit columns 
		sdate DATETIME,
		edate DATETIME,
		CreationDateTime DATETIME,
		ClosureDateTime DATETIME,

		DistanceUnit NVARCHAR(MAX),
		FuelUnit NVARCHAR(MAX),
		Co2Unit NVARCHAR(MAX),
		FuelMult FLOAT,
		LiquidUnit NVARCHAR(MAX),
		Currency NVARCHAR(10)
)

-- Now perform main report processing

INSERT INTO @data
        ( PeriodNum ,
          WeekStartDate ,
          WeekEndDate ,
          PeriodType ,
          VehicleId ,
          Registration ,
          DriverId ,
          DisplayName ,
          FirstName ,
          Surname ,
          MiddleNames ,
          Number ,
          NumberAlternate ,
          NumberAlternate2 ,
		  ReportConfigId ,
          GroupId ,
          GroupName ,
		  SweetSpot , 
		  OverRevWithFuel ,
		  TopGear ,
		  Cruise ,
		  CruiseInTopGears ,
		  CoastInGear ,
		  Idle ,
		  EngineServiceBrake ,
		  OverRevWithoutFuel ,
		  Rop ,
		  Rop2 ,
		  OverSpeed ,
		  OverSpeedHigh ,
		  OverSpeedDistance ,
		  IVHOverSpeed ,

		 SpeedGauge,

		  CoastOutOfGear ,
		  HarshBraking ,
		  FuelEcon ,
		  Pto ,
		  Co2 ,
		  CruiseTopGearRatio ,
		  Acceleration ,
	      Braking ,
		  Cornering ,
		  AccelerationLow ,
		  BrakingLow ,
		  CorneringLow ,
		  AccelerationHigh ,
		  BrakingHigh ,
		  CorneringHigh ,
		  ManoeuvresLow ,
		  ManoeuvresMed ,
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
		  SweetSpotTime,
		  OverRevTime,
		  TopGearTime,
		  Fatigue,
		  Distraction,
          Efficiency ,
          Safety ,
          TotalTime ,
          TotalDrivingDistance ,
          ServiceBrakeUsage ,
          EngineBrakeUsage ,
          OverRevCount ,
          sdate ,
          edate ,
          CreationDateTime ,
          ClosureDateTime ,
          DistanceUnit ,
          FuelUnit ,
          Co2Unit ,
          FuelMult ,
          LiquidUnit ,
		  Currency
        )
SELECT
		-- Vehicle, Driver and Group Identification columns
		p.PeriodNum,
		--p.StartDate,
		--p.EndDate,
		[dbo].TZ_GetTime(p.StartDate,DEFAULT,@luid),
		[dbo].TZ_GetTime(p.EndDate,DEFAULT,@luid),
		p.PeriodType,
		v.VehicleId,	
		v.Registration,
		
		d.DriverId,
 		dbo.FormatDriverNameByUser(d.DriverId, @luid),
 		d.FirstName,
 		d.Surname,
 		d.MiddleNames,
 		d.Number,
 		d.NumberAlternate,
 		d.NumberAlternate2,

		ISNULL(ReportConfigId, @lrprtcfgid) AS ReportConfigId,
 		
 		NULL,
 		NULL,
 		
 		-- Data columns with corresponding colours below 
		SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear,
		Idle, EngineServiceBrake, OverRevWithoutFuel, 
		Rop, Rop2, OverSpeed, OverSpeedHigh, OverSpeedDistance, IVHOverSpeed,
				 SpeedGauge,
		 CoastOutOfGear, HarshBraking, FuelEcon,
		Pto, Co2, 
		CruiseTopGearRatio,
		Acceleration, Braking, Cornering,
		AccelerationLow, BrakingLow, CorneringLow,
		AccelerationHigh, BrakingHigh, CorneringHigh,
		ManoeuvresLow,
		ManoeuvresMed,
		CruiseOverspeed,
		TopGearOverspeed,
		FuelWastage * @fuelcost AS FuelWastageCost,
		OverspeedCount,
		OverspeedHighCount,
		StabilityControl,
		CollisionWarningLow,
		CollisionWarningMed,
		CollisionWarningHigh,
		LaneDepartureDisable,
		LaneDepartureLeftRight,
		SweetSpotTime,
		OverRevTime,
		TopGearTime,
		Fatigue,
		Distraction,			
 --OverSpeedDistance
		
		-- Score columns
		Efficiency, 
		Safety,
		
		-- Additional columns with no corresponding colour	
		TotalTime,
		TotalDrivingDistance,
		ServiceBrakeUsage,
		NULL AS EngineBrakeUsage,	
		OverRevCount,

		-- Date and Unit columns 
		@lsdate,
		@ledate,
		@lsdate,
		@ledate,
		--[dbo].TZ_GetTime(@lsdate,default,@luid),
		--[dbo].TZ_GetTime(@ledate,default,@luid),

		@diststr,
		@fuelstr,
		@co2str,
		@fuelmult,
		@liquidstr,
		@currency AS Currency
			
FROM
	(SELECT *,
		
		0 AS Safety,
		0 AS Efficiency
--Safety = dbo.ScoreByClassConfig('S', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, ISNULL(ReportConfigId, @lrprtcfgid)),
--Efficiency = dbo.ScoreByClassConfig('E', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, ISNULL(ReportConfigId, @lrprtcfgid))


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
			ISNULL(SUM(wTopGearOverSpeed) / dbo.ZeroYieldNull(SUM(TopGearOverSpeedTotal)), 0) AS TopGearOverspeed,
			SUM(wFuelWastage) AS FuelWastage,

			ISNULL((SUM(wOverspeedCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(OverspeedCountTotal) * @distmult * 1000))))),0) AS OverspeedCount,
			ISNULL((SUM(wOverspeedHighCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(OverspeedHighCountTotal) * @distmult * 1000))))),0) AS OverspeedHighCount,
			ISNULL((SUM(wStabilityControl) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(StabilityControlTotal) * @distmult * 1000))))),0) AS StabilityControl,
			ISNULL((SUM(wCollisionWarningLow) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(CollisionWarningLowTotal) * @distmult * 1000))))),0) AS CollisionWarningLow,
			ISNULL((SUM(wCollisionWarningMed) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(CollisionWarningMedTotal) * @distmult * 1000))))),0) AS CollisionWarningMed,
			ISNULL((SUM(wCollisionWarningHigh) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(CollisionWarningHighTotal) * @distmult * 1000))))),0) AS CollisionWarningHigh,
			ISNULL((SUM(wLaneDepartureDisable) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(LaneDepartureDisableTotal) * @distmult * 1000))))),0) AS LaneDepartureDisable,
			ISNULL((SUM(wLaneDepartureLeftRight) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(LaneDepartureLeftRightTotal) * @distmult * 1000))))),0) AS LaneDepartureLeftRight,
			CAST(SUM(wSweetSpotTime) AS float) / dbo.ZeroYieldNull(SUM(SweetSpotTimeTotal)) AS SweetSpotTime,
			CAST(SUM(wOverRevTime) AS float) / dbo.ZeroYieldNull(SUM(OverRevTimeTotal)) AS OverRevTime,
			CAST(SUM(wTopGearTime) AS float) / dbo.ZeroYieldNull(SUM(TopGearTimeTotal)) AS TopGearTime,
			ISNULL((SUM(wFatigue) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(FatigueTotal) * @distmult * 1000))))),0) AS Fatigue,
			ISNULL((SUM(wDistraction) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DistractionTotal) * @distmult * 1000))))),0) AS Distraction,

			(CASE WHEN @fuelmult = 0.1 THEN
				(CASE WHEN SUM(wTotalFuel)=0 THEN NULL ELSE SUM(wTotalFuel * ISNULL(FuelMultiplier,1.0))*100 END)/SUM(FuelEconTotal) 
			ELSE
				(SUM(FuelEconTotal) * 1000) / (CASE WHEN SUM(wTotalFuel)=0 THEN NULL ELSE SUM(wTotalFuel * ISNULL(FuelMultiplier,1.0)) END) * @fuelmult END) AS FuelEcon,
		
			SUM(DrivingDistance * 1000 * @distmult) AS TotalDrivingDistance,
			SUM(TotalTime) AS TotalTime				
		FROM dbo.Reporting r
			INNER JOIN @weightedData w ON r.Date = w.Date AND r.VehicleIntId = w.VehicleIntId AND r.DriverIntId = w.DriverIntId
			INNER JOIN dbo.Driver d ON r.DriverIntId = d.DriverIntId
			INNER JOIN @period_dates p ON r.Date BETWEEN p.StartDate AND p.EndDate
			INNER JOIN dbo.Vehicle v ON r.VehicleIntId = v.VehicleIntId
			INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
			INNER JOIN dbo.[User] u ON cv.CustomerId = u.CustomerID
			--LEFT JOIN dbo.ReportingABC abc ON r.VehicleIntId = abc.VehicleIntId AND r.DriverIntId = abc.DriverIntId AND r.Date = abc.Date --AND r.RouteID = abc.RouteId
			--LEFT JOIN dbo.ReportingOverspeed ro ON r.VehicleIntId = ro.VehicleIntId AND r.DriverIntId = ro.DriverIntId AND r.Date = ro.Date --AND r.RouteID = ro.RouteId

		WHERE r.Date BETWEEN @lsdate AND @ledate
		  AND (d.DriverId IN (SELECT Value FROM dbo.Split(@ldids, ',')) OR @ldids IS NULL)
		  AND v.Archived = 0
		  AND cv.Archived = 0	
		  AND u.UserID = @luid
		  AND (v.VehicleTypeID = @lvehicletypeid OR @lvehicletypeid IS NULL)
		  AND (r.RouteID = @lrouteid OR @lrouteid IS NULL)
		  AND r.DrivingDistance > 0

		GROUP BY p.PeriodNum, v.VehicleId, d.DriverId WITH CUBE
		HAVING SUM(DrivingDistance) > 10 ) o

	LEFT JOIN @VehicleConfig vc ON o.VehicleId = vc.Vid

	) Result

LEFT JOIN dbo.Driver d ON Result.DriverId = d.DriverId
LEFT JOIN dbo.Vehicle v ON Result.VehicleId = v.VehicleId
LEFT JOIN @period_dates p ON Result.PeriodNum = p.PeriodNum

 --Calculate Scores
UPDATE @data
SET 	Safety = dbo.ScoreByClassAndConfigPlus('S', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, TopGearOverspeed, CruiseOverspeed, OverspeedCount, OverspeedHighCount, StabilityControl, CollisionWarningLow, CollisionWarningMed, CollisionWarningHigh, LaneDepartureDisable, LaneDepartureLeftRight, SweetSpotTime, OverRevTime, TopGearTime, Fatigue, Distraction,SpeedGauge, @lrprtcfgid),
		Efficiency = dbo.ScoreByClassAndConfigPlus('E', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, TopGearOverspeed, CruiseOverspeed, OverspeedCount, OverspeedHighCount, StabilityControl, CollisionWarningLow, CollisionWarningMed, CollisionWarningHigh, LaneDepartureDisable, LaneDepartureLeftRight, SweetSpotTime, OverRevTime, TopGearTime, Fatigue, Distraction,SpeedGauge, @lrprtcfgid)

 --Calculate Driver Scores based on weighted average of scores from vehicles driven by driver
UPDATE @data
SET Efficiency = WeightedEfficiency / d.TotalDrivingDistance, 
	Safety = WeightedSafety / d.TotalDrivingDistance
FROM @data d
INNER JOIN 
(SELECT d.DriverId, d.PeriodNum, SUM(d.Efficiency * d.TotalDrivingDistance) AS WeightedEfficiency, SUM(d.Safety * d.TotalDrivingDistance) AS WeightedSafety
FROM @data d
WHERE d.DriverId IS NOT NULL AND d.VehicleId IS NOT NULL AND d.PeriodNum IS NOT NULL	
GROUP BY d.DriverId, d.PeriodNum) w ON w.DriverId = d.DriverId AND w.PeriodNum = d.PeriodNum 
WHERE d.DriverId IS NOT NULL AND d.PeriodNum IS NOT NULL AND d.VehicleId IS NULL

SELECT *
FROM @data
WHERE DriverId IS NOT NULL AND PeriodNum IS NOT NULL AND VehicleId IS NULL AND GroupId IS NULL


GO
