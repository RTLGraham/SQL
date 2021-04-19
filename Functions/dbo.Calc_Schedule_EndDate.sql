SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[Calc_Schedule_EndDate] (@paramdate datetime, @uid UNIQUEIDENTIFIER)
RETURNS datetime
AS
--
-- This function calculates the end date for a scheduled report identified by a start date 
-- with year = 1960 or 1961
-- The end date will be set to now or today's midnight point where the date is 1960
-- depending whether we are running for today or previous days
-- dd = 01 signifies today, dd = 02 signifies yesterday, etc.
-- The end date will be set to now or the last day of the month mm - 1 months ago where the date is 1961
-- where mm is the mm datepart of the input date parameter
-- mm = 01 signifies current month, mm = 02 signifies last month
-- The returned datetime will be in the timezone of the user specified
--
BEGIN

	DECLARE @enddate DATETIME
	DECLARE @dd INT
	DECLARE @mm INT

	IF DATEPART(yyyy, @paramdate) = '1960'
	BEGIN
		IF DATEPART(dd, @paramdate) = 1 -- End date should be current datetime as we are running for today
			SET @enddate = dbo.TZ_GetTime(GETUTCDATE(),DEFAULT,@uid)
		ELSE -- End date should be set to previous midnight point (-1 minute) since we are running for previous day(s)
			SET @enddate = DATEADD(mi, -1, CAST(FLOOR( CAST( dbo.TZ_GetTime(GETUTCDATE(),DEFAULT,@uid) AS FLOAT ) )AS DATETIME))
	END
	
	IF DATEPART(yyyy, @paramdate) = '1961'
	BEGIN
		IF DATEPART(mm, @paramdate) = 1 -- End date should be current datetime as we are running for current month
			SET @enddate = dbo.TZ_GetTime(GETUTCDATE(),DEFAULT,@uid)
		ELSE -- End date should be set to last day of the appropriate previous month
		BEGIN
			-- Initialise enddate to 1 minute prior to today's midnight point (where the day is based upon the users timezone relative to UTC)
			SET @enddate = CAST(CEILING( CAST( dbo.TZ_GetTime(GETUTCDATE(),DEFAULT,@uid) AS FLOAT )) AS DATETIME)
			SET @enddate = DATEADD(mi, -1, @enddate)
			-- subtract the number of days for the current date to get to the end of the previous month
			SET @dd = (DATEPART(dd, @enddate) * -1)
			SET @enddate = DATEADD(dd, @dd, @enddate)
			-- now determine how many months to go back
			SET @mm = (DATEPART(mm, @paramdate) * -1) + 2
			SET @enddate = DATEADD(mm, @mm, @enddate)
		END
	END
	
	RETURN @enddate
END


GO
