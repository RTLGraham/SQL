SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_Performance_Fleet]
(
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER
)
AS
BEGIN
	EXECUTE dbo.[proc_ReportPerformance_Fleet] 
	   1
	  ,@uid
	  ,@rprtcfgid
END


GO
