SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the TAN_TriggerSchedule table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_TriggerSchedule_Find]
(

	@SearchUsingOR bit   = null ,

	@TriggerId uniqueidentifier   = null ,

	@DayNum smallint   = null ,

	@Archived bit   = null ,

	@LastOperation smalldatetime   = null ,

	@Count bigint   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [TriggerId]
	, [DayNum]
	, [Archived]
	, [LastOperation]
	, [Count]
    FROM
	[dbo].[TAN_TriggerSchedule]
    WHERE 
	 ([TriggerId] = @TriggerId OR @TriggerId IS NULL)
	AND ([DayNum] = @DayNum OR @DayNum IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND ([LastOperation] = @LastOperation OR @LastOperation IS NULL)
	AND ([Count] = @Count OR @Count IS NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [TriggerId]
	, [DayNum]
	, [Archived]
	, [LastOperation]
	, [Count]
    FROM
	[dbo].[TAN_TriggerSchedule]
    WHERE 
	 ([TriggerId] = @TriggerId AND @TriggerId is not null)
	OR ([DayNum] = @DayNum AND @DayNum is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	OR ([LastOperation] = @LastOperation AND @LastOperation is not null)
	OR ([Count] = @Count AND @Count is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				


GO
