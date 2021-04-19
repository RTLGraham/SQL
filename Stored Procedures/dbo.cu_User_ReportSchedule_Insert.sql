SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[cu_User_ReportSchedule_Insert]
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
	@dwString VARCHAR(15),
	@dmString VARCHAR(30),
	@DateTime DATETIME,
	@ReportRDLId INT
)
AS

DECLARE @newline CHAR(2),
		@parameter NVARCHAR(MAX),
		@reportscheduleid INT
		
SET @newline = CHAR(13) + CHAR(10)

INSERT INTO dbo.ReportSchedule
        ( Description,
          UserId,
          ReportId,
          ReportPeriodTypeId,
          DayList,
          DateList,
          SchTime,
          ExportFormat,
          EmailSubject,
          RecipientsTo,
          RecipientsCC,
          RecipientsBCC,
          ExecutionCount,
          Archived,
          ReplyTo,
          ReportRDLId
        )
VALUES  ( @comment, -- Description
          @userId, -- UserId
          @reportId, -- ReportId
          @reportPeriod, -- ReportPeriodTypeId
          dbo.TZ_DayListToUTC(@DateTime, DEFAULT, @userId, @dwString, 1), -- DayList
          dbo.TZ_DayListToUTC(@DateTime, DEFAULT, @userId, @dmString, 0), -- DateList
          dbo.TZ_ToUtc(@DateTime, DEFAULT, @userId), -- SchTime
          @format, -- ExportFormat
          @subject, -- EmailSubject
          @to, -- RecipientsTo
          @cc, -- RecipientsCC
          @bcc, -- RecipientsBCC
          0, -- ExecutionCount
          0,  -- Archived
          @replyto,  -- ReplyTo
          @reportRDLId
        )
        
SET @reportscheduleid = SCOPE_IDENTITY()

IF ISNULL(@paramsString, '') != ''
BEGIN

	DECLARE @params TABLE
	(
		ReportParameterId INT,
		ParameterValue NVARCHAR(MAX)
	)

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

END


GO
