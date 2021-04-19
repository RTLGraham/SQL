SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the WKD_WorkDiary table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WKD_WorkDiary_Delete]
(

	@WorkDiaryId int   
)
AS


                    UPDATE [dbo].[WKD_WorkDiary]
                    SET Archived = 1
				WHERE
					[WorkDiaryId] = @WorkDiaryId
					
			


GO
