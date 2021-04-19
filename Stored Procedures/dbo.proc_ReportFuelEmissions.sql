SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportFuelEmissions]
(
	@gids varchar(max), 
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER,
	@vids varchar(max) = NULL
) 
AS

--DECLARE	@gids varchar(max),
--		@sdate datetime,
--		@edate datetime,
--		@uid uniqueidentifier,
--		@rprtcfgid uniqueidentifier
--
--SET @gids = N'08BACCA2-74F4-4932-8244-038318FA54B6,169E0045-012A-44A5-ADB5-05BEFAB135A9'
----SET @gids = N'08BACCA2-74F4-4932-8244-038318FA54B6'
--
--SET @sdate = '2011-04-04 00:00:00'
--SET @edate = '2011-04-24 23:59:59'
--SET @uid = N'4c0a0d44-0685-4292-9087-f32e03f10134'
--SET @rprtcfgid = N'77C80BDB-5827-4C5E-BBF4-06F36ACB47D6'

DECLARE	@lgids varchar(max),
		@lsdate datetime,
		@ledate datetime,
		@luid uniqueidentifier,
		@lrprtcfgid UNIQUEIDENTIFIER,
		@lvids varchar(max)
		
SET @lgids = @gids
SET @lsdate = @sdate
SET @ledate = @edate
SET @luid = @uid
SET @lrprtcfgid = @rprtcfgid
SET @lvids = @vids

DECLARE @diststr varchar(20),
		@distmult float,
		@fuelstr varchar(20),
		@fuelmult float,
		@co2str varchar(20),
		@co2mult FLOAT,
		@liquidstr varchar(20),
		@liquidmult float

SELECT @diststr = [dbo].UserPref(@luid, 203)
SELECT @distmult = [dbo].UserPref(@luid, 202)
SELECT @fuelstr = [dbo].UserPref(@luid, 205)
SELECT @fuelmult = [dbo].UserPref(@luid, 204)
SELECT @co2str = [dbo].UserPref(@luid, 211)
SELECT @co2mult = [dbo].UserPref(@luid, 210)
SELECT @liquidstr = [dbo].UserPref(@luid, 201)
SELECT @liquidmult = [dbo].UserPref(@luid, 200)

SET @lsdate = [dbo].TZ_ToUTC(@lsdate,default,@luid)
SET @ledate = [dbo].TZ_ToUTC(@ledate,default,@luid)
 
 DECLARE @assets TABLE
(
	AssetId UNIQUEIDENTIFIER
)
IF @vids IS NOT NULL
BEGIN
	INSERT INTO @assets(AssetId) SELECT DISTINCT Value FROM dbo.Split(@vids, ',')
END
ELSE BEGIN
	INSERT INTO @assets(AssetId) 
	SELECT DISTINCT v.VehicleId
	FROM dbo.[Group] g
		INNER JOIN dbo.GroupDetail gd ON gd.GroupId = g.GroupId
		INNER JOIN dbo.Vehicle v ON gd.EntityDataId = v.VehicleId
	WHERE g.GroupId IN (SELECT Value FROM dbo.Split(@gids, ',')) AND g.IsParameter = 0 AND g.Archived = 0 AND v.Archived = 0
END

SELECT
	v.VehicleId,	
	v.Registration,
          v.MakeModel,
          v.EngineSize,
          v.ChassisNumber,
          v.FleetNumber,
	g.GroupId,
	GroupName,
	Co2,
	TotalDrivingDistance,
	TotalFuel, 
	OverRevWithFuel,
	Idle, 
	FuelEcon,				
	@lsdate AS sdate,
	@ledate AS edate,

	@diststr AS DistanceUnit,
	@fuelstr AS FuelUnit,
	@liquidstr AS LiquidUnit,
	@co2str AS Co2Unit
	
FROM
	(SELECT
		CASE WHEN (GROUPING(v.VehicleId) = 1) THEN NULL
			ELSE ISNULL(v.VehicleId, NULL)
		END AS VehicleId,
		
		CASE WHEN (GROUPING(gd.GroupId) = 1) THEN NULL
			ELSE ISNULL(gd.GroupId, NULL)
		END AS GroupId,
		
		ISNULL((SUM(TotalFuel) * 2639.1 * @co2mult) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)),0) AS Co2, --@co2mult: 1 for g/km, 1.6 for g/miles
		SUM(DrivingDistance * 1000 * @distmult) AS TotalDrivingDistance,
		SUM(TotalFuel * @liquidmult) AS TotalFuel,
		SUM(FueledOverRPMDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS OverRevWithFuel,
		CAST(SUM(IdleTime) AS float) / dbo.ZeroYieldNull(SUM(TotalTime)) AS Idle,
		(CASE WHEN @fuelmult = 0.1 THEN
			(CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel  * ISNULL(FuelMultiplier,1.0))*100 END)/dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance) )
		ELSE
			(SUM(DrivingDistance + PTOMovingDistance) * 1000) / (CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel * ISNULL(FuelMultiplier,1.0)) END) * @fuelmult END) AS FuelEcon
			
	FROM dbo.Reporting r
	INNER JOIN dbo.Vehicle v ON r.VehicleIntId = v.VehicleIntId
	INNER JOIN @assets ass ON ass.AssetId = v.VehicleId
	INNER JOIN GroupDetail gd ON gd.EntityDataId = v.VehicleId
	  AND GroupId IN (SELECT VALUE FROM dbo.Split(@lgids, ','))
		
	WHERE Date BETWEEN @lsdate AND @ledate 

	GROUP BY v.VehicleId, gd.GroupId WITH CUBE ) CubeResult
--	HAVING SUM(DrivingDistance) > 10 ) CubeResult

LEFT JOIN dbo.Vehicle v ON CubeResult.VehicleId = v.VehicleId
LEFT JOIN [Group] g ON CubeResult.GroupId = g.GroupId

WHERE NOT (CubeResult.GroupId is NULL AND CubeResult.VehicleId is NOT NULL) 

ORDER BY Registration, GroupName

GO
