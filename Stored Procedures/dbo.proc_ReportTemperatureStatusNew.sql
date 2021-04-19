SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportTemperatureStatusNew]
    (
	  @gids VARCHAR(MAX),
      @vids VARCHAR(MAX),
      @uid UNIQUEIDENTIFIER,
      @isChecked INT,
      @sdate DATETIME,
	  @edate DATETIME,
	  @isAlert01 BIT,
	  @isAlert02 BIT,
	  @isAlert03 BIT,
	  @isAlert04 BIT
    )
AS 
--DECLARE	@gids VARCHAR(MAX),
--		@vids VARCHAR(MAX),
--		@uid UNIQUEIDENTIFIER,
--		@isChecked INT,
--		@sdate DATETIME,
--		@edate DATETIME,
--		@isAlert01 BIT,
--		@isAlert02 BIT,
--		@isAlert03 BIT,
--		@isAlert04 BIT

----SET @gids = N'EA6FF8F6-F6EA-4632-9607-7B0A8A8A8DDB,7F46B04D-0C7D-4FDF-81DC-C15243BE6AD1'--,A4CA2CD5-2FCC-4B9A-8386-D69AF1B9DF15,D6FDE2B3-9BD7-4F85-83E0-FA6B25553C85'
--SET @gids = N'EA6FF8F6-F6EA-4632-9607-7B0A8A8A8DDB'
--SET @vids = N'87A3B70E-9B8D-42CB-BB13-2E1C9427331C'
--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
--SET @isChecked = 0
--SET @isAlert01 = 1
--SET @isAlert02 = 1
--SET @isAlert03 = 1
--SET @isAlert04 = 1
--SET @sdate = '2018-02-27 00:00'
--SET @edate = '2018-03-02 23:59'

DECLARE	@lgids VARCHAR(MAX),
		@lvids VARCHAR(MAX),
		@luid UNIQUEIDENTIFIER,
		@lisChecked INT,
		@lsdate DATETIME,
		@ledate DATETIME,
		@lisAlert01 BIT,
		@lisAlert02 BIT,
		@lisAlert03 BIT,
		@lisAlert04 BIT

SET @lgids = @gids
SET @lvids = @vids
SET @luid = @uid
SET @lisChecked = @isChecked
SET @lsdate = @sdate
SET @ledate = @edate
SET @lisAlert01 = @isAlert01
SET @lisAlert02 = @isAlert02
SET @lisAlert03 = @isAlert03
SET @lisAlert04 = @isAlert04

    DECLARE @stime DATETIME,
			@etime DATETIME

	SET @lsdate = dbo.TZ_ToUtc(@lsdate,DEFAULT,@luid) 
	SET @ledate = dbo.TZ_ToUtc(@ledate,DEFAULT,@luid)
    
	-- Set 'real' departure and return time limits
	-- Use today's date so that DST time conversion is applied p[roperly
	SET @stime = dbo.TZ_ToUtc(CAST(CONVERT(VARCHAR(11), GETDATE(), 120) + '05:00' AS DATETIME), DEFAULT, @luid)
	SET @etime = dbo.TZ_ToUtc(CAST(CONVERT(VARCHAR(11), GETDATE(), 120) + '20:00' AS DATETIME), DEFAULT, @luid)
	-- Now convert to 1900-01-01 date so that time comparisons using FLOOR will function correctly later
	SET @stime = '1900-01-01 ' + CONVERT(VARCHAR(5), @stime, 114)
	SET @etime = '1900-01-01 ' + CONVERT(VARCHAR(5), @etime, 114)

    SET @lisChecked = ISNULL(@lisChecked, 0)

    DECLARE @tempmult FLOAT,
        @liquidmult FLOAT
    SET @tempmult = ISNULL(dbo.[UserPref](@luid, 214), 1)
    SET @liquidmult = ISNULL(dbo.[UserPref](@luid, 200), 1)
	
    DECLARE @AnalogAlert1 SMALLINT,
        @AnalogAlert2 SMALLINT,
        @AnalogAlert3 SMALLINT,
        @AnalogAlert4 SMALLINT,
   		@productsensorid SMALLINT,
		@internalsensorid SMALLINT,
		@externalsensorid SMALLINT,
		@templimit FLOAT,
		@tempdepart FLOAT
		
    SET @AnalogAlert1 = 1
    SET @AnalogAlert2 = 2
    SET @AnalogAlert3 = 4
    SET @AnalogAlert4 = 8
    SET @internalsensorid = 1
	SET @productsensorid = 2
	SET @externalsensorid = 4
	SET @templimit = -18.0
	SET @tempdepart = -25.0
    
-- Create a table of vehicles and associated static data
	DECLARE @Vehicle TABLE
	(
		VehicleId UNIQUEIDENTIFIER,
		VehicleIntId INT,
		Registration NVARCHAR(MAX),
		Analog1Scaling FLOAT,
		Analog2Scaling FLOAT,
		Analog3Scaling FLOAT,
		Analog4Scaling FLOAT,
		Alert1Name NVARCHAR(MAX),
		Alert1Colour NVARCHAR(MAX),
		Alert2Name NVARCHAR(MAX),
		Alert2Colour NVARCHAR(MAX),
		Alert3Name NVARCHAR(MAX),
		Alert3Colour NVARCHAR(MAX),
		Alert4Name NVARCHAR(MAX),
		Alert4Colour NVARCHAR(MAX)
	)
	INSERT INTO @Vehicle (VehicleId, VehicleIntId, Registration, Analog1Scaling, Analog2Scaling, Analog3Scaling, Analog4Scaling, Alert1Name, Alert1Colour, Alert2Name, Alert2Colour, Alert3Name, Alert3Colour, Alert4Name, Alert4Colour)
	SELECT v.VehicleId, v.VehicleIntId, v.Registration, vs1.AnalogSensorScaleFactor, vs2.AnalogSensorScaleFactor, vs3.AnalogSensorScaleFactor, vs4.AnalogSensorScaleFactor,
	    dbo.CFG_GetTemperatureAlertValueFromHistory(v.VehicleId, 'Name_1', @lsdate) AS Alert1Name,
        dbo.CFG_GetTemperatureAlertValueFromHistory(v.VehicleId, 'Colour_1', @lsdate) AS Alert1Colour,
        dbo.CFG_GetTemperatureAlertValueFromHistory(v.VehicleId, 'Name_2', @lsdate) AS Alert2Name,
        dbo.CFG_GetTemperatureAlertValueFromHistory(v.VehicleId, 'Colour_2', @lsdate) AS Alert2Colour,
        dbo.CFG_GetTemperatureAlertValueFromHistory(v.VehicleId, 'Name_3', @lsdate) AS Alert3Name,
        dbo.CFG_GetTemperatureAlertValueFromHistory(v.VehicleId, 'Colour_3', @lsdate) AS Alert3Colour,
        dbo.CFG_GetTemperatureAlertValueFromHistory(v.VehicleId, 'Name_4', @lsdate) AS Alert4Name,
        dbo.CFG_GetTemperatureAlertValueFromHistory(v.VehicleId, 'Colour_4', @lsdate) AS Alert4Colour
	FROM dbo.Vehicle v
	LEFT JOIN dbo.VehicleSensor vs1 ON v.VehicleIntId = vs1.VehicleIntId AND vs1.SensorId = 1
    LEFT JOIN dbo.VehicleSensor vs2 ON v.VehicleIntId = vs2.VehicleIntId AND vs2.SensorId = 2
    LEFT JOIN dbo.VehicleSensor vs3 ON v.VehicleIntId = vs3.VehicleIntId AND vs3.SensorId = 3
    LEFT JOIN dbo.VehicleSensor vs4 ON v.VehicleIntId = vs4.VehicleIntId AND vs4.SensorId = 4
	WHERE v.VehicleId IN (SELECT VALUE FROM dbo.Split(@lvids, ','))

-- Create a table variable and populate with vehicles in alert between the given dates
    DECLARE @TemperatureAlert TABLE
        (
          VehicleId UNIQUEIDENTIFIER,
          VehicleIntId INT,
          EventDateTime DATETIME,
          EventId BIGINT,
          Lat FLOAT,
          Long FLOAT,
          AnalogData0 SMALLINT,
		  AnalogData1 SMALLINT,
		  AnalogData2 SMALLINT,
		  AnalogData3 SMALLINT,
		  AnalogData5 SMALLINT
        )
    INSERT  INTO @TemperatureAlert (VehicleId, VehicleIntId, EventDateTime, EventId, Lat, Long, AnalogData0, AnalogData1, AnalogData2, AnalogData3, AnalogData5)
    SELECT  v.VehicleId, v.VehicleIntId, e.EventDateTime, e.EventId, e.Lat, e.Long, e.AnalogData0, e.AnalogData1, e.AnalogData2, e.AnalogData3, e.AnalogData5								
    FROM    @Vehicle v
    INNER JOIN dbo.Event e ON v.VehicleIntId = e.VehicleIntId AND e.EventDateTime BETWEEN @lsdate AND @ledate
    WHERE   v.VehicleId IN ( SELECT VALUE FROM   dbo.Split(@lvids, ',') )
--	  AND e.CreationCodeId IN (111, 113, 115, 117)
	  AND ((e.CreationCodeId = 111 AND @lisAlert01 = 1)
	   OR (e.CreationCodeId = 113 AND @lisAlert02 = 1)
	   OR (e.CreationCodeId = 115 AND @lisAlert03 = 1)
	   OR (e.CreationCodeId = 117 AND @lisAlert04 = 1))

DECLARE @results TABLE
(
	VehicleId UNIQUEIDENTIFIER,
	VehicleIntId INT,
	Registration NVARCHAR(MAX),
	Occurred DATETIME,
	Location NVARCHAR(MAX),
    Alert1Name NVARCHAR(MAX),
    Alert1Colour NVARCHAR(MAX),
    Alert1Active BIT,
    Alert2Name NVARCHAR(MAX),
    Alert2Colour NVARCHAR(MAX),
    Alert2Active BIT,
    Alert3Name NVARCHAR(MAX),
    Alert3Colour NVARCHAR(MAX),
    Alert3Active BIT,
    Alert4Name NVARCHAR(MAX),
    Alert4Colour NVARCHAR(MAX),
    Alert4Active BIT,
    Ack BIT,
    AckReason NVARCHAR(MAX),
    AckDateTime DATETIME,
    AckName NVARCHAR(MAX),
    AnalogIoAlertTypeId INT,
    CheckInOut BIT,
    CheckOutreason NVARCHAR(MAX),
    CheckOutDateTime DATETIME,
    CheckIndateTime DATETIME,
    CheckOutName NVARCHAR(MAX),
	GeofenceLeaveTime DATETIME,
	GeofenceLeaveInternalTemp FLOAT,
	GeofenceLeaveProductTemp FLOAT,
	GeofenceEnterTime DATETIME,
	GeofenceEnterInternalTemp FLOAT,
	GeofenceEnterProductTemp FLOAT,
    SensorTime DATETIME,
    AnalogTemp0 FLOAT,
    AnalogTemp1 FLOAT,
    AnalogTemp2 FLOAT,
    AnalogTemp3 FLOAT,
    OutsideTime INT,
    OverTempDuration INT,
    Sensor1Name NVARCHAR(MAX),
    Sensor2Name NVARCHAR(MAX),
    Sensor3Name NVARCHAR(MAX),
    Sensor4Name NVARCHAR(MAX)
)

INSERT INTO @results
        ( VehicleId ,
		  VehicleIntId,
          Registration ,
   		  Occurred,
   		  Location,
          Alert1Name ,
          Alert1Colour ,
          Alert1Active ,
          Alert2Name ,
          Alert2Colour ,
          Alert2Active ,
          Alert3Name ,
          Alert3Colour ,
          Alert3Active ,
          Alert4Name ,
          Alert4Colour ,
          Alert4Active ,
          Ack ,
          AckReason ,
          AckDateTime ,
          AckName ,
          AnalogIoAlertTypeId ,
          CheckInOut ,
          CheckOutreason ,
          CheckOutDateTime ,
          CheckIndateTime ,
          CheckOutName ,
          SensorTime ,
          AnalogTemp0 ,
          AnalogTemp1 ,
          AnalogTemp2 ,
          AnalogTemp3 ,
		  Sensor1Name,
		  Sensor2Name,
		  Sensor3Name,
		  Sensor4Name
        )
SELECT  v.VehicleId,
		v.VehicleIntId,
        v.Registration,
        [dbo].TZ_GetTime(ta.EventDateTime, DEFAULT, @luid) AS Occurred,
        [dbo].[GetAddressFromLongLat](ta.Lat, ta.Long),
        v.Alert1Name,
        v.Alert1Colour,
        dbo.TestBits(ta.AnalogData5, @AnalogAlert1) AS Alert1Active,
        v.Alert2Name,
        v.Alert2Colour,
        dbo.TestBits(ta.AnalogData5, @AnalogAlert2) AS Alert2Active,
        v.Alert3Name,
        v.Alert3Colour,
        dbo.TestBits(ta.AnalogData5, @AnalogAlert3) AS Alert3Active,
        v.Alert4Name,
        v.Alert4Colour,
        dbo.TestBits(ta.AnalogData5, @AnalogAlert4) AS Alert4Active,
        t.Ack,
        t.AckReason,
        [dbo].TZ_GetTime(t.AckDateTime, DEFAULT, @luid) AS AckDateTime,
        u1.FirstName + ' ' + u1.Surname AS AckName,
        vle.AnalogIoAlertTypeId,
        CheckInOut = CASE ISNULL(ec.EntityCheckOutId, 0) WHEN 0 THEN 0 ELSE 1 END,
        ec.CheckOutReason AS CheckOutreason,
        ec.CheckOutDateTime AS CheckOutDateTime,
        ec.CheckInDateTime AS CheckIndateTime,
        u2.FirstName + ' ' + u2.Surname AS CheckOutName,
        vle.EventDateTime AS SensorTime,
        dbo.ScaleConvertAnalogValue(ta.AnalogData0, v.Analog1Scaling, @tempmult, @liquidmult),
        dbo.ScaleConvertAnalogValue(ta.AnalogData1, v.Analog2Scaling, @tempmult, @liquidmult),
        dbo.ScaleConvertAnalogValue(ta.AnalogData2, v.Analog3Scaling, @tempmult, @liquidmult),
        dbo.ScaleConvertAnalogValue(ta.AnalogData3, v.Analog4Scaling, @tempmult, @liquidmult),
		vs1.Description AS Sensor1Name,
		vs2.Description AS Sensor2Name,
		vs3.Description AS Sensor3Name,
		vs4.Description AS Sensor4Name
FROM @TemperatureAlert ta    
INNER JOIN dbo.VehicleLatestEvent vle ON ta.VehicleId = vle.VehicleId
INNER JOIN @Vehicle v ON vle.VehicleId = v.VehicleId
LEFT OUTER JOIN dbo.VehicleSensor vs1 ON vs1.VehicleIntId = v.VehicleIntId AND vs1.Enabled = 1 AND vs1.SensorId = 1
LEFT OUTER JOIN dbo.VehicleSensor vs2 ON vs2.VehicleIntId = v.VehicleIntId AND vs2.Enabled = 1 AND vs2.SensorId = 2
LEFT OUTER JOIN dbo.VehicleSensor vs3 ON vs3.VehicleIntId = v.VehicleIntId AND vs3.Enabled = 1 AND vs3.SensorId = 3
LEFT OUTER JOIN dbo.VehicleSensor vs4 ON vs4.VehicleIntId = v.VehicleIntId AND vs4.Enabled = 1 AND vs4.SensorId = 4
LEFT JOIN dbo.TemperatureStatus t ON v.VehicleId = t.VehicleId AND FLOOR(CAST(t.AckDateTime AS FLOAT)) = FLOOR(CAST(ta.EventDateTime AS FLOAT))
--LEFT JOIN dbo.TAN_EntityCheckOut ec ON v.VehicleId = ec.EntityId AND FLOOR(CAST(ec.CheckOutDateTime AS FLOAT)) = FLOOR(CAST(ta.EventDateTime AS FLOAT))
--LEFT JOIN dbo.TAN_EntityCheckOut ec ON v.VehicleId = ec.EntityId AND ta.EventDateTime BETWEEN ec.CheckOutDateTime AND ec.CheckInDateTime
LEFT JOIN dbo.TAN_EntityCheckOut ec ON v.VehicleId = ec.EntityId AND ta.EventDateTime BETWEEN CAST(FLOOR(CAST(ec.CheckOutDateTime AS FLOAT)) AS DATETIME) AND ec.CheckInDateTime
LEFT JOIN dbo.[User] u1 ON t.AckUserId = u1.UserID
LEFT JOIN dbo.[User] u2 ON ec.CheckOutUserId = u2.UserID
WHERE 1 = CASE @lisChecked
              WHEN 0 THEN 1 -- show ALL vehicles
              WHEN 1 THEN CASE WHEN ( ec.EntityCheckOutId IS NULL ) THEN 1 ELSE 0 END -- only non-checked out vehicles
              WHEN 2 THEN CASE WHEN ( ec.EntityCheckOutId IS NULL ) THEN 0 ELSE 1 END -- only checked out vehicles
          END

-- Create a temporary table for real geofence exits / entries for the required vehicles
DECLARE @RealTrips TABLE
(
	VehicleIntId INT,
	GeofenceId UNIQUEIDENTIFIER,
	ExitDateTime DATETIME,
	ExitEventId BIGINT,
	EntryDateTime DATETIME,
	EntryEventId BIGINT,
	ExitSeconds INT,
	OverLimitDuration INT
)
INSERT INTO @RealTrips (VehicleIntId, GeofenceId, ExitDateTime, ExitEventId, EntryDateTime, EntryEventId, ExitSeconds)
SELECT DISTINCT gexit.VehicleIntId AS vehicleIntId, gexit.GeofenceId AS GeofenceId, gexit.ExitDateTime, gexit.ExitEventId, gentry.EntryDateTime, gentry.EntryEventId, DATEDIFF(ss, gexit.ExitDateTime, gentry.EntryDateTime) AS ExitSeconds
FROM

	(SELECT ROW_NUMBER() OVER (PARTITION BY VehicleIntId, vgh.GeofenceId ORDER BY EntryDateTime) AS RowNum, vgh.*
	FROM dbo.VehicleGeofenceHistory vgh
	INNER JOIN dbo.Geofence geo ON geo.GeofenceId = vgh.GeofenceId AND geo.IsTemperatureMonitored = 1
	WHERE EntryDateTime BETWEEN @lsdate AND @ledate OR ExitDateTime BETWEEN @lsdate AND @ledate
	  ) gexit
	  
INNER JOIN 

	(SELECT ROW_NUMBER() OVER (PARTITION BY VehicleIntId, vgh.GeofenceId ORDER BY EntryDateTime) AS RowNum, vgh.*
	FROM dbo.VehicleGeofenceHistory vgh
	INNER JOIN dbo.Geofence geo ON geo.GeofenceId = vgh.GeofenceId AND geo.IsTemperatureMonitored = 1
	WHERE EntryDateTime BETWEEN @lsdate AND @ledate OR ExitDateTime BETWEEN @lsdate AND @ledate
	  ) gentry ON gexit.VehicleIntId = gentry.VehicleIntId AND gexit.GeofenceId = gentry.GeofenceId AND gentry.RowNum = gexit.RowNum + 1
	  
INNER JOIN @TemperatureAlert t ON gexit.VehicleIntId = t.VehicleIntId
WHERE DATEDIFF(ss, gexit.ExitDateTime, gentry.EntryDateTime) BETWEEN 2700 AND 43200 -- Real trips are between 30mins and 12 hours in duration
  AND CAST(gexit.ExitDateTime AS FLOAT) - FLOOR(CAST(gexit.ExitDateTime AS FLOAT)) > CAST(@stime AS FLOAT)
  AND CAST(gentry.EntryDateTime AS FLOAT) - FLOOR(CAST(gentry.EntryDateTime AS FLOAT)) < CAST(@etime AS FLOAT)

-- Update the over temp duration
UPDATE @results
SET	OverTempDuration = nce.OverLimitDuration
FROM @results r
INNER JOIN dbo.ReportingNCE nce ON r.VehicleIntId = nce.VehicleIntId AND FLOOR(CAST(r.Occurred AS FLOAT)) = FLOOR(CAST(nce.Date AS FLOAT))

-- Update the date, times and temperatures at leaving and entering the geofence
UPDATE @results
SET GeofenceLeaveTime = rt.FirstExit, 
	GeofenceEnterTime = rt.LastEntry,
	GeofenceLeaveInternalTemp = dbo.GetScaleConvertAnalogValue(ISNULL(xe.AnalogData0, 0), 0, r.VehicleId, @tempmult, @liquidmult),
    GeofenceLeaveProductTemp = dbo.GetScaleConvertAnalogValue(ISNULL(xe.AnalogData1, 0), 1, r.VehicleId, @tempmult, @liquidmult),
	GeofenceEnterInternalTemp = dbo.GetScaleConvertAnalogValue(ISNULL(ee.AnalogData0, 0), 0, r.VehicleId, @tempmult, @liquidmult),
    GeofenceEnterProductTemp = dbo.GetScaleConvertAnalogValue(ISNULL(ee.AnalogData1, 0), 1, r.VehicleId, @tempmult, @liquidmult)
FROM @results r
INNER JOIN (
		SELECT VehicleIntId, FLOOR(CAST(ExitDateTime as float)) AS Date, MIN(ExitDateTime) AS FirstExit, MIN(ExitEventId) AS ExitEventId, MAX(EntryDateTime) AS LastEntry, MAX(EntryEventId) AS EntryEventId
		FROM @RealTrips
		GROUP BY VehicleIntId, FLOOR(CAST(ExitDateTime as float))
	) rt ON r.vehicleIntId = rt.VehicleIntId AND FLOOR(CAST(r.Occurred as float)) = rt.Date
INNER JOIN dbo.Event ee ON ee.EventId = rt.EntryEventId
INNER JOIN dbo.Event xe ON xe.EventId = rt.ExitEventId  

SELECT	  g.GroupId,
		  g.GroupName,
		  r.VehicleId ,
          r.Registration ,
          r.Occurred ,
          r.Location,
          CASE r.Alert1Name WHEN NULL THEN 0 ELSE 1 END AS Alert1Enabled,
          r.Alert1Colour ,
          r.Alert1Active ,
          CASE r.Alert2Name WHEN NULL THEN 0 ELSE 1 END AS Alert2Enabled,
          r.Alert2Colour ,
          r.Alert2Active ,
          CASE r.Alert3Name WHEN NULL THEN 0 ELSE 1 END AS Alert3Enabled,
          r.Alert3Colour ,
          r.Alert3Active ,
          CASE r.Alert4Name WHEN NULL THEN 0 ELSE 1 END AS Alert4Enabled,
          r.Alert4Colour ,
          r.Alert4Active ,
          r.AnalogTemp0 AS Analog0Temp ,
          r.AnalogTemp1 AS Analog1Temp ,
          r.AnalogTemp2 AS Analog2Temp ,
          r.AnalogTemp3 AS Analog3Temp ,
          r.CheckOutName ,
          dbo.TZ_GetTime(r.CheckOutDateTime, DEFAULT, @uid) AS CheckOutDateTime ,
          r.CheckOutReason ,
          dbo.TZ_GetTime(r.CheckIndateTime, DEFAULT, @uid) AS CheckIndateTime ,
          r.AckName ,
          r.AckDateTime ,
          r.AckReason , 
	  	  r.GeofenceLeaveTime ,
		  r.GeofenceLeaveInternalTemp ,
		  r.GeofenceLeaveProductTemp ,
		  r.GeofenceEnterTime ,
		  r.GeofenceEnterInternalTemp ,
		  r.GeofenceEnterProductTemp ,        
          dbo.TZ_GetTime(r.SensorTime, DEFAULT, @luid) AS SensorTime,
          r.OverTempDuration AS DurationWarmerOutsideRDC,
		  r.Sensor1Name, 
		  r.Sensor2Name,
		  r.Sensor3Name,
		  r.Sensor4Name
FROM @results r
INNER JOIN dbo.GroupDetail gd ON gd.EntityDataId = r.VehicleId
INNER JOIN dbo.[Group] g ON gd.GroupId = g.GroupId
WHERE g.GroupId IN (SELECT VALUE FROM dbo.Split(@lgids, ','))
ORDER BY r.VehicleId, r.Occurred

      

GO
