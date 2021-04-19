SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the CFG_Category table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[CFG_Category_Update]
(

	@CategoryId int   ,

	@Name varchar (255)  ,

	@Description varchar (MAX)  ,

	@Archived bit   ,

	@LastOperation smalldatetime   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[CFG_Category]
				SET
					[Name] = @Name
					,[Description] = @Description
					,[Archived] = @Archived
					,[LastOperation] = @LastOperation
				WHERE
[CategoryId] = @CategoryId 
				
			


GO
