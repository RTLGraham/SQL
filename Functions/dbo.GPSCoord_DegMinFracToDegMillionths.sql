SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[GPSCoord_DegMinFracToDegMillionths] (@DegMinFrac [nvarchar] (4000))
RETURNS [float]
WITH EXECUTE AS CALLER
EXTERNAL NAME [SQLTypeConversions].[UserDefinedFunctions].[GPSCoord_DegMinFracToDegMillionths]
GO
EXEC sp_addextendedproperty N'AutoDeployed', N'yes', 'SCHEMA', N'dbo', 'FUNCTION', N'GPSCoord_DegMinFracToDegMillionths', NULL, NULL
GO
EXEC sp_addextendedproperty N'SqlAssemblyFile', N'GPSCoord_DegMinFracToDegMillionths.cs', 'SCHEMA', N'dbo', 'FUNCTION', N'GPSCoord_DegMinFracToDegMillionths', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=9
EXEC sp_addextendedproperty N'SqlAssemblyFileLine', @xp, 'SCHEMA', N'dbo', 'FUNCTION', N'GPSCoord_DegMinFracToDegMillionths', NULL, NULL
GO