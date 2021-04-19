SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[proc_ProcessDgen4]
AS

SELECT MyVar = 5 INTO #ProcessDgen4

IF @@ERROR <> 0
BEGIN
	-- do nothing!
	SELECT 0
END
ELSE
BEGIN

	DECLARE @DGenTemp TABLE
		(
		  DgenId INT,
		  Tag VARCHAR(MAX),
		  IMEI VARCHAR(MAX),
		  OpenReason VARCHAR(MAX),
		  OpenDateTime DATETIME,
		  CloseReason VARCHAR(MAX),
		  CloseDateTime DATETIME,
		  Lat FLOAT,
		  Long FLOAT,
		  AccumSeq BIGINT,
		  NumRows INT,
		  NumCols INT,
		  SweetSpotLow INT,
		  SweetSpotHigh INT,
		  OverRev INT,
		  TotalTime INT,
		  TotalDistance FLOAT,
		  TotalFuel FLOAT,
		  RPM100Time INT,
		  RPM100Distance FLOAT,
		  RPM100Fuel FLOAT,
		  RPM0Time INT,
		  RPM0Distance FLOAT,
		  RPM0Fuel FLOAT
		)
	    
	DECLARE	@PayloadTable TABLE (
		Id INT,
		Value VARCHAR(MAX)
		)

	DECLARE @DGenId INT,
			@Payload VARCHAR(MAX),
			@NumRows INT,
			@NumCols INT,
			@CurrRow INT,
			@CurrCol INT,
			@RowId INT,
			@ColId INT,
			@SweetSpotLow INT,
			@SweetSpotHigh INT,
			@OverRev INT
			
	-- Initialise ProcessInd to 0 for rows about to be processed
	UPDATE dbo.DGen
	SET ProcessInd = 0
	WHERE DGenTypeId = 4
	  AND DGenIndexId = 0
	  AND ProcessInd IS NULL
	 
	-- Use a cursor to process each Dgen table entry in turn
	DECLARE TCursor CURSOR FAST_FORWARD READ_ONLY
	FOR
	SELECT d0.DGenId, LEFT(d0.Payload, LEN(d0.Payload)-4) + ISNULL(LEFT(d1.Payload, LEN(d1.Payload)-4), '')  -- CR/LF characters are stripped from the end of Payload
	FROM dbo.DGen d0
	LEFT OUTER JOIN dbo.Dgen d1 ON d1.DgenId = d0.DgenId + 1 AND d1.DgenIndexId = 1
	WHERE d0.DgenTypeId = 4
	  AND d0.DGenIndexId = 0
	  AND d0.ProcessInd = 0
	ORDER BY d0.DgenId

	OPEN TCursor
	FETCH NEXT FROM TCursor INTO @DGenId, @Payload

	WHILE @@FETCH_STATUS = 0 
	BEGIN

		-- Mark the DGen record as being processed
		UPDATE dbo.DGen
		SET ProcessInd = 2
		WHERE DGenId = @DGenId
	    
		INSERT INTO @PayloadTable (Id, Value)
		SELECT * FROM dbo.Split(@Payload,',')
	    
		INSERT  INTO @DgenTemp
		SELECT  DgenId,[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23]
		FROM    ( SELECT    @DgenId AS DGenId, Id, Value
				  FROM      @PayloadTable
				) AS SourceTable
		PIVOT
		(MAX(Value)
		FOR Id IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23]))
		AS PivotTable

		INSERT INTO DGenCharHeader (DgenId, Tag, IMEI, OpenReason, OpenDateTime, CloseReason, CloseDateTime, Lat, Long, AccumSeq, NumRows, NumCols, SweetSpotLow,
									SweetSpotHigh, OverRev, TotalTime, TotalDistance, TotalFuel, RPM100Time, RPM100Distance, RPM100Fuel, 
									RPM0Time, RPM0Distance, RPM0Fuel)
		SELECT DgenId, Tag, IMEI, OpenReason, OpenDateTime, CloseReason, CloseDateTime, Lat, Long, AccumSeq, NumRows, NumCols, SweetSpotLow, SweetSpotHigh,
			   OverRev, TotalTime, TotalDistance, TotalFuel, RPM100Time, RPM100Distance, RPM100Fuel, RPM0Time, RPM0Distance, RPM0Fuel
		FROM @DGenTemp
		WHERE DGenId = @DGenId

		SELECT @NumRows = NumRows, @NumCols = NumCols, @SweetSpotLow = SweetSpotLow, @SweetSpotHigh = SweetSpotHigh, @OverRev = OverRev
		FROM @DGenTemp
		
		DELETE FROM @DGenTemp -- Clean up the temp table
		
		-- Use a cursor to read the Ids of the first cell in each row of data
		DECLARE RowCursor CURSOR FAST_FORWARD READ_ONLY
		FOR
		SELECT Id-23
		FROM @PayloadTable
		WHERE Id > 23
		  AND (Id-24) % (@NumRows * 3) = 0
		ORDER BY Id
		
		OPEN RowCursor
		FETCH NEXT FROM RowCursor INTO @RowId
		SET @CurrRow = 0
		WHILE @@FETCH_STATUS = 0 AND @CurrRow < @NumRows 
		BEGIN
			-- Use 
			DECLARE ColCursor CURSOR FAST_FORWARD READ_ONLY
			FOR
			SELECT Id-23
			FROM @PayloadTable
			WHERE Id > 23 + (@CurrRow * (@NumCols * 3))
			  AND Id <= 23 + ((@CurrRow + 1) * (@NumCols * 3))
			  AND (Id-24) % 3 = 0
			ORDER BY Id
		
			OPEN ColCursor
			FETCH NEXT FROM ColCursor INTO @ColId	
			SET @CurrCol = 0
			WHILE @@FETCH_STATUS = 0 AND @CurrCol < @NumCols 
			BEGIN
				
				IF ISNULL((SELECT Value FROM @PayloadTable WHERE Id = @ColId + 23),0) != 0 -- Only insert values if non zero
				BEGIN
					INSERT INTO DGenCharData (DGenId, RowIndex, ColIndex, TimeVal, Distance, Fuel)
					SELECT	@DgenId, @CurrRow, @CurrCol, ptime.Value, pdist.Value, pfuel.Value
					FROM @PayloadTable ptime
					INNER JOIN @PayloadTable pdist ON pdist.Id = ptime.Id + 1
					INNER JOIN @PayloadTable pfuel ON pfuel.Id = ptime.Id + 2
					WHERE ptime.Id = @ColId + 23
						and pdist.Id = @ColId + 24
						and pfuel.Id = @ColId + 25
				END
				SET @CurrCol = @CurrCol + 1
				FETCH NEXT FROM ColCursor INTO @ColId
			END
			
			CLOSE ColCursor
			DEALLOCATE ColCursor
		
			SET @CurrRow = @CurrRow + 1
			FETCH NEXT FROM RowCursor INTO @RowId
		END
		
		CLOSE RowCursor
		DEALLOCATE RowCursor
		
		DELETE FROM @PayloadTable
		
		-- Mark the DGen Record as Processed
		UPDATE dbo.DGen
		SET ProcessInd = 1
		WHERE DGenId = @DGenId

		FETCH NEXT FROM TCursor INTO @DGenId, @Payload

	END

	CLOSE TCursor
	DEALLOCATE TCursor	

	-- Delete temporary table to indicate job has completed
	DROP TABLE #ProcessDgen4

END
			
                        
                        


GO
