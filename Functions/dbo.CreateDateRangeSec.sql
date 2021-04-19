SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[CreateDateRangeSec]( @sdate DATETIME, @edate DATETIME, @periodnum INT = 1 )
	RETURNS @dateTable TABLE ( StartDate DATETIME, EndDate DATETIME )
AS
BEGIN
	--DECLARE @sdate DATETIME,
	--		@edate DATETIME,
	--		@periodnum INT
			
	--DECLARE	@dateTable TABLE ( StartDate DATETIME, EndDate DATETIME )
	
	--SET @sdate = '2010-09-27 00:00:00'
	--SET @edate = '2010-10-31 23:59:59'
	--SET @periodnum = 168
			
	DECLARE @cursdate DATETIME,
			@curedate DATETIME

	SET @cursdate = @sdate
	SET @curedate = @edate

	WHILE @cursdate < @edate
	BEGIN
		-- split into bite-sized chunks
		SET @curedate = DATEADD( Second, -1, DATEADD(hh, @periodnum, @cursdate))
		
		INSERT INTO @dateTable( startdate , enddate )
		VALUES (@cursdate, @curedate)
		
		SET @cursdate = DATEADD(Second, 1, @curedate)
	END

	--SELECT * FROM @dateTable
	RETURN
END

GO
