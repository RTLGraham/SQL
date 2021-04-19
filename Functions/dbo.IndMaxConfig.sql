SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[IndMaxConfig] (@indicator int, @rprtcfgid uniqueidentifier)
RETURNS float
AS
BEGIN
	DECLARE @indmax float
		
	SET @indmax = CAST((SELECT TOP 1 CAST([Max] AS float) 
	FROM dbo.ReportIndicatorConfig 
	WHERE IndicatorId=@indicator AND ReportConfigurationId = @rprtcfgid)  AS float)
	
	RETURN @indmax
END

GO
