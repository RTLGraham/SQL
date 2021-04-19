SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the UserNote table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[UserNote_Delete]
(

	@UserId uniqueidentifier   ,

	@NoteId uniqueidentifier   
)
AS


                    UPDATE [dbo].[UserNote]
                    SET Archived = 1
				WHERE
					[UserId] = @UserId
					AND [NoteId] = @NoteId
					
			


GO
