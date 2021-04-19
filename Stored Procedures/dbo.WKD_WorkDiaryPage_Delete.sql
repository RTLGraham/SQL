SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the WKD_WorkDiaryPage table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WKD_WorkDiaryPage_Delete]
(

	@WorkDiaryPageId int   
)
AS


                    UPDATE [dbo].[WKD_WorkDiaryPage]
                    SET Archived = 1
				WHERE
					[WorkDiaryPageId] = @WorkDiaryPageId
					
			


GO
