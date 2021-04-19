SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_Report_DriverCoachingSessions_RS]
          @uid UNIQUEIDENTIFIER,
          @dids NVARCHAR(MAX),
          @sdate DATETIME,
          @edate DATETIME
AS
	SET NOCOUNT ON;

	EXECUTE dbo.[cuf_Driver_CoachingSessions] 
	   @uid
	  ,@dids
	  ,@sdate
	  ,@edate


GO
