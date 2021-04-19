SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

---- =============================================
---- Author:	  <Dmitrijs Jurins>
---- Create date: <2015-05-08 11:29>
---- Description: <Core of speeding post-processing job to be called from RTL.DataDispatcher>
---- =============================================
CREATE PROCEDURE [dbo].[proc_PopulateSpeeding_DataDispatcher]
	@sdate DATETIME,
	@edate DATETIME
AS

	SET NOCOUNT ON;

    DECLARE @Lat FLOAT,
			@Lon FLOAT,
			@Speed SMALLINT,
			@MaxSpeed SMALLINT,
			@EventId BIGINT,
			@SpeedLimit INT,
			@StreetName NVARCHAR(400),
			@CustomerIntId INT,
			@CustomerId UNIQUEIDENTIFIER,
			@Heading SMALLINT,
			@count INT,
			@VehicleType INT,
			@GeoName NVARCHAR(1024),
			@speedunitdefault CHAR(1)

	-- Determine the default value of the speed unit for this database	
	SELECT @speedunitdefault = Value
	FROM dbo.DBConfig
	WHERE NameID = 9001

	UPDATE dbo.EventSpeeding
	SET ProcessInd = 1
	WHERE ProcessInd IS NULL
		
	/* Additional Check for Speeding in a Geofence */
	DECLARE Event_cursor CURSOR FAST_FORWARD FOR
		SELECT et.Lat, et.Lon, et.EventId, c.CustomerId, et.StreetName, e.Speed
		FROM dbo.EventSpeeding et
			INNER JOIN dbo.Event e ON et.EventId = e.EventId
			INNER JOIN dbo.Customer c ON e.CustomerIntId = c.CustomerIntId
		WHERE e.CustomerIntId IN (SELECT CustomerIntId FROM dbo.CustomerGeofenceSpeeding)
		  AND et.ProcessInd = 1
	
	OPEN Event_cursor
	FETCH NEXT FROM Event_cursor INTO @Lat, @Lon, @EventId, @CustomerId, @StreetName, @Speed
	WHILE @@fetch_status = 0
	BEGIN
		-- Initialise variables
		SET @SpeedLimit = NULL
		SET @GeoName = NULL

		SELECT TOP 1 @SpeedLimit = g.SpeedLimit, @GeoName = g.Name
		FROM dbo.Geofence g --WITH(INDEX(SIndx_Geofence_thegeom))
		INNER JOIN dbo.[User] u ON g.CreationUserId = u.UserID
		WHERE g.Archived = 0
		AND g.SpeedLimit is not NULL
		AND @Speed > g.SpeedLimit
		AND u.CustomerID = @CustomerId
		AND geometry::Point(@Lon, @Lat, 4326).STWithin(the_geom) = 1

		IF ISNULL(@SpeedLimit, 0) > 0
		BEGIN
			UPDATE dbo.EventSpeeding
			SET StreetName = @GeoName + CASE WHEN @StreetName IS NOT NULL THEN ', ' + @StreetName ELSE '' END, SpeedLimit = @SpeedLimit	
			WHERE EventId = @EventId
		END 	
		FETCH NEXT FROM Event_cursor INTO @Lat, @Lon, @EventId, @CustomerId, @StreetName, @Speed
		
	END 
	CLOSE Event_cursor
	DEALLOCATE Event_cursor		
	
	/* Update Event data in one go */
	--UPDATE dbo.Event
	--SET dbo.Event.SpeedLimit = Event_processed.SpeedLimit
	--FROM dbo.EventSpeeding Event_processed
	--WHERE   dbo.Event.EventId = Event_processed.EventId
	--	AND Event_processed.SpeedLimit IS NOT NULL
		
	/* Write Speeding events to TAN */
	INSERT INTO dbo.TAN_TriggerEvent (TriggerEventId, CreationCodeId, EventId, CustomerIntId, VehicleIntID, DriverIntId, ApplicationId, Long, Lat, Heading, Speed, TriggerDateTime, ProcessInd)
	  SELECT  NEWID(), 129, e.EventId, e.CustomerIntId, e.VehicleIntId, e.DriverIntId, 4, e.Long, e.Lat, e.Heading, e.Speed, e.EventDateTime, 0
	  FROM dbo.EventSpeeding et
	  INNER JOIN dbo.Event e WITH (NOLOCK) ON et.EventId = e.EventId
	  INNER JOIN dbo.Customer c ON e.CustomerIntId = c.CustomerIntId
	  WHERE et.SpeedLimit BETWEEN 1 AND 240 AND et.SpeedLimit IS NOT NULL
		AND ((e.Speed * 100) / dbo.ZeroYieldNull(ISNULL(e.SpeedLimit, et.SpeedLimit) / CASE WHEN ISNULL(et.SpeedUnit, @speedunitdefault) = 'M' THEN 0.6214 ELSE 1 END)) - 100 > ISNULL(c.OverSpeedPercent, 0)
		AND ROUND(e.Speed, 0, 1) > (ISNULL(e.SpeedLimit, et.SpeedLimit) / CASE WHEN ISNULL(et.SpeedUnit, @speedunitdefault) = 'M' THEN 0.6214 ELSE 1 END) + ISNULL(c.OverSpeedValue, 0)
		AND et.ProcessInd = 1

	/* Write a log entry */
	SELECT @count = COUNT(*) FROM dbo.EventSpeeding	 WHERE ProcessInd = 1	
	INSERT INTO dbo.SpeedwiseLog ( ScanTimeStart, ScanTimeEnd , ScanTimeActual, EventCount, ExecutionTime)
	VALUES  ( @sdate, @edate, GETDATE(), @count, GETUTCDATE() - @edate )
	
	/* Update cache */
	--INSERT INTO dbo.RevGeocodeSpeeding (Long, Lat, StreetName)
	--SELECT Lon, Lat, StreetName
	--FROM dbo.EventSpeeding et
	--WHERE NOT EXISTS (SELECT 1 FROM dbo.RevGeocodeSpeeding rvs
	--				  WHERE rvs.Long = et.Lon AND rvs.Lat = et.Lat)
	--  AND et.StreetName ! = ''
	--  AND et.SpeedLimit BETWEEN 1 AND 240 AND et.SpeedLimit IS NOT NULL 
		
	UPDATE dbo.EventSpeeding
	SET ProcessInd = 2
	WHERE ProcessInd = 1

GO
