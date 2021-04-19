SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[IndPercent] (@indicator int, @value float)
RETURNS float
AS
BEGIN
	DECLARE @indpercent float
		
	SELECT @indpercent = CASE WHEN [Type]='P' THEN @value * 100 ELSE @value END FROM dbo.ReportIndicators WHERE IndicatorId=@indicator
	
	RETURN @indpercent
END

GO
