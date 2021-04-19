SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the TAN_TriggerSchedule table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_TriggerSchedule_Insert]
(

	@TriggerId uniqueidentifier   ,

	@DayNum smallint   ,

	@Archived bit   ,

	@LastOperation smalldatetime   ,

	@Count bigint   
)
AS


				
				INSERT INTO [dbo].[TAN_TriggerSchedule]
					(
					[TriggerId]
					,[DayNum]
					,[Archived]
					,[LastOperation]
					,[Count]
					)
				VALUES
					(
					@TriggerId
					,@DayNum
					,@Archived
					,@LastOperation
					,@Count
					)
				
									
							
			


GO
