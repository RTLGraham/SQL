SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_WriteAccumNewTemp] @aid bigint=NULL OUTPUT,
	@trackerid varchar(50), @driverid varchar(32), @routenumber varchar(32),
	@creationcid smallint, @creationdt datetime, 
	@closurecid smallint, @closuredt datetime, @closurelat float, @closurelong float,
	
	@d_t int, @d_d float, @d_f float,
	@i_t int, @i_f float,
	@si_t int, @si_f float,
	@ptonm_t int, @ptonm_f float,
	@ptom_t int, @ptom_d float, @ptom_f float,
	@crc_t int, @crc_d float, @crc_f float,
	@rsg_t int, @rsg_d float, @rsg_f float,
	@tg_t int, @tg_d float, @tg_f float,
	@gd_t int, @gd_d float, @gd_f float,
	@coog_t int, @coog_d float, @coog_c smallint,
	@cig_t int, @cig_d float, @cig_f float,
	@bss_t int, @bss_d float, @bss_f float,
	@iss_t int, @iss_d float, @iss_f float,
	@ass_t int, @ass_d float, @ass_f float,
	@os_t int, @os_d float, @os_f float,
	@forpm_t int, @forpm_d float, @forpm_f float,
	@eborpm_t int, @eborpm_d float,
	@aerpm SMALLINT=NULL, @aerpmwd SMALLINT=NULL,
	@dld_t int,
	@sb_t int, @sb_d float, @sb_c smallint,
	@eb_t int, @eb_d float, @eb_c smallint,
	@MaxRPM SMALLINT=NULL, @MaxRPMTS datetime, @MaxRPMLt float, @MaxRPMLg float,
	@MaxRoadSpeedT int, @MaxRoadSpeedD float, @MaxRoadSpeedF float, @MaxRoadSp smallint, @MaxRoadSpeedTS datetime, @MaxRoadSpeedLt float, @MaxRoadSpeedLg float,
	@LongestCoastOutofgearT int, @LongestCoastOutofgearTimeD float, @LongestCoastOutofgearTimeTS datetime, @LongestCoastOutofgearTimeLt float, @LongestCoastOutofgearTimeLg float,
	@LongestIdleT int, @LongestIdleF float, @LongestIdleTS datetime, @LongestIdleLt float, @LongestIdleLg float,
	@panicstopcount smallint,
	@EngineTempMidT int, @EngineTempHighT int, @MaxEngineCoolantTemp smallint,	
	@ael float, @DataVal varchar(50), 
	@OverSpeedHighT int, @OverSpeedHighD float, @OverSpeedHighF float,
	@totalenginehours float, @totalvehicledist float, @totalvehiclefuel float,
	@di1c smallint, @di1at int,
	@di2c smallint, @di2at int,
	@cael float, @rael float, @tael float, @gael float,
	@AverageWeight int,
	@EngineLoad0Time int, @EngineLoad0Distance float, @EngineLoad0Fuel float,
	@EngineLoad100Time int, @EngineLoad100Distance float, @EngineLoad100Fuel float,
	@DriveFuelWhole int, @DriveFuelFrac int,
	@ORCount INT,
	@CTGTime INT = NULL,
	@CTGDistance FLOAT = NULL,
	@CTGFuel FLOAT = NULL,
	@CNGDTime INT = NULL,
	@CNGDDistance FLOAT = NULL,
	@CNGDFuel FLOAT = NULL,

	@CSTime INT = NULL,
	@CSDistance FLOAT = NULL,
	@CSFuel FLOAT = NULL,

	@StatusFlags INT = NULL,

	@TGSTime INT = NULL,
	@TGSDistance FLOAT = NULL,
	@TGSFuel FLOAT = NULL,

	@OSTTime INT = NULL,
	@OSTSDistance FLOAT = NULL,
	@OSTSFuel FLOAT = NULL,

	@SeqNumber INT = NULL
	
AS

-- need to look up 
--	CustomerIntId, VehicleIntId, DriverIntId, RouteID,
DECLARE @customerintid INT, @vintid INT, @ivhintid INT, @dintid INT, @rid INT
DECLARE @customerid UNIQUEIDENTIFIER, @vid UNIQUEIDENTIFIER, @ivhid UNIQUEIDENTIFIER, @did UNIQUEIDENTIFIER

SET @vintid = NULL
SET @dintid = NULL
SET @ivhintid = NULL
SET @customerintid = NULL
SET @customerid = NULL
SET @rid = NULL
SET @vid = NULL
SET @did = NULL
SET @ivhid = NULL

-- Dates used as bounds for customer lookup
declare @sdateinthepast datetime
declare @edateinthefuture datetime
DECLARE @updatelatestdid bit
set @sdateinthepast = '1900-01-01 00:00'
set @edateinthefuture = '2100-01-01 00:00'

-- Set default driver if none provided
IF @driverID = '' OR @driverID IS NULL
BEGIN
	SET @driverid = 'No ID'
END

-- Set default route if none provided
If @routenumber = '' or @routenumber is NULL
BEGIN
	SET @routenumber = 'No Route'
END

-- Code below taken from proc_writeeventnewnonidtemp() with some select columns removed
-- Should place into a fn()
-- get ivh, vehicle and customer details
SELECT @ivhid = IVH.IVHId, @vintid = Vehicle.VehicleIntId, @vid = Vehicle.VehicleId, @customerid = Customer.CustomerId, @customerintid = Customer.CustomerIntId
FROM IVH 
	INNER JOIN Vehicle ON IVH.IVHId = Vehicle.IVHId
	INNER JOIN CustomerVehicle ON Vehicle.VehicleId = CustomerVehicle.VehicleId
	INNER JOIN Customer ON Customer.CustomerId = CustomerVehicle.CustomerId
WHERE TrackerNumber = @trackerid 
	AND IVH.Archived = 0 AND Vehicle.Archived = 0 AND dbo.CustomerVehicle.Archived = 0 AND (IVH.IsTag = 0 OR IVH.IsTag IS NULL)
	AND (GETDATE() BETWEEN ISNULL(StartDate, @sdateinthepast) AND ISNULL(EndDate, @edateinthefuture))

-- If we couldn't find the customer then set to the default customer
IF @customerintid IS NULL
BEGIN
	SET @customerintid = 1
	SET @customerid = dbo.GetCustomerIdFromInt(@customerintid)
END


--Check for the linked driver
SET @did = dbo.GetLinkedDriverId(@vid)

IF @did IS NULL
BEGIN
	--If there is no linked driver - obtain the driver ID from the driver number
	SET @did = dbo.GetDriverIdFromNumberAndCustomer(@driverid, @customerid)
END


IF @did IS NOT NULL
	SET @dintid = dbo.GetDriverIntFromId(@did)
ELSE  -- Driver not found so create one
	BEGIN
		SET @did = NEWID()
		EXEC proc_WriteDriver @did, @dintid OUTPUT, @customerid, @driverid, 'UNKNOWN'
	END

IF @ivhid IS NULL
BEGIN
	DECLARE @reg varchar(20)
	SET @ivhid = NEWID()
	SET @vid = NEWID()
	SET @reg = 'UNKNOWN ' + @trackerid
	
	EXEC proc_WriteIVH @ivhid = @ivhid, @ivhintid = @ivhintid OUTPUT, @trackerid = @trackerid
	EXEC proc_WriteVehicle @vid = @vid, @vintid = @vintid OUTPUT, @ivhid = @ivhid, @customerid = @customerid, @reg = @reg

END

--Write Route
SET @rid = dbo.GetRouteIdFromNumberAndCustomer(@routenumber, @customerid)
IF @rid IS NULL -- route not found so create one
	EXEC proc_WriteRoute @rid OUTPUT, @customerid, @routenumber, 'UNKNOWN'

INSERT INTO AccumTemp
	(
	CustomerIntId, VehicleIntId, DriverIntId, RouteID,
	CreationCodeId, CreationDateTime,
	ClosureCodeId, ClosureDateTime, ClosureLat, ClosureLong,

	DrivingTime, DrivingDistance, DrivingFuel,
	IdleTime, IdleFuel,
	ShortIdleTime, ShortIdleFuel,
	PTONonMovingTime, PTONonMovingFuel,
	PTOMovingTime, PTOMovingDistance, PTOMovingFuel,
	CruiseControlTime, CruiseControlDistance, CruiseControlFuel,
	RSGTime, RSGDistance, RSGFuel,
	TopGearTime, TopGearDistance, TopGearFuel,
	GearDownTime, GearDownDistance, GearDownFuel,
	CoastOutOfGearTime, CoastOutOfGearDistance, CoastOutOfGearCount,
	CoastInGearTime, CoastInGearDistance, CoastInGearFuel,
	BelowSweetSpotTime, BelowSweetSpotDistance, BelowSweetSpotFuel,
	InSweetSpotTime, InSweetSpotDistance, InSweetSpotFuel,
	AboveSweetSpotTime, AboveSweetSpotDistance, AboveSweetSpotFuel,
	OverSpeedTime, OverSpeedDistance, OverSpeedFuel,
	FueledOverRPMTime, FueledOverRPMDistance, FueledOverRPMFuel,
	EngineBrakeOverRPMTime, EngineBrakeOverRPMDistance,
	AverageEngineRPM, AverageEngineRPMWhileDriving,
	DataLinkDownTime,
	ServiceBrakeTime, ServiceBrakeDistance, ServiceBrakeCount,
	EngineBrakeTime, EngineBrakeDistance, EngineBrakeCount,
	MaxRPM, MaxRPMTimestamp, MaxRPMLat, MaxRPMLong,
	MaxRoadSpeedTime, MaxRoadSpeedDistance, MaxRoadSpeedFuel, MaxRoadSpeed, MaxRoadSpeedTimestamp, MaxRoadSpeedLat, MaxRoadSpeedLong,
	LongestCoastOutofgearTime, LongestCoastOutofgearTimeDistance, LongestCoastOutofgearTimeTimestamp, LongestCoastOutofgearTimeLat, LongestCoastOutofgearTimeLong,
	LongestIdleTime, LongestIdleFuel, LongestIdleTimestamp, LongestIdleLat, LongestIdleLong,
	PanicStopCount, 
	EngineTempMidrangeTime, EngineTempHighTime, MaxEngineCoolantTemp,
	AverageEngineLoad, DataValidity,
	OverSpeedHighTime, OverSpeedHighDistance, OverSpeedHighFuel,
	TotalEngineHours, TotalVehicleDistance, TotalVehicleFuel,
	DigitalInput1Count, DigitalInput1ActivationTime,
	DigitalInput2Count, DigitalInput2ActivationTime,
	CruiseAverageEngineLoad, RSGAverageEngineLoad,
	TopGearAverageEngineLoad, GearDownAverageEngineLoad,
	AverageWeight,
	EngineLoad0Time, EngineLoad0Distance, EngineLoad0Fuel,
	EngineLoad100Time, EngineLoad100Distance, EngineLoad100Fuel,
	DriveFuelWhole, DriveFuelFrac,
	ORCount,
	CruiseTopGearTime,
	CruiseTopGearDistance,
	CruiseTopGearFuel,
	CruiseGearDownTime,
	CruiseGearDownDistance,
	CruiseGearDownFuel,
	CruiseSpeedingTime,
	CruiseSpeedingDistance,
	CruiseSpeedingFuel,
	StatusFlags,

	TopGearSpeedingTime,
	TopGearSpeedingDistance,
	TopGearSpeedingFuel,

	OverSpeedThresholdTime,
	OverSpeedThresholdDistance,
	OverSpeedThresholdFuel,

	SeqNumber
	)
VALUES
	(
	@customerintid, @vintid, @dintid, @rid,
	@creationcid, @creationdt, 
	@closurecid, @closuredt, @closurelat, @closurelong,
	
	@d_t, @d_d, @d_f,
	@i_t, @i_f,
	@si_t, @si_f,
	@ptonm_t, @ptonm_f,
	@ptom_t, @ptom_d, @ptom_f,
	@crc_t, @crc_d, @crc_f,
	@rsg_t, @rsg_d, @rsg_f,
	@tg_t, @tg_d, @tg_f,
	@gd_t, @gd_d, @gd_f,
	@coog_t, @coog_d, @coog_c,
	@cig_t, @cig_d, @cig_f,
	@bss_t, @bss_d, @bss_f,
	@iss_t, @iss_d, @iss_f,
	@ass_t, @ass_d, @ass_f,
	@os_t, @os_d, @os_f,
	@forpm_t, @forpm_d, @forpm_f,
	@eborpm_t, @eborpm_d,
	ISNULL(@aerpm,0),  ISNULL(@aerpmwd,0),
	@dld_t,
	@sb_t, @sb_d, @sb_c,
	@eb_t, @eb_d, @eb_c,
	ISNULL(@MaxRPM,0), @MaxRPMTS, @MaxRPMLt, @MaxRPMLg,
	@MaxRoadSpeedT, @MaxRoadSpeedD, @MaxRoadSpeedF, @MaxRoadSp, @MaxRoadSpeedTS, @MaxRoadSpeedLt, @MaxRoadSpeedLg,
	@LongestCoastOutofgearT, @LongestCoastOutofgearTimeD, @LongestCoastOutofgearTimeTS, @LongestCoastOutofgearTimeLt, @LongestCoastOutofgearTimeLg,
	@LongestIdleT, @LongestIdleF, @LongestIdleTS, @LongestIdleLt, @LongestIdleLg,
	@panicstopcount,
	@EngineTempMidT, @EngineTempHighT, @MaxEngineCoolantTemp,	
	@ael, @DataVal, 
	@OverSpeedHighT, @OverSpeedHighD, @OverSpeedHighF,
	@totalenginehours, @totalvehicledist, @totalvehiclefuel,
	@di1c, @di1at,
	@di2c, @di2at,
	@cael, @rael, @tael, @gael,
	@AverageWeight,
	@EngineLoad0Time, @EngineLoad0Distance, @EngineLoad0Fuel,
	@EngineLoad100Time, @EngineLoad100Distance, @EngineLoad100Fuel,
	@DriveFuelWhole, @DriveFuelFrac,
	@ORCount,
	@CTGTime,
	@CTGDistance,
	@CTGFuel,
	@CNGDTime,
	@CNGDDistance,
	@CNGDFuel,
	@CSTime,
	@CSDistance,
	@CSFuel,
	@StatusFlags,

	@TGSTime,
	@TGSDistance,
	@TGSFuel,

	@OSTTime,
	@OSTSDistance,
	@OSTSFuel,

	@SeqNumber
	)

-- Return AccumId
SET @aid = SCOPE_IDENTITY()

GO
