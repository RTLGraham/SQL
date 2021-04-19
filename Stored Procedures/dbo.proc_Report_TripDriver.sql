SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[proc_Report_TripDriver]
	@did UNIQUEIDENTIFIER,
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME,
	@route INT,
	@vehicleType INT
AS
--DECLARE @did UNIQUEIDENTIFIER,
--		@uid UNIQUEIDENTIFIER,
--		@rprtcfgid UNIQUEIDENTIFIER,
--		@sdate DATETIME,
--		@edate DATETIME,
--		@route INT,
--		@vehicleType INT
		
--SET		@did = N'82C340C4-F732-43EC-AB31-5C8E0627261D' 
--SET		@sdate = '2012-02-01 00:00'
--SET		@edate = '2012-02-03 23:59'
--SET		@uid = N'725ABDD5-54F6-4DB5-8789-B03949B29473'
--SET		@rprtcfgid = N'77C80BDB-5827-4C5E-BBF4-06F36ACB47D6'

IF @route = -999
BEGIN 
	SET @route = NULL
END
IF @vehicleType = -999
BEGIN 
	SET @vehicleType = NULL
END

DECLARE @diststr VARCHAR(50),
		@distmult FLOAT,
		@fuelstr VARCHAR(50),
		@fuelmult FLOAT,
		@language VARCHAR(20),
		@liquidstr VARCHAR(50),
		@liquidmult FLOAT,
		@co2mult FLOAT,
		@co2str VARCHAR(50),
		@co2const FLOAT

/* Convert time to UTC */
SET @sdate = [dbo].TZ_ToUTC(@sdate,DEFAULT,@uid)
SET @edate = [dbo].TZ_ToUTC(@edate,DEFAULT,@uid)
SET @co2const = 2639.1

SELECT @diststr = [dbo].UserPref(@uid, 203)
SELECT @distmult = [dbo].UserPref(@uid, 202)
SELECT @fuelstr = [dbo].UserPref(@uid, 205)
SELECT @fuelmult = [dbo].UserPref(@uid, 204)
SELECT @liquidstr = [dbo].UserPref(@uid, 201)
SELECT @liquidmult = [dbo].UserPref(@uid, 200)
SELECT @co2str = [dbo].UserPref(@uid, 211)
SELECT @co2mult = [dbo].UserPref(@uid, 210)

SELECT
	/*General*/
	v.Registration,
	ISNULL(vt.Name,'Unknown') AS VehicleType,
	d.Surname,	
	r.RouteNumber,
	[dbo].TZ_GetTime(a.CreationDateTime,default,@uid) AS CreationDateTime,
	[dbo].TZ_GetTime(a.ClosureDateTime,default,@uid) AS ClosureDateTime,
	/*Total*/
	ROUND(SUM(CAST(a.TotalEngineHours AS FLOAT)/60.0),1) AS TotalTime, 
	ROUND(SUM(TotalVehicleDistance * 1000) * @distmult,1) AS TotalDistance, 
	ROUND(SUM(TotalVehicleFuel) * @liquidmult,1) AS TotalFuel, 
	ROUND(SUM(TotalVehicleFuel) * @co2const / dbo.ZeroYieldNull(SUM(TotalVehicleDistance)) * @co2mult,1) AS TotalCO2,
	CASE WHEN @fuelmult = 0.1 
		THEN
			ROUND(dbo.ZeroYieldNull(SUM(TotalVehicleFuel * ISNULL(FuelMultiplier,1.0) * 100) / dbo.ZeroYieldNull(SUM(TotalVehicleDistance))),2)
		ELSE
			ROUND((SUM(TotalVehicleDistance * 1000)) / dbo.ZeroYieldNull(SUM(TotalVehicleFuel * ISNULL(FuelMultiplier,1.0))) * @fuelmult,2)
		END AS TotalFuelEcon,
	
	/*Driving*/
	ROUND(SUM(CAST(a.DrivingTime AS FLOAT)/60.0),1) AS DrivingTime, 
	ROUND(SUM(DrivingDistance * 1000) * @distmult,1) AS DrivingDistance, 
	ROUND(SUM(DrivingFuel) * @liquidmult,1) AS DrivingFuel,
	CASE WHEN @fuelmult = 0.1 
		THEN
			ROUND(dbo.ZeroYieldNull(SUM(DrivingFuel * ISNULL(FuelMultiplier,1.0) * 100) / dbo.ZeroYieldNull(SUM(DrivingDistance))),2)
		ELSE
			ROUND((SUM(DrivingDistance * 1000)) / dbo.ZeroYieldNull(SUM(DrivingFuel * ISNULL(FuelMultiplier,1.0))) * @fuelmult,2)
		END AS DrivingFuelEcon,	
	
	/*Efficiency*/	
	ROUND(dbo.ScoreEfficiencyConfig(
		SUM(InSweetSpotDistance * 1000)/dbo.ZeroYieldNull(SUM(DrivingDistance * 1000)), 
		SUM(FueledOverRPMDistance * 1000)/dbo.ZeroYieldNull(SUM(DrivingDistance * 1000)), 
		0, 
		0, 
		SUM(IdleTime)/dbo.ZeroYieldNull(SUM(TotalEngineHours)), 
		0, 
		@rprtcfgid),0) AS Efficiency,
	dbo.GYRColourConfig(
		dbo.ScoreEfficiencyConfig(
			SUM(InSweetSpotDistance * 1000)/dbo.ZeroYieldNull(SUM(DrivingDistance * 1000)), 
			SUM(FueledOverRPMDistance * 1000)/dbo.ZeroYieldNull(SUM(DrivingDistance * 1000)), 
			0, 
			0, 
			SUM(IdleTime)/dbo.ZeroYieldNull(SUM(TotalEngineHours)), 
			0, 
			@rprtcfgid), 
		14, 
		@rprtcfgid) AS EfficiencyColour,
	/*Sweet Spot*/
	ROUND(CAST(SUM(InSweetSpotTime) AS FLOAT)/60.0, 1) AS SweetSpotTime,
	ROUND(SUM(InSweetSpotDistance * 1000) * @distmult, 1) AS SweetSpotDistance,
	ROUND(SUM(InSweetSpotFuel) * @liquidmult, 1) AS SweetSpotFuel,
	SUM(InSweetSpotDistance * 1000)/dbo.ZeroYieldNull(SUM(DrivingDistance * 1000)) AS SweetSpotDistancePrcnt,
	
	/*OverRev*/
	ROUND(CAST(SUM(FueledOverRPMTime) AS FLOAT)/60.0, 1) AS OverRevTime,
	ROUND(SUM(FueledOverRPMDistance * 1000) * @distmult,1) AS OverRevDistance,
	ROUND(SUM(FueledOverRPMFuel) * @liquidmult,1) AS OverRevFuel,
	SUM(FueledOverRPMDistance * 1000)/dbo.ZeroYieldNull(SUM(DrivingDistance * 1000)) AS OverRevDistancePrcnt,
	
	/*Idle*/
	ROUND(CAST(SUM(IdleTime) AS FLOAT)/60.0, 1) AS IdleTime,
	ROUND(SUM(IdleFuel) * @liquidmult,1) AS IdleFuel, 
	SUM(IdleTime)/dbo.ZeroYieldNull(SUM(TotalEngineHours)) AS IdleTimePrcnt, 
	
	/*Safety*/	
	ROUND(dbo.ScoreSafetyConfig(
		0, 
		0, 
		0, 
		0, 
		0, 
		0, 
		0, 
		COUNT(ea.creationcodeid)/dbo.ZeroYieldNull(SUM(DrivingDistance * 1000) * @distmult / 1000), 
		COUNT(ea.creationcodeid)/dbo.ZeroYieldNull(SUM(DrivingDistance * 1000) * @distmult / 1000), 
		COUNT(ea.creationcodeid)/dbo.ZeroYieldNull(SUM(DrivingDistance * 1000) * @distmult / 1000), 
		@rprtcfgid),0) AS Safety,
	dbo.GYRColourConfig(
		dbo.ScoreSafetyConfig(
			0, 
			0, 
			0, 
			0, 
			0, 
			0, 
			0, 
			COUNT(ea.creationcodeid)/dbo.ZeroYieldNull(SUM(DrivingDistance * 1000) * @distmult / 1000), 
			COUNT(ea.creationcodeid)/dbo.ZeroYieldNull(SUM(DrivingDistance * 1000) * @distmult / 1000), 
			COUNT(ea.creationcodeid)/dbo.ZeroYieldNull(SUM(DrivingDistance * 1000) * @distmult / 1000), 
			@rprtcfgid), 
		15, 
		@rprtcfgid) AS SafetyColour,
		
	/*A*/
	ROUND(COUNT(ea.creationcodeid)/dbo.ZeroYieldNull(SUM(DrivingDistance * 1000) * @distmult / 1000),0) AS AccelerationProp,
	COUNT(ea.creationcodeid) AS AccelerationCount,
	
	/*B*/
	ROUND(COUNT(ea.creationcodeid)/dbo.ZeroYieldNull(SUM(DrivingDistance * 1000) * @distmult / 1000),0) AS BrakingProp,
	COUNT(eb.creationcodeid) AS BrakingCount,
	
	/*C*/
	ROUND(COUNT(ea.creationcodeid)/dbo.ZeroYieldNull(SUM(DrivingDistance * 1000) * @distmult / 1000),0) AS CorneringProp,
	COUNT(ec.creationcodeid) AS CorneringCount,
	
	/*Unmeasured*/	
	/*Cruise control*/
	ROUND(SUM(CAST(a.CruiseControlTime AS FLOAT)/60.0),1) AS CruiseControlTime, 
	ROUND(SUM(CruiseControlDistance * 1000) * @distmult,1) AS CruiseControlDistance, 
	ROUND(SUM(CruiseControlFuel) * @liquidmult,1) AS CruiseControlFuel, 
	
	/*Coast out of gear*/
	ROUND(SUM(CAST(a.CoastOutOfGearTime AS FLOAT)/60.0),1) AS CoastOutOfGearTime, 
	ROUND(SUM(CoastOutOfGearDistance * 1000) * @distmult,1) AS CoastOutOfGearDistance, 
	
	/*Coast in gear*/
	ROUND(SUM(CAST(a.CoastInGearTime AS FLOAT)/60.0),1) AS CoastInGearTime, 
	ROUND(SUM(CoastInGearDistance * 1000) * @distmult,1) AS CoastInGearDistance, 
	ROUND(SUM(CoastInGearFuel) * @liquidmult,1) AS CoastInGearFuel, 
	
	/*Average RPM*/
	AVG(AverageEngineRPM) as AverageRPM,
	AVG(AverageEngineRPMWhileDriving) as AverageDrivingRPM,
	
	/*Service Brake*/
	ROUND(SUM(CAST(a.ServiceBrakeTime AS FLOAT)/60.0),1) AS ServiceBrakeTime, 
	ROUND(SUM(ServiceBrakeDistance * 1000) * @distmult,1) AS ServiceBrakeDistance,
	
	/*Technical*/
	@fuelstr AS FuelStr,
	@diststr AS DistanceStr,
	@liquidstr AS LiquidStr,
	@co2str AS CO2Str,
	[dbo].TZ_GetTime(@sdate,default,@uid) AS ReportStartDate,
	[dbo].TZ_GetTime(@edate,default,@uid) AS ReportEndDate
FROM dbo.Accum a 
	INNER JOIN dbo.Driver d ON a.DriverIntId = d.DriverIntId  
	INNER JOIN dbo.Vehicle v ON a.VehicleIntId = v.VehicleIntId
	LEFT JOIN dbo.Event ea ON v.VehicleIntId = ea.VehicleIntId AND d.DriverIntId = ea.DriverIntId AND ea.CreationCodeId = 37
		AND ea.eventdatetime BETWEEN a.CreationDateTime AND a.ClosureDateTime
	LEFT JOIN dbo.Event eb ON v.VehicleIntId = eb.VehicleIntId AND d.DriverIntId = eb.DriverIntId AND eb.CreationCodeId = 36
		AND eb.eventdatetime BETWEEN a.CreationDateTime AND a.ClosureDateTime
	LEFT JOIN dbo.Event ec ON v.VehicleIntId = eb.VehicleIntId AND d.DriverIntId = eb.DriverIntId AND eb.CreationCodeId = 38
		AND ec.eventdatetime BETWEEN a.CreationDateTime AND a.ClosureDateTime
	LEFT JOIN dbo.VehicleType vt ON v.VehicleTypeID = vt.VehicleTypeID
	LEFT JOIN dbo.Route r ON r.RouteID = a.RouteID
WHERE d.DriverId = @did
	AND CreationDateTime BETWEEN @sdate AND @edate
	AND DrivingTime > 0
	AND DrivingDistance > 0
	--AND a.RouteID = CASE WHEN @route IS NOT NULL THEN @route WHEN @route IS NULL THEN a.RouteID END
	--AND vt.VehicleTypeID = CASE WHEN @vehicleType IS NOT NULL THEN @vehicleType WHEN @vehicleType IS NULL THEN vt.VehicleTypeID END
GROUP BY v.Registration, 
		 vt.Name,
		 d.Surname, 
		 CreationDateTime,
		 ClosureDateTime,
		 r.RouteNumber, 
		 vt.Name

GO
