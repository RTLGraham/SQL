SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the DictionaryName table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[DictionaryName_Delete]
(

	@NameId int   
)
AS


                    UPDATE [dbo].[DictionaryName]
                    SET Archived = 1
				WHERE
					[NameID] = @NameId
					
			


GO
