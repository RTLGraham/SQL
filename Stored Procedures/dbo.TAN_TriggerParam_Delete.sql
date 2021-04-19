SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the TAN_TriggerParam table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_TriggerParam_Delete]
(

	@TriggerId uniqueidentifier   ,

	@TriggerParamTypeId int   
)
AS


                    DELETE [dbo].[TAN_TriggerParam]
				WHERE
					[TriggerId] = @TriggerId
					AND [TriggerParamTypeId] = @TriggerParamTypeId
					
			


GO
