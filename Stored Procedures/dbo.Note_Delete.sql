SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the Note table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Note_Delete]
(

	@NoteId uniqueidentifier   
)
AS


                    UPDATE [dbo].[Note]
                    SET Archived = 1
				WHERE
					[NoteId] = @NoteId
					
			


GO
