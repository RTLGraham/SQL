SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[clr_DDS_GetSpeedLimitWithFullPostcode] (@lat [float], @lon [float], @heading [int], @vehicleType [int], @speed [int], @maxSpeed [int], @eventId [bigint])
WITH EXECUTE AS CALLER
AS EXTERNAL NAME [RTL.Two.TriggerAnalyseNotify].[RTL.Two.TriggerAnalyseNotify.DDSGeocodingCLR].[clr_DDS_GetSpeedLimitWithFullPostcode]
GO
