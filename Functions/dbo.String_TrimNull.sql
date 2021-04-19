SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[String_TrimNull] (@str [nvarchar] (4000))
RETURNS [nvarchar] (4000)
WITH EXECUTE AS CALLER
EXTERNAL NAME [SQLTypeConversions].[UserDefinedFunctions].[String_TrimNull]
GO
EXEC sp_addextendedproperty N'AutoDeployed', N'yes', 'SCHEMA', N'dbo', 'FUNCTION', N'String_TrimNull', NULL, NULL
GO
EXEC sp_addextendedproperty N'SqlAssemblyFile', N'String_TrimNull.cs', 'SCHEMA', N'dbo', 'FUNCTION', N'String_TrimNull', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=9
EXEC sp_addextendedproperty N'SqlAssemblyFileLine', @xp, 'SCHEMA', N'dbo', 'FUNCTION', N'String_TrimNull', NULL, NULL
GO
