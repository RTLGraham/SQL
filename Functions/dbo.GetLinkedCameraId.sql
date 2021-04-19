SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- ====================================================================
-- Author:		Dmitrijs Jurins
-- Create date: 09/07/2013
-- Description:	Gets Linked Driver Uniqueidentifier from the VehicleDriver table
-- ====================================================================
CREATE FUNCTION [dbo].[GetLinkedCameraId] 
(
	@vehicleid UNIQUEIDENTIFIER
)
RETURNS UNIQUEIDENTIFIER
AS
BEGIN
	DECLARE @cameraid UNIQUEIDENTIFIER
	
	SET @cameraid = NULL
	
	SELECT TOP 1 @cameraid = CameraId
	FROM dbo.VehicleCamera
	WHERE VehicleId = @vehicleid
		AND Archived = 0
		AND EndDate IS NULL
	ORDER BY LastOperation DESC

	RETURN @cameraid
END


GO
