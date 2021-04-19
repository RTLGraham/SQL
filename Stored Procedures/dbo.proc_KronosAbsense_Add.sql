SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_KronosAbsense_Add]
(
	@uid UNIQUEIDENTIFIER,
	@absenseTypeId INT,
	@driverId UNIQUEIDENTIFIER,
	@duration INT,
	@date DATETIME,
	@comment NVARCHAR(MAX)
)
AS
	SET NOCOUNT ON;

--DECLARE	@uid UNIQUEIDENTIFIER,
--		@absenseTypeId INT,
--		@driverId UNIQUEIDENTIFIER,
--		@duration INT,
--		@date DATETIME,
--		@comment NVARCHAR(MAX)

--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
--SET @absenseTypeId = 2
--SET @driverId = N'74577134-6D36-49BB-AD57-B5A35884431A'
--SET @duration = 1440
--SET @date = '2018-02-07 00:00:00.000'
--SET @comment = 'Test to be removed'

	DECLARE @depottime INT,
			@outsidetime INT,
			@sdate DATETIME,
			@edate DATETIME,
			@stime TIME,
			@etime TIME

	SELECT @depottime = ISNULL(DATEDIFF(MINUTE,k.FirstIn, k.FirstOut), 0) + ISNULL(DATEDIFF(MINUTE,k.SecondIn, k.SecondOut), 0)
		FROM dbo.Kronos k
		INNER JOIN dbo.Driver d ON d.DriverIntId = k.DriverIntId
		WHERE d.DriverId = @driverId	
		  AND k.KronosDate = @date 

	-- Set 'real' departure and return time limits
	-- Use today's date by default so that DST time conversion is applied properly
	SET @stime = dbo.TZ_TimeToUtc('05:00', NULL, DEFAULT, @uid)
	SET @etime = dbo.TZ_TimeToUtc('20:00', NULL, DEFAULT, @uid)
		
	SET @sdate = @date
	SET @edate = DATEADD(mi, 1439, @date)

	-- Create a temporary table for real geofence exits / entries for the required vehicles
	-- Insert one row per day, driver, geofence combination taking the earliest exit and latest entry, with total exit duration
	DECLARE @RealDriverTrips TABLE
	(
		DateNum FLOAT,
		DriverIntId INT,
		GeofenceId UNIQUEIDENTIFIER,
		ExitDateTime DATETIME,
		ExitEventId BIGINT,
		EntryDateTime DATETIME,
		EntryEventId BIGINT,
		ExitSeconds BIGINT
	)

	INSERT INTO @RealDriverTrips (DateNum, DriverIntId, GeofenceId, ExitDateTime, ExitEventId, EntryDateTime, EntryEventId, ExitSeconds)
	SELECT DISTINCT FLOOR(CAST(gexit.ExitDateTime AS FLOAT)), gexit.ExitDriverIntId AS DriverIntId, gexit.GeofenceId AS GeofenceId, MIN(gexit.ExitDateTime), MIN(gexit.ExitEventId), MAX(gentry.EntryDateTime), MAX(gentry.EntryEventId), SUM(DATEDIFF(ss, gexit.ExitDateTime, gentry.EntryDateTime)) AS ExitSeconds
	FROM
		(SELECT ROW_NUMBER() OVER (PARTITION BY vgh.VehicleIntId, vgh.GeofenceId ORDER BY vgh.EntryDateTime) AS RowNum, vgh.*
		FROM dbo.VehicleGeofenceHistory vgh
		INNER JOIN dbo.Geofence geo ON geo.GeofenceId = vgh.GeofenceId AND geo.IsTemperatureMonitored = 1
		WHERE vgh.EntryDateTime BETWEEN @sdate AND @edate OR vgh.ExitDateTime BETWEEN @sdate AND @edate
		  ) gexit	  
	INNER JOIN 
		(SELECT ROW_NUMBER() OVER (PARTITION BY vgh.VehicleIntId, vgh.GeofenceId ORDER BY vgh.EntryDateTime) AS RowNum, vgh.*
		FROM dbo.VehicleGeofenceHistory vgh
		INNER JOIN dbo.Geofence geo ON geo.GeofenceId = vgh.GeofenceId AND geo.IsTemperatureMonitored = 1
		WHERE vgh.EntryDateTime BETWEEN @sdate AND @edate OR vgh.ExitDateTime BETWEEN @sdate AND @edate
		  ) gentry ON gexit.VehicleIntId = gentry.VehicleIntId AND gexit.GeofenceId = gentry.GeofenceId AND gentry.RowNum = gexit.RowNum + 1	  
	INNER JOIN dbo.Driver d ON d.DriverIntId = gexit.ExitDriverIntId
	WHERE DATEDIFF(ss, gexit.ExitDateTime, gentry.EntryDateTime) BETWEEN 2700 AND 43200 -- Real trips are between 30mins and 12 hours in duration
	  AND CAST(gexit.ExitDateTime AS TIME) > @stime
	  AND CAST(gentry.EntryDateTime AS TIME) < @etime
	  AND d.DriverId = @driverId
	GROUP BY FLOOR(CAST(gexit.ExitDateTime AS FLOAT)), gexit.ExitDriverIntId, gexit.GeofenceId

	SELECT @outsidetime = ISNULL(SUM(DATEDIFF(MINUTE, ExitDateTime, EntryDateTime)), 0)
	FROM @RealDriverTrips

	IF @duration > @depottime - @outsidetime--= 1440 -- All Day was selected so calculate actual duration from Kronos data
		SET @duration = @depottime - @outsidetime

	INSERT INTO dbo.KronosAbsense
	        ( KronosAbsenseTypeId ,
	          DriverId ,
	          UserId ,
	          Comment ,
	          LastOperation ,
	          Archived,
			  Duration,
			  Date
	        )
	VALUES  ( @absenseTypeId , -- KronosAbsenseTypeId - int
	          @driverId , -- DriverId - uniqueidentifier
	          @uid , -- UserId - uniqueidentifier
	          @comment , -- Comment - nvarchar(max)
	          GETDATE() , -- LastOperation - datetime
	          0 , -- Archived - bit
			  @duration,
			  @date
	        )


GO
