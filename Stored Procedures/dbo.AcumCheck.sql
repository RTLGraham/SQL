SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[AcumCheck]
(
	@sdate DATETIME,
	@edate DATETIME
)
AS		

--SET @sdate = '2012-06-18 00:00' 
--SET @edate = '2012-06-18 23:59' 


SELECT	
	a.AccumId,
	a.VehicleIntId,
	v.Registration,
	
	a.CreationDateTime,
	a.ClosureDateTime,
	
	CONVERT(CHAR(8), DATEADD(SECOND,CONVERT(INT, a.IdleTime+a.DrivingTime), '00:00:00'), 108) AS TotalTime,
	a.IdleFuel+a.DrivingFuel + a.ShortIdleFuel+a.ptomovingfuel+a.ptononmovingfuel AS TotalFuel,
	
	a.DrivingDistance AS DrDist,
	CONVERT(CHAR(8), DATEADD(SECOND,CONVERT(INT, a.DrivingTime), '00:00:00'), 108) AS DrTime,
	a.DrivingFuel AS DrFuel, 
	
	--a.DrivingDistance/dbo.ZeroYieldNull(a.DrivingFuel) as DrivingEconomy,
	ISNULL(ROUND(a.DrivingDistance/dbo.ZeroYieldNull(a.IdleFuel+a.DrivingFuel + a.ShortIdleFuel+a.ptomovingfuel+a.ptononmovingfuel),2),0) AS KPL,
	ISNULL(ROUND((a.DrivingDistance*0.621371192)/(dbo.ZeroYieldNull(a.IdleFuel+a.DrivingFuel + a.ShortIdleFuel+a.ptomovingfuel+a.ptononmovingfuel)*0.219969157),2),0) AS MPG,
	
	CONVERT(CHAR(8), DATEADD(SECOND,CONVERT(INT, a.InSweetSpotTime), '00:00:00'), 108) AS SSTime,
	CAST(a.InSweetSpotTime AS FLOAT)/dbo.ZeroYieldNull(CAST(a.DrivingTime AS FLOAT)) AS SSTPercent,
	a.InSweetSpotFuel AS FuelSS, 
	a.InSweetSpotFuel/dbo.ZeroYieldNull(a.IdleFuel+a.DrivingFuel + a.ShortIdleFuel+a.ptomovingfuel+a.ptononmovingfuel) AS FuelSSPercent, 
	a.InSweetSpotDistance AS SSDist,
	a.InSweetSpotDistance/dbo.ZeroYieldNull(a.DrivingDistance) AS SSDistPercent,
	--a.InSweetSpotDistance/dbo.ZeroYieldNull(a.DrivingFuel) as SweetSpotEconomy,
	CONVERT(CHAR(8), DATEADD(SECOND,CONVERT(INT, a.FueledOverRPMTime), '00:00:00'), 108) AS ORTime,
	CAST(a.FueledOverRPMTime AS FLOAT)/dbo.ZeroYieldNull(CAST(a.DrivingTime AS FLOAT)) AS ORTimePercent,
	a.FueledOverRPMFuel AS FuelOR,
	a.FueledOverRPMFuel/dbo.ZeroYieldNull(a.IdleFuel+a.DrivingFuel + a.ShortIdleFuel+a.ptomovingfuel+a.ptononmovingfuel) AS FuelORPercent,
	a.FueledOverRPMDistance AS ORDist,
	a.FueledOverRPMDistance/dbo.ZeroYieldNull(a.DrivingDistance) AS ORDistPercent,
	CAST(a.IdleTime AS FLOAT) / 3600.0 AS IdleTime,
	CAST(a.IdleTime AS FLOAT)/dbo.ZeroYieldNull(CAST((a.IdleTime+a.DrivingTime) AS FLOAT)) AS IdleTimePercent,
	a.IdleFuel AS FuelIdle,
	ISNULL(a.EngineBrakeDistance / dbo.ZeroYieldNull(a.ServiceBrakeDistance + a.EngineBrakeDistance),0) AS EngineServiceBrakeRatio,
	ISNULL(a.ServiceBrakeDistance + a.EngineBrakeDistance/dbo.ZeroYieldNull(a.DrivingDistance),0) AS EngineServiceBrakeDistPercent
FROM Accum a
	INNER JOIN dbo.Vehicle v ON a.VehicleIntId = v.VehicleIntId
	INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
	INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
WHERE a.CreationDateTime BETWEEN @sdate AND @edate
	AND c.Name = 'Nestle Switzerland'
ORDER BY a.CreationDateTime
GO
