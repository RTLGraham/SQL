SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Driver_Report_LeagueTable]
(
	@did uniqueidentifier
)
AS

	IF OBJECT_ID('dbo.DriverMobileActivity') IS NOT NULL 
	BEGIN 
		INSERT INTO dbo.DriverMobileActivity(DriverId,StoredProcedure,StartDate,EndDate,GuidParam,IntParam,StringParam)
		VALUES (@did, OBJECT_NAME(@@PROCID), NULL, NULL, NULL, NULL, NULL)
	END
	--DECLARE	@did uniqueidentifier
	--SET	@did = N'13D845DA-BD4F-46CA-97B4-0C3D615D3681'

	DECLARE @uid UNIQUEIDENTIFIER,
			@rprtcfgid UNIQUEIDENTIFIER,
			@today DATETIME,
			@cwsdate DATETIME,
			@cwedate DATETIME,
			@pwsdate DATETIME,
			@pwedate DATETIME,
			@groupid UNIQUEIDENTIFIER,
			@groupname NVARCHAR(MAX),
			@dids NVARCHAR(MAX)

	DECLARE @output TABLE
    (
		SafetyPosition INT,
		EfficiencyPosition INT,
		TemperaturePosition INT,
		Name NVARCHAR(MAX),
		IsMe BIT,
		SafetyScore FLOAT,
		EfficiencyScore FLOAT,
		TemperatureScore FLOAT,
		SafetyProgress BIT,
		EfficiencyProgress BIT,
		TemperatureProgress BIT,
		SafetyPositionPrevious INT,
		EfficiencyPositionPrevious INT,
		SafetyPositionProgress BIT,
		EfficiencyPositionProgress BIT,
		TemperaturePositionProgress BIT
	)
    IF (1=0)
	begin
    SET FMTONLY OFF;
	SELECT SafetyPosition ,
           EfficiencyPosition ,
           TemperaturePosition ,
           Name ,
           IsMe ,
           SafetyScore ,
           EfficiencyScore ,
           TemperatureScore ,
           SafetyProgress ,
           EfficiencyProgress ,
           TemperatureProgress,
		   SafetyPositionProgress,
		   EfficiencyPositionProgress,
		   TemperaturePositionProgress,
		   'This Week' AS PeriodText,
		   GETDATE() AS StartDate,
		  GETDATE() AS EndDate
	FROM @output
	END

	ELSE
	BEGIN

	DECLARE @currweek TABLE
    (
		VehicleId UNIQUEIDENTIFIER,	
		Registration VARCHAR(MAX),
		VehicleTypeID INT,
		DriverId UNIQUEIDENTIFIER,
 		DisplayName VARCHAR(MAX),
 		DriverName VARCHAR(MAX), 
 		FirstName VARCHAR(MAX),
 		Surname VARCHAR(MAX),
 		MiddleNames VARCHAR(MAX),
 		Number VARCHAR(MAX),
 		NumberAlternate VARCHAR(MAX),
 		NumberAlternate2 VARCHAR(MAX),
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

		SpeedGaugeComponent FLOAT,

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
		SweetSpotTimeComponent FLOAT,
		OverRevTimeComponent FLOAT,
		TopGearTimeComponent FLOAT,
		FatigueComponent FLOAT,
		DistractionComponent FLOAT,

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
		Currency NVARCHAR(10),
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

		SpeedGaugeColour VARCHAR(MAX),
		SpeedGaugeMix BIT,

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
		OverspeedCountMix TINYINT,
		OverspeedHighCountColour VARCHAR(MAX),
		OverspeedHighCountMix TINYINT,
		StabilityControlColour VARCHAR(MAX),
		StabilityControlMix TINYINT,
		CollisionWarningLowColour VARCHAR(MAX),
		CollisionWarningLowMix TINYINT,
		CollisionWarningMedColour VARCHAR(MAX),
		CollisionWarningMedMix TINYINT,
		CollisionWarningHighColour VARCHAR(MAX),
		CollisionWarningHighMix TINYINT,
		LaneDepartureDisableColour VARCHAR(MAX),
		LaneDepartureDisableMix TINYINT,
		LaneDepartureLeftRightColour VARCHAR(MAX),
		LaneDepartureLeftRightMix TINYINT,
		SweetSpotTimeColour VARCHAR(MAX),
		SweetSpotTimeMix TINYINT,
		OverRevTimeColour VARCHAR(MAX),
		OverRevTimeMix TINYINT,
		TopGearTimeColour VARCHAR(MAX),
		TopGearTimeMix TINYINT,
		FatigueColour VARCHAR(MAX),
		FatigueMix TINYINT,
		DistractionColour VARCHAR(MAX),
		DistractionMix TINYINT
	)

	DECLARE @prevweek TABLE
    (
		VehicleId UNIQUEIDENTIFIER,	
		Registration VARCHAR(MAX),
		VehicleTypeID INT,
		DriverId UNIQUEIDENTIFIER,
 		DisplayName VARCHAR(MAX),
 		DriverName VARCHAR(MAX), 
 		FirstName VARCHAR(MAX),
 		Surname VARCHAR(MAX),
 		MiddleNames VARCHAR(MAX),
 		Number VARCHAR(MAX),
 		NumberAlternate VARCHAR(MAX),
 		NumberAlternate2 VARCHAR(MAX),
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

		SpeedGaugeComponent FLOAT,

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
		SweetSpotTimeComponent FLOAT,
		OverRevTimeComponent FLOAT,
		TopGearTimeComponent FLOAT,
		FatigueComponent FLOAT,
		DistractionComponent FLOAT,

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
		Currency NVARCHAR(10),
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

		SpeedGaugeColour VARCHAR(MAX),
		SpeedGaugeMix BIT,

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
		OverspeedCountMix TINYINT,
		OverspeedHighCountColour VARCHAR(MAX),
		OverspeedHighCountMix TINYINT,
		StabilityControlColour VARCHAR(MAX),
		StabilityControlMix TINYINT,
		CollisionWarningLowColour VARCHAR(MAX),
		CollisionWarningLowMix TINYINT,
		CollisionWarningMedColour VARCHAR(MAX),
		CollisionWarningMedMix TINYINT,
		CollisionWarningHighColour VARCHAR(MAX),
		CollisionWarningHighMix TINYINT,
		LaneDepartureDisableColour VARCHAR(MAX),
		LaneDepartureDisableMix TINYINT,
		LaneDepartureLeftRightColour VARCHAR(MAX),
		LaneDepartureLeftRightMix TINYINT,
		SweetSpotTimeColour VARCHAR(MAX),
		SweetSpotTimeMix TINYINT,
		OverRevTimeColour VARCHAR(MAX),
		OverRevTimeMix TINYINT,
		TopGearTimeColour VARCHAR(MAX),
		TopGearTimeMix TINYINT,
		FatigueColour VARCHAR(MAX),
		FatigueMix TINYINT,
		DistractionColour VARCHAR(MAX),
		DistractionMix TINYINT
	)

	-- Get default user for this customer to get units of measure etc (this needs to be changed to a proper default user)
	SELECT TOP 1 @uid = u.UserID
	FROM dbo.[User] u
	INNER JOIN dbo.Customer c ON c.CustomerId = u.CustomerID
	INNER JOIN dbo.CustomerDriver cd ON cd.CustomerId = c.CustomerId
	WHERE cd.DriverId = @did
	  AND cd.Archived = 0
	  AND cd.EndDate IS NULL	
	  AND u.Archived = 0

	-- Determine week start and end dates
	SET @today = GETUTCDATE()
	--SET @cwsdate = CAST(FLOOR(CAST(DATEADD(dd,(DATEPART(dw, @today) * -1) + 1, @today) AS FLOAT)) AS DATETIME) -- original calendar week method
	SET @cwsdate = CAST(FLOOR(CAST(DATEADD(dd, -6, @today) AS FLOAT)) AS DATETIME) -- change to a rolling 7 day week
	SET @cwedate = DATEADD(dd, 7, DATEADD(ss, -1, @cwsdate))
	SET @pwsdate = DATEADD(dd, -7, @cwsdate)
	SET @pwedate = DATEADD(dd, -7, @cwedate)

	-- Get default report configuration for the Driver Individual Report
	SELECT @rprtcfgid = cp.Value
	FROM dbo.CustomerPreference cp
	INNER JOIN dbo.Customer c ON c.CustomerId = cp.CustomerID
	INNER JOIN dbo.CustomerDriver cd ON cd.CustomerId = c.CustomerId
	WHERE cd.DriverId = @did
	  AND cd.Archived = 0
	  AND cd.EndDate IS NULL
	  AND cp.NameID = 3002 -- Driver Individual Report Config

	-- Identify the appropriate group for the driver and create a list of all drivers in the group
	-- Group identification needs to be changed - this is just a temporary random top 1 group selection
	SELECT TOP 1 @groupid = g.GroupId, @groupname = g.GroupName
	FROM dbo.[Group] g
	INNER JOIN dbo.GroupDetail gd ON gd.GroupId = g.GroupId
	WHERE g.GroupTypeId = 2
	  AND g.IsParameter = 0
	  AND g.Archived = 0
	  AND gd.EntityDataId = @did
	  AND g.IsPhysical = 1
	  
		IF @groupid IS NULL 
	BEGIN
		SET @dids = CAST(@did AS NVARCHAR(max))
	END	
	ELSE 
	BEGIN

	-- Create string of driver ids to use as parameter
	SET @dids = '' -- initialise the variable, so the first COALESCE is not skipped
	SELECT @dids = COALESCE(@dids + CAST(gd.EntityDataId AS NVARCHAR(MAX)) + ',', '')
	FROM dbo.GroupDetail gd
	INNER JOIN dbo.Driver d ON gd.EntityDataId = d.DriverId
	WHERE gd.GroupId = @groupid
	  AND d.Archived = 0
	SET @dids = LEFT(@dids, LEN(@dids) - 1)

	END	

	---- Populate data for the current week
	INSERT INTO @currweek
	EXEC dbo.proc_ReportByVehicleConfigId_USA @vids = NULL, -- varchar(max)
	    @dids = @dids, -- varchar(max)
	    @sdate = @cwsdate, -- datetime
	    @edate = @cwedate, -- datetime
	    @uid = @uid, -- uniqueidentifier
	    @rprtcfgid = @rprtcfgid -- uniqueidentifier

	---- Populate data for the previous week
	INSERT INTO @prevweek
	EXEC dbo.proc_ReportByVehicleConfigId_USA @vids = NULL, -- varchar(max)
	    @dids = @dids, -- varchar(max)
	    @sdate = @pwsdate, -- datetime
	    @edate = @pwedate, -- datetime
	    @uid = @uid, -- uniqueidentifier
	    @rprtcfgid = @rprtcfgid -- uniqueidentifier	
	
	-- Populate the output table for the drivers
	INSERT INTO @output (SafetyPosition, EfficiencyPosition, TemperaturePosition, Name, IsMe, SafetyScore, EfficiencyScore, TemperatureScore, SafetyProgress, EfficiencyProgress, TemperatureProgress, SafetyPositionPrevious, EfficiencyPositionPrevious, SafetyPositionProgress, EfficiencyPositionProgress, TemperaturePositionProgress)
	SELECT	ROW_NUMBER() OVER (ORDER BY cw.Safety DESC), 
			ROW_NUMBER() OVER (ORDER BY cw.Efficiency DESC), 
			NULL,
			CASE WHEN cw.DriverId = @did THEN cw.DriverName ELSE '*' END,
			CASE WHEN cw.DriverId = @did THEN 1 ELSE 0 END,
			cw.Safety,
			cw.Efficiency,
			NULL,
			CASE WHEN ROUND(cw.Safety,0) > ROUND(pw.Safety,0) THEN 1 ELSE CASE WHEN ROUND(cw.Safety,0) < ROUND(pw.Safety,0) THEN 0 ELSE NULL END END,
			CASE WHEN ROUND(cw.Efficiency,0) > ROUND(pw.Efficiency,0) THEN 1 ELSE CASE WHEN ROUND(cw.Efficiency,0) < ROUND(pw.Efficiency,0) THEN 0 ELSE NULL END END,
			NULL,	
					
			ROW_NUMBER() OVER (ORDER BY pw.Safety DESC), 
			ROW_NUMBER() OVER (ORDER BY pw.Efficiency DESC),
			
			CASE 
				WHEN ROW_NUMBER() OVER (ORDER BY cw.Safety DESC) > ROW_NUMBER() OVER (ORDER BY pw.Safety DESC) 
				THEN 0 
				ELSE CASE 
					WHEN ROW_NUMBER() OVER (ORDER BY cw.Safety DESC) < ROW_NUMBER() OVER (ORDER BY pw.Safety DESC) 
					THEN 1 
					ELSE NULL 
				END 
			END,
			CASE 
				WHEN ROW_NUMBER() OVER (ORDER BY cw.Efficiency DESC) > ROW_NUMBER() OVER (ORDER BY pw.Efficiency DESC) 
				THEN 0 
				ELSE CASE 
					WHEN ROW_NUMBER() OVER (ORDER BY cw.Efficiency DESC) < ROW_NUMBER() OVER (ORDER BY pw.Efficiency DESC) 
					THEN 1 
					ELSE NULL 
				END 
			END,
			NULL
	FROM @currweek cw
	LEFT JOIN @prevweek pw ON cw.DriverId = pw.DriverId AND pw.VehicleId IS NULL
	WHERE cw.DriverId IS NOT NULL	
	  AND cw.VehicleId IS NULL

	-- Populate the output table for the group
	INSERT INTO @output (SafetyPosition, EfficiencyPosition, TemperaturePosition, Name, IsMe, SafetyScore, EfficiencyScore, TemperatureScore, SafetyProgress, EfficiencyProgress, TemperatureProgress, SafetyPositionPrevious, EfficiencyPositionPrevious, SafetyPositionProgress, EfficiencyPositionProgress, TemperaturePositionProgress)
	SELECT	0, 
			0, 
			NULL,
			@groupname,
			0,
			cw.Safety,
			cw.Efficiency,
			NULL,
			CASE WHEN ROUND(cw.Safety,0) > ROUND(pw.Safety,0) THEN 1 ELSE CASE WHEN ROUND(cw.Safety,0) < ROUND(pw.Safety,0) THEN 0 ELSE NULL END END,
			CASE WHEN ROUND(cw.Efficiency,0) > ROUND(pw.Efficiency,0) THEN 1 ELSE CASE WHEN ROUND(cw.Efficiency,0) < ROUND(pw.Efficiency,0) THEN 0 ELSE NULL END END,
			NULL,
			0,
			0,
			0,
			0,
			NULL
	FROM @currweek cw
	CROSS JOIN @prevweek pw 
	WHERE cw.DriverId IS NULL	
	  AND cw.VehicleId IS NULL
	  AND pw.DriverId IS NULL
	  AND pw.VehicleId IS NULL	

	SELECT SafetyPosition ,
           EfficiencyPosition ,
           TemperaturePosition ,
           Name ,
           IsMe ,
           SafetyScore ,
           EfficiencyScore ,
           TemperatureScore ,
           SafetyProgress ,
           EfficiencyProgress ,
           TemperatureProgress,
		   SafetyPositionProgress,
		   EfficiencyPositionProgress,
		   TemperaturePositionProgress,
		   'This Week' AS PeriodText,
		   @cwsdate AS StartDate,
		   @cwedate AS EndDate
	FROM @output

END
GO
