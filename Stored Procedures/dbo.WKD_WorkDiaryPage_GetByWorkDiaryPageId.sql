SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the WKD_WorkDiaryPage table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WKD_WorkDiaryPage_GetByWorkDiaryPageId]
(

	@WorkDiaryPageId int   
)
AS


				SELECT
					[WorkDiaryPageId],
					[WorkDiaryId],
					[Date],
					[DriverSignature],
					[SignDate],
					[TwoUpWorkDiaryPageId],
					[Archived],
					[LastOperation]
				FROM
					[dbo].[WKD_WorkDiaryPage]
				WHERE
					[WorkDiaryPageId] = @WorkDiaryPageId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
