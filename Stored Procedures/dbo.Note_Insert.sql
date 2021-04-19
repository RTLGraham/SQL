SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the Note table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Note_Insert]
(

	@NoteId uniqueidentifier    OUTPUT,

	@NoteEntityId uniqueidentifier   ,

	@NoteTypeId int   ,

	@Note nvarchar (MAX)  ,

	@NoteDate datetime   ,

	@LastModified datetime   ,

	@Archived bit   
)
AS


				
				Declare @IdentityRowGuids table (NoteId uniqueidentifier	)
				INSERT INTO [dbo].[Note]
					(
					[NoteEntityId]
					,[NoteTypeId]
					,[Note]
					,[NoteDate]
					,[LastModified]
					,[Archived]
					)
						OUTPUT INSERTED.NoteId INTO @IdentityRowGuids
					
				VALUES
					(
					@NoteEntityId
					,@NoteTypeId
					,@Note
					,@NoteDate
					,@LastModified
					,@Archived
					)
				
				SELECT @NoteId=NoteId	 from @IdentityRowGuids
									
							
			


GO
