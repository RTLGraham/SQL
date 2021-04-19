SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the CFG_KeyCommand table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[CFG_KeyCommand_Update]
(

	@KeyCommandId int   ,

	@CategoryId int   ,

	@CommandId int   ,

	@KeyId int   ,

	@MinValue float   ,

	@MaxValue float   ,

	@MinDate datetime   ,

	@MaxDate datetime   ,

	@LastOperation smalldatetime   
)
AS


				
				
				/*Legacy*/
				-- Modify the updatable columns
--				UPDATE
--					[dbo].[CFG_KeyCommand]
--				SET
--					[CategoryId] = @CategoryId
--					,[CommandId] = @CommandId
--					,[KeyId] = @KeyId
--					,[MinValue] = @MinValue
--					,[MaxValue] = @MaxValue
--					,[MinDate] = @MinDate
--					,[MaxDate] = @MaxDate
--					,[LastOperation] = @LastOperation
--				WHERE
--[KeyCommandId] = @KeyCommandId 
				
			


GO
