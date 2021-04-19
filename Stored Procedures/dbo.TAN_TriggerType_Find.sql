SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the TAN_TriggerType table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_TriggerType_Find]
(

	@SearchUsingOR bit   = null ,

	@TriggerTypeId int   = null ,

	@Name varchar (255)  = null ,

	@Description varchar (MAX)  = null ,

	@CreationCodeId smallint   = null ,

	@Archived bit   = null ,

	@LastOperation smalldatetime   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [TriggerTypeId]
	, [Name]
	, [Description]
	, [CreationCodeId]
	, [Archived]
	, [LastOperation]
    FROM
	[dbo].[TAN_TriggerType]
    WHERE 
	 ([TriggerTypeId] = @TriggerTypeId OR @TriggerTypeId IS NULL)
	AND ([Name] = @Name OR @Name IS NULL)
	AND ([Description] = @Description OR @Description IS NULL)
	AND ([CreationCodeId] = @CreationCodeId OR @CreationCodeId IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND ([LastOperation] = @LastOperation OR @LastOperation IS NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [TriggerTypeId]
	, [Name]
	, [Description]
	, [CreationCodeId]
	, [Archived]
	, [LastOperation]
    FROM
	[dbo].[TAN_TriggerType]
    WHERE 
	 ([TriggerTypeId] = @TriggerTypeId AND @TriggerTypeId is not null)
	OR ([Name] = @Name AND @Name is not null)
	OR ([Description] = @Description AND @Description is not null)
	OR ([CreationCodeId] = @CreationCodeId AND @CreationCodeId is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	OR ([LastOperation] = @LastOperation AND @LastOperation is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				


GO
