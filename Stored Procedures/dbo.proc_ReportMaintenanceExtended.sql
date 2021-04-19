SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportMaintenanceExtended]
    (
		@sdate DATETIME,
		@edate DATETIME,
		@regs NVARCHAR(MAX) = NULL	
--		@uid UNIQUEIDENTIFIER
    )
AS 
SET NOCOUNT ON

DECLARE	@uid UNIQUEIDENTIFIER
--		@sdate DATETIME,
--		@edate DATETIME,
--		@regs NVARCHAR(MAX)
		
--SET @sdate = '2013-04-16 00:00'
--SET @edate = '2013-04-16 23:59'
--SET @regs = N'ZH 283810 (6104) D,ZH 300827 (6091) iB,ZH 313274 (6040) iB,ZH 415001 (6179) D,ZH 429531 (6160) D,ZH 612189 (6087) iB4,ZH 638744 (6166) iB4,ZH 69404 (6063) iB,ZH 85946 (6035) iB,ZH 96636 (6173) D'
SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5' -- CHRauTi

DECLARE @diststr varchar(20),
		@distmult float

SELECT @diststr = [dbo].UserPref(@uid, 203)
SELECT @distmult = [dbo].UserPref(@uid, 202)

IF datepart(yyyy, @sdate) IN  ('1960', '1961')
BEGIN
	SET @edate = dbo.Calc_Schedule_EndDate(@sdate, @uid)
	SET @sdate = dbo.Calc_Schedule_StartDate(@sdate, @uid)
END	

SELECT	m.Date,
		v.Registration,
		v.BodyType,
		v.MakeModel,
		i.FirmwareVersion,
		m.SS1,
		i.SerialNumber,
		m.SWS,
		CASE WHEN m.BatteryDisconnect = 0 THEN NULL ELSE m.BatteryDisconnect END AS BatteryDisconnect,
		CASE WHEN m.HardwareErrors = 0 THEN NULL ELSE m.HardwareErrors END AS HardwareErrors,
		CASE WHEN m.GPRSRetries = 0 THEN NULL ELSE m.GPRSRetries END AS GPRSRetries,
		CASE WHEN m.TXFails = 0 THEN NULL ELSE m.TXFails END AS TXFails,
		m.TANCheckout,
		m.DaysSincePoll,
		m.DaysSinceDrive,
		m.GPSDriveDistance * @distmult * 1000 AS GPSDriveDistance,
		m.CANDriveDistance * @distmult * 1000 AS CANDriveDistance,
		m.CANDriveDistanceNoID * @distmult * 1000 AS CANDriveDistanceNoID,
		CASE m.T0 WHEN 0 THEN 'Fail' WHEN 1 THEN 'OK' ELSE NULL END AS T0,
		CASE m.T1 WHEN 0 THEN 'Fail' WHEN 1 THEN 'OK' ELSE NULL END AS T1,
		CASE m.T2 WHEN 0 THEN 'Fail' WHEN 1 THEN 'OK' ELSE NULL END AS T2,
		CASE m.T3 WHEN 0 THEN 'Fail' WHEN 1 THEN 'OK' ELSE NULL END AS T3,
		CASE m.DID1 WHEN 0 THEN 'Fail' WHEN 1 THEN 'OK' ELSE NULL END AS DID1,
		CASE m.DID2 WHEN 0 THEN 'Fail' WHEN 1 THEN 'OK' ELSE NULL END AS DID2,
		CASE m.CAN WHEN 0 THEN 'Fail' WHEN 1 THEN 'OK' ELSE NULL END AS CAN,
		CASE m.GPS WHEN 0 THEN 'Fail' WHEN 1 THEN 'OK' ELSE NULL END AS GPS,
		CASE m.GPSDrift WHEN 0 THEN 'Fail' WHEN 1 THEN 'OK' ELSE NULL END AS GPSDrift,
		m.MaxDataAgeMins,
		((CAST(m.MinBatteryCharge AS FLOAT) * 10) + 2500) / 1000 AS MinBatteryCharge,
		((CAST(m.MaxBatteryCharge AS FLOAT) * 10) + 2500) / 1000 AS MaxBatteryCharge,
		((CAST(m.AvgBatteryCharge AS FLOAT) * 10) + 2500) / 1000 AS AvgBatteryCharge,
		CAST(m.MaxExternalVoltage AS FLOAT) * 0.5 AS MaxExternalVoltage,
		CAST(m.MinExternalVoltage AS FLOAT) * 0.5 AS MinExternalVoltage,
		CAST(m.AvgExternalVoltage AS FLOAT) * 0.5 AS AvgExternalVoltage,
		m.Acceleration,
		m.Braking,
		m.Cornering,
		CASE m.Accelerometer WHEN 0 THEN 'Fail' WHEN 1 THEN 'OK' ELSE NULL END AS Accelerometer,
		@diststr AS DistanceUnit
						
FROM dbo.Maintenance m
INNER JOIN dbo.Vehicle v ON m.VehicleIntId = v.VehicleIntId
INNER JOIN dbo.IVH i ON m.IVHIntId = i.IVHIntId
WHERE m.Date BETWEEN @sdate AND @edate
  AND (v.Registration IN (SELECT Value FROM dbo.Split(@regs, ',')) OR @regs IS NULL)
ORDER BY m.Date, v.Registration






GO
