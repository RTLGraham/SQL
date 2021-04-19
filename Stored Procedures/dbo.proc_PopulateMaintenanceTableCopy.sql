SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_PopulateMaintenanceTableCopy]
AS 
SET NOCOUNT ON

DECLARE @tempdate SMALLDATETIME
SET @tempdate = DATEADD(HOUR, -24, GETDATE()) -- set to yesterday

DECLARE @sdate SMALLDATETIME, 
		@edate SMALLDATETIME
-- sdate must be midnight on day in question to match reporting table dates
SET @sdate = CAST(YEAR(@tempdate) AS VARCHAR(4)) + '-' + CAST(dbo.LeadingZero(MONTH(@tempdate),2) AS VARCHAR(2)) + '-' + CAST(dbo.LeadingZero(DAY(@tempdate),2) AS VARCHAR(2)) + ' 00:00:00.000'
SET @edate = CAST(YEAR(@tempdate) AS VARCHAR(4)) + '-' + CAST(dbo.LeadingZero(MONTH(@tempdate),2) AS VARCHAR(2)) + '-' + CAST(dbo.LeadingZero(DAY(@tempdate),2) AS VARCHAR(2)) + ' 23:59:59.999'

CREATE TABLE #MaintenanceCopy
(
	[CustomerIntId] [int] NOT NULL,
	[CustomerId] [uniqueidentifier] NOT NULL,
	[VehicleIntId] [int] NOT NULL,
	[VehicleId] [uniqueidentifier] NOT NULL,
	[Date] [datetime] NOT NULL,
	[IVHIntId] [int] NOT NULL,
	[IVHId] [uniqueidentifier] NOT NULL,
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
	[DriverIdInUse] [bit] NULL
)

INSERT INTO #MaintenanceCopy
        ( CustomerIntId,
          CustomerId,
          VehicleIntId,
          VehicleId,
          Date,
          IVHIntId,
          IVHId,
          DaysSincePoll
        )
SELECT	c.CustomerIntId, 
		c.CustomerId, 
		v.VehicleIntId, 
		v.VehicleId, 
		@sdate, 
		i.IVHIntId, 
		i.IVHId,
		CASE WHEN DATEDIFF(DAY, vle.EventDateTime, @sdate) < 0 THEN 0 ELSE DATEDIFF(DAY, vle.EventDateTime, @sdate) END
FROM dbo.IVH i
INNER JOIN dbo.Vehicle v ON i.IVHId = v.IVHId
INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId AND cv.EndDate IS NULL AND cv.Archived = 0
INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
INNER JOIN dbo.VehicleLatestAllEvent vle ON vle.vehicleid = v.vehicleid
WHERE v.Archived = 0
  AND i.Archived = 0
  AND v.Registration NOT LIKE 'UNKNOWN%'

-- TAN Data
UPDATE #MaintenanceCopy
SET TANCheckout = tac.CheckOutReason
FROM #MaintenanceCopy mc
LEFT JOIN dbo.TAN_EntityCheckOut tac ON tac.EntityId = mc.VehicleId AND mc.Date BETWEEN tac.CheckOutDateTime AND ISNULL(tac.CheckInDateTime, '2199-12-31 23:59')
  
-- data from the Event table for the single day -- GPS Distance, Analogue Data, Data Age, Battery and Sensor Data
UPDATE #MaintenanceCopy
SET GPSDriveDistance = eday.DriveDistGPSKm,
	T0 = eday.T0, T1 = eday.T1, T2 = eday.T2, T3 = eday.T3,
	DriverIdInUse = CASE WHEN eday.RealDriverCount > 0 THEN 1 ELSE 0 END,
	Ignition = CASE WHEN eday.IgnitionCount > 0 THEN 1 ELSE 0 END,
	MaxDataAgeMins = eday.MaxDataAgeMinutes,
	MinBatteryCharge = eday.MinBattCharge,
	MaxBatteryCharge = eday.MaxBattCharge,
	AvgBatteryCharge = eday.AvgBattCharge,
	MinExternalVoltage = eday.MinExtVoltage,
	MaxExternalVoltage = eday.MaxExtVoltage,
	AvgExternalVoltage = eday.AvgExtVoltage,
	Sensor01 = eday.Sensor01,
	Sensor02 = eday.Sensor02,
	Sensor03 = eday.Sensor03,
	Sensor04 = eday.Sensor04
FROM #MaintenanceCopy mc
INNER JOIN  
(
	SELECT	mc.VehicleIntId,
			CAST((CAST(MAX(e.OdoGPS) AS BIGINT) - CAST(MIN(e.OdoGPS) AS BIGINT)) AS FLOAT)/1000 as DriveDistGPSKm,
			CASE WHEN CAST(MAX(AnalogData0) AS INT)-CAST(MIN(AnalogData0) AS INT) > 0 THEN 1 ELSE 0 END AS T0,
			CASE WHEN CAST(MAX(AnalogData1) AS INT)-CAST(MIN(AnalogData1) AS INT) > 0 THEN 1 ELSE 0 END AS T1,
			CASE WHEN CAST(MAX(AnalogData2) AS INT)-CAST(MIN(AnalogData2) AS INT) > 0 THEN 1 ELSE 0 END AS T2,
			CASE WHEN CAST(MAX(AnalogData3) AS INT)-CAST(MIN(AnalogData3) AS INT) > 0 THEN 1 ELSE 0 END AS T3,
			SUM(CASE WHEN e.CreationCodeId = 61 AND ISNULL(d.Number, '') != 'No ID' AND ISNULL(d.Number, '') NOT LIKE '%fff%00%fff%' THEN 1 ELSE 0 END) AS RealDriverCount,
			SUM(CASE WHEN e.CreationCodeId IN (4,5) THEN 1 ELSE 0 END) AS IgnitionCount,
			MAX(DATEDIFF(MINUTE, e.EventDateTime, e.LastOperation)) AS MaxDataAgeMinutes,
			MIN(CASE WHEN e.BatteryChargeLevel = 0 THEN NULL ELSE e.BatteryChargeLevel END) AS MinBattCharge,
			MAX(CASE WHEN e.BatteryChargeLevel = 0 THEN NULL ELSE e.BatteryChargeLevel END) AS MaxBattCharge,
			AVG(CASE WHEN e.BatteryChargeLevel = 0 THEN NULL ELSE e.BatteryChargeLevel END) AS AvgBattCharge,
			MIN(CASE WHEN e.ExternalInputVoltage = 0 THEN NULL ELSE e.ExternalInputVoltage END) AS MinExtVoltage,
			MAX(CASE WHEN e.ExternalInputVoltage = 0 THEN NULL ELSE e.ExternalInputVoltage END) AS MaxExtVoltage,
			AVG(CASE WHEN e.ExternalInputVoltage = 0 THEN NULL ELSE e.ExternalInputVoltage END) AS AvgExtVoltage,
			CASE WHEN AVG(e.AnalogData0) != 192 THEN 1 ELSE 0 END AS Sensor01,
			CASE WHEN AVG(e.AnalogData1) != 192 THEN 1 ELSE 0 END AS Sensor02,
			CASE WHEN AVG(e.AnalogData2) != 192 THEN 1 ELSE 0 END AS Sensor03,
			CASE WHEN AVG(e.AnalogData3) != 192 THEN 1 ELSE 0 END AS Sensor04			
	FROM #MaintenanceCopy mc
	INNER JOIN dbo.Event e WITH (NOLOCK) ON mc.VehicleIntId = e.VehicleIntId
	INNER JOIN dbo.Driver d ON e.DriverIntId = d.DriverIntId
	WHERE e.EventDateTime BETWEEN @sdate AND @edate
	GROUP BY mc.VehicleIntId
) eday ON mc.VehicleIntId = eday.VehicleIntId

-- Data from Reporting table -- Driving Distance and Fuel
UPDATE #MaintenanceCopy
SET CANDriveDistance = rpt.DriveDistCANKm, DrivingFuel = rpt.DrivingFuel
FROM #MaintenanceCopy mc
LEFT JOIN
(
	SELECT	mc.Vehicleintid, 
			SUM(r.drivingdistance) AS DriveDistCANKm,
			SUM(r.drivingfuel) AS DrivingFuel
	FROM #MaintenanceCopy mc
	INNER JOIN dbo.Reporting r ON mc.VehicleIntId = r.VehicleIntId AND mc.Date = r.Date
	GROUP BY mc.VehicleIntId
) rpt ON mc.VehicleIntId = rpt.VehicleIntId

-- Drive Distance with No Driver
UPDATE #MaintenanceCopy
SET CANDriveDistanceNoID = rnoid.DriveDistCANKmNoID
FROM #MaintenanceCopy mc
LEFT JOIN
(
	SELECT mc.VehicleIntId, SUM(r.drivingdistance) AS DriveDistCANKmNoID
	FROM #MaintenanceCopy mc
	INNER JOIN dbo.Reporting r ON mc.VehicleIntId = r.VehicleIntId AND mc.Date = r.Date
	INNER JOIN dbo.Driver d on r.driverintid = d.driverintid
	WHERE d.Number = 'No ID'
	GROUP BY mc.VehicleIntId
) rnoid ON mc.VehicleIntId = rnoid.VehicleIntId

-- SS1 Check
UPDATE #MaintenanceCopy
SET SS1 = ssv.SSV
FROM #MaintenanceCopy mc
LEFT JOIN
(
	SELECT mc.VehicleIntId, MAX(ed.EventDataString) AS SSV
	FROM #MaintenanceCopy mc
	INNER JOIN dbo.EventData ed WITH (NOLOCK) ON mc.VehicleIntId = ed.VehicleIntId
	WHERE ed.EventDateTime BETWEEN @sdate and @edate
	  AND ed.EventDataName = 'SSV'
	GROUP BY mc.VehicleIntId
) ssv ON mc.VehicleIntId = ssv.VehicleIntId

-- GPRSRetries and TXFails by counting EventData rows for each using EventDataString
UPDATE #MaintenanceCopy
SET GPRSRetries = edcount.[GPRS Retry], TXFails = edcount.[TX Fail]
FROM #MaintenanceCopy mc
LEFT JOIN
(
	SELECT VehicleIntId, [GPRS Retry], [TX Fail]
	FROM
		(SELECT mc.VehicleIntId, ed.EventDataString, ed.CreationCodeId
		FROM #MaintenanceCopy mc
		INNER JOIN EventData ed WITH (NOLOCK) ON mc.VehicleIntId = ed.VehicleIntId
		WHERE ed.EventDateTime BETWEEN @sdate AND @edate ) AS source
		PIVOT 
		(	COUNT(CreationCodeId) 
			FOR EventDataString IN ([GPRS Retry], [TX Fail])
		) AS pvt
) edcount on mc.VehicleIntId = edcount.VehicleIntId

-- iButton and Tacho by counting EventData rows for appropriate EventDataStrings where EventDataName = SRC
UPDATE #MaintenanceCopy
SET iButton = CASE WHEN edsrc.[IB] > 0 THEN 1 ELSE 0 END, 
	Tacho = CASE WHEN edsrc.[VD] + edsrc.[ST] > 0 THEN 1 ELSE 0 END
FROM #MaintenanceCopy mc
LEFT JOIN
(
	SELECT VehicleIntId, [VD], [ST], [IB]
	FROM
		(SELECT mc.VehicleIntId, ed.EventDataString, ed.CreationCodeId
		FROM #MaintenanceCopy mc
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
UPDATE #MaintenanceCopy
SET CheetahFaults = ederr.[ERR], SS1Faults = ederr.[SS1]
FROM #MaintenanceCopy mc
LEFT JOIN
(
	SELECT VehicleIntId, [ERR], [SS1]
	FROM
		(SELECT mc.VehicleIntId, ed.EventDataName, ed.CreationCodeId
		FROM #MaintenanceCopy mc
		INNER JOIN dbo.EventData ed WITH (NOLOCK) ON mc.VehicleIntId = ed.VehicleIntId 
		WHERE ed.EventDateTime BETWEEN @sdate AND @edate
		) AS source
		PIVOT 
		(	COUNT(CreationCodeId) 
			FOR EventDataName IN ([ERR], [SS1])
		) AS pvt
) ederr ON mc.VehicleIntId = ederr.VehicleIntId 

INSERT INTO dbo.MaintenanceCopy (CustomerIntId,VehicleIntId,Date,IVHIntId,SS1,GPRSRetries,TXFails,TANCheckout,DaysSincePoll,
								GPSDriveDistance,CANDriveDistance,CANDriveDistanceNoID,T0,T1,T2,T3,MaxDataAgeMins,MinBatteryCharge,
								MaxBatteryCharge,AvgBatteryCharge,MinExternalVoltage,MaxExternalVoltage,AvgExternalVoltage,Ignition,
								DrivingFuel,iButton,Tacho,CheetahFaults,SS1Faults,Sensor01,Sensor02,Sensor03,Sensor04,DriverIdInUse)
SELECT 	CustomerIntId,VehicleIntId,Date,IVHIntId,SS1,GPRSRetries,TXFails,TANCheckout,DaysSincePoll,GPSDriveDistance,CANDriveDistance,
		CANDriveDistanceNoID,T0,T1,T2,T3,MaxDataAgeMins,MinBatteryCharge,MaxBatteryCharge,AvgBatteryCharge,MinExternalVoltage,MaxExternalVoltage,
		AvgExternalVoltage,Ignition,DrivingFuel,iButton,Tacho,CheetahFaults,SS1Faults,Sensor01,Sensor02,Sensor03,Sensor04,DriverIdInUse
FROM #MaintenanceCopy	

DROP TABLE #MaintenanceCopy




GO
