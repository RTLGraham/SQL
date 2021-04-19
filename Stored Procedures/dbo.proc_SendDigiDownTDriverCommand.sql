SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[proc_SendDigiDownTDriverCommand] 
AS

BEGIN

	DECLARE @LastOperation SMALLDATETIME
	SET @LastOperation = GETDATE()

	-- Mark Rows as in process
	UPDATE dbo.EventData_DriverLogin
	SET Archived = 1

	-- Now process the data
	INSERT INTO dbo.VehicleCommand
	        ( IVHId ,
	          Command ,
	          ExpiryDate ,
	          AcknowledgedDate ,
	          LastOperation ,
	          Archived ,
	          ProcessInd
	        )
	SELECT DISTINCT v.IVHId, CAST('>STCXAT+DBGD=CARD' AS VARBINARY(1024)), DATEADD(hh, 23, GETUTCDATE()), NULL, @LastOperation, 0, NULL
	FROM dbo.EventData_DriverLogin dl
	LEFT JOIN dbo.DigiDownTLog l ON l.DriverIntId = dl.DriverIntId AND l.FileTimeStamp > DATEADD(hh, -24, GETUTCDATE()) AND l.Succeeded = 1
	INNER JOIN dbo.Vehicle v ON v.VehicleIntId = dl.VehicleIntId
	INNER JOIN dbo.VehicleFirmware vf ON vf.VehicleId = v.VehicleId AND vf.BaseActiveInd = 'A'
	INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId
	INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
	INNER JOIN dbo.CustomerPreference cp ON cp.CustomerID = cv.CustomerId
	WHERE i.IVHTypeId = 5 -- only send to vehicles fitted with Cheetah units
	  AND cp.NameID = 3003
	  AND cp.Value = '1'
	  AND cv.EndDate IS NULL	
	  AND (vf.COM1 = 'DIG' OR vf.COM2 = 'DIG')
	  AND cv.Archived = 0
	  AND v.Archived = 0
	  AND v.IVHId IS NOT NULL	
	  AND l.DigiDownTLogId IS NULL -- no command sent within the last 24 hours
	  AND dl.Archived = 1
	
	DELETE
    FROM dbo.EventData_DriverLogin
	WHERE Archived = 1

END





GO
