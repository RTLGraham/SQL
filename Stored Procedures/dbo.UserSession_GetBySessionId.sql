SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the UserSession table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[UserSession_GetBySessionId]
(

	@SessionId uniqueidentifier   
)
AS


				SELECT
					[SessionID],
					[UserID],
					[IsLoggedIn],
					[LastOperation]
				FROM
					[dbo].[UserSession]
				WHERE
					[SessionID] = @SessionId
				SELECT @@ROWCOUNT
					
			


GO
