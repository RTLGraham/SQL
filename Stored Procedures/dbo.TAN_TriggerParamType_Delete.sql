SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the TAN_TriggerParamType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_TriggerParamType_Delete]
(

	@TriggerParamTypeId int   
)
AS


                    UPDATE [dbo].[TAN_TriggerParamType]
                    SET Archived = 1
				WHERE
					[TriggerParamTypeId] = @TriggerParamTypeId
					
			


GO
