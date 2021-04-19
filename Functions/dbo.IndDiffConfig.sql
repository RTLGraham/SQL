SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[IndDiffConfig] (@indicator int, @value float, @rprtcfgid uniqueidentifier)
RETURNS float
AS
BEGIN
	DECLARE @inddiff float
		
	SELECT @inddiff = CASE WHEN HighLow=0 THEN [Max] - @value ELSE @value - [Max] END 
	FROM dbo.ReportIndicatorConfig
	WHERE IndicatorId = @indicator AND ReportConfigurationId = @rprtcfgid
	
	RETURN @inddiff
END

GO
