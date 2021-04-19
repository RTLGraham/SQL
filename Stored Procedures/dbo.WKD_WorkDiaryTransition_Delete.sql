SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the WKD_WorkDiaryTransition table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WKD_WorkDiaryTransition_Delete]
(

	@WorkDiaryTransitionId bigint   
)
AS


                    UPDATE [dbo].[WKD_WorkDiaryTransition]
                    SET Archived = 1
				WHERE
					[WorkDiaryTransitionId] = @WorkDiaryTransitionId
					
			


GO
