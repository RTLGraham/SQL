SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE PROCEDURE [dbo].[cuf_Driver_Report_MileageClaimSummary]
(
	@did UNIQUEIDENTIFIER,
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER
)
AS
BEGIN
	EXECUTE dbo.proc_ReportMileageClaimSummaryByDriver 
	   @did
	  ,@sdate
	  ,@edate
	  ,@uid
END



GO
