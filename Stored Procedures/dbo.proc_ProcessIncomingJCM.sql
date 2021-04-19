SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_ProcessIncomingJCM] 
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @action CHAR(1),
			@string VARCHAR(1024),
			@jobid INT,
			@jobstepid INT,
			@datetime DATETIME,
			@stepstatus TINYINT,
			@jobstatus INT

	-- Mark all relevant rows in EDJCM
	UPDATE EventDataJCM
	SET Archived = 1 
	
	DECLARE EDJCMCursor CURSOR FAST_FORWARD READ_ONLY
	FOR 
		SELECT SUBSTRING(edpc.EventDataString, 4, 1), SUBSTRING(edpc.EventDataString, 6, 1024)
		FROM dbo.EventDataJCM edpc
		WHERE edpc.Archived = 1
		ORDER BY edpc.EventDateTime ASC

	OPEN EDJCMCursor
	FETCH NEXT FROM EDJCMCursor INTO @action, @string
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		SET @jobid = NULL
		SET @jobstepid = NULL
		SET @datetime = NULL
		SET @stepstatus = NULL

		-- Parse for the job numer
		SELECT @jobid = j.Value
		FROM dbo.Split(@string, '|') j
		WHERE j.Id = 1

		IF @action IN ('5', '7') -- In Progress or Completed : parse for JobStepId, DateTime and StepStatus
		BEGIN
        
			SELECT @jobstepid = j.Value
			FROM dbo.Split(@string, '|') j
			WHERE j.Id = 2

			SELECT @datetime = j.Value
			FROM dbo.Split(@string, '|') j
			WHERE j.Id = 3

			SELECT @stepstatus = j.Value
			FROM dbo.Split(@string, '|') j
			WHERE j.Id = 4

		END ELSE --On Device or Suspended : just parse for DateTime
		BEGIN
        
			SELECT @datetime = j.Value
			FROM dbo.Split(@string, '|') j
			WHERE j.Id = 2

		END	
		
		-- Determine the job status from the action code
		SET @jobstatus = CASE @action WHEN 1 THEN 6 -- Deleted
									  WHEN 3 THEN 2 -- On Device
									  WHEN 4 THEN 7 -- Factory Reset
									  WHEN 5 THEN 3 -- In Progress
									  WHEN 6 THEN 4 -- Suspended
									  WHEN 7 THEN 5 -- Completed
						 END

		-- Update the Status on the Job 
		UPDATE dbo.JCM_Job
		SET StatusId = @jobstatus
		WHERE JobId = @jobid

		-- If the step number is provided mark the current step and update the step completion if appropriate
		IF @jobstepid IS NOT NULL	
			UPDATE dbo.JCM_Job
			SET CurrentStepNum = js.StepNum, CurrentStepCompletedDateTime = CASE WHEN @stepstatus = '2' THEN @datetime ELSE NULL END
			FROM dbo.JCM_Job j
			INNER JOIN dbo.JCM_JobStep js ON js.JobId = j.JobId AND js.JobStepId = @jobstepid

		-- Add JobStatusHistory where job status has changed
		INSERT INTO dbo.JCM_JobStatusHistory (JobId, StatusId, StatusDateTime, Archived, JobStepId, StepStatus)
		SELECT j.JobId, @jobstatus, @datetime, 0, @jobstepid, @stepstatus
		FROM (	SELECT TOP 1 jsh.JobId, jsh.JobStepId, jsh.StatusId, jsh.StepStatus -- get the most recent statusid
				FROM dbo.JCM_JobStatusHistory jsh
				WHERE jsh.JobId = 129
				ORDER BY jsh.StatusDateTime DESC	
			 ) j
		WHERE j.JobId = @jobid AND (j.StatusId != @jobstatus OR j.JobStepId != @jobstepid OR j.StepStatus != @stepstatus) -- insert if the statusid or stepid is different

		-- Get the next row from the cursor	    
		FETCH NEXT FROM EDJCMCursor INTO @action, @string
	END
	CLOSE EDJCMCursor
	DEALLOCATE EDJCMCursor	

	-- Clean up processed rows
	DELETE FROM dbo.EventDataJCM
	WHERE Archived = 1 
	
END




GO
