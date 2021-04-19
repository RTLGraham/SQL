SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the TAN_Trigger table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_Trigger_Delete]
(

	@TriggerId uniqueidentifier   
)
AS


                    UPDATE [dbo].[TAN_Trigger]
                    SET Archived = 1
				WHERE
					[TriggerId] = @TriggerId
					
			


GO
