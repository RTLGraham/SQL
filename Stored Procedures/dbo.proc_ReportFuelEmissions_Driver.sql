SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportFuelEmissions_Driver]
(
	@gids varchar(max), 
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER,
	@dids varchar(max) = NULL
) 
AS

--DECLARE	@gids varchar(max),
--		@sdate datetime,
--		@edate datetime,
--		@uid uniqueidentifier,
--		@rprtcfgid UNIQUEIDENTIFIER,
--		@dids NVARCHAR(MAX)

--SET @gids = N'A58D9752-FB5D-4A72-A3D6-B5350006CF8A,BCD2D8EE-B5C5-46D6-AF71-EE9DB73EC7C0,27B0D5DF-BD7F-4DD6-9C19-F0BEE7B8B772,C7152466-0FB2-4C82-8B9C-F8A97AF6BDBC'
--SET @sdate = '2015-05-01 00:00:00'
--SET @edate = '2015-05-30 23:59:59'
--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
--SET @rprtcfgid = N'8D968BBE-9F7A-411C-ACC2-4F321B651383'

DECLARE	@lgids varchar(max),
		@lsdate datetime,
		@ledate datetime,
		@luid uniqueidentifier,
		@lrprtcfgid UNIQUEIDENTIFIER,
	    @ldids varchar(max)
		
SET @lgids = @gids
SET @ldids = @dids
SET @lsdate = @sdate
SET @ledate = @edate
SET @luid = @uid
SET @lrprtcfgid = @rprtcfgid

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
IF @ldids IS NOT NULL
BEGIN
	INSERT INTO @assets(AssetId) SELECT DISTINCT Value FROM dbo.Split(@ldids, ',')
END
ELSE BEGIN
	INSERT INTO @assets(AssetId) 
	SELECT DISTINCT d.DriverId
	FROM dbo.[Group] g
		INNER JOIN dbo.GroupDetail gd ON gd.GroupId = g.GroupId
		INNER JOIN dbo.Driver d ON gd.EntityDataId = d.DriverId
	WHERE g.GroupId IN (SELECT Value FROM dbo.Split(@gids, ',')) AND g.IsParameter = 0 AND g.Archived = 0 AND d.Archived = 0
END


SELECT
	d.DriverId,
	d.Number,
	d.NumberAlternate,
	d.NumberAlternate2,
	d.FirstName,
	d.Surname,
	dbo.FormatDriverNameByUser(d.DriverId, @luid) AS DriverName,
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
		CASE WHEN (GROUPING(d.DriverId) = 1) THEN NULL
			ELSE ISNULL(d.DriverId, NULL)
		END AS DriverId,
		
		CASE WHEN (GROUPING(gd.GroupId) = 1) THEN NULL
			ELSE ISNULL(gd.GroupId, NULL)
		END AS GroupId,
		
		ISNULL((SUM(TotalFuel) * 2639.1 * @co2mult) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)),0) AS Co2, --@co2mult: 1 for g/km, 1.6 for g/miles
		SUM(DrivingDistance * 1000 * @distmult) AS TotalDrivingDistance,
		SUM(TotalFuel * @liquidmult) AS TotalFuel,
		SUM(FueledOverRPMDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)) AS OverRevWithFuel,
		CAST(SUM(IdleTime) AS float) / dbo.ZeroYieldNull(SUM(TotalTime)) AS Idle,
		(CASE WHEN @fuelmult = 0.1 THEN
			(CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel)*100 END)/dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance) )
		ELSE
			(SUM(DrivingDistance + PTOMovingDistance) * 1000) / (CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel) END) * @fuelmult END) AS FuelEcon
			
	FROM dbo.Reporting r
	INNER JOIN dbo.Driver d ON d.DriverIntId = r.DriverIntId
	INNER JOIN @assets ass ON ass.AssetId = d.DriverId
	INNER JOIN GroupDetail gd ON gd.EntityDataId = d.DriverId
	  AND GroupId IN (SELECT VALUE FROM dbo.Split(@lgids, ','))
		
	WHERE Date BETWEEN @lsdate AND @ledate 

	GROUP BY d.DriverId, gd.GroupId WITH CUBE ) CubeResult
--	HAVING SUM(DrivingDistance) > 10 ) CubeResult

LEFT JOIN dbo.Driver d ON CubeResult.DriverId = d.DriverId
LEFT JOIN [Group] g ON CubeResult.GroupId = g.GroupId

WHERE NOT (CubeResult.GroupId is NULL AND CubeResult.DriverId is NOT NULL) 

ORDER BY Surname, GroupName

GO
