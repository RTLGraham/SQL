SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the CFG_KeyCommand table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[CFG_KeyCommand_Delete]
(

	@KeyCommandId int   
)
AS


				    DELETE FROM [dbo].[CFG_KeyCommand] WITH (ROWLOCK) 
				WHERE
					[KeyCommandId] = @KeyCommandId
					
			


GO
