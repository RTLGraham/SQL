SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the NoteType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[NoteType_Delete]
(

	@NoteTypeId int   
)
AS


                    UPDATE [dbo].[NoteType]
                    SET Archived = 1
				WHERE
					[NoteTypeId] = @NoteTypeId
					
			


GO
