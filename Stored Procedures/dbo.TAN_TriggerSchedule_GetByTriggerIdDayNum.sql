SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the TAN_TriggerSchedule table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_TriggerSchedule_GetByTriggerIdDayNum]
(

	@TriggerId uniqueidentifier   ,

	@DayNum smallint   
)
AS


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
					AND [DayNum] = @DayNum
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
