SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cu_SiteImportRequest_Get]
(
	@userId UNIQUEIDENTIFIER,
	@sdate DATETIME NULL,
	@edate DATETIME NULL
)
AS

--DECLARE	@groupName nvarchar(255),
--		@userId UNIQUEIDENTIFIER,
--		@groupTypeId INT

--SET @groupTypeId = 4
--SET @groupName = ''
--SET @userId = N'4C0A0D44-0685-4292-9087-F32E03F10134'

	
	SELECT r.SiteImportRequestID ,
           r.UserID ,
		   u.Name AS RequestorName,
           r.Name ,
           r.Description ,
           r.RequestDate ,
           r.ExecutionStartDate ,
           r.CompletionDate ,
           r.Status ,
           r.SiteCount ,
           r.RiakFileURL ,
           r.LastOperation ,
           r.Archived
	FROM dbo.SiteImportRequest r
		INNER JOIN dbo.[User] u ON u.UserID = r.UserID
		INNER JOIN dbo.[User] uMe ON uMe.CustomerID = u.CustomerID
	WHERE uMe.UserID = @userId
		AND r.Archived = 0
		AND ((@sdate IS NULL AND @edate IS NULL) OR (r.RequestDate BETWEEN @sdate AND @edate))
	ORDER BY r.RequestDate DESC
    

GO
