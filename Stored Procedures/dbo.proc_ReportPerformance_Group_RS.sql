SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dmitrijs Jurins>
-- Create date: <2011-07-25>
-- Description:	<Individual Performance Report DataView>
-- =============================================
CREATE PROCEDURE [dbo].[proc_ReportPerformance_Group_RS]
	@gids varchar(max), 
	@uid UNIQUEIDENTIFIER,
	@configid UNIQUEIDENTIFIER,
	@isDriver BIT,
	@sdate datetime,
	@edate datetime
AS
BEGIN
--	DECLARE @gids varchar(max), 
--			@uid UNIQUEIDENTIFIER,
--			@configid UNIQUEIDENTIFIER,
--			@isDriver BIT,
--			@sdate datetime,
--			@edate datetime
--	All driver groups: N'DE3AF4C5-C63C-4B9F-BE97-0AAAA6D43CF4,DB31D258-16A0-4902-9192-1CD39B2F7364,D76DEFE8-8061-4834-BB31-493F299B4DDA,358AB936-67E5-4F3E-90B6-4F6EA4D7D34A,CA90D055-9EC6-427B-98EA-7600A5FD70BB'
--	All vehicle groups: N'CE04C50D-EB69-43EA-8E69-0E371242DDF3,629B7E57-93FD-48A7-9450-68DC41CF34E0,897D67BB-8C17-45C1-BDFB-933F10C58913,C030D59D-5DB3-40F8-8666-DB6FC2E611A5,B1D1EC14-48C8-4DC0-9E71-F03758D6D367'
	
--	SET @isDriver = 1
--	SET @gids = N'23F2C6D1-F93E-4733-BAE2-7BE779B0BD75'
--	SET @sdate = '2011-11-01 00:00:00'
--	SET @edate = '2011-11-08 23:59:59'
--	SET @uid = N'550D4B75-6764-4FBC-B8A6-010F19452062'
--	SET @configid = N'3FED49AA-15C3-4875-A980-D252A6DAEF80'	
	
--	SET @isDriver = 0	
--	SET @gids = N'CE04C50D-EB69-43EA-8E69-0E371242DDF3,629B7E57-93FD-48A7-9450-68DC41CF34E0'
--	SET @uid = N'FD7BB89A-A486-438E-BF85-0E199E8BD243'
--	SET @configid = N'3FED49AA-15C3-4875-A980-D252A6DAEF80'
--	SET @sdate = '2011-06-01 00:00'
--	SET @edate = '2011-06-30 23:59'
	
	DECLARE @gtypeid INT
	
	IF @isDriver = 1
	BEGIN
		SET @gtypeid = 2
	END
	ELSE 
	BEGIN 
		SET @gtypeid = 1
	END
	
	DECLARE @results TABLE(VehicleId UNIQUEIDENTIFIER,Registration NVARCHAR(MAX),DriverId UNIQUEIDENTIFIER,DriverName NVARCHAR(MAX),GroupId UNIQUEIDENTIFIER,GroupName NVARCHAR(MAX),SweetSpot FLOAT,OverRevWithFuel FLOAT,TopGear FLOAT,Cruise FLOAT,CoastInGear FLOAT,Idle FLOAT,TotalTime FLOAT,ServiceBrakeUsage FLOAT,EngineServiceBrake FLOAT,OverRevWithoutFuel FLOAT,Rop FLOAT,OverSpeed FLOAT,CoastOutOfGear FLOAT,HarshBraking FLOAT,TotalDrivingDistance FLOAT,FuelEcon FLOAT,Pto FLOAT,Co2 FLOAT,CruiseTopGearRatio FLOAT,Efficiency FLOAT,Safety FLOAT,sdate DATETIME,edate DATETIME,CreationDateTime DATETIME,ClosureDateTime DATETIME,DistanceUnit  NVARCHAR(MAX),FuelUnit NVARCHAR(MAX),Co2Unit NVARCHAR(MAX),IdleColour NVARCHAR(MAX),SweetSpotColour NVARCHAR(MAX),OverRevWithFuelColour NVARCHAR(MAX),TopgearColour NVARCHAR(MAX),CruiseColour NVARCHAR(MAX),CoastInGearColour NVARCHAR(MAX),KPLColour NVARCHAR(MAX),EfficiencyColour NVARCHAR(MAX),SafetyColour NVARCHAR(MAX),EngineServiceBrakeColour NVARCHAR(MAX),OverRevWithoutFuelColour NVARCHAR(MAX),RopColour NVARCHAR(MAX),TimeOverSpeedColour NVARCHAR(MAX),TimeOutOfGearCoastingColour NVARCHAR(MAX),HarshBrakingColour NVARCHAR(MAX),CruiseTopGearRatioColour NVARCHAR(MAX))
	
	INSERT INTO @results( VehicleId ,Registration ,DriverId ,DriverName ,GroupId ,GroupName ,SweetSpot ,OverRevWithFuel ,TopGear ,Cruise ,CoastInGear ,Idle ,TotalTime ,ServiceBrakeUsage ,EngineServiceBrake ,OverRevWithoutFuel ,Rop ,OverSpeed ,CoastOutOfGear ,HarshBraking ,TotalDrivingDistance ,FuelEcon ,Pto ,Co2 ,CruiseTopGearRatio ,Efficiency ,Safety ,sdate ,edate ,CreationDateTime ,ClosureDateTime ,DistanceUnit ,FuelUnit ,Co2Unit ,IdleColour ,SweetSpotColour ,OverRevWithFuelColour ,TopgearColour ,CruiseColour ,CoastInGearColour ,KPLColour ,EfficiencyColour ,SafetyColour ,EngineServiceBrakeColour ,OverRevWithoutFuelColour ,RopColour ,TimeOverSpeedColour ,TimeOutOfGearCoastingColour ,HarshBrakingColour ,CruiseTopGearRatioColour)
	EXECUTE [dbo].[proc_ReportPerformance_Group] @gids,@gtypeid,NULL,@sdate,@edate,@uid,@configid

	SELECT 
		CASE WHEN r2.VehicleId IS NOT NULL THEN r2.Registration ELSE dbo.FormatDriverName(r2.DriverName) END AS AssetName,
		r2.Efficiency AS AssetScore,
		r2.TotalDrivingDistance AS AssetDistance,
		r2.SweetSpot * 100 AS AssetSweetSpot,
		r2.Idle * 100 AS AssetIdle,
		r2.OverRevWithFuel * 100 AS AssetOverRev,
		r2.Cruise * 100 AS AssetCruise,
		r2.EngineServiceBrake * 100 AS AssetESBrake,
		CEILING(r2.HarshBraking) AS AssetHarshBrake,
		r2.CoastInGear * 100 AS AssetCoastInGear,
		r2.OverSpeed * 100 AS AssetOverSpeed,
		CEILING(r2.Rop) AS AssetROP,
		r2.OverRevWithoutFuel * 100 AS AssetOverRevWithoutFuel,
		r2.Pto * 100 AS AssetPTO,
		r2.FuelEcon AS AssetFuelEcon,
		
		r2.EfficiencyColour AS AssetScoreColour,
		r2.SweetSpotColour AS AssetSweetSpotColour,
		r2.IdleColour AS AssetIdleColour,
		r2.OverRevWithFuelColour AS AssetOverRevColour,
		r2.CruiseColour AS AssetCruiseColour,
		r2.EngineServiceBrakeColour AS AssetESBrakeColour,
		r2.HarshBrakingColour AS AssetHarshBrakeColour,
		r2.CoastInGearColour AS AssetCoastInGearColour,
		
		r3.Efficiency AS TotalScore,
		r3.TotalDrivingDistance AS TotalDistance,
		r3.SweetSpot * 100 AS TotalSweetSpot,
		r3.Idle * 100 AS TotalIdle,
		r3.OverRevWithFuel * 100 AS TotalOverRev,
		r3.Cruise * 100 AS TotalCruise,
		r3.EngineServiceBrake * 100 AS TotalESBrake,
		CEILING(r3.HarshBraking) AS TotalHarshBrake,
		r3.CoastInGear * 100 AS TotalCoastInGear,

		r3.EfficiencyColour AS TotalScoreColour,
		r3.SweetSpotColour AS TotalSweetSpotColour,
		r3.IdleColour AS TotalIdleColour,
		r3.OverRevWithFuelColour AS TotalOverRevColour,
		r3.CruiseColour AS TotalCruiseColour,
		r3.EngineServiceBrakeColour AS TotalESBrakeColour,
		r3.HarshBrakingColour AS TotalHarshBrakeColour,
		r3.CoastInGearColour AS TotalCoastInGearColour,
		
		r3.DistanceUnit AS DistanceUnit,
		@sdate AS sdate,
		@edate AS edate
	FROM @results r2
		INNER JOIN @results r3 ON r3.VehicleId IS NULL AND r3.DriverId IS NULL AND r3.GroupId IS NULL
	WHERE (r2.VehicleId IS NOT NULL OR r2.DriverId IS NOT NULL)
	ORDER BY r2.Efficiency ASC
END

GO
