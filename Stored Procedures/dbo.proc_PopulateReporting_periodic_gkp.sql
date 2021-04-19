SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[proc_PopulateReporting_periodic_gkp] 
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
		[CruiseControlDistance] [float] NULL,
		[CruiseInTopGearsDistance] [float] NULL,
		[CoastInGearDistance] [float] NULL,
		[IdleTime] [int] NULL,
		[TotalTime] [int] NULL,
		[EngineBrakeDistance] [float] NULL,
		[ServiceBrakeDistance] [float] NULL,
		[EngineBrakeOverRPMDistance] [float] NULL,
		[ROPCount] [int] NULL,
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
		[ORCount] [int] NULL
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
	DECLARE @TopGearDistance float
	DECLARE @CruiseControlDistance FLOAT
	DECLARE @CruiseInTopGearsDistance FLOAT
	DECLARE @CoastInGearDistance float
	DECLARE @IdleTime int
	DECLARE @TotalTime int
	DECLARE @EngineBrakeDistance float
	DECLARE @ServiceBrakeDistance float
	DECLARE @EngineBrakeOverRPMDistance float
	DECLARE @ROPCount int
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
	DECLARE @ReportingId int

	---------------------------------------------------------------------
	-- Mark all records to be processed in 'copy' table
	UPDATE AccumReportingCopy SET Archived = 1
	WHERE CreationDateTime between @sdate and @edate -- < DateAdd(hour, -2, @now)

	UPDATE PassComfReportingCopy SET Archived = 1
	--WHERE CreationDateTime between @sdate and @edate -- < DateAdd(hour, -2, @now)

	---------------------------------------------------------------------
	-- Update the ROP count for any Accum we are about to process
	-- We use DLDTime as a spare int field
	
	UPDATE dbo.AccumReportingCopy
	SET DataLinkDownTime = 
	(
		SELECT COUNT(*)
		FROM dbo.SnapshotROPCopy src
		WHERE src.CreationCodeId = 7
		  AND src.VehicleIntId = dbo.AccumReportingCopy.VehicleIntId
		  AND src.EventDateTime BETWEEN dbo.AccumReportingCopy.CreationDateTime AND dbo.AccumReportingCopy.ClosureDateTime
	)
	FROM dbo.AccumReportingCopy
	WHERE dbo.AccumReportingCopy.Archived = 1

	---------------------------------------------------------------------
	-- build a temp result set
	INSERT INTO @tempResults 
	(
		VehicleIntId, DriverIntId, InSweetSpotDistance, FueledOverRPMDistance,
		TopGearDistance, CruiseControlDistance, CruiseInTopGearsDistance, CoastInGearDistance, IdleTime, TotalTime,
		EngineBrakeDistance, ServiceBrakeDistance, EngineBrakeOverRPMDistance, ROPCount, OverSpeedDistance,
		CoastOutOfGearDistance, PanicStopCount, TotalFuel, TimeNoID, TimeID,
		DrivingDistance, PTOMovingDistance, Date, Rows, DrivingFuel,
		PTOMovingTime, PTOMovingFuel, PTONonMovingTime, PTONonMovingFuel,DigitalInput2Count,RouteID,ORCount
	)

	SELECT aa.VehicleIntId, aa.DriverIntId,
		SUM(InSweetSpotDistance) AS InSweetSpotDistance,
		SUM(FueledOverRPMDistance) AS FueledOverRPMDistance,
		SUM(TopGearDistance) AS TopGearDistance,
		SUM(CruiseControlDistance) AS CruiseControlDistance,
		SUM(CruiseTopGearDistance + CruiseGearDownDistance) AS CruiseInTopGearsDistance,
		SUM(CoastInGearDistance) AS CoastInGearDistance,
		SUM(IdleTime) AS IdleTime,
		SUM(DrivingTime + IdleTime + ShortIdleTime) AS TotalTime,
		SUM(EngineBrakeDistance) AS EngineBrakeDistance,
		SUM(ServiceBrakeDistance) AS ServiceBrakeDistance,
		SUM(EngineBrakeOverRPMDistance) AS EngineBrakeOverRPMDistance,
		SUM(DataLinkDownTime) AS ROPCount,
		SUM(OverSpeedDistance) AS OverSpeedDistance,
		SUM(CoastOutOfGearDistance) AS CoastOutOfGearDistance,
		SUM(PanicStopCount) AS PanicStopCount,
		SUM(DrivingFuel + PTONonMovingFuel + PTOMovingFuel + IdleFuel + ShortIdleFuel) AS TotalFuel,
		SUM(	CASE WHEN Driver.Number = 'No ID' OR Driver.Surname = 'UNKNOWN' THEN 0
				ELSE CAST(DrivingTime + PTOMovingTime + PTONonMovingTime + IdleTime + ShortIdleTime AS float) END) AS TimeNoID,
		SUM(CAST(DrivingTime + PTOMovingTime + PTONonMovingTime + IdleTime + ShortIdleTime AS float)) AS TimeID,
		SUM(DrivingDistance) AS DrivingDistance,
		SUM(PTOMovingDistance) AS PTOMovingDistance,
		CAST(YEAR(CreationDateTime) AS varchar(4)) + '-' + CAST(dbo.LeadingZero(MONTH(CreationDateTime),2) AS varchar(2)) + '-' + CAST(dbo.LeadingZero(DAY(CreationDateTime),2) AS varchar(2)) + ' 00:00:00.000' AS Date,
		COUNT(*) AS Rows,
		SUM(DrivingFuel) AS DrivingFuel,
		SUM(PTOMovingTime) AS PTOMovingTime,
		SUM(PTOMovingFuel) AS PTOMovingFuel,
		SUM(PTONonMovingTime) AS PTONonMovingTime,
		SUM(PTONonMovingFuel) AS PTONonMovingFuel,
		SUM(DigitalInput2Count) As DigitalInput2Count,
		RouteID,
		SUM(ORCount) AS ORCount
		FROM AccumReportingCopy aa
			INNER JOIN dbo.Vehicle v ON aa.VehicleIntId = v.VehicleIntId
			INNER JOIN dbo.IVH i ON v.IVHId = i.IVHId
			INNER JOIN Driver ON aa.DriverIntId = Driver.DriverIntId
		WHERE aa.Archived = 1 AND (v.IsCAN = 1 OR v.IsCAN IS NULL OR i.IVHTypeId = 6)
				AND ABS(DATEDIFF(HOUR, aa.CreationDateTime, aa.ClosureDateTime)) < 30
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
	SELECT aa.VehicleIntId, aa.DriverIntId, aa.CreationDateTime, aa.ClosureDateTime, aa.RouteID, NULL
	FROM AccumReportingCopy aa
		INNER JOIN dbo.Vehicle v ON aa.VehicleIntId = v.VehicleIntId
	WHERE aa.Archived = 1 AND v.IsCAN = 0
		AND v.VehicleTypeID != 4000000	/*		exclude trailers	 */
		AND ABS(DATEDIFF(HOUR, aa.CreationDateTime, aa.ClosureDateTime)) < 30
		
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
		TopGearDistance, CruiseControlDistance, CruiseInTopGearsDistance, CoastInGearDistance, IdleTime, TotalTime,
		EngineBrakeDistance, ServiceBrakeDistance, EngineBrakeOverRPMDistance, ROPCount, OverSpeedDistance,
		CoastOutOfGearDistance, PanicStopCount, TotalFuel, TimeNoID, TimeID,
		DrivingDistance, PTOMovingDistance, Date, Rows, DrivingFuel,
		PTOMovingTime, PTOMovingFuel, PTONonMovingTime, PTONonMovingFuel,DigitalInput2Count,RouteID,ORCount
	)

	SELECT 
		aa.VehicleIntId, 
		aa.DriverIntId,
		
		0 AS InSweetSpotDistance,
		0 AS FueledOverRPMDistance,
		0 AS TopGearDistance,
		0 AS CruiseControlDistance,
		0 AS CruiseInTopGearsDistance,
		0 AS CoastInGearDistance,
		0 AS IdleTime,
		0 AS TotalTime,
		0 AS EngineBrakeDistance,
		0 AS ServiceBrakeDistance,
		0 AS EngineBrakeOverRPMDistance,
		0 AS ROPCount,
		0 AS OverSpeedDistance,
		0 AS CoastOutOfGearDistance,
		0 AS PanicStopCount,
		0 AS TotalFuel,
		0 AS TimeNoID,
		0 AS TimeID,
		SUM(aa.DrivingDistance) AS DrivingDistance,
		0 AS PTOMovingDistance,
		CAST(YEAR(aa.CreationDateTime) AS varchar(4)) + '-' + CAST(dbo.LeadingZero(MONTH(aa.CreationDateTime),2) AS varchar(2)) + '-' + CAST(dbo.LeadingZero(DAY(aa.CreationDateTime),2) AS varchar(2)) + ' 00:00:00.000' AS Date,
		COUNT(*) AS Rows,
		0 AS DrivingFuel,
		0 AS PTOMovingTime,
		0 AS PTOMovingFuel,
		0 AS PTONonMovingTime,
		0 AS PTONonMovingFuel,
		0 AS DigitalInput2Count,
		
		aa.RouteID,
		
		0 AS ORCount
	FROM @t_Results aa
	WHERE aa.DrivingDistance IS NOT NULL
	GROUP BY aa.VehicleIntId, aa.DriverIntId, aa.RouteID,
		CAST(YEAR(aa.CreationDateTime) AS varchar(4)) + '-' + CAST(dbo.LeadingZero(MONTH(aa.CreationDateTime),2) AS varchar(2)) + '-' + CAST(dbo.LeadingZero(DAY(aa.CreationDateTime),2) AS varchar(2)) + ' 00:00:00.000'

	/********************************************************************************/
	/*				Finished processing data for non-CAN vehicles.					*/
	/********************************************************************************/
	
	
	

	INSERT INTO @tempResults1 (VehicleIntId, DriverIntId, RouteID, PassengerComfortScore, Date,PassComfID)
	Select VehicleIntID, DriverIntID, RouteID, cast((isnull(Score / dbo.ZeroYieldNull(DrivingDistance),0)) as float) as PassengerComfortScore,
	CAST(YEAR(CreationDateTime) AS varchar(4)) + '-' + CAST(dbo.LeadingZero(MONTH(CreationDateTime),2) AS varchar(2)) + '-' + CAST(dbo.LeadingZero(DAY(CreationDateTime),2) AS varchar(2)) + ' 00:00:00.000' AS Date,
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
					@CruiseControlDistance,
					@CruiseInTopGearsDistance,
					@CoastInGearDistance,
					@IdleTime,
					@TotalTime,
					@EngineBrakeDistance,
					@ServiceBrakeDistance,
					@EngineBrakeOverRPMDistance,
					@ROPCount,
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
					@ORCount

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
					CruiseControlDistance = CruiseControlDistance + ISNULL(@CruiseControlDistance,0),
					CruiseInTopGearsDistance = CruiseInTopGearsDistance + ISNULL(@CruiseInTopGearsDistance,0),
					CoastInGearDistance = CoastInGearDistance + ISNULL(@CoastInGearDistance,0),
					IdleTime = IdleTime + ISNULL(@IdleTime,0),
					TotalTime = TotalTime + ISNULL(@TotalTime,0),
					EngineBrakeDistance = EngineBrakeDistance + ISNULL(@EngineBrakeDistance,0),
					ServiceBrakeDistance = ServiceBrakeDistance + ISNULL(@ServiceBrakeDistance,0),
					EngineBrakeOverRPMDistance = EngineBrakeOverRPMDistance + ISNULL(@EngineBrakeOverRPMDistance,0),
					ROPCount = ROPCount + ISNULL(@ROPCount,0), 
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
					ORCount = ORCount + ISNULL(@ORCount,0)
				FROM Reporting
				WHERE ReportingId = @ReportingId

			END
			ELSE BEGIN
				-- No row yet so just insert a new one
				INSERT INTO Reporting (VehicleIntId, DriverIntId, InSweetSpotDistance, FueledOverRPMDistance,
					TopGearDistance, CruiseControlDistance, CruiseInTopGearsDistance, CoastInGearDistance, IdleTime, TotalTime,
					EngineBrakeDistance, ServiceBrakeDistance, EngineBrakeOverRPMDistance, ROPCount, OverSpeedDistance,
					CoastOutOfGearDistance, PanicStopCount, TotalFuel, TimeNoID, TimeID,
					DrivingDistance, PTOMovingDistance, Date, Rows, DrivingFuel,
					PTOMovingTime, PTOMovingFuel, PTONonMovingTime, PTONonMovingFuel,DigitalInput2Count,RouteID,PassengerComfort,ORCount)
				VALUES (@VehicleIntId, @DriverIntId, @InSweetSpotDistance, @FueledOverRPMDistance,
					@TopGearDistance, @CruiseControlDistance, @CruiseInTopGearsDistance, @CoastInGearDistance, @IdleTime, @TotalTime,
					@EngineBrakeDistance, @ServiceBrakeDistance, @EngineBrakeOverRPMDistance, @ROPCount, @OverSpeedDistance,
					@CoastOutOfGearDistance, @PanicStopCount, @TotalFuel, @TimeNoID, @TimeID,
					@DrivingDistance, @PTOMovingDistance, @Date, @Rows, @DrivingFuel,
					@PTOMovingTime,	@PTOMovingFuel,	@PTONonMovingTime,	@PTONonMovingFuel,@DigitalInput2Count,@RouteID,0,@ORCount)

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
