SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_WorkingPeriod]
(
	@vids NVARCHAR(MAX),
	@uid UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME,
	@period TINYINT
)
AS

IF @period = 1
	EXECUTE dbo.[proc_ReportWorkingDay] 
	   @vids
	  ,@uid
	  ,@sdate
	  ,@edate
ELSE	
	SELECT 1 -- placeholder for proc_ReportWorkingMonth



GO
