SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the TAN_TriggerParam table through a foreign key
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_TriggerParam_GetByTriggerParamTypeId]
(

	@TriggerParamTypeId int   
)
AS


				SET ANSI_NULLS OFF
				
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
                            [TriggerParamTypeId] = @TriggerParamTypeId
                                AND
                            Archived = 0
				
				SELECT @@ROWCOUNT
				SET ANSI_NULLS ON
			


GO
