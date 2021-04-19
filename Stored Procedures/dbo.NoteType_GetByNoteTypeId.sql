SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the NoteType table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[NoteType_GetByNoteTypeId]
(

	@NoteTypeId int   
)
AS


				SELECT
					[NoteTypeId],
					[NoteTypeName],
					[NoteTypeDescription],
					[LastModified],
					[Archived]
				FROM
					[dbo].[NoteType]
				WHERE
					[NoteTypeId] = @NoteTypeId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
