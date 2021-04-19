SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Vehicle_GetTDFC]
(
	@vehicleId UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME
)
AS

SELECT
	Sum(DrivingTime + PTOMovingTime) AS [Time],
	Sum(DrivingDistance + PTOMovingDistance) AS Distance,
	Sum(DrivingFuel + PTOMovingFuel) AS Fuel,
	0 as Cost
FROM
	[dbo].[Accum]
WHERE VehicleIntId = dbo.GetVehicleIntFromId(@vehicleid)
  AND CreationDateTime BETWEEN @sdate AND @edate


GO
