SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the TAN_Trigger table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_Trigger_Update]
(

	@TriggerId uniqueidentifier   ,

	@OriginalTriggerId uniqueidentifier   ,

	@TriggerTypeId int   ,

	@Name varchar (255)  ,

	@Description varchar (MAX)  ,

	@Disabled bit   ,

	@Archived bit   ,

	@LastOperation smalldatetime   ,

	@CustomerId uniqueidentifier   ,

	@CreatedBy uniqueidentifier   ,

	@Count bigint   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[TAN_Trigger]
				SET
					[TriggerId] = @TriggerId
					,[TriggerTypeId] = @TriggerTypeId
					,[Name] = @Name
					,[Description] = @Description
					,[Disabled] = @Disabled
					,[Archived] = @Archived
					,[LastOperation] = @LastOperation
					--,[CustomerId] = @CustomerId
					,[CreatedBy] = @CreatedBy
					,[Count] = @Count
				WHERE
[TriggerId] = @TriggerId 
				
			


GO
