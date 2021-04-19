SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_IndicatorConfig_GetByReportConfig]
	@rprtcfgid uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;

          EXEC dbo.cuf_IndicatorConfig_GetByReportConfig @rprtcfgid;
END;

GO
