SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[proc_GetAddressFromService] (@lat [float], @lon [float])
WITH EXECUTE AS CALLER
AS EXTERNAL NAME [RTL.Two.TriggerAnalyseNotify].[RTL.Two.TriggerAnalyseNotify.GetAddressFromServiceCLR].[proc_GetAddressFromService]
GO
