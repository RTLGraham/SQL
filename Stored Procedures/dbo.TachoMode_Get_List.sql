SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the TachoMode table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TachoMode_Get_List]

AS


				
				SELECT
					[TachoModeID],
					[Name],
					[Description],
					[Archived]
				FROM
					[dbo].[TachoMode]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
