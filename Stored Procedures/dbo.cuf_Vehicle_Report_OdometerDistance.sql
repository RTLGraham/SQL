SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_OdometerDistance]
(
	@gids VARCHAR(MAX),
	@vids VARCHAR(MAX),
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER
)
AS
BEGIN

	EXECUTE dbo.[proc_ReportTotalDistance] 
	   @gids
	  ,@vids
	  ,@sdate
	  ,@edate
	  ,@uid			

END





GO
