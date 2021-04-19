SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Driver_VideoTool]
(
	@dids NVARCHAR(MAX), 
	@status VARCHAR(MAX),
    @uid UNIQUEIDENTIFIER,
	@sdate DATETIME, 
	@edate DATETIME
)
AS

	EXEC dbo.proc_VideoTool_Driver @dids, @status,@uid, @sdate, @edate
GO
