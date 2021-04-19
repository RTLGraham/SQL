SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the TAN_TriggerSchedule table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_TriggerSchedule_Update]
(

	@TriggerId uniqueidentifier   ,

	@OriginalTriggerId uniqueidentifier   ,

	@DayNum smallint   ,

	@OriginalDayNum smallint   ,

	@Archived bit   ,

	@LastOperation smalldatetime   ,

	@Count bigint   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[TAN_TriggerSchedule]
				SET
					[TriggerId] = @TriggerId
					,[DayNum] = @DayNum
					,[Archived] = @Archived
					,[LastOperation] = @LastOperation
					,[Count] = @Count
				WHERE
[TriggerId] = @OriginalTriggerId 
AND [DayNum] = @OriginalDayNum 
				
			


GO
