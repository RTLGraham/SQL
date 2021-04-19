SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Driver_VideoList]
(
	@dids NVARCHAR(MAX), 
	@types VARCHAR(MAX),
    @uid UNIQUEIDENTIFIER,
	@sdate DATETIME, 
	@edate DATETIME
)
AS

	EXEC dbo.proc_VideoList_Driver @dids, @types,@uid, @sdate, @edate


GO
