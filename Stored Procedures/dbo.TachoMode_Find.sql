SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the TachoMode table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TachoMode_Find]
(

	@SearchUsingOR bit   = null ,

	@TachoModeId int   = null ,

	@Name nvarchar (255)  = null ,

	@Description nvarchar (MAX)  = null ,

	@Archived bit   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [TachoModeID]
	, [Name]
	, [Description]
	, [Archived]
    FROM
	[dbo].[TachoMode]
    WHERE 
	 ([TachoModeID] = @TachoModeId OR @TachoModeId IS NULL)
	AND ([Name] = @Name OR @Name IS NULL)
	AND ([Description] = @Description OR @Description IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [TachoModeID]
	, [Name]
	, [Description]
	, [Archived]
    FROM
	[dbo].[TachoMode]
    WHERE 
	 ([TachoModeID] = @TachoModeId AND @TachoModeId is not null)
	OR ([Name] = @Name AND @Name is not null)
	OR ([Description] = @Description AND @Description is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				


GO
