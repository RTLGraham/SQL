SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the TAN_TriggerEntity table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_TriggerEntity_Insert]
(

	@TriggerId uniqueidentifier   ,

	@TriggerEntityId uniqueidentifier   ,

	@Disabled bit   ,

	@Archived bit   ,

	@LastOperation smalldatetime   ,

	@Count bigint   
)
AS


				
				INSERT INTO [dbo].[TAN_TriggerEntity]
					(
					[TriggerId]
					,[TriggerEntityId]
					,[Disabled]
					,[Archived]
					,[LastOperation]
					,[Count]
					)
				VALUES
					(
					@TriggerId
					,@TriggerEntityId
					,@Disabled
					,@Archived
					,@LastOperation
					,@Count
					)
				
									
							
			


GO
