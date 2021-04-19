SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_Combined_Performance]
(
	@vehicleid UNIQUEIDENTIFIER,
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER
)
AS
BEGIN
	EXECUTE dbo.[proc_ReportCombined_Performance] 
	   @vehicleid
	  ,1
	  ,@sdate
	  ,@edate
	  ,@uid
	  ,@rprtcfgid
END


GO
