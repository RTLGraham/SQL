SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the WKD_WorkDiaryTransition table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WKD_WorkDiaryTransition_Find]
(

	@SearchUsingOR bit   = null ,

	@WorkDiaryTransitionId bigint   = null ,

	@WorkDiaryPageId int   = null ,

	@VehicleIntId int   = null ,

	@WorkStateTypeId int   = null ,

	@TransitionDateTime smalldatetime   = null ,

	@Odometer int   = null ,

	@Lat float   = null ,

	@SafeNameLong float   = null ,

	@Location nvarchar (200)  = null ,

	@TwoUpInd bit   = null ,

	@Note nvarchar (200)  = null ,

	@Archived bit   = null ,

	@LastOperation smalldatetime   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [WorkDiaryTransitionId]
	, [WorkDiaryPageId]
	, [VehicleIntId]
	, [WorkStateTypeId]
	, [TransitionDateTime]
	, [Odometer]
	, [Lat]
	, [Long]
	, [Location]
	, [TwoUpInd]
	, [Note]
	, [Archived]
	, [LastOperation]
    FROM
	[dbo].[WKD_WorkDiaryTransition]
    WHERE 
	 ([WorkDiaryTransitionId] = @WorkDiaryTransitionId OR @WorkDiaryTransitionId IS NULL)
	AND ([WorkDiaryPageId] = @WorkDiaryPageId OR @WorkDiaryPageId IS NULL)
	AND ([VehicleIntId] = @VehicleIntId OR @VehicleIntId IS NULL)
	AND ([WorkStateTypeId] = @WorkStateTypeId OR @WorkStateTypeId IS NULL)
	AND ([TransitionDateTime] = @TransitionDateTime OR @TransitionDateTime IS NULL)
	AND ([Odometer] = @Odometer OR @Odometer IS NULL)
	AND ([Lat] = @Lat OR @Lat IS NULL)
	AND ([Long] = @SafeNameLong OR @SafeNameLong IS NULL)
	AND ([Location] = @Location OR @Location IS NULL)
	AND ([TwoUpInd] = @TwoUpInd OR @TwoUpInd IS NULL)
	AND ([Note] = @Note OR @Note IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND ([LastOperation] = @LastOperation OR @LastOperation IS NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [WorkDiaryTransitionId]
	, [WorkDiaryPageId]
	, [VehicleIntId]
	, [WorkStateTypeId]
	, [TransitionDateTime]
	, [Odometer]
	, [Lat]
	, [Long]
	, [Location]
	, [TwoUpInd]
	, [Note]
	, [Archived]
	, [LastOperation]
    FROM
	[dbo].[WKD_WorkDiaryTransition]
    WHERE 
	 ([WorkDiaryTransitionId] = @WorkDiaryTransitionId AND @WorkDiaryTransitionId is not null)
	OR ([WorkDiaryPageId] = @WorkDiaryPageId AND @WorkDiaryPageId is not null)
	OR ([VehicleIntId] = @VehicleIntId AND @VehicleIntId is not null)
	OR ([WorkStateTypeId] = @WorkStateTypeId AND @WorkStateTypeId is not null)
	OR ([TransitionDateTime] = @TransitionDateTime AND @TransitionDateTime is not null)
	OR ([Odometer] = @Odometer AND @Odometer is not null)
	OR ([Lat] = @Lat AND @Lat is not null)
	OR ([Long] = @SafeNameLong AND @SafeNameLong is not null)
	OR ([Location] = @Location AND @Location is not null)
	OR ([TwoUpInd] = @TwoUpInd AND @TwoUpInd is not null)
	OR ([Note] = @Note AND @Note is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	OR ([LastOperation] = @LastOperation AND @LastOperation is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				


GO
