SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Indicator_GetSafetyColours]
(
		@vid UNIQUEIDENTIFIER,
		@date datetime = null,
		@EngineBrake float = null,
		@OverRevWithoutFuel float = null,
		@Overspeed float = null,
		@OutOfGear float = null,
		@Rop float = null,
		@HarshBraking float = null,
		@Score float = null
)
AS
BEGIN
	DECLARE @depid INT
	
	SELECT TOP 1 @depid = CustomerIntId
	FROM dbo.Customer c
		INNER JOIN dbo.CustomerVehicle cv ON c.CustomerId = cv.CustomerId
	WHERE VehicleId = @vid AND (EndDate IS NULL OR EndDate > GETDATE())

	SELECT	
		dbo.[GYRColour](@Score, 15, @depid) AS SafetyColour,
		dbo.[GYRColour](@EngineBrake, 7, @depid) AS EngineServiceBrakeColour,
		dbo.[GYRColour](@OverRevWithoutFuel, 8, @depid) AS OverRevWithoutFuelColour,
		dbo.[GYRColour](@Rop, 9, @depid) AS RopColour,
		dbo.[GYRColour](@OverSpeed, 10, @depid) AS TimeOverSpeedColour,
		dbo.[GYRColour](@OutOfGear, 11, @depid) AS TimeOutOfGearCoastingColour,
		dbo.[GYRColour](@HarshBraking, 12, @depid) AS HarshBrakingColour
END

GO
