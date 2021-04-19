SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the CFG_History table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[CFG_History_Find]
(

	@SearchUsingOR bit   = null ,

	@HistoryId int   = null ,

	@IvhIntId int   = null ,

	@KeyId int   = null ,

	@KeyValue nvarchar (MAX)  = null ,

	@StartDate datetime   = null ,

	@EndDate datetime   = null ,

	@Status bit   = null ,

	@LastOperation smalldatetime   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [HistoryId]
	, [IVHIntId]
	, [KeyId]
	, [KeyValue]
	, [StartDate]
	, [EndDate]
	, [Status]
	, [LastOperation]
    FROM
	[dbo].[CFG_History]
    WHERE 
	 ([HistoryId] = @HistoryId OR @HistoryId IS NULL)
	AND ([IVHIntId] = @IvhIntId OR @IvhIntId IS NULL)
	AND ([KeyId] = @KeyId OR @KeyId IS NULL)
	AND ([KeyValue] = @KeyValue OR @KeyValue IS NULL)
	AND ([StartDate] = @StartDate OR @StartDate IS NULL)
	AND ([EndDate] = @EndDate OR @EndDate IS NULL)
	AND ([Status] = @Status OR @Status IS NULL)
	AND ([LastOperation] = @LastOperation OR @LastOperation IS NULL)
						
  END
  ELSE
  BEGIN
    SELECT
	  [HistoryId]
	, [IVHIntId]
	, [KeyId]
	, [KeyValue]
	, [StartDate]
	, [EndDate]
	, [Status]
	, [LastOperation]
    FROM
	[dbo].[CFG_History]
    WHERE 
	 ([HistoryId] = @HistoryId AND @HistoryId is not null)
	OR ([IVHIntId] = @IvhIntId AND @IvhIntId is not null)
	OR ([KeyId] = @KeyId AND @KeyId is not null)
	OR ([KeyValue] = @KeyValue AND @KeyValue is not null)
	OR ([StartDate] = @StartDate AND @StartDate is not null)
	OR ([EndDate] = @EndDate AND @EndDate is not null)
	OR ([Status] = @Status AND @Status is not null)
	OR ([LastOperation] = @LastOperation AND @LastOperation is not null)
	SELECT @@ROWCOUNT			
  END
				


GO
