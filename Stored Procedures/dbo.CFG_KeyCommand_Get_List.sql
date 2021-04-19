SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the CFG_KeyCommand table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[CFG_KeyCommand_Get_List]

AS


				SELECT
					[KeyCommandId],
					[CommandId],
					[KeyId],
					[LastOperation],
					[IndexPos]
				FROM
					[dbo].[CFG_KeyCommand]

				SELECT @@ROWCOUNT
			


GO
