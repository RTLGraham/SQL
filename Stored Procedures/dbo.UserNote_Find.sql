SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the UserNote table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[UserNote_Find]
(

	@SearchUsingOR bit   = null ,

	@UserId uniqueidentifier   = null ,

	@NoteId uniqueidentifier   = null ,

	@Archived bit   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [UserId]
	, [NoteId]
	, [Archived]
    FROM
	[dbo].[UserNote]
    WHERE 
	 ([UserId] = @UserId OR @UserId IS NULL)
	AND ([NoteId] = @NoteId OR @NoteId IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [UserId]
	, [NoteId]
	, [Archived]
    FROM
	[dbo].[UserNote]
    WHERE 
	 ([UserId] = @UserId AND @UserId is not null)
	OR ([NoteId] = @NoteId AND @NoteId is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				


GO
