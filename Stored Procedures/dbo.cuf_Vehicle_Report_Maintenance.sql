SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_Maintenance]
(
	@vids VARCHAR(MAX),
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER
)
AS
BEGIN
	SET NOCOUNT ON
	EXECUTE dbo.[proc_ReportMaintenance] 
	   @vids
	  ,@sdate
	  ,@edate
	  ,@uid

END




GO
