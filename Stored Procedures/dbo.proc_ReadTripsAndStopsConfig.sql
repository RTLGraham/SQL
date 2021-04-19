SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_ReadTripsAndStopsConfig] @Vehicleid uniqueidentifier
AS

Declare @MinGap int
Declare @ExpiryDay int
Declare @KeyState int
Declare @MovingState int
Declare @LastKeyTime datetime
Declare @LastMovingTime datetime
Declare @LastKeyTotalDistance bigint
Declare @LastMovingTotalDistance bigint
Declare @PrevKeyID bigint
Declare @PrevMovingID bigint
Declare @LastPointTotalDistance bigint

SELECT TOP 1 @MinGap = MinGap, @ExpiryDay = ExpiryDay FROM TripsAndStopsConfig
WHERE (VehicleID = @vehicleid or VehicleID is null) AND (Archived = 0 or Archived is null)
Order by TripsAndStopsConfigID desc

SELECT @KeyState=KeyState, @MovingState=MovingState, @LastKeyTime=LastKeyTime, @LastMovingTime=LastMovingTime, 
@LastKeyTotalDistance=LastKeyTotalDistance, @LastMovingTotalDistance=LastMovingTotalDistance, 
@PrevKeyID=PrevKeyID, @PrevMovingID=PrevMovingID, @LastPointTotalDistance = isnull(LastPointTotalDistance, Case When isnull(LastKeyTotalDistance,0) >= isnull(LastMovingTotalDistance,0) then isnull(LastKeyTotalDistance,0) else isnull(LastMovingTotalDistance,0) END)
FROM TripsAndStopsState
WHERE VehicleID = @vehicleid AND (Archived = 0 or Archived is null)

Select @MinGap as MinGap, @ExpiryDay as ExpiryDay, @KeyState as KeyState, @MovingState as MovingState, @LastKeyTime as LastKeyTime, 
@LastMovingTime as LastMovingTime, @LastKeyTotalDistance as LastKeyTotalDistance, @LastMovingTotalDistance as LastMovingTotalDistance, 
@PrevKeyID as PrevKeyID, @PrevMovingID as PrevMovingID, @LastPointTotalDistance as LastPointTotalDistance

GO
