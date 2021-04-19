SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[proc_PopulateReporting_periodic] 
	@sdate smalldatetime = null, -- start datetime for processing period
	@edate smalldatetime = null, -- end datetime for processing period (must be on same day as sdate)
	@tidy int = 1 -- boolean indicating if we should tidy the copy tables when we're done
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- check we're not already running
SELECT MyVar = 5 INTO #PopulateReportingRunningTable

IF @@ERROR <> 0
BEGIN
	-- do nothing!
	SELECT 0
END
ELSE
BEGIN
	
	-- Have we been passed a time to process?
	-- if not then just process for right now
	--
	-- There really is no need to do this anymore, we 
	-- can just process all Accum in the arc table.
	-- The only benefit to this is that it 'may' reduce
	-- the load if a whole set of dodgy data turns up.
	--
	IF(@edate is null)
	BEGIN
		DECLARE @tempdate smalldatetime
		--SET @edate = DateAdd(hour, -4, GetDate())
		SET @edate = DateAdd(hour, -6, GetDate())
		SET @tempdate = DateAdd(hour, -168, @edate)
		SET @sdate = CAST(YEAR(@tempdate) AS varchar(4)) + '-' + CAST(dbo.LeadingZero(MONTH(@tempdate),2) AS varchar(2)) + '-' + CAST(dbo.LeadingZero(DAY(@tempdate),2) AS varchar(2)) + ' 00:00:00.000'
		SET @edate = CAST(YEAR(@edate) AS varchar(4)) + '-' + CAST(dbo.LeadingZero(MONTH(@edate),2) AS varchar(2)) + '-' + CAST(dbo.LeadingZero(DAY(@edate),2) AS varchar(2)) + ' 23:59:59.999'
	END

	DECLARE @tempResults table(
		[VehicleIntId] [int] NULL,
		[DriverIntId] [int] NULL,
		[InSweetSpotDistance] [float] NULL,
		[FueledOverRPMDistance] [float] NULL,
		[TopGearDistance] [float] NULL,
		[GearDownDistance] [float] NULL,
		[CruiseControlDistance] [float] NULL,
		[CruiseInTopGearsDistance] [float] NULL,
		[CoastInGearDistance] [float] NULL,
		[IdleTime] [int] NULL,
		[TotalTime] [int] NULL,
		[EngineBrakeDistance] [float] NULL,
		[ServiceBrakeDistance] [float] NULL,
		[EngineBrakeOverRPMDistance] [float] NULL,
		[ROPCount] [int] NULL,
		[ROP2Count] [INT] NULL,
		[OverSpeedDistance] [float] NULL,
		[CoastOutOfGearDistance] [float] NULL,
		[PanicStopCount] [int] NULL,
		[TotalFuel] [float] NULL,
		[TimeNoID] [float] NULL,
		[TimeID] [float] NULL,
		[DrivingDistance] [float] NULL,
		[PTOMovingDistance] [float] NULL,
		[Date] [smalldatetime] NOT NULL,
		[Rows] [int] NULL,
		[DrivingFuel] [float] NULL,
		[PTOMovingTime] [int] NULL,
		[PTOMovingFuel] [float] NULL,
		[PTONonMovingTime] [int] NULL,
		[PTONonMovingFuel] [float] NULL,
		[DigitalInput2Count] [int] NULL,
		[RouteID] [int] NULL,
		[ORCount] [int] NULL,
		[CruiseSpeedingDistance] [FLOAT] NULL,
		[OverSpeedThresholdDistance] [FLOAT] NULL,
		[TopGearSpeedingDistance] FLOAT NULL,
		[FuelWastage] FLOAT NULL,
		[Odogps] BIGINT NULL		
	);

	DECLARE @tempResults1 table(
		[VehicleIntId] [int] NULL,
		[DriverIntId] [int] NULL,
		[RouteID] [int] NULL,
		[PassengerComfortScore] [float] NULL,
		[Date] [smalldatetime] NOT NULL,
		[PassComfID] int NOT NULL	
	);


	DECLARE @VehicleIntId int
	DECLARE @DriverIntId int
	DECLARE @InSweetSpotDistance float
	DECLARE @FueledOverRPMDistance float
	DECLARE @TopGearDistance FLOAT
	DECLARE @GearDownDistance float
	DECLARE @CruiseControlDistance FLOAT
	DECLARE @CruiseInTopGearsDistance FLOAT
	DECLARE @CoastInGearDistance float
	DECLARE @IdleTime int
	DECLARE @TotalTime int
	DECLARE @EngineBrakeDistance float
	DECLARE @ServiceBrakeDistance float
	DECLARE @EngineBrakeOverRPMDistance float
	DECLARE @ROPCount INT
    DECLARE @ROP2Count INT
	DECLARE @OverSpeedDistance float
	DECLARE @CoastOutOfGearDistance float
	DECLARE @PanicStopCount int
	DECLARE @TotalFuel float
	DECLARE @TimeNoID float
	DECLARE @TimeID float
	DECLARE @DrivingDistance float
	DECLARE @PTOMovingDistance float
	DECLARE @Date smalldatetime
	DECLARE @Rows int
	DECLARE @DrivingFuel float
	DECLARE @PTOMovingTime int
	DECLARE @PTOMovingFuel float
	DECLARE @PTONonMovingTime int
	DECLARE @PTONonMovingFuel float
	DECLARE @DigitalInput2Count int
	DECLARE @RouteID INT
	DECLARE @ORCount INT
	DECLARE @PassengerComfortScore float
	DECLARE @PassComfID int
	DECLARE @ReportingId INT
    DECLARE @CruiseSpeedingDistance FLOAT
	DECLARE @OverSpeedThresholdDistance FLOAT
	DECLARE @TopGearSpeedingDistance FLOAT
	DECLARE @Fuelwastage FLOAT
	DECLARE @Odogps BIGINT

	---------------------------------------------------------------------
	-- Mark all records to be processed in 'copy' table
	UPDATE AccumReportingCopy SET Archived = 1
	WHERE CreationDateTime between @sdate and @edate -- < DateAdd(hour, -2, @now)

	UPDATE PassComfReportingCopy SET Archived = 1
	--WHERE CreationDateTime between @sdate and @edate -- < DateAdd(hour, -2, @now)

	---------------------------------------------------------------------
	-- Update the ROP count for any C/F Series device Accum we are about to process
	-- We use DLDTime as a spare int field
	UPDATE dbo.AccumReportingCopy
	SET DataLinkDownTime = 
	(
		SELECT COUNT(*)
		FROM dbo.SnapshotROPCopy src
			INNER JOIN dbo.Vehicle v ON src.VehicleIntId = v.VehicleIntId
			INNER JOIN dbo.IVH i ON v.IVHId = i.IVHId
		WHERE src.CreationCodeId = 7
		  AND src.VehicleIntId = arc.VehicleIntId
		  AND src.EventDateTime BETWEEN arc.CreationDateTime AND CASE WHEN DATEDIFF(YEAR, arc.ClosureDateTime, GETUTCDATE()) > 0 THEN arc.LastOperation ELSE arc.ClosureDateTime END
		  AND i.IVHTypeId IN (1,2)
	)
	FROM dbo.AccumReportingCopy arc
	INNER JOIN dbo.Vehicle v ON v.VehicleIntId = arc.VehicleIntId
	INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId
	WHERE arc.Archived = 1
	  AND i.IVHTypeId IN (1,2)

	-- Update the ROP count for any any Cheetah / A9 / A11 device Accum we are about to process
	-- We use DLDTime as a spare int field
	UPDATE dbo.AccumReportingCopy
	SET DataLinkDownTime = 
	(
		SELECT COUNT(*)
		FROM dbo.Event e
			INNER JOIN dbo.EventData ed ON e.EventId = ed.EventId
			INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
			INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
			INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
			INNER JOIN dbo.IVH i ON v.IVHId = i.IVHId
		WHERE e.CreationCodeId = 30
		  AND ed.EventDataString NOT LIKE 'STAT%'
		  AND e.VehicleIntId = arc.VehicleIntId
		  AND e.EventDateTime BETWEEN arc.CreationDateTime AND CASE WHEN DATEDIFF(YEAR, arc.ClosureDateTime, GETUTCDATE()) > 0 THEN arc.LastOperation ELSE arc.ClosureDateTime END
		  AND i.IVHTypeId IN (0,5,8,9)
	)
	FROM dbo.AccumReportingCopy arc
	INNER JOIN dbo.Vehicle v ON v.VehicleIntId = arc.VehicleIntId
	INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId
	WHERE arc.Archived = 1
	  AND i.IVHTypeId IN (0,5,8,9)


	-- Update the ROP2 count for any Cheetah /A9 / A11 device Accum we are about to process
	-- We use RSGTime as a spare int field
	UPDATE dbo.AccumReportingCopy
	SET RSGTime = 
	(
		SELECT COUNT(*)
		FROM dbo.Event e
			INNER JOIN dbo.EventData ed ON e.EventId = ed.EventId
			INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
			INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
			INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
			INNER JOIN dbo.IVH i ON v.IVHId = i.IVHId
		WHERE e.CreationCodeId = 231
		  AND ed.EventDataString NOT LIKE 'STAT%'
		  AND e.VehicleIntId = arc.VehicleIntId
		  AND e.EventDateTime BETWEEN arc.CreationDateTime AND CASE WHEN DATEDIFF(YEAR, arc.ClosureDateTime, GETUTCDATE()) > 0 THEN arc.LastOperation ELSE arc.ClosureDateTime END
		  AND i.IVHTypeId IN (0,5,8,9)
	)
	FROM dbo.AccumReportingCopy arc
	INNER JOIN dbo.Vehicle v ON v.VehicleIntId = arc.VehicleIntId
	INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId
	WHERE arc.Archived = 1
	  AND i.IVHTypeId IN (0,5,8,9)

	---------------------------------------------------------------------
	-- build a temp result set
	INSERT INTO @tempResults 
	(
		VehicleIntId, DriverIntId, InSweetSpotDistance, FueledOverRPMDistance,
		TopGearDistance, GearDownDistance, CruiseControlDistance, CruiseInTopGearsDistance, CoastInGearDistance, IdleTime, TotalTime,
		EngineBrakeDistance, ServiceBrakeDistance, EngineBrakeOverRPMDistance, ROPCount, ROP2Count, OverSpeedDistance,
		CoastOutOfGearDistance, PanicStopCount, TotalFuel, TimeNoID, TimeID,
		DrivingDistance, PTOMovingDistance, Date, Rows, DrivingFuel,
		PTOMovingTime, PTOMovingFuel, PTONonMovingTime, PTONonMovingFuel,DigitalInput2Count,RouteID,ORCount,
		CruiseSpeedingDistance, OverSpeedThresholdDistance, TopGearSpeedingDistance, FuelWastage, Odogps
	)

	SELECT aa.VehicleIntId, aa.DriverIntId,
		SUM(InSweetSpotDistance) AS InSweetSpotDistance,
		SUM(FueledOverRPMDistance) AS FueledOverRPMDistance,
		SUM(TopGearDistance) AS TopGearDistance,
		SUM(GearDownDistance) AS GearDownDistance,
		SUM(CruiseControlDistance) AS CruiseControlDistance,
		SUM(CruiseTopGearDistance + CruiseGearDownDistance) AS CruiseInTopGearsDistance,
		SUM(CoastInGearDistance) AS CoastInGearDistance,
		SUM(IdleTime) AS IdleTime,
		SUM(DrivingTime + IdleTime + ShortIdleTime) AS TotalTime,
		SUM(EngineBrakeDistance) AS EngineBrakeDistance,
		SUM(ServiceBrakeDistance) AS ServiceBrakeDistance,
		SUM(EngineBrakeOverRPMDistance) AS EngineBrakeOverRPMDistance,
		SUM(DataLinkDownTime) AS ROPCount,
		SUM(RSGTime) AS ROP2Count,
		SUM(OverSpeedDistance) AS OverSpeedDistance,
		SUM(CoastOutOfGearDistance) AS CoastOutOfGearDistance,
		SUM(PanicStopCount) AS PanicStopCount,
		SUM(DrivingFuel + PTONonMovingFuel + PTOMovingFuel + IdleFuel + ShortIdleFuel) AS TotalFuel,
		SUM(	CASE WHEN Driver.Number = 'No ID' OR Driver.Surname = 'UNKNOWN' THEN 0
				ELSE CAST(DrivingTime + PTOMovingTime + PTONonMovingTime + IdleTime + ShortIdleTime AS float) END) AS TimeNoID,
		SUM(CAST(DrivingTime + PTOMovingTime + PTONonMovingTime + IdleTime + ShortIdleTime AS float)) AS TimeID,
		SUM(DrivingDistance) AS DrivingDistance,
		SUM(PTOMovingDistance) AS PTOMovingDistance,
		CAST(FLOOR(CAST(aa.CreationDateTime AS FLOAT)) AS DATETIME) AS Date,
		COUNT(*) AS Rows,
		SUM(DrivingFuel) AS DrivingFuel,
		SUM(PTOMovingTime) AS PTOMovingTime,
		SUM(PTOMovingFuel) AS PTOMovingFuel,
		SUM(PTONonMovingTime) AS PTONonMovingTime,
		SUM(PTONonMovingFuel) AS PTONonMovingFuel,
		SUM(DigitalInput2Count) As DigitalInput2Count,
		RouteID,
		SUM(ORCount) AS ORCount,
		SUM(CruiseSpeedingDistance) AS CruiseSpeedingDistance,
		SUM(OverSpeedThresholdDistance) AS OverSpeedThresholdDistance,
		SUM(TopGearSpeedingDistance) AS TopGearSpeedingDistance,
		SUM(CASE WHEN FueledOverRPMFuel - (((DrivingFuel + PTONonMovingFuel + PTOMovingFuel - FueledOverRPMFuel) / CASE WHEN (DrivingDistance - FueledOverRPMDistance) = 0 THEN NULL ELSE (DrivingDistance - FueledOverRPMDistance) END) * FueledOverRPMDistance) + IdleFuel + ShortIdleFuel < 0 
			THEN 0 
			ELSE FueledOverRPMFuel - (((DrivingFuel + PTONonMovingFuel + PTOMovingFuel - FueledOverRPMFuel) / CASE WHEN (DrivingDistance - FueledOverRPMDistance) = 0 THEN NULL ELSE (DrivingDistance - FueledOverRPMDistance) END) * FueledOverRPMDistance) + IdleFuel + ShortIdleFuel END) AS FuelWastage,
		-- Above fuel wastage calculation is:
		-- (Fuel used not in OR) / (Dist not in OR) = good fuel econ 
		-- (Good fuel econ) x (Dist in OR) = SSORFuel (i.e. fuel would have used if not in OR
		-- ORFuel - SSORFuel + IdleFuel + ShortIdleFuel = Fuelwasted
		MIN(vle.Odogps) AS Odogps
		FROM AccumReportingCopy aa
			INNER JOIN dbo.Vehicle v ON aa.VehicleIntId = v.VehicleIntId
			INNER JOIN dbo.VehicleLatestEvent vle ON vle.VehicleId = v.VehicleId
			LEFT JOIN dbo.IVH i ON v.IVHId = i.IVHId
			INNER JOIN Driver ON aa.DriverIntId = Driver.DriverIntId
		WHERE aa.Archived = 1 AND (v.IsCAN = 1 OR v.IsCAN IS NULL OR i.IVHTypeId = 6)
				AND ABS(DATEDIFF(HOUR, aa.CreationDateTime, CASE WHEN DATEDIFF(YEAR, aa.ClosureDateTime, GETUTCDATE()) > 0 THEN aa.LastOperation ELSE aa.ClosureDateTime END)) < 30
		GROUP BY aa.CustomerIntId, aa.VehicleIntId, aa.DriverIntId, aa.RouteID, aa.CreationDateTime			


	/********************************************************************************/
	/*					Process data for non-CAN vehicles here.						*/
	/********************************************************************************/
	DECLARE @t_DrivingDistance FLOAT,
			@t_MinDistance FLOAT,
			@t_MaxDistance FLOAT,
			@t_VehicleIntId INT,
			@t_DriverIntId INT,
			@t_sdate DATETIME,
			@t_edate DATETIME,
			@t_RouteID INT	
			
	DECLARE @t_Results TABLE
	(
		VehicleIntId INT NOT NULL,
		DriverIntId INT NOT NULL,
		CreationDateTime DATETIME NOT NULL,
		ClosureDateTime DATETIME NOT NULL,
		RouteID INT NULL,
		DrivingDistance FLOAT NULL
	)
	INSERT INTO @t_Results (VehicleIntId,	DriverIntId, CreationDateTime, ClosureDateTime, RouteID, DrivingDistance)
	SELECT aa.VehicleIntId, aa.DriverIntId, aa.CreationDateTime, CASE WHEN DATEDIFF(YEAR, aa.ClosureDateTime, GETUTCDATE()) > 0 THEN aa.LastOperation ELSE aa.ClosureDateTime END, aa.RouteID, NULL
	FROM AccumReportingCopy aa
		INNER JOIN dbo.Vehicle v ON aa.VehicleIntId = v.VehicleIntId
	WHERE aa.Archived = 1 AND v.IsCAN = 0
		AND v.VehicleTypeID != 4000000	/*		exclude trailers	 */
		AND ABS(DATEDIFF(HOUR, aa.CreationDateTime, CASE WHEN DATEDIFF(YEAR, aa.ClosureDateTime, GETUTCDATE()) > 0 THEN aa.LastOperation ELSE aa.ClosureDateTime END)) < 30
		
	DECLARE t_Cursor CURSOR FAST_FORWARD READ_ONLY
	FOR SELECT VehicleIntId, DriverIntId, CreationDateTime, ClosureDateTime, RouteID FROM @t_Results

	OPEN t_Cursor
	FETCH NEXT FROM t_Cursor INTO @t_VehicleIntId, @t_DriverIntId, @t_sdate, @t_edate, @t_RouteID
					
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @t_MinDistance = NULL
		SET @t_MaxDistance = NULL
		SET @t_DrivingDistance = NULL
		
		SELECT @t_MinDistance = MIN(OdoGPS), @t_MaxDistance = MAX(OdoGPS)
		FROM dbo.Event
		WHERE VehicleIntId = @t_VehicleIntId AND DriverIntId = @t_DriverIntId AND EventDateTime BETWEEN @t_sdate AND @t_edate
			AND OdoGPS != 0
		
		IF(@t_MaxDistance IS NULL OR @t_MinDistance IS NULL)
		BEGIN
			SET @t_DrivingDistance = 0
		END
		ELSE BEGIN
			SET @t_DrivingDistance = (@t_MaxDistance - @t_MinDistance) / 1000
		END
		
		UPDATE @t_Results
		SET DrivingDistance = @t_DrivingDistance
		WHERE VehicleIntId = @t_VehicleIntId 
			AND DriverIntId = @t_DriverIntId 
			AND CreationDateTime = @t_sdate 
			AND ClosureDateTime = @t_edate	
			AND RouteID = @t_RouteID
		
		FETCH NEXT FROM t_Cursor INTO @t_VehicleIntId, @t_DriverIntId, @t_sdate, @t_edate, @t_RouteID
	END

	CLOSE t_Cursor
	DEALLOCATE t_Cursor

	INSERT INTO @tempResults 
	(
		VehicleIntId, DriverIntId, InSweetSpotDistance, FueledOverRPMDistance,
		TopGearDistance, GearDownDistance, CruiseControlDistance, CruiseInTopGearsDistance, CoastInGearDistance, IdleTime, TotalTime,
		EngineBrakeDistance, ServiceBrakeDistance, EngineBrakeOverRPMDistance, ROPCount, ROP2Count, OverSpeedDistance,
		CoastOutOfGearDistance, PanicStopCount, TotalFuel, TimeNoID, TimeID,
		DrivingDistance, PTOMovingDistance, Date, Rows, DrivingFuel,
		PTOMovingTime, PTOMovingFuel, PTONonMovingTime, PTONonMovingFuel,DigitalInput2Count,RouteID,ORCount,
		CruiseSpeedingDistance, OverSpeedThresholdDistance, TopGearSpeedingDistance, FuelWastage, Odogps
	)

	SELECT 
		aa.VehicleIntId, 
		aa.DriverIntId,
		
		0 AS InSweetSpotDistance,
		0 AS FueledOverRPMDistance,
		0 AS TopGearDistance,
		0 AS GearDownDistance,
		0 AS CruiseControlDistance,
		0 AS CruiseInTopGearsDistance,
		0 AS CoastInGearDistance,
		0 AS IdleTime,
		0 AS TotalTime,
		0 AS EngineBrakeDistance,
		0 AS ServiceBrakeDistance,
		0 AS EngineBrakeOverRPMDistance,
		0 AS ROPCount,
		0 AS ROP2Count,
		0 AS OverSpeedDistance,
		0 AS CoastOutOfGearDistance,
		0 AS PanicStopCount,
		0 AS TotalFuel,
		0 AS TimeNoID,
		0 AS TimeID,
		SUM(aa.DrivingDistance) AS DrivingDistance,
		0 AS PTOMovingDistance,
		CAST(FLOOR(CAST(aa.CreationDateTime AS FLOAT)) AS DATETIME) AS Date,
		COUNT(*) AS Rows,
		0 AS DrivingFuel,
		0 AS PTOMovingTime,
		0 AS PTOMovingFuel,
		0 AS PTONonMovingTime,
		0 AS PTONonMovingFuel,
		0 AS DigitalInput2Count,
		aa.RouteID,
		0 AS ORCount,
		0 AS CruiseSpeedingDistance,
		0 AS OverSpeedThresholdDistance,
		0 AS TopGearSpeedingDistance,
		0 AS FuelWastage,
		MIN(vle.OdoGPS) AS Odogps
	FROM @t_Results aa
	INNER JOIN dbo.VehicleLatestEvent vle ON dbo.GetVehicleIdFromInt(aa.VehicleIntId) = vle.VehicleId
	WHERE aa.DrivingDistance IS NOT NULL
	GROUP BY aa.VehicleIntId, aa.DriverIntId, aa.RouteID,
		CAST(FLOOR(CAST(aa.CreationDateTime AS FLOAT)) AS DATETIME)

	/********************************************************************************/
	/*				Finished processing data for non-CAN vehicles.					*/
	/********************************************************************************/
	
	
	

	INSERT INTO @tempResults1 (VehicleIntId, DriverIntId, RouteID, PassengerComfortScore, Date,PassComfID)
	Select VehicleIntID, DriverIntID, RouteID, cast((isnull(Score / dbo.ZeroYieldNull(DrivingDistance),0)) as float) as PassengerComfortScore,
	CAST(FLOOR(CAST(CreationDateTime AS FLOAT)) AS DATETIME) AS Date,
	PassComfID
	From PassComfReportingCopy pc Where pc.Archived = 1
	--Group By VehicleID,DriverID,RouteID,CreationDateTime,PassComfID

	---------------------------------------------------------------------
	-- cursor through the temp set and check if rows already exist in reporting table
	DECLARE @nCursorCheck int
	DECLARE tempCursor CURSOR FAST_FORWARD READ_ONLY
	FOR Select * FROM @tempResults

	SET @nCursorCheck    = 0

	OPEN tempCursor
	WHILE(@nCursorCheck = 0)
	BEGIN
		FETCH NEXT FROM tempCursor INTO 
					@VehicleIntId,
					@DriverIntId,
					@InSweetSpotDistance,
					@FueledOverRPMDistance,
					@TopGearDistance,
					@GearDownDistance,
					@CruiseControlDistance,
					@CruiseInTopGearsDistance,
					@CoastInGearDistance,
					@IdleTime,
					@TotalTime,
					@EngineBrakeDistance,
					@ServiceBrakeDistance,
					@EngineBrakeOverRPMDistance,
					@ROPCount,
					@ROP2Count,
					@OverSpeedDistance,
					@CoastOutOfGearDistance,
					@PanicStopCount,
					@TotalFuel,
					@TimeNoID,
					@TimeID,
					@DrivingDistance,
					@PTOMovingDistance,
					@Date,
					@Rows,
					@DrivingFuel,
					@PTOMovingTime,
					@PTOMovingFuel,
					@PTONonMovingTime,
					@PTONonMovingFuel,
					@DigitalInput2Count,
					@RouteID,
					@ORCount,
					@CruiseSpeedingDistance,
					@OverSpeedThresholdDistance,
					@TopGearSpeedingDistance,
					@Fuelwastage,
					@Odogps

		SET @nCursorCheck = @@FETCH_STATUS
		IF (@nCursorCheck = 0)
		BEGIN
			
			-- Does the row already exist?
			SELECT Top 1 @ReportingId = ReportingId FROM Reporting WHERE Date = @Date AND VehicleIntId = @VehicleIntId AND DriverIntId = @DriverIntId AND RouteID = @RouteID
			IF (@@RowCount > 0)
			BEGIN
				-- Row already exists, update existing
				UPDATE Reporting
				SET
					InSweetSpotDistance = InSweetSpotDistance + ISNULL(@InSweetSpotDistance,0),
					FueledOverRPMDistance = FueledOverRPMDistance + ISNULL(@FueledOverRPMDistance,0),
					TopGearDistance = TopGearDistance + ISNULL(@TopGearDistance,0),
					GearDownDistance = GearDownDistance + ISNULL(@GearDownDistance,0),
					CruiseControlDistance = CruiseControlDistance + ISNULL(@CruiseControlDistance,0),
					CruiseInTopGearsDistance = CruiseInTopGearsDistance + ISNULL(@CruiseInTopGearsDistance,0),
					CoastInGearDistance = CoastInGearDistance + ISNULL(@CoastInGearDistance,0),
					IdleTime = IdleTime + ISNULL(@IdleTime,0),
					TotalTime = TotalTime + ISNULL(@TotalTime,0),
					EngineBrakeDistance = EngineBrakeDistance + ISNULL(@EngineBrakeDistance,0),
					ServiceBrakeDistance = ServiceBrakeDistance + ISNULL(@ServiceBrakeDistance,0),
					EngineBrakeOverRPMDistance = EngineBrakeOverRPMDistance + ISNULL(@EngineBrakeOverRPMDistance,0),
					ROPCount = ROPCount + ISNULL(@ROPCount,0),
					ROP2Count = ROP2Count + ISNULL(@ROP2Count,0), 
					OverSpeedDistance = OverSpeedDistance + ISNULL(@OverSpeedDistance,0),
					CoastOutOfGearDistance = CoastOutOfGearDistance + ISNULL(@CoastOutOfGearDistance,0), 
					PanicStopCount = PanicStopCount + ISNULL(@PanicStopCount,0),
					TotalFuel = TotalFuel + ISNULL(@TotalFuel,0),
					TimeNoID = TimeNoID + ISNULL(@TimeNoID,0),
					TimeID = TimeID + ISNULL(@TimeID,0),
					DrivingDistance = DrivingDistance + ISNULL(@DrivingDistance,0),
					PTOMovingDistance = PTOMovingDistance + ISNULL(@PTOMovingDistance,0),
					Rows = Rows + ISNULL(@Rows,0),
					DrivingFuel = DrivingFuel + ISNULL(@DrivingFuel,0),
					PTOMovingTime = PTOMovingTime + ISNULL(@PTOMovingTime,0),
					PTOMovingFuel = PTOMovingFuel + ISNULL(@PTOMovingFuel,0),
					PTONonMovingTime = PTONonMovingTime + ISNULL(@PTONonMovingTime,0),
					PTONonMovingFuel = PTONonMovingFuel + ISNULL(@PTONonMovingFuel,0),
					DigitalInput2Count = DigitalInput2Count + ISNULL(@DigitalInput2Count,0),
					ORCount = ORCount + ISNULL(@ORCount,0),
					CruiseSpeedingDistance = CruiseSpeedingDistance + ISNULL(@CruiseSpeedingDistance,0),
					OverSpeedThresholdDistance = OverSpeedThresholdDistance + ISNULL(@OverSpeedThresholdDistance,0),
					TopGearSpeedingDistance = TopGearSpeedingDistance + ISNULL(@TopGearSpeedingDistance,0),
					FuelWastage = FuelWastage + ISNULL(@FuelWastage,0),
					LatestOdoGPS = ISNULL(@Odogps, 0)
				FROM Reporting
				WHERE ReportingId = @ReportingId

			END
			ELSE BEGIN
				-- No row yet so just insert a new one
				INSERT INTO Reporting (VehicleIntId, DriverIntId, InSweetSpotDistance, FueledOverRPMDistance,
					TopGearDistance, GearDownDistance, CruiseControlDistance, CruiseInTopGearsDistance, CoastInGearDistance, IdleTime, TotalTime,
					EngineBrakeDistance, ServiceBrakeDistance, EngineBrakeOverRPMDistance, ROPCount, ROP2Count, OverSpeedDistance,
					CoastOutOfGearDistance, PanicStopCount, TotalFuel, TimeNoID, TimeID,
					DrivingDistance, PTOMovingDistance, Date, Rows, DrivingFuel,
					PTOMovingTime, PTOMovingFuel, PTONonMovingTime, PTONonMovingFuel,DigitalInput2Count,RouteID,PassengerComfort,ORCount,
					CruiseSpeedingDistance, OverSpeedThresholdDistance, TopGearSpeedingDistance, FuelWastage, EarliestOdoGPS, LatestOdoGPS)
				VALUES (@VehicleIntId, @DriverIntId, @InSweetSpotDistance, @FueledOverRPMDistance,
					@TopGearDistance, @GearDownDistance, @CruiseControlDistance, @CruiseInTopGearsDistance, @CoastInGearDistance, @IdleTime, @TotalTime,
					@EngineBrakeDistance, @ServiceBrakeDistance, @EngineBrakeOverRPMDistance, @ROPCount, @ROP2Count, @OverSpeedDistance,
					@CoastOutOfGearDistance, @PanicStopCount, @TotalFuel, @TimeNoID, @TimeID,
					@DrivingDistance, @PTOMovingDistance, @Date, @Rows, @DrivingFuel,
					@PTOMovingTime,	@PTOMovingFuel,	@PTONonMovingTime,	@PTONonMovingFuel,@DigitalInput2Count,@RouteID,0,@ORCount,
					@CruiseSpeedingDistance, @OverSpeedThresholdDistance, @TopGearSpeedingDistance, @Fuelwastage, @Odogps, @Odogps)

			END

		END
	END

	CLOSE tempCursor
	DEALLOCATE tempCursor

	DECLARE tempCursor CURSOR FAST_FORWARD READ_ONLY
	FOR Select * FROM @tempResults1

	SET @nCursorCheck    = 0

	OPEN tempCursor
	WHILE(@nCursorCheck = 0)
	BEGIN
		FETCH NEXT FROM tempCursor INTO 
					@VehicleIntId,
					@DriverIntId,
					@RouteID,
					@PassengerComfortScore,
					@Date,
					@PassComfID

		SET @nCursorCheck = @@FETCH_STATUS
		IF (@nCursorCheck = 0)
		BEGIN
			
			-- Does the row already exist?
			SELECT Top 1 @ReportingId = ReportingId FROM Reporting WHERE Date = @Date AND VehicleIntId = @VehicleIntId AND DriverIntId = @DriverIntId AND RouteID = @RouteID
			IF (@@RowCount > 0)
			BEGIN
				-- Row already exists, update existing
				UPDATE Reporting
				SET
					PassengerComfort = ISNULL(PassengerComfort,0) + ISNULL(@PassengerComfortScore,0)
				FROM Reporting
				WHERE ReportingId = @ReportingId
				DELETE From PassComfReportingCopy Where PassComfID = @PassComfID
				--WHERE Archived = 1 
				--and CAST(YEAR(CreationDateTime) AS varchar(4)) + '-' + CAST(dbo.LeadingZero(MONTH(CreationDateTime),2) AS varchar(2)) + '-' + CAST(dbo.LeadingZero(DAY(CreationDateTime),2) AS varchar(2)) + ' 00:00:00.000' = @Date
				--and VehicleID = @VehicleID and DriverID = @DriverID and RouteID = @RouteID And ISNULL((Score / dbo.ZeroYieldNull(DrivingDistance)),0) = ISNULL(@PassengerComfortScore,0)
			END
		END
	END

	CLOSE tempCursor
	DEALLOCATE tempCursor

	---------------------------------------------------------------------
	-- Delete any AccumReportingTemp records that were in the table when we started
	DELETE From AccumReportingCopy WHERE Archived = 1


	IF(@tidy = 1)
	BEGIN
		---------------------------------------------------------------------
		-- Tidy old records that may have been missed due to late arrival
		-- Tidy any old SnapshotROPCopy records that are over 2 days old
		DELETE From SnapshotROPCopy WHERE SnapshotROPCopy.EventDateTime < DateAdd(day, -2, @sdate)
		DELETE From SnapshotROPCopy WHERE SnapshotROPCopy.EventDateTime > DateAdd(day, 2, @edate)
		---------------------------------------------------------------------
		-- Tidy old records that may have been missed due to late arrival
		-- Tidy any old AccumReportingCopy records that are over 2 days old
		DELETE From AccumReportingCopy WHERE AccumReportingCopy.CreationDateTime < DateAdd(day, -2, @sdate)
		DELETE From AccumReportingCopy WHERE AccumReportingCopy.CreationDateTime > DateAdd(day, 2, @edate)
		---------------------------------------------------------------------
		-- Tidy old records that may have been missed due to late arrival
		-- Tidy any old AccumReportingCopy records that are over 2 days old
		DELETE From PassComfReportingCopy WHERE PassComfReportingCopy.CreationDateTime < DateAdd(day, -2, @sdate)
		DELETE From PassComfReportingCopy WHERE PassComfReportingCopy.CreationDateTime > DateAdd(day, 2, @edate)
		---------------------------------------------------------------------
		-- Should we also tidy data that is way in the future!
	END

END -- End of already running test

DROP TABLE #PopulateReportingRunningTable

END



GO
