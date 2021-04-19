SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_GetDiseaseOutbreakList]
	@uid UNIQUEIDENTIFIER = NULL
AS

--DECLARE @uid UNIQUEIDENTIFIER
--SET @uid = N'C5560083-4361-4160-8D28-AC191A3AA1DA'

SELECT  do.DiseaseOutbreakId ,
        Name ,
        OutbreakStartDate ,
        RegisteredBy ,
        Description ,
        Infected ,
        AtRisk
FROM dbo.DiseaseOutbreak do
INNER JOIN 
	(SELECT do.DiseaseOutbreakId, COUNT(DISTINCT dog1.GeofenceId) AS Infected, COUNT(DISTINCT dog2.GeofenceId) AS AtRisk
	FROM dbo.DiseaseOutbreak do
	INNER JOIN dbo.DiseaseOutbreakGeofence dog1 ON do.DiseaseOutbreakId = dog1.DiseaseOutbreakId AND dog1.DiseaseOutbreakGeofenceTypeId = 1 AND dog1.Archived = 0
	INNER JOIN dbo.DiseaseOutbreakGeofence dog2 ON do.DiseaseOutbreakId = dog2.DiseaseOutbreakId AND dog2.DiseaseOutbreakGeofenceTypeId = 2 AND dog2.Archived = 0
	GROUP BY do.DiseaseOutbreakId) counts ON do.DiseaseOutbreakId = counts.DiseaseOutbreakId
WHERE do.RegisteredBy = @uid	
  AND do.Archived = 0
GO
