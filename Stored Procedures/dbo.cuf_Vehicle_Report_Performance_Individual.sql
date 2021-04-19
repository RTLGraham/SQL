SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_Performance_Individual]
(
	@vid UNIQUEIDENTIFIER,
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER,
	@flexible BIT
)
AS
BEGIN
	EXECUTE dbo.[proc_ReportPerformance_Individual] 
	   @vid
	  ,1
	  ,NULL
	  ,@sdate
	  ,@edate
	  ,@uid
	  ,@rprtcfgid
	  ,@flexible
END



GO
