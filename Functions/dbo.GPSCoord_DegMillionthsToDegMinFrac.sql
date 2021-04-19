SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[GPSCoord_DegMillionthsToDegMinFrac] (@DegMillionths [float])
RETURNS [nvarchar] (4000)
WITH EXECUTE AS CALLER
EXTERNAL NAME [SQLTypeConversions].[UserDefinedFunctions].[GPSCoord_DegMillionthsToDegMinFrac]
GO
EXEC sp_addextendedproperty N'AutoDeployed', N'yes', 'SCHEMA', N'dbo', 'FUNCTION', N'GPSCoord_DegMillionthsToDegMinFrac', NULL, NULL
GO
EXEC sp_addextendedproperty N'SqlAssemblyFile', N'GPSCoord_DegMillionthsToDegMinFrac.cs', 'SCHEMA', N'dbo', 'FUNCTION', N'GPSCoord_DegMillionthsToDegMinFrac', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=9
EXEC sp_addextendedproperty N'SqlAssemblyFileLine', @xp, 'SCHEMA', N'dbo', 'FUNCTION', N'GPSCoord_DegMillionthsToDegMinFrac', NULL, NULL
GO
