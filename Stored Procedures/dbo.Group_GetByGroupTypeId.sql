SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the Group table through a foreign key
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Group_GetByGroupTypeId]
(

	@GroupTypeId int   
)
AS


				SET ANSI_NULLS OFF
				
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
                            [GroupTypeId] = @GroupTypeId
                                AND
                            Archived = 0
				
				SELECT @@ROWCOUNT
				SET ANSI_NULLS ON
			


GO
