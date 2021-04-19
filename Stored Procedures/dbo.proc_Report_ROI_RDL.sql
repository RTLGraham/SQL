SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_Report_ROI_RDL]
          @uid UNIQUEIDENTIFIER,
          @vids nvarchar(MAX),
          @sdate datetime,
          @edate datetime,
          @targetoverrevpc float = 1,
          @targetidlepc float = 5,
          @actualoverrevpc float = 5,
          @actualidlepc float = 10,
          @fuelcost float = 1
AS
	SET NOCOUNT ON;

          --DECLARE @uid UNIQUEIDENTIFIER;
          --DECLARE @sdate datetime;
          --DECLARE @edate datetime;
          --DECLARE @fuelcost float;
          --DECLARE @vids nvarchar(MAX)
          --DECLARE @targetoverrevpc float
          --DECLARE @targetidlepc float
          --DECLARE @actualoverrevpc float
          --DECLARE @actualidlepc float

          --SET @uid = N'3DB40C4A-7E79-4F41-8017-DE6E12EC7A20';
          --SET @vids = N'BAE976F9-38BF-466C-ADA7-DA3CD8EA0E79'
          --SET @sdate = '2018-04-24 00:00';
          --SET @edate = '2018-04-30 23:59';
          --SET @fuelcost = 1;
          --SET @targetoverrevpc = 1
          --SET @targetidlepc = 5
          --SET @actualoverrevpc = 5
          --SET @actualidlepc = 10	          
		          
		DECLARE	@lvids VARCHAR(MAX),
				@lsdate datetime,
				@ledate datetime,
				@luid uniqueidentifier
				
		SET @lvids = @vids
		SET @lsdate = @sdate
		SET @ledate = @edate
		SET @luid = @uid

		DECLARE @diststr varchar(20),
				@distmult float,
				@fuelstr varchar(20),
				@fuelmult float,
				@liquidstr varchar(20),
				@liquidmult float,
				@co2str varchar(20),
				@co2mult float

		SELECT @diststr = [dbo].UserPref(@luid, 203)
		SELECT @distmult = [dbo].UserPref(@luid, 202)
		SELECT @distmult = @distmult * 1000.0
		SELECT @fuelstr = [dbo].UserPref(@luid, 205)
		SELECT @fuelmult = [dbo].UserPref(@luid, 204)
		SELECT @liquidstr = [dbo].UserPref(@luid, 201)
		SELECT @liquidmult = [dbo].UserPref(@luid, 200)
		SELECT @co2str = [dbo].UserPref(@luid, 211)
		SELECT @co2mult = [dbo].UserPref(@luid, 210)

		SET @lsdate = [dbo].TZ_ToUTC(@lsdate,default,@luid)
		SET @ledate = [dbo].TZ_ToUTC(@ledate,default,@luid)
          
          -- Bit used to store the status of FMTONLY
	DECLARE @fmtonlyON BIT
	SET @fmtonlyON = 0

	--This line will be executed if FMTONLY was initially set to ON
	IF (1=0) BEGIN SET @fmtonlyON = 1 END
	-- Turning off FMTONLY so the temp tables can be declared and read by the calling application
	SET FMTONLY OFF
          
			  --DROP TABLE #Vehicles
          
			  SELECT    Value AS VehicleID
			  INTO      #Vehicles
			  FROM      dbo.Split(@lvids, ',')

			  DECLARE   @CustomerName NVARCHAR(200);
			  SELECT    @CustomerName = c.Name
			  FROM      dbo.Customer c
						INNER JOIN dbo.[User] u ON c.CustomerId = u.CustomerID
			  WHERE     u.UserID = @luid

			  DECLARE   @VehicleCount float;
			  SELECT    @VehicleCount = COUNT(1)
			  FROM      #Vehicles;
          
			  DECLARE   @PerVehicleFactor float;
			  SET       @PerVehicleFactor = 365/dbo.ZeroYieldNull(NULLIF(@VehicleCount, 0) * DATEDIFF(dd, @lsdate, @ledate));

			  SELECT    @CustomerName AS GroupName,
						@VehicleCount AS NumberOfVehicles,
                    
						COALESCE(SweetSpotDistance * @distmult, 0) AS SweetSpotDistance,
						COALESCE(SweetSpotFuel * @liquidmult, 0) AS SweetSpotFuel,
						COALESCE((	CASE 
										WHEN @fuelmult = 0.1 THEN
											(SweetSpotFuel * 100)/dbo.ZeroYieldNull(SweetSpotDistance)
										ELSE
											(SweetSpotDistance / dbo.ZeroYieldNull(SweetSpotFuel)) * @fuelmult * 1000.0
									END),0) AS SweetSpotEconomy,

						COALESCE(SweetSpotDistance/dbo.ZeroYieldNull(TotalDistance), 0) AS SweetSpotRatio,
                    
                    
						COALESCE(OverRevDistance * @distmult, 0) AS OverRevDistance,
						COALESCE(OverRevFuel * @liquidmult, 0) AS OverRevFuel,
						COALESCE((	CASE 
										WHEN @fuelmult = 0.1 THEN
											(OverRevFuel * 100)/dbo.ZeroYieldNull(OverRevDistance)
										ELSE
											(OverRevDistance / dbo.ZeroYieldNull(OverRevFuel)) * @fuelmult
									END),0) AS OverRevEconomy,
						COALESCE(OverRevDistance/dbo.ZeroYieldNull(TotalDistance), 0) AS OverRevRatio,
                    
						COALESCE((OverRevDistance/(SweetSpotDistance / dbo.ZeroYieldNull(SweetSpotFuel))) * @liquidmult, 0) AS OverallOverRevSaving,
						COALESCE(((OverRevDistance/(SweetSpotDistance / dbo.ZeroYieldNull(SweetSpotFuel))) * @liquidmult)*@PerVehicleFactor, 0) AS PerVehicleOverRevSaving,
                    
						CONVERT(float, IdleTime) AS IdleTime,
						IdleFuel * @liquidmult AS IdleFuel,
						CONVERT(float, IdleTime)/dbo.ZeroYieldNull(CONVERT(float, TotalTime)) AS IdleRatio,
						IdleFuel * @liquidmult AS OverallIdleSaving,
						IdleFuel * @liquidmult * @PerVehicleFactor AS PerVehicleIdleSaving,
                    
						TotalDistance * @distmult AS TotalDistance,
						TotalFuel * @liquidmult AS TotalFuel,
						CONVERT(float, TotalTime) AS TotalTime,
						COALESCE((	CASE 
										WHEN @fuelmult = 0.1 THEN
											(TotalFuel * 100)/dbo.ZeroYieldNull(TotalDistance)
										ELSE
											(TotalDistance / dbo.ZeroYieldNull(TotalFuel)) * @fuelmult * 1000.0
									END),0) AS TotalEconomy,
                    
                    
                    
						--Times are in seconds, so they are split here
						IdleTime/3600 AS IdleHours,
						(IdleTime%3600)/60 AS IdleMinutes,
						(IdleTime%3600)%60 AS IdleSeconds,
						TotalTime/3600 AS TotalHours,
						(TotalTime%3600)/60 AS TotalMinutes,
						(TotalTime%3600)%60 AS TotalSeconds,
                    
						COALESCE(@targetoverrevpc, 1) AS TargetOverRevPc,
						COALESCE(@targetidlepc, 5) AS TargetIdlePc,
						COALESCE(@actualoverrevpc, 5) AS ActualOverRevPc,
						COALESCE(@actualidlepc, 10) AS ActualIdlePc,
						COALESCE(@fuelcost, 1) AS FuelCost,
                    
						@diststr AS DistanceStr,
						@fuelstr AS FuelStr,
						@liquidstr AS LiquidStr
			  FROM      (SELECT   NULLIF(SUM(A.InSweetSpotDistance), 0) AS SweetSpotDistance,
								  NULLIF(SUM(A.InSweetSpotFuel), 0) AS SweetSpotFuel,
								  NULLIF(SUM(A.FueledOverRPMDistance), 0) AS OverRevDistance,
								  NULLIF(SUM(A.FueledOverRPMFuel), 0) AS OverRevFuel,
								  NULLIF(SUM(A.IdleTime), 0) AS IdleTime,
								  NULLIF(SUM(A.IdleFuel), 0) AS IdleFuel,
								  NULLIF(SUM(A.DrivingDistance), 0) AS TotalDistance,
								  NULLIF(SUM(A.IdleFuel + A.DrivingFuel + A.ShortIdleFuel + A.ptomovingfuel + A.ptononmovingfuel), 0) AS TotalFuel,
								  NULLIF(SUM(A.DrivingTime + A.IdleTime + A.ShortIdleTime + A.PTOMovingTime + A.PTONonMovingTime), 0) AS TotalTime
						FROM      dbo.Accum A
								  INNER JOIN dbo.Vehicle V ON A.VehicleIntId = V.VehicleIntId
								  INNER JOIN #Vehicles VF ON VF.VehicleID = V.VehicleId
						WHERE     A.CreationDateTime BETWEEN @lsdate AND @ledate
								  --AND A.DrivingDistance > 0
								  ) Data;
		
			DROP TABLE #Vehicles
			-- Now the compiler knows these things exist so we can set FMTONLY back to its original status
	IF @fmtonlyON = 1 BEGIN SET FMTONLY ON END

GO
