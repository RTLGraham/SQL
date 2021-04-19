SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [dbo].[cuf_Driver_Report_MileageClaim]
(
	@did UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME,
	@uid UNIQUEIDENTIFIER
)
AS
BEGIN
	EXECUTE dbo.proc_ReportMileageClaimByDriver 
	   @did
	  ,@sdate
	  ,@edate
	  ,@uid
END



GO
