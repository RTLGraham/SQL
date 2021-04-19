SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_TemperatureStatus_Release]
(
	@userId UNIQUEIDENTIFIER,
	@vehicleId UNIQUEIDENTIFIER,
	@reason NVARCHAR(MAX)
)
AS
BEGIN

	INSERT INTO dbo.TemperatureStatus (
			VehicleId,
			Ack,
			AckReason,
			AckDateTime,
			AckUserId,
			AnalogData0,
			AnalogData1,
			AnalogData2,
			AnalogData3)
	SELECT	VehicleId,
			1, -- Released
			@reason, 
			GETUTCDATE(),
			@userid , 
			AnalogData0,
			AnalogData1,
			AnalogData2,
			AnalogData3
	FROM dbo.VehicleLatestEvent vle
	WHERE vle.VehicleId = @vehicleid
	
END

GO
