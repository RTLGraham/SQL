SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_dest_PeriodicProcess] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @CustomerIntId int
	DECLARE @ivhId uniqueidentifier
	Declare @DriverIntID int
	Declare @VehicleIntID INT
	DECLARE @VehicleId UNIQUEIDENTIFIER
	Declare @DestinationID varchar(20)
	Declare @CustomerID uniqueidentifier
	Declare @GeofenceID uniqueidentifier
	Declare @GeofenceLatitude float
	Declare @GeofenceLongitude float
	Declare @GeofenceRadius int
	Declare @TimeDestinationIDEntered smalldatetime
	Declare @NotificationID bigint
	Declare @CommandID int
	Declare @Command varchar(1024)
	Declare @TimeCommandCreated smalldatetime
	Declare @TimeCommandExpires smalldatetime
	
	SET @TimeCommandCreated = getutcdate()
	SET @TimeCommandExpires = DateAdd(HH,12,@TimeCommandCreated)

	-- line terminator
	DECLARE @crlf varbinary(2)
	SET @crlf = 0x0d0a

	-- Mark all Dest rows (cc=32) in EDC
	UPDATE EventDataCopy SET Archived = 1 WHERE CreationCodeId = 32
	
	-- delete any rows with dst='' as these are from canceled destinations
	DELETE FROM EventDataCopy
		WHERE CreationCodeId = 32 AND Archived = 1
		AND EventDataString=''

	-- delete where destination is an unknown one
	DELETE FROM EventDataCopy
		WHERE CreationCodeId = 32 AND Archived = 1
		AND dbo.GetGeofenceIdFromCustomerDestination(EventDataString,CustomerIntId) is NULL

--Delivery Notifications Population Stage 1 Occurs Here!
	DECLARE EDCCursor CURSOR FAST_FORWARD READ_ONLY
	FOR 
		select dbo.DeliveryNS_TrimID(edc.EventDataString) as DestinationID,
		edc.DriverIntID, edc.VehicleIntID, v.VehicleId, edc.CustomerIntId,
		ga.GeoFenceID, ga.lat as GeofenceLatitude, ga.long as GeofenceLongitude, ga.Radius as GeofenceRadius,
		edc.EventDateTime as TimeDestinationIDEntered,v.IVHID
		from EventDataCopy edc
		INNER JOIN dbo.Vehicle v ON edc.VehicleIntId = v.VehicleIntId
		left join (SELECT  gf.GeoFenceId, gf.Lat, gf.Long, gf.Radius, gf.DestinationID, cl.CustomerID, gf.Archived, gf.Flags
			FROM GeoFences gf
			INNER JOIN AddressesGeofences ag ON gf.GeoFenceId = ag.GeofenceId 
			INNER JOIN Addresses a ON a.AddressId = ag.AddressId 
			INNER JOIN LocationsAddresses la ON ag.AddressId = la.AddressId 
			INNER JOIN CustomerLocations cl ON la.LocationId = cl.LocationId) ga on edc.EventDataString = ga.DestinationID and d.CustomerID = ga.CustomerID 
		--left join GeofenceAddresses ga on edc.EventDataString = ga.DestinationID and d.CustomerID = ga.CustomerID 
		where e.creationcodeid = 32
		and edc.EventDataName = 'DST'		
		and edc.EventDataString <> ''
		and edc.EventDataString is not null
		and edc.EventDataString <> 'No ID'
		and (ga.Archived = 0 or ga.Archived is null)
		and (ga.Flags = 2 or ga.Flags is null)
		and edc.Archived = 1
	OPEN EDCCursor
	FETCH NEXT FROM EDCCursor INTO @DestinationID, @DriverIntID, @VehicleIntID, @VehicleId, @CustomerIntId, @GeofenceID, @GeofenceLatitude, @GeofenceLongitude,
		@GeofenceRadius, @TimeDestinationIDEntered,@IVHID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @Command = '#ACTION,DELETE,CGEOF,ALL' + CAST(@crlf AS varchar(2)) + dbo.BuildGeofenceCommandtring(@GeofenceID,@DestinationID)

		--Insertion of new Command for Destination ID Entered
		INSERT INTO Command ([IVHId] ,[Command] ,[ExpiryDate] ,[LastOperation] ,[Archived])  
		Values( @IVHID, CAST(@Command AS binary(1024)), @TimeCommandExpires, @TimeCommandCreated, 0)

		SET @CommandID = SCOPE_IDENTITY()

		Insert into DeliveryNotification (DestinationID, DriverID, VehicleID, CustomerId, GeofenceID, GeofenceLatitude, GeofenceLongitude,
		GeofenceRadius, TimeDestinationIDEntered, CommandID, TimeCommandCreated) 
		Values (@DestinationID, dbo.GetDriverIdFromInt(@DriverIntID), @VehicleID, dbo.GetCustomerIdFromInt(@CustomerIntId), @GeofenceID, @GeofenceLatitude, @GeofenceLongitude,
		@GeofenceRadius, @TimeDestinationIDEntered, @CommandID, @TimeCommandCreated)

		SET @NotificationID = SCOPE_IDENTITY()

		--Update of VehicleLatestState with current Destination and Notification ID
		EXEC proc_WriteVehicleLatestState @StateTypeId=20, @CurrentDestination=@DestinationID, @VehicleId=@VehicleId, @NotificationID = @NotificationID

	FETCH NEXT FROM EDCCursor INTO @DestinationID, @DriverIntID, @VehicleIntId, @VehicleID, @CustomerIntId, @GeofenceID, @GeofenceLatitude, @GeofenceLongitude,
		@GeofenceRadius, @TimeDestinationIDEntered,@IVHID
	END
	CLOSE EDCCursor
	DEALLOCATE EDCCursor
--End Delivery Notifications Stage 1

	DELETE FROM EventDataCopy WHERE CreationCodeId = 32 AND Archived = 1

-- GKP: If this last section is still required it can be uncommented and updated for new structure
--	-- Repeat for broken dst rows (cc=0)
--	UPDATE EventDataCopy SET Archived = 1 WHERE CreationCodeId = 0
--	
--	-- delete any rows with dst='' as these are from canceled destinations
--	DELETE FROM EventDataCopy WHERE CreationCodeId = 0 AND Archived = 1 AND EventDataString=''
--
--	-- delete where dst is an unknown one
--	DELETE FROM EventDataCopy
--		FROM EventDataCopy
--		INNER JOIN Event ON Event.EventId = EventDataCopy.EventId AND Event.CustomerIntId = EventDataCopy.CustomerIntId
--		WHERE EventDataCopy.CreationCodeId = 0 AND EventDataCopy.Archived = 1
--		AND dbo.GetGeofenceIdFromCustomerDestination(EventDataString,dbo.GetCustomerIdFromIVH(Event.ivhId)) is NULL
--
--	-- build Command for all remaining destinations	
--	INSERT INTO [Fleetwise21st].[dbo].[Command]  
--		([IVHId] ,[Command] ,[ExpiryDate] ,[LastOperation] ,[Archived])  
--		SELECT Event.ivhId, CAST('#ACTION,DELETE,CGEOF,ALL' + CAST(@crlf AS varchar(2)) + dbo.BuildGeofenceCommandtring(dbo.GetGeofenceIdFromCustomerDestination(EventDataString,dbo.GetCustomerIdFromIVH(Event.ivhId)),EventDataString) AS binary(1024)), DateAdd(Hh, 12, GetDate()), GetDate(), 0
--		FROM EventDataCopy
--		INNER JOIN Event ON Event.EventId = EventDataCopy.EventId AND Event.CustomerIntId = EventDataCopy.CustomerIntId
--		WHERE EventDataCopy.CreationCodeId = 0 AND EventDataCopy.Archived = 1
--
--	-- Update the VehicleLatestState table with the current dst ID
--	-- I suspect that there is a nice SQL way to do this rather than using a cursor.
--	DECLARE EDCCursor CURSOR FAST_FORWARD READ_ONLY
--	FOR 
--		SELECT Event.ivhId, EventDataCopy.EventDataString
--		FROM EventDataCopy
--		INNER JOIN Event ON Event.EventId = EventDataCopy.EventId AND Event.CustomerIntId = EventDataCopy.CustomerIntId
--		WHERE EventDataCopy.CreationCodeId = 30 AND EventDataCopy.Archived = 1
--	OPEN EDCCursor
--	FETCH NEXT FROM EDCCursor INTO @ivhId, @destinationId
--	WHILE @@FETCH_STATUS = 0
--	BEGIN
--		EXEC proc_WriteVehicleLatestState @StateTypeId=20, @CurrentDestination=@destinationId, @VehicleId=@ivhId
--		FETCH NEXT FROM EDCCursor INTO @ivhId, @destinationId
--	END
--	CLOSE EDCCursor
--	DEALLOCATE EDCCursor
--
--	DELETE FROM EventDataCopy WHERE CreationCodeId = 0 AND Archived = 1
END

GO
