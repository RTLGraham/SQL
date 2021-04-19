SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the DictionaryCreationCodes table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[DictionaryCreationCodes_Get_List]

AS


				
				SELECT
					[CreationCodeId],
					[DictionaryNameId],
					[DictionaryCreationCodeTypeId]
				FROM
					[dbo].[DictionaryCreationCodes]

				SELECT @@ROWCOUNT
			


GO
