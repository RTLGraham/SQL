SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportFuelEmissions_RS]
(
	@gids varchar(max), 
	@uid UNIQUEIDENTIFIER,
	@configid UNIQUEIDENTIFIER,
	@sdate datetime,
	@edate datetime,
	@vids varchar(max) = NULL
)
AS
--DECLARE	@gids varchar(max),
--		@sdate datetime,
--		@edate datetime,
--		@uid uniqueidentifier,
--		@configid uniqueidentifier

--SET @gids = N'08BACCA2-74F4-4932-8244-038318FA54B6,169E0045-012A-44A5-ADB5-05BEFAB135A9'

--SET @sdate = '2011-04-04 00:00:00'
--SET @edate = '2011-04-24 23:59:59'
--SET @uid = N'4c0a0d44-0685-4292-9087-f32e03f10134'
--SET @configid = N'77C80BDB-5827-4C5E-BBF4-06F36ACB47D6'

DECLARE @results TABLE
(
	VehicleId UNIQUEIDENTIFIER, Registration NVARCHAR(MAX), MakeModel NVARCHAR(MAX), EngineSize INTEGER, ChassisNumber NVARCHAR(MAX), FleetNumber NVARCHAR(MAX), GroupId UNIQUEIDENTIFIER, GroupName NVARCHAR(MAX), Co2 FLOAT, TotalDrivingDistance FLOAT, TotalFuel FLOAT, OverRevWithFuel FLOAT, Idle FLOAT, FuelEcon FLOAT, sdate DATETIME, edate DATETIME, DistanceUnit NVARCHAR(MAX), FuelUnit NVARCHAR(MAX), LiquidUnit NVARCHAR(MAX), Co2Unit NVARCHAR(MAX) 
)

INSERT INTO @results
EXEC [dbo].[proc_ReportFuelEmissions] @gids, @sdate, @edate, @uid, @configid,@vids

SELECT 
	r.GroupId,
	r.GroupName,

	r.Registration AS VehicleRegistration, 
          r.MakeModel AS VehicleMakeModel,
          r.EngineSize AS VehicleEngineSize,
          r.ChassisNumber AS VehicleChassisNumber,
          r.FleetNumber AS VehicleFleetNumber,
	r.Co2 AS VehicleCo2, 
	r.TotalDrivingDistance AS VehicleTotalDrivingDistance, 
	r.TotalFuel AS VehicleTotalFuel, 
	r.OverRevWithFuel * 100 AS VehicleOverRevWithFuel, 
	r.Idle * 100 AS VehicleIdle, 
	r.FuelEcon AS VehicleFuelEcon, 
	
	g.Co2 AS GroupCo2, 
	g.TotalDrivingDistance AS GroupTotalDrivingDistance, 
	g.TotalFuel AS GroupTotalFuel, 
	g.OverRevWithFuel * 100 AS GroupOverRevWithFuel, 
	g.Idle * 100 AS GroupIdle, 
	g.FuelEcon AS GroupFuelEcon, 
	
	t.Co2 AS TotalCo2, 
	t.TotalDrivingDistance AS TotalTotalDrivingDistance, 
	t.TotalFuel AS TotalTotalFuel, 
	t.OverRevWithFuel * 100 AS TotalOverRevWithFuel, 
	t.Idle * 100 AS TotalIdle, 
	t.FuelEcon AS TotalFuelEcon, 
	
	@sdate AS sdate, 
	@edate AS edate, 
	r.DistanceUnit, 
	r.FuelUnit, 
	r.LiquidUnit, 
	r.Co2Unit
FROM @results r
	INNER JOIN @results g ON g.VehicleId IS NULL AND g.GroupId IS NOT NULL AND r.GroupId = g.GroupId
	INNER JOIN @results t ON t.VehicleId IS NULL AND t.GroupId IS NULL
WHERE r.VehicleId IS NOT NULL AND r.GroupId IS NOT NULL

GO
