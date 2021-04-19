SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_DailyArchive]
AS
BEGIN

	-- This job should be scheduled to run after midnight every day
	-- It will archive all data older than XX months from the end of the previous day
	-- If the job is scheduled to run daily it will archive one days worth of data at a time, but if it does not run for any reason it will delete a longer period in order to catch up
	-- The InitialDateTime in the ArchiveHistory table will be set correctly if the job runs daily but may be incorrect following a catch up period

	DECLARE @now DATETIME,
			@archivemonths INT,
			@archivedatetime DATETIME,
			@archivehistoryid INT,
			@backuplocation VARCHAR(200),
			@backupfilepath VARCHAR(MAX)

	SET @now = GETUTCDATE()
	SET @archivemonths = 25
	SET @backuplocation = 'G:\Archive\'
	SET @archivedatetime = DATEADD(SECOND, -1, CAST(FLOOR(CAST(DATEADD(MONTH, -1 * @archivemonths, @now) AS FLOAT)) AS DATETIME))

	--SET @archivedatetime = DATEADD(DAY, -7, @archivedatetime)

	-- Determine if we have an open history record
	SELECT @archivehistoryid = ArchiveHistoryId
	FROM dbo.ArchiveHistory
	WHERE BackupDateTime IS NULL	

	IF @archivehistoryid IS NULL 
	BEGIN -- no open history record - so create one
		INSERT INTO dbo.ArchiveHistory (InitialDateTime, FinalDateTime, LatestArchiveStartDateTime, LatestArchiveEndDateTime, BackupFileName, BackupDateTime)
		VALUES  (CAST(FLOOR(CAST(@archivedatetime AS FLOAT)) AS DATETIME), @archivedatetime, GETDATE(), NULL, NULL, NULL)
		SET @archivehistoryid = SCOPE_IDENTITY()
	END	ELSE
    BEGIN -- we have an open history record - so update it
		UPDATE dbo.ArchiveHistory
		SET FinalDateTime = @archivedatetime, LatestArchiveStartDateTime = GETDATE(), LatestArchiveEndDateTime = NULL
		WHERE ArchiveHistoryId = @archivehistoryid
	END	

	-- Now perform the delete operations
	DELETE
	FROM dbo.Event
	OUTPUT DELETED.*
	INTO Archive_NG.dbo.Event	
	WHERE EventDateTime <= @archivedatetime

	DELETE
	FROM dbo.EventData
	OUTPUT DELETED.*
	INTO Archive_NG.dbo.EventData	
	WHERE LastOperation <= @archivedatetime

	DELETE
	FROM dbo.EventSpeeding
	OUTPUT DELETED.*
	INTO Archive_NG.dbo.EventSpeeding	
	WHERE EventDateTime <= @archivedatetime

	-- Mark the completion time of this archive run
	UPDATE dbo.ArchiveHistory
	SET LatestArchiveEndDateTime = GETDATE()
	WHERE ArchiveHistoryId = @archivehistoryid

	-- If the current date is the first of the month we have just completed the final backup of the previous month
	-- Therefore, we now proceed to backup the dataset and prepare for the next archive

	IF DATEPART(DAY, @now) = 1
	BEGIN
		-- Determine the backup filename
		SET @backupfilepath = @backuplocation + 'Archive-' + DB_NAME() + '-' + CONVERT(VARCHAR(7), @archivedatetime, 120) + '.bak' 

		-- Now perform the actual database backup
		BACKUP DATABASE Archive_NG
		 TO DISK = @backupfilepath
		 WITH FORMAT;

		-- Mark the history row as backed up with the filepath details
		UPDATE dbo.ArchiveHistory
		SET BackupFileName = @backupfilepath, BackupDateTime = GETDATE()
		WHERE ArchiveHistoryId = @archivehistoryid

		-- Now truncate the tables in the Archive Database in preparation for the next month
		TRUNCATE TABLE Archive_NG.dbo.Event
		TRUNCATE TABLE Archive_NG.dbo.EventData
		TRUNCATE TABLE Archive_NG.dbo.EventSpeeding
	END	

END 




GO
