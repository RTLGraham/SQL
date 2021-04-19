SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the UserNote table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[UserNote_GetByUserIdNoteId]
(

	@UserId uniqueidentifier   ,

	@NoteId uniqueidentifier   
)
AS


				SELECT
					[UserId],
					[NoteId],
					[Archived]
				FROM
					[dbo].[UserNote]
				WHERE
					[UserId] = @UserId
					AND [NoteId] = @NoteId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
