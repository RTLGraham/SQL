SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE PROCEDURE [dbo].[cuf_Driver_Report_ActivityTrace]
(
	@did UNIQUEIDENTIFIER,
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER
)
AS
BEGIN

	EXECUTE dbo.[proc_Report_ActivityTraceByDriver] 
	   @did
	  ,@uid
	  ,@sdate
	  ,@edate


END


GO
