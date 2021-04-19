SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportTotalDistanceReporting]
    (
	  @gids VARCHAR(MAX),
      @vids VARCHAR(MAX),
      @sdate DATETIME,
      @edate DATETIME,
      @uid UNIQUEIDENTIFIER
    )
AS 

--DECLARE	@gids VARCHAR(max),
--		@vids varchar(max),
--		@sdate datetime,
--		@edate datetime,
--		@uid UNIQUEIDENTIFIER
	
--SET @gids = N'949C6051-81F1-4AF9-BE5A-604F72D3A3E7,D428076C-5765-41A1-A9F9-B6D908468D18'
--SET @vids = N'76ECA73D-2923-42AE-8B29-85C2E44DC733,DD5AF9C5-061B-49DC-AAB8-0C331B3F4706,4737FF89-C84E-4406-B67F-EDB38844258E'
--SET @sdate = '2018-02-18 00:00'
--SET @edate = '2018-02-18 23:59'
--SET @uid = N'D1143A2C-6F43-4BE9-9C18-E1C9B8135FD4'    
        
	DECLARE	@lgids VARCHAR(max),
			@lvids varchar(max),
			@lsdate datetime,
			@ledate datetime,
			@luid UNIQUEIDENTIFIER
			
	SET @lgids = @gids
	SET @lvids = @vids
	SET @lsdate = @sdate
	SET @ledate = @edate
	SET @luid = @uid
                                                            
    DECLARE @diststr VARCHAR(20),
			@distmult FLOAT

    SELECT  @diststr = [dbo].UserPref(@luid, 203)
    SELECT  @distmult = [dbo].UserPref(@luid, 202)

    SET @lsdate = [dbo].TZ_ToUTC(@lsdate, DEFAULT, @luid)
    SET @ledate = [dbo].TZ_ToUTC(@ledate, DEFAULT, @luid)
    
    DECLARE  @Vehicles  TABLE
	(
			GroupId UNIQUEIDENTIFIER,
			GroupName VARCHAR(MAX), 
			VehicleId UNIQUEIDENTIFIER,
			VehicleIntId INT,
			Registration VARCHAR(MAX), 
			DepotId INT
	)
			
	INSERT INTO @Vehicles (GroupId, GroupName, VehicleId, VehicleIntId, Registration, DepotId)
	SELECT g.GroupId, g.GroupName, v.VehicleId, v.VehicleIntId, v.Registration, c.CustomerIntId
	FROM dbo.Vehicle v
	LEFT OUTER JOIN dbo.IVH i ON i.IVHId = v.IVHId
	INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
	INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
	INNER JOIN dbo.GroupDetail gd ON v.VehicleId = gd.EntityDataId
	INNER JOIN dbo.[Group] g ON gd.GroupId = g.GroupId
	WHERE g.IsParameter = 0
      AND g.Archived = 0
      AND g.GroupTypeId = 1
      AND c.CustomerIntId > 0
      AND (cv.EndDate IS NULL OR cv.EndDate > GETDATE())
      AND v.VehicleId IN ( SELECT Value FROM dbo.Split(@lvids, ',') )
      AND g.GroupId IN ( SELECT Value FROM dbo.Split(@lgids, ',') )

	DECLARE  @Results TABLE(
			GroupId UNIQUEIDENTIFIER,
			GroupName VARCHAR(MAX), 
			VehicleId UNIQUEIDENTIFIER,
			VehicleIntId INT,
			Registration VARCHAR(MAX), 
			StartDistance INT,
			EndDistance INT)
			
	INSERT INTO @Results (GroupId, GroupName, VehicleId, VehicleIntId, Registration, StartDistance) 
	SELECT v.GroupId, v.GroupName, v.VehicleId, vv.VehicleIntId, v.Registration, MAX(ISNULL(r.EarliestOdogps, 0))
	FROM @Vehicles v 
		INNER JOIN dbo.Vehicle vv ON v.VehicleId = vv.VehicleId
		INNER JOIN dbo.Reporting r ON vv.VehicleIntId = r.VehicleIntId	AND r.Date = CAST(FLOOR(CAST(@sdate AS FLOAT)) AS DATETIME)	
	GROUP BY v.GroupId, v.GroupName, v.VehicleId, vv.VehicleIntId, v.Registration
	
	UPDATE @Results 
	SET EndDistance = ISNULL(rend.TotalVehicleDistance, 0)
	FROM @Results r
	INNER JOIN ( 
				SELECT v.GroupId, v.GroupName, v.VehicleId, v.Registration, MAX(r.LatestOdogps) AS TotalVehicleDistance 
				FROM @Vehicles v 
					INNER JOIN dbo.Vehicle vv ON v.VehicleId = vv.VehicleId
					INNER JOIN dbo.Reporting r ON vv.VehicleIntId = r.VehicleIntId	AND r.Date = CAST(FLOOR(CAST(@edate AS FLOAT)) AS DATETIME)	
				GROUP BY v.GroupId, v.GroupName, v.VehicleId, v.Registration
				) rend ON r.GroupId = rend.GroupId AND r.VehicleId = rend.VehicleId			

	SELECT  DISTINCT r.GroupId,
            r.GroupName,
            r.VehicleId,
            r.Registration,
            (ISNULL(r.StartDistance, 0) + (ISNULL(voo.OdometerOffset, 0) * 1000)) * @distmult AS DistanceStart,
            (ISNULL(r.EndDistance, 0) + (ISNULL(voo.OdometerOffset, 0) * 1000)) * @distmult AS DistanceEnd,
            ISNULL(r.EndDistance - r.StartDistance, 0) * @distmult AS DistanceDifference,
            CAST(0 AS FLOAT) AS StartEngineHours,
            CAST(0 AS FLOAT) AS EndEngineHours,
            CAST(0 AS FLOAT) AS EngineHoursDifference,
            @lsdate AS sdate,
            @ledate AS edate,
            [dbo].TZ_GetTime(@lsdate, DEFAULT, @luid) AS CreationDateTime,
            [dbo].TZ_GetTime(@ledate, DEFAULT, @luid) AS ClosureDateTime,
            @diststr AS DistanceString
	FROM @Results r
	LEFT JOIN dbo.VehicleOdoOffset voo ON r.VehicleIntId = voo.VehicleIntId
	ORDER BY r.GroupName, r.Registration




GO
