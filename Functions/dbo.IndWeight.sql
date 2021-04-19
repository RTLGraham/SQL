SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[IndWeight] (@indicator int)
RETURNS float
AS
BEGIN
	DECLARE @indweight float
		
	SET @indweight = CAST((SELECT CAST([Weight] AS float) FROM dbo.ReportIndicators WHERE IndicatorId=@indicator)  AS float) / 100
	
	RETURN @indweight
END

GO
