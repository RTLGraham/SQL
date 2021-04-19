SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[zz_remove_cuf_Vehicle_TAN_CheckOut]
(
	@userId UNIQUEIDENTIFIER,
	@vehicleId UNIQUEIDENTIFIER,
	@reason NVARCHAR(MAX),
	@expiry DATETIME
)
AS
BEGIN

	INSERT INTO dbo.TAN_EntityCheckOut (
			EntityId,
			CheckOutDateTime,
			CheckInDateTime,
			CheckOutUserId,
			CheckOutReason,
			AnalogData0,
			AnalogData1,
			AnalogData2,
			AnalogData3)
	SELECT	VehicleId,
			GETUTCDATE(),
			dbo.TZ_ToUtc(@expiry, DEFAULT, @userId),
			@userid,
			@reason, 
			AnalogData0,
			AnalogData1,
			AnalogData2,
			AnalogData3
	FROM dbo.VehicleLatestEvent vle
	WHERE vle.VehicleId = @vehicleid

END

GO
