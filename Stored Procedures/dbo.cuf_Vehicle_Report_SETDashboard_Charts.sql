SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_SETDashboard_Charts]
(
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER,
	@period INT
)
AS
BEGIN
	EXECUTE dbo.[proc_ReportSET_Dashboard_Charts] 
	   @uid
	  ,@rprtcfgid
	  ,@period
END


GO
