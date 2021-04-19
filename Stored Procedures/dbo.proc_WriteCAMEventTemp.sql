SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE PROC [dbo].[proc_WriteCAMEventTemp]
	@vid UNIQUEIDENTIFIER, @vintid INT, @customerid UNIQUEIDENTIFIER, @customerintid INT, @did UNIQUEIDENTIFIER, @ivhid UNIQUEIDENTIFIER,
	@ccid smallint, @long float, @lat float, @heading smallint, @speed smallint,
	@odogps int, @odotrip INT,
	@eventdt DATETIME,
	@dintid INT OUTPUT,
	@eid bigint=NULL OUTPUT

AS

DECLARE @tempvid uniqueidentifier, @tempattvid uniqueidentifier, @tempccid SMALLINT, @tempdt DATETIME, @prevlat FLOAT, @prevlon FLOAT

-- Try and determine driver if no linked driver already provided
IF @did IS NULL	
BEGIN
	IF @ivhid IS NOT NULL -- No linked driver and Vehicle has an attached unit so try tacho lookup	
	BEGIN
		SET @dintid = dbo.GetDriverIdFromEvent_ITcamera(@vintid, @eventdt)
	END ELSE
    BEGIN -- no matching driver so use 'No ID' Driver
		SET @dintid = dbo.GetDriverIntFromId(dbo.GetDriverIdFromNumberAndCustomer('No ID', @customerid))
	END	
END ELSE
	SET @dintid = dbo.GetDriverIntFromId(@did)

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
	
	-- Get next EventId for the Event table
	SELECT @eid = NEXT VALUE FOR EventId

	-- Write event 
	EXEC proc_WriteEventCamTemp 	@eid=@eid, @vintid = @vintid, @dintid = @dintid,
					@ccid = @ccid, @long = @long, @lat = @lat, @heading = @heading,
					@speed = @speed, @odogps = @odogps, @odoroadspeed = @odotrip, @ododash = @odogps, 
					@eventdt = @eventdt, @dio = NULL, 
					@customerintid = @customerintid,
					@analog0 = NULL, @analog1 = NULL, @analog2 = NULL, @analog3 = NULL, 
					@analog4 = NULL, @analog5 = NULL,
					@sequencenumber = NULL,
					@evtstring = NULL, @evtdname = NULL,
					@altitude = NULL,
					@gpssatellitecount = NULL,
					@gprssignalstrength = NULL,
					@systemstatus = NULL,
					@batterychargelevel = NULL,
					@externalinputvoltage = NULL,
					@maxspeed = NULL,
					@tripdistance = @odotrip, @tachostatus = NULL, @canstatus = NULL,
					@fuelLevel = NULL,
					@hardwareStatus = NULL
	
END

SELECT @eid AS EventId


GO
