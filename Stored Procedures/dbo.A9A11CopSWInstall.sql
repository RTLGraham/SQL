SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE PROCEDURE [dbo].[A9A11CopSWInstall]
AS	
BEGIN	

	-- Requirements for A9 and A11 are slightly different so the initial inserts are done separately for each device type

	-- A9 First
	INSERT INTO dbo.A9A11CopSWCommands
			(VehicleId,
			 IVHId,
			 DeviceTypeId,
			 Command,
			 SentDateTime,
			 ProcessInd
			)
	SELECT	DISTINCT v.VehicleId,
			i.IVHId,
			d.DeviceTypeId, 
			'>STCXAT-OTAP=http://cs.l-track.com/home/Download/7b0f7663-f35f-48cc-a3c4-31053484299c',
			GETDATE(),
			0
	FROM dbo.Vehicle v
	INNER JOIN dbo.VehicleLatestAllEvent vlae ON vlae.VehicleId = v.VehicleId AND DATEDIFF(MINUTE, vlae.EventDateTime, GETUTCDATE()) <= 4
	INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId
	INNER JOIN [192.168.53.14].[CommServer].dbo.Device d ON i.TrackerNumber = d.IMEI
	INNER JOIN [192.168.53.14].[CommServer].dbo.Firmware f ON f.FirmwareId = d.FirmwareId
	INNER JOIN [192.168.53.14].[CommServer].dbo.DeviceType dt ON dt.DeviceTypeId = d.DeviceTypeId
	WHERE v.Archived = 0
	  AND i.Archived = 0
	  AND vlae.Speed > 20
	  AND vlae.DigitalIO >= 128
	  AND vlae.CreationCodeId != 5
	  AND d.DeviceTypeId = 8 AND dbo.CompareDottedDecimal('3.9.7', d.CopSW) = 1  -- d.CopSW != '3.9.8'
	  AND dbo.CompareDottedDecimal(f.FirmwareVersion, '1.14.0') = 1  -- A9 firmware must be at least version 1.14.0

	-- Now A11
	INSERT INTO dbo.A9A11CopSWCommands
			(VehicleId,
			 IVHId,
			 DeviceTypeId,
			 Command,
			 SentDateTime,
			 ProcessInd
			)
	SELECT	DISTINCT v.VehicleId,
			i.IVHId,
			d.DeviceTypeId, 
			'>STCXAT-OTAP=http://cs.l-track.com/home/Download/b58a825d-2723-4c59-9593-5041695d4e41',
			GETDATE(),
			0
	FROM dbo.Vehicle v
	INNER JOIN dbo.VehicleLatestAllEvent vlae ON vlae.VehicleId = v.VehicleId AND DATEDIFF(MINUTE, vlae.EventDateTime, GETUTCDATE()) <= 4
	INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId
	INNER JOIN [192.168.53.14].[CommServer].dbo.Device d ON i.TrackerNumber = d.IMEI
	INNER JOIN [192.168.53.14].[CommServer].dbo.DeviceType dt ON dt.DeviceTypeId = d.DeviceTypeId
	WHERE v.Archived = 0
	  AND i.Archived = 0
	  AND vlae.Speed > 20
	  AND vlae.DigitalIO >= 128
	  AND vlae.CreationCodeId != 5
	  AND d.DeviceTypeId = 9 AND dbo.CompareDottedDecimal('1.5.7', d.CopSW) = 1  -- d.CopSW != '1.5.8'

	UPDATE dbo.A9A11CopSWCommands
	SET ProcessInd = 1
	WHERE ProcessInd = 0

	INSERT INTO dbo.VehicleCommand
			(IVHId,
			 Command,
			 ExpiryDate,
			 AcknowledgedDate,
			 LastOperation,
			 Archived,
			 ProcessInd,
			 ReceivedDate
			)
	SELECT IVHId, CAST(Command AS VARBINARY(1024)), DATEADD(MINUTE, 10, GETDATE()), NULL, GETDATE(), 0, 0, NULL
	FROM dbo.A9A11CopSWCommands
	WHERE ProcessInd = 1

	UPDATE dbo.A9A11CopSWCommands
	SET ProcessInd = 2
	WHERE ProcessInd = 1

END	

GO
