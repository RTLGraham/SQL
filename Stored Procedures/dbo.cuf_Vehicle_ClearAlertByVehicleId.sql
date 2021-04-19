SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_ClearAlertByVehicleId]
(
	@vehicleId UNIQUEIDENTIFIER
)
AS
BEGIN
	UPDATE dbo.VehicleLatestEvent
	SET AnalogIoAlertTypeId = NULL
	WHERE VehicleId = @vehicleId
END


GO
