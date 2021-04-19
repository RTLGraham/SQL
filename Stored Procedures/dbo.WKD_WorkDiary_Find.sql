SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the WKD_WorkDiary table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WKD_WorkDiary_Find]
(

	@SearchUsingOR bit   = null ,

	@WorkDiaryId int   = null ,

	@DriverIntId int   = null ,

	@StartDate datetime   = null ,

	@Number varchar (20)  = null ,

	@EndDate datetime   = null ,

	@Archived bit   = null ,

	@LastOperation smalldatetime   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [WorkDiaryId]
	, [DriverIntId]
	, [StartDate]
	, [Number]
	, [EndDate]
	, [Archived]
	, [LastOperation]
    FROM
	[dbo].[WKD_WorkDiary]
    WHERE 
	 ([WorkDiaryId] = @WorkDiaryId OR @WorkDiaryId IS NULL)
	AND ([DriverIntId] = @DriverIntId OR @DriverIntId IS NULL)
	AND ([StartDate] = @StartDate OR @StartDate IS NULL)
	AND ([Number] = @Number OR @Number IS NULL)
	AND ([EndDate] = @EndDate OR @EndDate IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND ([LastOperation] = @LastOperation OR @LastOperation IS NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [WorkDiaryId]
	, [DriverIntId]
	, [StartDate]
	, [Number]
	, [EndDate]
	, [Archived]
	, [LastOperation]
    FROM
	[dbo].[WKD_WorkDiary]
    WHERE 
	 ([WorkDiaryId] = @WorkDiaryId AND @WorkDiaryId is not null)
	OR ([DriverIntId] = @DriverIntId AND @DriverIntId is not null)
	OR ([StartDate] = @StartDate AND @StartDate is not null)
	OR ([Number] = @Number AND @Number is not null)
	OR ([EndDate] = @EndDate AND @EndDate is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	OR ([LastOperation] = @LastOperation AND @LastOperation is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				


GO
