SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_ReportFuelEfficiencySafetyDashboard]
	(
		@gids VARCHAR(MAX),
		@sdate DATETIME,
		@edate DATETIME,
		@uid UNIQUEIDENTIFIER,
		@rprtcfgid UNIQUEIDENTIFIER
	)
AS
BEGIN
	SET NOCOUNT ON;
    
--	DECLARE	@gids VARCHAR(MAX),
--		@sdate DATETIME,
--		@edate DATETIME,
--		@uid UNIQUEIDENTIFIER,
--		@rprtcfgId UNIQUEIDENTIFIER;
--
--	SET @gids = NULL;
--	SET @sdate = '2011-09-01 00:00:00';
--	SET @edate = '2011-12-31 23:59:59';
--	SET @uid = N'38AAFFD4-1AE7-479B-889A-4D7F52C0DB58';
--	SET @rprtcfgid = N'77C80BDB-5827-4C5E-BBF4-06F36ACB47D6'

	-- Note that the input date parameters are ignored as this report runs YTD only
	-- Start date will be set to 1st Jan
	-- End date will be set to yesterday
	
	DECLARE	@fuelstr VARCHAR(20),
		@fuelmult FLOAT,
		@distmult FLOAT;
		
	SET @sdate = CONVERT(VARCHAR(16), CAST(DATEPART(yyyy,GETUTCDATE()) AS VARCHAR(4)) + '-01-01 00:00', 120)
	SET @edate = DATEADD(mi, -1, CAST(FLOOR( CAST( GETUTCDATE() AS FLOAT ) )AS DATETIME))

	-- If date is January 1st set dates for previous year
	IF DATEPART(mm,GETUTCDATE()) = 1 AND DATEPART(dd,GETUTCDATE()) = 1
	BEGIN
		SET @sdate = DATEADD(yy, -1, @sdate)
	END
	
	SELECT	@fuelstr = [dbo].UserPref(@uid, 205),
		@fuelmult = [dbo].UserPref(@uid, 204),
		@distmult = [dbo].UserPref(@uid, 202),
		@gids = NULLIF(@gids,'');

	WITH	RawData AS (
		SELECT	g.GroupName,
			CONVERT(NCHAR(4), DATEPART(YY, r.Date)) + '-' + RIGHT('0' + CONVERT(NVARCHAR(2), DATEPART(MM, r.Date)), 2) AS [Month],
			DrivingDistance + PTOMovingDistance AS DrivingDistance,
			TotalFuel,
			FuelMultiplier,
			ServiceBrakeDistance, EngineBrakeDistance, EngineBrakeOverRPMDistance, ROPCount, OverSpeedDistance, CoastOutOfGearDistance, CoastInGearDistance,
			PanicStopCount, InSweetSpotDistance, FueledOverRPMDistance, TopGearDistance, CruiseControlDistance, IdleTime, TotalTime,
                              abc.Acceleration, abc.Braking, abc.Cornering
		FROM	dbo.Reporting r
			LEFT JOIN dbo.ReportingABC abc ON r.VehicleIntId = abc.VehicleIntId AND r.DriverIntId = abc.DriverIntId AND r.Date = abc.Date --AND r.RouteID = abc.RouteId
			INNER JOIN dbo.Vehicle v ON r.VehicleIntId = v.VehicleIntId
			INNER JOIN dbo.GroupDetail gd ON gd.EntityDataId = v.VehicleId
			INNER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId
		WHERE	r.Date BETWEEN @sdate AND @edate 
		AND	(@gids IS NULL OR g.GroupId IN (SELECT Value FROM dbo.Split(@gids, ',')))
		AND	g.GroupId IN (SELECT ug.GroupId 
						  FROM dbo.UserGroup ug
							INNER JOIN dbo.[Group] g ON ug.GroupId = g.GroupId
						  WHERE UserId = @uid AND g.IsParameter = 0 AND g.Archived = 0 AND g.GroupTypeId = 1)
		AND	g.IsParameter = 0
		AND	g.Archived = 0
		AND	g.GroupTypeId = 1)
	SELECT	COALESCE(GroupName, N'Total') AS GroupName,
		COALESCE([Month], N'YTD') AS [Month],
		(CASE
			WHEN @fuelmult = 0.1 THEN
				(CASE WHEN SUM(TotalFuel) = 0 THEN NULL ELSE SUM(TotalFuel * ISNULL(FuelMultiplier, 1.0)) * 100 END)
				/ SUM(DrivingDistance) 
			ELSE
				(SUM(DrivingDistance) * 1000)
				/ (CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel * ISNULL(FuelMultiplier,1.0)) END) * @fuelmult
		END) AS FuelEcon,
		@fuelstr AS FuelStr,
		dbo.ScoreSafetyConfig(SUM(CoastInGearDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance)),
                                        ISNULL(SUM(EngineBrakeDistance) / dbo.ZeroYieldNull(SUM(ServiceBrakeDistance + EngineBrakeDistance)),0), --EngineServiceBrake
				ISNULL(SUM(EngineBrakeOverRPMDistance) / dbo.ZeroYieldNull(SUM(EngineBrakeDistance)),0), --OverRevWithoutFuel 
				ISNULL((SUM(ROPCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance) * @distmult * 1000))))),0), --Rop 
				ISNULL(SUM(OverSpeedDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance)),0), --OverSpeed 
				ISNULL(SUM(CoastOutOfGearDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance)),0), --CoastOutOfGear 
				ISNULL((SUM(PanicStopCount) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance) * @distmult * 1000))))),0), --HarshBraking 
				ISNULL((SUM(Acceleration) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance) * @distmult * 1000))))),0),
                                        ISNULL((SUM(Braking) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance) * @distmult * 1000))))),0),
                                        ISNULL((SUM(Cornering) * (dbo.ZeroYieldNull(1000 / dbo.ZeroYieldNull((SUM(DrivingDistance) * @distmult * 1000))))),0),
                                        @rprtcfgid) AS SafetyScore,
		dbo.ScoreEfficiencyConfig(SUM(InSweetSpotDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance)), --SweetSpot 
				SUM(FueledOverRPMDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance)), --OverRevWithFuel
				SUM(TopGearDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance)), --TopGear 
				SUM(CruiseControlDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance)), --Cruise 
				CAST(SUM(IdleTime) AS float) / dbo.ZeroYieldNull(SUM(TotalTime)), --Idle
				SUM(CruiseControlDistance) / dbo.ZeroYieldNull(SUM(TopGearDistance)), --CruiseTopGearRatio 
				@rprtcfgid) AS EfficiencyScore		
	FROM	RawData
	GROUP BY	GroupName, [Month] WITH CUBE
	HAVING	SUM(DrivingDistance) > 10 AND SUM(TotalFuel) <> 0
	ORDER BY	GroupName, [Month];
END;

GO
