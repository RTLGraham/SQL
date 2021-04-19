SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE PROC [dbo].[proc_WriteEventNewNonIdTemp]
	@trackerid varchar(50), @driverid varchar(32), 
	@ccid smallint, @long float, @lat float, @heading smallint, @speed smallint,
	@odogps int, @odoroadspeed int, @ododash int,
	@eventdt datetime, @dio tinyint, 
	@analog0 smallint, @analog1 smallint, @analog2 smallint, @analog3 smallint,
	@analog4 smallint, @analog5 smallint, 
	@sequencenumber int,
	@evtstring varchar(1024) = NULL, @evtdname varchar(30) = NULL,
	@customerintid int OUTPUT, @vid UNIQUEIDENTIFIER OUTPUT, @eid bigint=NULL OUTPUT,
	@altitude SMALLINT = NULL,
	@gpssatellitecount TINYINT = NULL,
	@gprssignalstrength TINYINT = NULL,
	@systemstatus TINYINT = NULL,
	@batterychargelevel TINYINT = NULL,
	@externalinputvoltage TINYINT = NULL,
	@maxspeed TINYINT = NULL,
	@tripdistance INT = NULL,
	@tachostatus TINYINT = NULL,
	@canstatus TINYINT = NULL,
	@fuelLevel TINYINT = NULL,
	@hardwareStatus TINYINT = NULL,
	@ADBlueLevel TINYINT = NULL,
	@bitmask INT = NULL	
AS

DECLARE @ivhid uniqueidentifier, @did uniqueidentifier, @customerid UNIQUEIDENTIFIER
DECLARE @vintid INT, @ivhintid INT, @dintid INT
DECLARE @tempvid uniqueidentifier, @tempattvid uniqueidentifier, @tempccid smallint

DECLARE @usesgf bit
declare @sdateinthepast datetime
declare @edateinthefuture datetime
DECLARE @updatelatestdid bit
set @sdateinthepast = '1900-01-01 00:00'
set @edateinthefuture = '2100-01-01 00:00'
set @updatelatestdid = 1

-- get ivh, vehicle and customer details
SELECT @ivhid = IVH.IVHId, @ivhintid = IVH.IVHIntId, @vid = Vehicle.VehicleId, @vintid = Vehicle.VehicleIntId, @customerid = Customer.CustomerId, @customerintid = Customer.CustomerIntId
FROM IVH 
	INNER JOIN Vehicle ON IVH.IVHId = Vehicle.IVHId
	INNER JOIN CustomerVehicle ON Vehicle.VehicleId = CustomerVehicle.VehicleId
	INNER JOIN Customer ON Customer.CustomerId = CustomerVehicle.CustomerId
WHERE TrackerNumber = @trackerid 
	AND IVH.Archived = 0 AND Vehicle.Archived = 0 AND dbo.CustomerVehicle.Archived = 0 AND (IVH.IsTag = 0 OR IVH.IsTag IS NULL)
--	AND (GETDATE() BETWEEN ISNULL(StartDate, @sdateinthepast) AND ISNULL(EndDate, @edateinthefuture))
	AND GETDATE() >= ISNULL(StartDate, @sdateinthepast) AND EndDate IS NULL

IF @customerintid IS NULL
BEGIN
	SET @customerintid = 1
	SET @customerid = dbo.GetCustomerIdFromInt(@customerintid)
END

-- JWF TODO rework this DID / NOID bit
-- Work out if the DID really is not ID or if we just didn't get it from the unit
IF @driverid = 'No ID' AND @ccid != 61
BEGIN
	SET @updatelatestdid = 0
END
-- DRIVER LOGOFF is an internally used string set by the listener when it actually gets a logoff rather than just no did info
IF @driverid = 'DRIVER LOGOFF' OR dbo.IsNonAlphaNumeric(@driverid) = 1
BEGIN
	SET @driverid = 'No ID'
END

--Check for the linked driver only if no driver logged in
IF @driverid = 'No ID'
	SET @did = dbo.GetLinkedDriverId(@vid)

IF @did IS NULL
BEGIN
	--If we are not using a linked driver - obtain the driver ID from the driver number
	SET @did = dbo.GetDriverIdFromNumberAndCustomer(@driverid, @customerid)
END
ELSE BEGIN
	--Update the VLE and set the last known driver
	SET @updatelatestdid = 1
END

IF @did IS NOT NULL
	SET @dintid = dbo.GetDriverIntFromId(@did)
ELSE  -- Driver not found so create one
	BEGIN
		SET @did = NEWID()
		EXEC proc_WriteDriver @did, @dintid OUTPUT, @customerid, @driverid, 'UNKNOWN'
	END

IF @ivhid IS NULL
BEGIN
	DECLARE @reg varchar(20)
	SET @ivhid = NEWID()
	SET @vid = NEWID()
	SET @reg = 'UNKNOWN ' + @trackerid
	
	EXEC proc_WriteIVH @ivhid = @ivhid, @ivhintid = @ivhintid OUTPUT, @trackerid = @trackerid
	EXEC proc_WriteVehicle @vid = @vid, @vintid = @vintid OUTPUT, @ivhid = @ivhid, @customerid = @customerid, @reg = @reg

END

-- Get next EventId for the Event table
SELECT @eid = NEXT VALUE FOR EventId

-- Write event 
EXEC proc_WriteEventListenerTemp 	@eid=@eid, @vintid = @vintid, @dintid = @dintid,
				@ccid = @ccid, @long = @long, @lat = @lat, @heading = @heading,
				@speed = @speed, @odogps = @odogps, @odoroadspeed = @odoroadspeed, @ododash = @ododash, 
				@eventdt = @eventdt, @dio = @dio, 
				@customerintid = @customerintid,
				@analog0 = @analog0, @analog1 = @analog1, @analog2 = @analog2, @analog3 = @analog3, 
				@analog4 = @analog4, @analog5 = @analog5,
				@sequencenumber = @sequencenumber,
				@evtstring = @evtstring, @evtdname = @evtdname,
				@altitude = @altitude,
				@gpssatellitecount = @gpssatellitecount,
				@gprssignalstrength = @gprssignalstrength,
				@systemstatus = @systemstatus,
				@batterychargelevel = @batterychargelevel,
				@externalinputvoltage = @externalinputvoltage,
				@maxspeed = @maxspeed,
				@tripdistance = @tripdistance, @tachostatus = @tachostatus, @canstatus = @canstatus,
				@fuelLevel = @fuelLevel,
				@hardwareStatus = @hardwareStatus,
				@ADBlueLevel = @ADBlueLevel,
				@bitmask = @bitmask

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
