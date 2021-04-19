SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[clr_DDS_ReverseGeocode] (@lat [float], @lon [float])
WITH EXECUTE AS CALLER
AS EXTERNAL NAME [RTL.Two.TriggerAnalyseNotify].[RTL.Two.TriggerAnalyseNotify.DDSGeocodingCLR].[clr_DDS_ReverseGeocode]
GO
