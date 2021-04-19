SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the UserGroup table through a foreign key
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[UserGroup_GetByGroupId]
(

	@GroupId uniqueidentifier   
)
AS


				SET ANSI_NULLS OFF
				
				SELECT
					[UserId],
					[GroupId],
					[Archived],
					[LastModified]
				FROM
					[dbo].[UserGroup]
				WHERE
                            [GroupId] = @GroupId
                                AND
                            Archived = 0
				
				SELECT @@ROWCOUNT
				SET ANSI_NULLS ON
			


GO
