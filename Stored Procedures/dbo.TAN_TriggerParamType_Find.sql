SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the TAN_TriggerParamType table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_TriggerParamType_Find]
(

	@SearchUsingOR bit   = null ,

	@TriggerParamTypeId int   = null ,

	@Name varchar (255)  = null ,

	@Description varchar (MAX)  = null ,

	@Archived bit   = null ,

	@LastOperation smalldatetime   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [TriggerParamTypeId]
	, [Name]
	, [Description]
	, [Archived]
	, [LastOperation]
    FROM
	[dbo].[TAN_TriggerParamType]
    WHERE 
	 ([TriggerParamTypeId] = @TriggerParamTypeId OR @TriggerParamTypeId IS NULL)
	AND ([Name] = @Name OR @Name IS NULL)
	AND ([Description] = @Description OR @Description IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND ([LastOperation] = @LastOperation OR @LastOperation IS NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [TriggerParamTypeId]
	, [Name]
	, [Description]
	, [Archived]
	, [LastOperation]
    FROM
	[dbo].[TAN_TriggerParamType]
    WHERE 
	 ([TriggerParamTypeId] = @TriggerParamTypeId AND @TriggerParamTypeId is not null)
	OR ([Name] = @Name AND @Name is not null)
	OR ([Description] = @Description AND @Description is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	OR ([LastOperation] = @LastOperation AND @LastOperation is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				


GO
