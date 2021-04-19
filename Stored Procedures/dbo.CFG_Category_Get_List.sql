SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the CFG_Category table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[CFG_Category_Get_List]

AS


				
				SELECT
					[CategoryId],
					[Name],
					[Description],
					[Archived],
					[LastOperation]
				FROM
					[dbo].[CFG_Category]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
