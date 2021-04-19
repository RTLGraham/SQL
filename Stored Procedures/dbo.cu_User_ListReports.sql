SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[cu_User_ListReports]
    (
      @userId UNIQUEIDENTIFIER
    )
AS 

SELECT	r.ReportId,
		r.Name,
		rdl.RDL,
		r.WidgetTypeId
FROM dbo.Report r
INNER JOIN dbo.ReportRDL rdl ON r.ReportId = rdl.ReportId
INNER JOIN dbo.WidgetType wt ON r.WidgetTypeId = wt.WidgetTypeID
INNER JOIN dbo.UserPreference up ON wt.NameId = up.NameID
WHERE up.UserID = @userid
  AND up.Archived = 0
  AND rdl.DisplaySeq = 0 -- default RDL

GO
