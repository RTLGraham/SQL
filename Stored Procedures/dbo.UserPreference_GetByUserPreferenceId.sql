SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the UserPreference table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[UserPreference_GetByUserPreferenceId]
(

	@UserPreferenceId uniqueidentifier   
)
AS


				SELECT
					[UserPreferenceID],
					[UserID],
					[NameID],
					[Value],
					[Archived]
				FROM
					[dbo].[UserPreference]
				WHERE
					[UserPreferenceID] = @UserPreferenceId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
