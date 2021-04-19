SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[WeekDayHoursBetween] (@sdate DATETIME, @edate DATETIME)
RETURNS INT
AS	
BEGIN

	--DECLARE @sdate DATETIME,
	--		@edate DATETIME

	--SET @sdate = '2019-02-01 12:00'
	--SET @edate = '2019-02-04 20:00'

	DECLARE @hours INT
	SELECT @hours = SUM(DATEDIFF(HOUR, StartDate, EndDate))
	FROM dbo.CreateDependentDateRange (@sdate, @edate, NULL, 1, 1, 1)
	WHERE DATEPART(WEEKDAY, EndDate) NOT IN (7,1)

	RETURN @hours

END	
GO
