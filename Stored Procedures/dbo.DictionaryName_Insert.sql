SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the DictionaryName table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[DictionaryName_Insert]
(

	@NameId int   ,

	@Name nvarchar (255)  ,

	@Description nvarchar (MAX)  ,

	@Archived bit   
)
AS


				
				INSERT INTO [dbo].[DictionaryName]
					(
					[NameID]
					,[Name]
					,[Description]
					,[Archived]
					)
				VALUES
					(
					@NameId
					,@Name
					,@Description
					,@Archived
					)
				
									
							
			


GO
