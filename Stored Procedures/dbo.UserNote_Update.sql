SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the UserNote table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[UserNote_Update]
(

	@UserId uniqueidentifier   ,

	@OriginalUserId uniqueidentifier   ,

	@NoteId uniqueidentifier   ,

	@OriginalNoteId uniqueidentifier   ,

	@Archived bit   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[UserNote]
				SET
					[UserId] = @UserId
					,[NoteId] = @NoteId
					,[Archived] = @Archived
				WHERE
[UserId] = @OriginalUserId 
AND [NoteId] = @OriginalNoteId 
				
			


GO
