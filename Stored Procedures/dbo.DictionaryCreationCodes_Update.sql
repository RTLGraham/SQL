SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the DictionaryCreationCodes table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[DictionaryCreationCodes_Update]
(

	@CreationCodeId smallint   ,

	@OriginalCreationCodeId smallint   ,

	@DictionaryNameId int   ,

	@OriginalDictionaryNameId int   ,

	@DictionaryCreationCodeTypeId int   ,

	@OriginalDictionaryCreationCodeTypeId int   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[DictionaryCreationCodes]
				SET
					[CreationCodeId] = @CreationCodeId
					,[DictionaryNameId] = @DictionaryNameId
					,[DictionaryCreationCodeTypeId] = @DictionaryCreationCodeTypeId
				WHERE
[CreationCodeId] = @OriginalCreationCodeId 
AND [DictionaryNameId] = @OriginalDictionaryNameId 
AND [DictionaryCreationCodeTypeId] = @OriginalDictionaryCreationCodeTypeId 
				
			


GO
