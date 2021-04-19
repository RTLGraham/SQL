SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[proc_DataDispatcher_GetGPS]
	@customer NVARCHAR(MAX),
	@option SMALLINT,
	@seconds INT
AS

--DECLARE @customer NVARCHAR(MAX),
--		@option SMALLINT,
--		@seconds INT
--SET @customer = 'BP'
--SET @option = 1
--SET @seconds = 9999

SET @option = ISNULL(@option, 2)

IF @option = 2
BEGIN
	--BP Oilpac, should work for all vehicles, unless any are excluded
	SELECT	v.FleetNumber AS TruckId, 
			vle.EventDateTime,
			vle.Lat, 
			vle.Long AS Lon, 
			e.Altitude,
			16 AS GeoQuality, --16 = averaged
			e.GPSSatelliteCount,
			0 AS HdopError, -- unknown
			--0 AS TimeDiff -- not used if EventDateTime is in UTC
			--DATEDIFF(SECOND, dbo.[TZ_GetTime](vle.EventDateTime, 'GMT Time', NULL), vle.EventDateTime) AS TimeDiff,
			DATEDIFF(SECOND, vle.EventDateTime, dbo.[TZ_GetTime](vle.EventDateTime, 'GMT Time', NULL)) AS TimeDiff,
			vle.Speed,
			vle.Heading
	FROM dbo.VehicleLatestAllEvent vle
		INNER JOIN dbo.Event e WITH (NOLOCK) ON vle.EventId = e.EventId
		INNER JOIN dbo.Vehicle v ON vle.VehicleId = v.VehicleId
		INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
		INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
	WHERE v.Archived = 0
	  AND v.FleetNumber IS NOT NULL
	  AND v.FleetNumber != ''
	  AND v.IVHId IS NOT NULL
	  AND cv.Archived = 0
	  AND cv.EndDate IS NULL
	  AND c.Name = @customer
	  AND DATEDIFF(ss, e.LastOperation, GETDATE()) < @seconds
	 ORDER BY v.FleetNumber, vle.EventDateTime
END

IF @option = 3
BEGIN
	--Hoyer Oilpac, should work for some vehicles, unless fully migrated
	SELECT	v.FleetNumber AS TruckId, 
			vle.EventDateTime,
			vle.Lat, 
			vle.Long AS Lon, 
			e.Altitude,
			16 AS GeoQuality, --16 = averaged
			e.GPSSatelliteCount,
			0 AS HdopError, -- unknown
			--0 AS TimeDiff -- not used if EventDateTime is in UTC
			--DATEDIFF(SECOND, dbo.[TZ_GetTime](vle.EventDateTime, 'GMT Time', NULL), vle.EventDateTime) AS TimeDiff,
			DATEDIFF(SECOND, vle.EventDateTime, dbo.[TZ_GetTime](vle.EventDateTime, 'GMT Time', NULL)) AS TimeDiff,
			vle.Speed,
			vle.Heading
	FROM dbo.VehicleLatestAllEvent vle
		INNER JOIN dbo.Rubicon_TrucksVehicles t ON t.VehicleId = vle.VehicleId
		INNER JOIN dbo.Event e WITH (NOLOCK) ON vle.EventId = e.EventId
		INNER JOIN dbo.Vehicle v ON vle.VehicleId = v.VehicleId
		INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
		INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
	WHERE v.Archived = 0
	  AND v.FleetNumber IS NOT NULL
	  AND v.FleetNumber != ''
	  AND v.IVHId IS NOT NULL
	  AND cv.Archived = 0
	  AND cv.EndDate IS NULL
	  AND c.Name = @customer
	  AND DATEDIFF(ss, e.LastOperation, GETDATE()) < @seconds
	 ORDER BY v.FleetNumber, vle.EventDateTime
END

GO
