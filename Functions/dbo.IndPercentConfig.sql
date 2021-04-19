SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[IndPercentConfig] (@indicator int, @value float, @rprtcfgid uniqueidentifier)
RETURNS float
AS
BEGIN
	DECLARE @indpercent float
		
	SELECT @indpercent = CASE WHEN [Type]='P' THEN @value * 100 ELSE @value END 
	FROM dbo.ReportIndicatorConfig 
	WHERE IndicatorId=@indicator 
	  AND ReportConfigurationId = @rprtcfgid
	
	RETURN @indpercent
END

GO
