SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the CFG_Key table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[CFG_Key_Find]
(

	@SearchUsingOR bit   = null ,

	@KeyId int   = null ,

	@Name varchar (255)  = null ,

	@Description varchar (MAX)  = null ,

	@IndexPos smallint   = null ,

	@Archived bit   = null ,

	@LastOperation smalldatetime   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [KeyId]
	, [Name]
	, [Description]
	, [IndexPos]
	, [Archived]
	, [LastOperation]
    FROM
	[dbo].[CFG_Key]
    WHERE 
	 ([KeyId] = @KeyId OR @KeyId IS NULL)
	AND ([Name] = @Name OR @Name IS NULL)
	AND ([Description] = @Description OR @Description IS NULL)
	AND ([IndexPos] = @IndexPos OR @IndexPos IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND ([LastOperation] = @LastOperation OR @LastOperation IS NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [KeyId]
	, [Name]
	, [Description]
	, [IndexPos]
	, [Archived]
	, [LastOperation]
    FROM
	[dbo].[CFG_Key]
    WHERE 
	 ([KeyId] = @KeyId AND @KeyId is not null)
	OR ([Name] = @Name AND @Name is not null)
	OR ([Description] = @Description AND @Description is not null)
	OR ([IndexPos] = @IndexPos AND @IndexPos is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	OR ([LastOperation] = @LastOperation AND @LastOperation is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				

GO
