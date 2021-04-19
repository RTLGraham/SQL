SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the CFG_Command table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[CFG_Command_GetByCommandId]
(

	@CommandId int   
)
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
				WHERE
					[CommandId] = @CommandId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
