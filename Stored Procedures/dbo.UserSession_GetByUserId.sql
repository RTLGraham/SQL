SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the UserSession table through a foreign key
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[UserSession_GetByUserId]
(

	@UserId uniqueidentifier   
)
AS


				SET ANSI_NULLS OFF
				
				SELECT
					[SessionID],
					[UserID],
					[IsLoggedIn],
					[LastOperation]
				FROM
					[dbo].[UserSession]
				WHERE
                            [UserID] = @UserId
				
				SELECT @@ROWCOUNT
				SET ANSI_NULLS ON
			


GO
