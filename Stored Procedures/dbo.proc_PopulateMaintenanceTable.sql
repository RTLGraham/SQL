SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_PopulateMaintenanceTable]
AS 
SET NOCOUNT ON

DECLARE @tempdate SMALLDATETIME
SET @tempdate = DATEADD(HOUR, -24, GETDATE()) -- set to yesterday

DECLARE @sdate SMALLDATETIME, 
		@edate SMALLDATETIME
-- sdate must be midnight on day in question to match reporting table dates
SET @sdate = CAST(YEAR(@tempdate) AS VARCHAR(4)) + '-' + CAST(dbo.LeadingZero(MONTH(@tempdate),2) AS VARCHAR(2)) + '-' + CAST(dbo.LeadingZero(DAY(@tempdate),2) AS VARCHAR(2)) + ' 00:00:00.000'
SET @edate = CAST(YEAR(@tempdate) AS VARCHAR(4)) + '-' + CAST(dbo.LeadingZero(MONTH(@tempdate),2) AS VARCHAR(2)) + '-' + CAST(dbo.LeadingZero(DAY(@tempdate),2) AS VARCHAR(2)) + ' 23:59:59.999'

--Variables to define durations when identifying camera faults
Declare @CamWithTelInactiveDays INT,
		@CamOnlyInactiveDays INT,
		@NoVidDistance INT,
		@NoVidDays INT


SET @CamOnlyInactiveDays = 3
SET @CamWithTelInactiveDays = 5
SET @NoVidDistance = 1000
SET @NoVidDays = 10

CREATE TABLE #Maintenance
(
	[CustomerIntId] [int] NOT NULL,
	[CustomerId] [uniqueidentifier] NOT NULL,
	[VehicleIntId] [int] NOT NULL,
	[VehicleId] [uniqueidentifier] NOT NULL,
	[Date] [datetime] NOT NULL,
	[IVHIntId] [int] NULL,
	[IVHId] [uniqueidentifier] NULL,
	[SS1] [varchar](max) NULL,					
	[GPRSRetries] [int] NULL,
	[TXFails] [int] NULL,
	[TANCheckout] [nvarchar](max) NULL,
	[DaysSincePoll] [int] NULL,					
	[GPSDriveDistance] [float] NULL,
	[CANDriveDistance] [float] NULL,
	[CANDriveDistanceNoID] [float] NULL,
	[T0] [bit] NULL,
	[T1] [bit] NULL,
	[T2] [bit] NULL,
	[T3] [bit] NULL,
	[MaxDataAgeMins] [int] NULL,
	[MinBatteryCharge] [smallint] NULL,
	[MaxBatteryCharge] [smallint] NULL,
	[AvgBatteryCharge] [smallint] NULL,
	[MinExternalVoltage] [smallint] NULL,
	[MaxExternalVoltage] [smallint] NULL,
	[AvgExternalVoltage] [smallint] NULL,
	[Ignition] [bit] NULL,
	[DrivingFuel] [float] NULL,
	[iButton] [bit] NULL,
	[Tacho] [bit] NULL,
	[CheetahFaults] [int] NULL,
	[SS1Faults] [int] NULL,
	[Sensor01] [bit] NULL,
	[Sensor02] [bit] NULL,
	[Sensor03] [bit] NULL,
	[Sensor04] [bit] NULL,
	[DriverIdInUse] [bit] NULL,
	[AverageRPM] [SMALLINT] NULL,
	[ConsumedFuel] [FLOAT] NULL,
	[BelowSweetSpotDistance] FLOAT NULL,
	[BelowSweetSpotFuel] FLOAT NULL,
	[SweetSpotDistance] FLOAT NULL,
	[SweetSpotFuel] FLOAT NULL,
	[OverRevDistance] FLOAT NULL,
	[OverRevFuel] FLOAT NULL,
	[Camera] [bit] NULL,
	[Video] [BIT] NULL,
	[Corruption] [BIT] NULL
)

INSERT INTO #Maintenance
        ( CustomerIntId,
          CustomerId,
          VehicleIntId,
          VehicleId,
          Date,
          IVHIntId,
          IVHId,
          DaysSincePoll,
          Sensor01,
          Sensor02,
          Sensor03,
          Sensor04
        )
SELECT	c.CustomerIntId, 
		c.CustomerId, 
		v.VehicleIntId, 
		v.VehicleId, 
		@sdate, 
		i.IVHIntId, 
		i.IVHId,
		CASE WHEN DATEDIFF(DAY, vle.EventDateTime, @sdate) < 0 THEN 0 ELSE DATEDIFF(DAY, vle.EventDateTime, @sdate) END,
		-- Sensor values = 1 means sensor enabled, = 0 means sensor not enabled
		CASE WHEN vs1.Enabled = 1 THEN 1 ELSE 0 END,
		CASE WHEN vs2.Enabled = 1 THEN 1 ELSE 0 END,
		CASE WHEN vs3.Enabled = 1 THEN 1 ELSE 0 END,
		CASE WHEN vs4.Enabled = 1 THEN 1 ELSE 0 END
FROM dbo.Vehicle v
LEFT JOIN dbo.IVH i ON i.IVHId = v.IVHId
LEFT JOIN dbo.VehicleSensor vs1 ON v.VehicleIntId = vs1.VehicleIntId AND vs1.SensorId = 1
LEFT JOIN dbo.VehicleSensor vs2 ON v.VehicleIntId = vs2.VehicleIntId AND vs2.SensorId = 2
LEFT JOIN dbo.VehicleSensor vs3 ON v.VehicleIntId = vs3.VehicleIntId AND vs3.SensorId = 3
LEFT JOIN dbo.VehicleSensor vs4 ON v.VehicleIntId = vs4.VehicleIntId AND vs4.SensorId = 4
INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId AND cv.EndDate IS NULL AND cv.Archived = 0
INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
INNER JOIN dbo.VehicleLatestAllEvent vle ON vle.vehicleid = v.vehicleid
WHERE v.Archived = 0
  AND (i.Archived = 0 OR i.Archived IS NULL)
  AND v.Registration NOT LIKE 'UNKNOWN%'


  
  --Insert Scorpion Camera only vehicles because they have been excluded from the above by the inner join on vehicle latest all event
  INSERT INTO #Maintenance
        ( CustomerIntId,
          CustomerId,
          VehicleIntId,
          VehicleId,
          Date,
          IVHIntId,
          IVHId
        )
SELECT cu.CustomerIntId,cu.CustomerId,v.VehicleIntId,cv.VehicleId,@sdate,NULL,NULL
FROM dbo.Vehicle v
INNER JOIN dbo.VehicleCamera vc ON vc.VehicleId = v.VehicleId
INNER JOIN dbo.Camera c ON c.CameraId = vc.CameraId
INNER JOIN dbo.Project p ON p.ProjectId = c.ProjectId
INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
INNER JOIN dbo.Customer cu ON cu.CustomerId = cv.CustomerId
WHERE p.Project = '999'
AND c.Archived = 0
AND vc.Archived = 0
AND vc.EndDate IS NULL
AND v.Archived = 0
AND v.IVHId IS NULL
AND v.Registration NOT LIKE 'UNKNOWN%'
AND cv.Archived = 0
AND cv.EndDate IS NULL

-- TAN Data
UPDATE #Maintenance
SET TANCheckout = tac.CheckOutReason
FROM #Maintenance mc
LEFT JOIN dbo.TAN_EntityCheckOut tac ON tac.EntityId = mc.VehicleId AND mc.Date BETWEEN tac.CheckOutDateTime AND ISNULL(tac.CheckInDateTime, '2199-12-31 23:59')
  
 --data from the Event table for the single day -- GPS Distance, Analogue Data, Data Age, Battery and Sensor Data
UPDATE #Maintenance
SET GPSDriveDistance = eday.DriveDistGPSKm,
	T0 = eday.T0, T1 = eday.T1, T2 = eday.T2, T3 = eday.T3,
	DriverIdInUse = CASE WHEN eday.RealDriverCount > 0 THEN 1 ELSE 0 END,
	Ignition = CASE WHEN eday.IgnitionFault = 0 OR eday.KeyOnOffCount > 0 THEN 1 ELSE 0 END,
	MaxDataAgeMins = eday.MaxDataAgeMinutes,
	MinBatteryCharge = eday.MinBattCharge,
	MaxBatteryCharge = eday.MaxBattCharge,
	AvgBatteryCharge = eday.AvgBattCharge,
	MinExternalVoltage = eday.MinExtVoltage,
	MaxExternalVoltage = eday.MaxExtVoltage,
	AvgExternalVoltage = eday.AvgExtVoltage
FROM #Maintenance mc
INNER JOIN  
(
	SELECT	mc.VehicleIntId,
			CAST((CAST(MAX(e.OdoGPS) AS BIGINT) - CAST(MIN(e.OdoGPS) AS BIGINT)) AS FLOAT)/1000 as DriveDistGPSKm,
			-- T values = 0 means sensor flat lines, >0 means sensor working
			CASE WHEN CAST(MAX(AnalogData0) AS INT)-CAST(MIN(AnalogData0) AS INT) > 0 THEN 1 ELSE 0 END AS T0,
			CASE WHEN CAST(MAX(AnalogData1) AS INT)-CAST(MIN(AnalogData1) AS INT) > 0 THEN 1 ELSE 0 END AS T1,
			CASE WHEN CAST(MAX(AnalogData2) AS INT)-CAST(MIN(AnalogData2) AS INT) > 0 THEN 1 ELSE 0 END AS T2,
			CASE WHEN CAST(MAX(AnalogData3) AS INT)-CAST(MIN(AnalogData3) AS INT) > 0 THEN 1 ELSE 0 END AS T3,
			SUM(CASE WHEN e.CreationCodeId = 61 AND ISNULL(d.Number, '') != 'No ID' AND ISNULL(d.Number, '') NOT LIKE '%fff%00%fff%' THEN 1 ELSE 0 END) AS RealDriverCount,
			SUM(CASE WHEN e.CreationCodeId IN (42,43) THEN 1 ELSE 0 END) AS IgnitionFault,
			SUM(CASE WHEN e.CreationCodeId IN (4,5) THEN 1 ELSE 0 END) AS KeyOnOffCount,
			MAX(DATEDIFF(MINUTE, e.EventDateTime, e.LastOperation)) AS MaxDataAgeMinutes,
			MIN(CASE WHEN e.BatteryChargeLevel = 0 THEN NULL ELSE e.BatteryChargeLevel END) AS MinBattCharge,
			MAX(CASE WHEN e.BatteryChargeLevel = 0 THEN NULL ELSE e.BatteryChargeLevel END) AS MaxBattCharge,
			AVG(CASE WHEN e.BatteryChargeLevel = 0 THEN NULL ELSE e.BatteryChargeLevel END) AS AvgBattCharge,
			MIN(CASE WHEN e.ExternalInputVoltage = 0 THEN NULL ELSE e.ExternalInputVoltage END) AS MinExtVoltage,
			MAX(CASE WHEN e.ExternalInputVoltage = 0 THEN NULL ELSE e.ExternalInputVoltage END) AS MaxExtVoltage,
			AVG(CASE WHEN e.ExternalInputVoltage = 0 THEN NULL ELSE e.ExternalInputVoltage END) AS AvgExtVoltage
	FROM #Maintenance mc
	INNER JOIN dbo.Event e WITH (NOLOCK) ON mc.VehicleIntId = e.VehicleIntId
	INNER JOIN dbo.Driver d ON e.DriverIntId = d.DriverIntId
	WHERE e.EventDateTime BETWEEN @sdate AND @edate
	  AND e.OdoGPS > 0 -- needed to prevent invalid GPS Distance
	GROUP BY mc.VehicleIntId
) eday ON mc.VehicleIntId = eday.VehicleIntId

-- Data from Reporting table -- Driving Distance and Fuel
UPDATE #Maintenance
SET CANDriveDistance = rpt.DriveDistCANKm, DrivingFuel = rpt.DrivingFuel
FROM #Maintenance mc
LEFT JOIN
(
	SELECT	mc.Vehicleintid, 
			SUM(r.drivingdistance) AS DriveDistCANKm,
			SUM(r.drivingfuel) AS DrivingFuel
	FROM #Maintenance mc
	INNER JOIN dbo.Reporting r ON mc.VehicleIntId = r.VehicleIntId AND mc.Date = r.Date
	GROUP BY mc.VehicleIntId
) rpt ON mc.VehicleIntId = rpt.VehicleIntId

-- Drive Distance with No Driver
UPDATE #Maintenance
SET CANDriveDistanceNoID = rnoid.DriveDistCANKmNoID
FROM #Maintenance mc
LEFT JOIN
(
	SELECT mc.VehicleIntId, SUM(r.drivingdistance) AS DriveDistCANKmNoID
	FROM #Maintenance mc
	INNER JOIN dbo.Reporting r ON mc.VehicleIntId = r.VehicleIntId AND mc.Date = r.Date
	INNER JOIN dbo.Driver d on r.driverintid = d.driverintid
	WHERE d.Number = 'No ID'
	GROUP BY mc.VehicleIntId
) rnoid ON mc.VehicleIntId = rnoid.VehicleIntId

-- SS1 Check
UPDATE #Maintenance
SET SS1 = ssv.SSV
FROM #Maintenance mc
LEFT JOIN
(
	SELECT mc.VehicleIntId, MAX(ed.EventDataString) AS SSV
	FROM #Maintenance mc
	INNER JOIN dbo.EventData ed WITH (NOLOCK) ON mc.VehicleIntId = ed.VehicleIntId
	WHERE ed.EventDateTime BETWEEN @sdate and @edate
	  AND ed.EventDataName = 'SSV'
	GROUP BY mc.VehicleIntId
) ssv ON mc.VehicleIntId = ssv.VehicleIntId

-- GPRSRetries and TXFails by counting EventData rows for each using EventDataString
UPDATE #Maintenance
SET GPRSRetries = edcount.[GPRS Retry], TXFails = edcount.[TX Fail]
FROM #Maintenance mc
LEFT JOIN
(
	SELECT VehicleIntId, [GPRS Retry], [TX Fail]
	FROM
		(SELECT mc.VehicleIntId, ed.EventDataString, ed.CreationCodeId
		FROM #Maintenance mc
		INNER JOIN EventData ed WITH (NOLOCK) ON mc.VehicleIntId = ed.VehicleIntId
		WHERE ed.EventDateTime BETWEEN @sdate AND @edate ) AS source
		PIVOT 
		(	COUNT(CreationCodeId) 
			FOR EventDataString IN ([GPRS Retry], [TX Fail])
		) AS pvt
) edcount on mc.VehicleIntId = edcount.VehicleIntId

-- iButton and Tacho by counting EventData rows for appropriate EventDataStrings where EventDataName = SRC
UPDATE #Maintenance
SET iButton = CASE WHEN edsrc.[IB] > 0 THEN 1 ELSE 0 END, 
	Tacho = CASE WHEN edsrc.[VD] + edsrc.[ST] > 0 THEN 1 ELSE 0 END
FROM #Maintenance mc
LEFT JOIN
(
	SELECT VehicleIntId, [VD], [ST], [IB]
	FROM
		(SELECT mc.VehicleIntId, ed.EventDataString, ed.CreationCodeId
		FROM #Maintenance mc
		INNER JOIN dbo.EventData ed WITH (NOLOCK) ON mc.VehicleIntId = ed.VehicleIntId
		WHERE ed.EventDateTime BETWEEN @sdate AND @edate
			AND ed.EventDataName = 'SRC'
		) AS source
		PIVOT 
		(	COUNT(CreationCodeId) 
			FOR EventDataString IN ([VD], [ST], [IB])
		) AS pvt
) edsrc ON mc.VehicleIntId = edsrc.VehicleIntId 

-- Cheetah and SS1 Faults by counting EventData rows for appropriate EventDataNames
UPDATE #Maintenance
SET CheetahFaults = ederr.[ERR], SS1Faults = ederr.[SS1]
FROM #Maintenance mc
LEFT JOIN
(
	SELECT VehicleIntId, [ERR], [SS1]
	FROM
		(SELECT mc.VehicleIntId, ed.EventDataName, ed.CreationCodeId
		FROM #Maintenance mc
		INNER JOIN dbo.EventData ed WITH (NOLOCK) ON mc.VehicleIntId = ed.VehicleIntId 
		WHERE ed.EventDateTime BETWEEN @sdate AND @edate
		) AS source
		PIVOT 
		(	COUNT(CreationCodeId) 
			FOR EventDataName IN ([ERR], [SS1])
		) AS pvt
) ederr ON mc.VehicleIntId = ederr.VehicleIntId 

-- RPM and Fuel from Accums
UPDATE #Maintenance
SET AverageRPM = ac.AverageRPM, ConsumedFuel = ac.ConsumedFuel, 
	BelowSweetSpotDistance = ac.BelowSweetSpotDistance, BelowSweetSpotFuel = ac.BelowSweetSpotFuel,
	SweetSpotDistance = ac.SweetSpotDistance, SweetSpotFuel = ac.SweetSpotFuel,
	OverRevDistance = ac.OverRevDistance, OverRevFuel = ac.OverRevFuel
FROM #Maintenance mc
INNER JOIN 
(
	SELECT mc.VehicleIntId, AVG(ISNULL(a.AverageEngineRPM, 0)) AS AverageRPM, SUM(a.DrivingFuel + a.IdleFuel + a.ShortIdleFuel) AS ConsumedFuel,
		SUM(a.BelowSweetSpotDistance) AS BelowSweetSpotDistance, SUM(a.BelowSweetSpotFuel) AS BelowSweetSpotFuel,
		SUM(a.InSweetSpotDistance) AS SweetSpotDistance, SUM(a.InSweetSpotFuel) AS SweetSpotFuel,
		SUM(a.FueledOverRPMDistance) AS OverRevDistance, SUM(a.FueledOverRPMFuel) AS OverRevFuel
	FROM #Maintenance mc
	INNER JOIN dbo.Accum a WITH (NOLOCK) ON a.VehicleIntId = mc.VehicleIntId
	WHERE a.CreationDateTime BETWEEN @sdate AND @edate
	GROUP BY mc.VehicleIntId
) ac ON ac.VehicleIntId = mc.VehicleIntId


--Camera and video
UPDATE #Maintenance
SET Camera = x.Camera, Video = x.video

FROM #Maintenance mc
inner join

		(SELECT v.VehicleIntId,
			CASE WHEN (vle.EventDateTime IS NOT NULL AND DATEDIFF(DAY, m.EventDateTime, ISNULL(vle.EventDateTime,GETUTCDATE())) > @CamOnlyInactiveDays)
			 OR (vle.EventDateTime IS NULL AND DATEDIFF(DAY, m.EventDateTime, ISNULL(vle.EventDateTime,GETUTCDATE())) > @CamOnlyInactiveDays) THEN	0 ELSE 1 END AS Camera ,
			 CASE WHEN (m.EventDateTime IS NOT NULL AND DATEDIFF(DAY, ISNULL(m.EventDateTime,GETUTCDATE()),d.LastIdDate) > @NoVidDays)
			 OR (m.EventDateTime IS NULL AND DATEDIFF(DAY, ISNULL(d.FirstIdDate,GETUTCDATE()),GETUTCDATE()) > @NoVidDays) AND SUM(r.DrivingDistance) < @NoVidDistance  THEN	0 ELSE 1 END AS Video,
			 SUM(r.DrivingDistance) AS DistanceSinceLastVid

		FROM dbo.Camera c
			INNER JOIN dbo.VehicleCamera vc ON vc.CameraId = c.CameraId
			INNER JOIN [192.168.53.14].CommServer.dbo.Device d ON d.IMEI = c.Serial
			INNER JOIN dbo.Project p ON p.ProjectId = c.ProjectId
			INNER JOIN dbo.Vehicle v ON v.VehicleId = vc.VehicleId AND v.Archived = 0
			INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
			INNER JOIN dbo.Customer cu ON cu.CustomerId = cv.CustomerId
			LEFT JOIN dbo.VehicleLatestEvent vle ON vle.VehicleId = v.VehicleId
			LEFT JOIN [192.168.53.14].CommServer.dbo.CameraLatestVideo clv ON clv.DeviceId = d.DeviceId
			left JOIN dbo.Reporting r ON r.VehicleIntId = v.VehicleIntId AND clv.EventDate < r.Date
			OUTER APPLY(SELECT TOP 1 i.EventDateTime
			FROM dbo.CAM_Incident i
			WHERE v.VehicleIntId = i.VehicleIntId
			ORDER BY i. EventDateTime DESC) m 
		WHERE p.Project = '999'
		AND c.Archived = 0
		AND vc.Archived = 0
		AND vc.EndDate IS NULL
		AND d.Archived = 0
		GROUP BY v.VehicleIntId,m.EventDateTime,vle.EventDateTime,d.LastIdDate,d.FirstIdDate,r.DrivingDistance) x ON x.VehicleIntId = mc.VehicleIntId
		

----Cheetah cam
UPDATE #Maintenance
SET Corruption = c.MemoryCorruptions

FROM #Maintenance mc

INNER JOIN
(
SELECT v.Registration,v.VehicleIntId,--SUBSTRING(ed.EventDataString,3,6),ed.*
CASE WHEN COUNT(ed.EventDataId) > 5 THEN 1 ELSE 0 END AS MemoryCorruptions
--   ed.EventDataName,
--   ed.EventDataString,
--   RIGHT((SELECT TOP 1 Value FROM dbo.Split(ed.EventDataString, ',') WHERE Id = 1),6) AS FirstVal,
--ed.EventDateTime
FROM dbo.EventData ed
INNER JOIN dbo.Vehicle v ON v.VehicleIntId = ed.VehicleIntId
INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
WHERE SUBSTRING(ed.EventDataString,3,6) IN ('10802b','11802b','0e802b','0d802b','0f802b')
AND ed.EventDateTime BETWEEN @sdate AND @edate
--AND RIGHT((SELECT TOP 1 Value FROM dbo.Split(ed.EventDataString, ',') WHERE Id = 1),6) IN ('10802b','11802b','0e802b','0d802b','0f802b')
GROUP BY v.Registration,v.VehicleIntId,ed.EventDataId) c ON c.VehicleIntId = mc.VehicleIntId




INSERT INTO dbo.Maintenance (CustomerIntId,VehicleIntId,Date,IVHIntId,SS1,GPRSRetries,TXFails,TANCheckout,DaysSincePoll,
								GPSDriveDistance,CANDriveDistance,CANDriveDistanceNoID,T0,T1,T2,T3,MaxDataAgeMins,MinBatteryCharge,
								MaxBatteryCharge,AvgBatteryCharge,MinExternalVoltage,MaxExternalVoltage,AvgExternalVoltage,Ignition,
								DrivingFuel,iButton,Tacho,CheetahFaults,SS1Faults,Sensor01,Sensor02,Sensor03,Sensor04,DriverIdInUse,AverageRPM,ConsumedFuel,
								BelowSweetSpotDistance, BelowSweetSpotFuel, SweetSpotDistance, SweetSpotFuel, OverRevDistance, OverRevFuel,Camera,Video,Corruption)
SELECT 	CustomerIntId,VehicleIntId,Date,IVHIntId,SS1,GPRSRetries,TXFails,TANCheckout,DaysSincePoll,GPSDriveDistance,CANDriveDistance,
		CANDriveDistanceNoID,T0,T1,T2,T3,MaxDataAgeMins,MinBatteryCharge,MaxBatteryCharge,AvgBatteryCharge,MinExternalVoltage,MaxExternalVoltage,
		AvgExternalVoltage,Ignition,DrivingFuel,iButton,Tacho,CheetahFaults,SS1Faults,Sensor01,Sensor02,Sensor03,Sensor04,DriverIdInUse,AverageRPM,ConsumedFuel,
		BelowSweetSpotDistance, BelowSweetSpotFuel, SweetSpotDistance, SweetSpotFuel, OverRevDistance, OverRevFuel,Camera,Video,Corruption
FROM #Maintenance	



DROP TABLE #Maintenance

GO
