SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[DeliveryNotification_ProcessDestinations] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ivhId UNIQUEIDENTIFIER,
			@IVHTypeId INT,
			@DriverID UNIQUEIDENTIFIER,
			@DriverIntId INT,
			@VehicleID UNIQUEIDENTIFIER,
			@VehicleIntId INT,
			@DestinationID VARCHAR(20) ,
			@CustomerID UNIQUEIDENTIFIER ,
			@GeofenceID UNIQUEIDENTIFIER,
			@GeofenceLatitude FLOAT,
			@GeofenceLongitude FLOAT,
			@GeofenceRadius INT,
			@TimeDestinationIDEntered SMALLDATETIME,
			@NotificationID BIGINT,
			@CommandID INT,
			@Command VARCHAR(1024),
			@TimeCommandCreated SMALLDATETIME,
			@TimeCommandExpires SMALLDATETIME,
			@deliveryNotificationType SMALLINT,
			@shiftId INT
	
	SET @TimeCommandCreated = GETUTCDATE()
	SET @TimeCommandExpires = DATEADD(HH,12,@TimeCommandCreated)

	-- line terminator
	DECLARE @crlf VARBINARY(2)
	SET @crlf = 0x0d0a

	-- Mark all Dest rows (cc=32) in EDC
	UPDATE dbo.EventDataCopy SET Archived = 1 WHERE CreationCodeId = 32
	
	-- Delete any rows with dst IN ('', '0') as these are from cancelled destinations
	DELETE FROM dbo.EventDataCopy
	WHERE CreationCodeId = 32 AND Archived = 1
	  AND EventDataString IN ('', '0')

	DECLARE EDCCursor CURSOR FAST_FORWARD READ_ONLY
	FOR 	
		SELECT  Result.DestinationID, Result.DriverId, Result.DriverIntId, Result.VehicleId, Result.VehicleIntId, Result.CustomerId, Result.GeofenceId, Result.GeofenceLatitude, Result.GeofenceLongitude,
				Result.GeofenceRadius, Result.TimeDestinationIDEntered, Result.IVHId, Result.IVHTypeId
		FROM	
		
			(SELECT dbo.TrimSiteId(edc.EventDataString) as DestinationID,
					dbo.GetDriverIdFromInt(edc.DriverIntID) AS DriverId, edc.DriverIntId, dbo.GetVehicleIdFromInt(edc.VehicleIntID) AS VehicleId, edc.VehicleIntId, dbo.GetCustomerIdFromInt(edc.CustomerIntId) AS CustomerId,
					g.GeoFenceID, g.CenterLat as GeofenceLatitude, g.CenterLon as GeofenceLongitude, g.Radius2 as GeofenceRadius,
					edc.EventDateTime as TimeDestinationIDEntered, i.ivhid, i.ivhtypeid, ROW_NUMBER() OVER(PARTITION BY edc.VehicleIntId ORDER BY edc.VehicleIntId, g.GeofenceId DESC) AS RowNum
			FROM dbo.EventDataCopy edc
			INNER JOIN dbo.Vehicle v ON edc.VehicleIntId = v.VehicleIntId
			INNER JOIN dbo.IVH i ON v.IVHId = i.IVHId
			-- Additional joins to limit to geofences matching the user/vehicle group
			INNER JOIN dbo.GroupDetail gdv ON gdv.EntityDataId = v.VehicleId
			INNER JOIN dbo.UserGroup ugv ON ugv.GroupId = gdv.GroupId

			INNER JOIN dbo.UserGroup ugg ON ugg.UserId = ugv.UserId
			INNER JOIN dbo.GroupDetail gdg ON gdg.GroupId = ugg.GroupId AND gdg.GroupTypeId = 4

			LEFT JOIN dbo.Geofence g on g.GeofenceId = gdg.EntityDataId AND dbo.TrimSiteId(edc.EventDataString) = g.SiteId -- 

			WHERE edc.creationcodeid = 32
			AND edc.EventDataName = 'DST'		
			AND edc.EventDataString <> ''
			AND edc.EventDataString IS NOT NULL
			AND edc.EventDataString <> 'No ID'
			AND (g.Archived = 0 or g.Archived IS NULL)
			) Result
			WHERE Result.RowNum = 1

	OPEN EDCCursor
	FETCH NEXT FROM EDCCursor INTO @DestinationID, @DriverID, @DriverIntId, @VehicleID, @VehicleIntId, @CustomerId, @GeofenceID, @GeofenceLatitude, @GeofenceLongitude,
		@GeofenceRadius, @TimeDestinationIDEntered, @IVHId, @IVHTypeId
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @IVHTypeId IN (5,8,9) OR @GeofenceID IS NOT NULL -- NULL geofences are ONLY sent to appropriate devices for attached device screen handling
		BEGIN
			SET @Command = '#ACTION,DELETE,CGEOF,ALL' + CAST(@crlf AS VARCHAR(2)) + dbo.BuildGeofenceCommandString(@GeofenceID,@DestinationID)

			--Identify any current unacknowledged / unreceived Delivery Notification commands and mark as Expired
			UPDATE dbo.VehicleCommand
			SET ExpiryDate = GETDATE()
			WHERE IVHId = @ivhId
			  AND CAST(Command AS VARCHAR(1024)) LIKE '#ACTION,DELETE,CGEOF,ALL%'
			  AND ExpiryDate > GETDATE()
			  AND (ReceivedDate IS NULL OR AcknowledgedDate IS NULL)	

			--Insertion of new Command for Destination ID Entered
			INSERT INTO VehicleCommand ([IVHId] ,[Command] ,[ExpiryDate] ,[LastOperation] ,[Archived])  
			VALUES (@IVHID, CAST(@Command AS BINARY(1024)), @TimeCommandExpires, @TimeCommandCreated, 0)

			SET @CommandID = SCOPE_IDENTITY()

			-- At this point we need to determine if vehicle or server monitored Delivery Notification is being used
			-- For vehicle monitored (1) we insert into DeliveryNotification and update VehicleLatestState
			-- For server monitored (2) we insert into shift header and detail (DeliveryNotification and VehicleLatestState are handled by the server side process later)
			-- This is only done if the GeofenceId is NOT NULL

			IF @GeofenceID IS NOT NULL
			BEGIN
            
				SELECT @deliveryNotificationType = Value 
				FROM dbo.CustomerPreference
				WHERE CustomerID = @CustomerID
				  AND NameID = 3014

				IF @deliveryNotificationType NOT IN (1,2) SET @deliveryNotificationType = 1 -- ensure default is set to Vehicle Monitored in case of any invalid entries in customer preference (e.g. 0)

				IF ISNULL(@deliveryNotificationType, 1) = 1 AND @IVHTypeId < 8 -- Vehicle Monitored Delivery Notification (default) for device types earlier than A9/A11
				BEGIN	

					INSERT INTO DeliveryNotification (DestinationID, DriverID, VehicleID, CustomerId, GeofenceID, GeofenceLatitude, GeofenceLongitude, GeofenceRadius, TimeDestinationIDEntered, CommandID, TimeCommandCreated, IsServerSide) 
					VALUES (@DestinationID, @DriverID, @VehicleID, @CustomerId, @GeofenceID, @GeofenceLatitude, @GeofenceLongitude, @GeofenceRadius, @TimeDestinationIDEntered, @CommandID, @TimeCommandCreated, 0)
					SET @NotificationID = SCOPE_IDENTITY()

				END ELSE -- Server Monitored Delivery Notification for A9/A11 and later
                BEGIN
 
 					INSERT INTO DeliveryNotification (DestinationID, DriverID, VehicleID, CustomerId, GeofenceID, GeofenceLatitude, GeofenceLongitude, GeofenceRadius, TimeDestinationIDEntered, CommandID, TimeCommandCreated, IsServerSide) 
					VALUES (@DestinationID, @DriverID, @VehicleID, @CustomerId, @GeofenceID, @GeofenceLatitude, @GeofenceLongitude, @GeofenceRadius, @TimeDestinationIDEntered, @CommandID, @TimeCommandCreated, 1)
					SET @NotificationID = SCOPE_IDENTITY()               

				END	

				--Update of VehicleLatestState with current Destination ID
				UPDATE VehicleLatestState SET CurrentDestination = NULL WHERE CurrentDestination = @DestinationID and VehicleID = @VehicleId 
				EXEC proc_WriteVehicleLatestState @StateTypeId=20, @Destination=@DestinationID, @VehicleId = @VehicleId, @NotificationID=@NotificationID
				UPDATE VehicleLatestState SET CurrentNotificationID = @NotificationID WHERE VehicleID = @VehicleId and CurrentDestination = @DestinationID

			END	
		END

		FETCH NEXT FROM EDCCursor INTO @DestinationID, @DriverID, @DriverIntId, @VehicleID, @VehicleIntId, @CustomerId, @GeofenceID, @GeofenceLatitude, @GeofenceLongitude,
			@GeofenceRadius, @TimeDestinationIDEntered, @IVHId, @IVHTypeId
	END
	CLOSE EDCCursor
	DEALLOCATE EDCCursor

	DELETE FROM EventDataCopy WHERE CreationCodeId = 32 AND Archived = 1

END

GO
