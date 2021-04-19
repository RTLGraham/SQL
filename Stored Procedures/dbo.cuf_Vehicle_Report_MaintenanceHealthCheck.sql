SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_MaintenanceHealthCheck]
(
	@vids VARCHAR(MAX),
	@uid UNIQUEIDENTIFIER,
	@date DATETIME = NULL
)
AS
BEGIN
	SET NOCOUNT ON
	EXECUTE dbo.[proc_ReportMaintenanceHealthCheckByDate] 
	   @vids
	  ,@uid
	  ,@date

END





GO
