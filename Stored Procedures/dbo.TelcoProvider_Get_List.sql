SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the TelcoProvider table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TelcoProvider_Get_List]

AS


				
				SELECT
					[TelcoProviderId],
					[Name],
					[Description],
					[Archived]
				FROM
					[dbo].[TelcoProvider]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
