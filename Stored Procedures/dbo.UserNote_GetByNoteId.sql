SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the UserNote table through a foreign key
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[UserNote_GetByNoteId]
(

	@NoteId uniqueidentifier   
)
AS


				SET ANSI_NULLS OFF
				
				SELECT
					[UserId],
					[NoteId],
					[Archived]
				FROM
					[dbo].[UserNote]
				WHERE
                            [NoteId] = @NoteId
                                AND
                            Archived = 0
				
				SELECT @@ROWCOUNT
				SET ANSI_NULLS ON
			


GO
