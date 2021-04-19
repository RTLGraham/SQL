SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_Report_ActivityLog]
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

--SET @vid =  N'BDB001FB-1EF4-4E1A-81A4-74373E6C5010' 
--SET @sdate = '2017-06-01 00:00'
--SET @edate = '2017-06-01 23:59'
--SET @uid = N'5E7D12DB-1038-4B16-882B-907A536250A5'

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
DECLARE @speedstr NVARCHAR(20)

SET @speedmult = cast([dbo].[UserPref](@uid,208) as float)
SET @distmult = Cast([dbo].[UserPref](@uid,202) as float)
SET @diststr = [dbo].UserPref(@uid, 203)
SET @timezone = [dbo].[UserPref](@uid, 600)
SET @speedstr = [dbo].[UserPref](@uid, 209)


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
	e.Speed * @speedmult AS Speed,
	e.OdoGPS * @distmult AS TripDistance,
	[dbo].[TZ_GetTime](e.EventDateTime, @timezone, @uid) AS EventDateTime
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
		@latlongidx BIGINT
DECLARE @spRes TABLE (StreetAddress NVARCHAR(MAX))

DECLARE addressCur CURSOR FAST_FORWARD
	FOR SELECT  DISTINCT ISNULL(Lat,0), ISNULL(Long,0)
		FROM    @tmpEvents
OPEN addressCur
FETCH NEXT FROM addressCur INTO @c_lat_end, @c_long_end
WHILE @@FETCH_STATUS = 0
	BEGIN
	--End address
	SET @address_end = NULL
	
	DELETE FROM @spRes
	INSERT INTO @spRes (StreetAddress)
	EXEC [dbo].[proc_GetGeofenceNameOrAdderssFromLongLat] @c_lat_end, @c_long_end, @uid, 1, 1
	SELECT TOP 1 @address_end = StreetAddress FROM @spRes

	--Update
	UPDATE @tmpEvents
	SET ReverseGeocode = @address_end
	WHERE Lat = @c_lat_end AND Long = @c_long_end
	
	FETCH NEXT FROM addressCur INTO @c_lat_end, @c_long_end
	END
CLOSE addressCur
DEALLOCATE addressCur    
	
SELECT	tstart.VehicleId,
		tstart.DriverId,
		tstart.CreationCodeId,
		
		tstart.Registration,
		tstart.Drivername,
		tstart.EventType,
		tstart.EventDateTime,
		tstart.ReverseGeocode,
		tstart.Lat,
		tstart.Long,
		0.0 AS TripDistance,
		tstart.Speed AS MinSpeed,
		tstart.Speed AS MaxSpeed,
		tstart.Speed AS AvgSpeed,
		@diststr AS DistanceUnit,
		@speedstr AS SpeedUnit

FROM @tmpEvents tstart
ORDER BY EventDateTime


GO
