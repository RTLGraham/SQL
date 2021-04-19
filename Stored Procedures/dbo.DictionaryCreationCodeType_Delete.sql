SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the DictionaryCreationCodeType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[DictionaryCreationCodeType_Delete]
(

	@DictionaryCreationCodeTypeId int   
)
AS


                    UPDATE [dbo].[DictionaryCreationCodeType]
                    SET Archived = 1
				WHERE
					[DictionaryCreationCodeTypeId] = @DictionaryCreationCodeTypeId
					
			


GO
