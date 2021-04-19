SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the TAN_TriggerType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_TriggerType_Update]
(

	@TriggerTypeId int   ,

	@OriginalTriggerTypeId int   ,

	@Name varchar (255)  ,

	@Description varchar (MAX)  ,

	@CreationCodeId smallint   ,

	@Archived bit   ,

	@LastOperation smalldatetime   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[TAN_TriggerType]
				SET
					[TriggerTypeId] = @TriggerTypeId
					,[Name] = @Name
					,[Description] = @Description
					,[CreationCodeId] = @CreationCodeId
					,[Archived] = @Archived
					,[LastOperation] = @LastOperation
				WHERE
[TriggerTypeId] = @OriginalTriggerTypeId 
				
			


GO
