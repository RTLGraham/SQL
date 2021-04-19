SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the Group table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Group_GetByGroupId]
(

	@GroupId uniqueidentifier   
)
AS


				SELECT
					[GroupId],
					[GroupName],
					[GroupTypeId],
					[IsParameter],
					[Archived],
					[LastModified],
					[OriginalGroupId]
				FROM
					[dbo].[Group]
				WHERE
					[GroupId] = @GroupId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
