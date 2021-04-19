SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Indicator_GetEfficiencyColours]
(
		@vid UNIQUEIDENTIFIER,
		@date datetime = null,
        @SweetSpot float = null,
        @OverRevWithFuel float = null,
        @TopGear float = null,
        @Cruise float = null,
        @Idle float = null,
        @FuelEconomy float = null,
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
		dbo.[GYRColour](@Idle, 6, @depid) AS IdleColour,
		dbo.[GYRColour](@SweetSpot, 1, @depid) AS SweetSpotColour,
		dbo.[GYRColour](@OverRevWithFuel, 2, @depid) AS OverRevWithFuelColour,
		dbo.[GYRColour](@TopGear, 3, @depid) AS TopgearColour,
		dbo.[GYRColour](@Cruise, 4, @depid) AS CruiseColour,
		dbo.[GYRColour](@FuelEconomy, 16, @depid) AS KPLColour,
		dbo.[GYRColour](@Score, 14, @depid) AS EfficiencyColour
END

GO
