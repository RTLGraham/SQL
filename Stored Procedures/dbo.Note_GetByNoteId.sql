SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the Note table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Note_GetByNoteId]
(

	@NoteId uniqueidentifier   
)
AS


				SELECT
					[NoteId],
					[NoteEntityId],
					[NoteTypeId],
					[Note],
					[NoteDate],
					[LastModified],
					[Archived]
				FROM
					[dbo].[Note]
				WHERE
					[NoteId] = @NoteId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
