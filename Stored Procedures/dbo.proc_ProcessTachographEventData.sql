SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ProcessTachographEventData] 
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @vehicleIntId INT,
			@driverIntId INT,
			@date SMALLDATETIME,
			@EventDataString VARCHAR(1024),
			@driverid VARCHAR(255)

	DECLARE @tachodata TABLE
	(
		VehicleIntId INT,
		DriverIntId INT,
		Rest INT,
		Available INT,
		Work INT,
		Drive INT,
		Error INT,
		Unavailable INT,
		Unknown INT,
		Date SMALLDATETIME
	)


	-- Mark all relevant rows in EDC
	UPDATE EventDataTachograph
	SET Archived = 1

	-- Cursor rouns each row in the table so that the values can be parsed from the EventDataString using dbo.Split
	DECLARE rowCursor CURSOR FAST_FORWARD READ_ONLY
	FOR 
		SELECT VehicleIntId, CAST(FLOOR(CAST(EventDateTime AS FLOAT)) AS DATETIME), EventDataString
		FROM dbo.EventDataTachograph
		WHERE Archived = 1

	OPEN rowCursor
	FETCH NEXT FROM rowCursor INTO @vehicleIntId, @date, @EventDataString
	WHILE @@FETCH_STATUS = 0
	BEGIN	

		-- First identify the driver from the first parameter of the payload
		SET @driverid = NULL
		SELECT @driverid = Value
		FROM dbo.Split(@EventDataString, ',')
		WHERE Id = 1
		
		--Remove the issue number
		IF LEN(@driverid) > 14
		BEGIN
			SET @driverid = LEFT(@driverid, 14)
		END

		IF @driverid != 'No ID'
		BEGIN	
			SELECT TOP 1 @driverIntId = DriverIntId
			FROM dbo.Driver
			WHERE (Number = @driverid OR NumberAlternate = @driverid OR NumberAlternate2 = @driverid)
			  AND Archived = 0
			ORDER BY LastOperation DESC	

			INSERT INTO @tachodata
					(VehicleIntId,
					 DriverIntId,
					 Rest,
					 Available,
					 Work,
					 Drive,
					 Error,
					 Unavailable,
					 Unknown,
					 Date
					)
			SELECT	@vehicleIntId, 
					@driverIntId, 
					SUM(CASE WHEN Id = 2 THEN Value ELSE 0 END),
					SUM(CASE WHEN Id = 3 THEN Value ELSE 0 END),
					SUM(CASE WHEN Id = 4 THEN Value ELSE 0 END),
					SUM(CASE WHEN Id = 5 THEN Value ELSE 0 END),
					SUM(CASE WHEN Id = 6 THEN Value ELSE 0 END),
					SUM(CASE WHEN Id = 7 THEN Value ELSE 0 END),
					SUM(CASE WHEN Id = 8 THEN Value ELSE 0 END),
					@date
			FROM dbo.Split(@EventDataString, ',')
		END	

		FETCH NEXT FROM rowCursor INTO @vehicleIntId, @date, @EventDataString
	END
	CLOSE rowCursor
	DEALLOCATE rowCursor

	SELECT *
	FROM @tachodata t
	INNER JOIN dbo.Driver d ON d.DriverIntId = t.DriverIntId

	-- Now accumulate the data using MERGE into ReportingTachograph
	MERGE dbo.ReportingTachograph AS tgt
	USING (SELECT VehicleIntId ,
				  DriverIntId ,
				  SUM(Rest) AS Rest,
				  SUM(Available) AS Available,
				  SUM(Work) AS Work,
				  SUM(Drive) AS Drive,
				  SUM(Error) AS Error,
				  SUM(Unavailable) AS Unavailable,
				  SUM(Unknown) AS Unknown,
				  Date
				FROM @tachodata
				GROUP BY VehicleIntId, DriverIntId, Date) AS src (VehicleIntId, DriverIntId, Rest, Available, Work, Drive, Error, Unavailable, Unknown, Date)
	ON (tgt.VehicleIntId = src.VehicleIntId AND tgt.DriverIntId = src.DriverIntId AND tgt.Date = src.Date)
	WHEN MATCHED

		THEN UPDATE SET tgt.Rest = tgt.Rest + src.Rest,
						tgt.Available = tgt.Available + src.Available,
						tgt.Work = tgt.Work + src.Work,
						tgt.Drive = tgt.Drive + src.Drive,
						tgt.Error = tgt.Error + src.Error,
						tgt.Unavailable = tgt.Unavailable + src.Unavailable,
						tgt.Unknown = tgt.Unknown + src.Unknown
	WHEN NOT MATCHED
		THEN INSERT	(VehicleIntId, DriverIntId, Rest, Available, Work, Drive, Error, Unavailable, Unknown, Date)
			 VALUES	(src.VehicleIntId, src.DriverIntId, src.Rest, src.Available, src.Work, src.Drive, src.Error, src.Unavailable, src.Unknown, src.Date);	

	-- Clean up processed rows
	DELETE FROM dbo.EventDataTachograph
	WHERE archived = 1 

END



GO
