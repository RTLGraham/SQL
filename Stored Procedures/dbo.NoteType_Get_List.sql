SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the NoteType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[NoteType_Get_List]

AS


				
				SELECT
					[NoteTypeId],
					[NoteTypeName],
					[NoteTypeDescription],
					[LastModified],
					[Archived]
				FROM
					[dbo].[NoteType]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
