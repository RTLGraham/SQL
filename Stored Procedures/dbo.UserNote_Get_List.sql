SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the UserNote table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[UserNote_Get_List]

AS


				
				SELECT
					[UserId],
					[NoteId],
					[Archived]
				FROM
					[dbo].[UserNote]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
