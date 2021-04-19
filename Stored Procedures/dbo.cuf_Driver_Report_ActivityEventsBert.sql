SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE PROCEDURE [dbo].[cuf_Driver_Report_ActivityEventsBert]
(
	@did UNIQUEIDENTIFIER,
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER
)
AS
BEGIN

	EXECUTE dbo.[proc_Report_ActivityEventsByDriver_Bert] 
	   @did
	  ,@uid
	  ,@sdate
	  ,@edate


END


GO
