SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the DictionaryCreationCodeType table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[DictionaryCreationCodeType_GetByDictionaryCreationCodeTypeId]
(

	@DictionaryCreationCodeTypeId int   
)
AS


				SELECT
					[DictionaryCreationCodeTypeId],
					[Name],
					[Description],
					[Archived],
					[LastModified]
				FROM
					[dbo].[DictionaryCreationCodeType]
				WHERE
					[DictionaryCreationCodeTypeId] = @DictionaryCreationCodeTypeId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
