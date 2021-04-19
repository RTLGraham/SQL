SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the WKD_WorkDiaryTransition table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WKD_WorkDiaryTransition_Get_List]

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
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
