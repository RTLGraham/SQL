SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[cuf_Driver_GetCustomerVehicles]
(
	@did UNIQUEIDENTIFIER
)
AS

	--DECLARE @did UNIQUEIDENTIFIER
	--SET @did = N'303D4050-1DB6-4D10-888E-9FC19AB42622'


	SELECT	v.VehicleId, v.VehicleIntId, v.Registration, v.VehicleTypeID,
			vDriver.DriverId, vDriver.DriverIntId, vDriver.FirstName, vDriver.Surname
	FROM dbo.Vehicle v
		LEFT JOIN dbo.VehicleDriver vd ON vd.VehicleId = v.VehicleId AND vd.Archived = 0
		LEFT JOIN dbo.Driver vDriver ON vDriver.DriverId = vd.DriverId
		INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
		INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
		INNER JOIN dbo.CustomerDriver cd ON cd.CustomerId = c.CustomerId
		INNER JOIN dbo.Driver d ON d.DriverId = cd.DriverId
	WHERE d.DriverId = @did
		AND d.Archived = 0 AND v.Archived = 0
		AND cd.Archived = 0 AND (cd.EndDate IS NULL OR cd.EndDate > GETDATE())
		AND cv.Archived = 0 AND (cv.EndDate IS NULL OR cv.EndDate > GETDATE())
	ORDER BY v.Registration


GO
