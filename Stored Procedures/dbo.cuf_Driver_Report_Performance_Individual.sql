SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [dbo].[cuf_Driver_Report_Performance_Individual]
(
	@did UNIQUEIDENTIFIER,
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER,
	@flexible BIT
)
AS
BEGIN

	EXECUTE dbo.[proc_ReportPerformance_Individual] 
	   @did
	  ,2
	  ,NULL
	  ,@sdate
	  ,@edate
	  ,@uid
	  ,@rprtcfgid
	  ,@flexible
END




GO
