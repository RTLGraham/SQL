SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Vehicle_VideoTool]
(
	@vids NVARCHAR(MAX), 
	@status VARCHAR(MAX),
    @uid UNIQUEIDENTIFIER,
	@sdate DATETIME, 
	@edate DATETIME
)
AS

	EXEC dbo.proc_VideoTool_Vehicle @vids, @status,@uid, @sdate, @edate
GO
