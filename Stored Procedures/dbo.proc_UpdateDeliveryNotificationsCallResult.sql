SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_UpdateDeliveryNotificationsCallResult]
(
	@TimeCallEnded smalldatetime,
	@CallDuration int,
	@CallAttempts int,
	@CallResult varchar(255),
	@NotificationID bigint
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @Status varchar(255)

	SELECT @Status = DeliveryNotificationStatus
	FROM DeliveryNotification
	WHERE NotificationID = @NotificationId

	IF (@Status IS NULL OR @Status != 'Delivery Succeeded')
	BEGIN
		--Update with VOIP call results
		UPDATE DeliveryNotification 
		SET TimeCallEnded = @TimeCallEnded, 
			CallDuration = @CallDuration, 
			CallAttempts = @CallAttempts, 
			CallResult = @CallResult,
			NotificationType = 'Voice',
			DeliveryNotificationStatus =
			CASE 
				WHEN (@CallResult = 'PlayedCompletely' OR @CallResult = 'PlayedPartially')
				THEN 'Delivery Succeeded'
				ELSE 'Delivery Failed'
			END,
			TimeCommandAcknowledged = c.AcknowledgedDate
		FROM dbo.VehicleCommand c
		WHERE c.CommandID = DeliveryNotification.CommandID 
			AND DeliveryNotification.NotificationID = @NotificationID

		UPDATE DeliveryNotification 
		SET TelephoneNumber = g.Recipients 
		FROM dbo.DeliveryNotification d
		INNER JOIN dbo.Geofence g on d.GeofenceId = g.GeoFenceId
		WHERE d.NotificationID = @NotificationID
	END
END





GO
