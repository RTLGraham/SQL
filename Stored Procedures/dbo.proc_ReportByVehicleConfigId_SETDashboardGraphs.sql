SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportByVehicleConfigId_SETDashboardGraphs]
(
	@gids VARCHAR(MAX),
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER,
	@periodType INT
)
AS

--DECLARE	@gids VARCHAR(MAX),
--		@sdate datetime,
--		@edate datetime,
--		@uid uniqueidentifier,
--		@rprtcfgid UNIQUEIDENTIFIER,
--		@periodType INT

--SET @gids = N'5C3153C6-FA67-471B-8008-3122D35CFEED'
--SET @sdate = '2018-10-20 00:00'
--SET @edate = '2018-11-19 23:59'
--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
--SET	@rprtcfgid = N'1C595889-0353-43F4-B840-64781558BBF5'
--SET @periodType = 2

DECLARE @lgids VARCHAR(MAX),
		@lsdate datetime,
		@ledate datetime,
		@luid UNIQUEIDENTIFIER,
		@lrprtcfgid UNIQUEIDENTIFIER
		
SET @lgids = @gids
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
END	ELSE
BEGIN
	SET @ledate = DATEADD(ss, -1, CAST(FLOOR(CAST(@now AS FLOAT)) AS DATETIME))
	IF @periodType >= 1 --last 3 months
	BEGIN
		INSERT INTO @period_dates(PeriodId, StartDate, EndDate) VALUES (DATEPART(MONTH, @now), DATEADD(MONTH, DATEDIFF(MONTH, 0, @now), 0), DATEADD(ss, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, @now)+1, 0)))
		INSERT INTO @period_dates(PeriodId, StartDate, EndDate) VALUES (DATEPART(MONTH, DATEADD(MONTH, -1, @now)), DATEADD(MONTH, DATEDIFF(MONTH, 0, @now)-1, 0), DATEADD(ss, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, @now), 0)))
		INSERT INTO @period_dates(PeriodId, StartDate, EndDate) VALUES (DATEPART(MONTH, DATEADD(MONTH, -2, @now)), DATEADD(MONTH, DATEDIFF(MONTH, 0, @now)-2, 0), DATEADD(ss, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, @now)-1, 0)))
		SET @lsdate = DATEADD(MONTH, DATEDIFF(MONTH, 0, @now)-2, 0)
	END

	IF @periodType >= 2 -- last 6 months
	BEGIN
		INSERT INTO @period_dates(PeriodId, StartDate, EndDate) VALUES (DATEPART(MONTH, DATEADD(MONTH, -3, @now)), DATEADD(MONTH, DATEDIFF(MONTH, 0, @now)-3, 0), DATEADD(ss, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, @now)-2, 0)))
		INSERT INTO @period_dates(PeriodId, StartDate, EndDate) VALUES (DATEPART(MONTH, DATEADD(MONTH, -4, @now)), DATEADD(MONTH, DATEDIFF(MONTH, 0, @now)-4, 0), DATEADD(ss, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, @now)-3, 0)))
		INSERT INTO @period_dates(PeriodId, StartDate, EndDate) VALUES (DATEPART(MONTH, DATEADD(MONTH, -5, @now)), DATEADD(MONTH, DATEDIFF(MONTH, 0, @now)-5, 0), DATEADD(ss, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, @now)-4, 0)))
		SET @lsdate = DATEADD(MONTH, DATEDIFF(MONTH, 0, @now)-5, 0)
	END

	IF @periodType = 3 -- last 12 months
	BEGIN
		INSERT INTO @period_dates(PeriodId, StartDate, EndDate) VALUES (DATEPART(MONTH, DATEADD(MONTH, -6, @now)), DATEADD(MONTH, DATEDIFF(MONTH, 0, @now)-6, 0), DATEADD(ss, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, @now)-5, 0)))
		INSERT INTO @period_dates(PeriodId, StartDate, EndDate) VALUES (DATEPART(MONTH, DATEADD(MONTH, -7, @now)), DATEADD(MONTH, DATEDIFF(MONTH, 0, @now)-7, 0), DATEADD(ss, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, @now)-6, 0)))
		INSERT INTO @period_dates(PeriodId, StartDate, EndDate) VALUES (DATEPART(MONTH, DATEADD(MONTH, -8, @now)), DATEADD(MONTH, DATEDIFF(MONTH, 0, @now)-8, 0), DATEADD(ss, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, @now)-7, 0)))
		INSERT INTO @period_dates(PeriodId, StartDate, EndDate) VALUES (DATEPART(MONTH, DATEADD(MONTH, -9, @now)), DATEADD(MONTH, DATEDIFF(MONTH, 0, @now)-9, 0), DATEADD(ss, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, @now)-8, 0)))
		INSERT INTO @period_dates(PeriodId, StartDate, EndDate) VALUES (DATEPART(MONTH, DATEADD(MONTH, -10, @now)), DATEADD(MONTH, DATEDIFF(MONTH, 0, @now)-10, 0), DATEADD(ss, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, @now)-9, 0)))
		INSERT INTO @period_dates(PeriodId, StartDate, EndDate) VALUES (DATEPART(MONTH, DATEADD(MONTH, -11, @now)), DATEADD(MONTH, DATEDIFF(MONTH, 0, @now)-11, 0), DATEADD(ss, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, @now)-10, 0)))
		SET @lsdate = DATEADD(MONTH, DATEDIFF(MONTH, 0, @now)-11, 0)
	END
END	

-- Create temporary table for vehicle configs
DECLARE @VehicleConfig TABLE
(
	Vid UNIQUEIDENTIFIER,
	ReportConfigId UNIQUEIDENTIFIER,
	TotalsIndicatorId INT
)

INSERT INTO @VehicleConfig (Vid, ReportConfigId)
SELECT DISTINCT v.VehicleId, ISNULL(vrc.ReportConfigurationId, @lrprtcfgid)
FROM dbo.Reporting r
INNER JOIN dbo.Vehicle v ON r.VehicleIntId = v.VehicleIntId
INNER JOIN dbo.Driver d ON r.DriverIntId = d.DriverIntId
INNER JOIN dbo.GroupDetail gd ON gd.EntityDataId = d.DriverId
INNER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId
LEFT JOIN dbo.VehicleReportConfiguration vrc ON v.VehicleId = vrc.VehicleId
WHERE r.Date BETWEEN @lsdate AND @ledate
  AND g.IsParameter = 0 
  AND g.Archived = 0 
  AND g.GroupId IN (SELECT Value FROM dbo.Split(@lgids, ','))

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
	DrivingDistance FLOAT,
	wInSweetSpotDistance FLOAT, InSweetSpotTotal FLOAT,
	wFueledOverRPMDistance FLOAT, FueledOverRPMTotal FLOAT, 
	wTopGearDistance FLOAT, TopGearTotal FLOAT, 
	wCruiseControlDistance FLOAT, CruiseTotal FLOAT, 
	wCruiseInTopGearsDistance FLOAT, CruiseInTopGearsTotal FLOAT, 
	wCoastInGearDistance FLOAT, CoastInGearTotal FLOAT, 
	wIdleTime FLOAT, IdleTotal FLOAT, 
	wEngineBrakeDistance FLOAT, EngineServiceTotal FLOAT,  
	wEngineBrakeOverRPMDistance FLOAT, EngineBrakeOverRPMTotal FLOAT, 
	wROPCount FLOAT, ROPTotal FLOAT,
	wROP2Count FLOAT, ROP2Total FLOAT, 
	wOverspeedDistance FLOAT, OverSpeedTotal FLOAT, 
	wOverSpeedHighDistance FLOAT, OverSpeedHighTotal FLOAT, 
	wIVHOverSpeedDistance FLOAT, IVHOverSpeedTotal FLOAT, 
	wCoastOutOfGearDistance FLOAT, CoastOutOfGearTotal FLOAT, 
	wPanicStopCount FLOAT, PanicStopTotal FLOAT, 
	wAcceleration FLOAT, AccelerationTotal FLOAT, 
	wBraking FLOAT, BrakingTotal FLOAT, 
	wCornering FLOAT, CorneringTotal FLOAT, 
	wAccelerationLow FLOAT, AccelerationLowTotal FLOAT, 
	wBrakingLow FLOAT, BrakingLowTotal FLOAT, 
	wCorneringLow FLOAT, CorneringLowTotal FLOAT,
	wAccelerationHigh FLOAT, AccelerationHighTotal FLOAT,
	wBrakingHigh FLOAT, BrakingHighTotal FLOAT, 
	wCorneringHigh FLOAT, CorneringHighTotal FLOAT, 
	wManoeuvresLow FLOAT, ManoeuvresLowTotal FLOAT, 		
	wManoeuvresMed FLOAT, ManoeuvresMedTotal FLOAT, 		
	wORCount FLOAT, ORCountTotal FLOAT, 
	wPTOTime FLOAT, PTOTotal FLOAT,
	wTotalFuel FLOAT, FuelEconTotal FLOAT,
	wTopGearOverSpeed FLOAT, TopGearOverSpeedTotal FLOAT, 
	wCruiseOverSpeed FLOAT, CruiseOverSpeedTotal FLOAT
)

INSERT INTO @weightedData  (Date, 
							DrivingDistance,
							wInSweetSpotDistance, InSweetSpotTotal, 
							wFueledOverRPMDistance, FueledOverRPMTotal, 
							wTopGearDistance, TopGearTotal, 
							wCruiseControlDistance, CruiseTotal, 
							wCruiseInTopGearsDistance, CruiseInTopGearsTotal, 
							wCoastInGearDistance, CoastInGearTotal, 
							wIdleTime, IdleTotal, 
							wEngineBrakeDistance, EngineServiceTotal, 
							wEngineBrakeOverRPMDistance, EngineBrakeOverRPMTotal, 
							wROPCount, ROPTotal, 
							wROP2Count, ROP2Total, 
							wOverspeedDistance, OverSpeedTotal, 
							wOverSpeedHighDistance, OverSpeedHighTotal, 
							wIVHOverSpeedDistance, IVHOverSpeedTotal, 
							wCoastOutOfGearDistance, CoastOutOfGearTotal, 
							wPanicStopCount, PanicStopTotal, 
							wAcceleration, AccelerationTotal, 
							wBraking, BrakingTotal, 
							wCornering, CorneringTotal,
							wAccelerationLow, AccelerationLowTotal, 
							wBrakingLow, BrakingLowTotal, 
							wCorneringLow, CorneringLowTotal, 
							wAccelerationHigh, AccelerationHighTotal, 
							wBrakingHigh, BrakingHighTotal, 
							wCorneringHigh, CorneringHighTotal, 
							wManoeuvresLow, ManoeuvresLowTotal, 
							wManoeuvresMed, ManoeuvresMedTotal, 													
							wORCount, ORCountTotal, 
							wPTOTime, PTOTotal,
							wTotalFuel, FuelEconTotal,
							wTopGearOverSpeed, TopGearOverSpeedTotal,
							wCruiseOverSpeed, CruiseOverSpeedTotal)
SELECT	Date,
		SUM(DrivingDistance),
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
		SUM(wTopGearOverSpeed), SUM(TopGearOverSpeedTotal),
		SUM(wCruiseOverSpeed), SUM(CruiseOverSpeedTotal)
FROM	(
	SELECT	r.Date,
			CASE WHEN ic.IndicatorId = vc.TotalsIndicatorId THEN r.DrivingDistance + r.PTOMovingDistance END AS DrivingDistance,

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
		LEFT JOIN dbo.ReportingABC abc ON r.VehicleIntId = abc.VehicleIntId AND r.DriverIntId = abc.DriverIntId AND r.Date = abc.Date --AND r.RouteID = abc.RouteId
		LEFT JOIN dbo.ReportingOverspeed ro ON r.VehicleIntId = ro.VehicleIntId AND r.DriverIntId = ro.DriverIntId AND r.Date = ro.Date --AND r.RouteID = ro.RouteId
		LEFT JOIN dbo.TAN_EntityCheckOut tec ON v.VehicleId = tec.EntityId -- to excluded data for days where a vehicle is checked out during that day
												AND FLOOR(CAST(r.Date AS FLOAT)) BETWEEN FLOOR(CAST(tec.CheckOutDateTime AS FLOAT)) AND FLOOR(CAST(tec.CheckInDateTime AS FLOAT))
												AND tec.CheckOutReason NOT IN ('Defrosting', 'Abtauen', 'Dégelé', 'Sbrinare')

	WHERE r.Date BETWEEN @lsdate AND @ledate 
	  AND r.DrivingDistance > 0
	  AND ic.Archived = 0
	  AND tec.EntityCheckOutId IS NULL -- exclude data for checked out periods
	) raw
GROUP BY raw.Date

-- Now perform main report processing
SELECT
		-- Period identification columns
 		p.PeriodId AS PeriodNum,
		[dbo].TZ_GetTime(p.StartDate,default,@luid) AS PeriodStartDate,
		[dbo].TZ_GetTime(p.EndDate,default,@luid) AS PeriodEndDate,	
 		
		-- Score columns
		Efficiency, 
		Safety

FROM
	(
		SELECT *,
		
		Safety = dbo.ScoreByClassAndConfig('S', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, TopGearOverspeed, CruiseOverspeed, @lrprtcfgid),
		Efficiency = dbo.ScoreByClassAndConfig('E', SweetSpot, OverRevWithFuel, TopGear, Cruise, CruiseInTopGears, CoastInGear, Idle, EngineServiceBrake, OverRevWithoutFuel, Rop, OverSpeed, OverSpeedHigh, CoastOutOfGear, HarshBraking, Co2, OverSpeedDistance, Acceleration, Braking, Cornering, AccelerationLow, BrakingLow, CorneringLow, AccelerationHigh, BrakingHigh, CorneringHigh, CruiseTopGearRatio, OverRevCount, Pto, IVHOverSpeed, ManoeuvresLow, ManoeuvresMed, Rop2, TopGearOverspeed, CruiseOverspeed, @lrprtcfgid)

	FROM
		(SELECT
			CASE WHEN (GROUPING(p.PeriodId) = 1) THEN NULL
				ELSE ISNULL(p.PeriodId, NULL)
			END AS PeriodId,	

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

			ISNULL(SUM(wCruiseOverSpeed) / dbo.ZeroYieldNull(SUM(CruiseOverSpeedTotal)), 0) AS CruiseOverspeed,
			ISNULL(SUM(wTopGearOverSpeed) / dbo.ZeroYieldNull(SUM(w.TopGearOverSpeedTotal)), 0) AS TopGearOverspeed,
			
			SUM(DrivingDistance * 1000 * @distmult) AS TotalDrivingDistance
			--SUM(TotalTime) AS TotalTime	
		FROM @weightedData w
			INNER JOIN @period_dates p ON w.Date BETWEEN p.StartDate AND p.EndDate


		WHERE DrivingDistance > 0
		--  AND tec.EntityCheckOutId IS NULL -- exclude data for checked out periods
		GROUP BY p.PeriodId WITH CUBE
		HAVING SUM(DrivingDistance) > 10 ) o

	) Result
    
LEFT JOIN @period_dates p ON Result.PeriodId = p.PeriodId
WHERE PeriodNum IS NOT NULL
ORDER BY PeriodStartDate	

GO
