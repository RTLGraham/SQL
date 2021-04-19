SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[cu_User_ListOnDemandReports]
    (
      @userId UNIQUEIDENTIFIER
    )
AS 

--DECLARE @userid UNIQUEIDENTIFIER
--SET @userid = N'AE49B2CA-E1A5-4800-AD69-6218B00A6E83'

DECLARE @cid UNIQUEIDENTIFIER
SELECT @cid = CustomerID
FROM dbo.[User]
WHERE UserID = @userid

SELECT rod.ReportOnDemandId AS ReportScheduleId,
	   r.Name,
	   r.WidgetTypeId,
	   rod.Description,
	   rod.Emailsubject,
	   NULL AS NextRunDateTime,
       dbo.TZ_GetTime(rod.CompletedDateTime, DEFAULT, @userid) AS LastRunDateTime,
	   CASE ISNULL(rod.Status, 0) WHEN 0 THEN 'Queued' WHEN 1 THEN 'Executing' WHEN 2 THEN 'Successful' WHEN 3 THEN 'Failed' END AS STATUS,
	   rod.Emailto + ISNULL('; ' + rod.Emailcc, '') + ISNULL('; ' + rod.Emailbcc, '') AS Recipients,
	   0 AS Disabled,
	   rod.UserId AS CreatedBy,
	   u.Name AS CreatedByName,
	   CASE WHEN u.UserId = @userid THEN 0 ELSE 1 END AS IsReadOnly
FROM dbo.ReportOnDemand rod
INNER JOIN dbo.Report r ON r.ReportId = rod.ReportId
INNER JOIN dbo.[User] u ON u.UserID = rod.UserId
WHERE rod.Archived = 0
  AND u.CustomerID = @cid


GO
