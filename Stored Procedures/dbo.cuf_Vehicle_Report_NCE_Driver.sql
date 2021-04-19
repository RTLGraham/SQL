SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_NCE_Driver]
(
	@gid UNIQUEIDENTIFIER,
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER
)
AS
BEGIN
	EXECUTE dbo.[proc_ReportNCE_Driver] 
	   @gid
	  ,@sdate
	  ,@edate
	  ,@uid
END



GO
