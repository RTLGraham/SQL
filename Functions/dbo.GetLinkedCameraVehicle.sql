SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- ====================================================================
-- Author:		Dmitrijs Jurins
-- Create date: 09/07/2013
-- Description:	Gets Linked Driver Uniqueidentifier from the VehicleDriver table
-- ====================================================================
CREATE FUNCTION [dbo].[GetLinkedCameraVehicle] 
(
	@cameraSerial VARCHAR(50)
)
RETURNS UNIQUEIDENTIFIER
AS
BEGIN
	DECLARE @vehicleid UNIQUEIDENTIFIER
	
	SET @vehicleid = NULL
	
	SELECT TOP 1 @vehicleid = vc.VehicleId
	FROM dbo.Camera c
		INNER JOIN dbo.VehicleCamera vc ON c.CameraId = vc.CameraId
	WHERE vc.Archived = 0 AND c.Archived = 0
		AND vc.EndDate IS NULL
		AND c.Serial = @cameraSerial
	ORDER BY vc.LastOperation DESC

	RETURN @vehicleid
END


GO
