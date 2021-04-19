SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_VT_GetRequestedVideos]
(
	@vids NVARCHAR(MAX), 
    @uid UNIQUEIDENTIFIER,
	@sdate DATETIME, 
	@edate DATETIME
)
AS

	EXEC dbo.proc_VT_GetRequestedVideos @vids, @uid, @sdate, @edate


GO
