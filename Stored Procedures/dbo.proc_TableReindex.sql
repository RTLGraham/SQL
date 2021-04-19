SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[proc_TableReindex]
AS

-- This job is used to re-index tables in the database
-- To re-index just specific tables, list them in the variable @include. If this variable is NOT null then only tables listed will be re-indexed
-- To re-index all except specific tables, set the @include variable to NULL and list the tables to be excluded in the @exclude parameter

DECLARE @tablename VARCHAR(255),
		@exclude VARCHAR(MAX),
		@include VARCHAR(MAX)

SET @exclude = 'Event,Accum,TripsAndStops'
SET @include = NULL

TRUNCATE TABLE dbo.ReindexLog

DECLARE TableCursor CURSOR FOR
SELECT table_name FROM information_schema.tables
WHERE table_type = 'base table'
  AND table_schema = 'dbo'
  AND (table_name NOT IN (SELECT VALUE FROM dbo.Split(@exclude, ',')) OR @exclude IS NULL)
  AND (table_name IN (SELECT VALUE FROM dbo.Split(@include, ',')) OR @include IS NULL)

OPEN TableCursor

FETCH NEXT FROM TableCursor INTO @tablename
WHILE @@FETCH_STATUS = 0
BEGIN

	INSERT INTO dbo.ReindexLog (TableName, StartTime)
	VALUES  ( @tablename, GETDATE() ) 

	EXECUTE ('
	alter index ALL on [dbo].['	+ @tablename +
	'] rebuild with (fillfactor = 80, 
		sort_in_tempdb = on, -- tempdb on diff disc so may improve any disc usage
		maxdop = 0)
	');
	
	UPDATE dbo.ReindexLog
	SET EndTime = GETDATE()
	WHERE TableName = @tablename

	FETCH NEXT FROM TableCursor INTO @tablename
END

CLOSE TableCursor

DEALLOCATE TableCursor




GO
