SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the UserSession table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[UserSession_Update]
(

	@SessionId uniqueidentifier   ,

	@UserId uniqueidentifier   ,

	@IsLoggedIn bit   ,

	@LastOperation datetime   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[UserSession]
				SET
					[UserID] = @UserId
					,[IsLoggedIn] = @IsLoggedIn
					,[LastOperation] = @LastOperation
				WHERE
[SessionID] = @SessionId 
				
			


GO
