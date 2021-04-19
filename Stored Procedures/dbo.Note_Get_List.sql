SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the Note table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Note_Get_List]

AS


				
				SELECT
					[NoteId],
					[NoteEntityId],
					[NoteTypeId],
					[Note],
					[NoteDate],
					[LastModified],
					[Archived]
				FROM
					[dbo].[Note]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
