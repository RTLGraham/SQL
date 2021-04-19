SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the DictionaryCreationCodes table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[DictionaryCreationCodes_GetByCreationCodeIdDictionaryNameIdDictionaryCreationCodeTypeId]
(

	@CreationCodeId smallint   ,

	@DictionaryNameId int   ,

	@DictionaryCreationCodeTypeId int   
)
AS


				SELECT
					[CreationCodeId],
					[DictionaryNameId],
					[DictionaryCreationCodeTypeId]
				FROM
					[dbo].[DictionaryCreationCodes]
				WHERE
					[CreationCodeId] = @CreationCodeId
					AND [DictionaryNameId] = @DictionaryNameId
					AND [DictionaryCreationCodeTypeId] = @DictionaryCreationCodeTypeId
				SELECT @@ROWCOUNT
					
			


GO
