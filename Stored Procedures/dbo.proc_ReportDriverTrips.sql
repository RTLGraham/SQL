SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportDriverTrips]
(
	@did UNIQUEIDENTIFIER,
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER
)
AS
BEGIN

--DECLARE @did UNIQUEIDENTIFIER,
--		@sdate datetime,
--		@edate datetime,
--		@uid UNIQUEIDENTIFIER

--SET @did = N'8849616D-BE6E-4C5B-B17F-3491E405A349' -- Private
----SET @did = N'C2D55299-3F94-4DE5-BAE7-31C0A5768B32' -- Working
--SET @sdate = '2016-07-28 00:00'
--SET @edate = '2016-07-28 23:59'
--SET @uid = N'495660B8-646B-43F6-8CE5-976280C834B2'

	DECLARE @diststr NVARCHAR(10),
			@distmult FLOAT

	SELECT @diststr = [dbo].UserPref(@uid, 203)
	SELECT @distmult = [dbo].UserPref(@uid, 202)

	SET @sdate = dbo.TZ_ToUtc(@sdate, DEFAULT, @uid)
	SET @edate = dbo.TZ_ToUtc(@edate, DEFAULT, @uid)

-- ResultSet to provide individual trip details
	SELECT  dt.DriverTripId,
	        d.DriverId,
	        dbo.FormatDriverNameByUser(d.DriverId, @uid) AS Drivername,
	        v.VehicleId,
	        v.Registration,
	        dbo.TZ_GetTime(dt.StartEventDateTime, DEFAULT, @uid) AS TripStart,
	        dt.StartLat,
	        dt.StartLong,
	        dbo.GetGeofenceNameFromLongLat (dt.StartLat, dt.StartLong, @uid, dbo.GetAddressFromLongLat (dt.StartLat, dt.StartLong)) as StartLocation,
	        dbo.TZ_GetTime(dt.EndEventDateTime, DEFAULT, @uid) AS TripEnd,
	        dt.EndLat,
	        dt.EndLong,
	        dbo.GetGeofenceNameFromLongLat (dt.EndLat, dt.EndLong, @uid, dbo.GetAddressFromLongLat (dt.EndLat, dt.EndLong)) as EndLocation,
	        dt.TripDistance * @distmult AS TripDistance,
	        @diststr AS DistanceUnit,
	        dt.TripDuration,
	        dt.IsBusiness,
			CASE WHEN cp.Value = '1' THEN ISNULL(d.PlayInd, 0) ELSE 0 END AS IsHidden, -- Take IsHidden from Driver.PlayInd when customer uses work/play Driver Mode
	        dt.Comment,
--	        dt.TripDistance * @distmult * COALESCE(NULLIF(v.ClaimRate,0), CASE WHEN dt.IsBusiness = 1 THEN mcc.BusinessPencePerMile ELSE mcc.PrivatePencePerMile END, 0)/100.0 AS Amount
			dt.TripDistance * @distmult * dbo.GetClaimRateForDriver(d.DriverId, v.FuelTypeId, v.EngineSize, dt.StartEventDateTime) / 100.0 AS Amount
	FROM dbo.DriverTrip dt
	INNER JOIN dbo.Driver d ON dt.DriverIntId = d.DriverIntId
	INNER JOIN dbo.Vehicle v ON dt.VehicleIntId = v.VehicleIntId
	INNER JOIN dbo.CustomerDriver cd ON cd.DriverId = d.DriverId
	LEFT JOIN dbo.CustomerPreference cp ON cp.CustomerID = cd.CustomerId AND cp.NameID = 3001
--	INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
--	INNER JOIN dbo.MileageClaimCustomer mcc ON cv.CustomerId = mcc.CustomerId
	WHERE d.DriverId = @did
	  AND dt.StartEventDateTime BETWEEN @sdate AND @edate
	  AND dt.Archived = 0
	  AND cd.Archived = 0
	  AND cd.EndDate IS NULL
	  AND dt.TripDistance >= 1
	ORDER BY dt.StartEventDateTime DESC

END


GO
