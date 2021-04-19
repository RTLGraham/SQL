SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the UserSession table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[UserSession_Insert]
(

	@SessionId uniqueidentifier    OUTPUT,

	@UserId uniqueidentifier   ,

	@IsLoggedIn bit   ,

	@LastOperation datetime   
)
AS


				
				Declare @IdentityRowGuids table (SessionId uniqueidentifier	)
				INSERT INTO [dbo].[UserSession]
					(
					[UserID]
					,[IsLoggedIn]
					,[LastOperation]
					)
						OUTPUT INSERTED.SessionID INTO @IdentityRowGuids
					
				VALUES
					(
					@UserId
					,@IsLoggedIn
					,@LastOperation
					)
				
				SELECT @SessionId=SessionId	 from @IdentityRowGuids
									
							
			


GO
