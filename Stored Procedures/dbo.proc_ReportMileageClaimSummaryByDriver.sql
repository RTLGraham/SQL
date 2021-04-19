SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_ReportMileageClaimSummaryByDriver]
(
	@did UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME,
	@uid UNIQUEIDENTIFIER
)
AS
BEGIN

--DECLARE @did UNIQUEIDENTIFIER,
--		@sdate datetime,
--		@edate datetime,
--		@uid UNIQUEIDENTIFIER

--SET @did = N'F645980A-9A2C-4062-B5A1-F5CADF29EF6F'
--SET @did = N'3ED02C1D-7291-4B2A-885C-B519CA640554'
--SET @did = N'045BAF39-6C9D-457C-A2AB-7DA25E04A006'
--SET @sdate = '2017-05-16 00:00'
--SET @edate = '2017-05-16 23:59'
--SET @uid = N'F9B76BD3-6490-48D5-AF90-DFC4F124B3BD'

	DECLARE @diststr NVARCHAR(10),
			@distmult FLOAT,
			@workplaymode TINYINT,
			@ldid UNIQUEIDENTIFIER,
			@lsdate DATETIME,
			@ledate DATETIME,
			@luid UNIQUEIDENTIFIER

	SELECT @diststr = [dbo].UserPref(@uid, 203)
	SELECT @distmult = [dbo].UserPref(@uid, 202)
	SET @ldid = @did
	SET @lsdate = @sdate
	SET @ledate = @edate
	SET @luid = @uid

	SET @lsdate = dbo.TZ_ToUtc(@lsdate, DEFAULT, @luid)
	SET @ledate = dbo.TZ_ToUtc(@ledate, DEFAULT, @luid)

	--Determine the work/play mode for the customer to identify if trips are defaulted to business or private
	SELECT @workplaymode = ISNULL(dbo.CustomerPref(c.CustomerId, 3001), 0)
	FROM dbo.[User] u
	INNER JOIN dbo.Customer c ON c.CustomerId = u.CustomerID
	WHERE u.UserID = @luid

	DECLARE @results TABLE
    (
		DriverTripId BIGINT,
		DriverId UNIQUEIDENTIFIER,
		VehicleId UNIQUEIDENTIFIER,
		Registration VARCHAR(20),
		TripStart DATETIME,
		StartOdo INT,
		StartLat FLOAT,
		StartLong FLOAT,
		TripEnd DATETIME,
		EndOdo INT,
		EndLat FLOAT,
		EndLong FLOAT,
		TripDistance FLOAT,
		TripDuration INT,
		IsBusiness TINYINT,
		IsHidden TINYINT,
		Comment VARCHAR(200),
		Amount FLOAT
	)

	INSERT INTO @results
	        (DriverTripId,
	         DriverId,
	         VehicleId,
			 Registration,
	         TripStart,
			 StartOdo,
	         StartLat,
	         StartLong,
	         TripEnd,
			 EndOdo,
	         EndLat,
	         EndLong,
	         TripDistance,
	         TripDuration,
	         IsBusiness,
	         IsHidden,
	         Comment,
	         Amount
	        )
	SELECT  ts.TripsAndStopsId AS DriverTripId,
	        d.DriverId,
	        v.VehicleId,
	        v.Registration,
	        dbo.TZ_GetTime(ts.Timestamp, DEFAULT, @luid) AS TripStart,
			se.OdoGPS + ISNULL(voo.OdometerOffset * 1000, 0),
	        ts.Latitude AS StartLat,
	        ts.Longitude AS StartLong,
	        dbo.TZ_GetTime(te.Timestamp, DEFAULT, @luid) AS TripEnd,
			ee.OdoGPS + ISNULL(voo.OdometerOffset * 1000, 0),
	        te.Latitude AS EndLat,
	        te.Longitude AS EndLong,
	        te.TripDistance * @distmult * 100 AS TripDistance,
	        te.Duration AS TripDuration,
			CASE WHEN @workplaymode = 2 THEN
				CASE WHEN ISNULL(wp.PlayInd, 1) = 0 THEN 1 ELSE 0 END	
			ELSE
				CASE WHEN ISNULL(wp.PlayInd, 0) = 0 THEN 1 ELSE 0 END
			END AS IsBusiness,
			0 AS IsHidden, 
	        wp.Comment,
			te.TripDistance * @distmult * 100 * dbo.GetClaimRateForDriver(d.DriverId, v.FuelTypeId, v.EngineSize, ts.Timestamp) / 100.0 AS Amount
	FROM dbo.TripsAndStops ts WITH (NOLOCK)
	INNER JOIN dbo.Event se WITH (NOLOCK) ON ts.EventID = se.EventId
	INNER JOIN dbo.TripsAndStops te WITH (NOLOCK) ON te.previousid = ts.tripsandstopsid
	INNER JOIN dbo.Event ee WITH (NOLOCK) ON te.EventID = ee.EventId
	INNER JOIN dbo.Driver d ON te.DriverIntID = d.DriverIntId
	INNER JOIN dbo.Vehicle v ON te.VehicleIntId = v.VehicleIntId
	LEFT JOIN dbo.VehicleOdoOffset voo ON voo.VehicleIntId = v.VehicleIntId
	LEFT JOIN dbo.TripsAndStopsWorkPlay wp ON wp.TripsAndStopsId = ts.TripsAndStopsId
	WHERE d.DriverId = @ldid
	  AND ts.Timestamp BETWEEN @lsdate AND @ledate
	  AND te.Timestamp BETWEEN @lsdate AND @ledate
	  AND ts.Archived = 0
	  AND te.Archived = 0
	  and te.vehiclestate = 5
	ORDER BY ts.Timestamp

	--SELECT r.DriverTripId,
 --          r.DriverId,
	--	   dbo.FormatDriverNameByUser(r.DriverId, @luid) AS Drivername,
 --          r.VehicleId,
 --          r.Registration,
 --          r.TripStart,
 --          r.StartLat,
 --          r.StartLong,
	--	   dbo.GetGeofenceNameFromLongLat (r.StartLat, r.StartLong, @luid, dbo.GetAddressFromLongLat (r.StartLat, r.StartLong)) AS StartLocation,
 --          r.TripEnd,
 --          r.EndLat,
 --          r.EndLong,
	--	   dbo.GetGeofenceNameFromLongLat (r.EndLat, r.EndLong, @luid, dbo.GetAddressFromLongLat (r.EndLat, r.EndLong)) AS EndLocation,
 --          r.TripDistance,
	--	   @diststr AS DistanceUnit,
 --          r.TripDuration,
 --          r.IsBusiness,
 --          r.IsHidden,
 --          r.Comment,
 --          r.Amount
	--	   --tot.StartOdo,
	--	   --tot.EndOdo,
	--	   --tot.BusinessDistance,
	--	   --tot.PrivateDistance,
	--	   --tot.TotalDistance
	--FROM @results r
	----CROSS JOIN (
	----			SELECT	MIN(t.StartOdo) * @distmult AS StartOdo,
	----					MAX(t.EndOdo) * @distmult AS EndOdo,
	----					SUM(CASE WHEN t.IsBusiness = 1 THEN t.TripDistance ELSE 0 END) AS BusinessDistance,
	----					SUM(CASE WHEN t.IsBusiness = 0 THEN t.TripDistance ELSE 0 END) AS PrivateDistance,
	----					SUM(t.TripDistance) AS TotalDistance
	----			FROM @results t
	----			) tot


	SELECT	t.VehicleId, Registration,
			MIN(t.StartOdo) * @distmult AS StartOdo,
			MAX(t.EndOdo) * @distmult AS EndOdo,
			SUM(CASE WHEN t.IsBusiness = 1 THEN t.TripDistance ELSE 0 END) AS BusinessDistance,
			SUM(CASE WHEN t.IsBusiness = 0 THEN t.TripDistance ELSE 0 END) AS PrivateDistance,
			SUM(t.TripDistance) AS TotalDistance,
			SUM(t.Amount) AS Amount,
			@diststr AS DistanceUnit
	FROM @results t
	GROUP BY t.VehicleId, t.Registration

END




GO
