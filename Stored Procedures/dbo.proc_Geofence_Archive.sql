SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_Geofence_Archive]
(
	@geoId UNIQUEIDENTIFIER
)
AS
BEGIN
	UPDATE dbo.Geofence
	SET	
		Archived = 1
	WHERE 
		GeofenceId = @geoId

END


GO
