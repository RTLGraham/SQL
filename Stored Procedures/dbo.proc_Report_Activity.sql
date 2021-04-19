SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_Report_Activity]
(
	@vid UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME,
	@uid UNIQUEIDENTIFIER
)
AS

--DECLARE	@vid UNIQUEIDENTIFIER,
--		@sdate DATETIME,
--		@edate DATETIME,
--		@uid uniqueidentifier

--SET @vid =  N'DCF94021-6AAC-446F-850A-7CCD5B637B6E'
--SET @sdate = '2018-03-30 00:00'
--SET @edate = '2018-03-30 23:59'
--SET @uid = N'CA0A703E-7334-4E2F-B79B-50932EFF4DF3'


DECLARE @tmpEvents TABLE (
	RowNum INT,
	GroupingNum INT,
	VehicleId uniqueidentifier,
	DriverId uniqueidentifier,
	CreationCodeId smallint,
	Registration  NVARCHAR(MAX),
	DriverName  NVARCHAR(MAX),
	EventType NVARCHAR(MAX),
	ReverseGeocode NVARCHAR(MAX),
	Long float,
	Lat FLOAT,
	Speed int,
	TripDistance INT,
	EventDateTime datetime)

DECLARE @s_date smalldatetime
DECLARE @e_date smalldatetime
SET @s_date = @sdate
SET @e_date = @edate
SET @sdate = [dbo].[TZ_ToUTC] (@sdate,default,@uid)
SET @edate = [dbo].[TZ_ToUTC] (@edate,default,@uid)

DECLARE @vintid INT
SET @vintid = dbo.GetVehicleIntFromId(@vid)

DECLARE @speedmult float
DECLARE @distmult float
DECLARE @timezone nvarchar(30)
DECLARE @diststr NVARCHAR(20)

SET @speedmult = cast([dbo].[UserPref](@uid,208) as float)
SET @distmult = Cast([dbo].[UserPref](@uid,202) as float)
SET @diststr = [dbo].UserPref(@uid, 203)
SET @timezone = [dbo].[UserPref](@uid, 600)

INSERT INTO @tmpEvents
SELECT
	ROW_NUMBER() OVER(ORDER BY EventDateTime),
	ROW_NUMBER() OVER(PARTITION BY CASE WHEN vm.Name IS NULL THEN cc.Name ELSE vm.Name END ORDER BY EventDateTime),
	v.VehicleId,
	d.DriverId,
	e.CreationCodeId,
	
	v.Registration,
	dbo.FormatDriverNameByUser(d.DriverId, @uid) AS DriverName,
	CASE WHEN (vm.Name IS NULL OR vm.VehicleModeID = 0) THEN cc.Name ELSE vm.Name END AS EventType,
	
	NULL AS ReverseGeocode,
	e.Long,
	e.Lat,
	e.Speed,
	e.OdoGPS AS TripDistance,
	e.EventDateTime
FROM dbo.[Event] e
	INNER JOIN dbo.Driver d ON e.DriverIntId = d.DriverIntId
	INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
	INNER JOIN dbo.CreationCode cc ON e.CreationCodeId = cc.CreationCodeId
	LEFT OUTER JOIN dbo.VehicleModeCreationCode vmcc ON cc.CreationCodeId = vmcc.CreationCodeId
	LEFT OUTER JOIN dbo.VehicleMode vm ON vmcc.VehicleModeId = vm.VehicleModeID
WHERE --e.DepotId = @currentdepid AND
	e.VehicleIntId = @vintid
	AND e.EventDateTime BETWEEN @sdate AND @edate
	AND e.CreationCodeId IS NOT NULL
	AND e.CreationCodeId IN (1,2,3,4,5,6,7,8,9,10,12,13,14,15,16,17,18,19,29,36,37,38,39,42,43,50,61,62)
	AND (e.Lat != 0 AND e.Long != 0)


DECLARE @c_lat_end FLOAT, 
		@c_long_end FLOAT,  
		@address_end NVARCHAR(MAX),
		@latlongidx BIGINT,
		@maxDiam FLOAT
DECLARE @spRes TABLE (StreetAddress NVARCHAR(MAX))


SELECT @maxDiam = dbo.GetUserGeoMaxDiam(@uid)

DECLARE addressCur CURSOR FAST_FORWARD
	FOR SELECT  DISTINCT ISNULL(Lat,0), ISNULL(Long,0)
		FROM    @tmpEvents
OPEN addressCur
FETCH NEXT FROM addressCur INTO @c_lat_end, @c_long_end
WHILE @@FETCH_STATUS = 0
	BEGIN
	--End address
	SET @address_end = NULL
	--SELECT @address_end = dbo.[GetGeofenceNameFromLongLat] (@c_lat_end, @c_long_end, @uid, dbo.[GetAddressFromLongLat] (@c_lat_end, @c_long_end))
	
	DELETE FROM @spRes
	INSERT INTO @spRes (StreetAddress)
	EXEC [dbo].[GetGeofenceNameFromLongLat_Ltd] @c_lat_end, @c_long_end, @uid, NULL, @maxDiam
	SELECT TOP 1 @address_end = StreetAddress FROM @spRes

	IF @address_end IS NULL
	BEGIN
		INSERT INTO @spRes (StreetAddress)
		EXEC [dbo].[proc_GetGeofenceNameOrAdderssFromLongLat] @c_lat_end, @c_long_end, @uid, 0, 1
		SELECT TOP 1 @address_end = StreetAddress FROM @spRes
	END

	--Update
	UPDATE @tmpEvents
	SET ReverseGeocode = @address_end
	WHERE Lat = @c_lat_end AND Long = @c_long_end
	
	FETCH NEXT FROM addressCur INTO @c_lat_end, @c_long_end
	END
CLOSE addressCur
DEALLOCATE addressCur    

--SELECT *
--FROM @tmpEvents
--ORDER BY RowNum

DECLARE @GroupData TABLE (
	RowNum INT,
	StartRowNum INT,
	EndRowNum INT,
	MinSpeed INT,
	MaxSpeed INT,
	AvgSpeed INT,
	StartEventdateTime DATETIME,
	EndEventDateTime DATETIME
	)
	
INSERT INTO @GroupData (RowNum, StartRowNum, EndRowNum, MinSpeed, MaxSpeed, AvgSpeed, StartEventdateTime, EndEventDateTime)
SELECT	RowNum,
		MIN(RowNum) OVER(PARTITION BY VehicleId, RowNum - GroupingNum, EventType),
		MAX(RowNum) OVER(PARTITION BY VehicleId, RowNum - GroupingNum, EventType),
		MIN(Cast(Round(Speed * @speedmult, 0) as smallint)) OVER(PARTITION BY VehicleId, RowNum - GroupingNum, EventType),
		MAX(Cast(Round(Speed * @speedmult, 0) as smallint)) OVER(PARTITION BY VehicleId, RowNum - GroupingNum, EventType),
		AVG(Cast(Round(Speed * @speedmult, 0) as smallint)) OVER(PARTITION BY VehicleId, RowNum - GroupingNum, EventType),
		MIN([dbo].[TZ_GetTime]( EventDateTime, @timezone, @uid)) OVER(PARTITION BY VehicleId, RowNum - GroupingNum, EventType),
		MAX([dbo].[TZ_GetTime]( EventDateTime, @timezone, @uid)) OVER(PARTITION BY VehicleId, RowNum - GroupingNum, EventType)
FROM @tmpEvents
ORDER BY VehicleId, EventDateTime

--SELECT *
--FROM @GroupData

DECLARE @cnt INT
SELECT @cnt = COUNT(*) FROM @tmpEvents

IF @cnt > 0
BEGIN

	SELECT	tstart.VehicleId,
			tstart.DriverId,
			tstart.CreationCodeId,
		
			tstart.Registration,
			tstart.Drivername,
			CASE WHEN g.RowNum = g.StartRowNum 
				THEN
					CASE tstart.EventType
						WHEN 'Drive' THEN 'Start Driving'  
						WHEN 'Idle' THEN 'Idling'
						WHEN 'Input 3 Active' THEN 'PTO On' 
						WHEN 'Input 3 Inactive' THEN 'PTO Off'
						ELSE tstart.EventType 
					END
				ELSE
					CASE tstart.EventType
						WHEN 'Drive' THEN 'Stop Driving'
						WHEN 'Idle' THEN 'Stop Idling'
						ELSE tstart.EventType
					END
				END AS EventType,
			CASE WHEN g.RowNum = g.StartRowNum THEN StartEventDateTime ELSE EndEventDateTime END AS EventDateTime,
			CASE WHEN g.RowNum = g.StartRowNum THEN tstart.ReverseGeocode ELSE tend.ReverseGeocode END AS Reversegeocode,
			CASE WHEN g.RowNum = g.StartRowNum THEN tstart.Lat ELSE tend.Lat END AS Lat,
			CASE WHEN g.RowNum = g.StartRowNum THEN tstart.Long ELSE tend.Long END AS Long,

	--		EndEventDateTime,
	--		tend.ReverseGeocode AS EndReversegeocode,
	--		tend.Lat AS EndLat,
	--		tend.Long AS EndLong,

			CASE WHEN tend.TripDistance - tstart.TripDistance > 0 THEN CAST((tend.TripDistance - tstart.TripDistance) AS FLOAT) * @distmult ELSE 0 END AS TripDistance,
			MinSpeed,
			MaxSpeed,
			AvgSpeed,
			@diststr AS DistanceUnit

	FROM @tmpEvents tstart
	INNER JOIN @GroupData g ON tstart.RowNum = g.StartRowNum
	INNER JOIN @tmpEvents tend ON tend.RowNum = g.EndRowNum
	WHERE g.RowNum = g.StartRowNum
	  OR (g.RowNum = g.EndRowNum AND (tstart.EventType = 'Drive' OR tstart.EventType = 'Idle'))
	ORDER BY g.RowNum
END
ELSE BEGIN
	SELECT 'n/a' AS Registration
END

















GO
