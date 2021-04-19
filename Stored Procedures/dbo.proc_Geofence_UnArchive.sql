SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_Geofence_UnArchive]
(
	@geoId UNIQUEIDENTIFIER
)
AS
BEGIN
	UPDATE dbo.Geofence
	SET	
		Archived = 0
	WHERE 
		GeofenceId = @geoId

END



GO
