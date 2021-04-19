SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_Heartbeat]
(
	@vids VARCHAR(MAX),
	@uid UNIQUEIDENTIFIER
)
AS
BEGIN
	EXECUTE dbo.[proc_ReportHeartbeat] 
	   @vids
	  ,@uid
END




GO
