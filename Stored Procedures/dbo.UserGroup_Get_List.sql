SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the UserGroup table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[UserGroup_Get_List]

AS


				
				SELECT
					[UserId],
					[GroupId],
					[Archived],
					[LastModified]
				FROM
					[dbo].[UserGroup]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
