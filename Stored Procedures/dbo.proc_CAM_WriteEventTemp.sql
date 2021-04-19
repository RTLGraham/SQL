SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE PROC [dbo].[proc_CAM_WriteEventTemp]
	@vid UNIQUEIDENTIFIER, @driverid varchar(32), 
	@ccid smallint, @long float, @lat float, @heading smallint, @speed smallint,
	@odogps int, @odotrip INT,
	@eventdt DATETIME,
	@customerintid int OUTPUT, @vintid INT OUTPUT, @dintid INT OUTPUT, @eid bigint=NULL OUTPUT

AS

DECLARE @ivhid uniqueidentifier, @did uniqueidentifier, @customerid UNIQUEIDENTIFIER
DECLARE @tempvid uniqueidentifier, @tempattvid uniqueidentifier, @tempccid SMALLINT, @tempdt DATETIME, @prevlat FLOAT, @prevlon FLOAT

DECLARE @usesgf bit
declare @sdateinthepast datetime
declare @edateinthefuture datetime
DECLARE @updatelatestdid bit
set @sdateinthepast = '1900-01-01 00:00'
set @edateinthefuture = '2100-01-01 00:00'
set @updatelatestdid = 1

-- get vehicle and customer details
SELECT @vintid = Vehicle.VehicleIntId, @ivhid = Vehicle.IVHId, @customerid = Customer.CustomerId, @customerintid = Customer.CustomerIntId
FROM Vehicle
	INNER JOIN CustomerVehicle ON Vehicle.VehicleId = CustomerVehicle.VehicleId
	INNER JOIN Customer ON Customer.CustomerId = CustomerVehicle.CustomerId
WHERE Vehicle.VehicleId = @vid
	AND Vehicle.Archived = 0 AND dbo.CustomerVehicle.Archived = 0 
	AND GETDATE() >= ISNULL(StartDate, @sdateinthepast) AND EndDate IS NULL

IF @customerintid IS NULL
BEGIN
	SET @customerintid = 1
	SET @customerid = dbo.GetCustomerIdFromInt(@customerintid)
END

SET @driverid = 'No ID'

--Check for the linked driver
SET @did = dbo.GetLinkedDriverId(@vid)

IF @did IS NULL	AND @ivhid IS NOT NULL -- No linked driver and Vehicle has an attached unit so try tacho lookup	
BEGIN
	SET @did = dbo.GetDriverIdFromInt(dbo.GetDriverIdFromEvent_ITcamera(@vintid, @eventdt))
END	

IF @did IS NULL -- did is still null so use 'No ID' driver
BEGIN
	SET @did = dbo.GetDriverIdFromNumberAndCustomer(@driverid, @customerid)
END
ELSE BEGIN
	--Update the VLE and set the last known driver
	SET @updatelatestdid = 1
END

IF @did IS NOT NULL
	SET @dintid = dbo.GetDriverIntFromId(@did)
ELSE  -- Driver not found so create one (should never reach this step as will be using 'No ID' driver)
	BEGIN
		SET @did = NEWID()
		EXEC proc_WriteDriver @did, @dintid OUTPUT, @customerid, @driverid, 'UNKNOWN'
	END

-- Write event 
-- Determine if a gps point has arrived for the vehicle within 60 minutes of a Key Off, and if so discard it unless it is a key On or a Video Creation Code
SELECT @tempdt = EventDateTime, @tempccid = CreationCodeId, @prevlat = Lat, @prevlon = Long
FROM dbo.VehicleLatestEventTemp
WHERE VehicleId = @vid

IF @tempdt IS NULL
SELECT @tempdt = EventDateTime, @tempccid = CreationCodeId, @prevlat = Lat, @prevlon = Long
FROM dbo.VehicleLatestEvent
WHERE VehicleId = @vid

IF @tempdt IS NULL OR DATEDIFF(mi, @tempdt, @eventdt) > 60 OR @tempccid != 5 OR @ccid IN (4, 5, 77, 78, 55, 56, 436, 437, 438, 455, 456, 457, 458)
BEGIN
	-- If this is a key on and the lat/long are zero, use the last known lat/long instead
	IF @ccid = 4 AND (@lat = 0 OR @long = 0)
	BEGIN
		SET @lat = @prevlat
		SET @long = @prevlon
	END	
	EXEC proc_WriteEventNewTemp 	@eid=@eid OUTPUT, @vintid = @vintid, @dintid = @dintid,
					@ccid = @ccid, @long = @long, @lat = @lat, @heading = @heading,
					@speed = @speed, @odogps = @odogps, @odoroadspeed = @odotrip, @ododash = @odogps, 
					@eventdt = @eventdt, @dio = NULL, 
					@customerintid = @customerintid,
					@analog0 = NULL, @analog1 = NULL, @analog2 = NULL, @analog3 = NULL, @analog4 = NULL, @analog5 = NULL,
					@sequencenumber = NULL,
					@evtstring = NULL, @evtdname = NULL,
					@altitude = NULL,
					@gpssatellitecount = NULL,
					@gprssignalstrength = NULL,
					@systemstatus = NULL,
					@batterychargelevel = NULL,
					@externalinputvoltage = NULL,
					@maxspeed = NULL 
END

-- This driver update code has been moved from above to below proc_WriteEventNewtemp
-- so that original driver is still in vehiclelatestEvent for driver check processing
-- of DriverlatestEvent within proc_WriteEventNewtemp
IF (@vid IS NOT NULL) AND (@dintid IS NOT NULL) AND (@updatelatestdid = 1)
BEGIN
	SET @did = dbo.GetDriverIdFromInt(@dintid)
	EXEC proc_WriteLatestDriver @did, @vid
END

SELECT @eid AS EventId




GO
