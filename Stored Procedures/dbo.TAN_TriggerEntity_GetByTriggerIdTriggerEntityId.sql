SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the TAN_TriggerEntity table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_TriggerEntity_GetByTriggerIdTriggerEntityId]
(

	@TriggerId uniqueidentifier   ,

	@TriggerEntityId uniqueidentifier   
)
AS


				SELECT
					[TriggerId],
					[TriggerEntityId],
					[Disabled],
					[Archived],
					[LastOperation],
					[Count]
				FROM
					[dbo].[TAN_TriggerEntity]
				WHERE
					[TriggerId] = @TriggerId
					AND [TriggerEntityId] = @TriggerEntityId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
