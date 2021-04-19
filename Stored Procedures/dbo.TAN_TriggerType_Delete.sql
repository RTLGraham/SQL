SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the TAN_TriggerType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_TriggerType_Delete]
(

	@TriggerTypeId int   
)
AS


                    UPDATE [dbo].[TAN_TriggerType]
                    SET Archived = 1
				WHERE
					[TriggerTypeId] = @TriggerTypeId
					
			


GO
