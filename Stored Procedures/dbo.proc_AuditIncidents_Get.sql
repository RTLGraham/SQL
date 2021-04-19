SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_AuditIncidents_Get] 
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT i.IncidentId, e.EventId, e.VehicleIntId, e.Lat, e.Long, e.Speed, i.ApiEventId
	FROM dbo.CAM_Incident i
		INNER JOIN dbo.Event e ON e.EventId = i.EventId
	WHERE e.Lat = 0 AND e.Long = 0
		AND i.EventDateTime BETWEEN '2016-03-04 00:00' AND GETDATE()

END

GO
