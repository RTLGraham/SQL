SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Vehicle_GetByRegistrationWithLocation]
(
	@Registration nvarchar(50)
)
AS
DECLARE @vehicleId uniqueidentifier
DECLARE @currentcustomerid int

DECLARE @vehIds TABLE (VehicleId uniqueidentifier, CustomerIntId int)
DECLARE @latlongs TABLE (VehicleId uniqueidentifier, Lat float, Long float, ReverseGeocode nvarchar(255), Direction float, Speed float, EventDateTime datetime, DriverId uniqueidentifier )

INSERT @vehIds
SELECT VehicleId, dbo.GetCustomerIntFromId(CustomerId)
FROM [dbo].[CustomerVehicle]
WHERE VehicleId IN (SELECT VehicleId
					FROM [dbo].[Vehicle]
					WHERE Registration LIKE '%' + @Registration + '%')
AND ((EndDate IS NULL) OR (EndDate > GetDate()))

DECLARE customer_cursor CURSOR STATIC FOR
	SELECT CustomerIntId, VehicleId FROM @vehIds

OPEN customer_cursor
FETCH NEXT FROM customer_cursor INTO @currentcustomerid, @vehicleId
WHILE @@FETCH_STATUS = 0
BEGIN
	INSERT INTO @latlongs (VehicleId, Lat, Long, ReverseGeocode, Direction, Speed, EventDateTime, DriverId)
	EXECUTE cuf_Vehicle_GetVehicleDetails @vehicleId
	
	FETCH NEXT FROM customer_cursor INTO @currentcustomerid, @vehicleId
END
CLOSE customer_cursor
DEALLOCATE customer_cursor

SELECT v.*
FROM [dbo].[Vehicle] v
WHERE VehicleId IN (SELECT VehicleId FROM @latlongs )

SELECT * FROM @latlongs

GO
