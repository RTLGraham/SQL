SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_ReportTemperatureScoreByVehicle]
(
	@vids NVARCHAR(MAX) = NULL,
	@gids NVARCHAR(MAX) = NULL,
	@sdate DATETIME,
	@edate DATETIME,
	@sensorid SMALLINT = NULL,
	@uid UNIQUEIDENTIFIER
)
AS

-- 19/07/16 gp/as added 2 additional over temperature bands 
-- 26/06/19 gp removed calculation of real trips and linked directly to ReportingNCE to get data instead

--DECLARE @vids NVARCHAR(MAX),
--		@gids NVARCHAR(MAX),
--		@sdate DATETIME,
--		@edate DATETIME,
--		@sensorid SMALLINT,
--		@uid UNIQUEIDENTIFIER

--SET @vids = N'1D3D521A-9CFF-4B73-BC2E-97ADB314A3A2'
--SET @gids = N'EA6DE145-B1B2-4D63-8239-33E8865A29B1' 
--SET @sdate = '2019-06-19 00:00'
--SET @edate = '2019-06-19 23:59'
--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'

DECLARE @lvids NVARCHAR(MAX),
		@lgids NVARCHAR(MAX),
		@lsdate DATETIME,
		@ledate DATETIME,
		@lsensorid SMALLINT,
		@luid UNIQUEIDENTIFIER
		
SET @lvids = @vids
SET @lgids = @gids
SET @lsdate = @sdate
SET @ledate = @edate
SET @lsensorid = @sensorid
SET @luid = @uid

DECLARE @tempmult FLOAT,
		@liquidmult FLOAT,
		@templimit FLOAT,
		@tempdepart FLOAT,
		@productsensorid SMALLINT,
		@internalsensorid SMALLINT,
		@externalsensorid SMALLINT,
		@stime TIME,
		@etime TIME
    
SET @tempmult = ISNULL([dbo].[UserPref](@luid, 214),1)
SET @liquidmult = ISNULL([dbo].[UserPref](@luid, 200),1)
-- Sensor Id and Temperature Limit are currently hard-coded
SET @internalsensorid = 1
SET @productsensorid = 2
SET @externalsensorid = 4
SET @templimit = -18.0
SET @tempdepart = -25.0
SET @lsdate = dbo.TZ_ToUtc(@lsdate, DEFAULT, @luid)
SET @ledate = dbo.TZ_ToUtc(@ledate, DEFAULT, @luid)

-- Use table variable to identify vehicles required and get associated sensor scaling factor and total time outside geofences
DECLARE @VehicleScaling TABLE (
	GroupId UNIQUEIDENTIFIER,
	VehicleIntId INT,
	InternalScaleFactor FLOAT,
	ProductScaleFactor FLOAT,
	ExternalScaleFactor FLOAT,
	OutsideTime BIGINT )
INSERT INTO @VehicleScaling (GroupId, VehicleIntId, InternalScaleFactor, ProductScaleFactor, ExternalScaleFactor, OutsideTime)
SELECT g.GroupId, v.VehicleIntId, vsi.AnalogSensorScalefactor, vsp.AnalogSensorScaleFactor, vse.AnalogSensorScaleFactor, SUM(nce.OutsideDuration)--DATEDIFF(ss, @lsdate, @ledate) - SUM(DATEDIFF(ss, CASE WHEN vgh.EntryDateTime < @lsdate THEN @lsdate ELSE vgh.EntryDateTime END, CASE WHEN ISNULL(vgh.ExitDateTime, @ledate) > @ledate THEN @ledate ELSE ISNULL(vgh.ExitDateTime, @ledate) END))
FROM dbo.Vehicle v 
INNER JOIN dbo.ReportingNCE nce ON nce.VehicleIntId = v.VehicleIntId
INNER JOIN dbo.GroupDetail gd ON v.VehicleId = gd.EntityDataId
INNER JOIN dbo.[Group] g ON gd.GroupId = g.GroupId
INNER JOIN dbo.VehicleSensor vsi ON v.VehicleIntId = vsi.VehicleIntId AND vsi.SensorId = @internalsensorid
INNER JOIN dbo.VehicleSensor vsp ON v.VehicleIntId = vsp.VehicleIntId AND vsp.SensorId = @productsensorid
INNER JOIN dbo.VehicleSensor vse ON v.VehicleIntId = vse.VehicleIntId AND vse.SensorId = @externalsensorid
WHERE v.VehicleId IN (SELECT VALUE FROM dbo.Split(@lvids, ','))
  AND gd.GroupId IN (SELECT VALUE	FROM dbo.Split(@lgids, ','))
  AND nce.Date BETWEEN @sdate AND @edate
  AND v.Archived = 0
  AND g.IsParameter = 0
  AND g.GroupTypeId = 1
  AND g.Archived = 0
GROUP BY g.GroupId, v.VehicleIntId, vsi.AnalogSensorScaleFactor, vsp.AnalogSensorScaleFactor, vse.AnalogSensorScaleFactor

SELECT	g.GroupName, 
		v.Registration, 
		vs.OutsideTime, 
		ISNULL(SUM(nce.OverLimitDuration),0) AS OverTempDuration,
		ISNULL(SUM(nce.OverLimit2Duration),0) AS OverTemp2Duration,
		ISNULL(SUM(nce.OverLimit3Duration),0) AS OverTemp3Duration,
		ISNULL(checkout.CheckOutCount,0) + ISNULL(releases.Released,0) - ISNULL(checkout.DefrostCount,0) AS Confirmed,
		ISNULL(SUM(alarms.AlarmCount),0) - (ISNULL(checkout.CheckOutCount,0)  - ISNULL(checkout.DefrostCount,0) + ISNULL(releases.Released,0)) AS NonConfirmed,
		dbo.ScaleConvertAnalogValue(AVG(nce.AnalogData1AvgInside),vs.ProductScaleFactor, @tempmult, @liquidmult) AS AvgProductTempInside,
		dbo.ScaleConvertAnalogValue(AVG(nce.AnalogData1AvgOutside),vs.ProductScaleFactor, @tempmult, @liquidmult) AS AvgProductTempOutside,
		dbo.ScaleConvertAnalogValue(AVG(nce.AnalogData3AvgOutside),vs.ExternalScaleFactor, @tempmult, @liquidmult) AS AvgExternalTempOutside,
		ISNULL(checkout.DefrostCount,0) AS DefrostCount
FROM @VehicleScaling vs
INNER JOIN dbo.Vehicle v ON vs.VehicleIntId = v.VehicleIntId
INNER JOIN dbo.[Group] g ON vs.GroupId = g.GroupId
INNER JOIN dbo.ReportingNCE nce ON vs.VehicleIntId = nce.VehicleIntId

-- The following line is intended to exclude outlier data (where the sensors are marked invalid).
-- We test T1 (the Product Sensor) as this is the sensor that drives the KPIs (additional sensors can be addde if required)
INNER JOIN dbo.Maintenance m ON m.VehicleIntId = nce.VehicleIntId AND nce.Date = m.Date AND m.T1 = 1

LEFT JOIN  (SELECT vs.VehicleIntId, ISNULL(SUM(CAST(ISNULL(ts.Ack, 0) AS INT)),0) AS Released
			FROM @VehicleScaling vs
			INNER JOIN dbo.TemperatureStatus ts ON vs.VehicleIntId = dbo.GetVehicleIntFromId(ts.VehicleId)
			WHERE ts.AckDateTime BETWEEN @lsdate AND @ledate
			GROUP BY vs.VehicleIntId) releases ON vs.VehicleIntId = releases.VehicleIntId			
LEFT JOIN  (SELECT vs.VehicleIntId, SUM(CASE WHEN tec.CheckOutReason IN ('Defrosting','Abtauen','Dégelé','Sbrinare') THEN 1 ELSE 0 END) AS DefrostCount,
			COUNT(*) AS CheckOutCount
			FROM @VehicleScaling vs
			INNER JOIN dbo.TAN_EntityCheckOut tec ON vs.VehicleIntId = dbo.GetVehicleIntFromId(tec.EntityId)
--			WHERE tec.CheckOutDateTime BETWEEN @lsdate AND @ledate
			WHERE tec.CheckOutDateTime <= @ledate AND ISNULL(tec.CheckInDateTime, @ledate) >= @lsdate
			GROUP BY vs.VehicleIntId) checkout ON vs.VehicleIntId = checkout.VehicleIntId
LEFT JOIN  (SELECT vs.VehicleIntId, nce.Date, SUM(CASE WHEN dbo.ScaleConvertAnalogValue(nce.AnalogData1Timed, vs.ProductScaleFactor, @tempmult, @liquidmult) > -25 THEN 1 ELSE 0 END) AS AlarmCount
			FROM @VehicleScaling vs
			INNER JOIN dbo.ReportingNCE nce ON vs.VehicleIntId = nce.VehicleIntId
			LEFT JOIN dbo.TAN_EntityCheckOut tec ON vs.VehicleIntId = dbo.GetVehicleIntFromId(tec.EntityId)
															  AND tec.CheckOutDateTime <= @ledate AND ISNULL(tec.CheckInDateTime, @ledate) >= @lsdate
			WHERE nce.Date BETWEEN @lsdate AND @ledate
			  AND tec.EntityId IS NULL
			GROUP BY vs.VehicleIntId, nce.Date) alarms ON vs.VehicleIntId = alarms.VehicleIntId AND nce.date = alarms.Date
WHERE nce.Date BETWEEN @lsdate AND @ledate
GROUP BY g.GroupName, v.Registration, vs.OutsideTime, 
releases.Released, 
--overtempcounts.OverDepartTemp, 
checkout.DefrostCount, checkout.CheckOutCount, 
vs.InternalScaleFactor, vs.ProductScaleFactor, vs.ExternalScaleFactor
ORDER BY g.GroupName, v.Registration

GO
