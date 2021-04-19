SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[proc_ReportEngineHours] 
@vid uniqueidentifier = NULL, @sdate datetime, @edate datetime, @uid uniqueidentifier = NULL
AS  


--DECLARE @vid UNIQUEIDENTIFIER
--DECLARE @sdate DATETIME
--DECLARE @edate DATETIME
--DECLARE @uid UNIQUEIDENTIFIER

--SET @uid = N'e3acb89a-e2f7-4325-8f2a-c228ff9056ba' 
--SET @sdate = '2017-05-11 07:42:11.000'
--SET @edate = '2017-05-11 23:59:59.000'
--SET @vid = N'db3ac174-1cfe-404c-914b-6be9db1b7038'


DECLARE @depid INT
DECLARE @idle INT
DECLARE @moving INT
DECLARE @stopped INT
DECLARE @diststr VARCHAR(20)
DECLARE @distmult FLOAT 
DECLARE @defaultgap INT


SELECT TOP 1
        @defaultgap = mingap
FROM    dbo.[tripsandstopsconfig]
WHERE   vehicleid = @vid
        OR vehicleid IS NULL
ORDER BY tripsandstopsconfigid DESC

IF @defaultgap IS NULL 
    BEGIN
        SET @defaultgap = 3
    END

SET @moving = 4
SET @stopped = 5
SET @idle = 0

DECLARE @s_date SMALLDATETIME
DECLARE @e_date SMALLDATETIME

SET @s_date = @sdate
SET @e_date = @edate
SET @sdate = dbo.TZ_ToUTC(@sdate, DEFAULT, @uid)
SET @edate = dbo.TZ_ToUTC(@edate, DEFAULT, @uid)

SELECT  @diststr = dbo.UserPref(@uid, 203)
 -- distance string
SELECT  @distmult = CAST(dbo.UserPref(@uid, 202) AS FLOAT) * 100
 -- distance multiplier

DECLARE @DepotName1 VARCHAR(255)
DECLARE @Registration1 VARCHAR(255)
DECLARE @Registration2 VARCHAR(255)
DECLARE @StartTripTime1 DATETIME
DECLARE @StartAddress1 VARCHAR(255)
DECLARE @EndTripTime1 DATETIME
DECLARE @EndAddress1 VARCHAR(255)
DECLARE @Distance1 INT
DECLARE @Duration1 INT
DECLARE @LatD1 FLOAT
DECLARE @LongD1 FLOAT
DECLARE @LatA1 FLOAT
DECLARE @LongA1 FLOAT
DECLARE @StartTripTime2 DATETIME
DECLARE @StartAddress2 VARCHAR(255)
DECLARE @EndTripTime2 DATETIME
DECLARE @EndAddress2 VARCHAR(255)
DECLARE @Distance2 INT
DECLARE @Duration2 INT
DECLARE @DistanceBetweenPoints2 FLOAT
DECLARE @LatD2 FLOAT
DECLARE @LongD2 FLOAT
DECLARE @LatA2 FLOAT
DECLARE @LongA2 FLOAT
DECLARE @ReportStartDate DATETIME
DECLARE @ReportStartYear VARCHAR(4)
DECLARE @ReportStartMonth VARCHAR(2)
DECLARE @ReportStartDay VARCHAR(2)
DECLARE @ReportEndDate DATETIME
DECLARE @ReportEndYear VARCHAR(4)
DECLARE @ReportEndMonth VARCHAR(2)
DECLARE @ReportEndDay VARCHAR(2)
DECLARE @DurationFloat FLOAT
DECLARE @DurationRound INT
DECLARE @TZStartTripTime DATETIME
DECLARE @TZStartTripMonth INT
DECLARE @TZStartTripDay INT
DECLARE @TZEndTripTime DATETIME
DECLARE @TZEndTripMonth INT
DECLARE @TZEndTripDay INT
DECLARE @Disp FLOAT
DECLARE @Disp1 FLOAT
DECLARE @Disp2 FLOAT
DECLARE @Duration12 INT
DECLARE @Distance12 INT

DECLARE @StartEventId BIGINT,
    @StartEventLat FLOAT,
    @StartEventLong FLOAT,
    @EndEventId BIGINT,
    @EndEventLat FLOAT,
    @EndEventLong FLOAT

IF @depid IS NULL
BEGIN
	-- broken needs to account for date
	SELECT TOP 1 @depid = c.CustomerIntId, @DepotName1 = c.Name
	FROM dbo.CustomerVehicle cv
		INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
	WHERE cv.VehicleId = @vid
	AND cv.StartDate <= @sdate and (cv.EndDate is null or cv.EndDate >= @edate)
	ORDER BY cv.LastOperation DESC
END

SET @Registration2 = ''

-- Changed from a temporary table to a table variable in keeping with best practices.
DECLARE @tripreport TABLE
    (
      DepotName VARCHAR(255),
      Registration VARCHAR(255),
      StartTripTime DATETIME,
      StartTripAddress VARCHAR(255),
      StartLat FLOAT,
      StartLong FLOAT,
      EndTripTime DATETIME,
      EndTripAddress VARCHAR(255),
      EndLat FLOAT,
      EndLong FLOAT,
      ReportDate DATETIME,
      Distance FLOAT,
      Duration INT,
      DurationHours INT,
      DurationMinutes INT,
      DistUnits VARCHAR(50)
    )

DECLARE @cursortable TABLE
    (
      registration VARCHAR(20),
      StartTripTime DATETIME,
      EndTripTime DATETIME,
      TripDistance INT,
      Duration INT,
      LatD1 FLOAT,
      LongD1 FLOAT,
      LatA1 FLOAT,
      LongA1 FLOAT,
      StartEventId BIGINT,
      EndEventId BIGINT,
      DepotId INT
    )

-- Pre-calculate everything and perform this set of complex joins only once rather than on every iteration of the cursor.
INSERT  INTO @cursortable
        SELECT  registration,
                e1.EventDateTime,
                e2.[EventDateTime],
                t2.tripdistance,
                t2.duration,
                t1.latitude,
                t1.longitude,
                t2.latitude,
                t2.longitude,
                t1.EventId,
                t2.EventId,
                @depid
        FROM    dbo.[tripsandstops] t1
                INNER JOIN dbo.[tripsandstops] t2 ON t2.previousid = t1.tripsandstopsid
                INNER JOIN dbo.[vehicle] v ON t1.VehicleIntID = v.VehicleIntID
                INNER JOIN dbo.Event e1 ON t1.EventID = e1.EventId
                INNER JOIN dbo.Event e2 ON t2.EventID = e2.EventId
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
                AND t1.vehiclestate = @moving
                AND t2.vehiclestate = @stopped
                AND NOT ( t1.latitude = 0
                          AND t1.longitude = 0
                          AND t2.latitude = 0
                          AND t2.longitude = 0
                        )
        ORDER BY v.vehicleid,
                t1.tripsandstopsid

DECLARE TRIPCALCCURSOR CURSOR FAST_FORWARD READ_ONLY
    FOR SELECT  *
        FROM    @cursortable
OPEN TRIPCALCCURSOR
--get first row
FETCH NEXT FROM TRIPCALCCURSOR INTO @Registration1, @StartTripTime1,
    @EndTripTime1, @Distance1, @Duration1, @LatD1, @LongD1, @LatA1, @LongA1,
    @StartEventId, @EndEventId, @depid
WHILE @@FETCH_STATUS = 0
    BEGIN
	--store the fresh data
        SET @StartTripTime2 = @StartTripTime1
        SET @EndTripTime2 = @EndTripTime1
        SET @Distance2 = @Distance1
        SET @Duration2 = @Duration1
        SET @LatD2 = @LatD1
        SET @LongD2 = @LongD1
        SET @LatA2 = @LatA1
        SET @LongA2 = @LongA1
        SET @Registration2 = @Registration1
        FETCH NEXT FROM TRIPCALCCURSOR INTO @Registration1, @StartTripTime1,
            @EndTripTime1, @Distance1, @Duration1, @LatD1, @LongD1, @LatA1,
            @LongA1, @StartEventId, @EndEventId, @depid

        SET @TZStartTripTime = dbo.TZ_GetTime(@StartTripTime2, DEFAULT, @uid)
        SET @TZEndTripTime = dbo.TZ_GetTime(@EndTripTime2, DEFAULT, @uid)
        SET @TZStartTripMonth = MONTH(@TZStartTripTime)
        SET @TZStartTripDay = DAY(@TZStartTripTime)
        SET @TZEndTripMonth = MONTH(@TZEndTripTime)
        SET @TZEndTripDay = DAY(@TZEndTripTime)
        SET @ReportStartYear = CAST(YEAR(@TZStartTripTime) AS VARCHAR(4))
        SET @ReportStartMonth = CASE WHEN @TZStartTripMonth > 9
                                     THEN CAST(@TZStartTripMonth AS VARCHAR(2))
                                     ELSE '0' + CAST(@TZStartTripMonth AS VARCHAR(1))
                                END
        SET @ReportStartDay = CASE WHEN @TZStartTripDay > 9
                                   THEN CAST(@TZStartTripDay AS VARCHAR(2))
                                   ELSE '0' + CAST(@TZStartTripDay AS VARCHAR(1))
                              END
        SET @ReportStartDate = @ReportStartYear + '-'
            + @ReportStartMonth + '-'
            + @ReportStartDay + ' 00:00:00.000'
        SET @ReportEndYear = CAST(YEAR(@TZEndTripTime) AS VARCHAR(4))
        SET @ReportEndMonth = CASE WHEN @TZEndTripMonth > 9
                                   THEN CAST(@TZEndTripMonth AS VARCHAR(2))
                                   ELSE '0' + CAST(@TZEndTripMonth AS VARCHAR(1))
                              END
        SET @ReportEndDay = CASE WHEN @TZEndTripDay > 9
                                 THEN CAST(@TZEndTripDay AS VARCHAR(2))
                                 ELSE '0' + CAST(@TZEndTripDay AS VARCHAR(1))
                            END
        SET @ReportEndDate = @ReportEndYear + '-'
            + @ReportEndMonth + '-' + @ReportEndDay
            + ' 00:00:00.000'
        IF @Duration2 > DATEDIFF(second,
                                 @StartTripTime2,
                                 @EndTripTime2) 
            BEGIN
                SET @Duration2 = DATEDIFF(second, @StartTripTime2, @EndTripTime2)
            END
        SET @DurationFloat = CAST(@Duration2 AS FLOAT)
            / 60
        SET @DurationRound = CAST(ROUND(@DurationFloat, 0) AS INT)
        IF @DurationRound % 60 = 0
            AND @DurationRound > 0 
            BEGIN
                SET @DurationFloat = @DurationFloat
                    + 1
            END

        SELECT  @StartEventLat = @LatD2,
                @StartEventLong = @LongD2
        SELECT  @EndEventLat = @LatA2,
                @EndEventLong = @LongA2

        IF DAY(@TZStartTripTime) = DAY(@TZEndTripTime) 
            BEGIN
                INSERT  INTO @tripreport
                        (
                          DepotName,
                          Registration,
                          StartTripTime,
                          StartTripAddress,
                          StartLat,
                          StartLong,
                          EndTripTime,
                          EndTripAddress,
                          EndLat,
                          EndLong,
                          ReportDate,
                          Distance,
                          Duration,
                          DurationHours,
                          DurationMinutes,
                          DistUnits
                        )
                VALUES  (
                          @DepotName1,
                          @Registration2,
                          @TZStartTripTime,
                          @StartAddress2,
                          @StartEventLat,
                          @StartEventLong,
                          @TZEndTripTime,
                          @EndAddress2,
                          @EndEventLat,
                          @EndEventLong,
                          @ReportStartDate,
                          ROUND(( CAST(@Distance2
                                  * @distmult AS FLOAT) ),
                                1),
                          @DurationRound,
                          CAST(@DurationFloat / 60 AS INT),
                          @DurationRound % 60,
                          @Diststr
                        )
            END
        ELSE 
            BEGIN
                INSERT  INTO @tripreport
                        (
                          DepotName,
                          Registration,
                          StartTripTime,
                          StartTripAddress,
                          StartLat,
                          StartLong,
                          ReportDate
                        )
                VALUES  (
                          @DepotName1,
                          @Registration2,
                          @TZStartTripTime,
                          @StartAddress2,
                          @StartEventLat,
                          @StartEventLong,
                          @ReportStartDate
                        )
                INSERT  INTO @tripreport
                        (
                          DepotName,
                          Registration,
                          EndTripTime,
                          EndTripAddress,
                          EndLat,
                          EndLong,
                          ReportDate,
                          Distance,
                          Duration,
                          DurationHours,
                          DurationMinutes,
                          DistUnits
                        )
                VALUES  (
                          @DepotName1,
                          @Registration2,
                          @TZEndTripTime,
                          @EndAddress2,
                          @EndEventLat,
                          @EndEventLong,
                          @ReportEndDate,
                          ROUND(( CAST(@Distance2
                                  * @distmult AS FLOAT) ),
                                1),
                          @DurationRound,
                          CAST(@DurationFloat / 60 AS INT),
                          @DurationRound % 60,
                          @Diststr
                        )
            END
    END
CLOSE TRIPCALCCURSOR
DEALLOCATE TRIPCALCCURSOR

DECLARE @c_lat_start FLOAT, 
		@c_long_start FLOAT, 
		@c_lat_end FLOAT, 
		@c_long_end FLOAT, 
		@address_start NVARCHAR(MAX), 
		@address_end NVARCHAR(MAX), 
		@latLonIndex BIGINT
DECLARE @spRes TABLE (StreetAddress NVARCHAR(MAX))

DECLARE addressCur CURSOR FAST_FORWARD
    FOR SELECT  DISTINCT ISNULL(StartLat,0), ISNULL(StartLong,0), 
				ISNULL(EndLat,0), ISNULL(EndLong,0)
        FROM    @tripreport
        WHERE	Duration > 0
OPEN addressCur
FETCH NEXT FROM addressCur INTO @c_lat_start, @c_long_start, @c_lat_end, @c_long_end
WHILE @@FETCH_STATUS = 0
    BEGIN
	--Start address
	DELETE FROM @spRes
	INSERT INTO @spRes (StreetAddress)
	EXEC [dbo].[proc_GetGeofenceNameOrAdderssFromLongLat] @c_lat_start, @c_long_start, @uid, 1, 1
	SELECT TOP 1 @address_start = StreetAddress FROM @spRes
	--End address
	DELETE FROM @spRes
	INSERT INTO @spRes (StreetAddress)
	EXEC [dbo].[proc_GetGeofenceNameOrAdderssFromLongLat] @c_lat_end, @c_long_end, @uid, 1, 1
	SELECT TOP 1 @address_end = StreetAddress FROM @spRes
	--Update
	UPDATE @tripreport
	SET StartTripAddress = @address_start, EndTripAddress = @address_end
	WHERE StartLat = @c_lat_start AND StartLong = @c_long_start AND EndLat = @c_lat_end AND EndLong = @c_long_end
	
	FETCH NEXT FROM addressCur INTO @c_lat_start, @c_long_start, @c_lat_end, @c_long_end
	END
CLOSE addressCur
DEALLOCATE addressCur


SELECT  Registration, StartTripTime, 
	StartTripAddress,
	StartLat, StartLong, EndTripTime, 
	EndTripAddress,
	EndLat, EndLong, ReportDate, Distance, Duration,DurationHours, DurationMinutes, DistUnits
FROM    @tripreport
WHERE	Duration > 0
ORDER BY Registration,
        ReportDate,
        StartTripTime,
        EndTripTime

GO
