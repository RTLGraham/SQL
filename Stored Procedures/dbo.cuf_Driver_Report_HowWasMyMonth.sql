SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_Driver_Report_HowWasMyMonth]
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
--SET @edate = '2020-03-23 23:59'


	IF OBJECT_ID('dbo.DriverMobileActivity') IS NOT NULL 
	BEGIN 
		INSERT INTO dbo.DriverMobileActivity(DriverId,StoredProcedure,StartDate,EndDate,GuidParam,IntParam,StringParam)
		VALUES (@did, OBJECT_NAME(@@PROCID), @sdate, @edate, NULL, NULL, NULL)
	END

	DECLARE @uid UNIQUEIDENTIFIER,
			@rprtcfgid UNIQUEIDENTIFIER
	
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

	SELECT TOP 1 @uid = u.UserID
	FROM dbo.[User] u
	INNER JOIN dbo.Customer c ON c.CustomerId = u.CustomerID
	INNER JOIN dbo.CustomerDriver cd ON cd.CustomerId = c.CustomerId
	WHERE cd.DriverId = @did
	  AND cd.Archived = 0
	  AND cd.EndDate IS NULL
	  AND u.Archived = 0	

	SELECT @rprtcfgid = cp.Value
	FROM dbo.CustomerPreference cp
	INNER JOIN dbo.Customer c ON c.CustomerId = cp.CustomerID
	INNER JOIN dbo.CustomerDriver cd ON cd.CustomerId = c.CustomerId
	WHERE cd.DriverId = @did
	  AND cd.Archived = 0
	  AND cd.EndDate IS NULL
	  AND cp.NameID = 3002 -- Driver Individual Report Config

	--IF @did = N'84005F46-4E0C-4DF9-802A-56CD6DB27EE3'
	--	SET @rprtcfgid = N'A5BB3638-BDB5-40BD-9A38-AD9C20378F0F'	  

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
	    @groupBy = 3 -- int

		SELECT *
		FROM @data

	SELECT	WeekStartDate AS MonthStartDate, 
			Safety,
			dbo.GYRColourConfig(Safety, 15, @rprtcfgid) AS SafetyColour,
			Efficiency,
			dbo.GYRColourConfig(Efficiency, 14, @rprtcfgid) AS EfficiencyColour,

			CASE WHEN dbo.GYRColourConfig(Rop, 9, @rprtcfgid) != 'Blue' 
				THEN ROUND((ISNULL(Rop,0)) * TotalDrivingDistance / 1000, 0) 
				ELSE NULL
			END AS Rops,
			CASE WHEN dbo.GYRColourConfig(Rop, 9, @rprtcfgid) != 'Blue' 
				--THEN dbo.GYRColourConfig(Rop, 9, @rprtcfgid)
				THEN CASE WHEN ROUND((ISNULL(Rop,0)) * TotalDrivingDistance / 1000, 0) > 0 
						THEN 'Red' 
						ELSE dbo.GYRColourConfig(Rop, 9, @rprtcfgid)
					END
			END AS RopsColour,

			CASE WHEN dbo.GYRColourConfig(Rop2, 41, @rprtcfgid) != 'Blue' 
				THEN ROUND((ISNULL(Rop2,0)) * TotalDrivingDistance / 1000, 0) 
				ELSE NULL
			END AS Rops2,
			CASE WHEN dbo.GYRColourConfig(Rop2, 41, @rprtcfgid) != 'Blue' 
				--dbo.GYRColourConfig(Rop2, 41, @rprtcfgid)
				THEN CASE WHEN ROUND((ISNULL(Rop2,0)) * TotalDrivingDistance / 1000, 0) > 0 
						THEN 'Red' 
						ELSE dbo.GYRColourConfig(Rop2, 41, @rprtcfgid)
					END
				ELSE NULL
			END AS Rops2Colour
	FROM @data
	ORDER BY WeekStartDate


GO
