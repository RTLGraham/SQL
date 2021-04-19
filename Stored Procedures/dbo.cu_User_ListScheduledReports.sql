SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[cu_User_ListScheduledReports]
    (
      @userId UNIQUEIDENTIFIER
    )
AS 

--DECLARE @userid UNIQUEIDENTIFIER
--SET @userid = N'9ED68AB9-82A3-445F-A587-C853BDB4F3B3'

DECLARE @cid UNIQUEIDENTIFIER
SELECT TOP 1 @cid = CustomerId FROM dbo.[User] WHERE UserID = @userid

SELECT  rs.ReportScheduleID,
        r.Name,
		r.WidgetTypeId,
		rs.Description,
		rs.EmailSubject,
		CASE WHEN rs.Disabled = 1 THEN NULL ELSE dbo.TZ_GetTime(rsa.ScheduleDateTime, DEFAULT, @userid) END AS NextRunDateTime,
		dbo.TZ_GetTime(prev.CompletedDateTime, DEFAULT, @userid) AS LastRunDateTime,
		CASE prev.Status WHEN NULL THEN 'Not Yet Run' WHEN 1 THEN 'Executing' WHEN 2 THEN 'Successful' WHEN 3 THEN 'Failed' END AS STATUS,
		prev.Recipients,
		rs.Disabled,
		u.UserId AS CreatedBy,
		u.Name AS CreatedByName,
		CASE WHEN u.UserId = @userid THEN 0 ELSE 1 END AS IsReadOnly
		
FROM dbo.ReportSchedule rs
INNER JOIN dbo.[User] u ON rs.UserId = u.UserID
LEFT JOIN dbo.ReportScheduleActivity rsa ON rs.ReportScheduleId = rsa.ReportScheduleId AND rsa.Status IN (0,1)
INNER JOIN dbo.Report r ON rs.ReportId = r.ReportId
LEFT JOIN (
	SELECT	ROW_NUMBER() OVER (PARTITION BY rsa.ReportScheduleId ORDER BY CompletedDateTime DESC) AS RowNum,
			rsa.ReportScheduleId,
			rsa.CompletedDateTime,
			rsa.Status,
			rsa.Recipients
	FROM dbo.ReportScheduleActivity rsa
	INNER JOIN dbo.ReportSchedule rs ON rsa.ReportScheduleId = rs.ReportScheduleId
	WHERE rsa.Status > 0) prev ON rs.ReportScheduleId = prev.ReportScheduleId AND prev.RowNum = 1
WHERE u.CustomerID = @cid
  AND rs.Archived = 0
  AND rs.DayList != '0' -- exclude immediate reports
ORDER BY u.UserId DESC, r.Name, rs.Description

GO
