SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the CFG_Category table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[CFG_Category_GetByCategoryId]
(

	@CategoryId int   
)
AS


				SELECT
					[CategoryId],
					[Name],
					[Description],
					[Archived],
					[LastOperation]
				FROM
					[dbo].[CFG_Category]
				WHERE
					[CategoryId] = @CategoryId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
