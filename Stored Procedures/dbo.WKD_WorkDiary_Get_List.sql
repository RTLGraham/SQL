SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the WKD_WorkDiary table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WKD_WorkDiary_Get_List]

AS


				
				SELECT
					[WorkDiaryId],
					[DriverIntId],
					[StartDate],
					[Number],
					[EndDate],
					[Archived],
					[LastOperation]
				FROM
					[dbo].[WKD_WorkDiary]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
