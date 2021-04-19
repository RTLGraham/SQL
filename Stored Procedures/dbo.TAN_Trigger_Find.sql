SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the TAN_Trigger table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_Trigger_Find]
(

	@SearchUsingOR bit   = null ,

	@TriggerId uniqueidentifier   = null ,

	@TriggerTypeId int   = null ,

	@Name varchar (255)  = null ,

	@Description varchar (MAX)  = null ,

	@Disabled bit   = null ,

	@Archived bit   = null ,

	@LastOperation smalldatetime   = null ,

	@CustomerId uniqueidentifier   = null ,

	@CreatedBy uniqueidentifier   = null ,

	@Count bigint   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [TriggerId]
	, [TriggerTypeId]
	, [Name]
	, [Description]
	, [Disabled]
	, [Archived]
	, [LastOperation]
	, [CustomerId]
	, [CreatedBy]
	, [Count]
    FROM
	[dbo].[TAN_Trigger]
    WHERE 
	 ([TriggerId] = @TriggerId OR @TriggerId IS NULL)
	AND ([TriggerTypeId] = @TriggerTypeId OR @TriggerTypeId IS NULL)
	AND ([Name] = @Name OR @Name IS NULL)
	AND ([Description] = @Description OR @Description IS NULL)
	AND ([Disabled] = @Disabled OR @Disabled IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND ([LastOperation] = @LastOperation OR @LastOperation IS NULL)
	AND ([CustomerId] = @CustomerId OR @CustomerId IS NULL)
	AND ([CreatedBy] = @CreatedBy OR @CreatedBy IS NULL)
	AND ([Count] = @Count OR @Count IS NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [TriggerId]
	, [TriggerTypeId]
	, [Name]
	, [Description]
	, [Disabled]
	, [Archived]
	, [LastOperation]
	, [CustomerId]
	, [CreatedBy]
	, [Count]
    FROM
	[dbo].[TAN_Trigger]
    WHERE 
	 ([TriggerId] = @TriggerId AND @TriggerId is not null)
	OR ([TriggerTypeId] = @TriggerTypeId AND @TriggerTypeId is not null)
	OR ([Name] = @Name AND @Name is not null)
	OR ([Description] = @Description AND @Description is not null)
	OR ([Disabled] = @Disabled AND @Disabled is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	OR ([LastOperation] = @LastOperation AND @LastOperation is not null)
	OR ([CustomerId] = @CustomerId AND @CustomerId is not null)
	OR ([CreatedBy] = @CreatedBy AND @CreatedBy is not null)
	OR ([Count] = @Count AND @Count is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				


GO
