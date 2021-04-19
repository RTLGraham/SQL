SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[CreateDateRange_Minutes]( @sdate DATETIME, @edate DATETIME, @periodnum FLOAT = 60 )
	RETURNS @dateTable TABLE ( StartDate DATETIME, EndDate DATETIME )
AS
BEGIN
	--DECLARE @sdate DATETIME,
	--		@edate DATETIME,
	--		@periodnum INT
			
	--DECLARE	@dateTable TABLE ( StartDate DATETIME, EndDate DATETIME )
	
	--SET @sdate = '2010-10-01'
	--SET @edate = '2010-10-21'
	--SET @periodnum = 168
			
	DECLARE @cursdate DATETIME,
			@curedate DATETIME

	SET @cursdate = @sdate
	SET @curedate = @edate

	WHILE @cursdate < @edate
	BEGIN
		-- split into bite-sized chunks
		SET @curedate = DATEADD( ms, -1, DATEADD(mm, @periodnum, @cursdate))

		INSERT INTO @dateTable( startdate , enddate )
		VALUES (@cursdate, @curedate)
		
		SET @cursdate = DATEADD(ms, 1, @curedate)
	END

	--SELECT * FROM @dateTable
	RETURN
END

GO
