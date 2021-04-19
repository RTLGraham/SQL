SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[cu_User_ReportSchedule_Delete]
(
	@reportScheduleId INT
)
AS

UPDATE dbo.ReportSchedule
SET Archived = 1
WHERE ReportScheduleId = @reportScheduleId





GO
