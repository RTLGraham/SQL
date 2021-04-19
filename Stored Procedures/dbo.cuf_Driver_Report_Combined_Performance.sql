SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[cuf_Driver_Report_Combined_Performance]
(
	@driverid UNIQUEIDENTIFIER,
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER
)
AS
BEGIN
	EXECUTE dbo.[proc_ReportCombined_Performance] 
	   @driverid
	  ,2
	  ,@sdate
	  ,@edate
	  ,@uid
	  ,@rprtcfgid
END


GO
