SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[proc_ProcessKronosImport]
AS

BEGIN

	DECLARE @DriverIntId INT,
			@RecordDate SMALLDATETIME,
			@FirstIn DATETIME,
			@FirstOut DATETIME,
			@SecondIn DATETIME,
			@SecondOut DATETIME

	-- Set Archived flag to 1 for rows about to be processed
	UPDATE dbo.KronosImportRecord
	SET Archived = 1
	WHERE Archived = 0
	 
	-- Use a cursor to process each KronosImportRecord table entry in turn
	DECLARE KCursor CURSOR FAST_FORWARD READ_ONLY
	FOR
	SELECT	d.DriverIntId, CAST(FLOOR(CAST(k.FirstOut AS FLOAT)) AS DATETIME),--k.RecordDate, 
			dbo.TZ_ToUtc(FirstIn, 'EUR Central Time', NULL),
			dbo.TZ_ToUtc(FirstOut, 'EUR Central Time', NULL),
			dbo.TZ_ToUtc(SecondIn, 'EUR Central Time', NULL),
			dbo.TZ_ToUtc(SecondOut, 'EUR Central Time', NULL)
	FROM dbo.KronosImportRecord k
	INNER JOIN dbo.Driver d ON k.DriverPersonalNr = d.EmpNumber
	WHERE k.Archived = 1
	ORDER BY k.KronosImportRecordId

	OPEN KCursor
	FETCH NEXT FROM KCursor INTO @DriverIntId, @RecordDate, @FirstIn, @FirstOut, @SecondIn, @SecondOut

	WHILE @@FETCH_STATUS = 0 
	BEGIN

		-- Merge data into Kronos table
		MERGE dbo.Kronos AS ktarget
		USING (SELECT @DriverIntId, @RecordDate, @FirstIn, @FirstOut, @SecondIn, @SecondOut) AS ksource (DriverIntId, RecordDate, FirstIn, FirstOut, SecondIn, SecondOut)
		ON (ktarget.DriverIntId = ksource.DriverIntId AND ktarget.KronosDate = ksource.RecordDate)
		WHEN MATCHED THEN
			UPDATE SET FirstIn = ksource.FirstIn, FirstOut = ksource.FirstOut, SecondIn = ksource.SecondIn, SecondOut = ksource.SecondOut, LastModified = GETDATE()
		WHEN NOT MATCHED THEN
			INSERT (DriverIntId, KronosDate, FirstIn, FirstOut, SecondIn, SecondOut)
			VALUES (ksource.DriverIntId, ksource.RecordDate, ksource.FirstIn, ksource.FirstOut, ksource.SecondIn, ksource.SecondOut);
			
		FETCH NEXT FROM KCursor INTO @DriverIntId, @RecordDate, @FirstIn, @FirstOut, @SecondIn, @SecondOut

	END

	CLOSE KCursor
	DEALLOCATE KCursor	

	-- Mark the Records as Processed
	DELETE dbo.KronosImportRecord
	WHERE Archived = 1

END


GO
