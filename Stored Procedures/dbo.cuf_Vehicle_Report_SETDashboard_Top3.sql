SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_SETDashboard_Top3]
(
	@uid UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME,
	@rprtcfgid UNIQUEIDENTIFIER,
	@groups BIT
)
AS
BEGIN
	EXECUTE dbo.[proc_ReportSET_Dashboard_Top3] 
	   @uid
	  ,@sdate
	  ,@edate
	  ,@rprtcfgid
	  ,@groups
END


GO
