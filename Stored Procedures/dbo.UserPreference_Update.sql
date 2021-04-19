SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the UserPreference table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[UserPreference_Update]
(

	@UserPreferenceId uniqueidentifier   ,

	@UserId uniqueidentifier   ,

	@NameId int   ,

	@Value nvarchar (MAX)  ,

	@Archived bit   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[UserPreference]
				SET
					[UserID] = @UserId
					,[NameID] = @NameId
					,[Value] = @Value
					,[Archived] = @Archived
				WHERE
[UserPreferenceID] = @UserPreferenceId 
				
			


GO
