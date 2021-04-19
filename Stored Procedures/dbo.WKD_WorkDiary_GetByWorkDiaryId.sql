SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the WKD_WorkDiary table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WKD_WorkDiary_GetByWorkDiaryId]
(

	@WorkDiaryId int   
)
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
				WHERE
					[WorkDiaryId] = @WorkDiaryId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
