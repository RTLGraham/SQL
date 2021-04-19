SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_CFG_History_GetCurrentConfigs]
(
	@vids VARCHAR(MAX),
	@uid UNIQUEIDENTIFIER
)
AS
BEGIN

--DECLARE @vids VARCHAR(MAX),
--		@uid UNIQUEIDENTIFIER
--
--SET @vids = N'8016F50D-A2D1-49A9-BC1E-13AE27953390,486A43F1-70D9-46CC-A745-542B6A4D77CE,5DE385BF-BFCB-4179-90CB-5AEE460B14AD,67B44E7F-6A0E-42E0-9DCF-5DDCA2AF502E,2C1A82DE-6DCB-4D03-BC21-5F65198B9A84,DB3AC174-1CFE-404C-914B-6BE9DB1B7038,D075F7EF-C02E-46E4-91C3-8191F2167F59,6CD1331B-F7FC-4866-A333-8FEE45667F33,91D26E73-DBD4-45DA-935C-997766C44AA2,3708F23A-F7CA-44F0-BB96-A94E80C40DFF'
--SET @uid = N'3C65E267-ED53-4599-98C5-CBF5AFD85A66'

-- Get Active values along with any corresponding pending values 

SELECT v.VehicleId, v.Registration, i.IVHId, i.IVHIntId, i.TrackerNumber, hcurr.KeyId, k.Name AS KeyName, k.Description AS KeyDescription, kc.IndexPos AS KeyIndex, 
	   cat.CategoryId, cat.Name AS CategoryName, cat.Description AS CategoryDescription,
	   it.ReadCommandPrefix + com.CommandRoot + it.ReadCommandSuffix AS ReadCommandString,
	   it.WriteCommandPrefix + com.CommandRoot + it.WriteCommandSuffix AS WriteCommandString,
	   com.Description AS CommandDescription, it.IVHTypeId, it.Name AS IVHTypeName, it.Description AS IVHTypeDescription,
	   k.MinValue, k.MaxValue, k.MinDate, k.MaxDate, 
	   hcurr.KeyValue AS ActiveValue, 
--	   dbo.TZ_GetTime(hcurr.StartDate,default,@uid) AS ActiveStartDate, -- TZ conversion removed for performance
	   hcurr.StartDate AS ActiveStartdate,
	   hpend.KeyValue AS PendingValue, 	   
--	   dbo.TZ_GetTime(hpend.StartDate,default,@uid) AS PendingStartDate, -- TZ conversion removed for performance
	   hpend.StartDate AS PendingStartDate,
	   CASE WHEN hpend.KeyValue IS NULL THEN hcurr.Status ELSE hpend.Status END AS PendingStatus
FROM dbo.Vehicle v
INNER JOIN dbo.IVH i ON v.IVHId = i.IVHId
INNER JOIN dbo.CFG_History hcurr ON i.IVHIntId = hcurr.IVHIntId AND hcurr.EndDate IS NULL AND hcurr.Status = 1
INNER JOIN dbo.CFG_Key k ON hcurr.KeyId = k.KeyId
INNER JOIN dbo.CFG_KeyCommand kc ON k.KeyId = kc.KeyId
INNER JOIN dbo.CFG_Command com ON kc.CommandId = com.CommandId
INNER JOIN dbo.CFG_Category cat ON com.CategoryId = cat.CategoryId
INNER JOIN dbo.IVHType it ON com.IVHTypeId = it.IVHTypeId AND i.IVHTypeId = it.IVHTypeId
LEFT JOIN dbo.CFG_History hpend ON hpend.IVHIntId = i.IVHIntId  AND k.KeyId = hpend.KeyId AND hpend.EndDate IS NULL AND hpend.Status IS NULL
WHERE v.VehicleId IN (SELECT Value FROM dbo.Split(@vids, ','))

UNION

-- union with any pending values that don't have current active values


SELECT v.VehicleId, v.Registration, i.IVHId, i.IVHIntId, i.TrackerNumber, hpend.KeyId, k.Name AS KeyName, k.Description AS KeyDescription, kc.IndexPos AS KeyIndex,
	   cat.CategoryId, cat.Name AS CategoryName, cat.Description AS CategoryDescription,
	   it.ReadCommandPrefix + com.CommandRoot + it.ReadCommandSuffix AS ReadCommandString,
	   it.WriteCommandPrefix + com.CommandRoot + it.WriteCommandSuffix AS WriteCommandString,
	   com.Description AS CommandDescription, it.IVHTypeId, it.Name AS IVHTypeName, it.Description AS IVHTypeDescription,
	   k.MinValue, k.MaxValue, k.MinDate, k.MaxDate,
	   NULL AS ActiveValue, NULL AS ActiveStartDate,
	   hpend.KeyValue AS PendingValue, 
--	   dbo.TZ_GetTime(hpend.StartDate,default,@uid) AS PendingStartDate,  -- TZ conversion removed for performance
	   hpend.StartDate AS PendingStartDate,
	   hpend.Status AS PendingStatus
FROM dbo.Vehicle v
INNER JOIN dbo.IVH i ON v.IVHId = i.IVHId
INNER JOIN dbo.CFG_History hpend ON i.IVHIntId = hpend.IVHIntId AND hpend.EndDate IS NULL AND hpend.Status IS NULL
INNER JOIN dbo.CFG_Key k ON hpend.KeyId = k.KeyId
INNER JOIN dbo.CFG_KeyCommand kc ON k.KeyId = kc.KeyId
INNER JOIN dbo.CFG_Command com ON kc.CommandId = com.CommandId
INNER JOIN dbo.CFG_Category cat ON com.CategoryId = cat.CategoryId
INNER JOIN dbo.IVHType it ON com.IVHTypeId = it.IVHTypeId AND i.IVHTypeId = it.IVHTypeId
WHERE v.VehicleId IN (SELECT Value FROM dbo.Split(@vids, ','))
  AND NOT EXISTS (SELECT 1
				  FROM CFG_History h
				  WHERE h.IVHIntId = hpend.IVHIntId
				    AND h.KeyId = hpend.KeyId
				    AND h.Status = 1)

UNION

-- union with any keys that don't have current active values nor pending values
SELECT v.VehicleId, v.Registration, i.IVHId, i.IVHIntId, i.TrackerNumber, k.KeyId, k.Name AS KeyName, k.Description AS KeyDescription, kc.IndexPos AS KeyIndex,
	   cat.CategoryId, cat.Name AS CategoryName, cat.Description AS CategoryDescription,
	   it.ReadCommandPrefix + com.CommandRoot + it.ReadCommandSuffix AS ReadCommandString,
	   it.WriteCommandPrefix + com.CommandRoot + it.WriteCommandSuffix AS WriteCommandString,
	   com.Description AS CommandDescription, it.IVHTypeId, it.Name AS IVHTypeName, it.Description AS IVHTypeDescription,
	   k.MinValue, k.MaxValue, k.MinDate, k.MaxDate,
	   NULL AS ActiveValue, NULL AS ActiveStartDate,
	   NULL AS PendingValue, NULL AS PendingStartDate,
	   NULL AS PendingStatus
FROM dbo.CFG_Key k
INNER JOIN dbo.CFG_KeyCommand kc ON k.KeyId = kc.KeyId
INNER JOIN dbo.CFG_Command com ON kc.CommandId = com.CommandId
INNER JOIN dbo.CFG_Category cat ON com.CategoryId = cat.CategoryId
INNER JOIN dbo.IVHType it ON com.IVHTypeId = it.IVHTypeId
INNER JOIN dbo.IVH i ON it.IVHTypeId = i.IVHTypeId
INNER JOIN dbo.Vehicle v ON i.IVHId = v.IVHId
WHERE v.VehicleId IN (SELECT Value FROM dbo.Split(@vids, ','))
  AND NOT EXISTS (SELECT 1
				  FROM CFG_History h
				  WHERE h.IVHIntId = i.IVHIntId
				    AND h.KeyId = k.KeyId)

ORDER BY Registration, CategoryId, KeyId

END


GO
