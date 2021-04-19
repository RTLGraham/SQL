SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_WriteVehicle]
	@vid uniqueidentifier = NULL, @vintid INT = NULL OUTPUT, @ivhid uniqueidentifier, @customerid UNIQUEIDENTIFIER, @reg varchar(20), @mkemdl varchar(100) = NULL, @bdymfr varchar(50) = NULL,
	@bdytyp varchar(50) = NULL, @chsnum varchar(50) = NULL, @fltnum varchar(20) = NULL, @clr varchar(6) = NULL, @iid int = NULL, @identifier varchar(200) = NULL,
	@notes varchar(8000) = NULL
AS

IF @vid IS NULL
BEGIN
	SET @vid = NEWID()
	INSERT INTO Vehicle 	(VehicleId, IVHId, Registration, MakeModel, BodyManufacturer, BodyType, ChassisNumber, FleetNumber,
				DisplayColour, IconId, Identifier, Notes)
	VALUES		(@vid, @ivhid, @reg, @mkemdl, @bdymfr, @bdytyp, @chsnum, @fltnum, @clr, @iid, @identifier, @notes)
	SET @vintid = SCOPE_IDENTITY()
	-- New insert a VehicleLatestEvent row for every vehicle
	INSERT INTO VehicleLatestEvent (VehicleId) VALUES (@vid)

	INSERT INTO CustomerVehicle (CustomerId, VehicleId, StartDate, EndDate)
	VALUES			(@customerid, @vid, GETDATE(), NULL)
END
ELSE
BEGIN
	-- check if vehicleid being passed already exists or if a new record needs to be created
	DECLARE @existingvid uniqueidentifier
	SELECT @existingvid = VehicleId, @vintid = VehicleIntId FROM Vehicle WHERE VehicleId = @vid
	IF @existingvid IS NULL
	BEGIN
		-- if a new id then write entry into Vehicle table
		INSERT INTO Vehicle 	(VehicleId, IVHId, Registration, MakeModel, BodyManufacturer, BodyType, ChassisNumber, FleetNumber,
					DisplayColour, IconId, Notes)
		VALUES		(@vid, @ivhid, @reg, @mkemdl, @bdymfr, @bdytyp, @chsnum, @fltnum, @clr, @iid, @notes)
		SET @vintid = SCOPE_IDENTITY()

		-- New insert a VehicleLatestEvent row for every vehicle
		INSERT INTO VehicleLatestEvent (VehicleId) VALUES (@vid)
		
		INSERT INTO CustomerVehicle (CustomerId, VehicleId, StartDate, EndDate)
		VALUES			(@customerid, @vid, GETDATE(), NULL)

	END
	ELSE
	BEGIN
		-- if id already exists then update existing entry
		UPDATE Vehicle SET	IVHId = @ivhid, Registration = @reg, MakeModel = @mkemdl, BodyManufacturer = @bdymfr,
					BodyType = @bdytyp, ChassisNumber = @chsnum, FleetNumber = @fltnum,
					DisplayColour = @clr, IconId = @iid, LastOperation = GETDATE(), Identifier = @identifier,
					Notes = @notes
		WHERE VehicleId = @vid
	END

--  This section no longer required in SkyNet
--	DECLARE @depvid int
--	DECLARE @now datetime
--
--	-- store the time so that enddate of old depotsVehicle entry and startdate of new will correspond
--	SET @now = GETDATE()
--
--	-- find out if this CustomerIntId is already in use with this vehicle
--	SELECT @depvid = DepotsVehicleId FROM Vehicle LEFT JOIN DepotsVehicle ON Vehicle.VehicleId = DepotsVehicle.VehicleId
--	WHERE Vehicle.VehicleId = @vid AND Vehicle.Archived = 0 AND
--	GETDATE() BETWEEN ISNULL(StartDate, GETDATE()) AND ISNULL(EndDate, GETDATE()) AND CustomerIntId = @depid
--
--	-- if not, find out what the old entry in the depotsVehicle table was and end it then create a new entry for the new depot starting from now
--	IF @depvid IS NULL
--	BEGIN
--		SELECT @depvid = DepotsVehicleId FROM Vehicle LEFT JOIN DepotsVehicle ON Vehicle.VehicleId = DepotsVehicle.VehicleId
--		WHERE Vehicle.VehicleId = @vid AND Vehicle.Archived = 0 AND
--		GETDATE() BETWEEN ISNULL(StartDate, GETDATE()) AND ISNULL(EndDate, GETDATE())
--
--		UPDATE DepotsVehicle SET EndDate = @now WHERE DepotsVehicleId = @depvid
--
--		INSERT INTO DepotsVehicle 	(CustomerIntId, VehicleId, Registration, FleetNumber, StartDate, EndDate)
--		VALUES			(@depid, @vid, @reg, @fltnum, @now, NULL)
--	END

END

GO
