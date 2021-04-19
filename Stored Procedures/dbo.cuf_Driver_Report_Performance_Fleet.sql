SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[cuf_Driver_Report_Performance_Fleet]
(
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER
)
AS
BEGIN
	EXECUTE dbo.[proc_ReportPerformance_Fleet] 
	   2
	  ,@uid
	  ,@rprtcfgid
END


GO
