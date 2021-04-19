SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[proc_SendDigiDownTCommands] 
AS

BEGIN

	DECLARE @hours_AllowedTimeForDownload INT,
			@downloadLimit TINYINT
	SELECT  @hours_AllowedTimeForDownload = 2	-- number of hours allowed to finish the download
	SELECT @downloadLimit = 10 -- maximum number of days for download

	DECLARE @vehicleCommand TABLE
	(
		CommandId [INT] NOT NULL IDENTITY(1, 1),
		[IVHId] [uniqueidentifier] NOT NULL,
		[Command] [binary] (1024) NULL,
		[ExpiryDate] [smalldatetime] NULL,
		[AcknowledgedDate] [smalldatetime] NULL,
		[LastOperation] [smalldatetime] NULL,
		[Archived] [bit] NOT NULL,
		[ProcessInd] [bit] NULL
	)

	DECLARE @LatestDownload TABLE	
	(
		IVHId UNIQUEIDENTIFIER,
		LatestDownload DATETIME,
		DaysToDownload INT
	) 


	PRINT 'Latest Downloads Cheetah'
	INSERT INTO @LatestDownload (IVHId, LatestDownload, DaysToDownload)
	SELECT	v.IVHId, MAX(l.FileTimeStamp) AS LatestDownload, DATEDIFF(dd, MAX(l.FileTimeStamp), GETUTCDATE() + 1) AS DaysToDownload
	FROM dbo.Vehicle v
		INNER JOIN dbo.VehicleLatestEvent vle ON vle.VehicleId = v.VehicleId
		INNER JOIN dbo.VehicleFirmware vf ON vf.VehicleId = v.VehicleId AND vf.BaseActiveInd = 'A'
		INNER JOIN dbo.DigiDownTLog l ON l.VehicleIntId = v.VehicleIntId --AND l.FileTimeStamp > DATEADD(hh, -24, GETUTCDATE()) 	
		INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId
		INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
		INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
		INNER JOIN dbo.CustomerPreference cp ON cp.CustomerID = c.CustomerId
	WHERE i.IVHTypeId = 5 -- only send to vehicles fitted with Cheetah units
		AND (vf.COM1 = 'DIG' OR vf.COM2 = 'DIG')
		AND v.Archived = 0
		AND cv.EndDate IS NULL	
		AND cv.Archived = 0
		AND v.Archived = 0
		AND v.IVHId IS NOT NULL	
		AND l.Succeeded = 1 
		AND (l.FileName LIKE '%vu' OR l.FileName LIKE '%DDD' OR l.FileName LIKE '%V1B' OR l.FileName LIKE '%TGD')
		AND cp.NameID = 3003
		AND cp.Value = '1'
	GROUP BY v.IVHId

	PRINT 'Latest Downloads A11'
	INSERT INTO @LatestDownload (IVHId, LatestDownload, DaysToDownload)
	SELECT	v.IVHId, MAX(l.FileTimeStamp) AS LatestDownload, DATEDIFF(dd, MAX(l.FileTimeStamp), GETUTCDATE() + 1) AS DaysToDownload
	FROM dbo.Vehicle v
		INNER JOIN dbo.VehicleLatestEvent vle ON vle.VehicleId = v.VehicleId
		INNER JOIN dbo.DigiDownTLog l ON l.VehicleIntId = v.VehicleIntId --AND l.FileTimeStamp > DATEADD(hh, -24, GETUTCDATE()) 	
		INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId
		INNER JOIN dbo.IVHType it ON it.IVHTypeId = i.IVHTypeId
		INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
		INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
		INNER JOIN dbo.CustomerPreference cp ON cp.CustomerID = c.CustomerId
	WHERE i.IVHTypeId = 9 -- only send to vehicles fitted with A11 units
		AND v.Archived = 0
		AND cv.EndDate IS NULL	
		AND cv.Archived = 0
		AND v.Archived = 0
		AND v.IVHId IS NOT NULL	
		AND l.Succeeded = 1 
		AND (l.FileName LIKE '%vu' OR l.FileName LIKE '%DDD' OR l.FileName LIKE '%V1B' OR l.FileName LIKE '%TGD')
		AND cp.NameID = 3003
		AND cp.Value = '1'
	GROUP BY v.IVHId

	PRINT 'Candidates Cheetah'
	INSERT INTO @vehicleCommand
	        ( IVHId ,
	          Command ,
	          ExpiryDate ,
	          AcknowledgedDate ,
	          LastOperation ,
	          Archived ,
	          ProcessInd
	        )
	SELECT	DISTINCT v.IVHId, 
			CASE WHEN c.Name IN ('Sucklings Transport', 'Air Products Spain') --Customers with speeding data
				THEN CAST('>STCXAT+DBGD=(1,2,3,4,5)(' + CAST(CASE WHEN ld.DaysToDownload > @downloadLimit THEN @downloadLimit ELSE ISNULL(ld.DaysToDownload, 3) END AS VARCHAR(2)) + ')' AS VARBINARY(1024))
				ELSE CAST('>STCXAT+DBGD=(1,2,3,5)(' + CAST(CASE WHEN ld.DaysToDownload > @downloadLimit THEN @downloadLimit ELSE ISNULL(ld.DaysToDownload, 3) END AS VARCHAR(2)) + ')' AS VARBINARY(1024))
			END, 
			DATEADD(hh, 23, GETUTCDATE()), 
			NULL, 
			GETDATE(), 
			0, 
			NULL
	FROM dbo.Vehicle v
		INNER JOIN dbo.VehicleLatestEvent vle ON vle.VehicleId = v.VehicleId
		INNER JOIN dbo.VehicleFirmware vf ON vf.VehicleId = v.VehicleId AND vf.BaseActiveInd = 'A'
		LEFT JOIN dbo.DigiDownTControl t ON t.VehicleIntId = v.VehicleIntId AND t.DriverIntid IS NULL AND FLOOR(CAST(t.CommandDateTime AS FLOAT)) = FLOOR(CAST(GETDATE() AS FLOAT)) 
									AND (t.StatusId = 2 OR (t.StatusId = 1 AND DATEDIFF(hh, t.CommandDateTime, GETDATE()) <= @hours_AllowedTimeForDownload))
		LEFT JOIN @LatestDownload ld ON ld.IVHId = v.IVHId
		INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId
		INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
		INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
		INNER JOIN dbo.CustomerPreference cp ON cp.CustomerID = c.CustomerId
	WHERE i.IVHTypeId = 5 -- only send to vehicles fitted with Cheetah units
		AND (vf.COM1 = 'DIG' OR vf.COM2 = 'DIG')
		AND v.Archived = 0
		AND cv.EndDate IS NULL	
		AND cv.Archived = 0
		AND v.Archived = 0
		AND v.IVHId IS NOT NULL	
		AND t.DigiDownTControlId IS NULL -- no download in progress or already succeeded within the last 24 hours
		AND vle.VehicleMode = 1 -- Vehicle is Driving
		AND vle.Speed > 30
		AND cp.NameID = 3003
		AND cp.Value = '1'

	PRINT 'Candidates A11'
	INSERT INTO @vehicleCommand
	        ( IVHId ,
	          Command ,
	          ExpiryDate ,
	          AcknowledgedDate ,
	          LastOperation ,
	          Archived ,
	          ProcessInd
	        )
	SELECT	DISTINCT v.IVHId, 
			CASE WHEN c.Name IN ('Sucklings Transport', 'Air Products Spain') --Customers with speeding data
				THEN CAST('>STCXAT+DBGD=(1,2,3,4,5)(' + CAST(CASE WHEN ld.DaysToDownload > @downloadLimit THEN @downloadLimit ELSE ISNULL(ld.DaysToDownload, 3) END AS VARCHAR(2)) + ')' AS VARBINARY(1024))
				ELSE CAST('>STCXAT+DBGD=(1,2,3,5)(' + CAST(CASE WHEN ld.DaysToDownload > @downloadLimit THEN @downloadLimit ELSE ISNULL(ld.DaysToDownload, 3) END AS VARCHAR(2)) + ')' AS VARBINARY(1024))
			END, 
			DATEADD(hh, 23, GETUTCDATE()), 
			NULL, 
			GETDATE(), 
			0, 
			NULL
	FROM dbo.Vehicle v
		INNER JOIN dbo.VehicleLatestEvent vle ON vle.VehicleId = v.VehicleId
		LEFT JOIN dbo.DigiDownTControl t ON t.VehicleIntId = v.VehicleIntId AND t.DriverIntid IS NULL AND FLOOR(CAST(t.CommandDateTime AS FLOAT)) = FLOOR(CAST(GETDATE() AS FLOAT)) 
									AND (t.StatusId = 2 OR (t.StatusId = 1 AND DATEDIFF(hh, t.CommandDateTime, GETDATE()) <= @hours_AllowedTimeForDownload))
		LEFT JOIN @LatestDownload ld ON ld.IVHId = v.IVHId
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
           vc.Command,
           vc.ExpiryDate ,
           vc.AcknowledgedDate ,
           vc.LastOperation ,
           vc.Archived ,
           vc.ProcessInd
	FROM @vehicleCommand vc
	INNER JOIN dbo.Vehicle v ON v.IVHId = vc.IVHId
	INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
	INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId

	-- Insert newly issued commands into DigidownTControl table
	INSERT INTO dbo.DigiDownTControl
	        (VehicleIntId,
	         DriverIntid,
	         CommandId,
	         CommandDateTime,
	         ExpiryDateTime,
	         StatusId,
			 DaysToDownload,
			 DownloadLimit
	        )
	SELECT v.VehicleIntId ,
           NULL,
           NULL,
           vc.LastOperation ,
           vc.ExpiryDate ,
           1,
		   ld.DaysToDownload,
		   @downloadLimit
	FROM @vehicleCommand vc
	INNER JOIN dbo.Vehicle v ON v.IVHId = vc.IVHId
	INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
	INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
	LEFT JOIN @LatestDownload ld ON ld.IVHId = vc.IVHId

	UPDATE dbo.DigiDownTControl
	SET CommandId = vc.CommandId
	FROM dbo.DigiDownTControl t
	INNER JOIN dbo.Vehicle v ON v.VehicleIntId = t.VehicleIntId
	INNER JOIN dbo.VehicleCommand vc ON vc.IVHId = v.IVHId AND t.CommandDateTime = vc.LastOperation AND CAST(vc.Command AS VARCHAR(1024)) LIKE '>STCXAT+DBGD=%'
	WHERE t.CommandId IS NULL	

END




GO
