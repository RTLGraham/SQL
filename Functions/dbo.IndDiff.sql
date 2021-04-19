SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[IndDiff] (@indicator int, @value float)
RETURNS float
AS
BEGIN
	DECLARE @inddiff float
		
	SELECT @inddiff = CASE WHEN HighLow=0 THEN [Max] - @value ELSE @value - [Max] END FROM dbo.ReportIndicators WHERE IndicatorId = @indicator
	
	RETURN @inddiff
END

GO
