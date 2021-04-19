SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the NoteType table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[NoteType_Find]
(

	@SearchUsingOR bit   = null ,

	@NoteTypeId int   = null ,

	@NoteTypeName nvarchar (255)  = null ,

	@NoteTypeDescription nvarchar (MAX)  = null ,

	@LastModified datetime   = null ,

	@Archived bit   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [NoteTypeId]
	, [NoteTypeName]
	, [NoteTypeDescription]
	, [LastModified]
	, [Archived]
    FROM
	[dbo].[NoteType]
    WHERE 
	 ([NoteTypeId] = @NoteTypeId OR @NoteTypeId IS NULL)
	AND ([NoteTypeName] = @NoteTypeName OR @NoteTypeName IS NULL)
	AND ([NoteTypeDescription] = @NoteTypeDescription OR @NoteTypeDescription IS NULL)
	AND ([LastModified] = @LastModified OR @LastModified IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [NoteTypeId]
	, [NoteTypeName]
	, [NoteTypeDescription]
	, [LastModified]
	, [Archived]
    FROM
	[dbo].[NoteType]
    WHERE 
	 ([NoteTypeId] = @NoteTypeId AND @NoteTypeId is not null)
	OR ([NoteTypeName] = @NoteTypeName AND @NoteTypeName is not null)
	OR ([NoteTypeDescription] = @NoteTypeDescription AND @NoteTypeDescription is not null)
	OR ([LastModified] = @LastModified AND @LastModified is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				


GO
