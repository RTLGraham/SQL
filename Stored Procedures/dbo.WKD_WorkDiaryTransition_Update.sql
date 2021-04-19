SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the WKD_WorkDiaryTransition table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WKD_WorkDiaryTransition_Update]
(

	@WorkDiaryTransitionId bigint   ,

	@WorkDiaryPageId int   ,

	@VehicleIntId int   ,

	@WorkStateTypeId int   ,

	@TransitionDateTime smalldatetime   ,

	@Odometer int   ,

	@Lat float   ,

	@SafeNameLong float   ,

	@Location nvarchar (200)  ,

	@TwoUpInd bit   ,

	@Note nvarchar (200)  ,

	@Archived bit   ,

	@LastOperation smalldatetime   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[WKD_WorkDiaryTransition]
				SET
					[WorkDiaryPageId] = @WorkDiaryPageId
					,[VehicleIntId] = @VehicleIntId
					,[WorkStateTypeId] = @WorkStateTypeId
					,[TransitionDateTime] = @TransitionDateTime
					,[Odometer] = @Odometer
					,[Lat] = @Lat
					,[Long] = @SafeNameLong
					,[Location] = @Location
					,[TwoUpInd] = @TwoUpInd
					,[Note] = @Note
					,[Archived] = @Archived
					,[LastOperation] = @LastOperation
				WHERE
[WorkDiaryTransitionId] = @WorkDiaryTransitionId 
				
			


GO
