SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[cuf_Driver_Report_Trends]
(
	@dids varchar(max) = NULL,
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

--DECLARE	@dids varchar(max),
--	@gids varchar(max),
--	@startDate datetime,
--	@endDate datetime,
--	@routeId int,
--	@vehicleTypeId int,
--	@userId uniqueidentifier,
--	@configId UNIQUEIDENTIFIER,
--	@groupBy INT,
--	@rptlevel INT
	
--SET @dids = N'cc4898c9-1017-4de6-9fcf-824feb0064cf,9646aba4-bcdb-4330-a89c-667971f16e4b,ade1e600-0d08-446e-a1e6-30d0559f8642,7698859b-3102-46e0-9b5d-bd53c13afa98,5aad127e-3822-48fa-9ebe-6c1c845a4931,f516bac0-05ef-43c8-bfd5-d8bb9dad0e08,f12247e5-84ad-4494-98d4-16e5ea442d14,1981b171-28fe-42f0-a866-adfd040d8b7e,e182c23f-b02d-48d5-aac8-144d0b8d8645,356fab16-fbd6-48e3-bb63-17fa76ccd371,217ed1a9-901e-48aa-a6f6-a9f033142287,8b5d301b-3f44-4237-818d-519b79d29aef,f8d25065-b868-4916-a7d1-52e37bcbd16a,2f27ebe1-b4a3-4876-9c3f-429b71177456,e222b286-4816-430c-a89a-f60c03f58d89,7ba1c109-3cbe-49fd-94be-010f4eb6dc82,a9956e1d-0396-4225-a22a-ab78343a5ce7,91d10c18-7143-450a-a8a5-48eac13194a1,fc0496ae-c058-4c71-9571-44f797fbdb01'
--SET @gids = N'7cb93031-14a6-4d51-88a6-546e4c377548,6b42d924-bcb7-4300-93f7-58bd82e26797'
--SET @vehicletypeid = NULL
--SET @routeid = NULL
--SET	@startdate = '2018-11-01 00:00'
--SET	@enddate = '2018-11-07 23:50'
--SET	@userid = N'23697441-6527-45fe-811d-4c37814bdb24'
--SET	@configid = N'dd0c6533-84a7-41eb-9f2a-c8e3b3a0a78e'
--SET @groupBy = 0
--SET @rptlevel = 3

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
	
	IF (@dids IS NULL AND @gids IS NOT NULL) OR @rptlevel = 2 -- report by driver group
	BEGIN
	INSERT INTO @Results
		EXEC dbo.proc_Report_Trend_DriverGroup
	  				@dids = @dids,
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
		WHERE DriverId IS NULL AND GroupId IS NOT NULL AND PeriodNum IS NOT NULL
		ORDER BY GroupName, PeriodNum
	END
	ELSE IF (@dids IS NOT NULL AND @gids IS NULL) OR @rptlevel = 3 -- report by driver
	BEGIN
	INSERT INTO @Results
		EXEC dbo.proc_Report_Trend_Driver
	  				@dids = @dids,
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
		WHERE DriverId IS NOT NULL AND GroupId IS NULL AND PeriodNum IS NOT NULL
		ORDER BY DisplayName, PeriodNum
	END
	ELSE
	BEGIN
	INSERT INTO @Results
		EXEC dbo.proc_Report_Trend_DriverFleet
	  				@dids = @dids,
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
		WHERE DriverId IS NULL AND GroupId IS NULL AND PeriodNum IS NOT NULL
		ORDER BY PeriodNum
	END


GO
