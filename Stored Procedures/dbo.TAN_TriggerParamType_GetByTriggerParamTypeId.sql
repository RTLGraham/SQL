SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the TAN_TriggerParamType table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_TriggerParamType_GetByTriggerParamTypeId]
(

	@TriggerParamTypeId int   
)
AS


				SELECT
					[TriggerParamTypeId],
					[Name],
					[Description],
					[Archived],
					[LastOperation]
				FROM
					[dbo].[TAN_TriggerParamType]
				WHERE
					[TriggerParamTypeId] = @TriggerParamTypeId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
