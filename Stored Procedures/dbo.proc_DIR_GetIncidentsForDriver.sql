SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROC [dbo].[proc_DIR_GetIncidentsForDriver]
(
	@DriverIntId INT
)
AS

BEGIN

--DECLARE @DriverIntId INT
--SET @DriverIntId = 5900


SELECT i.IncidentId, i.IncidentDate, t.Name AS IncidentType
FROM dbo.Driver d
INNER JOIN dbo.DIR_Incident i ON i.DriverIntId = d.DriverIntId
INNER JOIN dbo.DIR_IncidentType t ON t.IncidentTypeId = i.IncidentTypeId
WHERE i.DriverIntId = @DriverIntId


End
GO
