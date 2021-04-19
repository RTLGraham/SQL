SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

-- =======================================================================================================
-- Author:		<Dmitrijs Jurins>
-- Create date: <2012-02-17>
-- Description:	<Populates ReportingOverspeed table with overspeed distances>
-- Limitations: <Doesn't support overlaping data. Relies on data from the tracking unit.>
-- Modified by: GP 15/05/2013 <Fix problem where same driver (or No ID driver) logged in more 
--				than once per day caused occasional excessive overspeed distance>  
--
--				GP 07/03/2016 <Points with OdoGPS = 0 were excluded because cameras often did not
--				provide a value. This has been changed so that DistanceBetweenPoints is used if no OdoGPS>
--
--				GP 21/02/2018 <Added update of EventSpeeding table to record distance that has
--				nominally been attributed to each speeding point>
--
--				GP 08/08/2019 <Speeding points that have successfully been disputed are now excluded>
-- =======================================================================================================
CREATE PROCEDURE [dbo].[proc_PopulateReportingOverspeed] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Always run for today and the last 2 days to capture any late data
	DECLARE @sdate DATETIME,
			@edate DATETIME

	SET @edate = GETUTCDATE()
	SET @sdate = DATEADD(DAY, -2, @edate)

	--Declare tables & variables
	DECLARE @TempTable TABLE (
		VehicleIntId INT,
		DriverIntId INT,
		OverspeedDistance INT,
		OverSpeedHighDistance INT,
		Date DATETIME,
		Rows INT
		)

	DECLARE @data TABLE
		(
			VehicleIntId INT,
			DriverIntId INT,
			EventSpeedingId BIGINT NULL,
			Speed INT,
			SpeedLimit INT,
			Distance BIGINT,
			Lat FLOAT,
			Long FLOAT,
			EventDateTime DATETIME,
			EventDateTimeReal DATETIME,
			OverSpeedValue INT,
			OverSpeedPercent FLOAT,
			OverSpeedHighValue INT,
			OverSpeedHighPercent FLOAT,
			Multiplier FLOAT
		)

	DECLARE @curs_vehicleIntId INT,
			@curs_driverIntId INT,

			@VehicleIntId INT,
			@DriverIntId INT,
			@EventSpeedingId BIGINT,
			@Speed INT,
			@SpeedLimit INT,
			@Distance BIGINT,
			@Lat FLOAT,
			@Long FLOAT,
			@EventDateTime DATETIME,
			@EventDateTimeReal DATETIME,

			@OverSpeedValue INT, 
			@OverSpeedPercent FLOAT, 
			@OverSpeedHighValue INT, 
			@OverSpeedHighPercent FLOAT,

			@Multiplier FLOAT,

			@prev_VehicleIntId INT,
			@prev_DriverIntId INT,
			@prev_EventSpeedingId BIGINT,
			@prev_Speed INT,
			@prev_SpeedLimit INT,
			@prev_Distance BIGINT,
			@prev_Lat FLOAT,
			@prev_Long FLOAT,
			@prev_EventDateTime DATETIME,
			@prev_EventDateTimeReal DATETIME,

			@cursor_rows INT,
			@current_row INT,
			@speeding_dist INT,
			@speedinghigh_dist INT,
			@distTravelled BIGINT,

			@eventSpeedDist INT,
			@eventSpeedHighDist INT,

			@day DATETIME

	--Fetch data
	INSERT INTO @data(VehicleIntId, DriverIntId, EventSpeedingId, Speed, SpeedLimit, Distance, Lat, Long, EventDateTime, EventDateTimeReal, OverSpeedValue, OverSpeedPercent, OverSpeedHighValue, OverSpeedHighPercent, Multiplier)
		SELECT e.VehicleIntId , e.DriverIntId, es.EventId, e.Speed , ISNULL(e.SpeedLimit, es.SpeedLimit) , e.OdoGPS , e.Lat, e.Long,
			CAST(FLOOR(CAST(e.EventDateTime AS FLOAT)) AS DATETIME),
			e.EventDateTime, c.OverSpeedValue, c.OverSpeedPercent, c.OverSpeedHighValue, c.OverSpeedHighPercent, /*dbo.GetDistanceMultiplierByLatLon(e.Lat, e.Long),*/ CASE WHEN es.SpeedUnit = 'M' THEN 1.60934 ELSE 1 END 
		FROM dbo.Event e WITH (NOLOCK)
			LEFT JOIN dbo.EventSpeeding es ON es.EventId = e.EventId AND ISNULL(es.ChallengeInd, 0) != 2 -- exclude Speeding Events that have successfully been disputed
			INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
			INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
			INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
		WHERE e.EventDateTime BETWEEN @sdate AND @edate
		  AND c.Archived = 0 AND v.Archived = 0 AND cv.EndDate IS NULL AND cv.Archived = 0
		  AND e.Lat != 0 AND e.Long != 0
		  AND e.CreationCodeId NOT IN (77,78) -- trip start/end interefere with distance processing
		  --AND e.OdoGPS != 0 -- many camera events do not contain OdoGPS -- now removed and handled later in the script
		  AND (c.OverSpeedValue IS NOT NULL OR c.OverSpeedPercent IS NOT NULL)
		GROUP BY e.VehicleIntId , e.DriverIntId, es.EventId, e.Speed , e.SpeedLimit, es.SpeedLimit ,e.OdoGPS , e.Lat, e.Long,
			FLOOR(CAST(e.EventDateTime AS FLOAT)),
			e.EventDateTime, 
			c.OverSpeedValue, c.OverSpeedPercent, c.OverSpeedHighValue, c.OverSpeedHighPercent, es.SpeedUnit

	DECLARE vehicle_cur CURSOR FAST_FORWARD FOR
		SELECT DISTINCT VehicleIntId, EventDateTime FROM @data

	OPEN vehicle_cur
	FETCH NEXT FROM vehicle_cur INTO @curs_vehicleIntId, @day
	WHILE @@fetch_status = 0
	BEGIN

		SET @speeding_dist = 0
		SET @speedinghigh_dist = 0
		SET @cursor_rows = 0
		SET @current_row = 1

		SET @prev_VehicleIntId = NULL
		SET @prev_DriverIntId = NULL

		DECLARE data_cur CURSOR STATIC FOR
			SELECT VehicleIntId, DriverIntId, EventSpeedingId, Speed, SpeedLimit, Distance, Lat, Long, EventDateTime, EventDateTimeReal, OverSpeedValue, OverSpeedPercent, OverSpeedHighValue, OverSpeedHighPercent, Multiplier
			FROM @data
			WHERE VehicleIntId = @curs_vehicleIntId
				AND EventDateTime = @day 
			ORDER BY EventDateTimeReal ASC

		OPEN data_cur
		FETCH NEXT FROM data_cur INTO @VehicleIntId, @DriverIntId, @EventSpeedingId, @Speed, @SpeedLimit, @Distance, @Lat, @Long, @EventDateTime, @EventDateTimeReal, @OverSpeedValue, @OverSpeedPercent, @OverSpeedHighValue, @OverSpeedHighPercent, @Multiplier

		WHILE @@fetch_status = 0
		BEGIN

			IF @DriverIntId != @prev_DriverIntId
			BEGIN
				IF @speeding_dist > 0 OR @speedinghigh_dist > 0
				BEGIN

					INSERT INTO @TempTable (VehicleIntId, DriverIntId, OverspeedDistance, OverSpeedHighDistance, Date, Rows)
					VALUES (@curs_vehicleIntId, @prev_driverIntId, @speeding_dist, @speedinghigh_dist, @day, @cursor_rows)			
					--Reset values for next driver
					SET @speeding_dist = 0
					SET @speedinghigh_dist = 0
					SET @cursor_rows = 0				
				END
				SET @prev_Speed = NULL
				SET @prev_SpeedLimit = NULL
				SET @prev_Distance = 0
				SET @prev_EventSpeedingId = @EventSpeedingId
				SET @prev_Lat = @Lat
				SET @prev_Long = @Long
				SET @prev_EventDateTime = NULL
				SET @prev_EventDateTimeReal = NULL
			END

			IF ISNULL(@Distance, 0) = 0 OR ISNULL(@prev_Distance, 0) = 0
				-- No GPS Distance available so calculate distance between current and previous GPS position
				SELECT @distTravelled = dbo.DistanceBetweenPoints(@Lat, @Long, @prev_Lat, @prev_Long) * 1000
			ELSE
				-- Just calculate from OdoGPS provided
				SET @distTravelled = @Distance - @prev_Distance	

			--GET threshold
			IF (@distTravelled) > 0 AND @DriverIntId = @prev_DriverIntId
			BEGIN

				--Initialise event distance variables
				SET @eventSpeedDist = 0
				SET @eventSpeedHighDist = 0

				-- Check for High Speeding
				IF @prev_SpeedLimit BETWEEN 1 AND 240
					AND (((@prev_Speed * 100) / (@prev_SpeedLimit * @Multiplier)) - 100 > ISNULL(@OverSpeedHighPercent,999) -- Over Percentage
					 OR @prev_Speed - (@prev_SpeedLimit * @Multiplier) > ISNULL(@OverSpeedHighValue, 999)) -- Over Value
				BEGIN
					--Previous point was a speeding high point
					SET @eventSpeedHighDist = @distTravelled
					SET @speedinghigh_dist = @speedinghigh_dist + @distTravelled
				END	

				-- Repeat Check for normal speeding
				--IF @prev_SpeedLimit IS NOT NULL AND @prev_SpeedLimit != 255 --AND (@prev_Speed + @Threshold) > @prev_SpeedLimit
				IF @prev_SpeedLimit BETWEEN 1 AND 240
					AND (((@prev_Speed * 100) / (@prev_SpeedLimit * @Multiplier)) - 100 > ISNULL(@OverSpeedPercent,999) -- Over Percentage
					 OR @prev_Speed - (@prev_SpeedLimit * @Multiplier) > ISNULL(@OverSpeedValue, 999) -- Over Value
					 OR (@OverSpeedPercent IS NULL AND @OverSpeedValue IS NULL)) -- No thresholds set
				BEGIN
					--Previous point was a speeding point
					SET @eventSpeedDist = @distTravelled
					SET @speeding_dist = @speeding_dist + @distTravelled
					SET @cursor_rows = @cursor_rows + 1

					-- Update EventSpeeding Row
					IF @prev_eventSpeedingId IS NOT NULL
					BEGIN		
						UPDATE dbo.EventSpeeding
						SET SpeedingDistance = @eventSpeedDist, SpeedingHighDistance = @eventSpeedHighDist
						WHERE EventId = @prev_EventSpeedingId
					END	

				END
			
			END

			SET @prev_VehicleIntId = @VehicleIntId
			SET @prev_DriverIntId = @DriverIntId
			SET @prev_EventSpeedingId = @EventSpeedingId
			SET @prev_Speed = @Speed
			SET @prev_SpeedLimit = @SpeedLimit
			SET @prev_Distance = @Distance
			SET @prev_Lat = @Lat
			SET @prev_Long = @Long
			SET @prev_EventDateTime = @EventDateTime
			SET @prev_EventDateTimeReal = @EventDateTimeReal
			SET @current_row = @current_row + 1

			FETCH NEXT FROM data_cur INTO @VehicleIntId, @DriverIntId, @eventSpeedingId, @Speed, @SpeedLimit, @Distance, @Lat, @Long, @EventDateTime, @EventDateTimeReal, @OverSpeedValue, @OverSpeedPercent, @OverSpeedHighValue, @OverSpeedHighPercent, @Multiplier
		END
		CLOSE data_cur
		DEALLOCATE data_cur

		IF @DriverIntId = @prev_DriverIntId AND (@speeding_dist > 0 OR @speedinghigh_dist > 0) -- ensure last row for this vehicle is written if required
		BEGIN
			INSERT INTO @TempTable (VehicleIntId, DriverIntId, OverspeedDistance, OverSpeedHighDistance, Date, Rows)
			VALUES (@curs_vehicleIntId, @prev_driverIntId, @speeding_dist, @speedinghigh_dist, @day, @cursor_rows)
		END		

		FETCH NEXT FROM vehicle_cur INTO @curs_vehicleIntId, /*@curs_driverIntId,*/ @day
	END
	CLOSE vehicle_cur
	DEALLOCATE vehicle_cur

	-- Perform checks against total distance on Reporting table to ensure we are not inserting any bad data (speeding distance > total distance)
	DELETE
	FROM @TempTable
	FROM @TempTable t
	INNER JOIN dbo.Reporting r ON r.VehicleIntId = t.VehicleIntId AND r.DriverIntId = t.DriverIntId AND r.Date = t.Date
	LEFT JOIN dbo.ReportingOverspeed ro ON ro.VehicleIntId = t.VehicleIntId AND ro.DriverIntId = t.DriverIntId AND ro.Date = t.Date
	WHERE (t.OverspeedDistance + ISNULL(ro.OverspeedDistance, 0) > r.DrivingDistance*1000)
	   OR (t.OverSpeedHighDistance + ISNULL(ro.OverSpeedHighDistance, 0) > r.DrivingDistance*1000)

	-- Now update the ReportingOverspeed table using MERGE to perform an INSERT or UPDATE accordingly	
	MERGE dbo.ReportingOverspeed AS tgt
	USING (SELECT VehicleIntId ,


				  DriverIntId ,
				  SUM(CAST(OverspeedDistance AS FLOAT)) AS OverSpeedDistance,
				  SUM(CAST(OverspeedHighDistance AS FLOAT)) AS OverSpeedHighDistance,
				  Date,
				  SUM(ROWS)
				FROM @TempTable
				GROUP BY VehicleIntId, DriverIntId, Date) AS src (VehicleIntId, DriverIntId, OverSpeedDistance, OverSpeedHighDistance, Date, Rows)
	ON (tgt.VehicleIntId = src.VehicleIntId AND tgt.DriverIntId = src.DriverIntId AND tgt.Date = src.Date)
	WHEN MATCHED

		THEN UPDATE SET tgt.OverspeedDistance = CAST(src.OverSpeedDistance AS FLOAT) / 1000.0,
						tgt.OverSpeedHighDistance = CAST(src.OverspeedHighDistance AS FLOAT) / 1000.0,
						tgt.Rows = src.Rows
	WHEN NOT MATCHED
		THEN INSERT	(VehicleIntId, DriverIntId, OverspeedDistance, Date, Rows, OverSpeedHighDistance)
			 VALUES	(src.VehicleIntId, src.DriverIntId, CAST(src.OverSpeedDistance AS FLOAT) / 1000.0, src.Date, src.Rows, CAST(src.OverspeedHighDistance AS FLOAT) / 1000.0);

END



GO
