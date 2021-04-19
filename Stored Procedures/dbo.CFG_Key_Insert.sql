SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the CFG_Key table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[CFG_Key_Insert]
(

	@KeyId int    OUTPUT,

	@Name varchar (255)  ,

	@Description varchar (MAX)  ,

	@IndexPos smallint   ,

	@Archived bit   ,

	@LastOperation smalldatetime   
)
AS


				
				INSERT INTO [dbo].[CFG_Key]
					(
					[Name]
					,[Description]
					,[IndexPos]
					,[Archived]
					,[LastOperation]
					)
				VALUES
					(
					@Name
					,@Description
					,@IndexPos
					,@Archived
					,@LastOperation
					)
				
				-- Get the identity value
				SET @KeyId = SCOPE_IDENTITY()
									
							
			

GO
