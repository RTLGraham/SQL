SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[proc_ProcessDgen7]
AS

BEGIN

	DECLARE @Characteristics TABLE
		(
		  CharId INT,
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
		  CustomerIntId INT,
		  VehicleIntId INT,
		  DriverIntId INT
		)

	DECLARE	@PayloadTable TABLE (
		Id INT,
		Value VARCHAR(MAX)
		)

	DECLARE @CharId INT,
			@Payload VARCHAR(MAX),
			@Value VARCHAR(20),
			@NumRows INT,
			@NumCols INT,
			@CurrRow INT,
			@CurrCol INT,
			@Id INT,
			@RowId INT,
			@ColId INT,
			@Config VARCHAR(MAX),
			@CharMatrixId INT,
			@CustomerIntId INT,
			@VehicleIntId INT,
			@DriverIntId INT
			
	-- Initialise ProcessInd to 0 for rows about to be processed
	UPDATE dbo.DGen
	SET ProcessInd = 0
	WHERE DGenTypeId = 7
	  AND DGenIndexId = 0
	  AND ProcessInd IS NULL
	 
	-- Use a cursor to process each Dgen table entry in turn
	DECLARE TCursor CURSOR FAST_FORWARD READ_ONLY
	FOR
	SELECT d0.DGenId, LEFT(d0.Payload, LEN(d0.Payload)-4) + ISNULL(LEFT(d1.Payload, LEN(d1.Payload)-4), ''),  -- CR/LF characters are stripped from the end of Payload
		   d0.CustomerIntId, d0.VehicleIntId, d0.DriverIntId
	FROM dbo.DGen d0
	LEFT OUTER JOIN dbo.Dgen d1 ON d1.DgenId = d0.DgenId + 1 AND d1.DgenIndexId = 1
	WHERE d0.DgenTypeId = 7
	  AND d0.DGenIndexId = 0
	  AND d0.ProcessInd = 0
	ORDER BY d0.DgenId DESC	

	OPEN TCursor
	FETCH NEXT FROM TCursor INTO @CharId, @Payload, @CustomerIntId, @VehicleIntId, @DriverIntId

	WHILE @@FETCH_STATUS = 0 
	BEGIN

		-- Mark the DGen record as being processed
		UPDATE dbo.DGen
		SET ProcessInd = 2
		WHERE DGenId = @CharId
	    
		-- Split the payload using the comma separator
		INSERT INTO @PayloadTable (Id, Value)
		SELECT * FROM dbo.Split(@Payload,',')
	    
		-- Now parse the data into the temporary Characteristics table
		INSERT  INTO @Characteristics
		SELECT  CharId,[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11], @CustomerIntId, @VehicleIntId, @DriverIntId
		FROM    ( SELECT    @CharId AS CharId, Id, Value
				  FROM      @PayloadTable
				) AS SourceTable
		PIVOT
		(MAX(Value)
		FOR Id IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11]))
		AS PivotTable

		-- Record the number of rows and columns for later use
		SELECT @NumRows = NumRows, @NumCols = NumCols
		FROM @Characteristics

		IF ISNULL(@NumRows, 0) > 0 -- Only process data if number of rows (and therefore columns) is greater than 0
		BEGIN	
		
			-- Parse the appropriate section of the Payload to build the matrix configuration ready to test against the CharacteristicsMatrix table
			SET @Config = '' -- Initialise
			SELECT @Config = COALESCE(@Config + CAST(Value AS VARCHAR(MAX)) + ',', '')
			FROM @PayloadTable
			WHERE Id > 11
			  AND Id <= (@NumRows * 3) + 11
			ORDER BY Id

			-- Remove trailing comma
			IF @config != '' SET @Config = LEFT(@Config, LEN(@Config) - 1)

			SET @CharMatrixId = NULL -- Initialise
			-- See if we have a matrix of this type already
			SELECT @CharMatrixId = CharMatrixId
			FROM dbo.CharacteristicsMatrix
			WHERE Config = @Config AND NumRows = @NumRows AND NumCols = @NumCols

			IF @CharMatrixId IS NULL -- this is a new matrix type so insert it	
			BEGIN
				INSERT INTO dbo.CharacteristicsMatrix (Config, NumRows, NumCols)
				VALUES  (@Config, @NumRows, @NumCols)

				SELECT @CharMatrixId = SCOPE_IDENTITY()
			END	

			---- Now insert the Characteristics row
			INSERT INTO Characteristics (CharId, Tag, IMEI, OpenReason, OpenDateTime, CloseReason, CloseDateTime, Lat, Long, AccumSeq, NumRows, NumCols, CharMatrixId, CustomerIntId, VehicleIntId, DriverIntId, Archived)
			SELECT CharId, Tag, IMEI, OpenReason, OpenDateTime, CloseReason, CloseDateTime, Lat, Long, AccumSeq, NumRows, NumCols, @CharMatrixId, @CustomerIntId, @VehicleIntId, @DriverIntId, 0
			FROM @Characteristics
			WHERE CharId = @CharId

			DELETE FROM @Characteristics -- Clean up the temp table ready for the next iteration

			-- Use a cursor to identify the Ids of the first cell in each column of data and then write each triplet of Time, Distance and Fuel (Skip the first three items as are these are the totals)
			DECLARE ColCursor CURSOR FAST_FORWARD READ_ONLY
			FOR
			SELECT Id - (12 + @NumCols * 3)
			FROM @PayloadTable
			WHERE Id > (12 + @NumCols * 3)
			  AND (Id-(12 + @NumCols * 3)) % (@NumCols * 3) = 0
			ORDER BY Id
		
			OPEN ColCursor
			FETCH NEXT FROM ColCursor INTO @ColId
			SET @CurrCol = 0
			WHILE @@FETCH_STATUS = 0 AND @CurrCol < @NumCols 
			BEGIN
				-- Use 
				DECLARE RowCursor CURSOR FAST_FORWARD READ_ONLY
				FOR
				SELECT Id-(12 + @NumCols * 3)
				FROM @PayloadTable
				WHERE Id > (12 + @NumCols * 3) + (@CurrCol * (@NumRows * 3))
				  AND Id <= (12 + @NumCols * 3) + ((@CurrCol + 1) * (@NumRows * 3))
				  AND (Id-(12 + @NumCols * 3)) % 3 = 0
				ORDER BY Id
		
				OPEN RowCursor
				FETCH NEXT FROM RowCursor INTO @RowId	
				SET @CurrRow = 0
				WHILE @@FETCH_STATUS = 0 AND @CurrRow < @NumRows 
				BEGIN
				
					IF ISNULL((SELECT Value FROM @PayloadTable WHERE Id = @RowId + (12 + @NumCols * 3)),0) != 0 -- Only insert values if non zero
					BEGIN
						INSERT INTO dbo.CharacteristicsCell (CharId, RowIndex, ColIndex, TimeVal, Distance, Fuel)
						SELECT	@CharId, @CurrRow, @CurrCol, ptime.Value, pdist.Value, pfuel.Value
						FROM @PayloadTable ptime
						INNER JOIN @PayloadTable pdist ON pdist.Id = ptime.Id + 1
						INNER JOIN @PayloadTable pfuel ON pfuel.Id = ptime.Id + 2
						WHERE ptime.Id = @RowId + (12 + @NumCols * 3)
							and pdist.Id = @RowId + (13 + @NumCols * 3)
							and pfuel.Id = @RowId + (14 + @NumCols * 3)
					END
					SET @CurrRow = @CurrRow + 1
					FETCH NEXT FROM RowCursor INTO @RowId
				END
			
				CLOSE RowCursor
				DEALLOCATE RowCursor
		
				SET @CurrCol = @CurrCol + 1
				FETCH NEXT FROM ColCursor INTO @ColId
			END
		
			CLOSE ColCursor
			DEALLOCATE ColCursor
		
		END -- Row and Column processing

		DELETE FROM @PayloadTable
		
		-- Mark the DGen Record as Processed
		UPDATE dbo.DGen
		SET ProcessInd = 1
		WHERE DGenId = @CharId

		FETCH NEXT FROM TCursor INTO @CharId, @Payload, @CustomerIntId, @VehicleIntId, @DriverIntId

	END

	CLOSE TCursor
	DEALLOCATE TCursor	

END


GO
