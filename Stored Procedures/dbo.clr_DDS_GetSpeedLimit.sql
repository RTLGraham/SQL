SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[clr_DDS_GetSpeedLimit] (@lat [float], @lon [float], @heading [int], @speed [int], @maxSpeed [int], @vehicleType [int], @eventId [bigint])
WITH EXECUTE AS CALLER
AS EXTERNAL NAME [RTL.Two.TriggerAnalyseNotify].[RTL.Two.TriggerAnalyseNotify.DDSGeocodingCLR].[clr_DDS_GetSpeedLimit]
GO
