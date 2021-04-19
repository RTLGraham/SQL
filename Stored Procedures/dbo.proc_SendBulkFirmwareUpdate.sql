SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[proc_SendBulkFirmwareUpdate]
		@vids NVARCHAR(MAX),
		@software VARCHAR(20),
		@rptonly BIT = NULL
AS

--DECLARE @vids NVARCHAR(MAX),
--		@software VARCHAR(20),
--		@rptonly BIT
		
--SET @vids = N'C98B01D1-B2E7-4378-A1A4-D5245CDDDF0D,2660BB7C-C530-4F5A-8988-EDB6DE4D21FE,A2609578-A02A-4150-8525-F86F3E0C2177'
--SET @software = '1_4_187'
--SET @rptonly = 1

DECLARE @otatable TABLE
(
	VehicleId UNIQUEIDENTIFIER,
	CurrentFirmware VARCHAR(MAX),
	NewFirmware VARCHAR(MAX),
	OtaString VARCHAR(MAX)
)

DECLARE @testversion VARCHAR(20)
SET @testversion = NULL

INSERT INTO @otatable (VehicleId, CurrentFirmware, NewFirmware, OtaString)
SELECT	v.VehicleId,

		vf.Website
		+ '_' + vf.Network
		+ '_' + ISNULL(vf.Com1, 'NON')
		+ '_' + ISNULL(vf.Com2, 'NON') 
		+ '_' + vf.CanType
		+ CASE WHEN vf.Options IS NULL THEN '' ELSE '_' + vf.Options END
		+ CASE WHEN @TestVersion IS NULL THEN '' ELSE '_' + @TestVersion END 
		+ '_' + vf.Version AS CurrentFirmware,

		vf.Website
		+ '_' + vf.Network
		+ '_' + ISNULL(vf.Com1, 'NON')
		+ '_' + ISNULL(vf.Com2, 'NON') 
		+ '_' + vf.CanType
		+ CASE WHEN vf.Options IS NULL THEN '' ELSE '_' + vf.Options END
		+ CASE WHEN @TestVersion IS NULL THEN '' ELSE '_' + @TestVersion END 
		+ '_' + @software AS NewFirmware,

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
		+ CASE WHEN vf.Options IS NULL THEN '' ELSE '_' + vf.Options END
		+ CASE WHEN @TestVersion IS NULL THEN '' ELSE '_' + @TestVersion END 
		+ '_' + @software
		+ '";PW=00000000;ID='
		+ CHAR(56 + CAST(SUBSTRING(i.SerialNumber,1,1) + SUBSTRING(i.SerialNumber,3,1) AS INT)) + SUBSTRING(i.SerialNumber,2,1) + SUBSTRING(RTRIM(i.SerialNumber),4, 50)
		+ ';*' 
		+ dbo.OTACheckSum('>STCH1' + s.FileSize + s.FileCheckSum + TFTPIPAddress + '"' + vf.Website + '_' + vf.Network + '_' + ISNULL(vf.Com1, 'NON') + '_' + ISNULL(vf.Com2, 'NON') + '_' + vf.CanType + CASE WHEN vf.Options IS NULL THEN '' ELSE '_' + vf.Options END + CASE WHEN @TestVersion IS NULL THEN '' ELSE '_' + @TestVersion END + '_' + @software + '";PW=00000000;ID=' + CHAR(56 + CAST(SUBSTRING(i.SerialNumber,1,1) + SUBSTRING(i.SerialNumber,3,1) AS INT)) + SUBSTRING(i.SerialNumber,2,1) + SUBSTRING(RTRIM(i.SerialNumber),4, 50) + ';*') 
		+ '<' END END END END
FROM dbo.Vehicle v
INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
INNER JOIN dbo.IVH i ON v.IVHId = i.IVHId
LEFT JOIN dbo.VehicleFirmware vf ON vf.VehicleId = v.VehicleId
LEFT JOIN dbo.IVHSoftware s ON s.FileName = vf.Website
		+ '_' + vf.Network
		+ '_' + ISNULL(vf.Com1, 'NON')
		+ '_' + ISNULL(vf.Com2, 'NON') 
		+ '_' + vf.CanType
		+ CASE WHEN vf.Options IS NULL THEN '' ELSE '_' + vf.Options END +  
		+ CASE WHEN @TestVersion IS NULL THEN '' ELSE '_' + @TestVersion END 
		+ '_' + @software
		AND s.Archived = 0
WHERE ISNULL(vf.BaseActiveInd, 'X') in ('A', 'X')
  AND v.Archived = 0
  AND i.Archived = 0
  AND v.VehicleId IN (SELECT VALUE FROM dbo.Split(@vids, ','))

IF @rptonly = 1
BEGIN
	SELECT v.VehicleId, i.IVHId, v.Registration, vle.EventDateTime AS LastEventDateTimeUTC, o.CurrentFirmware, o.NewFirmware, OTAString
	FROM dbo.Vehicle v
	INNER JOIN dbo.VehicleLatestAllEvent vle ON vle.VehicleId = v.VehicleId
	INNER JOIN dbo.IVH i ON v.IVHId = i.IVHId
	INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
	LEFT JOIN @otatable o ON cv.VehicleId = o.VehicleId
	WHERE cv.Archived = 0
	  AND i.Archived = 0
	  AND v.VehicleId IN (SELECT VALUE FROM dbo.Split(@vids, ','))
	ORDER BY v.Registration
END	ELSE
BEGIN
	INSERT INTO dbo.VehicleCommand (IVHId, Command, ExpiryDate, AcknowledgedDate, LastOperation, Archived)
	SELECT v.IVHId, CAST(OtaString AS VARBINARY(1024)), DATEADD(dd, 3, GETDATE()), NULL, GETDATE(), 0
	FROM dbo.Vehicle v
	INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
	INNER JOIN @otatable o ON cv.VehicleId = o.VehicleId
	WHERE cv.Archived = 0
        AND v.VehicleId IN (SELECT VALUE FROM dbo.Split(@vids, ','))
		AND o.OtaString NOT LIKE 'Error%' AND o.OtaString NOT LIKE 'Software%'
END


GO
