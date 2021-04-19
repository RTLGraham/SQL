SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the CFG_Category table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[CFG_Category_Insert]
(

	@CategoryId int    OUTPUT,

	@Name varchar (255)  ,

	@Description varchar (MAX)  ,

	@Archived bit   ,

	@LastOperation smalldatetime   
)
AS


				
				INSERT INTO [dbo].[CFG_Category]
					(
					[Name]
					,[Description]
					,[Archived]
					,[LastOperation]
					)
				VALUES
					(
					@Name
					,@Description
					,@Archived
					,@LastOperation
					)
				
				-- Get the identity value
				SET @CategoryId = SCOPE_IDENTITY()
									
							
			


GO
