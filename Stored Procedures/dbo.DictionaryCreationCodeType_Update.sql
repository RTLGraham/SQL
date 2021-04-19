SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the DictionaryCreationCodeType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[DictionaryCreationCodeType_Update]
(

	@DictionaryCreationCodeTypeId int   ,

	@OriginalDictionaryCreationCodeTypeId int   ,

	@Name nvarchar (255)  ,

	@Description nvarchar (MAX)  ,

	@Archived bit   ,

	@LastModified datetime   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[DictionaryCreationCodeType]
				SET
					[DictionaryCreationCodeTypeId] = @DictionaryCreationCodeTypeId
					,[Name] = @Name
					,[Description] = @Description
					,[Archived] = @Archived
					,[LastModified] = @LastModified
				WHERE
[DictionaryCreationCodeTypeId] = @OriginalDictionaryCreationCodeTypeId 
				
			


GO
