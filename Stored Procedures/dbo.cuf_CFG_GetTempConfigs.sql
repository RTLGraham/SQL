SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[cuf_CFG_GetTempConfigs]
(
	@vids VARCHAR(MAX),
	@uid UNIQUEIDENTIFIER
)
AS

BEGIN	
--DECLARE @vids VARCHAR(MAX),
--		@uid UNIQUEIDENTIFIER 

----SET @vids = N'7A194F1E-F9BB-45B0-AFC3-DE7E228B5EA9'
--SET @vids = N'E49EE089-9A99-4CED-A069-5C793CD9CDDE'		
--SET @uid = N'3DB40C4A-7E79-4F41-8017-DE6E12EC7A20'




SELECT hcurr.IVHIntId,c.CommandRoot,k.Name,hcurr.KeyValue, 
v.VehicleId, v.Registration, i.IVHId, i.IVHIntId, i.TrackerNumber, hcurr.KeyId, k.Name AS KeyName, k.Description AS KeyDescription, kc.IndexPos AS KeyIndex, 
	   cat.CategoryId, cat.Name AS CategoryName, cat.Description AS CategoryDescription,
	   it.ReadCommandPrefix + c.CommandRoot + it.ReadCommandSuffix AS ReadCommandString,
	   it.WriteCommandPrefix + c.CommandRoot + it.WriteCommandSuffix AS WriteCommandString,
	   c.Description AS CommandDescription, it.IVHTypeId, it.Name AS IVHTypeName, it.Description AS IVHTypeDescription,
	   k.MinValue, k.MaxValue, k.MinDate, k.MaxDate 
FROM dbo.Vehicle v
INNER JOIN dbo.IVH i ON v.IVHId = i.IVHId
INNER JOIN dbo.CFG_History hcurr ON i.IVHIntId = hcurr.IVHIntId AND hcurr.EndDate IS NULL AND hcurr.Status = 1
INNER JOIN dbo.CFG_Key k ON hcurr.KeyId = k.KeyId
INNER JOIN dbo.CFG_KeyCommand kc ON k.KeyId = kc.KeyId
INNER JOIN dbo.CFG_Command c ON kc.CommandId = c.CommandId
INNER JOIN dbo.CFG_Category cat ON c.CategoryId = cat.CategoryId
INNER JOIN dbo.IVHType it ON c.IVHTypeId = it.IVHTypeId AND i.IVHTypeId = it.IVHTypeId
LEFT JOIN dbo.CFG_History hpend ON hpend.IVHIntId = i.IVHIntId  AND k.KeyId = hpend.KeyId AND hpend.EndDate IS NULL AND hpend.Status IS NULL
INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
INNER JOIN dbo.[User] u ON u.CustomerID = cv.CustomerId
WHERE v.VehicleId IN (SELECT Value FROM dbo.Split(@vids, ','))
AND	 c.CommandRoot = 'RTLT'
AND kc.IndexPos >= 0
AND i.IVHTypeId < 8 --Device types that are less than 8 have configs stored in the main database.
AND v.VehicleId = @vids
AND c.Archived = 0
AND v.Archived = 0
AND u.userID = @uid
 



UNION 

SELECT d.DeviceId,c.CommandRoot,cp.Name,cc.ParamValue,
v.VehicleId,v.Registration,i.IVHId,i.IVHIntId,i.TrackerNumber,cfh.DeviceId,it.Name,cf.Description,cp.IndexPos,
c.CategoryId,cf.BucketName,c.Description,
 it.ReadCommandPrefix + c.CommandRoot + it.ReadCommandSuffix AS ReadCommandString,
it.WriteCommandPrefix + c.CommandRoot + it.WriteCommandSuffix AS WriteCommandString,
cp.Description,it.IVHTypeId, it.Name AS IVHTypeName, it.Description AS IVHTypeDescription,
cp.MinValue, cp.MaxValue, cp.MinDate, cp.MaxDate
FROM [192.168.53.14].CommServer.dbo.Device d
INNER JOIN [192.168.53.14].CommServer.dbo.ConfigFileHistory cfh ON cfh.DeviceId = d.DeviceId
INNER JOIN [192.168.53.14].CommServer.dbo.ConfigFile cf ON cf.ConfigFileId = cfh.ConfigFileId
INNER JOIN [192.168.53.14].CommServer.dbo.SWConfigComponentFiles sc ON sc.SWConfigFileId = cf.ConfigFileId
INNER JOIN [192.168.53.14].CommServer.dbo.ConfigFile cf2 ON cf2.ConfigFileId = sc.ComponentConfigFileId
INNER JOIN [192.168.53.14].CommServer.dbo.Command c ON c.DeviceTypeId = d.DeviceTypeId
INNER JOIN [192.168.53.14].CommServer.dbo.CommandParameter cp ON cp.CommandId = c.CommandId
INNER JOIN [192.168.53.14].CommServer.dbo.ConfigComponent cc ON cc.CommandParameterId = cp.CommandParameterId AND cc.ConfigFileId = cf2.ConfigFileId
INNER JOIN dbo.IVH i ON i.SerialNumber = d.SerialNumber
INNER JOIN dbo.IVHType it ON it.IVHTypeId = i.IVHTypeId
INNER JOIN dbo.Vehicle v ON v.IVHId = i.IVHId
WHERE cf2.CategoryId = 5
AND c.CommandRoot = 'RTLT'
AND c.DeviceTypeId >= 8 -- Device Types greater than 8 data stored in commserver
AND v.VehicleId = @vids

ORDER BY kc.IndexPos ASC
END	

GO
