SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[proc_WriteEventNonIdNoDriverUpdateTemp]
	@trackerid varchar(50), @driverid varchar(32), 
	@ccid smallint, @long float, @lat float, @heading smallint, @speed smallint,
	@odogps int, @odoroadspeed int, @ododash int,
	@eventdt datetime, @dio tinyint, 
	@analog0 smallint, @analog1 smallint, @analog2 smallint, @analog3 smallint,
	@analog4 smallint, @analog5 smallint, 
	@sequencenumber int,
	@evtstring varchar(1024) = NULL, @evtdname varchar(30) = NULL,
	@customerintid int OUTPUT, @vid UNIQUEIDENTIFIER OUTPUT, @eid bigint=NULL OUTPUT
AS
DECLARE @ivhid uniqueidentifier, @did uniqueidentifier, @customerid UNIQUEIDENTIFIER
DECLARE @ivhintid INT, @dintid INT, @vintid INT
DECLARE @tempvid uniqueidentifier, @tempattvid uniqueidentifier, @tempccid SMALLINT

DECLARE @usesgf bit
declare @sdateinthepast datetime
declare @edateinthefuture datetime
DECLARE @updatelatestdid bit
set @sdateinthepast = '1900-01-01 00:00'
set @edateinthefuture = '2100-01-01 00:00'

-- get ivh and vehicle details
SELECT @ivhid = IVH.IVHId, @ivhintid = dbo.IVH.IVHIntId, @vid = Vehicle.VehicleId, @vintid = dbo.Vehicle.VehicleIntId, @customerid = dbo.CustomerVehicle.CustomerId, @customerintid = dbo.Customer.CustomerIntId
FROM IVH 
	INNER JOIN Vehicle ON IVH.IVHId = Vehicle.IVHId
	INNER JOIN CustomerVehicle ON Vehicle.VehicleId = CustomerVehicle.VehicleId
	INNER JOIN dbo.Customer ON Customer.CustomerId = CustomerVehicle.CustomerId
WHERE TrackerNumber = @trackerid 
	AND IVH.Archived = 0 AND Vehicle.Archived = 0 AND dbo.CustomerVehicle.Archived = 0 AND (IVH.IsTag = 0 OR IVH.IsTag IS NULL)
	AND (GETDATE() BETWEEN ISNULL(StartDate, @sdateinthepast) AND ISNULL(EndDate, @edateinthefuture))

IF @customerintid IS NULL
BEGIN
	SET @customerintid = 1
	SET @customerid = dbo.GetCustomerIdFromInt(@customerintid)
END
-- DRIVER LOGOFF is an internally used string set by the listener when it actually gets a logoff rather than just no did info
IF @driverid = 'DRIVER LOGOFF'
BEGIN
	SET @driverid = 'No ID'
END


--Check for the linked driver
SET @did = dbo.GetLinkedDriverId(@vid)

IF @did IS NULL
BEGIN
	--If there is no linked driver - obtain the driver ID from the driver number
	SET @did = dbo.GetDriverIdFromNumberAndCustomer(@driverid, @customerid)
END

IF @did IS NOT NULL
	SET @dintid = dbo.GetDriverIntFromId(@did)

IF @ivhid IS NULL
BEGIN
	DECLARE @reg varchar(20)
	SET @ivhid = NEWID()
	SET @vid = NEWID()
	SET @reg = 'UNKNOWN ' + @trackerid

	EXEC proc_WriteIVH @ivhid = @ivhid, @ivhintid = @ivhintid OUTPUT, @trackerid = @trackerid
	EXEC proc_WriteVehicle @vid = @vid, @vintid = @vintid OUTPUT, @ivhid = @ivhid, @customerid = @customerid, @reg = @reg
END

IF @did IS NULL
BEGIN
	SET @did = NEWID()
	EXEC proc_WriteDriver @did = @did, @dintid = @dintid OUTPUT, @customerid = @customerid, @drivernumber = @driverid, @drivername = 'UNKNOWN'
END

-- Processing for trailers has been removed from here

-- Write event 
EXEC proc_WriteEventNewTemp 	@eid=@eid OUTPUT, @vintid = @vintid, @dintid = @dintid,
				@ccid = @ccid, @long = @long, @lat = @lat, @heading = @heading,
				@speed = @speed, @odogps = @odogps, @odoroadspeed = @odoroadspeed, @ododash = @ododash, 
				@eventdt = @eventdt, @dio = @dio, 
				@customerintid = @customerintid,
				@analog0 = @analog0, @analog1 = @analog1, @analog2 = @analog2, @analog3 = @analog3, 
				@analog4 = @analog4, @analog5 = @analog5,
				@sequencenumber = @sequencenumber,
				@evtstring = @evtstring, @evtdname = @evtdname

SELECT @eid AS EventId


GO
