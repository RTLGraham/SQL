SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Driver_GetByVehicleIdAndTime]
	@cName NVARCHAR(MAX),
	@vehicleId UNIQUEIDENTIFIER,
	@timestamp DATETIME
AS
	--DECLARE @cName NVARCHAR(MAX),
	--		@vehicleId UNIQUEIDENTIFIER,
	--		@timestamp DATETIME
	--SELECT  @cName = 'Hoyer', 
	--		@vehicleId = N'AC476CC8-4BC4-44D6-8E54-3ECD1E6497CE',
	--		@timestamp = '2016-10-28 11:28:55'
	
	DECLARE @minutesRange INT
	SET @minutesRange =180

	SELECT TOP 1 e.EventId, v.Registration, d.FirstName, d.Surname, d.Number, d.NumberAlternate, d.NumberAlternate2, e.EventDateTime
	FROM dbo.Event e
		INNER JOIN dbo.Driver d ON d.DriverIntId = e.DriverIntId
		INNER JOIN dbo.Vehicle v ON v.VehicleIntId = e.VehicleIntId
		INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
		INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
    WHERE c.Name = @cName
		AND v.VehicleId = @vehicleId
		AND e.CreationCodeId = 61
		AND e.EventDateTime BETWEEN DATEADD(MINUTE, @minutesRange * (-1), @timestamp) AND DATEADD(MINUTE, @minutesRange, @timestamp)
	ORDER BY e.EventId DESC
    

GO
