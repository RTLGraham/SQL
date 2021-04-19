SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[proc_GetReportTrips_Cached] 
@cid uniqueidentifier = NULL, @depid int = NULL, @vid uniqueidentifier = NULL, @sdate datetime, @edate datetime,
@reportparameter1 int = 2, @idle int = 5, @uid uniqueidentifier = NULL
AS  

--DECLARE @cid uniqueidentifier
--DECLARE @depid int
--DECLARE @vid uniqueidentifier
--DECLARE @sdate datetime
--DECLARE @edate datetime
--DECLARE @reportparameter1 int
--DECLARE @idle int
--DECLARE @uid uniqueidentifier
--
--SET @cid = null
--SET @uid ='3DB40C4A-7E79-4F41-8017-DE6E12EC7A20'
--SET @sdate = '2012-08-07 00:00:00.000'
--SET @edate = '2012-08-07 23:59:59.000'
--SET @vid = N'577536E5-4AED-4450-A8DF-F5F6AC54A3FD'
----default stop time in minutes
--SET @idle = 5
----2 gaps 1 key switch
--SET @reportparameter1 = 1

DECLARE @lcid UNIQUEIDENTIFIER
DECLARE @ldepid int
DECLARE @lvid uniqueidentifier
DECLARE @lsdate datetime
DECLARE @ledate datetime
DECLARE @lreportparameter1 int
DECLARE @lidle int
DECLARE @luid uniqueidentifier

SET @lcid = @cid
SET @ldepid = @depid
SET @lvid = @vid
SET @lsdate = @sdate
SET @ledate = @edate
SET @lreportparameter1 = @reportparameter1
SET @lidle = @idle
SET @luid = @uid

DECLARE @moving int
DECLARE @stopped int
DECLARE @diststr varchar(20)
DECLARE @distmult float 
DECLARE @defaultgap int
DECLARE @mindistance float
SET @mindistance = 0.05

SELECT top 1 @defaultgap = mingap from dbo.[tripsandstopsconfig] where vehicleid = @lvid or vehicleid is null order by tripsandstopsconfigid desc

IF @defaultgap is null
BEGIN
	SET @defaultgap = 3
END

IF @lreportparameter1 = 1
BEGIN
	SET @lidle = 0
	SET @moving = 4
	SET @stopped = 5
END
IF @lreportparameter1 = 2
BEGIN
	SET @moving = 1
	SET @stopped = 0
END

IF @lidle IS NULL
	SET @lidle = 0
	
-- Section added to allow the report to be automatically scheduled
IF datepart(yyyy, @lsdate) = '1960'
BEGIN
	SET @ledate = dbo.Calc_Schedule_EndDate(@lsdate, @luid)
	SET @lsdate = dbo.Calc_Schedule_StartDate(@lsdate, @luid)
END

DECLARE @s_date smalldatetime
DECLARE @e_date smalldatetime
SET @s_date = @lsdate
SET @e_date = @ledate
SET @lsdate = dbo.TZ_ToUTC(@lsdate,default,@luid)
SET @ledate = dbo.TZ_ToUTC(@ledate,default,@luid)

SELECT @diststr = dbo.UserPref(@luid,203) -- distance string
SELECT @distmult = cast(dbo.UserPref(@luid,202) as float) * 100 -- distance multiplier

DECLARE @CustomerName1 varchar(255)
DECLARE @DepotName1 varchar(255)
DECLARE @Registration1 varchar(255)
DECLARE @Registration2 varchar(255)
DECLARE @StartTripTime1 datetime
DECLARE @StartAddress1 varchar(255)
DECLARE @EndTripTime1 datetime
DECLARE @EndAddress1 varchar(255)
DECLARE @Distance1 int
DECLARE @Duration1 int
DECLARE @LatD1 float
DECLARE @LongD1 float
DECLARE @LatA1 float
DECLARE @LongA1 float
DECLARE @StartTripTime2 datetime
DECLARE @StartAddress2 varchar(255)
DECLARE @EndTripTime2 datetime
DECLARE @EndAddress2 varchar(255)
DECLARE @Distance2 int
DECLARE @Duration2 int
DECLARE @DistanceBetweenPoints2 float
DECLARE @LatD2 float
DECLARE @LongD2 float
DECLARE @LatA2 float
DECLARE @LongA2 float
DECLARE @ReportStartDate datetime
DECLARE @ReportStartYear varchar(4)
DECLARE @ReportStartMonth varchar(2)
DECLARE @ReportStartDay varchar(2)
DECLARE @ReportEndDate datetime
DECLARE @ReportEndYear varchar(4)
DECLARE @ReportEndMonth varchar(2)
DECLARE @ReportEndDay varchar(2)
DECLARE @DurationFloat float
DECLARE @DurationRound int
DECLARE @TZStartTripTime datetime
DECLARE @TZStartTripMonth int
DECLARE @TZStartTripDay int
DECLARE @TZEndTripTime datetime
DECLARE @TZEndTripMonth int
DECLARE @TZEndTripDay int
DECLARE @Disp float
DECLARE @Disp1 float
DECLARE @Disp2 float
DECLARE @Duration12 int
DECLARE @Distance12 int

DECLARE @StartEventId bigint,
		@StartEventLat float,
		@StartEventLong float,
		@EndEventId bigint,
		@EndEventLat float,
		@EndEventLong float

IF @ldepid IS NULL
BEGIN
	-- broken needs to account for date
	SELECT TOP 1 @ldepid = c.CustomerIntId, @DepotName1 = c.Name
	FROM dbo.CustomerVehicle cv
		INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
	WHERE cv.VehicleId = @lvid
	AND cv.StartDate <= @lsdate and (cv.EndDate is null or cv.EndDate >= @ledate)
	ORDER BY cv.LastOperation DESC
END

SET @Registration2 = ''

-- Changed from a temporary table to a table variable in keeping with best practices.
DECLARE @tripreport TABLE (
	CustomerName varchar(255),
	DepotName varchar(255),
	Registration varchar(255),
	StartTripTime datetime,
	StartTripAddress varchar(255),
	StartLat float,
	StartLong float,
	EndTripTime datetime,
	EndTripAddress varchar(255),
	EndLat float,
	EndLong float,
	ReportDate datetime,
	Distance float,
	Duration int,
	DurationHours int,
	DurationMinutes int,
	DistUnits varchar(50))

DECLARE @cursortable TABLE (
	registration varchar(20),
	StartTripTime datetime,
	EndTripTime datetime,
	TripDistance int,
	Duration int,
	LatD1 float,
	LongD1 float,
	LatA1 float,
	LongA1 float,
	StartEventId bigint,
	EndEventId bigint,
	DepotId int)

-- Pre-calculate everything and perform this set of complex joins only once rather than on every iteration of the cursor.
INSERT INTO @cursortable
	select registration,e1.EventDateTime, e2.[EventDateTime],t2.tripdistance,t2.duration,
		   t1.latitude,t1.longitude,t2.latitude,t2.longitude, t1.EventId, t2.EventId, @ldepid
	from dbo.[tripsandstops] t1
	inner join dbo.[tripsandstops] t2 WITH (NOLOCK) ON t2.previousid = t1.tripsandstopsid 
	inner join dbo.[vehicle] v WITH (NOLOCK) ON t1.VehicleIntID = v.VehicleIntID
	INNER JOIN dbo.Event e1 WITH (NOLOCK) ON t1.EventID = e1.EventId
	INNER JOIN dbo.Event e2 WITH (NOLOCK) ON t2.EventID = e2.EventId
	where --t1.customerid = @lcid
	(v.vehicleid = @lvid or @lvid is null) 
	and t1.CustomerIntID = @ldepid
	and ((t1.[timestamp] >= @lsdate and t2.[timestamp] <= @ledate) or 
		(t1.[timestamp] <= @ledate and t2.[timestamp] > @ledate) or 
		(t1.[timestamp] < @lsdate and t2.[timestamp] >= @lsdate))
	and t1.vehiclestate = @moving
	and t2.vehiclestate = @stopped
	and not (t1.latitude = 0 and t1.longitude = 0 and t2.latitude = 0 and t2.longitude = 0)
	order by v.vehicleid, t1.tripsandstopsid




DECLARE TRIPCALCCURSOR CURSOR FAST_FORWARD READ_ONLY
FOR SELECT * FROM @cursortable
OPEN TRIPCALCCURSOR
--get first row
FETCH NEXT FROM TRIPCALCCURSOR INTO @Registration1, @StartTripTime1, @EndTripTime1, @Distance1, @Duration1, @LatD1, @LongD1, @LatA1, @LongA1, @StartEventId, @EndEventId, @ldepid
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
	SET @Disp1 = dbo.[DistanceBetweenPoints] (@LatA2,@LongA2,@LatD1,@LongD1)

	--SELECT @StartEventLat = Lat, @StartEventLong = Long FROM dbo.[Events] WHERE EventId = @StartEventId and DepotId = @ldepid
	--SELECT @EndEventLat = Lat, @EndEventLong = Long FROM dbo.[Events] WHERE EventId = @EndEventId and DepotId = @ldepid
	
	FETCH NEXT FROM TRIPCALCCURSOR INTO @Registration1, @StartTripTime1, @EndTripTime1, @Distance1, @Duration1, @LatD1, @LongD1, @LatA1, @LongA1, @StartEventId, @EndEventId, @ldepid

	IF @Registration1 = @Registration2
	BEGIN
		-- line below corrected to test against @Distance2 instead of @Distance1 GP 30/4/13
		IF @Disp1 >= @mindistance OR @Distance2 > @mindistance --valid leg check next leg to see if gap is genuine
		BEGIN
			IF Round(DateDiff(second,@EndTripTime2,@StartTripTime1)/60,0) >= @lidle--genuine gap store the first leg as a trip
			BEGIN
				SET @TZStartTripTime = dbo.TZ_GetTime(@StartTripTime2,default,@luid)
				SET @TZEndTripTime = dbo.TZ_GetTime(@EndTripTime2,default,@luid)
				SET @TZStartTripMonth = Month(@TZStartTripTime)
				SET @TZStartTripDay = Day(@TZStartTripTime)
				SET @TZEndTripMonth = Month(@TZEndTripTime)
				SET @TZEndTripDay = Day(@TZEndTripTime)
				Set @ReportStartYear = cast(Year(@TZStartTripTime) as varchar(4))
				Set @ReportStartMonth = CASE WHEN @TZStartTripMonth > 9 THEN cast(@TZStartTripMonth as varchar(2)) ELSE '0' + cast(@TZStartTripMonth as varchar(1)) END
				Set @ReportStartDay = CASE WHEN @TZStartTripDay > 9 THEN cast(@TZStartTripDay as varchar(2)) ELSE '0' + cast(@TZStartTripDay as varchar(1)) END
				SET @ReportStartDate = @ReportStartYear + '-' + @ReportStartMonth + '-' + @ReportStartDay + ' 00:00:00.000'
				Set @ReportEndYear = cast(Year(@TZEndTripTime) as varchar(4))
				Set @ReportEndMonth = CASE WHEN @TZEndTripMonth > 9 THEN cast(@TZEndTripMonth as varchar(2)) ELSE '0' + cast(@TZEndTripMonth as varchar(1)) END
				Set @ReportEndDay = CASE WHEN @TZEndTripDay > 9 THEN cast(@TZEndTripDay as varchar(2)) ELSE '0' + cast(@TZEndTripDay as varchar(1)) END
				SET @ReportEndDate = @ReportEndYear + '-' + @ReportEndMonth + '-' + @ReportEndDay + ' 00:00:00.000'
				IF @Duration2 > datediff(second,@StartTripTime2,@EndTripTime2)
				BEGIN
					SET @Duration2 = datediff(second,@StartTripTime2,@EndTripTime2)
				END
				SET @DurationFloat = cast(@Duration2 as float)/60
				SET @DurationRound = cast(Round(@DurationFloat,0)as int)
				IF @DurationRound %60 = 0 and @DurationRound > 0
				BEGIN
					SET @DurationFloat = @DurationFloat + 1
				END
				SET @StartAddress1 = [dbo].GetAddressFromLongLat(@LatD1, @LongD1)
				SET @StartAddress2 = [dbo].GetAddressFromLongLat(@LatD2, @LongD2)
				SET @EndAddress2 = [dbo].GetAddressFromLongLat(@LatA2, @LongA2)
					
				--Get geofence name if such geofence exists
				SET @StartAddress2 = [dbo].[GetGeofenceNameFromLongLat] (@LatD2, @LongD2, @luid, @StartAddress2)
				SET @EndAddress2 = [dbo].[GetGeofenceNameFromLongLat] (@LatA2, @LongA2, @luid, @EndAddress2)
				
				IF @EndAddress2 = 'Address Unknown' and @StartAddress1 <> 'Address Unknown'
				BEGIN
					SET @StartAddress1 = [dbo].[GetGeofenceNameFromLongLat] (@LatD1, @LongD1, @luid, @StartAddress1)
					SET @EndAddress2 = @StartAddress1
				END
				-- bil start
				SELECT @StartEventLat = @LatD2, @StartEventLong = @LongD2
				SELECT @EndEventLat = @LatA2, @EndEventLong = @LongA2
				-- bil end
				IF Day(@TZStartTripTime) = Day(@TZEndTripTime)
				BEGIN
					insert into @tripreport
						(CustomerName, DepotName, Registration, StartTripTime, StartTripAddress, StartLat, StartLong, EndTripTime, EndTripAddress, EndLat, EndLong, ReportDate, Distance, Duration,DurationHours, DurationMinutes, DistUnits)
						Values(@CustomerName1, @DepotName1, @Registration2, @TZStartTripTime, @StartAddress2, @StartEventLat, @StartEventLong, @TZEndTripTime, @EndAddress2, @EndEventLat, @EndEventLong, @ReportStartDate,Round((cast(@Distance2 * @distmult as float)),1),@DurationRound,cast(@DurationFloat/60 as int),@DurationRound % 60, @Diststr)
				END
				ELSE
				BEGIN
					insert into @tripreport
						(CustomerName, DepotName, Registration, StartTripTime, StartTripAddress, StartLat, StartLong, ReportDate)
						Values(@CustomerName1, @DepotName1, @Registration2, @TZStartTripTime, @StartAddress2, @StartEventLat, @StartEventLong, @ReportStartDate)
					insert into @tripreport
						(CustomerName, DepotName, Registration, EndTripTime, EndTripAddress, EndLat, EndLong, ReportDate, Distance, Duration,DurationHours, DurationMinutes, DistUnits)
						Values(@CustomerName1, @DepotName1, @Registration2,  @TZEndTripTime, @EndAddress2, @EndEventLat, @EndEventLong, @ReportEndDate,Round((cast(@Distance2 * @distmult as float)),1),@DurationRound,cast(@DurationFloat/60 as int),@DurationRound % 60, @Diststr)
				END
			END
			ELSE
			BEGIN
				--1-2 is not a genuine gap combine the 2 legs
				SET @StartTripTime1 = @StartTripTime2
				SET @LatD1 = @LatD2
				SET @LongD1 = @LongD2
				SET @Distance1 = @Distance1 + @Distance2
				SET @Duration1 = DateDiff(second,@StartTripTime2,@EndTripTime1)
			END
		END
		ELSE
		BEGIN
			IF Round(DateDiff(second,@EndTripTime2,@StartTripTime1)/60,0) < @lidle --not a genuine gap combine the legs
			BEGIN
				--1 is not a genuine leg combine the 2 legs
				SET @StartTripTime1 = @StartTripTime2
				SET @LatD1 = @LatD2
				SET @LongD1 = @LongD2
				SET @Distance1 = @Distance1 + @Distance2
				SET @Duration1 = DateDiff(second,@StartTripTime2,@EndTripTime1)
			END
		END
	END
	ELSE
	BEGIN
		SET @Disp1 = dbo.DistanceBetweenPoints(@LatA2,@LongA2,@LatD2,@LongD2)
		IF @Disp1 >= @mindistance OR @Distance1 > @mindistance --valid leg
		BEGIN
			SET @TZStartTripTime = dbo.TZ_GetTime(@StartTripTime2,default,@luid)
			SET @TZEndTripTime = dbo.TZ_GetTime(@EndTripTime2,default,@luid)
			SET @TZStartTripMonth = Month(@TZStartTripTime)
			SET @TZStartTripDay = Day(@TZStartTripTime)
			SET @TZEndTripMonth = Month(@TZEndTripTime)
			SET @TZEndTripDay = Day(@TZEndTripTime)
			Set @ReportStartYear = cast(Year(@TZStartTripTime) as varchar(4))
			Set @ReportStartMonth = CASE WHEN @TZStartTripMonth > 9 THEN cast(@TZStartTripMonth as varchar(2)) ELSE '0' + cast(@TZStartTripMonth as varchar(1)) END
			Set @ReportStartDay = CASE WHEN @TZStartTripDay > 9 THEN cast(@TZStartTripDay as varchar(2)) ELSE '0' + cast(@TZStartTripDay as varchar(1)) END
			SET @ReportStartDate = @ReportStartYear + '-' + @ReportStartMonth + '-' + @ReportStartDay + ' 00:00:00.000'
			Set @ReportEndYear = cast(Year(@TZEndTripTime) as varchar(4))
			Set @ReportEndMonth = CASE WHEN @TZEndTripMonth > 9 THEN cast(@TZEndTripMonth as varchar(2)) ELSE '0' + cast(@TZEndTripMonth as varchar(1)) END
			Set @ReportEndDay = CASE WHEN @TZEndTripDay > 9 THEN cast(@TZEndTripDay as varchar(2)) ELSE '0' + cast(@TZEndTripDay as varchar(1)) END
			SET @ReportEndDate = @ReportEndYear + '-' + @ReportEndMonth + '-' + @ReportEndDay + ' 00:00:00.000'
			IF @Duration2 > datediff(second,@StartTripTime2,@EndTripTime2)
			BEGIN
				SET @Duration1 = datediff(second,@StartTripTime2,@EndTripTime2)
			END
			SET @DurationFloat = cast(@Duration2 as float)/60
			SET @DurationRound = cast(Round(@DurationFloat,0)as int)
			IF @DurationRound %60 = 0 and @DurationRound > 0
			BEGIN
				SET @DurationFloat = @DurationFloat + 1
			END
			SET @StartAddress2 = [dbo].GetAddressFromLongLat(@LatD2, @LongD2)
			SET @EndAddress2 = [dbo].GetAddressFromLongLat(@LatA2, @LongA2)
				
			--Get geofence name if such geofence exists
			SET @StartAddress2 = [dbo].[GetGeofenceNameFromLongLat] (@LatD2, @LongD2, @luid, @StartAddress2)
			SET @EndAddress2 = [dbo].[GetGeofenceNameFromLongLat] (@LatA2, @LongA2, @luid, @EndAddress2)
				
			-- bil start
			SELECT @StartEventLat = @LatD2, @StartEventLong = @LongD2
			SELECT @EndEventLat = @LatA2, @EndEventLong = @LongA2
			-- bil end
			IF Day(@TZStartTripTime) = Day(@TZEndTripTime)
			BEGIN
			insert into @tripreport
				(CustomerName, DepotName, Registration, StartTripTime, StartTripAddress, StartLat, StartLong, EndTripTime, EndTripAddress, EndLat, EndLong, ReportDate, Distance, Duration,DurationHours, DurationMinutes, DistUnits)
				Values(@CustomerName1, @DepotName1, @Registration2, @TZStartTripTime, @StartAddress2, @StartEventLat, @StartEventLong, @TZEndTripTime, @EndAddress2, @EndEventLat, @EndEventLong, @ReportStartDate,Round((cast(@Distance2 * @distmult as float)),1),@DurationRound,cast(@DurationFloat/60 as int),@DurationRound % 60, @Diststr)
			END
			ELSE
			BEGIN
				insert into @tripreport
					(CustomerName, DepotName, Registration, StartTripTime, StartTripAddress, StartLat, StartLong, ReportDate)
					Values(@CustomerName1, @DepotName1, @Registration2, @TZStartTripTime, @StartAddress2, @StartEventLat, @StartEventLong, @ReportStartDate)
				insert into @tripreport
					(CustomerName, DepotName, Registration, EndTripTime, EndTripAddress, EndLat, EndLong, ReportDate, Distance, Duration,DurationHours, DurationMinutes, DistUnits)
					Values(@CustomerName1, @DepotName1, @Registration2,  @TZEndTripTime, @EndAddress2, @EndEventLat, @EndEventLong, @ReportEndDate,Round((cast(@Distance2 * @distmult as float)),1),@DurationRound,cast(@DurationFloat/60 as int),@DurationRound % 60, @Diststr)
			END
		END
	END
END
CLOSE TRIPCALCCURSOR
DEALLOCATE TRIPCALCCURSOR
--is last leg valid?
SET @Disp1 = dbo.DistanceBetweenPoints(@LatA2,@LongA2,@LatD1,@LongD1)
IF @Disp1 >= @mindistance OR @Distance1 > @mindistance --valid leg
BEGIN
	SET @TZStartTripTime = dbo.TZ_GetTime(@StartTripTime2,default,@luid)
	SET @TZEndTripTime = dbo.TZ_GetTime(@EndTripTime2,default,@luid)
	SET @TZStartTripMonth = Month(@TZStartTripTime)
	SET @TZStartTripDay = Day(@TZStartTripTime)
	SET @TZEndTripMonth = Month(@TZEndTripTime)
	SET @TZEndTripDay = Day(@TZEndTripTime)
	Set @ReportStartYear = cast(Year(@TZStartTripTime) as varchar(4))
	Set @ReportStartMonth = CASE WHEN @TZStartTripMonth > 9 THEN cast(@TZStartTripMonth as varchar(2)) ELSE '0' + cast(@TZStartTripMonth as varchar(1)) END
	Set @ReportStartDay = CASE WHEN @TZStartTripDay > 9 THEN cast(@TZStartTripDay as varchar(2)) ELSE '0' + cast(@TZStartTripDay as varchar(1)) END
	SET @ReportStartDate = @ReportStartYear + '-' + @ReportStartMonth + '-' + @ReportStartDay + ' 00:00:00.000'
	Set @ReportEndYear = cast(Year(@TZEndTripTime) as varchar(4))
	Set @ReportEndMonth = CASE WHEN @TZEndTripMonth > 9 THEN cast(@TZEndTripMonth as varchar(2)) ELSE '0' + cast(@TZEndTripMonth as varchar(1)) END
	Set @ReportEndDay = CASE WHEN @TZEndTripDay > 9 THEN cast(@TZEndTripDay as varchar(2)) ELSE '0' + cast(@TZEndTripDay as varchar(1)) END
	SET @ReportEndDate = @ReportEndYear + '-' + @ReportEndMonth + '-' + @ReportEndDay + ' 00:00:00.000'
	IF @Duration1 > datediff(second,@StartTripTime2,@EndTripTime2)
	BEGIN
		SET @Duration1 = datediff(second,@StartTripTime2,@EndTripTime2)
	END
	SET @DurationFloat = cast(@Duration1 as float)/60
	SET @DurationRound = cast(Round(@DurationFloat,0)as int)
	IF @DurationRound %60 = 0 and @DurationRound > 0
	BEGIN
		SET @DurationFloat = @DurationFloat + 1
	END
	SET @StartAddress1 = [dbo].GetAddressFromLongLat(@LatD1, @LongD1)
	SET @StartAddress2 = [dbo].GetAddressFromLongLat(@LatD2, @LongD2)
	SET @EndAddress2 = [dbo].GetAddressFromLongLat(@LatA2, @LongA2)
	IF @EndAddress2 = 'Address Unknown' and @StartAddress1 <> 'Address Unknown'
	BEGIN
		SET @EndAddress2 = @StartAddress1
	END
		
	--Get geofence name if such geofence exists
	SET @StartAddress2 = [dbo].[GetGeofenceNameFromLongLat] (@LatD2, @LongD2, @luid, @StartAddress2)
	SET @EndAddress2 = [dbo].[GetGeofenceNameFromLongLat] (@LatA2, @LongA2, @luid, @EndAddress2)
			
	-- bil start
	SELECT @StartEventLat = @LatD2, @StartEventLong = @LongD2
	SELECT @EndEventLat = @LatA2, @EndEventLong = @LongA2
	-- bil end
	IF Day(@TZStartTripTime) = Day(@TZEndTripTime)
	BEGIN
	insert into @tripreport
		(CustomerName, DepotName, Registration, StartTripTime, StartTripAddress, StartLat, StartLong, EndTripTime, EndTripAddress, EndLat, EndLong, ReportDate, Distance, Duration,DurationHours, DurationMinutes, DistUnits)
		Values(@CustomerName1, @DepotName1, @Registration2, @TZStartTripTime, @StartAddress2, @StartEventLat, @StartEventLong, @TZEndTripTime, @EndAddress2, @EndEventLat, @EndEventLong, @ReportStartDate,Round((cast(@Distance2 * @distmult as float)),1),@DurationRound,cast(@DurationFloat/60 as int),@DurationRound % 60, @Diststr)
	END
	ELSE
	BEGIN
		insert into @tripreport
			(CustomerName, DepotName, Registration, StartTripTime, StartTripAddress, StartLat, StartLong, ReportDate)
			Values(@CustomerName1, @DepotName1, @Registration2, @TZStartTripTime, @StartAddress2, @StartEventLat, @StartEventLong, @ReportStartDate)
		insert into @tripreport
			(CustomerName, DepotName, Registration, EndTripTime, EndTripAddress, EndLat, EndLong, ReportDate, Distance, Duration,DurationHours, DurationMinutes, DistUnits)
			Values(@CustomerName1, @DepotName1, @Registration2,  @TZEndTripTime, @EndAddress2, @EndEventLat, @EndEventLong, @ReportEndDate,Round((cast(@Distance2 * @distmult as float)),1),@DurationRound,cast(@DurationFloat/60 as int),@DurationRound % 60, @Diststr)
	END
END
Select * From @tripreport 
WHERE StartTripTime BETWEEN @s_date AND @e_date
order by Registration,ReportDate,StartTripTime,EndTripTime

GO
