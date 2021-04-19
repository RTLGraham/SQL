SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the CFG_KeyCommand table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[CFG_KeyCommand_GetByKeyCommandId]
(

	@KeyCommandId int   
)
AS


				SELECT
					[KeyCommandId],
					[CommandId],
					[KeyId],
					[LastOperation],
					[IndexPos]
				FROM
					[dbo].[CFG_KeyCommand]
				WHERE
					[KeyCommandId] = @KeyCommandId
				SELECT @@ROWCOUNT
					
			


GO
