SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO












CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_Trends]
(
	@vids varchar(max) = NULL,
	@gids varchar(max) = NULL,
	@startDate datetime,
	@endDate datetime,
	@routeId int = NULL,
	@vehicleTypeId int = NULL,
	@userId uniqueidentifier,
	@configId uniqueidentifier,
	@groupBy INT,
	@rptlevel INT = NULL
)
AS

--DECLARE	@vids varchar(max),
--	@gids varchar(max),
--	@startDate datetime,
--	@endDate datetime,
--	@routeId int,
--	@vehicleTypeId int,
--	@userId uniqueidentifier,
--	@configId UNIQUEIDENTIFIER,
--	@groupby INT,
--	@rptlevel INT
	
--SET @vids = N'a8dc179e-04ab-4483-9141-a95f46b0968b,5de385bf-bfcb-4179-90cb-5aee460b14ad,486a43f1-70d9-46cc-a745-542b6a4d77ce,db3ac174-1cfe-404c-914b-6be9db1b7038,6cd1331b-f7fc-4866-a333-8fee45667f33,16e217d8-bd8d-4d91-a894-b132c6c46170,67b44e7f-6a0e-42e0-9dcf-5ddca2af502e,91d26e73-dbd4-45da-935c-997766c44aa2,2c1a82de-6dcb-4d03-bc21-5f65198b9a84,8016f50d-a2d1-49a9-bc1e-13ae27953390,3708f23a-f7ca-44f0-bb96-a94e80c40dff,d075f7ef-c02e-46e4-91c3-8191f2167f59'
--SET @gids = N'906e3bad-7739-44b1-8966-28f8d4f10a09'
--SET @vehicletypeid = NULL
--SET @routeid = NULL
--SET	@startdate = '2016-12-05 00:00:00'
--SET	@enddate = '2016-12-11 23:59:59'
--SET	@userid = N'e3acb89a-e2f7-4325-8f2a-c228ff9056ba'
--SET	@configid = N'00000000-0000-0000-0000-000000000000'
--SET @groupby = 0
--SET @rptlevel = 1

DECLARE @Results TABLE (
	
		-- Vehicle, Driver and Group Identification columns
		PeriodNum INT,
		WeekStartDate DATETIME,
		WeekEndDate DATETIME,
		PeriodType VARCHAR(MAX),
		VehicleId UNIQUEIDENTIFIER,	
		Registration VARCHAR(MAX),
		
		DriverId UNIQUEIDENTIFIER,
 		DisplayName VARCHAR(MAX),
 		FirstName VARCHAR(MAX),
 		Surname VARCHAR(MAX),
 		MiddleNames VARCHAR(MAX),
 		Number VARCHAR(MAX),
 		NumberAlternate VARCHAR(MAX),
 		NumberAlternate2 VARCHAR(MAX),
 		
 		GroupId UNIQUEIDENTIFIER,
 		GroupName VARCHAR(MAX),
 		
 		-- Data columns 
		SweetSpot FLOAT, 
		OverRevWithFuel FLOAT, 
		TopGear FLOAT, 
		Cruise FLOAT, 
		CruiseInTopGears FLOAT,
		CoastInGear FLOAT, 
		CruiseTopGearRatio FLOAT,
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
		TotalFuel FLOAT,
		Pto FLOAT, 
		Co2 FLOAT, 
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
		
		-- Score columns
		Efficiency FLOAT, 
		Safety FLOAT,
		
		-- Additional columns with no corresponding colour	
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

		DistanceUnit VARCHAR(MAX),
		FuelUnit VARCHAR(MAX),
		Co2Unit VARCHAR(MAX),
		FuelMult VARCHAR(MAX),
		LiquidUnit VARCHAR(MAX),
		Currency VARCHAR(10)
	)
                    
	IF (@vids IS NULL AND @gids IS NULL) OR @rptlevel = 1 -- full fleet report
	BEGIN	
	INSERT INTO @Results
		EXEC dbo.proc_Report_Trend_VehicleFleet
					@vids = @vids,
					@gids = @gids,
                    @sdate = @startDate,
                    @edate = @endDate,
                    @routeid = @routeid,
                    @vehicletypeid = @vehicleTypeId,
                    @uid = @userId,
                    @rprtcfgid = @configId,
                    @drilldown = 1,
                    @calendar = 0,
                    @groupBy = @groupBy;
		SELECT *
		FROM @Results
		WHERE VehicleId IS NULL AND GroupId IS NULL AND PeriodNum IS NOT NULL
		ORDER BY PeriodNum
	END
	
	IF (@vids IS NULL AND @gids IS NOT NULL) OR @rptlevel = 2 -- vehicle group report
	BEGIN
	INSERT INTO @Results
		EXEC dbo.proc_Report_Trend_VehicleGroup
	  				@vids = @vids,
                    @gids = @gids,
                    @sdate = @startDate,
                    @edate = @endDate,
                    @routeid = @routeid,
                    @vehicletypeid = @vehicleTypeId,
                    @uid = @userId,
                    @rprtcfgid = @configId,
                    @drilldown = 1,
                    @calendar = 0,
                    @groupBy = @groupBy;
		SELECT *
		FROM @Results
		WHERE VehicleId IS NULL AND GroupId IS NOT NULL AND PeriodNum IS NOT NULL
		ORDER BY GroupName, PeriodNum
	END
	
	IF (@vids IS NOT NULL AND @gids IS NULL) OR @rptlevel = 3 -- report by vehicle
	BEGIN
		INSERT INTO @Results
		EXEC dbo.proc_Report_Trend_Vehicle
	  				@vids = @vids,
                    @gids = @gids,
                    @sdate = @startDate,
                    @edate = @endDate,
                    @routeid = @routeid,
                    @vehicletypeid = @vehicleTypeId,
                    @uid = @userId,
                    @rprtcfgid = @configId,
                    @drilldown = 1,
                    @calendar = 0,
                    @groupBy = @groupBy;
		SELECT *
		FROM @Results
		WHERE VehicleId IS NOT NULL AND GroupId IS NULL AND PeriodNum IS NOT NULL
		ORDER BY Registration, PeriodNum
	END
	

GO
