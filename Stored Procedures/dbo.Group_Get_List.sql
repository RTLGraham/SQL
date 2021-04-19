SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the Group table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Group_Get_List]

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
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
