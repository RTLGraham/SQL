SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_PopulateTemperatureHistogram]
(
	@date DATETIME = NULL,
	@sensorid TINYINT
)
AS

--DECLARE @date DATETIME,
--		@sensorid TINYINT
	
--SET @date = '2019-08-05'
--SET @sensorid = 4

DECLARE @lsdate DATETIME,
		@ledate DATETIME,
		@gid UNIQUEIDENTIFIER

-- If a date is provided script will run for that whole day. If no date provided script will run for whole of yesterday
IF @date IS NULL SET @date = CAST(FLOOR(CAST(DATEADD(dd, -1, GETDATE()) AS FLOAT)) AS DATETIME)	
SET @lsdate = CAST(FLOOR(CAST(@date AS FLOAT)) AS DATETIME)
SET @ledate = DATEADD(ss, -1, CAST(FLOOR(CAST(@date AS FLOAT)) + 1 AS DATETIME))

DECLARE @tempmult FLOAT,
		@analogscaling FLOAT,
		@totalsecs FLOAT,
		@vintid INT,
		@eventid BIGINT	


-- Hardcoded values for this report only
SET @analogscaling = 0.00390625
SET @tempmult = 1 -- Use centigrade scale
SET @totalsecs = DATEDIFF(ss, @lsdate, @ledate)

CREATE TABLE #Event (EventId BIGINT, EventDateTime DATETIME, VehicleIntId INT, Temperature FLOAT, Duration BIGINT, InGeofence BIT)
CREATE NONCLUSTERED INDEX #Event_Vehicle ON #Event
(
	[VehicleIntId] ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

-- Populate the temporary event table with just the necessary data, but calculate duration from previous event to current event in seconds
INSERT INTO #Event (EventId, EventDateTime, VehicleIntId, Temperature, Duration, InGeofence)
SELECT ecurr.EventId, ecurr.EventDateTime, ecurr.VehicleIntId, dbo.ScaleConvertAnalogValue(ecurr.AnalogData, @AnalogScaling, @tempmult, NULL), 
		DATEDIFF(ss, ISNULL(eprev.EventDateTime, @lsdate), ecurr.EventDateTime), CASE WHEN geo.GeofenceId IS NULL THEN 0 ELSE 1 END AS InGeofence
FROM (SELECT e.EventId, e.VehicleIntId, e.EventDateTime,
		CASE @sensorid WHEN 1 THEN e.AnalogData0 WHEN 2 THEN e.AnalogData1 WHEN 3 THEN e.AnalogData2 WHEN 4 THEN e.AnalogData3 END AS AnalogData, 
		ROW_NUMBER() OVER (PARTITION BY e.VehicleIntId ORDER BY e.EventDateTime) AS RowNum
	  FROM dbo.Event e WITH (NOLOCK, INDEX (IX_Event_EventDateTime))
	  WHERE   e.EventDateTime BETWEEN @lsdate AND @ledate
		AND e.CreationCodeId IS NOT NULL
		AND e.CreationCodeId NOT IN (24, 91)
		AND (e.Lat != 0 AND e.Long != 0)
	  ) ecurr
	  LEFT JOIN (SELECT e.EventId, e.VehicleIntId, e.EventDateTime, ROW_NUMBER() OVER (PARTITION BY e.VehicleIntId ORDER BY e.EventDateTime) AS RowNum
			FROM dbo.Event e WITH (NOLOCK, INDEX (IX_Event_EventDateTime))
			WHERE   e.EventDateTime BETWEEN @lsdate AND @ledate
			  AND e.CreationCodeId IS NOT NULL
			  AND e.CreationCodeId NOT IN (24, 91)
			  AND (e.Lat != 0 AND e.Long != 0)
			) eprev ON eprev.VehicleIntId = ecurr.VehicleIntId AND eprev.RowNum = ecurr.RowNum - 1
LEFT JOIN (
	SELECT vgh.GeofenceId, vgh.VehicleIntId, vgh.EntryDateTime, vgh.ExitDateTime
	FROM dbo.VehicleGeofenceHistory vgh
	INNER JOIN dbo.Geofence g ON g.GeofenceId = vgh.GeofenceId AND g.IsTemperatureMonitored = 1) geo ON geo.VehicleIntId = ecurr.VehicleIntId AND ecurr.EventDateTime BETWEEN geo.EntryDateTime AND geo.ExitDateTime
LEFT JOIN dbo.TAN_EntityCheckOut t ON ecurr.VehicleIntId = dbo.GetVehicleIntFromId(t.EntityId) AND ecurr.EventDateTime BETWEEN t.CheckOutDateTime AND t.CheckInDateTime
WHERE t.EntityCheckOutId IS NULL -- Vehicle is not checked out


-- Need to update the final row for each vehicle to account for the time from the last event of the day to midnight
-- use a cursor for this

DECLARE Evt_Cur CURSOR FAST_FORWARD 
FOR
SELECT VehicleIntId, MAX(EventId)
FROM #Event
GROUP BY VehicleIntId

OPEN Evt_Cur
FETCH NEXT FROM Evt_Cur INTO @vintid, @eventid

WHILE @@FETCH_STATUS = 0
BEGIN

	UPDATE #Event
	SET Duration = Duration + DATEDIFF(ss, EventDateTime, @ledate)
	WHERE EventId = @eventid

	FETCH NEXT FROM Evt_Cur INTO @vintid, @eventid

END

CLOSE Evt_Cur
DEALLOCATE Evt_Cur

-- Delete any data already existing for the day and sensor
DELETE
FROM dbo.TemperatureHistogram
WHERE Date = @date
  AND SensorId = @sensorid

-- Now select data from temporary Event table in cube format to insert into TemperatureHistogram table
INSERT INTO dbo.TemperatureHistogram (Date, VehicleIntId, SensorId, BucketId, InGeofence, Duration)
SELECT	@lsdate AS Date,
		cuberesult.VehicleIntId,
		@sensorid AS SensorId,
		cuberesult.BucketId,
		cuberesult.InGeofence,
		cuberesult.Duration
FROM
(	SELECT  
			CASE WHEN (GROUPING(e.VehicleIntId) = 1) THEN NULL
				ELSE ISNULL(e.VehicleIntId, NULL)
			END AS VehicleIntId,

			CASE WHEN (GROUPING(e.InGeofence) = 1) THEN NULL
				ELSE ISNULL(e.InGeofence, NULL)
			END AS InGeofence,

			h.BucketId,
			SUM(e.Duration) AS Duration

	FROM    #Event e
	INNER JOIN dbo.TemperatureHistogramScale h ON e.Temperature > h.TempLow AND e.Temperature <= h.TempHigh AND h.SensorId = @sensorid
	
	GROUP BY e.vehicleIntId, e.InGeofence, h.BucketId WITH CUBE
) cuberesult
INNER JOIN dbo.TemperatureHistogramScale h ON cuberesult.BucketId = h.BucketId AND h.SensorId = @sensorid
WHERE cuberesult.VehicleIntId IS NOT NULL AND cuberesult.InGeofence IS NOT NULL	
ORDER BY cuberesult.vehicleIntId, h.TempLow	

DROP TABLE #Event


GO
