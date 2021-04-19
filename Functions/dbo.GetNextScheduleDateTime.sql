SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[GetNextScheduleDateTime] 
(
	@daylist VARCHAR(15),
	@datelist VARCHAR(30),
	@schtime DATETIME,
	@userid UNIQUEIDENTIFIER
)
RETURNS DATETIME
AS
BEGIN

--	DECLARE @daylist VARCHAR(15),
--			@datelist VARCHAR(30),
--			@schtime DATETIME,
--			@userid UNIQUEIDENTIFIER
--	
--	SET @daylist = NULL--'5'
--	SET @datelist = '0'
--	SET @schtime = '2015-04-25 20:42'
--	SET @userid = N'9ED68AB9-82A3-445F-A587-C853BDB4F3B3'

	DECLARE @result DATETIME,
			@now DATETIME,
			@endofmonth BIT,
			@lastday INT
			
	DECLARE @Range TABLE 
	(
		DayNum INT,
		CalcDate DATETIME
	)
			
	SET @now = GETUTCDATE()
	
	IF @daylist = '0'
	BEGIN -- schedule to run immediately
	
		INSERT INTO @Range (DayNum, CalcDate)
		VALUES (0, @now)	
		
	END ELSE	
	IF ISNULL(@daylist, '') = '' 
	BEGIN -- scheduled based on date in month
		
		INSERT INTO @Range (DayNum)
		SELECT VALUE FROM dbo.Split(dbo.TZ_GetDayList(@schtime, DEFAULT, @userid, @datelist, 0), ',')
				
		-- calculate dates according to selected values
		UPDATE @Range
		SET CalcDate = CAST(CAST(YEAR(@now) AS VARCHAR(4)) + '-' + RIGHT('0' + CAST(MONTH(@now) AS VARCHAR(2)),2) + '-' + RIGHT('0' + CAST(DayNum AS VARCHAR(2)),2) + ' ' + CONVERT(VARCHAR(8), @schtime, 108) AS DATETIME)
		FROM @Range
		WHERE DayNum != -1

		-- repeat date calculation for end of month option		
		SELECT @lastday = CASE WHEN MONTH(@now) IN (4,6,9,11) THEN 30 ELSE 31 END
		IF MONTH(@now) = 2
		BEGIN
			IF (YEAR(@now) % 4 = 0) AND (YEAR(@now) % 100 != 0) OR (YEAR(@now) % 400 = 0)
				SET @lastday = 29
			ELSE 
				SET @lastday = 28
		END
		
		UPDATE @Range
		SET CalcDate = CAST(CAST(YEAR(@now) AS VARCHAR(4)) + '-' + RIGHT('0' + CAST(MONTH(@now) AS VARCHAR(2)),2) + '-' + RIGHT('0' + CAST(@lastday AS VARCHAR(2)),2) + ' ' + CONVERT(VARCHAR(8), @schtime, 108) AS DATETIME)
		FROM @Range
		WHERE DayNum = -1
			
		-- For any dates that have already passed add 1 month
		UPDATE @Range
		SET CalcDate = DATEADD(mm, 1, CalcDate)
		WHERE CalcDate < @now
		
	END ELSE
	BEGIN -- schedule based on day of week
		
		DECLARE @DayTable TABLE (DayNum INT, CalcDate DATETIME)
		
		-- Insert the next 7 dates into temporary table
		INSERT INTO @DayTable (DayNum, CalcDate) VALUES (DATEPART(dw, @now), @now)
		INSERT INTO @DayTable (DayNum, CalcDate) VALUES (DATEPART(dw, DATEADD(dd, 1, @now)), dateadd(dd, 1, @now))
		INSERT INTO @DayTable (DayNum, CalcDate) VALUES (DATEPART(dw, DATEADD(dd, 2, @now)), dateadd(dd, 2, @now))
		INSERT INTO @DayTable (DayNum, CalcDate) VALUES (DATEPART(dw, DATEADD(dd, 3, @now)), dateadd(dd, 3, @now))
		INSERT INTO @DayTable (DayNum, CalcDate) VALUES (DATEPART(dw, DATEADD(dd, 4, @now)), dateadd(dd, 4, @now))
		INSERT INTO @DayTable (DayNum, CalcDate) VALUES (DATEPART(dw, DATEADD(dd, 5, @now)), dateadd(dd, 5, @now))
		INSERT INTO @DayTable (DayNum, CalcDate) VALUES (DATEPART(dw, DATEADD(dd, 6, @now)), dateadd(dd, 6, @now))
		
		INSERT INTO @Range (DayNum)
		SELECT VALUE FROM dbo.Split(@daylist, ',')
			
		UPDATE @Range
		SET CalcDate = CAST(CAST(YEAR(d.CalcDate) AS VARCHAR(4)) + '-' + RIGHT('0' + CAST(MONTH(d.CalcDate) AS VARCHAR(2)),2) + '-' + RIGHT('0' + CAST(DATEPART(dd, d.CalcDate) AS VARCHAR(2)),2) + ' ' + CONVERT(VARCHAR(8), @schtime, 108) AS DATETIME)
		FROM @Range r
		INNER JOIN @DayTable d ON r.DayNum = d.DayNum
		
		-- For any dates that have already passed add 1 week
		UPDATE @Range
		SET CalcDate = DATEADD(dd, 7, CalcDate)
		WHERE CalcDate < @now

	END

	SELECT TOP 1 @Result = CalcDate
	FROM @Range
	ORDER BY CalcDate 
	
--	SELECT @Result	
	RETURN @Result

END



GO
