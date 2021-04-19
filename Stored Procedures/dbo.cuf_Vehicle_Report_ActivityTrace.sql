SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_ActivityTrace]
(
	@vids VARCHAR(MAX),
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER
)
AS
BEGIN

	EXECUTE dbo.[proc_Report_ActivityTraceByVehicle] 
	   @vids
	  ,@uid
	  ,@sdate
	  ,@edate


END


GO
