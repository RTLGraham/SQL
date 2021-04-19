SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportGpsDistance]
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
--		@uid uniqueidentifier

----SET @gids = N'A6C8FDB7-A4BC-46CD-A850-28D13638527B'
----SET @vids = N'DD0ED3A1-FA7A-4573-BACA-040DA9E75F63,883BBEFD-3402-4CF4-81E2-22170DE40A41,0594362C-8735-4711-9BD8-26316E6CC1BD,8F2224CE-C44B-44D1-B661-4CFE0337B903,9747D017-1A2A-459A-B6ED-5278279DB77C,F501897F-77D0-47B4-BC3D-5D353F0F0C84,4483D389-E438-43FE-B6A6-5F8C8BE3B812,5BF54A2E-782E-4F22-8CE4-711F8107E6D1,0DC77542-7922-4A7A-9607-853BD2E3DDC2,FEF3F3DC-0878-47C3-AE62-86B4CE4386E9,0D26606A-00BD-4622-933A-8813E2CD4232,4654D39F-7CBB-4552-B40B-9D15029CCF20,71442A52-424A-411C-9914-C42F617D5611,1F1C855D-D53C-410A-BD2C-E7958982342B,0EFA6728-4B2F-4637-BFD3-E9911E592856,18ACFA97-7AF2-413D-969F-EFABDCC45842,AFF77C41-48B9-45EB-889E-F86395994315,9F3013DE-2FA3-4F4F-BCAE-FA412C3D5805,628B7540-AB12-4E33-A569-FA58F7DBF7C7,FB2223BB-5B04-44E9-B652-094554FB34A9,2FE8D719-658F-406B-A0B3-0F2C32A70F9A,4F7F7479-103F-4A4F-82D9-162E96800D04,EB3A515E-5D86-4CBA-92AF-180058AC0971,9AA3391F-8C1B-4075-AF57-263FD5B2D88E,409A2814-856A-4696-8E2A-36C48A97BBFE,EBF12DEC-0F72-4230-B4FD-446B93024398,979A71E7-9AC6-4CF9-A7E9-49366F8E3BAD,F0016098-D25B-448D-A2CD-4A3899CF63F1,1F631664-5306-4451-9E31-56909111D87C,537D669C-1C78-4620-9F0A-5A8697753AEF,68988B1F-2CD0-43F3-8F94-633D8A440DCA,AB1C8126-44BB-4D78-97D2-6693429E7C54,A3F35FBA-8C3D-4A1F-9644-734A27252D3E,CA641C85-0BA8-46EB-B502-74ECF8A2A03E,E597D644-7931-4465-94F1-78DC4CA4129F,4274C402-B855-461F-B205-7E68487150CA,B1D992E2-CC51-4212-8B12-7FE23BD32CE6,AE518A74-D475-4EF2-80AC-89C4F75683DB,8E8BA8C7-9D34-4C10-BB88-8BD24D5704E9,A1590596-6DE5-4467-909C-8F5F402D560D,7819B0EA-9636-4405-AACD-991FA2D134D9,A564A1EF-A8E1-4DD1-8CCB-A83BF94C2EE7,69208DA2-F56A-4C9E-898A-B5D9CF62B658,25AF268F-3A1B-49D8-95AA-B74F2F34CF99,786A99C1-7F30-4446-9805-BB2B55EB8FFD,044A1143-8A6D-438F-89D0-C03A90D2D3EE,047448D4-6E1A-4929-8B6A-CED851158395,D8FFE8E3-4C27-4B67-8430-D122B1C8915E,E91AA7CF-751A-461A-9559-D20856F26E8A,C608F73E-BD1A-491B-8C78-D4A87E920673,4865FB4F-4396-4920-BDB6-E74D084FAF90,520D09BA-4F63-4C9F-ABFD-EFE7D834231F'
--SET @gids = N'906E3BAD-7739-44B1-8966-28F8D4F10A09'
--SET @vids = N'8016F50D-A2D1-49A9-BC1E-13AE27953390,486A43F1-70D9-46CC-A745-542B6A4D77CE,5DE385BF-BFCB-4179-90CB-5AEE460B14AD,67B44E7F-6A0E-42E0-9DCF-5DDCA2AF502E,2C1A82DE-6DCB-4D03-BC21-5F65198B9A84,DB3AC174-1CFE-404C-914B-6BE9DB1B7038,D075F7EF-C02E-46E4-91C3-8191F2167F59,6CD1331B-F7FC-4866-A333-8FEE45667F33,91D26E73-DBD4-45DA-935C-997766C44AA2,3708F23A-F7CA-44F0-BB96-A94E80C40DFF,A8DC179E-04AB-4483-9141-A95F46B0968B,16E217D8-BD8D-4D91-A894-B132C6C46170,BAE976F9-38BF-466C-ADA7-DA3CD8EA0E79,004A89CA-8104-4728-AE2B-F7F6635EBB19'
--SET @sdate = '2017-12-17 00:00'
--SET @edate = '2017-12-20 23:59'
--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5' 

-- Bit used to store the status of FMTONLY
DECLARE @fmtonlyON BIT
SET @fmtonlyON = 0

--This line will be executed if FMTONLY was initially set to ON
IF (1=0) BEGIN SET @fmtonlyON = 1 END
-- Turning off FMTONLY so the temp tables can be declared and read by the calling application
SET FMTONLY OFF

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
    
    CREATE TABLE #Vehicles (
			GroupId UNIQUEIDENTIFIER,
			GroupName VARCHAR(MAX), 
			VehicleIntId INT,
			VehicleId UNIQUEIDENTIFIER,
			Registration VARCHAR(MAX), 
			StartDistance INT,
			EndDistance INT)
			
	CREATE NONCLUSTERED INDEX [#Vehicles_VehIntId] ON #Vehicles
	(
		[VehicleIntId] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

        
	INSERT INTO #Vehicles (GroupId, GroupName, VehicleIntId, VehicleId, Registration)
	SELECT g.GroupId, g.GroupName, v.VehicleIntId, v.VehicleId, v.Registration
	FROM dbo.Vehicle v
	INNER JOIN dbo.GroupDetail gd ON v.VehicleId = gd.EntityDataId
	INNER JOIN dbo.[Group] g ON gd.GroupId = g.GroupId
	WHERE g.IsParameter = 0
      AND g.Archived = 0
      AND g.GroupTypeId = 1
      AND v.VehicleId IN ( SELECT Value FROM dbo.Split(@lvids, ',') )
      AND g.GroupId IN ( SELECT Value FROM dbo.Split(@lgids, ',') )
   
--	UPDATE #Vehicles 
--	SET StartDistance = x.StartDistance, EndDistance = x.EndDistance 
--	FROM #Vehicles v 
--	INNER JOIN ( 
--		SELECT v.VehicleId, MIN(e.OdoGps) AS StartDistance, MAX(e.OdoGps) AS EndDistance 
--                    FROM #Vehicles v 
--		INNER JOIN dbo.Vehicle vv ON v.VehicleId = vv.VehicleId
--		INNER JOIN dbo.Event e WITH (NOLOCK) ON vv.VehicleIntId = e.VehicleIntId
--	 WHERE e.EventDateTime BETWEEN @lsdate AND @ledate 
--		AND e.OdoGPS > 0 
--	GROUP BY v.VehicleId) x ON v.VehicleId = x.VehicleId

	UPDATE #Vehicles 
	SET StartDistance = x.StartDistance
	FROM #Vehicles v 
	INNER JOIN ( 
		SELECT v.VehicleId, MIN(e.OdoGps) AS StartDistance
                    FROM #Vehicles v 
		INNER JOIN dbo.Vehicle vv ON v.VehicleId = vv.VehicleId
		INNER JOIN dbo.Event e WITH (NOLOCK) ON vv.VehicleIntId = e.VehicleIntId
	 WHERE e.EventDateTime BETWEEN @lsdate AND DATEADD(dd, 7, @lsdate) 
		AND e.OdoGPS > 0 
	GROUP BY v.VehicleId) x ON v.VehicleId = x.VehicleId

	UPDATE #Vehicles 
	SET EndDistance = x.EndDistance 
	FROM #Vehicles v 
	INNER JOIN ( 
		SELECT v.VehicleId, MAX(e.OdoGps) AS EndDistance 
                    FROM #Vehicles v 
		INNER JOIN dbo.Vehicle vv ON v.VehicleId = vv.VehicleId
		INNER JOIN dbo.Event e WITH (NOLOCK) ON vv.VehicleIntId = e.VehicleIntId
	 WHERE e.EventDateTime BETWEEN DATEADD(dd, -7, @ledate) AND @ledate 
		AND e.OdoGPS > 0 
	GROUP BY v.VehicleId) x ON v.VehicleId = x.VehicleId
		
	-- Where the vehicle has not been driven within the period get the latest OdoGps
	-- from VehiclesLatestEvents if the latest date is prior to the selected start date
	UPDATE #Vehicles
	SET StartDistance = vle.OdoGps, EndDistance = vle.OdoGps
	FROM #Vehicles v
	INNER JOIN dbo.VehicleLatestEvent vle ON v.VehicleId = vle.VehicleId
	WHERE ISNULL(v.StartDistance, 0) = 0
	  AND vle.EventDateTime < @lsdate
	  
	-- If we still don't have any distance data go back through events to get it
	-- as long we know the vehicle was installed prior to the start date
	
	UPDATE #Vehicles 
	SET StartDistance = x.StartDistance, EndDistance = x.StartDistance 
	FROM #Vehicles v 
	INNER JOIN ( 
		SELECT v.VehicleId, MAX(e.OdoGps) AS StartDistance 
		FROM #Vehicles v 
			INNER JOIN dbo.Vehicle vv ON v.VehicleId = vv.VehicleId
			INNER JOIN dbo.Event e WITH (NOLOCK) ON vv.VehicleIntId = e.VehicleIntId
	 WHERE e.EventDateTime BETWEEN DATEADD(MONTH,-1,@lsdate) AND @lsdate 
		AND e.OdoGps > 0
		AND ISNULL(v.StartDistance, 0) = 0
	GROUP BY v.VehicleId) x ON v.VehicleId = x.VehicleId 
	WHERE ISNULL(v.StartDistance, 0) = 0
						   
	SELECT  DISTINCT v.GroupId,
            v.GroupName,
            v.VehicleId,
            v.Registration,
            (v.StartDistance + (ISNULL(voo.OdometerOffset, 0) * 1000)) * @distmult AS DistanceStart,
            (v.EndDistance + (ISNULL(voo.OdometerOffset, 0) * 1000)) * @distmult AS DistanceEnd,
            (v.EndDistance - v.StartDistance) * @distmult AS DistanceDifference,
            @lsdate AS sdate,
            @ledate AS edate,
            [dbo].TZ_GetTime(@lsdate, DEFAULT, @luid) AS CreationDateTime,
            [dbo].TZ_GetTime(@ledate, DEFAULT, @luid) AS ClosureDateTime,
            @diststr AS DistanceString
	FROM #Vehicles v
	LEFT JOIN dbo.VehicleOdoOffset voo ON v.VehicleIntId = voo.VehicleIntId
	ORDER BY v.GroupName

	DROP TABLE #Vehicles

-- Now the compiler knows these things exist so we can set FMTONLY back to its original status
IF @fmtonlyON = 1 BEGIN SET FMTONLY ON END


GO
