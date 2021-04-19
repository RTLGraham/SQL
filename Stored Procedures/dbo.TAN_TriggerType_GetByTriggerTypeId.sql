SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the TAN_TriggerType table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_TriggerType_GetByTriggerTypeId]
(

	@TriggerTypeId int   
)
AS


				SELECT
					[TriggerTypeId],
					[Name],
					[Description],
					[CreationCodeId],
					[Archived],
					[LastOperation]
				FROM
					[dbo].[TAN_TriggerType]
				WHERE
					[TriggerTypeId] = @TriggerTypeId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
