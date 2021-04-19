SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the TAN_TriggerSchedule table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_TriggerSchedule_Get_List]

AS


				
				SELECT
					[TriggerId],
					[DayNum],
					[Archived],
					[LastOperation],
					[Count]
				FROM
					[dbo].[TAN_TriggerSchedule]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
