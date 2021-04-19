SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_Report_DriverCoachingLog_RS]
          @uid UNIQUEIDENTIFIER,
          @gids NVARCHAR(MAX),
          @sdate DATETIME,
          @edate DATETIME
AS
	SET NOCOUNT ON;

	EXECUTE dbo.[cuf_Driver_CoachingLog] 
	   @uid
	  ,@gids
	  ,@sdate
	  ,@edate


GO
