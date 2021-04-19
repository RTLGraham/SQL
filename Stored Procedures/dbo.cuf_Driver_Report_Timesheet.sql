SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Driver_Report_Timesheet]
(
	@did UNIQUEIDENTIFIER,
	@uid UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME
	
)
AS

	EXECUTE dbo.[proc_ReportDriverTimesheet] 
	   @did
	  ,@uid
	  ,@sdate
	  ,@edate


GO
