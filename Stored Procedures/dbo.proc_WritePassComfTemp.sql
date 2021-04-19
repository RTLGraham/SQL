SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[proc_WritePassComfTemp] @passcomfid int OUTPUT,
	@trackerid varchar(50), @driverid varchar(32), @RouteNumber varchar(50),
	@ccid smallint, @creationDateTime datetime, @closureDateTime datetime,
	@d_t int, @d_d float, @Score int, 
	@RS0Accel int, @RS0Brake int, @RS0Corner int,
	@RS1Accel int, @RS1Brake int, @RS1Corner int,
	@RS2Accel int, @RS2Brake int, @RS2Corner int,
	@RS3Accel int, @RS3Brake int, @RS3Corner int,
	@RS4Accel int, @RS4Brake int, @RS4Corner int,
	@RS5Accel int, @RS5Brake int, @RS5Corner int,
	@RS6Accel int, @RS6Brake int, @RS6Corner int,
	@RS7Accel int, @RS7Brake int, @RS7Corner int,
	@RS8Accel int, @RS8Brake int, @RS8Corner int,
	@RS9Accel int, @RS9Brake int, @RS9Corner int

AS

DECLARE @customerid UNIQUEIDENTIFIER
DECLARE @vintid INT, @dintid INT, @customerintid int
DECLARE @RouteID int
declare @sdateinthepast datetime
declare @edateinthefuture datetime

SET @RouteID = NULL
set @sdateinthepast = '1900-01-01 00:00'
set @edateinthefuture = '2100-01-01 00:00'


------------------------------------------------------
-- Find Vehicle / customer 
SELECT top 1 @vintid = Vehicle.VehicleIntId, @customerid = Customer.CustomerId, @customerintid = Customer.CustomerIntId
FROM IVH 
	INNER JOIN Vehicle ON IVH.IVHId = Vehicle.IVHId
	INNER JOIN CustomerVehicle ON Vehicle.VehicleId = CustomerVehicle.VehicleId
	INNER JOIN dbo.Customer ON dbo.CustomerVehicle.CustomerId = dbo.Customer.CustomerId
WHERE TrackerNumber = @trackerid 
	AND IVH.Archived = 0 AND Vehicle.Archived = 0 AND Customer.Archived = 0 AND (IVH.IsTag = 0 OR IVH.IsTag IS NULL)
	AND (GETDATE() BETWEEN ISNULL(StartDate, @sdateinthepast) AND ISNULL(EndDate, @edateinthefuture))


------------------------------------------------------
-- Find Driver 
IF @driverid = ''
BEGIN
	SET @driverid = 'No ID'
END

SET @dintid = dbo.GetDriverIntFromId(dbo.GetDriverIdFromNumberAndCustomer(@driverid, @customerid))

------------------------------------------------------
-- Find Route - from write accum
-- Should always exist, aswe've just written an accum with them same route?
-- !!!!! Accum don't currently support Route via gprs, only via ftp
If @RouteNumber = '' or @RouteNumber is NULL or @RouteNumber = '0'
BEGIN
	SET @RouteNumber = 'No Route'
END

Select @RouteID = r.RouteID 
from Route r
inner join CustomerRoute cr on r.RouteID = cr.RouteID
Where CustomerId = @customerid
And RouteNumber = @RouteNumber
And r.Archived = 0 and cr.Archived = 0

IF @RouteID is NULL--add it to the depot
BEGIN
INSERT INTO Route(RouteNumber, RouteName, LastOperation, Archived) Values (@RouteNumber,'UNKNOWN',GETUTCDATE(),0)
SET @RouteID = SCOPE_IDENTITY()
INSERT INTO CustomerRoute(CustomerId, RouteID, StartDate, EndDate, LastOperation,Archived)
Values(@customerid, @RouteID, GETUTCDATE(),NULL,GETUTCDATE(),0)
END


------------------------------------------------------
-- Write Data

INSERT INTO [dbo].[PassComfTemp]
           ([CreationCodeId]
           ,[CreationDateTime]
           ,[ClosureDateTime]
           ,[VehicleIntId]
           ,[DriverIntId]
           ,[RouteId]
           ,[CustomerIntId]
           ,[DrivingTime]
           ,[DrivingDistance]
           ,[Score]
           ,[RS0Accel]
           ,[RS0Brake]
           ,[RS0Corner]
           ,[RS1Accel]
           ,[RS1Brake]
           ,[RS1Corner]
           ,[RS2Accel]
           ,[RS2Brake]
           ,[RS2Corner]
           ,[RS3Accel]
           ,[RS3Brake]
           ,[RS3Corner]
           ,[RS4Accel]
           ,[RS4Brake]
           ,[RS4Corner]
           ,[RS5Accel]
           ,[RS5Brake]
           ,[RS5Corner]
           ,[RS6Accel]
           ,[RS6Brake]
           ,[RS6Corner]
           ,[RS7Accel]
           ,[RS7Brake]
           ,[RS7Corner]
           ,[RS8Accel]
           ,[RS8Brake]
           ,[RS8Corner]
           ,[RS9Accel]
           ,[RS9Brake]
           ,[RS9Corner]
           ,[LastOperation]
           ,[Archived])
     VALUES
           (@ccid, @creationDateTime, @closureDateTime,
            @vintid, @dintid, @RouteID, @customerintid,
 			@d_t, @d_d, @Score, 
			@RS0Accel , @RS0Brake , @RS0Corner ,
			@RS1Accel , @RS1Brake , @RS1Corner ,
			@RS2Accel , @RS2Brake , @RS2Corner ,
			@RS3Accel , @RS3Brake , @RS3Corner ,
			@RS4Accel , @RS4Brake , @RS4Corner ,
			@RS5Accel , @RS5Brake , @RS5Corner ,
			@RS6Accel , @RS6Brake , @RS6Corner ,
			@RS7Accel , @RS7Brake , @RS7Corner ,
			@RS8Accel , @RS8Brake , @RS8Corner ,
			@RS9Accel , @RS9Brake , @RS9Corner ,
            GetDate(), 1)

SET @passcomfid = SCOPE_IDENTITY()




GO
