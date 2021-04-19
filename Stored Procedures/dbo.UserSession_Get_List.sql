SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the UserSession table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[UserSession_Get_List]

AS


				
				SELECT
					[SessionID],
					[UserID],
					[IsLoggedIn],
					[LastOperation]
				FROM
					[dbo].[UserSession]

				SELECT @@ROWCOUNT
			


GO
