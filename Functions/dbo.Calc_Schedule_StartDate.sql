SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[Calc_Schedule_StartDate] (@paramdate datetime, @uid UNIQUEIDENTIFIER)
RETURNS datetime
AS
--
-- This function calculates the start date for a scheduled report identified by a start date 
-- with year = 1960 or 1961
-- The start date will be set to dd days prior to today's midnight point where the date is 1960
-- where dd is the dd datepart of the input date parameter
-- dd = 01 signifies today, dd = 02 signifies yesterday
-- The start date will be set to mm months prior to today's midnight point where the date is 1961
-- where mm is the mm datepart of the input date parameter
-- mm = 01 signifies current month, mm = 02 signifies last month
-- The returned datetime will be in the timezone of the user specified
--
BEGIN

	DECLARE @startdate datetime
	DECLARE @dd int
	DECLARE @mm INT
	
	-- Initialise startdate to previous midnight point (where the day is based upon the users timezone relative to UTC)
	SET @startdate = CAST(FLOOR( CAST( dbo.TZ_GetTime(GETUTCDATE(),DEFAULT,@uid) AS FLOAT )) AS DATETIME)
	
	IF DATEPART(yyyy, @paramdate) = '1960'
	BEGIN
		SET @dd = (datepart(dd, @paramdate) * -1) + 1 -- calculate number of days to schedule		
		SET @startdate = dateadd(dd, @dd, @startdate)
	END
	
	IF DATEPART(yyyy, @paramdate) = '1961'
	BEGIN
		-- reset start date to the 1st of the month (still in user's time zone)
		SET @dd = (DATEPART(dd, @startdate) * -1) + 1
		SET @startdate = DATEADD(dd, @dd, @startdate)		
		SET @mm = (datepart(mm, @paramdate) * -1) + 1 -- calculate number of months to schedule
		SET @startdate = DATEADD(mm, @mm, @startdate)
	END
		
	RETURN @startdate
END


GO
