SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[cu_User_ReportOnDemand_Insert]
(
	@reportId UNIQUEIDENTIFIER,
	@userId UNIQUEIDENTIFIER,
	@format VARCHAR(30),
	@comment NVARCHAR(200),
	@reportPeriod INT,
	@paramsString NVARCHAR(MAX),
	@to NVARCHAR(MAX),
	@cc NVARCHAR(MAX),
	@bcc NVARCHAR(MAX),
	@replyTo NVARCHAR(MAX),
	@subject NVARCHAR(255),
	@sDate DATETIME NULL,
	@eDate DATETIME NULL,
	@ReportRDLId INT
)
AS

INSERT INTO dbo.ReportOnDemand
        (CustomerId,
         CustomerReferenceId,
         RDL,
         Exportformat,
         Description,
         Emailto,
         Emailcc,
         Emailbcc,
         Emailsubject,
         Paramstring,
         Status,
         StartDate,
         EndDate,
         Archived,
         UserId,
         ReportId
        )
SELECT u.CustomerID, NULL, @ReportRDLId, @format, @comment, @to, @cc, @bcc, @subject, @paramsString, 0, 
		CASE WHEN @reportPeriod = 15 THEN @sDate ELSE dbo.TZ_GetTime(CONVERT(CHAR(19), dbo.GetScheduledStartDate(@reportPeriod, @userId), 120), DEFAULT, @userId) END,
		CASE WHEN @reportPeriod = 15 THEN @eDate ELSE dbo.TZ_GetTime(CONVERT(CHAR(19), dbo.GetScheduledEndDate(@reportPeriod, @userId), 120), DEFAULT, @userId) END,
		0, @userId, @reportId
FROM dbo.[User] u
WHERE u.UserID = @userId



GO
