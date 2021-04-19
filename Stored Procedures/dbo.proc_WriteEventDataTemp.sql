SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_WriteEventDataTemp]
    @eid BIGINT,
    @evtdname VARCHAR(30) = NULL,
    @evtstring VARCHAR(1024) = NULL,
    @evtint INT = NULL,
    @evtfloat FLOAT = NULL,
    @evtbit BIT = NULL,
    @ccid SMALLINT,
    @customerintid INT,
    @trackerid VARCHAR(50),
    @driverid VARCHAR(32),
    @eventdt DATETIME
AS 
    DECLARE @vintid INT,
			@dintid INT,
			@customerid UNIQUEIDENTIFIER,
			@did UNIQUEIDENTIFIER,
			@vid UNIQUEIDENTIFIER
    
    -- Get Vehicle ID
    SELECT  @vintid = Vehicle.VehicleIntId,
			@vid = Vehicle.VehicleId,
            @customerid = Customer.CustomerId
    FROM    IVH
            INNER JOIN Vehicle ON IVH.IVHId = Vehicle.IVHId
            INNER JOIN CustomerVehicle ON Vehicle.VehicleId = CustomerVehicle.VehicleId
            INNER JOIN Customer ON Customer.CustomerId = CustomerVehicle.CustomerId
    WHERE   TrackerNumber = @trackerid
            AND IVH.Archived = 0
            AND Vehicle.Archived = 0
            AND dbo.CustomerVehicle.Archived = 0
            AND ( IVH.IsTag = 0
                  OR IVH.IsTag IS NULL
                )
    
    
    --Get Driver ID
    IF @driverid = 'DRIVER LOGOFF' 
    BEGIN
        SET @driverid = 'No ID' -- DRIVER LOGOFF is an internally used string set by the listener when it actually gets a logoff rather than just no did info
    END
    
	    
	--Check for the linked driver
	SET @did = dbo.GetLinkedDriverId(@vid)

	IF @did IS NULL
	BEGIN
		--If there is no linked driver - obtain the driver ID from the driver number
		SET @did = dbo.GetDriverIdFromNumberAndCustomer(@driverid, @customerid)
	END   
	
	SET @dintid = dbo.GetDriverIntFromId(@did)
        
    IF @evtdname IS NULL 
        SET @evtdname = 'Dump'


    INSERT  INTO EventDataTemp
            (
              EventId,
              EventDataName,
              EventDataString,
              EventDataInt,
              EventDataFloat,
              EventDataBit,
              LastOperation,
			  EventDateTime ,
              CreationCodeId,
              CustomerIntId,
              VehicleIntId,
              DriverIntId
            )
    VALUES  (
              @eid,
              @evtdname,
              @evtstring,
              @evtint,
              @evtfloat,
              @evtbit,
              GETDATE(),
              @eventdt,
              @ccid,
              @customerintid,
              @vintid,
              @dintid
            )

GO
