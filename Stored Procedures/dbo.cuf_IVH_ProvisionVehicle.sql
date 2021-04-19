SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_IVH_ProvisionVehicle] (
	@trackerid nvarchar(255),
	@reg nvarchar(50),
	@hwSupplierId int = NULL,
	@hwId int = NULL,
	@telcoId int = NULL,
	@customerid UNIQUEIDENTIFIER,
	@serial nvarchar(50),
	@phone varchar(50),
	@scrdnum varchar(50),
	@groupid uniqueidentifier = NULL, 
	@typeid INT = NULL,
	@frmwrver varchar(50)
)
AS
	
DECLARE @ivhid UNIQUEIDENTIFIER
DECLARE @ivhintid INT
DECLARE @pktype varchar(50)
DECLARE @svcprvdr varchar(50)
DECLARE @atype varchar(50)
DECLARE @istag bit
DECLARE @manufacturer varchar(50)
DECLARE @model varchar(50)

declare @groupName varchar(255),
		@vid uniqueidentifier

declare @exists uniqueidentifier

-- Get values from the look up tables if specified
IF @hwSupplierId IS NOT NULL
BEGIN
	SELECT @manufacturer = Name FROM dbo.HardwareSupplier WHERE HardwareSupplierId = @hwSupplierId 
END

IF @hwId IS NOT NULL
BEGIN
	SELECT @model = Name FROM dbo.HardwareType WHERE HardwareTypeId = @hwId
END

IF @telcoId IS NOT NULL
BEGIN
	SELECT @svcprvdr = Name FROM dbo.TelcoProvider WHERE TelcoProviderId = @telcoId 
END

-- check to see if this vehicle has already sent data
SELECT @ivhid = IVHId FROM [dbo].[IVH] WHERE TrackerNumber = @trackerid AND Archived = 0

-- pre-provision the vehicle hardware
EXECUTE [dbo].[proc_WriteIVH] 
   @ivhid
  ,@ivhintid
  ,@trackerid
  ,@manufacturer
  ,@model
  ,@pktype
  ,@phone
  ,@scrdnum
  ,@svcprvdr
  ,@serial
  ,@frmwrver
  ,@atype
  ,@istag

SELECT @ivhid = IVHId FROM [dbo].[IVH] WHERE TrackerNumber = @trackerid AND Archived = 0

-- if this vehicle has already sent data, then there will already be an entry in the Vehicle table
-- for this tracker number. If so, then perform an update rather than an insert
SELECT @exists = VehicleId FROM [dbo].[Vehicle] WHERE Ivhid = @ivhid AND Archived = 0

IF @exists IS NULL
BEGIN
	INSERT INTO [dbo].[Vehicle] 
		(
			ivhid, 
			registration
			, VehicleTypeID
		) 
	VALUES 
		(
			@ivhid, 
			@reg
			, @typeid
		)
END
ELSE
BEGIN
	UPDATE [dbo].[Vehicle]
	SET Registration = @reg
		, VehicleTypeID = @typeid
	WHERE IVHId = @ivhid
END

SELECT @vid = vehicleid 
FROM [dbo].[Vehicle]
WHERE ivhid = @ivhid AND registration = @reg

-- have we got an entry in the VehicleLatestEvent for today?
SELECT @exists = VehicleId FROM [dbo].[VehicleLatestEvent]
WHERE VehicleId = @vid AND dateadd(dd,0, datediff(dd,0, EventDateTime)) = dateadd(dd,0, datediff(dd,0, getDate()))

-- if not, then add it.
IF @exists IS NULL
BEGIN
	INSERT INTO [dbo].[VehicleLatestEvent] (VehicleId)
	VALUES (@vid)
END

-- if the Customer is unknown at this point, then don't add it twice (below)
SELECT @exists = VehicleId FROM [dbo].[CustomerVehicle]
WHERE VehicleId = @vid AND CustomerId = dbo.GetCustomerIdFromInt(0)

IF @exists IS NULL
BEGIN
	INSERT INTO [dbo].[CustomerVehicle] (CustomerId, vehicleid, startdate, enddate, archived)
	VALUES (dbo.GetCustomerIdFromInt(0), @vid, getdate(), getdate(), 0)
END

INSERT INTO [dbo].[CustomerVehicle] (CustomerId, vehicleid, startdate, enddate, archived)
VALUES (@customerid, @vid, getdate(), null, 0)

IF @customerid != dbo.GetCustomerIdFromInt(0)
BEGIN
	UPDATE [dbo].[CustomerVehicle]
	SET EndDate = GetDate()
	WHERE VehicleId = @vid
	AND CustomerId = dbo.GetCustomerIdFromInt(0)
	AND EndDate IS NULL
END

-- if we specified a group in the parameters, then add this vehicle to the group.
IF @groupId IS NOT NULL
BEGIN
	INSERT INTO dbo.[GroupDetail] (GroupId, GroupTypeId, EntityDataId)
	VALUES (@groupId, 1, @vid)
END

GO
