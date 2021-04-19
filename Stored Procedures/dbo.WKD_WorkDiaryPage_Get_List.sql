SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the WKD_WorkDiaryPage table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WKD_WorkDiaryPage_Get_List]

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
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
