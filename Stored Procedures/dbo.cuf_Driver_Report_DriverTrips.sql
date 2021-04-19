SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[cuf_Driver_Report_DriverTrips]
(
	@did UNIQUEIDENTIFIER,
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER
)
AS
BEGIN
	EXECUTE dbo.[proc_ReportDriverTrips] 
	   @did
	  ,@sdate
	  ,@edate
	  ,@uid
END


GO
