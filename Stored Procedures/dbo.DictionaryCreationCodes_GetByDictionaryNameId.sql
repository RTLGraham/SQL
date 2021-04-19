SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the DictionaryCreationCodes table through a foreign key
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[DictionaryCreationCodes_GetByDictionaryNameId]
(

	@DictionaryNameId int   
)
AS


				SET ANSI_NULLS OFF
				
				SELECT
					[CreationCodeId],
					[DictionaryNameId],
					[DictionaryCreationCodeTypeId]
				FROM
					[dbo].[DictionaryCreationCodes]
				WHERE
                            [DictionaryNameId] = @DictionaryNameId
				
				SELECT @@ROWCOUNT
				SET ANSI_NULLS ON
			


GO
