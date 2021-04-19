SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--Load follows the same pattern as PassComf.
--Data arrives at the listener where it is parsed and written to the database.

CREATE PROCEDURE [dbo].[proc_WriteDgenTemp] @DgenId BIGINT OUTPUT,
	@trackerid VARCHAR(50), @DgenDateTime DATETIME, @driverid VARCHAR(32),
	@accumseqnbr INT, @type SMALLINT, @index SMALLINT, @count INT,
	@payload VARCHAR(MAX)
AS
BEGIN

DECLARE @customerid UNIQUEIDENTIFIER,
		@vid UNIQUEIDENTIFIER
DECLARE @vintid INT, @dintid INT, @customerintid int
declare @sdateinthepast datetime
declare @edateinthefuture datetime

set @sdateinthepast = '1900-01-01 00:00'
set @edateinthefuture = '2100-01-01 00:00'
-------------------------------------------------------- Find Vehicle / customer 
	
SELECT top 1 @vintid = Vehicle.VehicleIntId, @vid = Vehicle.VehicleId, @customerid = Customer.CustomerId, @customerintid = Customer.CustomerIntId
FROM IVH 
	INNER JOIN Vehicle ON IVH.IVHId = Vehicle.IVHId
	INNER JOIN CustomerVehicle ON Vehicle.VehicleId = CustomerVehicle.VehicleId
	INNER JOIN dbo.Customer ON dbo.CustomerVehicle.CustomerId = dbo.Customer.CustomerId
WHERE TrackerNumber = @trackerid 
	AND IVH.Archived = 0 AND Vehicle.Archived = 0 AND Customer.Archived = 0 AND (IVH.IsTag = 0 OR IVH.IsTag IS NULL)
	AND (GETDATE() BETWEEN ISNULL(StartDate, @sdateinthepast) AND ISNULL(EndDate, @edateinthefuture))
	

------------------------------------------------------- Find Driver - 
IF @driverid = ''
BEGIN
	SET @driverid = 'No ID'
END

DECLARE @did UNIQUEIDENTIFIER

--Check for the linked driver
SET @did = dbo.GetLinkedDriverId(@vid)

IF @did IS NULL
BEGIN
	--If there is no linked driver - obtain the driver ID from the driver number
	SET @did = dbo.GetDriverIdFromNumberAndCustomer(@driverid, @customerid)
END

IF @did IS NULL
BEGIN
	SET @did = NEWID()
	EXEC proc_WriteDriver @did, @dintid OUTPUT, @customerid, @driverid, 'UNKNOWN'
END
ELSE BEGIN
	SET @dintid = dbo.GetDriverIntFromId(@did)
END

-------------------------------------------------------- Write Data
INSERT INTO dbo.DgenTemp
        ( CustomerIntId ,
          VehicleIntId ,
          DriverIntId ,
          DgenDateTime ,
          DgenIndexId ,
          DgenTypeId ,
          AccumSeqNbr ,
          Payload ,
          DgenCount
        )

VALUES (
	@customerintid,
	@vintid,
	@dintid,
	@dgendatetime,
	@index,
	@type,
	@accumseqnbr,
	@payload,
	@count
	)
	
SET @DgenId = SCOPE_IDENTITY()
END

GO
