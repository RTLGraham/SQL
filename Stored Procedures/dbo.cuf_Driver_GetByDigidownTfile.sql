SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[cuf_Driver_GetByDigidownTfile]
	@cName NVARCHAR(MAX),
	@vehicleId UNIQUEIDENTIFIER,
	@timestamp DATETIME,
	@filename NVARCHAR(MAX)
AS
	--DECLARE @cName NVARCHAR(MAX),
	--		@vehicleId UNIQUEIDENTIFIER,
	--		@timestamp DATETIME,
	--		@filename NVARCHAR(MAX)
	--SELECT  @cName = 'Air Products Spain', 
	--		@vehicleId = N'417702da-ea3d-4802-98c8-c0a9dae4abd8',
	--		@timestamp = '2017-11-02 08:15:54',
	--		@filename = 'B3200855_472596ba.vu'

	DECLARE @minutesRange INT
	SET @minutesRange = 60

	DECLARE @eid BIGINT
	SELECT TOP 1 @eid = e.EventDataId
	FROM dbo.EventData e
		INNER JOIN dbo.Vehicle v ON v.VehicleIntId = e.VehicleIntId
		INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
		INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
    WHERE c.Name = @cName
		AND v.VehicleId = @vehicleId
		AND e.CreationCodeId = 104
		AND e.EventDataName = 'FTP'
		AND RTRIM(e.EventDataString) LIKE '%' + @filename + '%OK%'
		AND e.EventDateTime BETWEEN DATEADD(MINUTE, @minutesRange * (-1), @timestamp) AND DATEADD(MINUTE, @minutesRange, @timestamp)
	ORDER BY e.EventId DESC
	
	SELECT TOP 1 v.Registration, d.DriverId, d.FirstName, d.Surname, d.Number, d.NumberAlternate, d.NumberAlternate2, e.EventDateTime, e.EventDataName, e.EventDataString
	FROM dbo.EventData e
		INNER JOIN dbo.Driver d ON d.DriverIntId = e.DriverIntId
		INNER JOIN dbo.Vehicle v ON v.VehicleIntId = e.VehicleIntId
		INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
		INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
    WHERE e.EventDataId < @eid
		AND e.CreationCodeId = 160
		AND v.VehicleId = @vehicleId
		AND e.EventDataName = 'DIG'
		AND e.EventDataString LIKE '%DDD%'
		AND e.EventDateTime BETWEEN DATEADD(MINUTE, @minutesRange * (-1), @timestamp) AND DATEADD(MINUTE, @minutesRange, @timestamp) 
	ORDER BY e.EventId DESC
    
	
GO
