SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
--DECLARE @cid uniqueidentifier
--DECLARE @depid int
--DECLARE @vid uniqueidentifier
--DECLARE @sdate datetime
--DECLARE @edate datetime
--DECLARE @reportparameter1 int
--DECLARE @idle int
--DECLARE @uid uniqueidentifier
--
--SET @uid ='0A1D381D-C989-4C1C-A09D-FBE00BB5B8A3'
--SET @sdate = '2011-11-21 16:54:00.000'
--SET @edate = '2011-11-22 01:34:59.000'
--SET @vid = N'D2E5A996-CE77-E011-A26E-001C23C37503'
----default stop time in minutes
--SET @idle = 5
----2 gaps 1 key switch
--SET @reportparameter1 = 2

CREATE PROC [dbo].[proc_GetReportStops_Cached]
    @cid UNIQUEIDENTIFIER = NULL,
    @depid INT = NULL,
    @vid UNIQUEIDENTIFIER = NULL,
    @sdate DATETIME,
    @edate DATETIME,
    @reportparameter1 INT = 2,
    @idle INT = 5,
    @uid UNIQUEIDENTIFIER = NULL
AS 
    DECLARE @moving INT
    DECLARE @stopped INT
    DECLARE @diststr VARCHAR(20)
    DECLARE @distmult FLOAT 
    DECLARE @defaultgap INT
	
    SELECT TOP 1
            @defaultgap = mingap
    FROM    dbo.[tripsandstopsconfig]
    WHERE   VehicleID = @vid
            OR vehicleid IS NULL
    ORDER BY tripsandstopsconfigid DESC

    IF @defaultgap IS NULL 
        BEGIN
            SET @defaultgap = 3
        END

    IF @reportparameter1 = 1 
        BEGIN
			SET @idle = 0
            SET @moving = 4
            SET @stopped = 5
        END
    IF @reportparameter1 = 2 
        BEGIN
            SET @moving = 1
            SET @stopped = 0
        END
        
	-- Section added to allow the report to be automatically scheduled
	IF datepart(yyyy, @sdate) = '1960'
	BEGIN
		SET @edate = dbo.Calc_Schedule_EndDate(@sdate, @uid)
		SET @sdate = dbo.Calc_Schedule_StartDate(@sdate, @uid)
	END

	DECLARE @s_date smalldatetime
	DECLARE @e_date smalldatetime
	SET @s_date = @sdate
	SET @e_date = @edate
    SET @sdate = dbo.TZ_ToUTC(@sdate, DEFAULT, @uid)
    SET @edate = dbo.TZ_ToUTC(@edate, DEFAULT, @uid)

    SELECT  @diststr = dbo.UserPref(@uid, 203) -- distance string
    SELECT  @distmult = CAST(dbo.UserPref(@uid, 202) AS FLOAT) * 100 -- distance multiplier

    IF @idle IS NULL 
        SET @idle = 0
	
    DECLARE @CustomerName1 VARCHAR(255)
    DECLARE @DepotName1 VARCHAR(255)
    DECLARE @Registration VARCHAR(255)
    DECLARE @Arrival1 SMALLDATETIME
    DECLARE @Address VARCHAR(255)
    DECLARE @Departure1 SMALLDATETIME
    DECLARE @Duration1 INT
    DECLARE @IdleTimeHours1 INT
    DECLARE @IdleTimeMinutes1 INT
    DECLARE @LatA1 FLOAT
    DECLARE @LongA1 FLOAT
    DECLARE @LatD1 FLOAT
    DECLARE @LongD1 FLOAT
    DECLARE @Arrival2 SMALLDATETIME
    DECLARE @Departure2 SMALLDATETIME
    DECLARE @Duration2 INT
    DECLARE @IdleTimeHours2 INT
    DECLARE @IdleTimeMinutes2 INT
    DECLARE @LatA2 FLOAT
    DECLARE @LongA2 FLOAT
    DECLARE @LatD2 FLOAT
    DECLARE @LongD2 FLOAT
    DECLARE @ReportDate1 SMALLDATETIME
    DECLARE @ReportYear1 VARCHAR(4)
    DECLARE @ReportMonth1 VARCHAR(2)
    DECLARE @ReportDay1 VARCHAR(2)
    DECLARE @ReportDate2 SMALLDATETIME
    DECLARE @ReportYear2 VARCHAR(4)
    DECLARE @ReportMonth2 VARCHAR(2)
    DECLARE @ReportDay2 VARCHAR(2)
    DECLARE @DurationFloat FLOAT
    DECLARE @DurationRound INT
    DECLARE @TZArrival SMALLDATETIME
    DECLARE @TZArrivalMonth INT
    DECLARE @TZArrivalDay INT
    DECLARE @TZDeparture SMALLDATETIME
    DECLARE @TZDepartureMonth INT
    DECLARE @TZDepartureDay INT
    DECLARE @EventId BIGINT
    DECLARE @EventLat FLOAT
    DECLARE @EventLong FLOAT

    IF @depid IS NULL
        AND @vid IS NOT NULL
        AND @sdate IS NOT NULL
        AND @edate IS NOT NULL 
        BEGIN
	-- broken needs to account for date
            SELECT TOP 1
                    @depid = CustomerIntId,
                    @DepotName1 = Name
            FROM    dbo.CustomerVehicle cv
					INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
            WHERE   cv.VehicleId = @vid
                    AND cv.StartDate <= @sdate
                    AND ( cv.EndDate IS NULL
                          OR cv.EndDate >= @edate
                        )
            ORDER BY cv.LastOperation DESC
        END

    DECLARE @stopreport TABLE
        (
          CustomerName VARCHAR(255),
          DepotName VARCHAR(255),
          Registration VARCHAR(255),
          [Address] VARCHAR(255),
          Lat FLOAT,
          Long FLOAT,
          Arrival SMALLDATETIME,
          Departure SMALLDATETIME,
          ReportDate SMALLDATETIME,
          IdleTimeHours INT,
          IdleTimeMinutes INT,
          IdleTime INT
        )

    DECLARE @cursorTable TABLE
        (
          registration VARCHAR(20),
          StartTripTime SMALLDATETIME,
          EndTripTime SMALLDATETIME,
          Duration INT,
          LatD1 FLOAT,
          LongD1 FLOAT,
          LatA1 FLOAT,
          LongA1 FLOAT,
          EventId BIGINT,
          DepotId INT
        )

    INSERT  INTO @cursorTable
            SELECT  registration,
                    t1.[timestamp],
                    t2.[timestamp],
                    t2.duration,
                    t1.Latitude,
                    t1.Longitude,
                    t2.Latitude,
                    t2.Longitude,
                    t1.EventId,
                    @depid
            FROM    dbo.[tripsandstops] t1
                    INNER JOIN dbo.[tripsandstops] t2 ON t2.previousid = t1.tripsandstopsid
                    INNER JOIN dbo.[vehicle] v ON t1.VehicleIntID = v.VehicleIntId
            WHERE   ( v.vehicleid = @vid
                      OR @vid IS NULL
                    )
                    AND t1.CustomerIntID = @depid
                    AND ( ( t1.[timestamp] >= @sdate
                            AND t2.[timestamp] <= @edate
                          )
                          OR ( t1.[timestamp] <= @edate
                               AND t2.[timestamp] > @edate
                             )
                          OR ( t1.[timestamp] < @sdate
                               AND t2.[timestamp] >= @sdate
                             )
                        )
                    AND t1.vehiclestate = @stopped
                    AND t2.vehiclestate = @moving
                    AND NOT ( t1.latitude = 0
                              AND t1.longitude = 0
                              AND t2.latitude = 0
                              AND t2.longitude = 0
                            )
            ORDER BY v.vehicleid,
                    t1.tripsandstopsid

    DECLARE STOPCALCCURSOR CURSOR FAST_FORWARD READ_ONLY
        FOR SELECT  *
            FROM    @cursorTable
    OPEN STOPCALCCURSOR
    FETCH NEXT FROM STOPCALCCURSOR INTO @Registration, @Arrival1, @Departure1,
        @Duration1, @LatA1, @LongA1, @LatD1, @LongD1, @EventId, @depid
    WHILE @@FETCH_STATUS = 0
        BEGIN
	--Store the fresh data
            SET @Arrival2 = @Arrival1
            SET @Departure2 = @Departure1
            SET @Duration2 = @Duration1
            SET @LatA2 = @LatA1
            SET @LongA2 = @LongA1
            SET @LatD2 = @LatD1
            SET @LongD2 = @LongD1
	
            SELECT  @EventLat = Lat,
                    @EventLong = Long
            FROM    dbo.[Event]
            WHERE   EventId = @EventId
                    AND CustomerIntId = @depid
	
            FETCH NEXT FROM STOPCALCCURSOR INTO @Registration, @Arrival1,
                @Departure1, @Duration1, @LatA1, @LongA1, @LatD1, @LongD1,
                @EventId, @depid

		-- check to see if stop is required to be shown based on gap parameter
            IF ROUND(@Duration2 / 60, 0) >= @idle 
                BEGIN
                    SET @Address = [dbo].GetAddressFromLongLat(@LatA2, @LongA2)
				
				--Get geofence name if such geofence exists
                    SET @Address = [dbo].[GetGeofenceNameFromLongLat](@LatA2, @LongA2, @uid, @Address)	
                    SET @TZArrival = dbo.TZ_GetTime(@Arrival2, DEFAULT, @uid)
                    SET @TZDeparture = dbo.TZ_GetTime(@Departure2, DEFAULT,
                                                      @uid)
                    SET @TZArrivalMonth = MONTH(@TZArrival)
                    SET @TZArrivalDay = DAY(@TZArrival)
                    SET @TZDepartureMonth = MONTH(@TZDeparture)
                    SET @TZDepartureDay = DAY(@TZDeparture)
                    SET @ReportYear1 = CAST(YEAR(@TZArrival) AS VARCHAR(4))
                    SET @ReportMonth1 = CASE WHEN @TZArrivalMonth > 9
                                             THEN CAST(@TZArrivalMonth AS VARCHAR(2))
                                             ELSE '0'
                                                  + CAST(@TZArrivalMonth AS VARCHAR(1))
                                        END
                    SET @ReportDay1 = CASE WHEN @TZArrivalDay > 9
                                           THEN CAST(@TZArrivalDay AS VARCHAR(2))
                                           ELSE '0'
                                                + CAST(@TZArrivalDay AS VARCHAR(1))
                                      END
                    SET @ReportDate1 = @ReportYear1 + '-' + @ReportMonth1
                        + '-' + @ReportDay1 + ' 00:00:00.000'
                    SET @ReportYear2 = CAST(YEAR(@TZDeparture) AS VARCHAR(4))
                    SET @ReportMonth2 = CASE WHEN @TZDepartureMonth > 9
                                             THEN CAST(@TZDepartureMonth AS VARCHAR(2))
                                             ELSE '0'
                                                  + CAST(@TZDepartureMonth AS VARCHAR(1))
                                        END
                    SET @ReportDay2 = CASE WHEN @TZDepartureDay > 9
                                           THEN CAST(@TZDepartureDay AS VARCHAR(2))
                                           ELSE '0'
                                                + CAST(@TZDepartureDay AS VARCHAR(1))
                                      END
                    SET @ReportDate2 = @ReportYear2 + '-' + @ReportMonth2
                        + '-' + @ReportDay2 + ' 00:00:00.000'
                    IF @TZArrivalDay = @TZDepartureDay 
                        BEGIN
                            SET @DurationFloat = CAST(@Duration2 AS FLOAT)
                                / 60
                            SET @DurationRound = CAST(ROUND(@DurationFloat, 0) AS INT)
                            INSERT  INTO @stopreport
                                    (
                                      CustomerName,
                                      DepotName,
                                      Registration,
                                      Arrival,
                                      [Address],
                                      Lat,
                                      Long,
                                      Departure,
                                      ReportDate,
                                      IdleTimeHours,
                                      IdleTimeMinutes,
                                      IdleTime
                                    )
                            VALUES  (
                                      @CustomerName1,
                                      @DepotName1,
                                      @Registration,
                                      @TZArrival,
                                      @Address,
                                      @EventLat,
                                      @EventLong,
                                      @TZDeparture,
                                      @ReportDate1,
                                      CAST(@DurationFloat / 60 AS INT),
                                      @DurationRound % 60,
                                      @DurationRound
                                    )
                        END
                    ELSE 
                        BEGIN
                            INSERT  INTO @stopreport
                                    (
                                      CustomerName,
                                      DepotName,
                                      Registration,
                                      Arrival,
                                      [Address],
                                      Lat,
                                      Long,
                                      ReportDate
                                    )
                            VALUES  (
                                      @CustomerName1,
                                      @DepotName1,
                                      @Registration,
                                      @TZArrival,
                                      @Address,
                                      @EventLat,
                                      @EventLong,
                                      @ReportDate1
                                    )
                            INSERT  INTO @stopreport
                                    (
                                      CustomerName,
                                      DepotName,
                                      Registration,
                                      [Address],
                                      Lat,
                                      Long,
                                      Departure,
                                      ReportDate
                                    )
                            VALUES  (
                                      @CustomerName1,
                                      @DepotName1,
                                      @Registration,
                                      @Address,
                                      @EventLat,
                                      @EventLong,
                                      @TZDeparture,
                                      @ReportDate2
                                    )
                        END

                END

        END
    CLOSE STOPCALCCURSOR
    DEALLOCATE STOPCALCCURSOR

    SELECT  *
    FROM    @stopreport
	WHERE Arrival BETWEEN @s_date AND @e_date
    ORDER BY Registration,
            ReportDate,
            Arrival,
            Departure

GO
