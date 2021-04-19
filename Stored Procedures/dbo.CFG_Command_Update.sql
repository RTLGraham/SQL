SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the CFG_Command table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[CFG_Command_Update]
(

	@CommandId int   ,

	@IvhTypeId int   ,

	@CommandString varchar (MAX)  ,

	@Description varchar (MAX)  ,

	@Archived bit   ,

	@LastOperation smalldatetime   
)
AS


				
				/*Legacy*/
				-- Modify the updatable columns
--				UPDATE
--					[dbo].[CFG_Command]
--				SET
--					[IVHTypeId] = @IvhTypeId
--					,[CommandString] = @CommandString
--					,[Description] = @Description
--					,[Archived] = @Archived
--					,[LastOperation] = @LastOperation
--				WHERE
--[CommandId] = @CommandId 
				
			


GO
