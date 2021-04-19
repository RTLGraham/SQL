SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_SETDashboard]
(
	@gids VARCHAR(MAX),
	@uid UNIQUEIDENTIFIER,
	@top3type INT,
	@rprtcfgid UNIQUEIDENTIFIER
)
AS
BEGIN
	EXECUTE dbo.[proc_ReportSET_Dashboard] 
	   @gids
	  ,@uid
	  ,@top3type
	  ,@rprtcfgid
END


GO
