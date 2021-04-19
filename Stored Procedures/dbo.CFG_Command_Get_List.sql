SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the CFG_Command table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[CFG_Command_Get_List]

AS


				
				SELECT
					[CommandId],
					[CategoryId],
					[IVHTypeId],
					[CommandRoot],
					[Description],
					[Archived],
					[LastOperation]
				FROM
					[dbo].[CFG_Command]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
