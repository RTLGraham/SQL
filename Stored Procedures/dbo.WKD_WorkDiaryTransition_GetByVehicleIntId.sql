SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the WKD_WorkDiaryTransition table through a foreign key
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WKD_WorkDiaryTransition_GetByVehicleIntId]
(

	@VehicleIntId int   
)
AS


				SET ANSI_NULLS OFF
				
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
                            [VehicleIntId] = @VehicleIntId
                                AND
                            Archived = 0
				
				SELECT @@ROWCOUNT
				SET ANSI_NULLS ON
			


GO
