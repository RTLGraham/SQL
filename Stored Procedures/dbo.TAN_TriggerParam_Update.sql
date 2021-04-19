SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the TAN_TriggerParam table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_TriggerParam_Update]
(

	@TriggerId uniqueidentifier   ,

	@OriginalTriggerId uniqueidentifier   ,

	@TriggerParamTypeId int   ,

	@OriginalTriggerParamTypeId int   ,

	@TriggerParamTypeValue varchar (255)  ,

	@Archived bit   ,

	@LastOperation smalldatetime   ,

	@Count bigint   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[TAN_TriggerParam]
				SET
					[TriggerId] = @TriggerId
					,[TriggerParamTypeId] = @TriggerParamTypeId
					,[TriggerParamTypeValue] = @TriggerParamTypeValue
					,[Archived] = @Archived
					,[LastOperation] = @LastOperation
					,[Count] = @Count
				WHERE
[TriggerId] = @TriggerId 
AND [TriggerParamTypeId] = @TriggerParamTypeId 
				
			


GO
