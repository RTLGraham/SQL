SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE PROC [dbo].[proc_WriteSCAMDataIn]
	@imei varchar(50), 
	@ccid smallint, 
	@long float, 
	@lat float, 
	@heading SMALLINT = NULL, 
	@speed SMALLINT = NULL,
	@odogps INT = NULL, 
	@eventdt datetime, 
	@ignstatus TINYINT = NULL,
	@altitude SMALLINT = NULL,
	@gpssatellitecount TINYINT = NULL,
	@gprssignalstrength TINYINT = NULL,	 
	@sequencenumber int,
	@addtlname varchar(30) = NULL,
	@addtlvalue nvarchar(MAX) = NULL
AS
BEGIN
	DECLARE @vid UNIQUEIDENTIFIER,
			@ivhid UNIQUEIDENTIFIER,
			@camid UNIQUEIDENTIFIER, 
			@did UNIQUEIDENTIFIER, 
			@customerid UNIQUEIDENTIFIER,
			@vintid INT, 
			@camintid INT, 
			@dintid INT,
			@customerintid INT,
			@dnumber VARCHAR(100),
			@eid BIGINT

	--DECLARE @tempvid uniqueidentifier, @tempattvid uniqueidentifier, @tempccid smallint

	DECLARE @sdateinthepast DATETIME,
			@edateinthefuture DATETIME
	SET @sdateinthepast = '1900-01-01 00:00'
	SET @edateinthefuture = '2100-01-01 00:00'

	-- get camera, vehicle and customer details
	SELECT @camid = c.CameraId, @camintid = c.CameraIntId, @vid = v.VehicleId, @ivhid = v.IVHId, @vintid = v.VehicleIntId, @customerid = cust.CustomerId, @customerintid = cust.CustomerIntId
	FROM dbo.Camera c
		INNER JOIN dbo.VehicleCamera vc ON vc.CameraId = c.CameraId
		INNER JOIN dbo.Vehicle v ON v.VehicleId = vc.VehicleId
		INNER JOIN CustomerVehicle cv ON cv.VehicleId = vc.VehicleId
		INNER JOIN Customer cust ON cust.CustomerId = cv.CustomerId
	WHERE c.Serial = @imei 
		AND c.Archived = 0 AND vc.Archived = 0 AND cv.Archived = 0 AND v.Archived = 0
		AND GETDATE() >= ISNULL(vc.StartDate, @sdateinthepast) AND vc.EndDate IS NULL
		AND GETDATE() >= ISNULL(cv.StartDate, @sdateinthepast) AND cv.EndDate IS NULL

	IF @customerintid IS NULL
	BEGIN
		SET @customerintid = 1
		SET @customerid = dbo.GetCustomerIdFromInt(@customerintid)
	END

	SET @dnumber = 'No ID' -- initialise

	--Check for the linked driver
	SET @did = dbo.GetLinkedDriverId(@vid)

	IF @did IS NULL	AND @ivhid IS NOT NULL -- No linked driver and Vehicle has an attached unit so try tacho lookup	
	BEGIN
		SET @did = dbo.GetDriverIdFromInt(dbo.GetDriverIdFromEvent_ITcamera(@vintid, @eventdt))
	END	

	IF @did IS NULL -- did is still null so use 'No ID' driver
	BEGIN
		SET @did = dbo.GetDriverIdFromNumberAndCustomer(@dnumber, @customerid)
	END

	IF @did IS NOT NULL
		SET @dintid = dbo.GetDriverIntFromId(@did)

	IF @camid IS NULL
	BEGIN
		DECLARE @reg varchar(30)
		SET @camid = NEWID()
		SET @vid = NEWID()
		SET @reg = 'UNKNOWN ' + @imei
	
		--GKP 09/10/19 Next two lines commented out by request from Dima as autocreation of cameras is causing more problems than benefits 
		--EXEC dbo.proc_WriteCamera @Project = '999', @Serial = @imei, @LicensePlate = NULL, @ApiId = NULL, @vehicleId = @vid OUTPUT, @cameraId = @camid OUTPUT
		--SELECT @camintid = c.CameraIntId FROM dbo.Camera c WHERE c.CameraId = @camid
	END
	ELSE 
	BEGIN	
		IF 
			-- If no tracker - write everything
			(@ivhid IS NULL) 
			OR -- if there is a tracker, write only video-specific events (TODO: add camera diagnostics events as well)
			(@ivhid IS NOT NULL AND @ccid IN (0,36,37,38,55,336,337,338,435,436,437,438,455,456,457,458,459,460))
		BEGIN

			-- Get next EventId for the Event table
			SELECT @eid = NEXT VALUE FOR EventId

			-- Now write SCAMDataIn
			EXEC dbo.proc_InsertSCAMDataIn 
				@eid, -- bigint
				@customerintid, -- int
				@vintid, -- int
				@camintid, -- int
				@dintid, -- int
				@imei, -- varchar(50)
				@ccid, -- smallint
				@long, -- float
				@lat, -- float
				@heading, -- smallint
				@speed, -- smallint
				@odogps, -- int
				@eventdt, -- datetime
				@ignstatus, -- tinyint
				@altitude, -- smallint
				@gpssatellitecount, -- tinyint
				@gprssignalstrength, -- tinyint
				@sequencenumber, -- int
				@addtlname, -- varchar(30)
				@addtlvalue -- nvarchar(max)

				SELECT EventId, SeqNumber
				from dbo.SCAM_DataIn
				where EventId = @eid;
		END
		ELSE
		BEGIN

		SELECT 0 as EventId, 0 as SeqNumber

		END
	END	
	
END

GO
