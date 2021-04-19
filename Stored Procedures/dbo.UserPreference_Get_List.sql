SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the UserPreference table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[UserPreference_Get_List]

AS


				
				SELECT
					[UserPreferenceID],
					[UserID],
					[NameID],
					[Value],
					[Archived]
				FROM
					[dbo].[UserPreference]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
