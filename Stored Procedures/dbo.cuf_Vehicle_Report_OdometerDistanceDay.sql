SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_OdometerDistanceDay]
(
	@gids VARCHAR(MAX),
	@vids VARCHAR(MAX),
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER
)
AS
	EXECUTE dbo.[proc_ReportTotalDistanceReporting] 
	   @gids
	  ,@vids
	  ,@sdate
	  ,@edate
	  ,@uid			



GO
