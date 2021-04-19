SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
---- =============================================
---- Author:	  <Dmitrijs Jurins>
---- Create date: <2011-01-24 11:29>
---- Updated:     <2012-08-30 incorporate processing to TAN>
---- Description: <Core of speeding post-processing job>
---- =============================================
CREATE PROCEDURE [dbo].[z_remove_proc_PopulateSpeeding]
AS

-- First of all check whether or not this process is still running
-- by trying to create a temprary table
SELECT MyVar = 5 INTO #Populate_Speeding

IF @@ERROR <> 0
BEGIN
	-- do nothing!
	SELECT 0
END ELSE

BEGIN
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
			@sdate datetime,
			@edate DATETIME,
			@count INT,
			@VehicleType INT,
			@GeoName NVARCHAR(1024)
			
	DECLARE @Event_table TABLE 
	(
		EventId BIGINT, 
		StreetName NVARCHAR(MAX),
		PostCode NVARCHAR(MAX),
		SpeedLimit TINYINT,
		Lat FLOAT, 
		Lon FLOAT, 
		FoundLat FLOAT,
		FoundLon FLOAT
	)
	
	/* Get scan start and end times */
	--SELECT TOP 1 @sdate = ScanTimeEnd FROM dbo.SpeedwiseLog ORDER BY ScanTimeEnd DESC
	--IF @sdate IS NULL 
	--BEGIN
	--	SET @sdate = DATEADD (minute , -1, GETUTCDATE()) 
	--END
	SET @sdate = DATEADD (mi, -60, GETUTCDATE()) 
	SET @edate = GETUTCDATE()
	
	INSERT INTO @Event_table EXECUTE [dbo].[clr_DDS_GetSpeedLimitsWithFullPostcodes] @sdate, @edate
	
	/* Additional Check for Speeding in a Geofence */
	DECLARE Event_cursor CURSOR FAST_FORWARD FOR
		SELECT et.Lat, et.Lon, et.EventId, c.CustomerId FROM @Event_table et
		INNER JOIN dbo.Event e ON et.EventId = e.EventId
		INNER JOIN dbo.Customer c ON e.CustomerIntId = c.CustomerIntId
		WHERE e.CustomerIntId IN (SELECT CustomerIntId FROM dbo.CustomerGeofenceSpeeding)
	
	OPEN Event_cursor
	FETCH NEXT FROM Event_cursor INTO @Lat, @Lon, @EventId, @CustomerId
	WHILE @@fetch_status = 0
	BEGIN
		EXEC [FLEETWISE6,1435].Repl_dbo.IsSpeedingInGeofence @Lat, @Lon, @CustomerId, @SpeedLimit OUTPUT, @GeoName OUTPUT
		IF ISNULL(@SpeedLimit, 0) > 0
		BEGIN
			SET @StreetName = @GeoName + ', ' + @StreetName
		END 	
		FETCH NEXT FROM Event_cursor INTO @Lat, @Lon, @EventId, @CustomerId
	END 
	CLOSE Event_cursor
	DEALLOCATE Event_cursor		
	
	/* Update Event data in one go */
	UPDATE dbo.Event
	SET dbo.Event.SpeedLimit = Event_processed.SpeedLimit
	FROM @Event_table Event_processed
	WHERE   dbo.Event.EventId = Event_processed.EventId
		
	/* Write Speeding events to TAN */
	INSERT INTO dbo.TAN_TriggerEvent (TriggerEventId, CreationCodeId, EventId, CustomerIntId, VehicleIntID, DriverIntId, ApplicationId, Long, Lat, Heading, Speed, TriggerDateTime, ProcessInd)
	  SELECT  NEWID(), 129, e.EventId, e.CustomerIntId, e.VehicleIntId, e.DriverIntId, 4, e.Long, e.Lat, e.Heading, e.Speed, e.EventDateTime, 0
	  FROM @Event_table et
	  INNER JOIN dbo.Event e ON et.EventId = e.EventId
	  INNER JOIN dbo.Customer c ON e.CustomerIntId = c.CustomerIntId
	  WHERE et.SpeedLimit BETWEEN 1 AND 240 AND et.SpeedLimit IS NOT NULL
		AND ((((e.Speed / dbo.GetDistanceMultiplierByLatLon(et.Lat, et.Lon)) * 100) / dbo.ZeroYieldNull(et.SpeedLimit)) - 100 > c.OverSpeedPercent
		OR ROUND(e.Speed / dbo.GetDistanceMultiplierByLatLon(et.Lat, et.Lon), 0, 1) > et.SpeedLimit + c.OverSpeedValue)

	/* Write a log entry */
	SELECT @count = COUNT(*) FROM @Event_table		
	INSERT INTO dbo.SpeedwiseLog ( ScanTimeStart, ScanTimeEnd , ScanTimeActual, EventCount, ExecutionTime)
	VALUES  ( @sdate, @edate, GETDATE(), @count, GETUTCDATE() - @edate )
	
	/* Update cache */
	INSERT INTO dbo.RevGeocodeSpeeding (Long, Lat, StreetName)
	SELECT Lon, Lat, StreetName
	FROM @Event_table et
	WHERE NOT EXISTS (SELECT 1 FROM dbo.RevGeocodeSpeeding rvs
					  WHERE rvs.Long = et.Lon AND rvs.Lat = et.Lat)
	  AND et.StreetName ! = ''
	  AND et.SpeedLimit BETWEEN 1 AND 240 AND et.SpeedLimit IS NOT NULL 
	
	-- Delete temporary table to indicate job has completed
	DROP TABLE #Populate_Speeding

END




GO
