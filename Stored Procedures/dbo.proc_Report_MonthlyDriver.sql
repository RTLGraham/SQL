SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_Report_MonthlyDriver]
          @did UNIQUEIDENTIFIER,
          @gids VARCHAR(MAX),
          @uid UNIQUEIDENTIFIER,
          @rprtcfgid UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME
AS 
    BEGIN
	--DECLARE @did UNIQUEIDENTIFIER,
	--		@gids VARCHAR(MAX),
	--		@uid UNIQUEIDENTIFIER,
	--		@rprtcfgid UNIQUEIDENTIFIER,
	--		@sdate DATETIME,
	--		@edate DATETIME
	
	--SET @did = NULL --N'82C340C4-F732-43EC-AB31-5C8E0627261D'		--	RIVERA CARMONA, HIGINIO
	--SET @gids = N'5449160B-8035-4888-856A-4A5AAFD107C3'
	--SET @uid = N'389EFA92-5BFA-47F7-86B0-8EC7D109E39C'
	--SET @rprtcfgid = N'6FAD9660-775F-4E1D-94B2-613CD4F94D65'
	--SET @sdate = '2012-03-01 00:00'
	--SET @edate = '2012-03-31 23:59'
		
	DECLARE @diststr varchar(20),
			@distmult float,
			@fuelstr varchar(20),
			@fuelmult float,
			@co2str varchar(20),
			@co2mult FLOAT

	SELECT @diststr = [dbo].UserPref(@uid, 203)
	SELECT @distmult = [dbo].UserPref(@uid, 202)
	SELECT @fuelstr = [dbo].UserPref(@uid, 205)
	SELECT @fuelmult = [dbo].UserPref(@uid, 204)
	SELECT @co2str = [dbo].UserPref(@uid, 211)
	SELECT @co2mult = [dbo].UserPref(@uid, 210)
	
	SET @sdate = DATEADD(MONTH, -3, @sdate)
	
	SET @sdate = [dbo].TZ_ToUTC(@sdate,default,@uid)
	SET @edate = [dbo].TZ_ToUTC(@edate,default,@uid)
	
	--if the group is not provided, find the driver group
	DECLARE @gid UNIQUEIDENTIFIER		
	IF @gids IS NULL OR @gids = ''
	BEGIN
		SELECT TOP 1 @gid = g.GroupId
		FROM dbo.GroupDetail gd
			INNER JOIN dbo.[Group] g ON gd.GroupId = g.GroupId
		WHERE EntityDataId = @did AND g.GroupTypeId = 2 AND g.Archived = 0 AND g.IsParameter = 0
		ORDER BY g.LastModified DESC
	END
	ELSE BEGIN
		SELECT TOP 1 @gid = VALUE FROM dbo.Split(@gids, ',')
	END 

	DECLARE @results TABLE
	(
		DriverId UNIQUEIDENTIFIER,
		DriverName NVARCHAR(MAX),
		DriverNumber NVARCHAR(MAX),
		
		GroupId UNIQUEIDENTIFIER,
		GroupName NVARCHAR(MAX),
		
		RouteId INT,
		RouteNumber NVARCHAR(MAX),
		
		VehicleTypeId INT,
		VehicleTypeName NVARCHAR(MAX),
		
		Period CHAR(6),
		Score INT,
		Emissions FLOAT		
	)
	
	INSERT INTO @results
	        ( DriverId ,
	          DriverName ,
	          DriverNumber ,
	          GroupId ,
	          GroupName ,
	          RouteId ,
	          RouteNumber ,
	          VehicleTypeId ,
	          VehicleTypeName ,
	          Period ,
	          Score,
	          Emissions
	        )
	SELECT 
		o.DriverId ,
		d.Surname + CASE WHEN d.Firstname IS NULL THEN '' ELSE ' ' + d.Firstname END AS DriverName ,
		d.Number AS DriverNumber ,
		o.GroupId ,
		g.GroupName ,
		o.RouteId ,
		r.RouteNumber ,
		o.VehicleTypeId ,
		vt.Name AS VehicleTypeName ,
		o.Period ,
		o.Score,
		o.Emissions
	FROM 
		(
		SELECT 
			CASE WHEN (GROUPING(d.DriverId) = 1) THEN NULL
				ELSE ISNULL(d.DriverId, NULL)
			END AS DriverId,
					
			CASE WHEN (GROUPING(g.GroupId) = 1) THEN NULL
				ELSE ISNULL(g.GroupId, NULL)
			END AS GroupId,
			
			CASE WHEN (GROUPING(r.RouteID) = 1) THEN NULL
				ELSE ISNULL(r.RouteID, NULL)
			END AS RouteId,
			
			CASE WHEN (GROUPING(v.VehicleTypeID) = 1) THEN NULL
				ELSE ISNULL(v.VehicleTypeID, NULL)
			END AS VehicleTypeId,
			
			CASE WHEN (GROUPING(CONVERT(CHAR(6), r.Date, 112)) = 1) THEN NULL
				ELSE ISNULL(CONVERT(CHAR(6), r.Date, 112), NULL)
			END AS Period,
			
			ROUND(dbo.ScoreEfficiencyConfig(
				SUM(InSweetSpotDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)),		-- SweetSpot
				SUM(FueledOverRPMDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)),	-- OverRevWithFuel
				SUM(TopGearDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)),			-- TopGear
				SUM(CruiseControlDistance) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)),	-- Cruise
				CAST(SUM(IdleTime) AS float) / dbo.ZeroYieldNull(SUM(TotalTime)),							-- Idle
				SUM(CruiseControlDistance) / dbo.ZeroYieldNull(SUM(TopGearDistance)),						-- CruiseTopGearRatio
				@rprtcfgid), 0) AS Score,
			ROUND(ISNULL((SUM(TotalFuel) * 2639.1 * @co2mult) / dbo.ZeroYieldNull(SUM(DrivingDistance + PTOMovingDistance)),0),2) AS Emissions
		FROM 
			dbo.Reporting r
			INNER JOIN dbo.Driver d ON r.DriverIntId = d.DriverIntId
			INNER JOIN dbo.CustomerDriver cd ON d.DriverId = cd.DriverId
			INNER JOIN dbo.GroupDetail gd ON d.DriverId = gd.EntityDataId AND gd.GroupTypeId = 2
			INNER JOIN dbo.[Group] g ON gd.GroupId = g.GroupId
			INNER JOIN dbo.Vehicle v ON r.VehicleIntId = v.VehicleIntId
			INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
			INNER JOIN dbo.[User] u ON cv.CustomerId = u.CustomerID
		WHERE 
			r.Date BETWEEN @sdate AND @edate
			AND (d.DriverId = @did OR @did IS NULL) AND d.Archived = 0 AND cd.EndDate IS NULL AND cd.Archived = 0
			AND g.GroupId = @gid AND g.Archived = 0 AND g.IsParameter = 0 AND g.GroupTypeId = 2
			AND u.UserID = @uid
		GROUP BY d.DriverId,
			g.GroupId,
			r.RouteID,
			CONVERT(CHAR(6), r.Date, 112),
			v.VehicleTypeID
		WITH CUBE
		HAVING SUM(DrivingDistance) > 10
	)o
		LEFT OUTER JOIN dbo.Driver d ON d.DriverId = o.DriverId
		LEFT OUTER JOIN dbo.[Group] g ON g.GroupId = o.GroupId AND g.Archived = 0 AND g.IsParameter = 0
		LEFT OUTER JOIN dbo.[Route] r ON r.RouteID = o.RouteId
		LEFT OUTER JOIN dbo.VehicleType vt ON vt.VehicleTypeID = o.VehicleTypeId
		
	SELECT 
		'Driver' AS EntityType,
		r_driver.DriverName AS EntityName,
		r_driver.DriverNumber AS EntityNumber,
		r_driver.GroupName AS DriverGroupName,
		r_driver.Period ,
		r_driver.Score AS DriverScore,
		r_driver.RouteNumber ,
		r_route.Score AS RouteScore,
		r_group.Score AS FleetScore,
		r_group.Emissions
	FROM @results r_driver
		LEFT JOIN @results r_group ON (r_group.GroupId = r_driver.GroupId
								   AND r_group.RouteId = r_driver.RouteId 
								   AND r_group.Period = r_driver.Period 
								   AND r_group.VehicleTypeId IS NULL 
								   AND r_group.DriverId IS NULL)
		LEFT JOIN @results r_route ON (r_route.GroupId IS NULL
								   AND r_route.RouteId = r_driver.RouteId 
								   AND r_route.Period = r_driver.Period 
								   AND r_route.VehicleTypeId IS NULL 
								   AND r_route.DriverId IS NULL)
	WHERE r_driver.DriverId IS NOT NULL
		AND r_driver.Period IS NOT NULL
		AND r_driver.RouteId IS NOT NULL
		AND r_driver.GroupId IS NOT NULL
		AND r_driver.VehicleTypeId IS NULL
	
	UNION
	
	SELECT 
		'VehicleType' AS EntityType,
		r_vtype.VehicleTypeName AS EntityName,
		NULL AS EntityNumber,
		r_vtype.GroupName AS DriverGroupName,
		NULL AS Period ,
		r_vtype.Score AS DriverScore,
		r_vtype.RouteNumber ,
		r_route.Score AS RouteScore,
		r_group.Score AS FleetScore,
		r_group.Emissions
	FROM @results r_vtype
		LEFT JOIN @results r_group ON (r_group.GroupId IS NULL
								   AND r_group.RouteId IS NULL 
								   AND r_group.Period IS NULL 
								   AND r_group.VehicleTypeId = r_vtype.VehicleTypeId
								   AND r_group.DriverId IS NULL)
		LEFT JOIN @results r_route ON (r_route.GroupId IS NULL
								   AND r_route.RouteId = r_vtype.RouteId 
								   AND r_route.Period IS NULL 
								   AND r_route.VehicleTypeId = r_vtype.VehicleTypeId 
								   AND r_route.DriverId IS NULL)
	WHERE r_vtype.DriverId IS NULL
		AND r_vtype.Period IS NULL
		AND r_vtype.RouteId IS NOT NULL
		AND r_vtype.GroupId IS NOT NULL
		AND r_vtype.VehicleTypeId IS NOT NULL
	
	ORDER BY EntityType ASC, EntityName ASC, Period DESC, RouteNumber ASC
END

GO
