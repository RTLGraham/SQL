SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the TAN_Trigger table through a foreign key
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_Trigger_GetByTriggerTypeId]
(

	@TriggerTypeId int   
)
AS


				SET ANSI_NULLS OFF
				
				SELECT
					[TriggerId],
					[TriggerTypeId],
					[Name],
					[Description],
					[Disabled],
					[Archived],
					[LastOperation],
					[CustomerId],
					[CreatedBy],
					[Count]
				FROM
					[dbo].[TAN_Trigger]
				WHERE
                            [TriggerTypeId] = @TriggerTypeId
                                AND
                            Archived = 0
				
				SELECT @@ROWCOUNT
				SET ANSI_NULLS ON
			


GO
