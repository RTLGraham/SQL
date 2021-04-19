SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the TAN_Trigger table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_Trigger_GetByTriggerId]
(

	@TriggerId uniqueidentifier   
)
AS


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
					[TriggerId] = @TriggerId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
