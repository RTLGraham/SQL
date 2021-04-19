SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the TAN_TriggerParam table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_TriggerParam_Find]
(

	@SearchUsingOR bit   = null ,

	@TriggerId uniqueidentifier   = null ,

	@TriggerParamTypeId int   = null ,

	@TriggerParamTypeValue varchar (255)  = null ,

	@Archived bit   = null ,

	@LastOperation smalldatetime   = null ,

	@Count bigint   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [TriggerId]
	, [TriggerParamTypeId]
	, [TriggerParamTypeValue]
	, [Archived]
	, [LastOperation]
	, [Count]
    FROM
	[dbo].[TAN_TriggerParam]
    WHERE 
	 ([TriggerId] = @TriggerId OR @TriggerId IS NULL)
	AND ([TriggerParamTypeId] = @TriggerParamTypeId OR @TriggerParamTypeId IS NULL)
	AND ([TriggerParamTypeValue] = @TriggerParamTypeValue OR @TriggerParamTypeValue IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND ([LastOperation] = @LastOperation OR @LastOperation IS NULL)
	AND ([Count] = @Count OR @Count IS NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [TriggerId]
	, [TriggerParamTypeId]
	, [TriggerParamTypeValue]
	, [Archived]
	, [LastOperation]
	, [Count]
    FROM
	[dbo].[TAN_TriggerParam]
    WHERE 
	 ([TriggerId] = @TriggerId AND @TriggerId is not null)
	OR ([TriggerParamTypeId] = @TriggerParamTypeId AND @TriggerParamTypeId is not null)
	OR ([TriggerParamTypeValue] = @TriggerParamTypeValue AND @TriggerParamTypeValue is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	OR ([LastOperation] = @LastOperation AND @LastOperation is not null)
	OR ([Count] = @Count AND @Count is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				


GO
