SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[clr_DDS_GetSpeedLimits] (@sdate [datetime], @edate [datetime])
WITH EXECUTE AS CALLER
AS EXTERNAL NAME [RTL.Two.TriggerAnalyseNotify].[RTL.Two.TriggerAnalyseNotify.DDSGeocodingCLR].[clr_DDS_GetSpeedLimits]
GO
