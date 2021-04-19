SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the UserGroup table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[UserGroup_Delete]
(

	@UserId uniqueidentifier   ,

	@GroupId uniqueidentifier   
)
AS


                    UPDATE [dbo].[UserGroup]
                    SET Archived = 1
				WHERE
					[UserId] = @UserId
					AND [GroupId] = @GroupId
					
			


GO
