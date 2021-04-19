SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[CreateDependentDateRange]( @sdate DATETIME, @edate DATETIME, @uid UNIQUEIDENTIFIER, @drilldown TINYINT, @calendar TINYINT, @groupBy INT=NULL )
	RETURNS @dateTable TABLE ( StartDate DATETIME, EndDate DATETIME, PeriodType VARCHAR(MAX) )
	-- This function receives dates in user time zone and returns a table with dates in UTC
	-- @adate and @edate are the input date range
	-- @drilldown in a boolean determining whether the date range is to be split down or not
	-- @calendar is a boolean determining whether the split should adhere to calendar weeks and months 
	-- @groupBy can be used to override the automatic period selection with the following values:
	--			1 : Split by Day
	--			2 : Split by Week
	--			3 : Split by Month
	--			4 : Split by Year
	--			5 : Split by Hour 
	--			6 : Split by 15 mins
AS
BEGIN
	--DECLARE @sdate DATETIME,
	--		@edate DATETIME,
	--		@uid UNIQUEIDENTIFIER,
	--		@drilldown TINYINT,
	--		@calendar TINYINT,
	--		@groupBy INT
			
	--DECLARE	@dateTable TABLE ( StartDate DATETIME, EndDate DATETIME, PeriodType VARCHAR(MAX) )
	
	--SET @sdate = '2019-02-01 06:24'
	--SET @edate = '2019-02-10 09:18'
	--SET @uid = NULL--N'7A4C7369-7E93-455E-8B66-660E91AB26C5'--N'C21039E7-58BE-4748-9A92-9AAB74AED58E'
	--SET @drilldown = 1
	--SET @calendar = 1
	--SET @groupBy = 1
			
	DECLARE @cursdate DATETIME,
			@curedate DATETIME
	SET @cursdate = @sdate
	SET @curedate = @edate
	
	DECLARE @MonthsElapsed INT,
			@DaysElapsed INT,
			@mins INT
			
	IF @groupBy = 0
	BEGIN
		SET @MonthsElapsed = DATEDIFF(mm, @sdate, @edate)
		SET @DaysElapsed = DATEDIFF(dd, @sdate, @edate)
	END ELSE
	BEGIN
		-- force use of manually provided groupBy indicator
		SET @calendar = 1
		SET @drilldown = 1
		SET @MonthsElapsed = NULL
		SET @DaysElapsed = NULL
	END
	
	DECLARE @DayNum INT

	IF @drilldown = 1 -- Breakdown into smaller periods required	
	BEGIN
		
		IF (@calendar = 1 AND @MonthsElapsed = 0 AND @DaysElapsed < 7) OR (@calendar = 0 AND @DaysElapsed <= 31) OR (@groupBy = 1)
		-- Period should be set in days
		BEGIN
			WHILE @cursdate < @edate
			BEGIN
				SET @curedate = CAST(DATEPART(yyyy,@cursdate) AS CHAR(4)) + '-' + CAST(DATEPART(mm,@cursdate) AS CHAR(2)) 
								+ '-' + CAST(DATEPART(dd,@cursdate) AS CHAR(2)) + ' 23:59'
				IF @curedate > @edate SET @curedate = @edate
				INSERT INTO @dateTable( Startdate , Enddate, PeriodType )
				VALUES (CASE WHEN @uid IS NULL THEN [dbo].TZ_ToUTC(@cursdate,'GMT Time',@uid) ELSE [dbo].TZ_ToUTC(@cursdate,default,@uid) END, 
						CASE WHEN @uid IS NULL THEN [dbo].TZ_ToUTC(@curedate,'GMT Time',@uid) ELSE [dbo].TZ_ToUTC(@curedate,default,@uid) END, 'Day')
				
				SET @cursdate = DATEADD(mi, 1, @curedate)
			END
		END
		
		IF (@calendar = 1 AND @MonthsElapsed < 2 AND @DaysElapsed >= 7) OR (@calendar = 0 AND @DaysElapsed > 31 AND @MonthsElapsed < 6) OR (@groupBy = 2)
		-- Period should be set in weeks, where a week is defined as Monday to Sunday
		BEGIN
			-- identify the number of days to complete the first week
			SET @DayNum = 8 - DATEPART(dw, @cursdate)
			IF @DayNum = 7 SET @DayNum = 0
			WHILE @cursdate < @edate
			BEGIN
				SET @curedate = DATEADD(dd, @Daynum, CAST(DATEPART(yyyy,@cursdate) AS CHAR(4)) + '-' + CAST(DATEPART(mm,@cursdate) AS CHAR(2)) 
								+ '-' + CAST(DATEPART(dd,@cursdate) AS CHAR(2)) + ' 23:59')
				
				IF @curedate > @edate SET @curedate = @edate
				INSERT INTO @dateTable( Startdate , Enddate, PeriodType )
				VALUES (CASE WHEN @uid IS NULL THEN [dbo].TZ_ToUTC(@cursdate,'GMT Time',@uid) ELSE [dbo].TZ_ToUTC(@cursdate,default,@uid) END, 
						CASE WHEN @uid IS NULL THEN [dbo].TZ_ToUTC(@curedate,'GMT Time',@uid) ELSE [dbo].TZ_ToUTC(@curedate,default,@uid) END, 'Week')
				
				SET @cursdate = DATEADD(mi, 1, @curedate)
				SET @DayNum = 6 -- set so that remaining weeks are full weeks
			END		
		END
		
		IF (@calendar = 1 AND @MonthsElapsed >= 2) OR (@calendar = 0 AND @MonthsElapsed >= 6) OR (@groupBy = 3)
		-- Period should be set in calendar months
		BEGIN
			WHILE @cursdate < @edate
			BEGIN
				SET @curedate = DATEADD(mm, 1, @cursdate)
				SET @curedate = DATEADD(mi, -1, CAST(DATEPART(yyyy,@curedate) AS CHAR(4)) + '-' + CAST(DATEPART(mm,@curedate) AS CHAR(2)) 
								+ '-01 00:00')
				IF @curedate > @edate SET @curedate = @edate
				INSERT INTO @dateTable( Startdate , Enddate, PeriodType )
				VALUES (CASE WHEN @uid IS NULL THEN [dbo].TZ_ToUTC(@cursdate,'GMT Time',@uid) ELSE [dbo].TZ_ToUTC(@cursdate,default,@uid) END, 
						CASE WHEN @uid IS NULL THEN [dbo].TZ_ToUTC(@curedate,'GMT Time',@uid) ELSE [dbo].TZ_ToUTC(@curedate,default,@uid) END, 'Month')
				
				SET @cursdate = DATEADD(mi, 1, @curedate)
			END		
		END
		
		IF @groupBy = 4
		-- Period should be set in years
		BEGIN
			WHILE @cursdate < @edate
			BEGIN
				SET @curedate = DATEADD(yyyy, 1, @cursdate)
				SET @curedate = DATEADD(mi, -1, CAST(DATEPART(yyyy,@curedate) AS CHAR(4)) + '-01-01 00:00')
				IF @curedate > @edate SET @curedate = @edate
				INSERT INTO @dateTable( Startdate , Enddate, PeriodType )
				VALUES (CASE WHEN @uid IS NULL THEN [dbo].TZ_ToUTC(@cursdate,'GMT Time',@uid) ELSE [dbo].TZ_ToUTC(@cursdate,default,@uid) END, 
						CASE WHEN @uid IS NULL THEN [dbo].TZ_ToUTC(@curedate,'GMT Time',@uid) ELSE [dbo].TZ_ToUTC(@curedate,default,@uid) END, 'Year')
				
				SET @cursdate = DATEADD(mi, 1, @curedate)
			END			
		END
		
		IF @groupBy = 5
		-- Period should be set in hours
		BEGIN
			WHILE @cursdate < @edate
			BEGIN
				SET @curedate = CAST(DATEPART(yyyy,@cursdate) AS CHAR(4)) + '-' + CAST(DATEPART(mm,@cursdate) AS CHAR(2)) 
								+ '-' + CAST(DATEPART(dd,@cursdate) AS CHAR(2)) + ' ' + CAST(DATEPART(hh,@cursdate) AS CHAR(2)) + ':59'
				IF @curedate > @edate SET @curedate = @edate
				INSERT INTO @dateTable( Startdate , Enddate, PeriodType )
				VALUES (CASE WHEN @uid IS NULL THEN [dbo].TZ_ToUTC(@cursdate,'GMT Time',@uid) ELSE [dbo].TZ_ToUTC(@cursdate,default,@uid) END, 
						CASE WHEN @uid IS NULL THEN [dbo].TZ_ToUTC(@curedate,'GMT Time',@uid) ELSE [dbo].TZ_ToUTC(@curedate,default,@uid) END, 'Hour')
				
				SET @cursdate = DATEADD(mi, 1, @curedate)
			END			
		END		

		IF @groupBy = 6
		-- Period should be set at 15 mins
		BEGIN
			WHILE @cursdate < @edate
			BEGIN
				IF DATEPART(mi, @cursdate) BETWEEN 0 AND 14 SET @mins = 14
				IF DATEPART(mi, @cursdate) BETWEEN 15 AND 29 SET @mins = 29
				IF DATEPART(mi, @cursdate) BETWEEN 30 AND 44 SET @mins = 44
				IF DATEPART(mi, @cursdate) BETWEEN 45 AND 59 SET @mins = 59
				SET @curedate = CAST(DATEPART(yyyy,@cursdate) AS CHAR(4)) + '-' + CAST(DATEPART(mm,@cursdate) AS CHAR(2)) 
								+ '-' + CAST(DATEPART(dd,@cursdate) AS CHAR(2)) + ' ' + CAST(DATEPART(hh,@cursdate) AS CHAR(2)) + ':' + CAST(@mins AS CHAR(2))
				IF @curedate > @edate SET @curedate = @edate
				INSERT INTO @dateTable( Startdate , Enddate, PeriodType )
				VALUES (CASE WHEN @uid IS NULL THEN [dbo].TZ_ToUTC(@cursdate,'GMT Time',@uid) ELSE [dbo].TZ_ToUTC(@cursdate,default,@uid) END, 
						CASE WHEN @uid IS NULL THEN [dbo].TZ_ToUTC(@curedate,'GMT Time',@uid) ELSE [dbo].TZ_ToUTC(@curedate,default,@uid) END, '15 Mins')
				
				SET @cursdate = DATEADD(mi, 1, @curedate)
			END			
		END			
		
	END ELSE 
	BEGIN
		-- Set full period with no drilldown
		INSERT INTO @dateTable( Startdate , Enddate, PeriodType )
		VALUES (CASE WHEN @uid IS NULL THEN [dbo].TZ_ToUTC(@cursdate,'GMT Time',@uid) ELSE [dbo].TZ_ToUTC(@cursdate,default,@uid) END, 
				CASE WHEN @uid IS NULL THEN [dbo].TZ_ToUTC(@curedate,'GMT Time',@uid) ELSE [dbo].TZ_ToUTC(@curedate,default,@uid) END, 'Date Range')
	END
	
	--SELECT * FROM @dateTable
	RETURN
END


GO
