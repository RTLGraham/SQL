SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the TAN_TriggerParam table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_TriggerParam_GetByTriggerIdTriggerParamTypeId]
(

	@TriggerId uniqueidentifier   ,

	@TriggerParamTypeId int   
)
AS


				SELECT
					[TriggerId],
					[TriggerParamTypeId],
					[TriggerParamTypeValue],
					[Archived],
					[LastOperation],
					[Count]
				FROM
					[dbo].[TAN_TriggerParam]
				WHERE
					[TriggerId] = @TriggerId
					AND [TriggerParamTypeId] = @TriggerParamTypeId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
