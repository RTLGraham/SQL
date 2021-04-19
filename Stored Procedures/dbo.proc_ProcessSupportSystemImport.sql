SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROC [dbo].[proc_ProcessSupportSystemImport]
AS

SELECT MyVar = 5 INTO #ProcessSupportSystemImport

IF @@ERROR <> 0
BEGIN
	-- do nothing!
	SELECT 0
END
ELSE
BEGIN

	DECLARE @RecordDate SMALLDATETIME

	---- Set Archived flag to 1 for rows about to be processed
	--UPDATE dbo.SupportSystemImportRecord
	--SET Archived = 1
	--WHERE Archived = 0
	 
	---- Use a cursor to process each SupportSystemImportRecord table entry in turn
	--DECLARE KCursor CURSOR FAST_FORWARD READ_ONLY
	--FOR
	--SELECT	d.DriverIntId, k.RecordDate, 
	--		dbo.TZ_ToUtc(FirstIn, 'EUR Central Time', NULL),
	--		dbo.TZ_ToUtc(FirstOut, 'EUR Central Time', NULL),
	--		dbo.TZ_ToUtc(SecondIn, 'EUR Central Time', NULL),
	--		dbo.TZ_ToUtc(SecondOut, 'EUR Central Time', NULL)
	--FROM dbo.SupportSystemImportRecord k
	--INNER JOIN dbo.Driver d ON k.DriverPersonalNr = d.LicenceNumber
	--WHERE k.Archived = 1
	--ORDER BY k.SupportSystemImportRecordId

	--OPEN KCursor
	--FETCH NEXT FROM KCursor INTO @DriverIntId, @RecordDate, @FirstIn, @FirstOut, @SecondIn, @SecondOut

	--WHILE @@FETCH_STATUS = 0 
	--BEGIN

	--	-- Merge data into SupportSystem table
	--	MERGE dbo.SupportSystem AS ktarget
	--	USING (SELECT @DriverIntId, @RecordDate, @FirstIn, @FirstOut, @SecondIn, @SecondOut) AS ksource (DriverIntId, RecordDate, FirstIn, FirstOut, SecondIn, SecondOut)
	--	ON (ktarget.DriverIntId = ksource.DriverIntId AND ktarget.SupportSystemDate = ksource.RecordDate)
	--	WHEN MATCHED THEN
	--		UPDATE SET FirstIn = ksource.FirstIn, FirstOut = ksource.FirstOut, SecondIn = ksource.SecondIn, SecondOut = ksource.SecondOut, LastModified = GETDATE()
	--	WHEN NOT MATCHED THEN
	--		INSERT (DriverIntId, SupportSystemDate, FirstIn, FirstOut, SecondIn, SecondOut)
	--		VALUES (ksource.DriverIntId, ksource.RecordDate, ksource.FirstIn, ksource.FirstOut, ksource.SecondIn, ksource.SecondOut);
			
	--	FETCH NEXT FROM KCursor INTO @DriverIntId, @RecordDate, @FirstIn, @FirstOut, @SecondIn, @SecondOut

	--END

	--CLOSE KCursor
	--DEALLOCATE KCursor	

	---- Mark the Records as Processed
	--DELETE dbo.SupportSystemImportRecord
	--WHERE Archived = 1

	-- Delete temporary table to indicate job has completed
	DROP TABLE #ProcessSupportSystemImport

END

GO
