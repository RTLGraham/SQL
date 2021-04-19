SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the DictionaryName table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[DictionaryName_Update]
(

	@NameId int   ,

	@OriginalNameId int   ,

	@Name nvarchar (255)  ,

	@Description nvarchar (MAX)  ,

	@Archived bit   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[DictionaryName]
				SET
					[NameID] = @NameId
					,[Name] = @Name
					,[Description] = @Description
					,[Archived] = @Archived
				WHERE
[NameID] = @OriginalNameId 
				
			


GO
