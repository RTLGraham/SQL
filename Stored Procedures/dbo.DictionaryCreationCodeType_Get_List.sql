SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the DictionaryCreationCodeType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[DictionaryCreationCodeType_Get_List]

AS


				
				SELECT
					[DictionaryCreationCodeTypeId],
					[Name],
					[Description],
					[Archived],
					[LastModified]
				FROM
					[dbo].[DictionaryCreationCodeType]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
