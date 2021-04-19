SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the CFG_Category table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[CFG_Category_Delete]
(

	@CategoryId int   
)
AS


                    UPDATE [dbo].[CFG_Category]
                    SET Archived = 1
				WHERE
					[CategoryId] = @CategoryId
					
			


GO
