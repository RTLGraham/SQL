SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportCoaching_temporary]
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

--SET	@dids = N'AAC52DEC-CEE9-44ED-BB95-2EFF0CC83A30,EDBB2098-0BFA-49E5-B5F6-C6334B740E08'
--SET	@sdate = '2016-09-01 00:00'
--SET	@edate = '2016-10-10 23:59'
--SET	@uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
--SET	@rprtcfgid = N'56CE687D-9F1B-4FE7-92AD-D12089EAA608'
--SET @drilldown = 1
--SET @calendar = 0
--SET @groupBy = 2

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
	wFuelWastage FLOAT
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
							wFuelWastage)
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
		SUM(wFuelWastage)
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

			CASE WHEN ic.IndicatorId = 44 THEN ISNULL(r.FuelWastage,0) END AS wFuelWastage

	FROM dbo.Reporting r		
		INNER JOIN dbo.Vehicle v ON r.VehicleIntId = v.VehicleIntId
		INNER JOIN @VehicleConfig vc ON v.VehicleId = vc.Vid
		INNER JOIN dbo.IndicatorConfig ic ON vc.ReportConfigId = ic.ReportConfigurationId

		INNER JOIN dbo.Driver d ON r.DriverIntId = d.DriverIntId
		LEFT JOIN dbo.ReportingABC abc ON r.VehicleIntId = abc.VehicleIntId AND r.DriverIntId = abc.DriverIntId AND r.Date = abc.Date --AND r.RouteID = abc.RouteId
		LEFT JOIN dbo.ReportingOverspeed ro ON r.VehicleIntId = ro.VehicleIntId AND r.DriverIntId = ro.DriverIntId AND r.Date = ro.Date --AND r.RouteID = ro.RouteId
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
	TopGearOverspeedMix SMALLINT
)

INSERT INTO @ConfigCount (VehicleIntId, DriverIntId, SweetSpotMix, FueledOverRPMMix, TopGearMix, CruiseMix, CruiseInTopGearsMix, CoastInGearMix,
						  IdleMix, ServiceBrakeMix, EngineBrakeMix, RopMix, Rop2Mix, OverSpeedMix, OverSpeedHighMix, IVHOverSpeedMix, CoastOutOfGearMix,
						  HarshBrakingMix, AccelerationMix, BrakingMix, CorneringMix, AccelerationLowMix, BrakingLowMix, CorneringLowMix, 
						  AccelerationHighMix, BrakingHighMix, CorneringHighMix, ManoeuvresLowMix, ManoeuvresMedMix, ORCountMix, PtoMix, CruiseTopGearRatioMix,
						  CruiseOverspeedMix, TopGearOverspeedMix)
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
		COUNT(DISTINCT TopGearOverSpeedUsed) - 1
FROM @weightedData wd
GROUP BY VehicleIntId, DriverIntId

INSERT INTO @ConfigCount (VehicleIntId, DriverIntId, SweetSpotMix, FueledOverRPMMix, TopGearMix, CruiseMix, CruiseInTopGearsMix, CoastInGearMix,
						  IdleMix, ServiceBrakeMix, EngineBrakeMix, RopMix, Rop2Mix, OverSpeedMix, OverSpeedHighMix, IVHOverSpeedMix, CoastOutOfGearMix,
						  HarshBrakingMix, AccelerationMix, BrakingMix, CorneringMix, AccelerationLowMix, BrakingLowMix, CorneringLowMix, 
						  AccelerationHighMix, BrakingHighMix, CorneringHighMix, ManoeuvresLowMix, ManoeuvresMedMix, ORCountMix, PtoMix, CruiseTopGearRatioMix,
						  CruiseOverspeedMix, TopGearOverspeedMix)
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
		COUNT(DISTINCT TopGearOverSpeedUsed) - 1
FROM @weightedData wd
GROUP BY VehicleIntId

INSERT INTO @ConfigCount (VehicleIntId, DriverIntId, SweetSpotMix, FueledOverRPMMix, TopGearMix, CruiseMix, CruiseInTopGearsMix, CoastInGearMix,
						  IdleMix, ServiceBrakeMix, EngineBrakeMix, RopMix, Rop2Mix, OverSpeedMix, OverSpeedHighMix, IVHOverSpeedMix, CoastOutOfGearMix,
						  HarshBrakingMix, AccelerationMix, BrakingMix, CorneringMix, AccelerationLowMix, BrakingLowMix, CorneringLowMix, 
						  AccelerationHighMix, BrakingHighMix, CorneringHighMix, ManoeuvresLowMix, ManoeuvresMedMix, ORCountMix, PtoMix, CruiseTopGearRatioMix,
						  CruiseOverspeedMix, TopGearOverspeedMix)
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
		COUNT(DISTINCT TopGearOverSpeedUsed) - 1
FROM @weightedData wd
GROUP BY DriverIntId

INSERT INTO @ConfigCount (VehicleIntId, DriverIntId, SweetSpotMix, FueledOverRPMMix, TopGearMix, CruiseMix, CruiseInTopGearsMix, CoastInGearMix,
						  IdleMix, ServiceBrakeMix, EngineBrakeMix, RopMix, Rop2Mix, OverSpeedMix, OverSpeedHighMix, IVHOverSpeedMix, CoastOutOfGearMix,
						  HarshBrakingMix, AccelerationMix, BrakingMix, CorneringMix, AccelerationLowMix, BrakingLowMix, CorneringLowMix, 
						  AccelerationHighMix, BrakingHighMix, CorneringHighMix, ManoeuvresLowMix, ManoeuvresMedMix, ORCountMix, PtoMix, CruiseTopGearRatioMix,
						  CruiseOverspeedMix, TopGearOverspeedMix)
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
		COUNT(DISTINCT TopGearOverSpeedUsed) - 1
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
		dbo.GYRColourConfig(Acceleration, 33, ISNULL(ReportConfigId, @lrprtcfgid)) AS AccelerationLowColour, AccelerationLowMix,
		dbo.GYRColourConfig(Braking, 34, ISNULL(ReportConfigId, @lrprtcfgid)) AS BrakingLowColour, BrakingLowMix,
		dbo.GYRColourConfig(Cornering, 35, ISNULL(ReportConfigId, @lrprtcfgid)) AS CorneringLowColour, CorneringLowMix,
		dbo.GYRColourConfig(Acceleration, 36, ISNULL(ReportConfigId, @lrprtcfgid)) AS AccelerationHighColour, AccelerationHighMix,
		dbo.GYRColourConfig(Braking, 37, ISNULL(ReportConfigId, @lrprtcfgid)) AS BrakingHighColour, BrakingHighMix,
		dbo.GYRColourConfig(Cornering, 38, ISNULL(ReportConfigId, @lrprtcfgid)) AS CorneringHighColour, CorneringHighMix,
		dbo.GYRColourConfig(ManoeuvresLow, 39, ISNULL(ReportConfigId, @lrprtcfgid)) AS ManoeuvresLowColour, ManoeuvresLowMix,
		dbo.GYRColourConfig(ManoeuvresMed, 40, ISNULL(ReportConfigId, @lrprtcfgid)) AS ManoeuvresMedColour, ManoeuvresMedMix,
		dbo.GYRColourConfig(CruiseTopGearRatio*100, 25, ISNULL(ReportConfigId, @lrprtcfgid)) AS CruiseTopGearRatioColour, CruiseTopGearRatioMix,
		dbo.GYRColourConfig(OverRevCount, 28, ISNULL(ReportConfigId, @lrprtcfgid)) AS OverRevCountColour, ORCountMix AS OverRevCountMix,
		dbo.GYRColourConfig(Pto*100, 29, ISNULL(ReportConfigId, @lrprtcfgid)) AS PtoColour, PtoMix,
		dbo.GYRColourConfig(CruiseOverspeed*100, 43, ISNULL(ReportConfigId, @lrprtcfgid)) AS CruiseOverspeedColour, CruiseOverspeedMix,
		dbo.GYRColourConfig(TopGearOverspeed*100, 42, ISNULL(ReportConfigId, @lrprtcfgid)) AS TopGearOverspeedColour, TopGearOverspeedMix,
		NULL AS FuelWastageCostColour

FROM
	(SELECT *,
		
		Safety = dbo.ScoreByClassAndConfig('S', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, TopGearOverspeed, CruiseOverspeed, ISNULL(ReportConfigId, @lrprtcfgid)),
		Efficiency = dbo.ScoreByClassAndConfig('E', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, TopGearOverspeed, CruiseOverspeed, ISNULL(ReportConfigId, @lrprtcfgid)),

		SweetSpotComponent = dbo.ScoreComponentValueConfig(1, SweetSpot, ISNULL(ReportConfigId, @rprtcfgid)),
		OverRevWithFuelComponent = dbo.ScoreComponentValueConfig(2, OverRevWithFuel, ISNULL(ReportConfigId, @rprtcfgid)),
		TopGearComponent = dbo.ScoreComponentValueConfig(3, TopGear, ISNULL(ReportConfigId, @rprtcfgid)),
		CruiseComponent = dbo.ScoreComponentValueConfig(4, Cruise, ISNULL(ReportConfigId, @rprtcfgid)),
		CruiseInTopGearsComponent = dbo.ScoreComponentValueConfig(31, CruiseInTopGears, ISNULL(ReportConfigId, @rprtcfgid)),
		CruiseTopGearRatioComponent = dbo.ScoreComponentValueConfig(25, CruiseTopGearRatio, ISNULL(ReportConfigId, @rprtcfgid)),
		IdleComponent = dbo.ScoreComponentValueConfig(6, Idle, ISNULL(ReportConfigId, @rprtcfgid)),
		AccelerationComponent = dbo.ScoreComponentValueConfig(22, Acceleration, ISNULL(ReportConfigId, @rprtcfgid)),
		BrakingComponent = dbo.ScoreComponentValueConfig(23, Braking, ISNULL(ReportConfigId, @rprtcfgid)),
		CorneringComponent = dbo.ScoreComponentValueConfig(24, Cornering, ISNULL(ReportConfigId, @rprtcfgid)),
		AccelerationLowComponent = dbo.ScoreComponentValueConfig(33, AccelerationLow, ISNULL(ReportConfigId, @rprtcfgid)),
		BrakingLowComponent = dbo.ScoreComponentValueConfig(34, BrakingLow, ISNULL(ReportConfigId, @rprtcfgid)),
		CorneringLowComponent = dbo.ScoreComponentValueConfig(35, CorneringLow, ISNULL(ReportConfigId, @rprtcfgid)),
		AccelerationHighComponent = dbo.ScoreComponentValueConfig(36, AccelerationHigh, ISNULL(ReportConfigId, @rprtcfgid)),
		BrakingHighComponent = dbo.ScoreComponentValueConfig(37, BrakingHigh, ISNULL(ReportConfigId, @rprtcfgid)),
		CorneringHighComponent = dbo.ScoreComponentValueConfig(38, CorneringHigh, ISNULL(ReportConfigId, @rprtcfgid)),
		ManoeuvresLowComponent = dbo.ScoreComponentValueConfig(39, ManoeuvresLow, ISNULL(ReportConfigId, @rprtcfgid)),
		ManoeuvresMedComponent = dbo.ScoreComponentValueConfig(40, ManoeuvresMed, ISNULL(ReportConfigId, @rprtcfgid)),
		EngineServiceBrakeComponent = dbo.ScoreComponentValueConfig(7, EngineServiceBrake, ISNULL(ReportConfigId, @rprtcfgid)),
		OverRevWithoutFuelComponent = dbo.ScoreComponentValueConfig(8, OverRevWithoutFuel, ISNULL(ReportConfigId, @rprtcfgid)),
		RopComponent = dbo.ScoreComponentValueConfig(9, Rop, ISNULL(ReportConfigId, @rprtcfgid)),
		Rop2Component = dbo.ScoreComponentValueConfig(41, Rop2, ISNULL(ReportConfigId, @rprtcfgid)),
		OverSpeedComponent = dbo.ScoreComponentValueConfig(10, OverSpeed, ISNULL(ReportConfigId, @rprtcfgid)),
		OverSpeedHighComponent = dbo.ScoreComponentValueConfig(32, OverSpeedHigh, ISNULL(ReportConfigId, @rprtcfgid)),
		OverSpeedDistanceComponent = dbo.ScoreComponentValueConfig(21, OverSpeedDistance, ISNULL(ReportConfigId, @rprtcfgid)),
		IVHOverSpeedComponent = dbo.ScoreComponentValueConfig(30, IVHOverSpeed, ISNULL(ReportConfigId, @rprtcfgid)),
		CoastOutOfGearComponent = dbo.ScoreComponentValueConfig(11, CoastOutOfGear, ISNULL(ReportConfigId, @rprtcfgid)),
		CoastInGearComponent = dbo.ScoreComponentValueConfig(5, CoastInGear, ISNULL(ReportConfigId, @rprtcfgid)),
		HarshBrakingComponent = dbo.ScoreComponentValueConfig(12, HarshBraking, ISNULL(ReportConfigId, @rprtcfgid)),
		CruiseOverspeedComponent = dbo.ScoreComponentValueConfig(43, CruiseOverspeed, ReportConfigId),
		TopGearOverspeedComponent = dbo.ScoreComponentValueConfig(42, TopGearOverspeed, ReportConfigId)

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

			(CASE WHEN @fuelmult = 0.1 THEN
				(CASE WHEN SUM(wTotalFuel)=0 THEN NULL ELSE SUM(wTotalFuel * ISNULL(FuelMultiplier,1.0))*100 END)/SUM(FuelEconTotal) 
			ELSE
				(SUM(FuelEconTotal) * 1000) / (CASE WHEN SUM(wTotalFuel)=0 THEN NULL ELSE SUM(wTotalFuel * ISNULL(FuelMultiplier,1.0)) END) * @fuelmult END) AS FuelEcon
				
		FROM dbo.Reporting r
			INNER JOIN @weightedData w ON r.Date = w.Date AND r.VehicleIntId = w.VehicleIntId AND r.DriverIntId = w.DriverIntId
			INNER JOIN dbo.Vehicle v ON r.VehicleIntId = v.VehicleIntId
			INNER JOIN dbo.Driver d ON r.DriverIntId = d.DriverIntId
			INNER JOIN @period_dates p ON r.Date BETWEEN p.StartDate AND p.EndDate
			LEFT JOIN dbo.ReportingABC abc ON r.VehicleIntId = abc.VehicleIntId AND r.DriverIntId = abc.DriverIntId AND r.Date = abc.Date --AND r.RouteID = abc.RouteId
			LEFT JOIN dbo.ReportingOverspeed ro ON r.VehicleIntId = ro.VehicleIntId AND r.DriverIntId = ro.DriverIntId AND r.Date = ro.Date --AND r.RouteID = ro.RouteId
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
