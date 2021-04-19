SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportLogDataDaily]
	@vids   NVARCHAR(MAX),
	@sdate  DATETIME,
	@edate  DATETIME,
	@uid    UNIQUEIDENTIFIER

AS
SET NOCOUNT ON;

--DECLARE	@uid	UNIQUEIDENTIFIER,
--		@vids   NVARCHAR(MAX),
--		@sdate  DATETIME,
--		@edate  DATETIME
		
--SET @uid = N'F119F353-330C-48C9-9A21-5DD95F279749' -- ArrivaAdmin
--SET @vids = N'CC7F2300-76BC-4760-BA01-2FB1B81B9815,88678201-1353-4239-959D-36144E0CBA18,1848B7A6-99E5-486F-A0F5-ECE4CD1B0CDA,DAE0E727-BFFA-4454-9F64-FC87C13EFBC9'
--SET @sdate = '2014-11-01 11:00'
--SET @edate = '2014-11-30 23:59'

DECLARE @s_date DATETIME,
		@e_date DATETIME

SET @s_date = dbo.TZ_ToUtc(@sdate, DEFAULT, @uid)
SET @e_date = dbo.TZ_ToUtc(@edate, DEFAULT, @uid)

DECLARE @diststr VARCHAR(20),
        @distmult FLOAT,
        @fuelstr VARCHAR(20),
        @fuelmult FLOAT,
		@liquidstr varchar(20),
		@liquidmult float

SELECT  @diststr = [dbo].UserPref(@uid, 203)
SELECT  @distmult = [dbo].UserPref(@uid, 202)
SELECT  @fuelstr = [dbo].UserPref(@uid, 205)
SELECT  @fuelmult = [dbo].UserPref(@uid, 204)
SELECT  @liquidstr = [dbo].UserPref(@uid, 201)
SELECT  @liquidmult = [dbo].UserPref(@uid, 200)

SELECT	v.VehicleId,
		v.Registration,
		v.FleetNumber,
		MAX(lg.RunTime) - MIN(lg.RunTime) AS RunTime,
		MAX(lg.DecelTime) - MIN(lg.DecelTime) AS DecelTime,
		MAX(lg.StatTime) - MIN(lg.StatTime) AS StatTime,
		MAX(lg.EcoTime) - MIN(lg.EcoTime) AS EcoTime,
		(MAX(lg.TotalDistance) - MIN(lg.TotalDistance)) * 1000 * @distmult AS TotalDistance,
		(MAX(lg.MovingFuel) - MIN(lg.MovingFuel)) * @liquidmult AS MovingFuel,
		(MAX(lg.StatFuel) - MIN(lg.StatFuel)) * @liquidmult AS StatFuel,
		(CASE WHEN @fuelmult = 0.1 THEN
			-- L/100KM
			(((MAX(lg.MovingFuel) - MIN(lg.MovingFuel)) + (MAX(lg.StatFuel) - MIN(lg.StatFuel)))*100)/dbo.ZeroYieldNull((MAX(lg.TotalDistance) - MIN(lg.TotalDistance)))
		ELSE
			--MPG
			((MAX(lg.TotalDistance) - MIN(lg.TotalDistance)) * 1000) / dbo.ZeroYieldNull(((MAX(lg.MovingFuel) - MIN(lg.MovingFuel)) + (MAX(lg.StatFuel) - MIN(lg.StatFuel)))) * @fuelmult END) AS FuelEcon,
		@sdate AS CreationdateTime,
		@edate AS ClosureDateTime,
		@diststr AS diststr,
		@fuelstr AS fuelstr,
		@liquidstr AS liquidstr
FROM dbo.Vehicle v
INNER JOIN dbo.LogData lg ON v.VehicleIntId = lg.VehicleIntId
WHERE 
	v.VehicleId IN (SELECT VALUE FROM dbo.Split(@vids, ','))
	AND 
	lg.LogDateTime BETWEEN @s_date AND @e_date
GROUP BY v.VehicleId, v.Registration, v.FleetNumber
ORDER BY v.FleetNumber DESC




		

GO
