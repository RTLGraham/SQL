SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_ReportFuelEmissions_RS_Driver]
(
	@gids VARCHAR(MAX), 
	@uid UNIQUEIDENTIFIER,
	@configid UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME,
	@dids varchar(max) = NULL
)
AS

--DECLARE	@gids varchar(max),
--		@sdate datetime,
--		@edate datetime,
--		@uid uniqueidentifier,
--		@configid uniqueidentifier

--SET @gids = N'A58D9752-FB5D-4A72-A3D6-B5350006CF8A,BCD2D8EE-B5C5-46D6-AF71-EE9DB73EC7C0,27B0D5DF-BD7F-4DD6-9C19-F0BEE7B8B772,C7152466-0FB2-4C82-8B9C-F8A97AF6BDBC'
--SET @sdate = '2015-05-01 00:00:00'
--SET @edate = '2015-05-30 23:59:59'
--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
--SET @configid = N'8D968BBE-9F7A-411C-ACC2-4F321B651383'

DECLARE @results TABLE
(
	DriverId UNIQUEIDENTIFIER,
	Number NVARCHAR(MAX),
	NumberAlternate NVARCHAR(MAX),
	NumberAlternate2 NVARCHAR(MAX),
	FirstName NVARCHAR(MAX),
	Surname NVARCHAR(MAX),
	DriverName NVARCHAR(MAX),
	GroupId UNIQUEIDENTIFIER, GroupName NVARCHAR(MAX), Co2 FLOAT, TotalDrivingDistance FLOAT, TotalFuel FLOAT, OverRevWithFuel FLOAT, Idle FLOAT, FuelEcon FLOAT, sdate DATETIME, edate DATETIME, DistanceUnit NVARCHAR(MAX), FuelUnit NVARCHAR(MAX), LiquidUnit NVARCHAR(MAX), Co2Unit NVARCHAR(MAX) 
)

INSERT INTO @results
EXEC [dbo].[proc_ReportFuelEmissions_Driver] @gids, @sdate, @edate, @uid, @configid,@dids

SELECT 
	r.GroupId,
	r.GroupName,

	--r.Registration AS VehicleRegistration, 
 --         r.MakeModel AS VehicleMakeModel,
 --         r.EngineSize AS VehicleEngineSize,
 --         r.ChassisNumber AS VehicleChassisNumber,
 --         r.FleetNumber AS VehicleFleetNumber,
    r.DriverName,
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
	INNER JOIN @results g ON g.DriverId IS NULL AND g.GroupId IS NOT NULL AND r.GroupId = g.GroupId
	INNER JOIN @results t ON t.DriverId IS NULL AND t.GroupId IS NULL
WHERE r.DriverId IS NOT NULL AND r.GroupId IS NOT NULL


GO
