SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_GetDiseaseOutbreakSingle]
	@diseaseoutbreakid INT,
	@uid UNIQUEIDENTIFIER = NULL
AS

--DECLARE @diseaseoutbreakid INT, @uid UNIQUEIDENTIFIER
--SET @diseaseoutbreakid = 2
--SET @uid = N'C5560083-4361-4160-8D28-AC191A3AA1DA'

SELECT  do.DiseaseOutbreakId,
        Name,
        OutbreakStartDate,
        RegisteredBy,
        Description,
        DiseaseOutbreakGeofenceId,
        GeofenceId,
        DiseaseOutbreakGeofenceTypeId,
        AnnotationText,
        DiseaseOutbreakObjectId,
        ObjectText,
        Lat,
        Long,
        Angle
FROM dbo.DiseaseOutbreak do
LEFT JOIN dbo.DiseaseOutbreakGeofence dog ON do.DiseaseOutbreakId = dog.DiseaseOutbreakId AND dog.Archived = 0
LEFT JOIN dbo.DiseaseOutbreakObject doo ON dog.DiseaseOutbreakId = doo.DiseaseOutbreakId AND doo.Archived = 0
WHERE do.DiseaseOutbreakId = @diseaseoutbreakid

GO
