SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the Note table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Note_Find]
(

	@SearchUsingOR bit   = null ,

	@NoteId uniqueidentifier   = null ,

	@NoteEntityId uniqueidentifier   = null ,

	@NoteTypeId int   = null ,

	@Note nvarchar (MAX)  = null ,

	@NoteDate datetime   = null ,

	@LastModified datetime   = null ,

	@Archived bit   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [NoteId]
	, [NoteEntityId]
	, [NoteTypeId]
	, [Note]
	, [NoteDate]
	, [LastModified]
	, [Archived]
    FROM
	[dbo].[Note]
    WHERE 
	 ([NoteId] = @NoteId OR @NoteId IS NULL)
	AND ([NoteEntityId] = @NoteEntityId OR @NoteEntityId IS NULL)
	AND ([NoteTypeId] = @NoteTypeId OR @NoteTypeId IS NULL)
	AND ([Note] = @Note OR @Note IS NULL)
	AND ([NoteDate] = @NoteDate OR @NoteDate IS NULL)
	AND ([LastModified] = @LastModified OR @LastModified IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [NoteId]
	, [NoteEntityId]
	, [NoteTypeId]
	, [Note]
	, [NoteDate]
	, [LastModified]
	, [Archived]
    FROM
	[dbo].[Note]
    WHERE 
	 ([NoteId] = @NoteId AND @NoteId is not null)
	OR ([NoteEntityId] = @NoteEntityId AND @NoteEntityId is not null)
	OR ([NoteTypeId] = @NoteTypeId AND @NoteTypeId is not null)
	OR ([Note] = @Note AND @Note is not null)
	OR ([NoteDate] = @NoteDate AND @NoteDate is not null)
	OR ([LastModified] = @LastModified AND @LastModified is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				


GO
