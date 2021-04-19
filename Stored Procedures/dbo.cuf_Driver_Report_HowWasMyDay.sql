SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_Driver_Report_HowWasMyDay]
(
	@did uniqueidentifier,
	@sdate datetime,
	@edate datetime
)
AS

--	DECLARE	@did uniqueidentifier,
--			@sdate datetime,
--			@edate datetime
	
--SET @did = N'64844794-79A0-454B-999B-D2B30C33992A'
--SET @sdate = '2020-03-23 00:00'
--SET @edate = '2020-03-30 23:59'


	IF OBJECT_ID('dbo.DriverMobileActivity') IS NOT NULL 
	BEGIN 
		INSERT INTO dbo.DriverMobileActivity(DriverId,StoredProcedure,StartDate,EndDate,GuidParam,IntParam,StringParam)
		VALUES (@did, OBJECT_NAME(@@PROCID), @sdate, @edate, NULL, NULL, NULL)
	END

	DECLARE @uid UNIQUEIDENTIFIER,
			@rprtcfgid UNIQUEIDENTIFIER,
			@timezone VARCHAR(20),
			@distmult FLOAT,
			@diststr VARCHAR(10)

	DECLARE @output TABLE
    (
		Date DATETIME,
		SafetyScore FLOAT,
		SafetyColour VARCHAR(30),
		SafetyAlert BIT	,
		EfficiencyScore FLOAT,
		EfficiencyColour VARCHAR(30),
		EfficiencyAlert BIT,
		TemperatureScore FLOAT,
		TemperatureColour VARCHAR(30),
		TemperatureAlert BIT
	)

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

			SpeedGauge Float,

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

	SELECT @rprtcfgid = cp.Value
	FROM dbo.CustomerPreference cp
	INNER JOIN dbo.Customer c ON c.CustomerId = cp.CustomerID
	INNER JOIN dbo.CustomerDriver cd ON cd.CustomerId = c.CustomerId
	WHERE cd.DriverId = @did
	  AND cd.Archived = 0
	  AND cd.EndDate IS NULL
	  AND cp.NameID = 3002 -- Driver Individual Report Config
	
	-- The following code is a hack to get round the problem of identifying default user measurement parameters
	-- Identify a user for this customer that has the correct measurement definitions and use that as parameter to call stored procedures
	SELECT @distmult = ISNULL(cp.Value, 1)
	FROM dbo.CustomerPreference cp
	INNER JOIN dbo.CustomerDriver cd ON cd.CustomerId = cp.CustomerID
	WHERE cd.DriverId = @did
	  AND cp.NameID = 202
	  AND cd.Archived = 0
	  AND cd.EndDate IS NULL	
	  AND cp.Archived = 0

	SELECT @diststr = ISNULL(cp.Value, 'KM')
	FROM dbo.CustomerPreference cp
	INNER JOIN dbo.CustomerDriver cd ON cd.CustomerId = cp.CustomerID
	WHERE cd.DriverId = @did
	  AND cp.NameID = 203
	  AND cd.Archived = 0
	  AND cd.EndDate IS NULL	
	  AND cp.Archived = 0

	-- The above code no longer required as reporting data is now stored in local time, so use GMT by default
	SET @timezone = 'GMT Time'

	SELECT TOP 1 @uid = u.UserID
	FROM dbo.[User] u
	INNER JOIN dbo.UserPreference upmult ON upmult.UserID = u.UserID AND upmult.NameID = 202 AND upmult.Archived = 0 AND upmult.Value = @distmult
	INNER JOIN dbo.UserPreference upstr ON upstr.UserID = u.UserID AND upstr.NameID = 203 AND upstr.Archived = 0 AND upstr.Value = @diststr
	INNER JOIN dbo.UserPreference uptime ON uptime.UserID = u.UserID AND uptime.NameID = 600 AND uptime.Archived = 0 AND uptime.Value = @timezone
	INNER JOIN dbo.Customer c ON c.CustomerId = u.CustomerID
	INNER JOIN dbo.CustomerDriver cd ON cd.CustomerId = c.CustomerId
	WHERE cd.DriverId = @did
	  AND cd.Archived = 0
	  AND cd.EndDate IS NULL
	  AND u.Archived = 0	

	SET @sdate = dbo.TZ_ToUTC(@sdate,default,@uid)
	SET @edate = dbo.TZ_ToUTC(@edate,default,@uid)

	INSERT INTO @data
	EXEC dbo.proc_Report_Trend_DriverPlus 
		@dids = @did, -- varchar(max)
	    @gids = NULL, -- varchar(max)
	    @sdate = @sdate, -- datetime
	    @edate = @edate, -- datetime
	    @routeid = NULL, -- int
	    @vehicletypeid = NULL, -- int
	    @uid = @uid, -- uniqueidentifier
	    @rprtcfgid = @rprtcfgid, -- uniqueidentifier
	    @drilldown = 1, -- tinyint
	    @calendar = 1, -- tinyint
	    @groupBy = 1 -- int
	
	INSERT INTO @output (Date, SafetyScore, SafetyColour, EfficiencyScore, EfficiencyColour)
	SELECT	WeekStartDate, 
			Safety,
			dbo.GYRColourConfig(Safety, 15, @rprtcfgid),
			Efficiency,
			dbo.GYRColourConfig(Efficiency, 14, @rprtcfgid)
	FROM @data
	WHERE PeriodNum IS NOT NULL	
	  AND DriverId IS NOT NULL	
	
	SELECT Date ,
           SafetyScore ,
           SafetyColour ,
           SafetyAlert ,
           EfficiencyScore ,
           EfficiencyColour ,
           EfficiencyAlert ,
           TemperatureScore ,
           TemperatureColour ,
           TemperatureAlert
	FROM @output

GO
