SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_SendBulkOTA]
		@vids NVARCHAR(MAX) = NULL,
		@custid UNIQUEIDENTIFIER,
		@software VARCHAR(20),
		@testversion VARCHAR(20) = NULL,
		@rptonly BIT = NULL,
	    @force bit = 0
AS

--DECLARE @vids NVARCHAR(MAX),
--		@custid UNIQUEIDENTIFIER,
--		@software VARCHAR(20),
--		@testversion VARCHAR(20),
--		@rptonly BIT,
--		@force BIT
--		
--SET @vids = NULL--N'9B2B5A35-D0D9-4776-BB1F-87B27DBFD2CC,93431E81-EE44-4EEE-A959-387B6E4F9CE3,16DF929B-A773-46D2-900E-2CA8DCF23893,42C9DA5C-2BF6-4A23-865A-A5AB067F8DFA,87B51B30-B441-4A79-AD36-ED2BAD3E3204,7A03DFD2-3982-46E8-8C4E-12F297DEE350,B8C522B8-99C0-4630-A4DE-A7A523437829,39512BD9-7CCF-48AD-9623-46CD000D2AC6,3D0FA257-E0E9-4009-9508-BBFFA244F817,DFB2454E-1286-473B-9215-A38D8717CE57,C7343CE2-50EF-4AA2-AAAC-736442ECFA0A,ABAC69E6-CCCC-4E60-9F81-0B14A2CE8CFD,87A3B70E-9B8D-42CB-BB13-2E1C9427331C'
--SET @custid = N'36993114-90C0-4697-87E6-97C827D8765A'
--SET @software = '1_4_100'
--SET @testversion = NULL
--SET @rptonly = 1
--SET @force = 0

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
  AND cv.CustomerId = @custid
  AND (v.VehicleId IN (SELECT VALUE FROM dbo.Split(@vids, ',')) OR @vids IS NULL)

IF @rptonly = 1
BEGIN
	SELECT v.Registration, OTAString
	FROM dbo.Vehicle v
	INNER JOIN dbo.IVH i ON v.IVHId = i.IVHId
	INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
	LEFT JOIN @otatable o ON cv.VehicleId = o.VehicleId
	WHERE cv.Archived = 0
	  AND i.Archived = 0
	  AND cv.CustomerId = @custid
	  AND (v.VehicleId IN (SELECT VALUE FROM dbo.Split(@vids, ',')) OR @vids IS NULL)
--	ORDER BY v.Registration
END	ELSE
BEGIN
	IF @force = 1
	BEGIN
		INSERT INTO dbo.VehicleCommand (IVHId, Command, ExpiryDate, AcknowledgedDate, LastOperation, Archived)
		SELECT v.IVHId, CAST(OtaString AS VARBINARY(1024)), DATEADD(dd, 3, GETDATE()), NULL, GETDATE(), 0
		FROM dbo.Vehicle v
		INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
		INNER JOIN @otatable o ON cv.VehicleId = o.VehicleId
		WHERE cv.Archived = 0
		  AND cv.CustomerId = @custid
		  AND o.OtaString NOT LIKE 'Error%'
		  AND (v.VehicleId IN (SELECT VALUE FROM dbo.Split(@vids, ',')) OR @vids IS NULL)	
	END ELSE
	BEGIN
		INSERT INTO dbo.VehicleCommand (IVHId, Command, ExpiryDate, AcknowledgedDate, LastOperation, Archived)
		SELECT v.IVHId, CAST(OtaString AS VARBINARY(1024)), DATEADD(dd, 3, GETDATE()), NULL, GETDATE(), 0
		FROM dbo.Vehicle v
		INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
		INNER JOIN @otatable o ON cv.VehicleId = o.VehicleId
		WHERE cv.Archived = 0
		  AND cv.CustomerId = @custid
		  AND o.OtaString NOT LIKE 'Error%' AND o.OtaString NOT LIKE 'Software%'
		  AND (v.VehicleId IN (SELECT VALUE FROM dbo.Split(@vids, ',')) OR @vids IS NULL)
	END
END


GO
