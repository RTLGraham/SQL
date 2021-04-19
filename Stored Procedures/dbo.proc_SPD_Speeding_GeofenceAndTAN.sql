SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

---- =============================================
---- Author:	  Graham Pattison
---- Create date: 2021-01-15
---- Description: Receives data from external speed check and carries out final additional check against geofences
----			  Inserts speeding data events into TAN and Mobile Notification tables for potential notification
---- =============================================
CREATE PROCEDURE [dbo].[proc_SPD_Speeding_GeofenceAndTAN]
AS

	DECLARE @speedunitdefault CHAR(1)
	SELECT @speedunitdefault = Value
	FROM dbo.DBConfig
	WHERE NameID = 9001

	-- Mark rows to be processed
	UPDATE dbo.EventSpeedingTransition
	SET ProcessInd = 1
	WHERE ProcessInd IS NULL

	-- Create temporary table to hold data for ONLY Speed Defined Geofences (speed limit > 0)
	DECLARE @Geofence TABLE	
	(
		CustomerIntId INT,
		GeofenceId UNIQUEIDENTIFIER,
		Name NVARCHAR(1024),
		the_geom GEOMETRY,
		SpeedLimit INT
	)

	INSERT INTO @Geofence (CustomerIntId, GeofenceId, Name, the_geom, SpeedLimit)
	SELECT c.CustomerIntId, g.GeofenceId, g.Name, g.the_geom, g.SpeedLimit
	FROM dbo.Customer c 
	INNER JOIN dbo.[User] u ON u.CustomerID = c.CustomerId
	INNER JOIN dbo.Geofence g ON g.CreationUserId = u.UserID
	WHERE g.Archived = 0
	  AND ISNULL(g.SpeedLimit, 0) > 0

	-- Create temporary data table to hold Speeding Data
	DECLARE @Speeding TABLE
    (
		EventId BIGINT,
		CustomerIntId INT,
		VehicleIntId INT,
		DriverIntId INT,
		Long FLOAT,
		Lat FLOAT,
		Heading SMALLINT,
		Speed SMALLINT,
		SpeedUnit CHAR(1),
		SpeedLimit SMALLINT,
		Location NVARCHAR(1024),
		GeofenceId UNIQUEIDENTIFIER,
		EventDateTime DATETIME
	)	

	-- Insert data where speeding in a geofence
	INSERT INTO @Speeding (EventId, CustomerIntId, VehicleIntId, DriverIntId, Long, Lat, Heading, Speed, SpeedUnit, SpeedLimit, Location, GeofenceId, EventDateTime)
	SELECT es.EventId, es.CustomerIntId, es.VehicleIntId, es.DriverIntId, es.Lon, es.Lat, es.Heading, es.Speed, es.SpeedUnit, g2.SpeedLimit, g2.Name, g2.GeofenceId, es.EventDateTime
	FROM dbo.EventSpeedingTransition es WITH (NOLOCK)
	--INNER JOIN dbo.Event e WITH (NOLOCK) ON e.EventId = es.EventId
	INNER JOIN @Geofence g2 ON g2.CustomerIntId = es.CustomerIntId
	WHERE es.ProcessInd = 1
	  AND es.Speed > g2.SpeedLimit
	  AND geometry::Point(es.Lon, es.Lat, 4326).STWithin(the_geom) = 1

	-- Now update the StreetName and SpeedLimit in EventSpeedingTransition for these rows
	UPDATE dbo.EventSpeedingTransition
	SET StreetName = s.Location + CASE WHEN StreetName IS NOT NULL THEN ', ' + StreetName ELSE '' END, SpeedLimit = s.SpeedLimit	
	FROM dbo.EventSpeedingTransition es
	INNER JOIN @Speeding s ON s.EventId = es.EventId

	-- Now add ordinary speeding events to the temporary table
	INSERT INTO @Speeding (EventId, CustomerIntId, VehicleIntId, DriverIntId, Long, Lat, Heading, Speed, SpeedUnit, SpeedLimit, Location, GeofenceId, EventDateTime)
	SELECT et.EventId, et.CustomerIntId, et.VehicleIntId, et.DriverIntId, et.Lon, et.Lat, et.Heading, et.Speed, et.SpeedUnit, et.SpeedLimit, et.StreetName, NULL, et.EventDateTime
	FROM dbo.EventSpeedingTransition et
	LEFT JOIN @Speeding s ON s.EventId = et.EventId
	INNER JOIN dbo.Customer c ON et.CustomerIntId = c.CustomerIntId
	WHERE et.SpeedLimit BETWEEN 1 AND 240 AND et.SpeedLimit IS NOT NULL
	  AND et.Speed < 254
	  AND ((et.Speed * 100) / dbo.ZeroYieldNull(et.SpeedLimit / CASE WHEN ISNULL(et.SpeedUnit, @speedunitdefault) = 'M' THEN 0.6214 ELSE 1 END)) - 100 > ISNULL(c.OverSpeedPercent, 0)
	  AND ROUND(et.Speed, 0, 1) > (et.SpeedLimit / CASE WHEN ISNULL(et.SpeedUnit, @speedunitdefault) = 'M' THEN 0.6214 ELSE 1 END) + ISNULL(c.OverSpeedValue, 0)
	  AND et.ProcessInd = 1
	  AND s.EventId IS NULL -- don't insert if already present

	-- Write Speeding events to TAN from @Speeding table
	INSERT INTO dbo.TAN_TriggerEvent (TriggerEventId, CreationCodeId, EventId, CustomerIntId, VehicleIntID, DriverIntId, ApplicationId, Long, Lat, Heading, Speed, TriggerDateTime, ProcessInd, GeofenceId)
	SELECT  NEWID(), 129, s.EventId, s.CustomerIntId, s.VehicleIntId, s.DriverIntId, 4, s.Long, s.Lat, s.Heading, s.Speed, s.EventDateTime, 0, s.GeofenceId
	FROM @Speeding s
	INNER JOIN dbo.Customer c ON c.CustomerIntId = s.CustomerIntId
	WHERE s.SpeedLimit BETWEEN 1 AND 240 AND s.SpeedLimit IS NOT NULL
	  AND s.Speed < 254
	  AND ((s.Speed * 100) / dbo.ZeroYieldNull(s.SpeedLimit / CASE WHEN ISNULL(s.SpeedUnit, @speedunitdefault) = 'M' THEN 0.6214 ELSE 1 END)) - 100 > ISNULL(c.OverSpeedPercent, 0)
	  AND ROUND(s.Speed, 0, 1) > (s.SpeedLimit / CASE WHEN ISNULL(s.SpeedUnit, @speedunitdefault) = 'M' THEN 0.6214 ELSE 1 END) + ISNULL(c.OverSpeedValue, 0)

	  	  --Write High Speeding events to TAN from @Speeding table
	INSERT INTO dbo.TAN_TriggerEvent (TriggerEventId, CreationCodeId, EventId, CustomerIntId, VehicleIntID, DriverIntId, ApplicationId, Long, Lat, Heading, Speed, TriggerDateTime, ProcessInd, GeofenceId)
	SELECT  NEWID(), 147, s.EventId, s.CustomerIntId, s.VehicleIntId, s.DriverIntId, 4, s.Long, s.Lat, s.Heading, s.Speed, s.EventDateTime, 0, s.GeofenceId
	FROM @Speeding s
	INNER JOIN dbo.Customer c ON c.CustomerIntId = s.CustomerIntId
	WHERE s.Speed < 250
		AND s.SpeedLimit < 250
		AND ((s.Speed * 100) / dbo.ZeroYieldNull(s.SpeedLimit / CASE WHEN ISNULL(s.SpeedUnit, @speedunitdefault) = 'M' THEN 0.6214 ELSE 1 END)) - 100 > ISNULL(c.OverSpeedHighPercent, 0)
		AND ROUND(s.Speed, 0, 1) > (s.SpeedLimit / CASE WHEN ISNULL(s.SpeedUnit, @speedunitdefault) = 'M' THEN 0.6214 ELSE 1 END) + ISNULL(c.OverSpeedHighValue, 0)

	-- Transfer rows that are actually speeding into the EventSpeeding table
	INSERT INTO dbo.EventSpeeding (EventId, StreetName, PostCode, SpeedLimit, Lat, Lon, FoundLat, FoundLon, ProcessInd, SpeedingDistance, SpeedingHighDistance, ChallengeInd, PostedSpeedLimit, VehicleSpeedLimit, SpeedUnit, SpeedingDisputeTypeId, VehicleIntId, DriverIntId, CustomerIntId, EventDateTime, Speed, Heading, CreationCodeId)
	SELECT EventId, StreetName, PostCode, SpeedLimit, Lat, Lon, FoundLat, FoundLon, 2, SpeedingDistance, SpeedingHighDistance, ChallengeInd, PostedSpeedLimit, VehicleSpeedLimit, SpeedUnit, SpeedingDisputeTypeId, VehicleIntId, DriverIntId, CustomerIntId, EventDateTime, Speed, Heading, CreationCodeId
	FROM dbo.EventSpeedingTransition
	WHERE SpeedLimit BETWEEN 1 AND 249
	  AND Speed < 254
	AND ProcessInd = 1

	-- Clean up the table now processing has finished
	DELETE
	FROM dbo.EventSpeedingTransition
	WHERE ProcessInd = 1


GO
