SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the WKD_WorkDiaryPage table through a foreign key
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WKD_WorkDiaryPage_GetByWorkDiaryId]
(

	@WorkDiaryId int   
)
AS


				SET ANSI_NULLS OFF
				
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
                            [WorkDiaryId] = @WorkDiaryId
                                AND
                            Archived = 0
				
				SELECT @@ROWCOUNT
				SET ANSI_NULLS ON
			


GO
