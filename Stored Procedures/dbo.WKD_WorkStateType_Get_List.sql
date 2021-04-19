SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the WKD_WorkStateType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WKD_WorkStateType_Get_List]

AS


				
				SELECT
					[WorkStateTypeId],
					[Name],
					[Description],
					[LastModified],
					[Archived]
				FROM
					[dbo].[WKD_WorkStateType]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
