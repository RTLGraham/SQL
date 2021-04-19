SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the CFG_Key table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[CFG_Key_Update]
(

	@KeyId int   ,

	@Name varchar (255)  ,

	@Description varchar (MAX)  ,

	@IndexPos smallint   ,

	@Archived bit   ,

	@LastOperation smalldatetime   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[CFG_Key]
				SET
					[Name] = @Name
					,[Description] = @Description
					,[IndexPos] = @IndexPos
					,[Archived] = @Archived
					,[LastOperation] = @LastOperation
				WHERE
[KeyId] = @KeyId 
				
			

GO
