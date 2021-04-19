SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportTotalDistance]
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
----		
--SET @gids = N'906E3BAD-7739-44B1-8966-28F8D4F10A09'
--SET @vids = N'8016F50D-A2D1-49A9-BC1E-13AE27953390,486A43F1-70D9-46CC-A745-542B6A4D77CE,5DE385BF-BFCB-4179-90CB-5AEE460B14AD,67B44E7F-6A0E-42E0-9DCF-5DDCA2AF502E,2C1A82DE-6DCB-4D03-BC21-5F65198B9A84,DB3AC174-1CFE-404C-914B-6BE9DB1B7038,D075F7EF-C02E-46E4-91C3-8191F2167F59,6CD1331B-F7FC-4866-A333-8FEE45667F33,91D26E73-DBD4-45DA-935C-997766C44AA2,3708F23A-F7CA-44F0-BB96-A94E80C40DFF,A8DC179E-04AB-4483-9141-A95F46B0968B,16E217D8-BD8D-4D91-A894-B132C6C46170,BAE976F9-38BF-466C-ADA7-DA3CD8EA0E79,004A89CA-8104-4728-AE2B-F7F6635EBB19'
--SET @sdate = '2017-12-17 00:00'
--SET @edate = '2017-12-20 23:59'
--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'    
        
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
			Registration VARCHAR(MAX), 
			DepotId INT,
			--CalAmp units send TotalEngineHours in seconds, not hours
			TimeDivider INT
	)
			
	INSERT INTO @Vehicles (GroupId, GroupName, VehicleId, Registration, DepotId, TimeDivider)
	SELECT g.GroupId, g.GroupName, v.VehicleId, v.Registration, c.CustomerIntId, CASE WHEN ISNULL(i.IVHTypeId, 5) = 6 THEN 3600 ELSE 1 END AS TimeDivider
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
			EndDistance INT,
			StartEngineHours FLOAT,
			EndEngineHours FLOAT)
			
	INSERT INTO @Results (GroupId, GroupName, VehicleId, VehicleIntId, Registration, StartDistance, StartEngineHours) 
	SELECT v.GroupId, v.GroupName, v.VehicleId, vv.VehicleIntId, v.Registration, MAX(a.TotalVehicleDistance), MAX(a.TotalEngineHours / v.TimeDivider)
	FROM @Vehicles v 
		INNER JOIN dbo.Vehicle vv ON v.VehicleId = vv.VehicleId
		INNER JOIN dbo.Accum a ON vv.VehicleIntId = a.VehicleIntId
				AND a.CreationDateTime >= DATEADD(day, -7, @lsdate) AND a.CreationDateTime <= @lsdate
	--WHERE a.DrivingTime > 0
	WHERE ABS(DATEDIFF(HOUR, a.CreationDateTime, a.ClosureDateTime)) < 30
	GROUP BY v.GroupId, v.GroupName, v.VehicleId, vv.VehicleIntId, v.Registration, v.TimeDivider
	
	UPDATE @Results 
	SET EndDistance = aend.TotalVehicleDistance, EndEngineHours = aend.TotalEngineHours
	FROM @Results r
	INNER JOIN ( 
				SELECT v.GroupId, v.GroupName, v.VehicleId, v.Registration, MAX(a.TotalVehicleDistance) AS TotalVehicleDistance, MAX(a.TotalEngineHours / v.TimeDivider) AS TotalEngineHours 
				FROM @Vehicles v 
					INNER JOIN dbo.Vehicle vv ON v.VehicleId = vv.VehicleId
					INNER JOIN dbo.Accum a ON vv.VehicleIntId = a.VehicleIntId
							AND a.CreationDateTime <= @ledate AND a.CreationDateTime >= @lsdate
				--WHERE a.DrivingTime > 0
				WHERE ABS(DATEDIFF(HOUR, a.CreationDateTime, a.ClosureDateTime)) < 30
				GROUP BY v.GroupId, v.GroupName, v.VehicleId, v.Registration, v.TimeDivider
				) aend ON r.GroupId = aend.GroupId AND r.VehicleId = aend.VehicleId			

	SELECT  DISTINCT r.GroupId,
            r.GroupName,
            r.VehicleId,
            r.Registration,
            (r.StartDistance + ISNULL(voo.OdometerOffset, 0)) * @distmult * 1000 AS DistanceStart,
            (r.EndDistance + ISNULL(voo.OdometerOffset, 0)) * @distmult * 1000 AS DistanceEnd,
            (r.EndDistance - r.StartDistance) * @distmult * 1000 AS DistanceDifference,
            r.StartEngineHours,
            r.EndEngineHours,
            r.EndEngineHours - r.StartEngineHours AS EngineHoursDifference,
            @lsdate AS sdate,
            @ledate AS edate,
            [dbo].TZ_GetTime(@lsdate, DEFAULT, @luid) AS CreationDateTime,
            [dbo].TZ_GetTime(@ledate, DEFAULT, @luid) AS ClosureDateTime,
            @diststr AS DistanceString
	FROM @Results r
	LEFT JOIN dbo.VehicleOdoOffset voo ON r.VehicleIntId = voo.VehicleIntId
	ORDER BY r.GroupName, r.Registration

GO
