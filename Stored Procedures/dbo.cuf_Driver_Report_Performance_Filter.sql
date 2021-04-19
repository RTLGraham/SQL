SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [dbo].[cuf_Driver_Report_Performance_Filter]
(
	@gids VARCHAR(MAX),
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER
)
AS
BEGIN
	EXECUTE dbo.[proc_ReportPerformance_Filter] 
	   @gids
	  ,2
	  ,NULL
	  ,@sdate
	  ,@edate
	  ,@uid
	  ,@rprtcfgid
END



GO
