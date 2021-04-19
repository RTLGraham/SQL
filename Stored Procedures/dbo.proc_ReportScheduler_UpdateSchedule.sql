SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportScheduler_UpdateSchedule]
(
	@isReportOnDemand BIT,
    @reportscheduleid INT,
	@rsaid INT,
	@success BIT,
	@recipients NVARCHAR(MAX),	-- @emailto + CASE WHEN @emailcc = '' THEN '' ELSE '; ' + @emailcc END + CASE WHEN @emailbcc = '' THEN '' ELSE '; ' + @emailbcc END
    @RDL NVARCHAR(MAX),
	@startDate DATETIME,		--UTC
    @endDate DATETIME,			--UTC
	@exceptionName NVARCHAR(MAX), 
	@exceptionDetail NVARCHAR(MAX)
)
AS
	SET NOCOUNT ON


	IF @isReportOnDemand = 0
	BEGIN
		--Scheduled reports
		IF ISNULL(@success, 0) = 1 -- Report has run successfully
		BEGIN
			-- Mark Activity as Completed
			UPDATE dbo.ReportScheduleActivity
			SET Status = 2, 
				StartDateTime = @startDate,
				CompletedDateTime = @endDate,
				Recipients = @recipients
			WHERE ReportScheduleActivityId = @rsaid			
		END 
		ELSE -- Report execution has failed	
		BEGIN
			-- Mark Activity as Failed
			UPDATE dbo.ReportScheduleActivity
			SET Status = 3, 
				StartDateTime = @startDate,
				CompletedDateTime = @endDate
			WHERE ReportScheduleActivityId = @rsaid	

			INSERT INTO dbo.Log
					( EventID,
						Priority,
						Severity,
						Title,
						Timestamp,
						MachineName,
						AppDomainName,
						ProcessID,
						ProcessName,
						ThreadName,
						Win32ThreadId,
						Message,
						FormattedMessage
					)
			VALUES(	0, 
					1, 
					'Error', 
					'Report Scheduler Failure', 
					GETUTCDATE(), 
					'APOLLO', 
					'NG_RTL2Application', 
					@rsaid, 
					@RDL, 
					NULL, 
					NULL, 
					@exceptionName, 
					@exceptionDetail )
		END

		UPDATE dbo.ReportSchedule
		SET ExecutionCount = ExecutionCount + 1
		WHERE ReportScheduleId = @reportscheduleid
	END
	ELSE BEGIN
		--On Demand

		
			UPDATE dbo.ReportOnDemand
			SET Status = CASE WHEN ISNULL(@success, 0) = 1 THEN 2 ELSE 3 END, 
				StartDateTime = @startDate,
				CompletedDateTime = @endDate
			WHERE ReportOnDemandId = @reportscheduleid

		IF ISNULL(@success, 0) != 1 -- Report failed
		BEGIN

			INSERT INTO dbo.Log
					( EventID,
						Priority,
						Severity,
						Title,
						Timestamp,
						MachineName,
						AppDomainName,
						ProcessID,
						ProcessName,
						ThreadName,
						Win32ThreadId,
						Message,
						FormattedMessage
					)
			VALUES(	0, 
					1, 
					'Error', 
					'Report Scheduler On Demand Failure', 
					GETUTCDATE(), 
					'APOLLO', 
					'NG_RTL2Application', 
					@rsaid, 
					@RDL, 
					NULL, 
					NULL, 
					@exceptionName, 
					@exceptionDetail )
		END
	END

GO
