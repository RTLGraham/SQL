SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[IndWeightConfig] (@indicator int, @rprtcfgid uniqueidentifier)
RETURNS float
AS
BEGIN
	DECLARE @indweight float
		
	SET @indweight = CAST((SELECT CAST([Weight] AS float) 
	FROM dbo.ReportIndicatorConfig 
	WHERE IndicatorId=@indicator AND ReportConfigurationId=@rprtcfgid)  AS float) / 100
	
	RETURN @indweight
END



GO
