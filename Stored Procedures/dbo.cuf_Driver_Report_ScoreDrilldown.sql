SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Driver_Report_ScoreDrilldown]
(
	@uid UNIQUEIDENTIFIER,
	@configid UNIQUEIDENTIFIER,
	@dids VARCHAR(MAX),
	@sdate datetime,
	@edate datetime,
	@routeid INT = NULL,
	@vehicletypeid INT = NULL,
	@drilldown TINYINT
)
AS
--DECLARE	@dids varchar(max),
--	@sdate datetime,
--	@edate datetime,
--	@routeId int,
--	@vehicleTypeId int,
--	@uid uniqueidentifier,
--	@configId UNIQUEIDENTIFIER
--	
--SET @dids = N'54434FB9-8594-42A4-A695-970A1BE1B03E,AB0B496F-0659-495D-AD3D-EB5274BDC73C,B8706BAA-802A-4D6F-AD48-2483EB3F1440'
--SET @vehicletypeid = NULL
--SET @routeid = NULL
--SET	@sdate = '2011-10-16 10:00'
--SET	@edate = '2012-03-10 17:00'
--SET	@uid = N'C21039E7-58BE-4748-9A92-9AAB74AED58E'
--SET	@configid = N'77C80BDB-5827-4C5E-BBF4-06F36ACB47D6'

	DECLARE @gids VARCHAR(MAX)
	SET @gids = NULL
	
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
		CoastInGear FLOAT, 
		CruiseTopGearRatio FLOAT,
		Idle FLOAT, 
		EngineServiceBrake FLOAT, 
		OverRevWithoutFuel FLOAT, 
		Rop FLOAT, 
		OverSpeed FLOAT, 
		IVHOverSpeed FLOAT, 
		CoastOutOfGear FLOAT, 
		HarshBraking FLOAT, 
		FuelEcon FLOAT,
		TotalFuel FLOAT,
		Pto FLOAT, 
		Co2 FLOAT, 
		Acceleration FLOAT, 
		Braking FLOAT, 
		Cornering FLOAT,
		
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
		
		-- Colour columns corresponding to data columns above
		SweetSpotColour VARCHAR(MAX),
		OverRevWithFuelColour VARCHAR(MAX),
		TopGearColour VARCHAR(MAX),
		CruiseColour VARCHAR(MAX),
		CoastInGearColour VARCHAR(MAX),
		CruiseTopGearRatioColour VARCHAR(MAX),
		IdleColour VARCHAR(MAX),
		EngineServiceBrakeColour VARCHAR(MAX),
		OverRevWithoutFuelColour VARCHAR(MAX),
		RopColour VARCHAR(MAX),
		OverSpeedColour VARCHAR(MAX),
		IVHOverSpeedColour VARCHAR(MAX),
		CoastOutOfGearColour VARCHAR(MAX),
		HarshBrakingColour VARCHAR(MAX),
		FuelEconColour VARCHAR(MAX),
		AccelerationColour VARCHAR(MAX),
		BrakingColour VARCHAR(MAX),
		CorneringColour VARCHAR(MAX),
		EfficiencyColour VARCHAR(MAX),
		SafetyColour VARCHAR(MAX),
		OverRevCountColour VARCHAR(MAX)
	)

	INSERT INTO @Results
	EXEC dbo.proc_Report_Trend_Driver
	  				@dids = @dids,
                    @gids = @gids,
                    @sdate = @sdate,
                    @edate = @edate,
                    @routeid = @routeid,
                    @vehicletypeid = @vehicleTypeId,
                    @uid = @uid,
                    @rprtcfgid = @configId,
                    @drilldown = @drilldown,
                    @calendar = 1;
                    
	SELECT *
	FROM @Results
	WHERE DriverId IS NOT NULL AND GroupId IS NULL AND PeriodNum IS NOT NULL
	ORDER BY DisplayName, PeriodNum

GO
