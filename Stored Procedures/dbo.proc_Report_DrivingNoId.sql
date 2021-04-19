SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_Report_DrivingNoId]
(
	@gids NVARCHAR(MAX),
	@vids NVARCHAR(MAX),
	@sdate DATETIME,
	@edate DATETIME,
	@uid UNIQUEIDENTIFIER
)
AS

--DECLARE @gids NVARCHAR(MAX),
--		@vids NVARCHAR(MAX),
--		@uid UNIQUEIDENTIFIER,
--		@sdate DATETIME,
--		@edate DATETIME

--SET @gids = 'EA6FF8F6-F6EA-4632-9607-7B0A8A8A8DDB,C1234FEF-CE3B-4826-9FE8-B8560690165B,D44A8BB9-283D-4D6D-9FC3-1BB5DE7AD088,D2B5005D-E9C1-4B42-A0C9-0C56B704A392'
--SET @vids = '909FB8A2-A973-4253-99C1-03EAF670C13B,9F754430-BDF3-4F5A-9454-092C21FE247A,ABAC69E6-CCCC-4E60-9F81-0B14A2CE8CFD,7A03DFD2-3982-46E8-8C4E-12F297DEE350,97F53C63-1B1D-4760-9DE9-2B09A740A513,901BCFF8-BE83-4C2C-90E2-A7E0C80A1D99'
--SET @uid = 'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
--SET @sdate = '2012-09-01 00:00'
--SET @edate = '2012-09-30 23:59'

--DECLARE @did UNIQUEIDENTIFIER,
--		@uid UNIQUEIDENTIFIER,
--		@sdate DATETIME,
--		@edate DATETIME
--SET @did = N'BBA1EF4F-40D5-481C-B6CE-AED99E3D78C8'
--SET @uid = N'4CD81189-AB9F-4A4A-B9DD-E88D29CE95F2'
--SET @sdate = '2013-06-01 12:00'
--SET @edate = '2013-06-30 23:59'
 
DECLARE @dintid INT,
		@eventid BIGINT,
		@driverintid INT,
		@creationcodeid SMALLINT,
		@eventdatetime DATETIME,
		@OdoGPS INT,
		@lat FLOAT,
		@long FLOAT,
		@vehicleintid INT,
		@starteventid BIGINT,
		@startvehicleintid INT,
		@startlat FLOAT,
		@startlong FLOAT,
		@starteventdatetime DATETIME,
		@startdistance INT,
		@endeventid BIGINT,
		@endvehicleintid INT,
		@endlat FLOAT,
		@endlong FLOAT,
		@endeventdatetime DATETIME,
		@enddistance INT,
		@diststr VARCHAR(20),
		@distmult FLOAT,
                    @custid UNIQUEIDENTIFIER
		
SELECT @diststr = [dbo].UserPref(@uid, 203)
SELECT @distmult = [dbo].UserPref(@uid, 202)
SELECT @custid = CustomerID FROM [User] WHERE userID = @uid

SET @dintid = dbo.GetDriverIntFromIdAndCustomerId(NULL, @custid)

DECLARE @VehicleList TABLE ( VehicleintId INT )
DECLARE @TripTable TABLE ( 
	StartEventId BIGINT,
	StartLat FLOAT,
	StartLong FLOAT, 
	StartEventDateTime DATETIME, 
	StartDistance INT, 
	EndEventId BIGINT,
	EndLat FLOAT,
	EndLong FLOAT, 
	EndEventDateTime DATETIME, 
	EndDistance INT,
	VehicleIntId INT)

INSERT INTO @VehicleList (VehicleintId)
SELECT DISTINCT E.VehicleIntId
FROM dbo.Event E
INNER JOIN dbo.Vehicle V ON V.VehicleIntID = E.VehicleIntID
INNER JOIN dbo.CustomerVehicle C ON C.VehicleID = V.VehicleID
WHERE E.DriverIntId = @dintid
  AND C.CustomerID = @custid
  AND E.EventDateTime BETWEEN @sdate AND @edate
  AND V.VehicleID IN (SELECT Value FROM dbo.Split(@vids, ','))

SET @starteventid = 0
SET @endeventid = 0
SET @startvehicleintid = 0

DECLARE TripCursor CURSOR FAST_FORWARD READ_ONLY
FOR
SELECT e.eventid, e.Lat, e.Long, ISNULL(d.DriverIntId,0), e.CreationCodeId, e.EventDateTime, e.VehicleIntId, e.OdoGPS, e.VehicleIntId
FROM dbo.Event e
INNER JOIN @VehicleList vl ON e.VehicleIntId = vl.VehicleintId
LEFT JOIN dbo.Driver d ON e.DriverIntId = d.DriverIntId AND d.DriverIntId = @dintid
WHERE e.EventDateTime BETWEEN @sdate AND @edate
  AND e.CreationCodeId IN (4,5,61)
ORDER BY e.VehicleIntID, e.EventDateTime

OPEN TripCursor
FETCH NEXT FROM TripCursor INTO @eventid, @lat, @long, @driverintid, @creationcodeid, @eventdatetime, @vehicleintid, @OdoGPS, @vehicleintid
WHILE @@FETCH_STATUS = 0
BEGIN
	IF @driverintid = @dintid AND @creationcodeid IN (4,61) -- This is possibly a trip start (but could be a driver logout from a previous vehicle)
	BEGIN
		SET @startvehicleintid = @vehicleintid 
		SET @starteventid = @eventid
		SET @startlat = @lat
		SET @startlong = @long
		SET @starteventdatetime = @eventdatetime
		SET @startdistance = @OdoGPS
	END ELSE
	BEGIN
		IF (@creationcodeid = 5 OR (@creationcodeid = 61 AND @driverintid != @dintid)) AND @starteventid != 0 AND @vehicleintid = @startvehicleintid -- This is a trip end
		BEGIN
			SET @endeventid = @eventid
			SET @endlat = @lat
			SET @endlong = @long
			SET @endeventdatetime = @eventdatetime
			SET @enddistance = @OdoGPS
		END		
		IF @vehicleintid != @startvehicleintid -- We didn't have a trip start or end, but the vehicle has changed, so reset the start id
		BEGIN
			SET @starteventid = 0
			SET @endeventid = 0
		END
	END
	
	IF @starteventid != 0 AND @endeventid != 0 -- We have identified a complete trip
	BEGIN
		INSERT INTO @TripTable (StartEventId, StartLat, StartLong, StartEventDateTime, StartDistance, EndEventId, EndLat, EndLong, EndEventDateTime, EndDistance, VehicleIntId)
		VALUES  (@starteventid, @startlat, @startlong, @starteventdatetime, @startdistance, @endeventid, @endlat, @endlong, @endeventdatetime, @enddistance, @vehicleintid)
		-- Reset the trip start and end events
		SET @starteventid = 0
		SET @endeventid = 0
	END
	
	FETCH NEXT FROM TripCursor INTO @eventid, @lat, @long, @driverintid, @creationcodeid, @eventdatetime, @vehicleintid, @OdoGPS, @vehicleintid
END

SELECT  'No ID' AS DriverName,
		v.VehicleId,
		v.Registration,
		tt.StartLat,
        tt.StartLong,
        dbo.[GetGeofenceNameFromLongLat] (tt.StartLat, tt.StartLong, @uid, dbo.[GetAddressFromLongLat] (tt.StartLat, tt.StartLong)) as StartLocation,
        dbo.TZ_GetTime(tt.StartEventDateTime, DEFAULT, @uid) AS StartEventdateTime,
        tt.EndLat,
        tt.EndLong,
        dbo.[GetGeofenceNameFromLongLat] (tt.EndLat, tt.EndLong, @uid, dbo.[GetAddressFromLongLat] (tt.EndLat, tt.EndLong)) as EndLocation,        
        dbo.TZ_GetTime(tt.EndEventDateTime, DEFAULT, @uid) AS EndEventDateTime,
        DATEDIFF(mi, tt.StartEventDateTime, tt.EndEventDateTime) AS TripDuration,
        (tt.EndDistance - tt.StartDistance) * @distmult AS TripDistance,
		ttPeriod.PeriodShiftTime,
		ttPeriod.PeriodDriveTime,
		ttPeriod.PeriodDistance * @distmult AS PeriodDistance,
		ttPeriod.PeriodStopTime,
		dbo.TZ_GetTime(ttday.StartDateTime, DEFAULT, @uid) AS StartDayTime,
		dbo.TZ_GetTime(ttday.EndDateTime, DEFAULT, @uid) AS EndDayTime,
		ttday.ShiftTime AS DayShiftTime,
		ISNULL(DATEDIFF(mi, ttyesterday.EndDateTime, ttday.StartDateTime),0) AS DayRestTime,
        ttday.DriveTime AS DayDriveTime,
		ttday.Distance * @distmult AS DayDriveDistance,
		ttday.StopTime AS DayStopTime,
		@diststr AS DistanceUnit
FROM @TripTable tt
INNER JOIN dbo.Vehicle v ON tt.VehicleIntId = v.VehicleIntId
INNER JOIN (SELECT	ROW_NUMBER() OVER(ORDER BY CONVERT(CHAR(6),starteventdatetime, 12)) AS DayNum,
					CONVERT(CHAR(6),starteventdatetime, 12) AS ttDay,
					MIN(StartEventDateTime) AS StartDateTime,
					MAX(EndEventDateTime) AS EndDateTime,
					DATEDIFF(mi, MIN(StartEventDateTime), MAX(EndEventDateTime)) AS ShiftTime,
					1440 - DATEDIFF(mi, MIN(StartEventDateTime), MAX(EndEventDateTime)) AS RestTime,
					SUM(DATEDIFF(mi, StartEventDateTime, EndEventDateTime)) AS DriveTime,
					DATEDIFF(mi, MIN(StartEventDateTime), MAX(EndEventDateTime)) - SUM(DATEDIFF(mi, StartEventDateTime, EndEventDateTime)) AS StopTime,
					SUM(EndDistance - StartDistance) AS Distance
			FROM @TripTable
			GROUP BY CONVERT(CHAR(6),starteventdatetime, 12)) ttday ON CONVERT(CHAR(6),tt.starteventdatetime, 12) = ttday.ttDay
LEFT JOIN (SELECT	ROW_NUMBER() OVER(ORDER BY CONVERT(CHAR(6),starteventdatetime, 12)) AS DayNum,
					MIN(StartEventDateTime) AS StartDateTime,
					MAX(EndEventDateTime) AS EndDateTime
			FROM @TripTable
			GROUP BY CONVERT(CHAR(6),starteventdatetime, 12)) ttyesterday ON ttday.DayNum = ttyesterday.DayNum + 1					
CROSS JOIN (SELECT SUM(ShiftTime) AS PeriodShiftTime, SUM(DriveTime) AS PeriodDriveTime, SUM(StopTime) AS PeriodStopTime, SUM(Distance) AS PeriodDistance
			FROM (SELECT CONVERT(CHAR(6),starteventdatetime, 12) AS ttDay,
					MIN(StartEventDateTime) AS StartDateTime,
					MAX(EndEventDateTime) AS EndDateTime,
					DATEDIFF(mi, MIN(StartEventDateTime), MAX(EndEventDateTime)) AS ShiftTime,
					SUM(DATEDIFF(mi, StartEventDateTime, EndEventDateTime)) AS DriveTime,
					DATEDIFF(mi, MIN(StartEventDateTime), MAX(EndEventDateTime)) - SUM(DATEDIFF(mi, StartEventDateTime, EndEventDateTime)) AS StopTime,
					SUM(EndDistance - StartDistance) AS Distance
				  FROM @TripTable
				  GROUP BY CONVERT(CHAR(6),starteventdatetime, 12)) ttday
			) ttPeriod
WHERE tt.EndDistance - tt.StartDistance > 0 -- remove trips of zero distance
ORDER BY tt.StartEventDateTime
GO
