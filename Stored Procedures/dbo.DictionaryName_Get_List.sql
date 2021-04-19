SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the DictionaryName table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[DictionaryName_Get_List]

AS


				
				SELECT
					[NameID],
					[Name],
					[Description],
					[Archived]
				FROM
					[dbo].[DictionaryName]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
