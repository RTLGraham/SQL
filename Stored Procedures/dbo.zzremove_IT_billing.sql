SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[zzremove_IT_billing]
		@serial NVARCHAR(MAX),
		@sdate DATETIME,
		@edate DATETIME
AS
--DECLARE @serial NVARCHAR(MAX),
--		@sdate DATETIME,
--		@edate DATETIME

--SELECT	@serial = '22002842',
--		@sdate = '2016-02-01 00:00',
--		@edate = '2016-02-29 23:59'



--SELECT c.Name, v.Registration, cam.Serial, cc.Name, COUNT(*) AS Incidents
SELECT c.Name, v.Registration, cam.Serial,
	SUM(CASE WHEN cc.Name = 'Camera Button' THEN 1 ELSE 0 END) AS Button,
	SUM(CASE WHEN cc.Name = 'Camera Telematics Activation' THEN 1 ELSE 0 END) AS Telematics,
	SUM(CASE WHEN cc.Name = 'Harsh Accel High' THEN 1 ELSE 0 END) AS A,
	SUM(CASE WHEN cc.Name = 'Harsh Decel High' THEN 1 ELSE 0 END) AS B,
	SUM(CASE WHEN cc.Name = 'Harsh Corner High' THEN 1 ELSE 0 END) AS C,
	SUM(CASE WHEN cc.Name = 'RSP ST1 Video' THEN 1 ELSE 0 END) AS RSS1,
	SUM(CASE WHEN cc.Name = 'RSP ST2 Video' THEN 1 ELSE 0 END) AS RSS2
FROM dbo.CAM_Incident i
	INNER JOIN dbo.Camera cam ON cam.CameraIntId = i.CameraIntId
	INNER JOIN dbo.Vehicle v ON v.VehicleIntId = i.VehicleIntId
	INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
	INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
	INNER JOIN dbo.CreationCode cc ON cc.CreationCodeId = i.CreationCodeId
WHERE i.EventDateTime BETWEEN @sdate AND @edate
	AND cc.CreationCodeId IN (55, 56, 455, 456, 436, 437, 438)
	AND cam.Serial = @serial
GROUP BY c.Name, v.Registration, cam.Serial
	--, cc.Name


GO
