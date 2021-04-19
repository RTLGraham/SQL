SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [dbo].[cuf_Driver_GetByDigidownTfile_Aplicom]
	@cName NVARCHAR(MAX),
	@vehicleId UNIQUEIDENTIFIER,
	@timestamp DATETIME,
	@filename NVARCHAR(MAX),
	@minutesRange INT
AS
	--DECLARE @cName NVARCHAR(MAX),
	--		@vehicleId UNIQUEIDENTIFIER,
	--		@timestamp DATETIME,
	--		@filename NVARCHAR(MAX),
	--		@minutesRange INT
	----SELECT  @cName = 'Air Products Spain', 
	----		@vehicleId = N'417702da-ea3d-4802-98c8-c0a9dae4abd8',
	----		@timestamp = '2017-11-02 08:15:54',
	----		@filename = 'B3200855_472596ba.vu',
	----		@minutesRange = 1440
	--SELECT  @cName = 'Bert Logistics', 
	--		@vehicleId = N'a2c64475-5f36-4dd8-953d-183e88715540',
	--		@timestamp = '2018-12-14 15:33:54',
	--		@filename = 'F__EK-373-JQ    201812141527.V1B',
	--		@minutesRange = 144000
				
	SELECT TOP 1 v.Registration, d.DriverId, d.FirstName, d.Surname, d.Number, d.NumberAlternate, d.NumberAlternate2, e.EventDateTime, e.EventDataName, e.EventDataString
	FROM dbo.EventData e
		INNER JOIN dbo.Driver d ON d.DriverIntId = e.DriverIntId
		INNER JOIN dbo.Vehicle v ON v.VehicleIntId = e.VehicleIntId
		INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
		INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
    WHERE c.Name = @cName
		AND v.VehicleId = @vehicleId
		AND e.CreationCodeId = 104
		AND e.EventDataName = 'DIG'
		AND LTRIM(RTRIM(e.EventDataString)) LIKE 'UPLOAD SUCCESS%' + @filename
		AND e.EventDateTime BETWEEN DATEADD(MINUTE, @minutesRange * (-1), @timestamp) AND DATEADD(MINUTE, @minutesRange, @timestamp)
	ORDER BY e.EventId DESC

GO
