SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the CFG_Key table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[CFG_Key_Delete]
(

	@KeyId int   
)
AS


                    UPDATE [dbo].[CFG_Key]
                    SET Archived = 1
				WHERE
					[KeyId] = @KeyId
					
			


GO
