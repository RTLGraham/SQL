SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the CFG_Category table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[CFG_Category_Find]
(

	@SearchUsingOR bit   = null ,

	@CategoryId int   = null ,

	@Name varchar (255)  = null ,

	@Description varchar (MAX)  = null ,

	@Archived bit   = null ,

	@LastOperation smalldatetime   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [CategoryId]
	, [Name]
	, [Description]
	, [Archived]
	, [LastOperation]
    FROM
	[dbo].[CFG_Category]
    WHERE 
	 ([CategoryId] = @CategoryId OR @CategoryId IS NULL)
	AND ([Name] = @Name OR @Name IS NULL)
	AND ([Description] = @Description OR @Description IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND ([LastOperation] = @LastOperation OR @LastOperation IS NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [CategoryId]
	, [Name]
	, [Description]
	, [Archived]
	, [LastOperation]
    FROM
	[dbo].[CFG_Category]
    WHERE 
	 ([CategoryId] = @CategoryId AND @CategoryId is not null)
	OR ([Name] = @Name AND @Name is not null)
	OR ([Description] = @Description AND @Description is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	OR ([LastOperation] = @LastOperation AND @LastOperation is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				


GO
