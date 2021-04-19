SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_EngineHoursV2]
(
	@gids VARCHAR(MAX),
	@vids VARCHAR(MAX),
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER
)
AS
BEGIN
	EXECUTE dbo.proc_ReportEngineHoursV2
		@gids,
	    @vids,
	    @sdate,
	    @edate,
	    @uid

END





GO
