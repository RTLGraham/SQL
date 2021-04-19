SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the CFG_Key table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[CFG_Key_Get_List]

AS


				
				SELECT
					[KeyId],
					[Name],
					[Description],
					[IndexPos],
					[Archived],
					[LastOperation]
				FROM
					[dbo].[CFG_Key]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			

GO
