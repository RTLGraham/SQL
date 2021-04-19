SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the TAN_TriggerParamType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_TriggerParamType_Update]
(

	@TriggerParamTypeId int   ,

	@OriginalTriggerParamTypeId int   ,

	@Name varchar (255)  ,

	@Description varchar (MAX)  ,

	@Archived bit   ,

	@LastOperation smalldatetime   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[TAN_TriggerParamType]
				SET
					[TriggerParamTypeId] = @TriggerParamTypeId
					,[Name] = @Name
					,[Description] = @Description
					,[Archived] = @Archived
					,[LastOperation] = @LastOperation
				WHERE
[TriggerParamTypeId] = @OriginalTriggerParamTypeId 
				
			


GO
