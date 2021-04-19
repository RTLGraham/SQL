SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the CFG_Command table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[CFG_Command_Delete]
(

	@CommandId int   
)
AS


                    UPDATE [dbo].[CFG_Command]
                    SET Archived = 1
				WHERE
					[CommandId] = @CommandId
					
			


GO
