SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the Note table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Note_Update]
(

	@NoteId uniqueidentifier   ,

	@NoteEntityId uniqueidentifier   ,

	@NoteTypeId int   ,

	@Note nvarchar (MAX)  ,

	@NoteDate datetime   ,

	@LastModified datetime   ,

	@Archived bit   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[Note]
				SET
					[NoteEntityId] = @NoteEntityId
					,[NoteTypeId] = @NoteTypeId
					,[Note] = @Note
					,[NoteDate] = @NoteDate
					,[LastModified] = @LastModified
					,[Archived] = @Archived
				WHERE
[NoteId] = @NoteId 
				
			


GO
