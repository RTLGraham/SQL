SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the UserPreference table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[UserPreference_Delete]
(

	@UserPreferenceId uniqueidentifier   
)
AS


                    UPDATE [dbo].[UserPreference]
                    SET Archived = 1
				WHERE
					[UserPreferenceID] = @UserPreferenceId
					
			


GO
