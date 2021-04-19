SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the WKD_WorkDiaryTransition table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WKD_WorkDiaryTransition_GetByWorkDiaryTransitionId]
(

	@WorkDiaryTransitionId bigint   
)
AS


				SELECT
					[WorkDiaryTransitionId],
					[WorkDiaryPageId],
					[VehicleIntId],
					[WorkStateTypeId],
					[TransitionDateTime],
					[Odometer],
					[Lat],
					[Long],
					[Location],
					[TwoUpInd],
					[Note],
					[Archived],
					[LastOperation]
				FROM
					[dbo].[WKD_WorkDiaryTransition]
				WHERE
					[WorkDiaryTransitionId] = @WorkDiaryTransitionId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
