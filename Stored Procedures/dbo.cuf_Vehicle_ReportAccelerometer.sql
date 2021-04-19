SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_ReportAccelerometer]
(
	@vids NVARCHAR(MAX) = NULL, 
    @uid UNIQUEIDENTIFIER = NULL,
	@sdate DATETIME = NULL, 
	@edate DATETIME = NULL
)
AS

--DECLARE	@sdate DATETIME,
--		@edate DATETIME,
--		@uid UNIQUEIDENTIFIER,
--		@vids NVARCHAR(MAX)
		
--SET @sdate = '2016-05-09 00:00:00'
--SET @edate = '2016-05-11 23:59:59'
--SET @uid = N'ac5fc459-faf5-48d7-bbbe-88cc5ee824e1' 
--SET @vids = N'4039f0f0-e2d3-4dca-9683-1f2041f249ba,30de088b-23d4-4614-964b-ba0fac762448'

-- Bit used to store the status of FMTONLY
DECLARE @fmtonlyON BIT
SET @fmtonlyON = 0

--This line will be executed if FMTONLY was initially set to ON
IF (1=0) BEGIN SET @fmtonlyON = 1 END
-- Turning off FMTONLY so the temp tables can be declared and read by the calling application
SET FMTONLY OFF

DECLARE @tempmult FLOAT,
		@liquidmult FLOAT
		
SET @tempmult = ISNULL(dbo.[UserPref](@uid, 214),1)
SET @liquidmult = ISNULL(dbo.[UserPref](@uid, 200),1)

CREATE TABLE #results
(
	VehicleId UNIQUEIDENTIFIER,
	Speed SMALLINT,
	Registration NVARCHAR(MAX),
	VehicleTypeID INT,
	EventTime DATETIME,
	EventId BIGINT,
	CustomerIntId INT,
	CreationCodeId INT,
	CreationCodeName VARCHAR(50),
	Lat FLOAT,
	Lon FLOAT,
	TotalAcceleration INT,
	TotalBraking INT,
	TotalCorner INT,
	TotalRop INT,
	TotalRop2 INT,
	TotalHarshBrake INT,
	DriverName NVARCHAR(MAX),
	LatLonString NVARCHAR(MAX),
	EventDataString NVARCHAR(MAX),
	ReverseGeocode NVARCHAR(MAX),
	MaxForce FLOAT,
	EndSpeed SMALLINT,
	OdoGPS FLOAT,
	Heading SMALLINT
)

CREATE TABLE #tracedetails  
(
	VehicleIntId INT,
	DriverIntId INT,
	VehicleId UNIQUEIDENTIFIER,
	VehicleTypeID INT,
	DriverId UNIQUEIDENTIFIER,
	CreationCodeId smallint,
	SafeNameLong float,
	Lat float,
	Heading int,
	Speed int,
	OdoGPS int,
	OdoRoadSpeed INT,
	OdoDashboard INT,
	EventDateTime datetime,
	DigitalIO tinyint,
	SpeedLimit tinyint,
	LastOperation smalldatetime,
	Archived bit,
	CustomerIntId int,
	EventId bigint,
	ReverseGeocode nvarchar(255),
	AnalogData0 FLOAT,
	AnalogData1 FLOAT,
	AnalogData2 FLOAT,
	AnalogData3 FLOAT,
	AnalogData4 FLOAT,
	AnalogData5 FLOAT,
	EventDataString NVARCHAR(1024),
	SpeedEnd int
)

DECLARE @eventId BIGINT,
		@depid INT,
		@vid UNIQUEIDENTIFIER,
		@eventTime DATETIME,
		@speedmult FLOAT,
		@distmult FLOAT,
		@timezone NVARCHAR(30),
		@utc_time DATETIME

INSERT #results ( VehicleId, Speed, Registration, VehicleTypeID, EventTime , EventId , CustomerIntId , CreationCodeId , CreationCodeName, Lat , Lon , TotalAcceleration, TotalBraking, TotalCorner, TotalRop, TotalRop2, TotalHarshBrake, DriverName, LatLonString, ReverseGeocode, MaxForce, EndSpeed, OdoGPS, Heading )
	EXECUTE dbo.[proc_ReportAccelerometer] @vids, @uid, @sdate, @edate

DECLARE trace_cur CURSOR FAST_FORWARD FORWARD_ONLY FOR
	SELECT EventId, CustomerIntId, VehicleId, EventTime FROM #results

SET @timezone = dbo.[UserPref](@uid, 600)
SET @speedmult = CAST(dbo.[UserPref](@uid,208) AS FLOAT)
SET @distmult = CAST(dbo.[UserPref](@uid,202) AS FLOAT)

DECLARE @sql NVARCHAR(MAX)

OPEN trace_cur
FETCH NEXT FROM trace_cur INTO @eventId, @depid, @vid, @eventTime
WHILE @@FETCH_STATUS = 0
BEGIN
		SET @utc_time = dbo.TZ_ToUtc(@eventTime, DEFAULT, @uid)

		INSERT INTO #tracedetails 
			SELECT TOP 1 
				e.VehicleIntId,
				e.DriverIntId,
				v.VehicleId,
				v.VehicleTypeID,
				d.DriverId,
				e.CreationCodeId,
				e.Long as SafeNameLong,
				e.Lat,
				e.Heading,
				CASE WHEN ss.EventID IS NULL THEN
					Cast(Round(e.Speed * @speedmult, 0) as smallint)
				ELSE 
					Cast(Round(ss.RoadSpeed * @speedmult, 0) as smallint) 
				END as Speed,
				Cast(Round(e.OdoGPS * @distmult, 0) as int) as OdoGPS,
				Cast(Round(e.OdoRoadSpeed * @distmult, 0) as int) as OdoRoadSpeed,
				Cast(Round(e.OdoDashboard * @distmult, 0) as int) as OdoDashboard,
				dbo.[TZ_GetTime]( e.EventDateTime, @timezone, @uid) as EventDateTime,
				e.DigitalIO,
				e.SpeedLimit,
				e.LastOperation,
				e.Archived,
				e.CustomerIntId,
				e.EventId,
				dbo.[GetAddressFromLongLat] (e.Lat, e.Long) as ReverseGeoCode,
				dbo.GetScaleConvertAnalogValue(e.AnalogData0, 0, v.VehicleId, @tempmult, @liquidmult) AS AnalogData0,
				dbo.GetScaleConvertAnalogValue(e.AnalogData1, 1, v.VehicleId, @tempmult, @liquidmult) AS AnalogData1,
				dbo.GetScaleConvertAnalogValue(e.AnalogData2, 2, v.VehicleId, @tempmult, @liquidmult) AS AnalogData2,
				dbo.GetScaleConvertAnalogValue(e.AnalogData3, 3, v.VehicleId, @tempmult, @liquidmult) AS AnalogData3,
				NULL AS AnalogData4,
				NULL AS AnalogData5,
				evtData.EventDataString,
				evtData.Speed * @speedmult AS SpeedEnd
			FROM [dbo].[Event] e 
				LEFT OUTER JOIN 
					(
						SELECT ed.EventDataString ,
                               ed.VehicleIntId ,
							   @eventId AS StartEventId,
							   ede.Speed
						FROM dbo.EventData ed
							INNER JOIN dbo.Event ede ON ede.EventId = ed.EventId
							INNER JOIN dbo.Vehicle vEd ON vEd.VehicleIntId = ed.VehicleIntId
						WHERE vEd.VehicleId = @vid 
							AND ed.EventId > @eventId 
							AND ed.EventDateTime BETWEEN @utc_time AND DATEADD(MINUTE, 1, @utc_time) 
							AND ed.EventDataName LIKE '%HMV%'
					) evtData ON  evtData.VehicleIntId = e.VehicleIntId
				LEFT OUTER JOIN dbo.[Snapshot] ss ON e.EventId = ss.EventId
                                                    AND e.CustomerIntId = ss.CustomerIntId
                                                    AND ss.CreationCodeId = 7
                                                    AND ss.Reserved > 50
				INNER JOIN dbo.Driver d ON e.DriverIntId = d.DriverIntId
				INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
			WHERE e.CustomerIntId = @depid
				AND v.VehicleId = @vid 
				AND e.EventId = @eventId 
			ORDER BY v.VehicleId, EventDateTime DESC 

	FETCH NEXT FROM trace_cur INTO @eventId, @depid, @vid, @eventTime
END
CLOSE trace_cur
DEALLOCATE trace_cur

SELECT * FROM #results

SELECT * FROM #tracedetails

DROP TABLE #results
DROP TABLE #tracedetails


-- Now the compiler knows these things exist so we can set FMTONLY back to its original status
IF @fmtonlyON = 1 BEGIN SET FMTONLY ON END
GO
