SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_WKD_GetDriverDetails]
    @trackerid VARCHAR(50),
    @driverid VARCHAR(32),
    
    @driverName NVARCHAR(200) = NULL OUTPUT,
    @licenceNumber NVARCHAR(30) = NULL OUTPUT,
    @issuingAuthority NVARCHAR(20) = NULL OUTPUT,
    @workDiaryNumber NVARCHAR(20) = NULL OUTPUT
AS 
    BEGIN

        DECLARE @customerid UNIQUEIDENTIFIER,
				@vid UNIQUEIDENTIFIER,
				@vintid INT,
				@dintid INT,
				@customerintid INT,
				@sdateinthepast DATETIME,
				@edateinthefuture DATETIME

        SET @sdateinthepast = '1900-01-01 00:00'
        SET @edateinthefuture = '2100-01-01 00:00'
-------------------------------------------------------- Find Vehicle / customer 
	
        SELECT TOP 1
                @vintid = Vehicle.VehicleIntId,
                @vid = Vehicle.VehicleId,
                @customerid = Customer.CustomerId,
                @customerintid = Customer.CustomerIntId
        FROM    IVH
                INNER JOIN Vehicle ON IVH.IVHId = Vehicle.IVHId
                INNER JOIN CustomerVehicle ON Vehicle.VehicleId = CustomerVehicle.VehicleId
                INNER JOIN dbo.Customer ON dbo.CustomerVehicle.CustomerId = dbo.Customer.CustomerId
        WHERE   TrackerNumber = @trackerid
                AND IVH.Archived = 0
                AND Vehicle.Archived = 0
                AND Customer.Archived = 0
                AND ( IVH.IsTag = 0
                      OR IVH.IsTag IS NULL
                    )
                AND ( GETDATE() BETWEEN ISNULL(StartDate, @sdateinthepast)
                                AND     ISNULL(EndDate, @edateinthefuture) )
	

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
                EXEC proc_WriteDriver @did, @dintid OUTPUT, @customerid,
                    @driverid, 'UNKNOWN'
            END
        ELSE 
            BEGIN
                SET @dintid = dbo.GetDriverIntFromId(@did)
            END

------------------------------------------------------- Get Data		
		SELECT TOP 1
			@driverName = COALESCE(d.FirstName + ' ', '') + COALESCE(d.Surname, ''),
			@licenceNumber = d.LicenceNumber,
			@issuingAuthority = d.IssuingAuthority,
			@workDiaryNumber = wd.Number
		FROM dbo.Driver d
			LEFT JOIN dbo.WKD_WorkDiary wd ON d.DriverIntId = wd.DriverIntId AND wd.Archived = 0 AND wd.EndDate IS NULL
		WHERE d.DriverId = @did
		ORDER BY wd.StartDate DESC
	END

GO
