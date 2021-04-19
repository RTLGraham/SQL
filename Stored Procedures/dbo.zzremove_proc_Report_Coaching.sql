SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[zzremove_proc_Report_Coaching]
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

--declare	@dids varchar(max),
--		@sdate datetime,
--		@edate datetime,
--		@uid UNIQUEIDENTIFIER,
--		@rprtcfgid UNIQUEIDENTIFIER,
--		@drilldown TINYINT,
--		@calendar TINYINT,
--		@groupBy INT

--SET	@dids = N'983AEB57-6600-42C3-BA24-8D307F5AD57F'
--SET	@sdate = '2012-10-08 00:00'
--SET	@edate = '2012-11-11 23:59'
--SET	@uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
--SET	@rprtcfgid = N'583B4D46-F49F-4C93-B55C-4E0BC1E2A96C'
--SET @drilldown = 1
--SET @calendar = 1
--SET @groupBy = 2

DECLARE @Results TABLE
(
		-- Week identification columns
 		PeriodNum INT,
		PeriodStartDate DATETIME,
		PeriodEndDate DATETIME,
		
		-- Vehicle and Driver Identification columns
		VehicleId UNIQUEIDENTIFIER,	
		Registration VARCHAR(MAX),
		
		DriverId UNIQUEIDENTIFIER,
 		DisplayName VARCHAR(MAX),
 		DriverName VARCHAR(MAX), -- included for backward compatibility
 		FirstName VARCHAR(MAX),
 		Surname VARCHAR(MAX),
 		MiddleNames VARCHAR(MAX),
 		Number VARCHAR(MAX),
 		NumberAlternate VARCHAR(MAX),
 		NumberAlternate2 VARCHAR(MAX),

		-- Coaching figures
		Coached INT,
		NotRequired INT,
		NotCoached INT,
 		
 		-- Data columns with corresponding colours below 
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
		
		-- Score columns
		Efficiency FLOAT, 
		SAFETY FLOAT,

		-- Additional columns with no corresponding colour	
		TotalTime FLOAT,
		TotalDrivingDistance FLOAT,
		ServiceBrakeUsage FLOAT,	
		OverRevCount FLOAT,
		
		-- Date and Unit columns 
		sdate DATETIME,
		edate DATETIME,
		CreationDateTime DATETIME,
		ClosureDateTime DATETIME,

		DistanceUnit VARCHAR(MAX),
		FuelUnit VARCHAR(MAX),
		Co2Unit VARCHAR(MAX),
		FuelMult FLOAT
)

-- Driver values by week and for period
INSERT INTO @Results
EXEC dbo.proc_ReportCoaching 
	@dids, @sdate, @edate, @uid, @rprtcfgid, @drilldown, @calendar, @groupBy

DELETE FROM @Results
WHERE PeriodNum IS NULL AND DriverId IS NULL AND VehicleId IS NULL

-- Fleet averages
INSERT INTO @Results
EXEC dbo.proc_ReportCoaching_Fleet
	@sdate, @edate, @uid, @rprtcfgid  -- pass NULLs so that the Fleet average for all vehicles will be calculated
		
SELECT 	--IDs
	PeriodNum,
	DriverId,
	--Scores
	[Safety],
	Efficiency,
	FuelEcon,

	--Common
	TotalDrivingDistance,
	TotalTime,

	--Coaching Figures
	Coached,
	NotRequired,
	NotCoached,

	--Safety values
	EngineServiceBrake,
	OverRevWithoutFuel,
	OverSpeed,
	IVHOverSpeed,
	CoastOutOfGear,
	HarshBraking,
	Rop,
	Acceleration,
	Braking,
	Cornering,
	OverRevCount,
	
	--Efficiency Values
	SweetSpot,
	OverRevWithFuel,
	TopGear,
	Cruise,
	CruiseTopGearRatio,
	CoastInGear,
	Idle,
	Co2,
	Pto,

	--Technical fields
	FuelMult,
	PeriodStartDate AS CreationDateTime,
	PeriodEndDate AS ClosureDateTime
	
FROM @Results
WHERE (PeriodNum IS NOT NULL AND DriverId IN (SELECT VALUE FROM Split(@dids, ',')) AND VehicleId IS NULL) -- detailed driver rows by week
   OR (PeriodNum IS NULL AND DriverId IN (SELECT VALUE FROM Split(@dids, ',')) AND VehicleId IS NULL) -- Driver Average
   OR (PeriodNum IS NULL AND DriverId IS NULL AND VehicleId IS NULL) -- Fleet Average
   

GO
