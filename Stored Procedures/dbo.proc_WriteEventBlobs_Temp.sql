SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[proc_WriteEventBlobs_Temp]
    @ebid bigint = NULL OUTPUT,
	-- Event
    @trackerid VARCHAR(50),
    @driverid VARCHAR(32),
    @ccid SMALLINT,
    @long FLOAT,
    @lat FLOAT,
    @heading SMALLINT,
    @speed SMALLINT,
    @tdistance INT,
    @eventdt DATETIME,
    @dio TINYINT,
    -- Blob
    @blob VARBINARY(MAX)
AS 
    DECLARE @eid BIGINT
    DECLARE @vid UNIQUEIDENTIFIER
    DECLARE @depid INT
	DECLARE @did UNIQUEIDENTIFIER
	DECLARE @vintid INT,
			@dintid INT,
			@customerid UNIQUEIDENTIFIER
			
    SET @eid = NULL
    SET @vid = NULL
    SET @depid = NULL
	SET @did = NULL
	SET @dintid = NULL


    IF @driverID = '' OR @driverid = 'DRIVER LOGOFF'
    BEGIN
        SET @driverid = 'No ID'
    END
    
    --Get Driver ID
    IF @driverid = 'DRIVER LOGOFF' 
    BEGIN
        SET @driverid = 'No ID' -- DRIVER LOGOFF is an internally used string set by the listener when it actually gets a logoff rather than just no did info
    END
    
    
    -- Get Vehicle ID
    SELECT  @vintid = Vehicle.VehicleIntId,
			@vid = Vehicle.VehicleId,
            @customerid = Customer.CustomerId,
            @depid = Customer.CustomerIntId
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
    
	--Check for the linked driver
	SET @did = dbo.GetLinkedDriverId(@vid)

	IF @did IS NULL
	BEGIN
		--If there is no linked driver - obtain the driver ID from the driver number
		SET @did = dbo.GetDriverIdFromNumberAndCustomer(@driverid, @customerid)
	END   
	
	SET @dintid = dbo.GetDriverIntFromId(@did)

	-- Write Event
    EXEC proc_WriteEventNewNonIdTemp 
		@trackerid = @trackerid,
        @driverid = @driverid, 
        @ccid = @ccid, 
        @long = @long, 
        @lat = @lat,
        @heading = @heading, 
        @speed = @speed, 
        
        @odogps = @tdistance,
        @odoroadspeed = @tdistance,
        @ododash = @tdistance,
        
        @eventdt = @eventdt, 
        @dio = @dio, 
        
        @analog0 = NULL,
        @analog1 = NULL,
        @analog2 = NULL,
        @analog3 = NULL,
        @analog4 = NULL,
        @analog5 = NULL,
        @sequencenumber = NULL,
        
        @evtstring = NULL,
        @evtdname = NULL, 
        @customerintid = @depid OUTPUT,
        @vid = @vid OUTPUT,
        @eid = @eid OUTPUT

	
	INSERT INTO dbo.EventBlobTemp
	        ( EventId ,
	          CustomerIntId ,
	          EventDateTime ,
	          VehicleIntId ,
	          DriverIntId ,
	          CreationCodeId ,
	          SeverityId ,
	          Blob ,
	          LastOperation ,
	          Archived
	        )
	VALUES  (
	          @eid , -- EventId - bigint
	          @depid , -- DepotId - int
	          @eventdt , -- EventDateTime - datetime
	          @vintid , -- VehicleIntId - int
	          @dintid, -- DriverIntId - int
	          @ccid , -- CreationCodeId - smallint
	          NULL , -- SeverityId - smallint
	          @blob , -- Blob - binary
	          GETDATE() , -- LastOperation - smalldatetime
	          NULL  -- Archived - bit
	        )
	        
	SET @ebid = SCOPE_IDENTITY()    

	-- Return EventsBlobsId
    --SELECT  @ebid AS EventsBlobsId



GO
