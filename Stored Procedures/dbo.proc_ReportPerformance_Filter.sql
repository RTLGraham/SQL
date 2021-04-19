SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_ReportPerformance_Filter]
(
	@gids varchar(max), 
	@gtypeid INT,
	@depid INT = NULL,
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER
) 
AS

--DECLARE
--	@gids varchar(max), 
--	@gtypeid INT,
--	@depid INT,
--	@sdate datetime,
--	@edate datetime,
--	@uid UNIQUEIDENTIFIER,
--	@rprtcfgid UNIQUEIDENTIFIER
--	
--SET @gids = '23F2C6D1-F93E-4733-BAE2-7BE779B0BD75'
--SET	@gtypeid = 2
--SET @depid = NULL
--SET @sdate = '2011-11-24 00:00'
--SET @edate = '2011-11-30 23:59'
--SET @uid = N'38AAFFD4-1AE7-479B-889A-4D7F52C0DB58'
--SET @rprtcfgid = N'3FED49AA-15C3-4875-A980-D252A6DAEF80'

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
	

IF @gtypeid = 1
	INSERT INTO @Results
	EXEC proc_ReportPerformance_Group_Vehicle @gids, @sdate, @edate, @uid, @rprtcfgid
ELSE
	INSERT INTO @Results
	EXEC proc_ReportPerformance_Group_Driver @gids, @sdate, @edate, @uid, @rprtcfgid
	
SELECT	VehicleId,
		Registration,
		DriverId,
		DriverName,
		Efficiency AS Score,
		TotalDrivingDistance,
		SweetSpot,
		Idle,
		OverRevWithFuel,
		Cruise,
		EngineServiceBrake,
		CEILING(HarshBraking) AS HarshBraking,
		CoastInGear,
		OverSpeed,
		CEILING(Rop) AS Rop,
		OverRevWithoutFuel,
		Pto,
		FuelEcon,
		sdate,
		edate,
		DistanceUnit,
		FuelUnit,
		EfficiencyColour AS ScoreColour,
		SweetSpotColour,
		IdleColour,
		OverRevWithFuelColour,
		CruiseColour,
		EngineServiceBrakeColour,
		HarshBrakingColour,
		CoastInGearColour
FROM @Results

	

GO
