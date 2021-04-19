SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[proc_SendDigiDownTDriverCommandPeriodic] 
AS

BEGIN

	DECLARE @hours_AllowedTimeForDownload INT
	SELECT  @hours_AllowedTimeForDownload = 2	-- allow 2h to finish the download

	DECLARE @vehicleCommand TABLE
	(
		CommandId [INT] NOT NULL IDENTITY(1, 1),
		[IVHId] [uniqueidentifier] NOT NULL,
		[DriverIntId] INT NULL,
		[Command] [binary] (1024) NULL,
		[ExpiryDate] [smalldatetime] NULL,
		[AcknowledgedDate] [smalldatetime] NULL,
		[LastOperation] [smalldatetime] NULL,
		[Archived] [bit] NOT NULL,
		[ProcessInd] [bit] NULL
	)
	PRINT 'Candidates Cheetah'
	INSERT INTO @vehicleCommand
	        ( IVHId ,
			  DriverIntId ,
	          Command ,
	          ExpiryDate ,
	          AcknowledgedDate ,
	          LastOperation ,
	          Archived ,
	          ProcessInd
	        )
	SELECT	DISTINCT v.IVHId, 
			d.DriverIntId,
			CAST('>STCXAT+DBGD=CARD' AS VARBINARY(1024)), 
			DATEADD(hh, 23, GETUTCDATE()), 
			NULL, 
			GETDATE(), 
			0, 
			NULL
	FROM dbo.Vehicle v
		INNER JOIN dbo.VehicleLatestEvent vle ON vle.VehicleId = v.VehicleId
		INNER JOIN dbo.Driver d ON d.DriverId = vle.DriverId
		INNER JOIN dbo.VehicleFirmware vf ON vf.VehicleId = v.VehicleId AND vf.BaseActiveInd = 'A'
		--LEFT JOIN dbo.DigiDownTLog l ON l.DriverIntId = d.DriverIntId AND l.FileTimeStamp > DATEADD(DAY, DATEDIFF(DAY, 0, GETUTCDATE()), 0) AND l.Succeeded = 1 AND l.FileName LIKE '%crd'	-- no card files today
		LEFT JOIN dbo.DigiDownTControl t ON t.DriverIntid = d.DriverIntId AND FLOOR(CAST(t.CommandDateTime AS FLOAT)) = FLOOR(CAST(GETUTCDATE() AS FLOAT)) 
									AND (t.StatusId = 2 OR (t.StatusId = 1 AND DATEDIFF(hh, t.CommandDateTime, GETDATE()) <= @hours_AllowedTimeForDownload))
		INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId
		INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
		INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
		INNER JOIN dbo.CustomerPreference cp ON cp.CustomerID = c.CustomerId
	WHERE i.IVHTypeId = 5 -- only send to vehicles fitted with Cheetah units
		AND (vf.COM1 = 'DIG' OR vf.COM2 = 'DIG')
		--AND v.Registration IN ('DK65 XEU', 'DE62 JHK') 
		AND v.Archived = 0
		AND cv.EndDate IS NULL	
		AND cv.Archived = 0
		AND v.Archived = 0
		AND v.IVHId IS NOT NULL	
		AND ISNULL(ISNULL(d.Number, d.NumberAlternate), d.NumberAlternate2) != 'No ID'
		--AND l.DigiDownTLogId IS NULL -- no successful download within the current calendar day
		AND t.DigiDownTControlId IS NULL -- no download in progress or already succeeded within the last 24 hours
		AND vle.VehicleMode = 1 -- Vehicle is Driving
		AND vle.Speed > 30
		AND cp.NameID = 3003  
	    AND cp.Value = '1'

	PRINT 'Candidates A11'
	INSERT INTO @vehicleCommand
	        ( IVHId ,
			  DriverIntId ,
	          Command ,
	          ExpiryDate ,
	          AcknowledgedDate ,
	          LastOperation ,
	          Archived ,
	          ProcessInd
	        )
	SELECT	DISTINCT v.IVHId, 
			d.DriverIntId,
			CAST('>STCXAT+DBGD=CARD' AS VARBINARY(1024)), 
			DATEADD(hh, 23, GETUTCDATE()), 
			NULL, 
			GETDATE(), 
			0, 
			NULL
	FROM dbo.Vehicle v
		INNER JOIN dbo.VehicleLatestEvent vle ON vle.VehicleId = v.VehicleId
		INNER JOIN dbo.Driver d ON d.DriverId = vle.DriverId
		LEFT JOIN dbo.DigiDownTControl t ON t.DriverIntid = d.DriverIntId AND FLOOR(CAST(t.CommandDateTime AS FLOAT)) = FLOOR(CAST(GETUTCDATE() AS FLOAT)) 
									AND (t.StatusId = 2 OR (t.StatusId = 1 AND DATEDIFF(hh, t.CommandDateTime, GETDATE()) <= @hours_AllowedTimeForDownload))
		INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId
		INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
		INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
		INNER JOIN dbo.CustomerPreference cp ON cp.CustomerID = c.CustomerId
	WHERE i.IVHTypeId = 9 -- only send to vehicles fitted with A11 units
		AND v.Archived = 0
		AND cv.EndDate IS NULL	
		AND cv.Archived = 0
		AND v.Archived = 0
		AND v.IVHId IS NOT NULL	
		AND ISNULL(ISNULL(d.Number, d.NumberAlternate), d.NumberAlternate2) != 'No ID'
		--AND l.DigiDownTLogId IS NULL -- no successful download within the current calendar day
		AND t.DigiDownTControlId IS NULL -- no download in progress or already succeeded within the last 24 hours
		AND vle.VehicleMode = 1 -- Vehicle is Driving
		AND vle.Speed > 30
		AND cp.NameID = 3003  
	    AND cp.Value = '1'


	INSERT INTO dbo.VehicleCommand
	        ( IVHId ,
	          Command ,
	          ExpiryDate ,
	          AcknowledgedDate ,
	          LastOperation ,
	          Archived ,
	          ProcessInd
	        )
	SELECT vc.IVHId ,
           vc.Command ,
           vc.ExpiryDate ,
           vc.AcknowledgedDate ,
           vc.LastOperation ,
           vc.Archived ,
           vc.ProcessInd
	FROM @vehicleCommand vc

	-- Insert newly issued commands into DigidownTControl table
	INSERT INTO dbo.DigiDownTControl
	        (VehicleIntId,
	         DriverIntid,
	         CommandId,
	         CommandDateTime,
	         ExpiryDateTime,
	         StatusId
	        )
	SELECT v.VehicleIntId ,
           vc.DriverIntId ,
           NULL,
           vc.LastOperation ,
           vc.ExpiryDate ,
           1
	FROM @vehicleCommand vc
	INNER JOIN dbo.Vehicle v ON v.IVHId = vc.IVHId
	INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
	INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId

	UPDATE dbo.DigiDownTControl
	SET CommandId = vc.CommandId
	FROM dbo.DigiDownTControl t
	INNER JOIN dbo.Vehicle v ON v.VehicleIntId = t.VehicleIntId
	INNER JOIN dbo.VehicleCommand vc ON vc.IVHId = v.IVHId AND t.CommandDateTime = vc.LastOperation AND CAST(vc.Command AS VARCHAR(1024)) LIKE '%>STCXAT+DBGD=CARD%'
	WHERE t.CommandId IS NULL	
	
END




GO
