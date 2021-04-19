SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[IndMinConfig] (@indicator int, @rprtcfgid uniqueidentifier)
RETURNS float
AS
BEGIN
	DECLARE @indmin float
		
	SET @indmin = CAST((SELECT TOP 1 CAST([Min] AS float) 
	FROM dbo.ReportIndicatorConfig 
	WHERE IndicatorId=@indicator AND ReportConfigurationId = @rprtcfgid)  AS float)
	
	RETURN @indmin
END

GO
