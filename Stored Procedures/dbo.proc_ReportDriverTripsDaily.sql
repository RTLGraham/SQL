SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportDriverTripsDaily]
(
	@did UNIQUEIDENTIFIER,
	@sdate datetime,
	@edate datetime,
	@uid UNIQUEIDENTIFIER,
  @isBusiness BIT
)
AS
BEGIN

--DECLARE @did UNIQUEIDENTIFIER,
--		@sdate datetime,
--		@edate datetime,
--		@uid UNIQUEIDENTIFIER,
--		@isBusiness BIT
--
--SET @did = N'693DEF8B-816F-48D7-BE47-CFC32DC7511E'
--SET @sdate = '2014-02-17 00:00'
--SET @edate = '2014-02-24 23:59'
--SET @uid = N'CC161974-93BE-45EF-9D32-D411F7306885'
--SET @isBusiness = 1

	DECLARE @diststr NVARCHAR(10),
			@distmult FLOAT

	SELECT @diststr = [dbo].UserPref(@uid, 203)
	SELECT @distmult = [dbo].UserPref(@uid, 202)

	SET @sdate = dbo.TZ_ToUtc(@sdate, DEFAULT, @uid)
	SET @edate = dbo.TZ_ToUtc(@edate, DEFAULT, @uid)

-- ResultSet to provide Daily Summary by Vehicle
	SELECT  d.DriverId,
	        dbo.FormatDriverNameByUser(d.DriverId, @uid) AS Drivername,
	        v.Registration,
            DATEADD(dd, DATEDIFF(dd, 0, dbo.TZ_GetTime(dt.StartEventDateTime, DEFAULT, @uid)), 0) AS Date,
	        MIN(dt.StartOdo) * @distmult AS StartOdo,
	        MAX(dt.EndOdo) * @distmult AS EndOdo,
	        SUM(dt.TripDistance) * @distmult AS TripDistance,
	        @diststr AS DistanceUnit,
--            SUM(dt.TripDistance * @distmult * dbo.GetClaimRateForDriver(d.DriverId, v.FuelTypeId, v.EngineSize, dt.StartEventDateTime))/100.0 AS Amount
            SUM(dt.TripDistance * @distmult * CASE WHEN dt.IsBusiness = @isBusiness THEN dbo.GetClaimRateForDriver(d.DriverId, v.FuelTypeId, v.EngineSize, dt.StartEventDateTime) ELSE 0 END)/100.0 AS Amount
	FROM dbo.DriverTrip dt
	INNER JOIN dbo.Driver d ON dt.DriverIntId = d.DriverIntId
	INNER JOIN dbo.Vehicle v ON dt.VehicleIntId = v.VehicleIntId
--	INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
--	INNER JOIN dbo.MileageClaimCustomer mcc ON cv.CustomerId = mcc.CustomerId
	WHERE d.DriverId = @did
	  AND dt.StartEventDateTime BETWEEN @sdate AND @edate
	  AND dt.Archived = 0
	  AND dt.TripDistance >= 1
            AND dt.IsBusiness = @isbusiness
	GROUP BY d.DriverId,
                   v.Registration,
                   DATEADD(dd, DATEDIFF(dd, 0, dbo.TZ_GetTime(dt.StartEventDateTime, DEFAULT, @uid)), 0)
--                   v.ClaimRate,
--                   mcc.BusinessPencePerMile,
--                   mcc.PrivatePencePerMile
	ORDER BY DATEADD(dd, DATEDIFF(dd, 0, dbo.TZ_GetTime(dt.StartEventDateTime, DEFAULT, @uid)), 0) DESC, v.Registration ASC

END



GO
