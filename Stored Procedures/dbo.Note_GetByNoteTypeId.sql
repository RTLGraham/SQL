SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the Note table through a foreign key
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Note_GetByNoteTypeId]
(

	@NoteTypeId int   
)
AS


				SET ANSI_NULLS OFF
				
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
                            [NoteTypeId] = @NoteTypeId
                                AND
                            Archived = 0
				
				SELECT @@ROWCOUNT
				SET ANSI_NULLS ON
			


GO
