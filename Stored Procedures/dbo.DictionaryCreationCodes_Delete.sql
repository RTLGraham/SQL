SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the DictionaryCreationCodes table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[DictionaryCreationCodes_Delete]
(

	@CreationCodeId smallint   ,

	@DictionaryNameId int   ,

	@DictionaryCreationCodeTypeId int   
)
AS


				    DELETE FROM [dbo].[DictionaryCreationCodes] WITH (ROWLOCK) 
				WHERE
					[CreationCodeId] = @CreationCodeId
					AND [DictionaryNameId] = @DictionaryNameId
					AND [DictionaryCreationCodeTypeId] = @DictionaryCreationCodeTypeId
					
			


GO
