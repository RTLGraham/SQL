SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_VideoList]
(
	@vids NVARCHAR(MAX), 
	@types VARCHAR(MAX),
    @uid UNIQUEIDENTIFIER,
	@sdate DATETIME, 
	@edate DATETIME
)
AS

	EXEC dbo.proc_VideoList_Vehicle @vids, @types,@uid, @sdate, @edate


GO
