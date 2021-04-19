SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cu_User_EnableReportSchedule]
          @uid uniqueidentifier,
          @scheduleid int,
          @enabled bit
AS
	SET NOCOUNT ON;

          UPDATE    ReportSchedule
          SET       Disabled = ~@enabled
          WHERE     ReportScheduleID = @scheduleid;
GO
