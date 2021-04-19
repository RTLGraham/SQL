SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the UserGroup table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[UserGroup_GetByUserIdGroupId]
(

	@UserId uniqueidentifier   ,

	@GroupId uniqueidentifier   
)
AS


				SELECT
					[UserId],
					[GroupId],
					[Archived],
					[LastModified]
				FROM
					[dbo].[UserGroup]
				WHERE
					[UserId] = @UserId
					AND [GroupId] = @GroupId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
