SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[proc_Report_Trips]
	@did UNIQUEIDENTIFIER,
          @uid UNIQUEIDENTIFIER,
          @rprtcfgid UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME
AS

--DECLARE @did UNIQUEIDENTIFIER, 
--		@sdate DATETIME, 
--		@edate DATETIME, 
--		@uid UNIQUEIDENTIFIER, 
--		@rprtcfgid UNIQUEIDENTIFIER
--		
--SET		@did = N'E5A08347-77C2-4250-890F-06AD0D5DA177' 
--SET		@sdate = '2012-03-03 00:00'
--SET		@edate = '2012-03-03 23:59'
--SET		@uid = N'3DB40C4A-7E79-4F41-8017-DE6E12EC7A20'
--SET		@rprtcfgid = N'77C80BDB-5827-4C5E-BBF4-06F36ACB47D6'


DECLARE @diststr varchar(50)
DECLARE @distmult float
DECLARE @fuelstr varchar(50)
DECLARE @fuelmult float
DECLARE @s_date smalldatetime
DECLARE @e_date smalldatetime
DECLARE @language varchar(20)

/* Convert time to UTC */
SET @sdate = [dbo].TZ_ToUTC(@sdate,default,@uid)
SET @edate = [dbo].TZ_ToUTC(@edate,default,@uid)

--SET @language = dbo.GetUserLanguage(@uid)
--SET LANGUAGE @language
--SET DATEFORMAT mdy -- reset back to default because SET LANGUAGE may have changed it

SELECT @diststr = [dbo].UserPref(@uid, 203)
SELECT @distmult = [dbo].UserPref(@uid, 202)
SELECT @fuelstr = [dbo].UserPref(@uid, 205)
SELECT @fuelmult = [dbo].UserPref(@uid, 204)

SELECT
		Registration,
		VehicleType,
		Surname,
		CreationDateTime,
		ClosureDateTime,
		DrivingTime,
		DrivingDistance,
		IdleTime,
		IdleFuel,
		SweetSpotTime,
		FracSweetSpotDistance,
		SweetSpotDistance,
		DrivingFuel,
		FuelEcon,
--		MPG,
		AveRPM,
		AveDrivingRPM,
		OverRevTime,
		OverRevDistance,
		OverRevFuel,
		Efficiency,
		dbo.GYRColourConfig(Efficiency, 14, @rprtcfgid) AS EfficiencyColour,
		Acceleration,
		Braking,
		Cornering,
		Safety,
		dbo.GYRColourConfig(Safety, 15, @rprtcfgid) AS SafetyColour,
		CO2
		
FROM

	(SELECT *,
		
		Efficiency = dbo.ScoreEfficiencyConfig(FracSweetSpotDistance, FracOverRevDistance, 0, 0, FracIdleTime, 0, @rprtcfgid),
		Safety = dbo.ScoreSafetyConfig(0, 0, 0, 0, 0, 0, 0, Acceleration, Braking, Cornering, @rprtcfgid)
	FROM

	(SELECT  
		v.Registration,
		ISNULL(vt.Name,'Unknown') as VehicleType,
		d.surname,	
		creationdatetime,
		closuredatetime,

		ROUND(SUM(CAST(DrivingTime as float)/60.0),1) as DrivingTime,
		SUM(DrivingDistance) AS DrivingDistance,
		SUM(IdleTime) AS IdleTime,
		SUM(IdleFuel) AS IdleFuel,
		ROUND(SUM(CAST(InSweetSpotTime as float)/60),1) as SweetSpotTime,
		ROUND(SUM(InSweetSpotDistance/DrivingDistance),3) as FracSweetSpotDistance,
		SUM(InSweetSpotDistance) as SweetSpotDistance,
		
		SUM(DrivingFuel) AS DrivingFuel,		
		(CASE WHEN @fuelmult = 0.1 THEN
			(CASE WHEN SUM(DrivingFuel)=0 THEN NULL ELSE SUM(DrivingFuel * ISNULL(FuelMultiplier,1.0))*100 END)/SUM(DrivingDistance) 
		ELSE
			(SUM(DrivingDistance) * 1000) / (CASE WHEN SUM(DrivingFuel)=0 THEN NULL ELSE SUM(DrivingFuel * ISNULL(FuelMultiplier,1.0)) END) * @fuelmult END) AS FuelEcon,
		0 AS MPG,
		
		SUM(AverageEngineRPM) as AveRPM,
		SUM(AverageEngineRPMWhileDriving) as AveDrivingRPM,
		SUM(FueledOverRPMTime) as OverRevTime,
		SUM(FueledOverRPMDistance) as OverRevDistance,
		SUM(FueledOverRPMFuel) as OverRevFuel,
		
		COUNT(ea.creationcodeid) AS Acceleration,
		COUNT(eb.creationcodeid) AS Braking,
		COUNT(ec.creationcodeid) AS Cornering,

		ROUND(SUM(IdleTime/(IdleTime+DrivingTime+PTOMovingTime+PTONonMovingTime)),3) as FracIdleTime, 
		ROUND(SUM(FueledOverRPMDistance/DrivingDistance),3) as FracOverRevDistance, 
		
		ROUND(SUM((DrivingFuel + IdleFuel + PTOMovingFuel + PTONonMovingFuel) * 2639.1 / DrivingDistance),1) as CO2,
		MAX(@fuelstr) AS FuelStr,
		MAX(@diststr) AS DistanceStr
		
	FROM dbo.Accum a 
		INNER JOIN dbo.Driver d ON a.DriverIntId = d.DriverIntId  
		INNER JOIN dbo.Vehicle v ON a.VehicleIntId = v.VehicleIntId
		LEFT JOIN dbo.Event ea ON v.VehicleIntId = ea.VehicleIntId AND d.DriverIntId = ea.DriverIntId AND ea.CreationCodeId = 37
			AND ea.eventdatetime BETWEEN a.CreationDateTime AND a.ClosureDateTime
		LEFT JOIN dbo.Event eb ON v.VehicleIntId = eb.VehicleIntId AND d.DriverIntId = eb.DriverIntId AND eb.CreationCodeId = 36
			AND eb.eventdatetime BETWEEN a.CreationDateTime AND a.ClosureDateTime
		LEFT JOIN dbo.Event ec ON v.VehicleIntId = eb.VehicleIntId AND d.DriverIntId = eb.DriverIntId AND eb.CreationCodeId = 38
			AND ec.eventdatetime BETWEEN a.CreationDateTime AND a.ClosureDateTime
		LEFT JOIN dbo.VehicleType vt ON v.VehicleTypeID = vt.VehicleTypeID
	Where d.DriverID = @did
		and CreationDateTime >= @sdate and CreationDateTime < @edate
		and DrivingTime > 0
		and DrivingDistance > 0
	GROUP BY v.Registration, 
			 vt.Name,
			 d.Surname, 
			 CreationDateTime,
			 ClosureDateTime
	) x
) y





















GO
