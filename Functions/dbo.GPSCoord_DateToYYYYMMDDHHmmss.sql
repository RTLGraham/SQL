SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[GPSCoord_DateToYYYYMMDDHHmmss] (@date [datetime])
RETURNS [nvarchar] (4000)
WITH EXECUTE AS CALLER
EXTERNAL NAME [SQLTypeConversions].[UserDefinedFunctions].[GPSCoord_DateToYYYYMMDDHHmmss]
GO
EXEC sp_addextendedproperty N'AutoDeployed', N'yes', 'SCHEMA', N'dbo', 'FUNCTION', N'GPSCoord_DateToYYYYMMDDHHmmss', NULL, NULL
GO
EXEC sp_addextendedproperty N'SqlAssemblyFile', N'GPSCoord_DateToYYYYMMDDHHmmss.cs', 'SCHEMA', N'dbo', 'FUNCTION', N'GPSCoord_DateToYYYYMMDDHHmmss', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=9
EXEC sp_addextendedproperty N'SqlAssemblyFileLine', @xp, 'SCHEMA', N'dbo', 'FUNCTION', N'GPSCoord_DateToYYYYMMDDHHmmss', NULL, NULL
GO
