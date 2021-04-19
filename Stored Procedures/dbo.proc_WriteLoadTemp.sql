SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--Load follows the same pattern as PassComf.
--Data arrives at the listener where it is parsed and written to the database.

CREATE PROCEDURE [dbo].[proc_WriteLoadTemp] @Loadid int OUTPUT,
	@trackerid varchar(50), @driverid varchar(32),
	@ccid1 smallint, @creationDateTime datetime,
	@ccid2 smallint, @closureDateTime datetime,
	@clat float, @clng float, @t_t int, @t_d float, @t_f float,
	@time100 int, @dist100 float, @fuel100 float,
	@time0 int, @dist0 float, @fuel0 float,
	@time0_13 int, @dist0_13 float, @fuel0_13 float,
	@time14_37 int, @dist14_37 float, @fuel14_37 float,
	@time38_63 int, @dist38_63 float, @fuel38_63 float,
	@time64_88 int, @dist64_88 float, @fuel64_88 float,
	@time89_99 int, @dist89_99 float, @fuel89_99 float
AS
BEGIN

DECLARE @customerid UNIQUEIDENTIFIER
DECLARE @vintid INT, @dintid INT, @customerintid int
DECLARE @RouteID int
declare @sdateinthepast datetime
declare @edateinthefuture datetime

set @sdateinthepast = '1900-01-01 00:00'
set @edateinthefuture = '2100-01-01 00:00'
-------------------------------------------------------- Find Vehicle / customer 
	
SELECT top 1 @vintid = Vehicle.VehicleIntId, @customerid = Customer.CustomerId, @customerintid = Customer.CustomerIntId
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

SET @dintid = dbo.GetDriverIntFromId(dbo.GetDriverIdFromNumberAndCustomer(@driverid, @customerid))

-------------------------------------------------------- Write Data
INSERT INTO [LoadTemp] ([CreationCodeId],
	[CreationDateTime],
	[ClosureCodeId],
	[ClosureDateTime],
	[ClosureLat],
	[ClosureLong],
	[VehicleIntId],
	[DriverIntId],
	[CustomerIntId],
	[TotalTime],
	[TotalDistance],
	[TotalFuel],
	[TotalTime100],
	[TotalDistance100],
	[TotalFuel100],
	[TotalTime0],
	[TotalDistance0],
	[TotalFuel0],
	[TotalTime0_13],
	[TotalDistance0_13],
	[TotalFuel0_13],
	[TotalTime14_37],
	[TotalDistance14_37],
	[TotalFuel14_37],
	[TotalTime38_63],
	[TotalDistance38_63],
	[TotalFuel38_63],
	[TotalTime64_88],
	[TotalDistance64_88],
	[TotalFuel64_88],
	[TotalTime89_99],
	[TotalDistance89_99],
	[TotalFuel89_99],
	[LastOperation],
	[Archived])
	Values(@ccid1,
	@creationDateTime,
	@ccid2,
	@ClosureDateTime,
	@clat,
	@clng,
	@vintid,
	@dintid,
	@customerintid,
	@t_t,
	@t_d,
	@t_f,
	@time100,
	@dist100,
	@fuel100,
	@time0,
	@dist0,
	@fuel0,
	@time0_13,
	@dist0_13,
	@fuel0_13,
	@time14_37,
	@dist14_37,
	@fuel14_37,
	@time38_63,
	@dist38_63,
	@fuel38_63,
	@time64_88,
	@dist64_88,
	@fuel64_88,
	@time89_99,
	@dist89_99,
	@fuel89_99,
GetUtcDate(),
1)
SET @Loadid = SCOPE_IDENTITY()
END

GO
