SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[proc_WriteEventBlob_Temp]
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
    DECLARE @customerintid INT
	DECLARE @did UNIQUEIDENTIFIER

    SET @eid = NULL
    SET @vid = NULL
    SET @customerintid = NULL
	SET @did = NULL


    IF @driverID = '' 
        BEGIN
            SET @driverid = 'No ID'
        END


	-- Write Event
    EXEC proc_WriteEventNonIdTemp @trackerid = @trackerid,
        @driverid = @driverid, @ccid = @ccid, @long = @long, @lat = @lat,
        @heading = @heading, @speed = @speed, @tdistance = @tdistance,
        @eventdt = @eventdt, @dio = @dio, @flagid = 0, @evtstring = NULL,
        @evtdname = NULL, @customerintid = @customerintid OUTPUT, @vid = @vid OUTPUT,
        @eid = @eid OUTPUT

	
	INSERT INTO dbo.EventBlobTemp
	        ( 
			  EventId ,
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
	          @customerintid , -- CustomerIntId - int
	          @eventdt , -- EventDateTime - datetime
	          dbo.GetVehicleIntFromId(@vid) , -- VehicleIntId - int
	          null, --@did , -- DriverIntId - int
	          @ccid , -- CreationCodeId - smallint
	          NULL , -- SeverityId - smallint
	          @blob , -- Blob - binary
	          GETDATE() , -- LastOperation - smalldatetime
	          NULL  -- Archived - bit
	        )

	SET @ebid = SCOPE_IDENTITY()    

	-- Return EventBlobId
    --SELECT  @ebid AS EventBlobId


GO
