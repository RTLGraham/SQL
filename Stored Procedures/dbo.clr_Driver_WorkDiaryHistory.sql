SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[clr_Driver_WorkDiaryHistory] (@trackerID [nvarchar] (4000), @driverID [nvarchar] (4000), @filename [nvarchar] (4000) OUTPUT)
WITH EXECUTE AS CALLER
AS EXTERNAL NAME [RTL.Two.CLR.Data].[RTL.Two.CLR.Data.StoredProcedures].[WorkDiaryHistory]
GO
EXEC sp_addextendedproperty N'SqlAssemblyFile', N'WorkDiaryHistory.cs', 'SCHEMA', N'dbo', 'PROCEDURE', N'clr_Driver_WorkDiaryHistory', NULL, NULL
GO
EXEC sp_addextendedproperty N'SqlAssemblyFileLine', N'19', 'SCHEMA', N'dbo', 'PROCEDURE', N'clr_Driver_WorkDiaryHistory', NULL, NULL
GO
