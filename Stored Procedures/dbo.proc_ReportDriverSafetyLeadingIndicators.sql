SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportDriverSafetyLeadingIndicators]
(
	@cid UNIQUEIDENTIFIER,
	@uid UNIQUEIDENTIFIER,
	@sdate datetime,
	@edate datetime
)
AS

	--DECLARE	@cid UNIQUEIDENTIFIER,
	--		@sdate datetime,
	--		@edate datetime,
	--		@uid uniqueidentifier

	--SET @cid = N'B5F43FB3-465F-4C1E-8AB2-ADF9B8FF2022'
	--SET @sdate = '2017-12-01 00:00'
	--SET @edate = '2017-12-31 23:59'
	--SET @uid = N'C13C0754-8B33-49BA-8C93-C5CE1A5F6475'

	DECLARE	@lcid UNIQUEIDENTIFIER,
			@lsdate datetime,
			@ledate datetime,
			@luid uniqueidentifier
		
	SET @lcid = @cid
	SET @lsdate = @sdate
	SET @ledate = @edate
	SET @luid = @uid



	DECLARE @diststr varchar(20),
			@distmult float,
			@fuelstr varchar(20),
			@fuelmult float,
			@co2str varchar(20),
			@co2mult FLOAT,
			@cname NVARCHAR(1024)

	SELECT @cname = Name FROM dbo.Customer WHERE CustomerId = @lcid

	SELECT @diststr = [dbo].UserPref(@luid, 203)
	SELECT @distmult = [dbo].UserPref(@luid, 202)
	SELECT @fuelstr = [dbo].UserPref(@luid, 205)
	SELECT @fuelmult = [dbo].UserPref(@luid, 204)
	SELECT @co2str = [dbo].UserPref(@luid, 211)
	SELECT @co2mult = [dbo].UserPref(@luid, 210)

	SET @lsdate = [dbo].TZ_ToUTC(@lsdate,default,@luid)
	SET @ledate = [dbo].TZ_ToUTC(@ledate,default,@luid)

	SELECT	@cname AS Customer,
			gr.GroupName,
			o.TotalDrivingDistance,
			o.DistanceUnit,
			o.FuelConsumption,
			o.FuelConsumptionUnit,
			o.ROP2Count,
			o.BrakingCount,
			o.OverspeedDistance,
			o.OverspeedHighDistance
	FROM
	(
		SELECT
			CASE WHEN (GROUPING(vg.GroupId) = 1) THEN NULL
				ELSE ISNULL(vg.GroupId, NULL)
			END AS GroupId,
		

			ROUND(SUM(DrivingDistance * 1000 * @distmult), 2) AS TotalDrivingDistance,
			@diststr AS DistanceUnit,

			ROUND((CASE WHEN @fuelmult = 0.1 THEN
				(CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel * ISNULL(FuelMultiplier,1.0))*100 END)/SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) 
			ELSE
				(SUM(DrivingDistance + ISNULL(PTOMovingDistance,0)) * 1000) / (CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel * ISNULL(FuelMultiplier,1.0)) END) * @fuelmult END), 2) AS FuelConsumption,
			@fuelstr AS FuelConsumptionUnit,

			ISNULL(SUM(ROP2Count), 0) AS ROP2Count,
			ISNULL(SUM(abc.BrakingHigh), 0) AS BrakingCount,
		
			ROUND(ISNULL(SUM(ro.OverSpeedDistance), 0.00) * 1000 * @distmult, 2) AS OverspeedDistance,
			ROUND(ISNULL(SUM(ro.OverSpeedHighDistance), 0.00) * 1000 * @distmult, 2) AS OverspeedHighDistance

		FROM dbo.Reporting r
			INNER JOIN dbo.Vehicle v ON r.VehicleIntId = v.VehicleIntId
			INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
			INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
			INNER JOIN dbo.GroupDetail vgd ON v.VehicleId = vgd.EntityDataId
			INNER JOIN dbo.[Group] vg ON vgd.GroupId = vg.GroupId 
			INNER JOIN dbo.UserGroup ug ON ug.GroupId = vg.GroupId
			LEFT JOIN dbo.ReportingABC abc ON r.VehicleIntId = abc.VehicleIntId AND r.DriverIntId = abc.DriverIntId AND r.Date = abc.Date --AND r.RouteID = abc.RouteId
			LEFT JOIN dbo.ReportingOverspeed ro ON r.VehicleIntId = ro.VehicleIntId AND r.DriverIntId = ro.DriverIntId AND r.Date = ro.Date --AND r.RouteID = ro.RouteId

		WHERE r.Date BETWEEN @lsdate AND @ledate 
			AND c.CustomerId = @lcid
			AND ug.UserId = @luid
			AND r.DrivingDistance > 0
			AND v.Archived = 0
			AND vg.IsParameter = 0 
			AND vg.Archived = 0 
			AND ug.Archived = 0
		GROUP BY vg.GroupId WITH CUBE
		HAVING SUM(DrivingDistance) > 10 
	) o
		LEFT JOIN dbo.[Group] gr ON o.GroupId = gr.GroupId AND gr.IsParameter = 0 AND gr.Archived = 0
	ORDER BY gr.GroupName

GO
