SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dmitrijs Jurins>
-- Create date: <2011-07-25>
-- Description:	<Individual Performance Report DataView>
-- =============================================
CREATE PROCEDURE [dbo].[proc_ReportPerformance_Filter_RS]
	@gids VARCHAR(MAX), 
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER,
	@isDriver BIT,
	@sdate DATETIME,
	@edate DATETIME,
	@ScoreFrom FLOAT,
	@ScoreTo FLOAT,
	@SweetSpotFrom FLOAT,
	@SweetSpotTo FLOAT,
	@IdleFrom FLOAT,
	@IdleTo FLOAT,
	@OverRevFrom FLOAT,
	@OverRevTo FLOAT,
	@CruiseFrom FLOAT,
	@CruiseTo FLOAT,
	@ESBrakeFrom FLOAT,
	@ESBrakeTo FLOAT,
	@HarshBrakeFrom FLOAT,
	@HarshBrakeTo FLOAT,
	@CoastInGearFrom FLOAT,
	@CoastInGearTo FLOAT,
	@OverSpeedFrom FLOAT,
	@OverSpeedTo FLOAT,
	@ROPFrom FLOAT,
	@ROPTo FLOAT,
	@OverRevWithoutFuelFrom FLOAT,
	@OverRevWithoutFuelTo FLOAT,
	@PTOFrom FLOAT,
	@PTOTo FLOAT,
	@FuelEconFrom FLOAT,
	@FuelEconTo FLOAT
AS
BEGIN
--	DECLARE @gids varchar(max), 
--			@uid UNIQUEIDENTIFIER,
--			@rprtcfgid UNIQUEIDENTIFIER,
--			@isDriver BIT,
--			@sdate datetime,
--			@edate DATETIME,
--			@ScoreFrom FLOAT,
--			@ScoreTo FLOAT,
--			@SweetSpotFrom FLOAT,
--			@SweetSpotTo FLOAT,
--			@IdleFrom FLOAT,
--			@IdleTo FLOAT,
--			@OverRevFrom FLOAT,
--			@OverRevTo FLOAT,
--			@CruiseFrom FLOAT,
--			@CruiseTo FLOAT,
--			@ESBrakeFrom FLOAT,
--			@ESBrakeTo FLOAT,
--			@HarshBrakeFrom FLOAT,
--			@HarshBrakeTo FLOAT,
--			@CoastInGearFrom FLOAT,
--			@CoastInGearTo FLOAT,
--			@OverSpeedFrom FLOAT,
--			@OverSpeedTo FLOAT,
--			@ROPFrom FLOAT,
--			@ROPTo FLOAT,
--			@OverRevWithoutFuelFrom FLOAT,
--			@OverRevWithoutFuelTo FLOAT,
--			@PTOFrom FLOAT,
--			@PTOTo FLOAT,
--			@FuelEconFrom FLOAT,
--			@FuelEconTo FLOAT
			
--	SET @isDriver = 1
--	SET @gids = N'DB31D258-16A0-4902-9192-1CD39B2F7364'
--	SET @sdate = '2011-04-01 00:00:00'
--	SET @edate = '2011-04-08 23:59:59'
--	SET @uid = N'4C0A0D44-0685-4292-9087-F32E03F10134'
--	SET @rprtcfgid = N'3FED49AA-15C3-4875-A980-D252A6DAEF80'
--	SET @ScoreFrom = NULL
--	SET	@ScoreTo = NULL
--	SET	@SweetSpotFrom = NULL
--	SET	@SweetSpotTo = NULL
--	SET	@IdleFrom = NULL
--	SET	@IdleTo = NULL
--	SET	@OverRevFrom = NULL
--	SET	@OverRevTo = NULL
--	SET	@CruiseFrom = NULL
--	SET	@CruiseTo = NULL
--	SET	@ESBrakeFrom = NULL
--	SET	@ESBrakeTo = NULL
--	SET	@HarshBrakeFrom = NULL
--	SET	@HarshBrakeTo = NULL
--	SET	@CoastInGearFrom = NULL
--	SET	@CoastInGearTo = NULL
--	SET	@OverSpeedFrom = NULL
--	SET	@OverSpeedTo = NULL
--	SET	@ROPFrom = NULL
--	SET	@ROPTo = NULL
--	SET	@OverRevWithoutFuelFrom = NULL
--	SET	@OverRevWithoutFuelTo = NULL
--	SET	@PTOFrom = NULL
--	SET	@PTOTo = NULL
--	SET	@FuelEconFrom = NULL
--	SET	@FuelEconTo = NULL	
	
--	SET @isDriver = 0	
--	SET @gids = N'CE04C50D-EB69-43EA-8E69-0E371242DDF3,629B7E57-93FD-48A7-9450-68DC41CF34E0'
--	SET @uid = N'FD7BB89A-A486-438E-BF85-0E199E8BD243'
--	SET @rprtcfgid = N'3FED49AA-15C3-4875-A980-D252A6DAEF80'
--	SET @sdate = '2011-06-01 00:00'
--	SET @edate = '2011-06-30 23:59'
	
	DECLARE @Results TABLE (
			VehicleId UNIQUEIDENTIFIER,
			Registration VARCHAR(20),
			DriverId UNIQUEIDENTIFIER,
			DriverName VARCHAR(100),
			GroupId UNIQUEIDENTIFIER,
			GroupName VARCHAR(100),
			SweetSpot FLOAT,
			OverRevWithFuel FLOAT,
			TopGear FLOAT,
			Cruise FLOAT,
			CoastInGear FLOAT,
			Idle FLOAT,
			TotalTime FLOAT,
			ServiceBrakeUsage FLOAT,
			EngineServiceBrake FLOAT,
			OverRevWithoutFuel FLOAT,
			Rop FLOAT,
			OverSpeed FLOAT,
			CoastOutOfGear FLOAT,
			HarshBraking FLOAT,
			TotalDrivingDistance FLOAT,
			FuelEcon FLOAT,
			Pto FLOAT,
			Co2 FLOAT,
			CruiseTopGearRatio FLOAT,
			Efficiency FLOAT,
			SAFETY FLOAT,
			sdate DATETIME,
			edate DATETIME,
			CreationDateTime DATETIME,
			ClosureDateTime DATETIME,
			DistanceUnit VARCHAR(20),
			FuelUnit VARCHAR(20),
			Co2Unit VARCHAR(20),
			IdleColour VARCHAR(10),
			SweetSpotColour VARCHAR(10),
			OverRevWithFuelColour VARCHAR(10),
			TopgearColour VARCHAR(10),
			CruiseColour VARCHAR(10),
			CoastInGearColour VARCHAR(10),
			KPLColour VARCHAR(10),
			EfficiencyColour VARCHAR(10),
			SafetyColour VARCHAR(10),
			EngineServiceBrakeColour VARCHAR(10),
			OverRevWithoutFuelColour VARCHAR(10),
			RopColour VARCHAR(10),
			TimeOverSpeedColour VARCHAR(10),
			TimeOutOfGearCoastingColour VARCHAR(10),
			HarshBrakingColour VARCHAR(10),
			CruiseTopGearRatioColour VARCHAR(10)
			)
	
	IF @IsDriver = 1
	BEGIN -- Report being run for Drivers
		INSERT INTO @Results
		EXEC proc_ReportPerformance_Group_Driver @gids, @sdate, @edate, @uid, @rprtcfgid
		SELECT dbo.FormatDriverName(DriverName) AS AssetName,
			Efficiency AS AssetScore,
			TotalDrivingDistance AS AssetDistance,
			SweetSpot * 100 AS AssetSweetSpot,
			Idle * 100 AS AssetIdle,
			OverRevWithFuel * 100 AS AssetOverRev,
			Cruise * 100 AS AssetCruise,
			EngineServiceBrake * 100 AS AssetESBrake,
			CEILING(HarshBraking) AS AssetHarshBrake,
			CoastInGear * 100 AS AssetCoastInGear,
			OverSpeed * 100 AS AssetOverSpeed,
			CEILING(Rop) AS AssetROP,
			OverRevWithoutFuel * 100 AS AssetOverRevWithoutFuel,
			Pto * 100 AS AssetPTO,
			FuelEcon AS AssetFuelEcon,
			
			EfficiencyColour AS AssetScoreColour,
			SweetSpotColour AS AssetSweetSpotColour,
			IdleColour AS AssetIdleColour,
			OverRevWithFuelColour AS AssetOverRevColour,
			CruiseColour AS AssetCruiseColour,
			EngineServiceBrakeColour AS AssetESBrakeColour,
			HarshBrakingColour AS AssetHarshBrakeColour,
			CoastInGearColour AS AssetCoastInGearColour,
			DistanceUnit,

			@sdate AS sdate,
			@edate AS edate
		FROM @Results
		
		WHERE	
			Efficiency BETWEEN ISNULL(@ScoreFrom, 0) AND ISNULL(@ScoreTo, 100) AND
			SweetSpot * 100 BETWEEN ISNULL(@SweetSpotFrom, 0) AND ISNULL(@SweetSpotTo, 100) AND
			Idle * 100 BETWEEN ISNULL(@IdleFrom, 0) AND ISNULL(@IdleTo, 100) AND
			OverRevWithFuel * 100 BETWEEN ISNULL(@OverRevFrom, 0) AND ISNULL(@OverRevTo, 100) AND
			Cruise * 100 BETWEEN ISNULL(@CruiseFrom, 0) AND ISNULL(@CruiseTo, 100) AND
			EngineServiceBrake * 100 BETWEEN ISNULL(@ESBrakeFrom, 0) AND ISNULL(@ESBrakeTo, 100) AND
			CEILING(HarshBraking) BETWEEN ISNULL(@HarshBrakeFrom, 0) AND ISNULL(@HarshBrakeTo, 100) AND
			CoastInGear * 100 BETWEEN ISNULL(@CoastInGearFrom, 0) AND ISNULL(@CoastInGearTo, 100) AND
			OverSpeed * 100 BETWEEN ISNULL(@OverSpeedFrom, 0) AND ISNULL(@OverSpeedTo, 100) AND
			CEILING(Rop) BETWEEN ISNULL(@ROPFrom, 0) AND ISNULL(@ROPTo, 100) AND
			OverRevWithoutFuel * 100 BETWEEN ISNULL(@OverRevWithoutFuelFrom, 0) AND ISNULL(@OverRevWithoutFuelTo, 100) AND
			Pto * 100 BETWEEN ISNULL(@PTOFrom, 0) AND ISNULL(@PTOTo, 100) AND
			FuelEcon BETWEEN ISNULL(@FuelEconFrom, 0) AND ISNULL(@FuelEconTo, 100)
			AND DriverName IS NOT NULL
		
		ORDER BY Efficiency ASC
	
	END	
	ELSE -- Report being run for Vehicles
	BEGIN
	
		INSERT INTO @Results
		EXEC proc_ReportPerformance_Group_Vehicle @gids, @sdate, @edate, @uid, @rprtcfgid
		
		SELECT Registration AS AssetName,
			Efficiency AS AssetScore,
			TotalDrivingDistance AS AssetDistance,
			SweetSpot * 100 AS AssetSweetSpot,
			Idle * 100 AS AssetIdle,
			OverRevWithFuel * 100 AS AssetOverRev,
			Cruise * 100 AS AssetCruise,
			EngineServiceBrake * 100 AS AssetESBrake,
			CEILING(HarshBraking) AS AssetHarshBrake,
			CoastInGear * 100 AS AssetCoastInGear,
			OverSpeed * 100 AS AssetOverSpeed,
			CEILING(Rop) AS AssetROP,
			OverRevWithoutFuel * 100 AS AssetOverRevWithoutFuel,
			Pto * 100 AS AssetPTO,
			FuelEcon AS AssetFuelEcon,
			
			EfficiencyColour AS AssetScoreColour,
			SweetSpotColour AS AssetSweetSpotColour,
			IdleColour AS AssetIdleColour,
			OverRevWithFuelColour AS AssetOverRevColour,
			CruiseColour AS AssetCruiseColour,
			EngineServiceBrakeColour AS AssetESBrakeColour,
			HarshBrakingColour AS AssetHarshBrakeColour,
			CoastInGearColour AS AssetCoastInGearColour,
			DistanceUnit,

			@sdate AS sdate,
			@edate AS edate
		FROM @Results
		
		WHERE	
			Efficiency BETWEEN ISNULL(@ScoreFrom, 0) AND ISNULL(@ScoreTo, 100) AND
			SweetSpot * 100 BETWEEN ISNULL(@SweetSpotFrom, 0) AND ISNULL(@SweetSpotTo, 100) AND
			Idle * 100 BETWEEN ISNULL(@IdleFrom, 0) AND ISNULL(@IdleTo, 100) AND
			OverRevWithFuel * 100 BETWEEN ISNULL(@OverRevFrom, 0) AND ISNULL(@OverRevTo, 100) AND
			Cruise * 100 BETWEEN ISNULL(@CruiseFrom, 0) AND ISNULL(@CruiseTo, 100) AND
			EngineServiceBrake * 100 BETWEEN ISNULL(@ESBrakeFrom, 0) AND ISNULL(@ESBrakeTo, 100) AND
			CEILING(HarshBraking) BETWEEN ISNULL(@HarshBrakeFrom, 0) AND ISNULL(@HarshBrakeTo, 100) AND
			CoastInGear * 100 BETWEEN ISNULL(@CoastInGearFrom, 0) AND ISNULL(@CoastInGearTo, 100) AND
			OverSpeed * 100 BETWEEN ISNULL(@OverSpeedFrom, 0) AND ISNULL(@OverSpeedTo, 100) AND
			CEILING(Rop) BETWEEN ISNULL(@ROPFrom, 0) AND ISNULL(@ROPTo, 100) AND
			OverRevWithoutFuel * 100 BETWEEN ISNULL(@OverRevWithoutFuelFrom, 0) AND ISNULL(@OverRevWithoutFuelTo, 100) AND
			Pto * 100 BETWEEN ISNULL(@PTOFrom, 0) AND ISNULL(@PTOTo, 100) AND
			FuelEcon BETWEEN ISNULL(@FuelEconFrom, 0) AND ISNULL(@FuelEconTo, 100)
			AND Registration IS NOT NULL 

		
		ORDER BY Efficiency ASC

	END
	
END

GO
