SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cu_MessageHistory_GetMessage]
(
	@MessageId int
)
AS
	SELECT
		mv.MessageId,
		mv.UserId,
		mv.VehicleId,
		m.MessageText,
		m.Lat,
		m.Long,
		[dbo].[GetAddressFromLongLat]( m.Lat, m.Long ) AS ReverseGeoCode,
		mv.MessageStatusHardwareId,
		mv.MessageStatusWetwareId,
		mv.TimeSent,
		mv.HasBeenDeleted
	FROM
		[dbo].[MessageVehicle] mv
		INNER JOIN [dbo].[MessageHistory] m ON mv.MessageId = m.MessageId
	WHERE
		mv.MessageId = @MessageId
		AND mv.Archived != 1 AND m.Archived != 1


GO
