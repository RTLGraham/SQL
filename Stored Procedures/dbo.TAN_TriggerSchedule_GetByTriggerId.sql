SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the TAN_TriggerSchedule table through a foreign key
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_TriggerSchedule_GetByTriggerId]
(

	@TriggerId uniqueidentifier   
)
AS


				SET ANSI_NULLS OFF
				
				SELECT
					[TriggerId],
					[DayNum],
					[Archived],
					[LastOperation],
					[Count]
				FROM
					[dbo].[TAN_TriggerSchedule]
				WHERE
                            [TriggerId] = @TriggerId
                                AND
                            Archived = 0
				
				SELECT @@ROWCOUNT
				SET ANSI_NULLS ON
			


GO
