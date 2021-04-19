SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_WriteCustomerDriver] -- MUST BE PASSED A DriverID, even if just NEWID()
	@did uniqueidentifier, @customerid UNIQUEIDENTIFIER, @drivernumber varchar(32), @drivername varchar(50), @cid UNIQUEIDENTIFIER
AS
		INSERT INTO Driver (DriverId, Number, Surname)
		VALUES (@did, @drivernumber, @drivername)

		INSERT INTO CustomerDriver (CustomerId, DriverId, StartDate, EndDate)
		VALUES (@customerid, @did, GETDATE(), NULL)

GO
