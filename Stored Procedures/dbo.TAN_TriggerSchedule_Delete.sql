SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the TAN_TriggerSchedule table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_TriggerSchedule_Delete]
(

	@TriggerId uniqueidentifier   ,

	@DayNum smallint   
)
AS


                DELETE from [dbo].[TAN_TriggerSchedule]
                    
				WHERE
					[TriggerId] = @TriggerId
					AND [DayNum] = @DayNum
					
			


GO
