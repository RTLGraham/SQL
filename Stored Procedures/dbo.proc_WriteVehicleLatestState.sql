SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_WriteVehicleLatestState]
	@StateTypeId SMALLINT, @Destination VARCHAR(20), @VehicleId UNIQUEIDENTIFIER, @NotificationID BIGINT
AS

DECLARE @VehicleIdExists UNIQUEIDENTIFIER
SELECT TOP 1 @VehicleIdExists = VehicleId from VehiclesLatestState WHERE VehicleId = @VehicleId

IF @VehicleIdExists is not NULL
	UPDATE VehiclesLatestState
	SET StateTypeId = @StateTypeId, 
		CurrentDestination = @Destination, 
		CurrentNotificationID = @NotificationID,
		LastOperation = GetDate()
	WHERE VehicleId = @VehicleId
ELSE
	INSERT INTO VehiclesLatestState (VehicleId, StateTypeId, CurrentDestination, CurrentNotificationID) 
	VALUES (@VehicleId, @StateTypeId, @Destination, @NotificationID)

GO
