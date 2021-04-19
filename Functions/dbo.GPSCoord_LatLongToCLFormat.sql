SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[GPSCoord_LatLongToCLFormat] (@DegMillionths [float])
RETURNS [nvarchar] (4000)
WITH EXECUTE AS CALLER
EXTERNAL NAME [SQLTypeConversions].[UserDefinedFunctions].[GPSCoord_LatLongToCLFormat]
GO
EXEC sp_addextendedproperty N'AutoDeployed', N'yes', 'SCHEMA', N'dbo', 'FUNCTION', N'GPSCoord_LatLongToCLFormat', NULL, NULL
GO
EXEC sp_addextendedproperty N'SqlAssemblyFile', N'GPSCoord_LatLongToCLFormat.cs', 'SCHEMA', N'dbo', 'FUNCTION', N'GPSCoord_LatLongToCLFormat', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=10
EXEC sp_addextendedproperty N'SqlAssemblyFileLine', @xp, 'SCHEMA', N'dbo', 'FUNCTION', N'GPSCoord_LatLongToCLFormat', NULL, NULL
GO
