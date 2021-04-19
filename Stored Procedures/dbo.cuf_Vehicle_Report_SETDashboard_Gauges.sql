SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_SETDashboard_Gauges]
(
	@uid UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME,
	@rprtcfgid UNIQUEIDENTIFIER
)
AS
BEGIN
	EXECUTE dbo.[proc_ReportSET_Dashboard_Gauges] 
	   @uid
	  ,@sdate
	  ,@edate
	  ,@rprtcfgid
END


GO
