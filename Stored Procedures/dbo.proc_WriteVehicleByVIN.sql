SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_WriteVehicleByVIN]
	@trackerId VARCHAR(50),
	@vin VARCHAR(17),
	@eventdt DATETIME
AS
	DECLARE @ivhid UNIQUEIDENTIFIER,
			@customerId UNIQUEIDENTIFIER,
			@vehicleId UNIQUEIDENTIFIER,
			@vintid INT 
	
	
	DECLARE @defaultCustomerId UNIQUEIDENTIFIER

	/********************************************************************/
	/* Identify the tracker	and the customer from IVH stock (if known)	*/
	/********************************************************************/
	SELECT TOP 1 @ivhid = i.IVHId, @customerId = c.CustomerId
	FROM dbo.IVH i
		LEFT JOIN dbo.CustomerIVHStock c ON c.IVHId = i.IVHId AND (c.EndDate IS NULL OR c.EndDate > GETDATE()) AND c.Archived = 0
	WHERE i.TrackerNumber = @trackerId 
		AND i.Archived = 0
	ORDER BY c.LastOperation DESC, i.LastOperation DESC

	IF @ivhid IS NULL
	BEGIN
		-- New tracker, let's create it
		SET @ivhid = NEWID()
		INSERT INTO dbo.IVH (IVHId, TrackerNumber, Manufacturer, Model, LastOperation, Archived, IVHTypeId)
		VALUES (@ivhid, @trackerid, 'CalAmp', 'LMU3030', GETDATE(), 0, 6)

		-- Obtain the default customer id
		SELECT @defaultCustomerId = CustomerId 
		FROM dbo.Customer 
		WHERE CustomerIntId = 1 -- Default Customer

		--Write to the default customer ivh stock
		INSERT INTO dbo.CustomerIVHStock(IVHId, CustomerId, StartDate, EndDate, LastOperation, Archived)
		VALUES (@ivhid, @defaultCustomerId, GETDATE(), NULL, GETDATE(), 0)
		
		--Write vehicle
		EXECUTE [dbo].[proc_WriteVehicle] @vehicleId, @vintid OUTPUT, @ivhid, @defaultCustomerId, @vin, NULL, NULL, NULL, @vin, NULL, NULL, NULL, NULL, NULL
	END
	ELSE BEGIN
		/********************************************************************/
		/*	- if not identified - use the default customer					*/
		/*	- if identified - see if the current vehicle is assigned to the	*/
		/*	'default' customer IF it is - move it to the found customer		*/
		/********************************************************************/
		IF @customerId IS NULL
		BEGIN
			-- Obtain the default customer id
			SELECT @defaultCustomerId = CustomerId 
			FROM dbo.Customer 
			WHERE CustomerIntId = 1 -- Default Customer

			-- Tracker was not added to the customer stock
			SET @customerId = @defaultCustomerId
		END

		DECLARE @found_vehicleId UNIQUEIDENTIFIER,
				@found_customerId UNIQUEIDENTIFIER,
				@found_ivhId UNIQUEIDENTIFIER,
				@current_customerId UNIQUEIDENTIFIER

		/********************************************************************/
		/* Which vehice is the tracker currently assigned to?				*/
		/********************************************************************/
		SELECT TOP 1 @vehicleId = v.VehicleId, @current_customerId = cv.CustomerId
		FROM dbo.Vehicle v 
			INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
		WHERE v.IVHId = @ivhid AND v.Archived = 0 AND cv.Archived = 0 AND (cv.EndDate IS NULL OR cv.EndDate > GETDATE())
		ORDER BY v.LastOperation DESC
		
		IF @vehicleId IS NULL
		BEGIN
			EXECUTE [dbo].[proc_WriteVehicle] @vehicleId, @vintid OUTPUT, @ivhid, @customerid, @vin, NULL, NULL, NULL, @vin, NULL, NULL, NULL, NULL, NULL
		END

		/********************************************************************/
		/* Which vehice should the tracker be assigned to?					*/
		/********************************************************************/
		SELECT TOP 1 @found_vehicleId = v.VehicleId, @found_customerId = cv.CustomerId, @found_ivhId = v.IVHId
		FROM dbo.Vehicle v 
			INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
		WHERE v.ChassisNumber = @vin AND v.Archived = 0 AND cv.Archived = 0 AND (cv.EndDate IS NULL OR cv.EndDate > GETDATE())
		ORDER BY v.LastOperation DESC
		
		IF @found_vehicleId IS NOT NULL AND @found_vehicleId != @vehicleId
		BEGIN
			-- Detach tracker from the current vehicle
			UPDATE dbo.Vehicle 
			SET IVHId = NULL
			WHERE VehicleId = @vehicleId

			-- Attach tracker to the found vehicle (this automatically detaches the current tracker)
			UPDATE dbo.Vehicle 
			SET IVHId = @ivhid
			WHERE VehicleId = @found_vehicleId
		END
		ELSE IF @found_vehicleId IS NULL
		BEGIN
			-- Update ChassisNumber of the current vehicle
			UPDATE dbo.Vehicle 
			SET ChassisNumber = @vin
			WHERE VehicleId = @vehicleId
			-- Ensure the current vehicle is in the correct customer
			IF @customerId != @current_customerId AND @customerId != @defaultCustomerId
			BEGIN
				-- vehicle belongs to a customer which is different to IVH stock record, and IVH stock record is not the default customer
				UPDATE dbo.CustomerVehicle SET EndDate = GETDATE(), Archived = 1 WHERE VehicleId = @vehicleId AND CustomerId = @current_customerId
				-- assign the vehicle to the correct customer record
				INSERT INTO dbo.CustomerVehicle (VehicleId, CustomerId, StartDate, EndDate, LastOperation, Archived)
				VALUES ( @vehicleId, @customerId, GETDATE(), NULL, GETDATE(), 0)
			END
		END
		--IF @found_vehicleId IS NOT NULL AND @found_vehicleId = @vehicleId
		--BEGIN
		--	PRINT 'If found vehicle has this tracker attached - do nothing'
		--END
	END
	
	/********************************************************************************/
	/* Check and create (if necessary) the ' New Dongles' group						*/
	/********************************************************************************/
	DECLARE @groupName NVARCHAR(MAX),
			@groupId UNIQUEIDENTIFIER

	SET @groupName = ' New Dongles'

	SELECT TOP 1 @groupId = g.GroupId
	FROM dbo.[Group] g
		INNER JOIN dbo.UserGroup ug ON ug.GroupId = g.GroupId
		INNER JOIN dbo.[User] u ON u.UserID = ug.UserId
		INNER JOIN dbo.Customer c ON c.CustomerId = u.CustomerID
	WHERE c.CustomerId = @customerId AND g.IsParameter = 0 AND g.Archived = 0
		AND g.GroupName = @groupName
	ORDER BY g.LastModified ASC
    
	IF @groupId IS NULL
	BEGIN
		-- Create the group
		SET @groupId = NEWID()
		INSERT INTO dbo.[Group](GroupId, GroupName, GroupTypeId, IsParameter, Archived, LastModified)
		VALUES  (@groupId, @groupName, 1, 0, 0, GETDATE())

		-- Let admins (with rights to manage groups) see it
		INSERT INTO dbo.UserGroup(UserId, GroupId, Archived, LastModified)
		SELECT DISTINCT u.UserID, @groupId, 0, GETDATE()
		FROM dbo.Customer c
			INNER JOIN dbo.[User] u ON u.CustomerID = c.CustomerId
			INNER JOIN dbo.UserPreference up ON up.UserID = u.UserID
			INNER JOIN dbo.DictionaryName dn ON dn.NameID = up.NameID
		WHERE c.CustomerId = @customerId 
			AND u.Archived = 0 AND up.Value = 1 AND up.Archived = 0 
			AND dn.NameID IN (710, 1013)
	END
	
	/********************************************************************************/
	/* Check if the vehicle is already in ANY group, if not - add to the @groupId	*/
	/********************************************************************************/
	DECLARE @count INT

	SELECT @count = COUNT(*)
	FROM dbo.Customer c 
		INNER JOIN dbo.CustomerVehicle cv ON cv.CustomerId = c.CustomerId
		INNER JOIN dbo.Vehicle v ON v.VehicleId = cv.VehicleId
		INNER JOIN dbo.GroupDetail gd ON gd.EntityDataId = v.VehicleId
		INNER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId
	WHERE c.CustomerId = @customerId AND g.IsParameter = 0 AND g.Archived = 0
		AND v.VehicleId = @vehicleId
	
	IF ISNULL(@count, 0) = 0
	BEGIN
		INSERT INTO dbo.GroupDetail(GroupId, GroupTypeId, EntityDataId)
		VALUES (@groupId, 1, @vehicleId)
	END

GO
