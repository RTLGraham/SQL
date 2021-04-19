SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Driver_VideoTool_Escalated]
(
	@did UNIQUEIDENTIFIER
)
AS

	EXEC dbo.proc_VideoTool_Driver_Escalated @did


GO
