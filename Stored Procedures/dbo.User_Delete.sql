SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the User table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[User_Delete]
(

	@UserId uniqueidentifier   
)
AS


                    UPDATE [dbo].[User]
                    SET Archived = 1
				WHERE
					[UserID] = @UserId
					
			


GO
