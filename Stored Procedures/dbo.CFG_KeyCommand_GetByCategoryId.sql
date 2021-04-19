SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the CFG_KeyCommand table through a foreign key
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[CFG_KeyCommand_GetByCategoryId]
(

	@CategoryId int   
)
AS
				SET ANSI_NULLS OFF
				
				SELECT
					[KeyCommandId],
					[CommandId],
					[KeyId],
					[LastOperation],
					[IndexPos]
				FROM
					[dbo].[CFG_KeyCommand]
				
				SELECT @@ROWCOUNT
				SET ANSI_NULLS ON
			


GO
