SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[proc_SendBulkOTA_AllCustomers]
AS

DECLARE @software VARCHAR(20),
		@testversion VARCHAR(20),
		@rptonly BIT,
		@force BIT
		
SET @software = '1_4_200'
SET @testversion = NULL
SET @rptonly = 0
SET @force = 0

DECLARE @vehicles TABLE
(
	VehicleId UNIQUEIDENTIFIER
)

INSERT INTO @vehicles (VehicleId)
SELECT DISTINCT v.VehicleId
--SELECT c.Name, v.VehicleId, v.VehicleIntId, v.Registration, vf.Version, vle.EventDateTime
FROM dbo.Vehicle v
	INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId
	INNER JOIN dbo.VehicleFirmware vf ON vf.VehicleId = v.VehicleId AND vf.BaseActiveInd = 'A'
	INNER JOIN dbo.VehicleLatestAllEvent vle ON vle.VehicleId = v.VehicleId
	INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
	INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
WHERE v.Archived = 0 AND c.Archived = 0 AND cv.Archived = 0 AND i.Archived = 0
	AND vle.EventDateTime BETWEEN DATEADD(MONTH, -1, GETUTCDATE()) AND GETDATE()
	AND vf.Version != @software
--ORDER BY c.Name, v.Registration


DECLARE @otatable TABLE
(
	VehicleId UNIQUEIDENTIFIER,
	OtaString VARCHAR(MAX)
)

INSERT INTO @otatable (VehicleId, OtaString)
SELECT	v.VehicleId,
		CASE WHEN i.SerialNumber IS NULL THEN 'Error - No Serial Number' ELSE
		CASE WHEN vf.BaseActiveInd IS NULL THEN 'Error - No Active CFG' ELSE
		CASE WHEN s.SoftwareId IS NULL THEN 'Error - No Software Build'  ELSE
		CASE WHEN vf.Version = @software AND ISNULL(vf.TestVersion, 'NULL') = ISNULL(@testversion, 'NULL') THEN 'Software already deployed' ELSE
		'>STCH1' + s.FileSize + s.FileCheckSum + TFTPIPAddress + '"' 
		+ vf.Website
		+ '_' + vf.Network
		+ '_' + ISNULL(vf.Com1, 'NON')
		+ '_' + ISNULL(vf.Com2, 'NON') 
		+ '_' + vf.CanType
		--+ CASE WHEN vf.Options IS NULL THEN '' ELSE '_' + vf.Options END
		+ CASE WHEN vf.Options IS NULL THEN '' ELSE '_' + vf.Options END
		+ CASE WHEN @TestVersion IS NULL THEN '' ELSE '_' + @TestVersion END 
		+ '_' + @software
		+ '";PW=00000000;ID='
		+ CHAR(56 + CAST(SUBSTRING(i.SerialNumber,1,1) + SUBSTRING(i.SerialNumber,3,1) AS INT)) + SUBSTRING(i.SerialNumber,2,1) + SUBSTRING(RTRIM(i.SerialNumber),4, 50)
		+ ';*' 
		+ dbo.OTACheckSum('>STCH1' + s.FileSize + s.FileCheckSum + TFTPIPAddress + '"' 
		+ vf.Website
		+ '_' + vf.Network 
		+ '_' + ISNULL(vf.Com1, 'NON') 
		+ '_' + ISNULL(vf.Com2, 'NON') 
		+ '_' + vf.CanType 
		+ CASE WHEN vf.Options IS NULL THEN '' ELSE '_' + vf.Options END 
		+ CASE WHEN @TestVersion IS NULL THEN '' ELSE '_' + @TestVersion END 
		+ '_' + @software 
		+ '";PW=00000000;ID=' 
		+ CHAR(56 + CAST(SUBSTRING(i.SerialNumber,1,1) + SUBSTRING(i.SerialNumber,3,1) AS INT)) + SUBSTRING(i.SerialNumber,2,1) + SUBSTRING(RTRIM(i.SerialNumber),4, 50) + ';*') 
		+ '<' END END END END
FROM dbo.Vehicle v
INNER JOIN @vehicles veh ON veh.VehicleId = v.VehicleId
INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
INNER JOIN dbo.IVH i ON v.IVHId = i.IVHId
LEFT JOIN dbo.VehicleFirmware vf ON vf.VehicleId = v.VehicleId
LEFT JOIN dbo.IVHSoftware s ON s.FileName = vf.Website
		+ '_' + vf.Network
		+ '_' + ISNULL(vf.Com1, 'NON')
		+ '_' + ISNULL(vf.Com2, 'NON') 
		+ '_' + vf.CanType
		--+ CASE WHEN vf.Options IS NULL THEN '' ELSE '_' + vf.Options END +  
		+ CASE WHEN vf.Options IS NULL THEN '' ELSE '_' + vf.Options END
		+ CASE WHEN @TestVersion IS NULL THEN '' ELSE '_' + @TestVersion END 
		+ '_' + @software
		AND s.Archived = 0
WHERE ISNULL(vf.BaseActiveInd, 'X') in ('A', 'X')
  AND v.Archived = 0
  AND i.Archived = 0

IF @rptonly = 1
BEGIN
	SELECT c.Name, v.Registration, OTAString, vle.EventDateTime,
			vf.Website
			+ '_' + vf.Network
			+ '_' + ISNULL(vf.Com1, 'NON')
			+ '_' + ISNULL(vf.Com2, 'NON') 
			+ '_' + vf.CanType
			--+ CASE WHEN vf.Options IS NULL THEN '' ELSE '_' + vf.Options END +  
			+ CASE WHEN vf.Options IS NULL THEN '' ELSE '_' + vf.Options END
			+ CASE WHEN @TestVersion IS NULL THEN '' ELSE '_' + @TestVersion END 
			+ '_' + @software AS RequestedFirmware
	FROM dbo.Vehicle v
	INNER JOIN @vehicles veh ON veh.VehicleId = v.VehicleId
	INNER JOIN dbo.VehicleFirmware vf ON vf.VehicleId = v.VehicleId AND vf.BaseActiveInd = 'A'
	LEFT OUTER JOIN dbo.VehicleLatestAllEvent vle ON vle.VehicleId = v.VehicleId
	INNER JOIN dbo.IVH i ON v.IVHId = i.IVHId
	INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
	INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
	LEFT JOIN @otatable o ON cv.VehicleId = o.VehicleId
	WHERE cv.Archived = 0
	  AND i.Archived = 0
	  --AND o.OtaString NOT LIKE 'Error%' AND o.OtaString NOT LIKE 'Software%'
	  --AND o.OtaString LIKE 'Software%'
	ORDER BY c.Name, v.Registration
END	ELSE
BEGIN
	IF @force = 1
	BEGIN
		INSERT INTO dbo.VehicleCommand (IVHId, Command, ExpiryDate, AcknowledgedDate, LastOperation, Archived)
		SELECT v.IVHId, CAST(OtaString AS VARBINARY(1024)), DATEADD(mi, 30, GETDATE()), NULL, GETDATE(), 0
		FROM dbo.Vehicle v
		INNER JOIN @vehicles veh ON veh.VehicleId = v.VehicleId
		INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
		INNER JOIN @otatable o ON cv.VehicleId = o.VehicleId
		WHERE cv.Archived = 0
		  AND o.OtaString NOT LIKE 'Error%'
	END ELSE
	BEGIN
		INSERT INTO dbo.VehicleCommand (IVHId, Command, ExpiryDate, AcknowledgedDate, LastOperation, Archived)
		SELECT v.IVHId, CAST(OtaString AS VARBINARY(1024)), DATEADD(mi, 30, GETDATE()), NULL, GETDATE(), 0
		FROM dbo.Vehicle v
		INNER JOIN @vehicles veh ON veh.VehicleId = v.VehicleId
		INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
		INNER JOIN @otatable o ON cv.VehicleId = o.VehicleId
		WHERE cv.Archived = 0
		  AND o.OtaString NOT LIKE 'Error%' AND o.OtaString NOT LIKE 'Software%'
	END
END







GO
