SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_WriteVehicleAnalogIoDataTemp]
(
	@analogioid BIGINT OUTPUT,
	@trackerId VARCHAR(50),
	@driverId VARCHAR(32),
	@ccid INT,
	@lat FLOAT,
	@lon FLOAT,
	@edt DATETIME,
	@status TINYINT,
	@speed SMALLINT,
	@textblob VARCHAR(MAX)
)
AS
BEGIN
	DECLARE @customerid UNIQUEIDENTIFIER,
			@sdateinthepast DATETIME,
			@edateinthefuture DATETIME,
			@keyon BIT
	DECLARE @vintid INT, @ivhintid INT, @dintid INT	
			
	SET @sdateinthepast = '1900-01-01'
	SET @edateinthefuture = '2100-01-01'
	

-- Find Vehicle / customer 
SELECT top 1 @vintid = Vehicle.VehicleIntId, @customerid = Customer.CustomerId
FROM IVH 
	INNER JOIN Vehicle ON IVH.IVHId = Vehicle.IVHId
	INNER JOIN CustomerVehicle ON Vehicle.VehicleId = CustomerVehicle.VehicleId
	INNER JOIN dbo.Customer ON dbo.CustomerVehicle.CustomerId = dbo.Customer.CustomerId
WHERE TrackerNumber = @trackerid 
	AND IVH.Archived = 0 AND Vehicle.Archived = 0 AND Customer.Archived = 0 AND (IVH.IsTag = 0 OR IVH.IsTag IS NULL)
	AND (GETDATE() BETWEEN ISNULL(StartDate, @sdateinthepast) AND ISNULL(EndDate, @edateinthefuture))

-- Find Driver 
IF @driverid = ''
BEGIN
	SET @driverid = 'No ID'
END

SELECT TOP 1 @dintid = d.DriverIntId 
FROM dbo.CustomerDriver cd
INNER JOIN Driver d ON cd.DriverId = d.DriverId
WHERE 
	(d.Number = @driverid OR
	   d.NumberAlternate = @driverid OR
	   d.NumberAlternate2 = @driverid)
	AND cd.CustomerId = @customerid 
	AND cd.Archived = 0 
	AND d.Archived = 0
	AND (GETDATE() BETWEEN ISNULL(cd.StartDate, @sdateinthepast) AND ISNULL(cd.EndDate, @edateinthefuture))
ORDER BY d.LastOperation DESC
	
	SET @keyon = 0
	
	INSERT INTO dbo.VehicleAnalogIoDataTemp ( VehicleIntId , DriverIntId , EventDateTime , Lat , Long , Speed , KeyOn , Value, Archived )
	VALUES  ( @vintid, @dintid, @edt, @lat, @lon, @speed, @keyon, @textblob, 1)
			  
	SET @analogioid = SCOPE_IDENTITY()
END

GO
