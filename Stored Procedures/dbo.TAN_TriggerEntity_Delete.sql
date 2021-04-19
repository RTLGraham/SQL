SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the TAN_TriggerEntity table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_TriggerEntity_Delete]
(

	@TriggerId uniqueidentifier   ,

	@TriggerEntityId uniqueidentifier   
)
AS


                    DELETE [dbo].[TAN_TriggerEntity]
				WHERE
					[TriggerId] = @TriggerId
					AND [TriggerEntityId] = @TriggerEntityId
					
			


GO
