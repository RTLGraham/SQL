SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the NoteType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[NoteType_Insert]
(

	@NoteTypeId int   ,

	@NoteTypeName nvarchar (255)  ,

	@NoteTypeDescription nvarchar (MAX)  ,

	@LastModified datetime   ,

	@Archived bit   
)
AS


				
				INSERT INTO [dbo].[NoteType]
					(
					[NoteTypeId]
					,[NoteTypeName]
					,[NoteTypeDescription]
					,[LastModified]
					,[Archived]
					)
				VALUES
					(
					@NoteTypeId
					,@NoteTypeName
					,@NoteTypeDescription
					,@LastModified
					,@Archived
					)
				
									
							
			


GO
