SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the DictionaryName table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[DictionaryName_GetByNameId]
(

	@NameId int   
)
AS


				SELECT
					[NameID],
					[Name],
					[Description],
					[Archived]
				FROM
					[dbo].[DictionaryName]
				WHERE
					[NameID] = @NameId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
