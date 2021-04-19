SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[proc_WriteEventVideoTemp]
	@vehicleId UNIQUEIDENTIFIER,
	@cameraId UNIQUEIDENTIFIER,
    
    @eventdt DATETIME,
    @ccid SMALLINT,
	@lat float, 
    @long float, 
	@heading smallint, 
	@speed smallint,
	
    @apiEventId VARCHAR(1024),
    @apiVideoId VARCHAR(1024),
    @apiMetadataId VARCHAR(1024) = NULL,
    
    @apiFileName VARCHAR(1024),
    @apiStartTime DATETIME = NULL,
    @apiEndTime DATETIME = NULL ,
    
	@eventVideoId BIGINT=NULL OUTPUT  
AS 
    DECLARE @vintid INT,
			@dintid INT,
			@driverid VARCHAR(32),
			@customerintid INT,
    		@customerid UNIQUEIDENTIFIER,
			@did UNIQUEIDENTIFIER,
			@eid BIGINT
    
    -- Get Vehicle ID
    SELECT  @vintid = v.VehicleIntId,
            @customerid = c.CustomerId,
            @customerintid = c.CustomerIntId
    FROM    Vehicle v
            INNER JOIN CustomerVehicle cv ON v.VehicleId = cv.VehicleId
            INNER JOIN Customer c ON c.CustomerId = cv.CustomerId
    WHERE   v.VehicleId = @vehicleId
            AND v.Archived = 0
            AND cv.Archived = 0
    

	--Check for the linked driver
	SET @did = dbo.GetLinkedDriverId(@vehicleId)

	IF @did IS NULL
	BEGIN
		--If there is no linked driver - obtain the driver ID from the the most recent DID record in EventData table
		SELECT TOP 1 @did = d.DriverId
		FROM [dbo].EventData ed
		INNER JOIN dbo.Driver d ON ed.DriverIntId = d.DriverIntId
		WHERE ed.VehicleIntId = @vintid
		  AND ed.EventDateTime > DATEADD(dd, -1, GETUTCDATE())
		  AND ed.EventDataName = 'DID'
		ORDER BY ed.EventDateTime DESC
	END   
	
	SET @dintid = dbo.GetDriverIntFromId(@did)

	IF @vintid IS NOT NULL AND @dintid IS NOT NULL AND @customerintid IS NOT NULL
	BEGIN
		/* Write the event */
		INSERT INTO EventTemp 	
						(VehicleIntId, DriverIntId, CreationCodeId,
						Long, Lat, Heading, Speed, 
						OdoGPS, OdoRoadSpeed, OdoDashboard,
						EventDateTime, DigitalIO, CustomerIntId
						)
		VALUES			(@vintid, @dintid, @ccid,
						@long, @lat, @heading, @speed, 
						0, 0, 0,
						@eventdt, 0, @customerintid
						)

		SET @eid = SCOPE_IDENTITY()

		INSERT INTO dbo.EventVideoTemp
				( EventId ,
				  EventDateTime ,
				  CreationCodeId ,
				  CustomerIntId ,
				  VehicleIntId ,
				  DriverIntId ,
				  CoachingStatusId ,
				  ApiEventId ,
				  ApiVideoId ,
				  ApiMetadataId ,
				  ApiFileName ,
				  ApiStartTime ,
				  ApiEndTime ,
				  LastOperation 
				)
		VALUES  ( @eid , -- EventId - bigint
				  @eventdt , -- EventDateTime - datetime
				  @ccid , -- CreationCodeId - smallint
				  @customerintid , -- CustomerIntId - int
				  @vintid , -- VehicleIntId - int
				  @dintid , -- DriverIntId - int
				  0 , -- CoachingStatusId - int
				  @apiEventId , -- ApiEventId - varchar(1024)
				  @apiVideoId , -- ApiVideoId - varchar(1024)
				  @apiMetadataId,
				  @apiFileName , -- ApiFileName - varchar(1024)
				  @apiStartTime , -- ApiStartTime - datetime
				  @apiEndTime , -- ApiEndTime - datetime
				  GETDATE() -- LastOperation - smalldatetime
				)

		SET @eventVideoId = SCOPE_IDENTITY()
	END
	ELSE
	BEGIN	
		SET @eventVideoId = 0
	END

GO
