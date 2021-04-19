SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_EngineHours]
(
	@uid UNIQUEIDENTIFIER,
	@vid UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME
)
AS

EXECUTE dbo.[proc_ReportEngineHours] 
   @vid
  ,@sdate
  ,@edate
  ,@uid



GO
