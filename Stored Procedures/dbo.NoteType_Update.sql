SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the NoteType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[NoteType_Update]
(

	@NoteTypeId int   ,

	@OriginalNoteTypeId int   ,

	@NoteTypeName nvarchar (255)  ,

	@NoteTypeDescription nvarchar (MAX)  ,

	@LastModified datetime   ,

	@Archived bit   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[NoteType]
				SET
					[NoteTypeId] = @NoteTypeId
					,[NoteTypeName] = @NoteTypeName
					,[NoteTypeDescription] = @NoteTypeDescription
					,[LastModified] = @LastModified
					,[Archived] = @Archived
				WHERE
[NoteTypeId] = @OriginalNoteTypeId 
				
			


GO
