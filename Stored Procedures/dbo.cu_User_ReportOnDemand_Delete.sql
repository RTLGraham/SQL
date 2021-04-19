SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[cu_User_ReportOnDemand_Delete]
(
	@reportScheduleId INT
)
AS

UPDATE dbo.ReportOnDemand
SET Archived = 1
WHERE ReportOnDemandId = @reportScheduleId





GO
