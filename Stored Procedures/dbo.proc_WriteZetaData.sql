SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_WriteZetaData]
	@trackerid varchar(50),
	@unitproperty BINARY(2),
	@datavalue NVARCHAR(MAX)
AS

	SET NOCOUNT OFF

	DECLARE @vid UNIQUEIDENTIFIER,
			@vintid INT, 
			@ivhid UNIQUEIDENTIFIER, 
			@ivhintid INT,
			@customerid UNIQUEIDENTIFIER,
			@customerintid INT,
			@ecospeed BIT,
			@sdc BIT

	declare @sdateinthepast datetime
	declare @edateinthefuture datetime
	set @sdateinthepast = '1900-01-01 00:00'
	set @edateinthefuture = '2100-01-01 00:00'

	-- First identify the vehicle and customer from the trackerid
	SELECT @ivhid = IVH.IVHId, @ivhintid = IVH.IVHIntId, @vid = Vehicle.VehicleId, @vintid = Vehicle.VehicleIntId, @customerid = Customer.CustomerId, @customerintid = Customer.CustomerIntId
	FROM IVH 
		INNER JOIN Vehicle ON IVH.IVHId = Vehicle.IVHId
		INNER JOIN CustomerVehicle ON Vehicle.VehicleId = CustomerVehicle.VehicleId
		INNER JOIN Customer ON Customer.CustomerId = CustomerVehicle.CustomerId
	WHERE TrackerNumber = @trackerid 
		AND IVH.Archived = 0 AND Vehicle.Archived = 0 AND dbo.CustomerVehicle.Archived = 0
		AND GETDATE() >= ISNULL(StartDate, @sdateinthepast) AND EndDate IS NULL

	-- if customer not found use default customer instead
	IF @customerintid IS NULL
	BEGIN
		SET @customerintid = 1
		SET @customerid = dbo.GetCustomerIdFromInt(@customerintid)
	END

	-- if tracker not found create a vehicle and ivh
	IF @ivhid IS NULL
	BEGIN
		DECLARE @reg varchar(20)
		SET @ivhid = NEWID()
		SET @vid = NEWID()
		SET @reg = 'UNKNOWN ' + @trackerid
		
		EXEC proc_WriteIVH @ivhid = @ivhid, @ivhintid = @ivhintid OUTPUT, @trackerid = @trackerid
		EXEC proc_WriteVehicle @vid = @vid, @vintid = @vintid OUTPUT, @ivhid = @ivhid, @customerid = @customerid, @reg = @reg

	END
	
	-- Now determine the type of data to be written
	IF @unitproperty = 0x0000	-- Heartbeat
	BEGIN
		EXEC dbo.proc_WriteHeartbeatTemp @vintid, @ivhintid, @datavalue, NULL
	END ELSE
	IF @unitproperty = 0x0041	-- log Data
	BEGIN
		EXEC dbo.proc_WriteLogDataTemp @vintid, @ivhintid, @datavalue, NULL
	END



GO
