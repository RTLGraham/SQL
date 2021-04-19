SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Driver_Report_WorkDiary]
(
	@did UNIQUEIDENTIFIER,
	@sdate datetime,
	@edate datetime,
	@uid uniqueidentifier
)
AS
BEGIN

	EXECUTE dbo.[proc_ReportDriverWorkDiary] 
	   @did
	  ,@uid
	  ,@sdate

END


GO
