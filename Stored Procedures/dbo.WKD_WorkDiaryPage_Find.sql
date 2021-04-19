SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the WKD_WorkDiaryPage table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WKD_WorkDiaryPage_Find]
(

	@SearchUsingOR bit   = null ,

	@WorkDiaryPageId int   = null ,

	@WorkDiaryId int   = null ,

	@Date smalldatetime   = null ,

	@DriverSignature image   = null ,

	@SignDate datetime   = null ,

	@TwoUpWorkDiaryPageId int   = null ,

	@Archived bit   = null ,

	@LastOperation smalldatetime   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [WorkDiaryPageId]
	, [WorkDiaryId]
	, [Date]
	, [DriverSignature]
	, [SignDate]
	, [TwoUpWorkDiaryPageId]
	, [Archived]
	, [LastOperation]
    FROM
	[dbo].[WKD_WorkDiaryPage]
    WHERE 
	 ([WorkDiaryPageId] = @WorkDiaryPageId OR @WorkDiaryPageId IS NULL)
	AND ([WorkDiaryId] = @WorkDiaryId OR @WorkDiaryId IS NULL)
	AND ([Date] = @Date OR @Date IS NULL)
	AND ([SignDate] = @SignDate OR @SignDate IS NULL)
	AND ([TwoUpWorkDiaryPageId] = @TwoUpWorkDiaryPageId OR @TwoUpWorkDiaryPageId IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND ([LastOperation] = @LastOperation OR @LastOperation IS NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [WorkDiaryPageId]
	, [WorkDiaryId]
	, [Date]
	, [DriverSignature]
	, [SignDate]
	, [TwoUpWorkDiaryPageId]
	, [Archived]
	, [LastOperation]
    FROM
	[dbo].[WKD_WorkDiaryPage]
    WHERE 
	 ([WorkDiaryPageId] = @WorkDiaryPageId AND @WorkDiaryPageId is not null)
	OR ([WorkDiaryId] = @WorkDiaryId AND @WorkDiaryId is not null)
	OR ([Date] = @Date AND @Date is not null)
	OR ([SignDate] = @SignDate AND @SignDate is not null)
	OR ([TwoUpWorkDiaryPageId] = @TwoUpWorkDiaryPageId AND @TwoUpWorkDiaryPageId is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	OR ([LastOperation] = @LastOperation AND @LastOperation is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				


GO
