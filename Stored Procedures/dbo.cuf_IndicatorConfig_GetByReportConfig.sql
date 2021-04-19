SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_IndicatorConfig_GetByReportConfig](
	@rprtcfgid UNIQUEIDENTIFIER
)
AS
BEGIN

--	DECLARE @rprtcfgid UNIQUEIDENTIFIER
--	SET @rprtcfgid = N'77C80BDB-5827-4C5E-BBF4-06F36ACB47D6'
	
	SELECT  C.IndicatorConfigId,
	        C.IndicatorId,
	        C.ReportConfigurationId,
	        C.Min,
	        C.Max,
	        C.Weight,
	        C.GYRGreenMax,
	        C.GYRAmberMax,
	        C.GYRRedMax,
	        C.Target,
            I.HighLow,
			I.IndicatorClass,
			I.Name,
			I.UnitOfMeasureType,
			I.Description
	FROM dbo.IndicatorConfig C
                    INNER JOIN Indicator I ON I.IndicatorId = C.IndicatorId
	WHERE C.ReportConfigurationId = @rprtcfgid
	  AND C.Archived = 0

END

SELECT * FROM Indicator
GO
