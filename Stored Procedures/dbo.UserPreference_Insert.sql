SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the UserPreference table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[UserPreference_Insert]
(

	@UserPreferenceId uniqueidentifier    OUTPUT,

	@UserId uniqueidentifier   ,

	@NameId int   ,

	@Value nvarchar (MAX)  ,

	@Archived bit   
)
AS


				
				Declare @IdentityRowGuids table (UserPreferenceId uniqueidentifier	)
				INSERT INTO [dbo].[UserPreference]
					(
					[UserID]
					,[NameID]
					,[Value]
					,[Archived]
					)
						OUTPUT INSERTED.UserPreferenceID INTO @IdentityRowGuids
					
				VALUES
					(
					@UserId
					,@NameId
					,@Value
					,@Archived
					)
				
				SELECT @UserPreferenceId=UserPreferenceId	 from @IdentityRowGuids
									
							
			


GO
