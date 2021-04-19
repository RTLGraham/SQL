SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[cu_User_ReportSchedule_Update]
(
	@reportScheduleId INT,
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
	@dwString VARCHAR(15),
	@dmString VARCHAR(30),
	@DateTime DATETIME,
	@reportRDLId INT
)
AS

DECLARE @newline CHAR(2),
		@parameter NVARCHAR(MAX)
		
SET @newline = CHAR(13) + CHAR(10)

UPDATE dbo.ReportSchedule
SET Description = @comment,
	UserId = @userId,
	ReportId = @reportId,
	ReportPeriodTypeId = @reportPeriod,
    DayList = dbo.TZ_DayListToUTC(@DateTime, DEFAULT, @userId, @dwString, 1), 
    DateList = dbo.TZ_DayListToUTC(@DateTime, DEFAULT, @userId, @dmString, 0),
	SchTime = dbo.TZ_ToUtc(@DateTime, DEFAULT, @userId),
	ExportFormat = @format,
	EmailSubject = @subject,
	RecipientsTo = @to,
	RecipientsCC = @cc,
	RecipientsBCC = @bcc,
	ReplyTo = @replyTo,
	ReportRDLId = @reportRDLId
WHERE ReportScheduleId = @reportScheduleId

DECLARE @params TABLE
(
	ReportParameterId INT,
	ParameterValue NVARCHAR(MAX)
)

DELETE
FROM dbo.ReportScheduleParameter
WHERE ReportScheduleId = @reportScheduleId

DECLARE TCursor CURSOR FAST_FORWARD READ_ONLY
FOR
SELECT VALUE FROM dbo.Split(@paramsString, @newline)

OPEN TCursor
FETCH NEXT FROM TCursor INTO @parameter

WHILE @@FETCH_STATUS = 0
BEGIN
	INSERT INTO dbo.ReportScheduleParameter (ReportScheduleId, ReportParameterId, Value)
	VALUES  ( @reportscheduleid, -- ReportScheduleId
	          LEFT(@parameter,CHARINDEX('|',@parameter)-1), -- ReportParameterId
	          RIGHT(@parameter,LEN(@parameter)-CHARINDEX('|', @parameter))  -- Value
	        )
	
	FETCH NEXT FROM TCursor INTO @parameter
END

CLOSE TCursor
DEALLOCATE TCursor	



GO
