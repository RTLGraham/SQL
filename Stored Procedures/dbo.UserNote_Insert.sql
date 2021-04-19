SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the UserNote table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[UserNote_Insert]
(

	@UserId uniqueidentifier   ,

	@NoteId uniqueidentifier   ,

	@Archived bit   
)
AS


				
				INSERT INTO [dbo].[UserNote]
					(
					[UserId]
					,[NoteId]
					,[Archived]
					)
				VALUES
					(
					@UserId
					,@NoteId
					,@Archived
					)
				
									
							
			


GO
