SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the TAN_TriggerEntity table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_TriggerEntity_Update]
(

	@TriggerId uniqueidentifier   ,

	@OriginalTriggerId uniqueidentifier   ,

	@TriggerEntityId uniqueidentifier   ,

	@OriginalTriggerEntityId uniqueidentifier   ,

	@Disabled bit   ,

	@Archived bit   ,

	@LastOperation smalldatetime   ,

	@Count bigint   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[TAN_TriggerEntity]
				SET
					[TriggerId] = @TriggerId
					,[TriggerEntityId] = @TriggerEntityId
					,[Disabled] = @Disabled
					,[Archived] = @Archived
					,[LastOperation] = @LastOperation
					,[Count] = @Count
				WHERE
[TriggerId] = @OriginalTriggerId 
AND [TriggerEntityId] = @OriginalTriggerEntityId 
				
			


GO
