SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cu_MessageVehicle_CheckAllMessagesForVehicle]
(
	@vehicleId UNIQUEIDENTIFIER,
	@since DATETIME
)
AS
BEGIN
	DECLARE @messageId INT
	
	DECLARE msg_cur CURSOR FAST_FORWARD READ_ONLY FOR
		SELECT MessageId
		FROM dbo.MessageVehicle m
		INNER JOIN dbo.VehicleCommand c ON m.CommandId = c.CommandId
		WHERE VehicleId = @vehicleId
			AND c.AcknowledgedDate IS NOT NULL 
			AND m.TimeSent >= @since
	
	OPEN msg_cur
	FETCH NEXT FROM msg_cur INTO @messageId
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXECUTE [dbo].[cu_MessageVehicle_CheckMessage] @messageId
		FETCH NEXT FROM msg_cur INTO @messageId
	END
	CLOSE msg_cur
	DEALLOCATE msg_cur
END

GO
