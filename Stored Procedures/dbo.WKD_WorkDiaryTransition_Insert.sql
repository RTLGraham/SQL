SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the WKD_WorkDiaryTransition table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WKD_WorkDiaryTransition_Insert]
(

	@WorkDiaryTransitionId bigint    OUTPUT,

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


				
				INSERT INTO [dbo].[WKD_WorkDiaryTransition]
					(
					[WorkDiaryPageId]
					,[VehicleIntId]
					,[WorkStateTypeId]
					,[TransitionDateTime]
					,[Odometer]
					,[Lat]
					,[Long]
					,[Location]
					,[TwoUpInd]
					,[Note]
					,[Archived]
					,[LastOperation]
					)
				VALUES
					(
					@WorkDiaryPageId
					,@VehicleIntId
					,@WorkStateTypeId
					,@TransitionDateTime
					,@Odometer
					,@Lat
					,@SafeNameLong
					,@Location
					,@TwoUpInd
					,@Note
					,@Archived
					,@LastOperation
					)
				
				-- Get the identity value
				SET @WorkDiaryTransitionId = SCOPE_IDENTITY()
									
							
			


GO
